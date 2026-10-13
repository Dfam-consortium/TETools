#!/bin/sh

# Dfam TE Tools container wrapper script.
# See https://github.com/Dfam-consortium/TETools for more information
# about the Dfam TE Tools container.

set -eu

die() {
	printf "%s\n" "$*" >&2
	exit 1
}

usage() {
printf "%s\n" "Usage: dfam-tetools.sh [-h|--help]
	[--container=/path/to/dfam-tetools.sif | --container=dfam/tetools:tag]
	[--docker | --singularity]
	[--famdb=/path/to/famdb]
	[-- command [arg1 [arg2 [...]]]]

--container	Choose a specific container to use (a .sif file or a docker image ID or tag)
--docker	    Run the container via docker
--singularity	Run the container via singularity
--famdb         Path to an external FamDB installation (the directory containing famdb.py).
                It is mounted in the container at /famdb.  If not given, the FAMDB_DIR
                environment variable is used instead, if set.
command		    A command to run in the container instead of an interactive shell

If neither --docker nor --singularity is specified and both
programs are available, singularity is preferred."
}


## Parse command-line arguments ##

container="dfam/tetools:2.01"
use_docker=0
use_singularity=0
famdb_dir=""
bind_cmd=""

while [ $# -ge 1 ]; do
	opt="$1"
	shift
	case "$opt" in
	--)
		break
		;;
	--*=*)
		# Normalize "--x=y" format to "--x" "y" and try again
		set -- "${opt%%=*}" "${opt#*=}" "$@"
		;;
	--container)
		container="$1"
		shift
		;;
	-h|--help)
		usage >&2
		exit 0
		;;
	--trf_prgm)
		echo "Notice: Since Dfam TE Tools 1.2, TRF is included in the container.
The --trf_prgm parameter was ignored." >&2
		shift
		;;
	--docker)
		use_docker=1
		;;
	--singularity)
		use_singularity=1
		;;
	--famdb)
		famdb_dir="$1"
		shift
		;;
	--library)
		die "Error: The --library option was removed in Dfam TE Tools 2.00.
RepeatMasker and RepeatModeler now read Dfam directly from FamDB, and
tetoolsDfamUpdate.pl is no longer used. To use additional Dfam partitions,
install FamDB on the host and use --famdb instead. See the README section
\"Using an external FamDB installation\":
  https://github.com/Dfam-consortium/TETools#using-an-external-famdb-installation"
		;;
	*)
		die "Unrecognized argument: $opt
A command to run in the container must be preceded by a --"
		;;
	esac
done


## Check argument validity ##

# Ensure exactly one of docker or singularity is used
case $(( use_docker + use_singularity )) in
0)	if command -v singularity >/dev/null 2>&1; then
		use_singularity=1
	elif command -v docker >/dev/null 2>&1; then
		use_docker=1
	else
		die "Error: This script requires singularity or docker to be installed and available in PATH."
	fi;;
1)	;;
*)	die "Only one of --docker or --singularity can be specified.";;
esac

# Ensure the container name makes sense
if [ "$use_singularity" = 1 ] && ! [ -e "$container" ]; then
	# If a file named "$container" does not exist,
	# we assume that "container" is a docker image reference.
	# Singularity uses docker:// syntax for these
	container="docker://$container"
fi

# If --famdb was not given, fall back to a FAMDB_DIR set in the host
# environment. Either way the directory is mounted into the container at
# /famdb, as a host path is not necessarily visible inside the container.
famdb_src="--famdb"
if [ -z "$famdb_dir" ] && [ -n "${FAMDB_DIR-}" ]; then
	famdb_dir="$FAMDB_DIR"
	famdb_src="FAMDB_DIR"
fi
unset FAMDB_DIR

# Ensure the FamDB directory is a FamDB installation (not just a directory
# of *.h5 partition files)
if [ -n "$famdb_dir" ]; then
	if ! [ -f "$famdb_dir/famdb.py" ]; then
		die "Error: $famdb_src must point to a FamDB installation directory
(the directory containing famdb.py), but '$famdb_dir/famdb.py' was not found.
Install FamDB from https://github.com/Dfam-consortium/FamDB and use its
utils/download_dfam.py script to download the Dfam partitions you need."
	fi
	# Bind mounts require an absolute path
	famdb_dir=$(cd "$famdb_dir" && pwd)
	echo "Using external FamDB ($famdb_src): mounting $famdb_dir at /famdb (FAMDB_DIR=/famdb)" >&2
fi

## Run the container ##

if [ "$use_docker" = 1 ]; then
	if [ -n "$famdb_dir" ]; then
		bind_cmd="--mount type=bind,source=$famdb_dir,target=/famdb"
		FAMDB_DIR="/famdb"
	fi
	docker run -it --rm \
		--init \
		$bind_cmd \
		${FAMDB_DIR:+-e FAMDB_DIR="$FAMDB_DIR"} \
		--user "$(id -u):$(id -g)" \
		--workdir "/opt" \
		"$container" \
		"$@"
elif [ "$use_singularity" = 1 ]; then
	if [ -n "$famdb_dir" ]; then
		bind_cmd="-B $famdb_dir:/famdb"
		FAMDB_DIR="/famdb"
	fi
	#
	# Singularity maps the users home directory and thus when
	# using with a shell it would typically read in the home/.bashrc
	# file.  This has been known to cause issues -- for example the
	# user's path points to a non-existent directory or overrides 
	# the python interpreter with uninstalled dependencies etc.
	# To avoid this, we use --norc and --noprofile to prevent bash 
	# from reading these files.
	#
	if [ $# -eq 0 ]; then
		set -- /bin/bash --norc --noprofile -i
	fi
	export LANG=C
        singularity exec \
            --cleanenv \
	    ${FAMDB_DIR:+--env FAMDB_DIR="$FAMDB_DIR"} \
            $bind_cmd \
            "$container" \
	    "$@"
fi


# vi: noet ts=8 sw=0 sts=-1

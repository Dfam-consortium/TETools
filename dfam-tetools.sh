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
	[--library]
	[-- command [arg1 [arg2 [...]]]]

--container	Choose a specific container to use (a .sif file or a docker image ID or tag)
--docker	    Run the container via docker
--singularity	Run the container via singularity
--library       A directory containing modified RepeatMasker/Libraries files
command		    A command to run in the container instead of an interactive shell

If neither --docker nor --singularity is specified and both
programs are available, singularity is preferred."
}


## Parse command-line arguments ##

container="dfam/tetools:1.94"
use_docker=0
use_singularity=0
use_lib=0
workdir=""
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
	--library)
		use_lib=1
		workdir="$1"
		shift
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

## Run the container ##

if [ "$use_docker" = 1 ]; then
	if [ "$use_lib" = 1 ]; then
		bind_cmd="--mount type=bind,source=$workdir,target=/opt/RepeatMasker/Libraries"
	fi
	docker run -it --rm \
		--init \
		$bind_cmd \
		--user "$(id -u):$(id -g)" \
		--workdir "/opt" \
		"$container" \
		"$@"
elif [ "$use_singularity" = 1 ]; then
	if [ "$use_lib" = 1 ]; then
		bind_cmd="-B $workdir:/opt/RepeatMasker/Libraries"
	fi
	if [ $# -eq 0 ]; then
		set -- "/bin/bash"
	fi
	export LANG=C
	singularity exec \
		$bind_cmd \
		"$container" \
		"$@"
fi


# vi: noet ts=8 sw=0 sts=-1

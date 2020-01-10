#!/bin/sh

# Dfam TE Tools container wrapper script.
# See https://github.com/Dfam-consortium/TETools for more information
# about the Dfam TE Tools container.

set -eu

workdir="$(pwd)"

# find_command name1 name2 name3 ...
# Prints the full name (as reported by command -v) for the first
# name that can be found. Exits with status 1 if no command matches
find_command() (
	for attempt; do
		if found="$(command -v "$attempt" 2>/dev/null)"; then
			printf "%s\n" "$found"
			return 0
		fi
	done
	return 1
)

die() {
	printf "%s\n" "$*" >&2
	exit 1
}

usage() {
printf "%s\n" "Usage: dfam-tetools.sh [-h|--help]
	[--container=/path/to/dfam-tetools.sif | --container=dfam/tetools:tag]
	[--trf_prgm=/path/to/trf]
	[--docker | --singularity]
	[-- command [arg1 [arg2 [...]]]]

--container	Choose a specific container to use (a .sif file or a docker image ID or tag)
--trf_prgm	The path to the TRF binary
--docker	Run the container via docker
--singularity	Run the container via singularity
command		A command to run in the container instead of an interactive shell

If neither --docker nor --singularity is specified and both
programs are available, singularity is preferred."
}


## Parse command-line arguments ##

container="dfam/tetools:1"
trf_path=
use_docker=0
use_singularity=0

# getopt does some checking and reformats the options string
if ! optstr=$(getopt --name "${0##*/}" --shell sh --options -h --longoptions help,container:,trf_prgm:,docker,singularity -- "$@"); then
	usage >&2
	exit 1
fi

eval set -- "$optstr"

while [ $# -ge 1 ]; do
	opt="$1"
	shift
	case "$opt" in
	--)
		break
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
		trf_path="$1"
		shift
		;;
	--docker)
		use_docker=1
		;;
	--singularity)
		use_singularity=1
		;;
	*)
		die "Unexpected argument: $opt
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

# Try several different names for the TRF command if not specified
if [ -z "$trf_path" ]; then
	if ! trf_path="$(find_command trf trf.legacylinux64 trf.linux64 trf409.legacylinux64 trf409.linux64)"; then
		# TRF could not be found
		die "Error: Could not find a suitable TRF program.
Ensure trf is available in your PATH and is executable,
or specify the path with --trf-path=/path/to/trf"
	fi
fi

trf_path="$(readlink -f "$trf_path")"

# Ensure TRF exists...
if ! [ -e "$trf_path" ]; then
	die "Error: The specified TRF program at \"$trf_path\" does not exist.
Ensure trf is available in your PATH and is executable,
or specify the path with --trf-path=/path/to/trf"
fi

# ... and is executable
if ! [ -x "$trf_path" ]; then
	die "Error: TRF was found at \"$trf_path\" but it is not executable.
Ensure it is executable and try again, or specify the correct path with --trf=path=/path/to/trf"
fi


## Run the container ##

if [ "$use_docker" = 1 ]; then
	docker run -it --rm \
		--mount type=bind,source="$workdir",target=/work \
		--mount type=bind,source="$trf_path",target=/opt/trf,ro \
		--user "$(id -u):$(id -g)" \
		--workdir "/work" \
		--env "HOME=/work" \
		"$container" \
		"$@"
elif [ "$use_singularity" = 1 ]; then
	if [ $# -eq 0 ]; then
		set -- "/bin/bash"
	fi
	export LANG=C
	singularity exec \
		-B "$trf_path":/opt/trf:ro \
		"$container" \
		"$@"
fi


# vi: noet ts=8 sw=0 sts=-1

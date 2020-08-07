# Dfam TE Tools Container

Dfam TE Tools includes RepeatMasker, RepeatModeler, and coseg. This container is
an easy way to get a minimal yet fully functional installation of RepeatMasker
and RepeatModeler and is additionally useful for testing or reproducibility
purposes.

You should consider using the Dfam TE Tools container if:

* You or your computing environment already use docker or singularity
* You are uncomfortable compiling dependencies by hand or have had problems
  doing so
* You do not need to use any of the other tools (e.g. RMBlast, HMMER) for
  anything besides RepeatMasker and RepeatModeler

You should install RepeatMasker and/or RepeatModeler manually if:

* You do not have the necessary system permissions to install and/or run docker
  or singularity
* You need to install a different version of a dependency
* You need to compile a dependency in a specific way
* You need to use RepeatMasker as part of another pipeline
* You need to use AB-BLAST or Cross-Match. Either AB-BLAST or Cross-Match can
  probably be used with this container, but it is inconvenient and not tested.

## Using the Container

### Requirements

* A 64-bit Linux operating system. Other platforms (e.g. macOS) might work with
  extra effort but are not tested.
* `singularity` or `docker` installed with permissions to run containers. For
  `docker`, this usually means being in the `docker` group or running the
  container as the `root` user.

### Using the Wrapper Script

We provide a wrapper script, `dfam-tetools.sh`, which does most of the work automatically.

The wrapper script does the following:
* Runs the container from Docker Hub. This can be overridden with the
  `--container` flag if you want to use a different version than the default or
  if you have a specific `.sif` file for singularity.
* Uses `singularity` if it is available, `docker` otherwise. You can change this
  default with `--docker` or `--singularity` flags.
* Runs the container as the current user, in the current working directory

```
$ curl -sSLO https://github.com/Dfam-consortium/TETools/raw/master/dfam-tetools.sh
$ chmod +x dfam-tetools.sh
$ ./dfam-tetools.sh
```

Inside the container, the included tools are now available:

```
$ BuildDatabase -name genome1 genome1.fa
$ RepeatModeler -database genome1 [-LTRStruct] [-pa 8]

$ RepeatMasker genome1.fa [-lib library.fa] [-pa 8]

$ runcoseg.pl -d -m 50 -c ALU.cons -s ALU.seqs -i ALU.ins
```

### Running the Container Manually

The container can also be run manually, bypassing the wrapper script:

* `docker run -it --rm dfam/tetools:latest`
* `singularity run docker://dfam/tetools:latest`

When running the container manually, you will also need to set the UID/GID,
directories to mount, and so on according to your specific situation. By
default singularity mounts the current directory and your `HOME` directory;
docker does neither.

### Using RepBase RepeatMasker Edition

If you wish to use RepBase RepeatMasker Edition with the container, you will
need to perform some additional setup. These commands should be read as a
container-specific extension to the instructions at
<http://www.repeatmasker.org/RMDownload.html>.  These commands assume that
RepBaseRepeatMaskerEdition-######.tar.gz is accessible inside the container.

Once inside the container:
```
# Navigate to an appropriate directory that is persistent outside the container
$ cd /work

# Make a copy of RepeatMasker's Libraries directory here
$ cp -r /opt/RepeatMasker/Libraries/ ./

# Extract RepBase (the .tar.gz file unpacks files into Libraries/)
$ tar -x -f /work/path/to/RepBaseRepeatMaskerEdition-#######.tar.gz

# Run RepeatMasker with the LIBDIR environment variable set. RepeatMasker will
# detect the addition of RepBase RepeatMasker Edition and rebuild its cached
# libraries automatically as needed.
$ export LIBDIR=/path/to/Libraries
$ RepeatMasker genome.fa
```

In future runs you can reuse the same `Libraries/` directory by setting `LIBDIR`
again. Each time you update RepeatMasker, including a new version of the TETools
container, you should re-create your custom Libraries directory if you use one.

## Building the Container

You'll need:

* `curl`
* `docker`, with permissions to build containers
* `singularity` (optional) - if building a singularity container

```
# Download dependencies
$ ./getsrc.sh

# Build a docker container
$ docker build -t org/name:tag .

# (optional) build a singularity container
$ singularity build dfam-tetools.sif dfam-tetools.def
```

## Included software

The following software is included in the Dfam TE Tools container (version `<unreleased>`):

| | | |
| -------------- | -------- | --- |
| RepeatModeler  | 2.0.1    | <http://www.repeatmasker.org/RepeatModeler/>
| RepeatMasker   | 4.1.0    | <http://www.repeatmasker.org/RMDownload.html>
| coseg          | 0.2.2    | <http://www.repeatmasker.org/COSEGDownload.html>
| | | |
| RMBlast        | 2.10.0   | <http://www.repeatmasker.org/RMBlast.html>
| HMMER          | 3.3      | <http://hmmer.org/>
| TRF            | 4.09.1   | <https://github.com/Benson-Genomics-Lab/TRF> |
| RepeatScout    | 1.0.6    | <http://www.repeatmasker.org/RepeatScout-1.0.6.tar.gz>
| RECON          | 1.08     | <http://www.repeatmasker.org/RepeatModeler/RECON-1.08.tar.gz>
| cd-hit         | 4.8.1    | <https://github.com/weizhongli/cdhit>
| genometools    | 1.6.0    | <https://github.com/genometools/genometools>
| LTR\_retriever | 2.9.0    | <https://github.com/oushujun/LTR_retriever/>
| MAFFT          | 7.471    |  <https://mafft.cbrc.jp/alignment/software/>
| NINJA          | 0.97-cluster\_only | <https://github.com/TravisWheelerLab/NINJA>

## License
The Dfam TE Tools container project (the `Dockerfile` and associated build and
run scripts) is licensed under the CC 1.0 Universal Public Domain Dedication.
The software packages included in the container have their own associated
license terms; see the individual software packages for details.

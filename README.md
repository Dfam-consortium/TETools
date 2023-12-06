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

* A 64-bit Linux operating system, or appropriate virtualization software.
  Docker for Mac is known to work, including the wrapper script, but we do not
  regularly test this platform ourselves.
* `singularity` or `docker` installed with permissions to run containers. For
  `docker`, this usually means being in the `docker` group or running the
  container as the `root` user.

### Using the Wrapper Script

We provide a wrapper script, `dfam-tetools.sh`, which does most of the work automatically.

The wrapper script does the following:
* Runs the container from Docker Hub. You can also use the `--container` option to
  specify a different version of the container or an `.sif` file for singularity.
* Uses `singularity` if it is available, or `docker`. You can choose between them
  with the `--docker` or `--singularity` options.
* Runs the container as the current user, with the current working directory accessible
  from within the container. Depending on the environment and the software used, this
  directory appears inside the container at its original location and/or at the path `/work`.

```
curl -sSLO https://github.com/Dfam-consortium/TETools/raw/master/dfam-tetools.sh
chmod +x dfam-tetools.sh
./dfam-tetools.sh
```

Inside the container, the included tools are now available:

```
BuildDatabase -name genome1 genome1.fa
RepeatModeler -database genome1 [-LTRStruct] [-threads 16]

RepeatMasker genome1.fa [-lib library.fa] [-pa 8]

runcoseg.pl -d -m 50 -c ALU.cons -s ALU.seqs -i ALU.ins
```

### Running the Container Manually

The container can also be run manually, bypassing the wrapper script:

* `docker run -it --rm dfam/tetools:latest`
* `singularity run docker://dfam/tetools:latest`

When running the container manually, you will also need to set the UID/GID,
directories to mount, and so on according to your needs. By default singularity
mounts the current directory and your `HOME` directory; docker does neither.

You can also use `singularity pull` to download the container to a file:

```
singularity pull dfam-tetools-latest.sif docker://dfam/tetools:latest
singularity run dfam-tetools-latest.sif
```

### Customizing the RepeatMasker libraries
<!-- previous header name / link: --><a id="using-repbase-repeatmasker-edition"></a>

By default, RepeatMasker only includes the curated entries from the <a
href="https://www.dfam.org/">Dfam</a> database. Additional setup is needed to
install the full Dfam database including uncurated entries and/or to install
RepBase RepeatMasker Edition for use with the container. This is a different
process from using a custom library of FASTA or HMM models, which can be
accomplished by using the `-lib` option to `RepeatMasker`.

Modifying the container can become a quite complex task, depending on which
software and versions are being used and how the system is configured. Instead
of modifying the container or software directly, these instructions will create
a separate directory for the new libraries.

You will need access to the following files and directories from inside the
container.

* A location on the host system ("outside" the container) to store the new `Libraries/`
* (for Dfam) the full Dfam database including uncurated entries, `Dfam.h5`
* (for RepBase) RepBase RepeatMasker Edition, `RepBaseRepeatMaskerEdition-######.tar.gz`

```sh
# If needed, first change to the directory which corresponds to the host system.
# (dfam-tetools.sh does this automatically)
cd /work

# Make a copy of the original RepeatMasker Libraries/ directory here
cp -r /opt/RepeatMasker/Libraries/ ./

## If desired, update Dfam:
## ========================
# Overwrite the new Dfam.h5 file into Libraries/
cp Dfam.h5 Libraries/
# Update the file RepeatMaskerLib.h5 to the new Dfam.h5
ln -sf Dfam.h5 Libraries/RepeatMaskerLib.h5

## If desired, add RepBase RepeatMasker Edition:
## =============================================
# Extract RepBase RepeatMasker Edition (the .tar.gz file should unpack into Libraries/)
tar -x -f /work/path/to/RepBaseRepeatMaskerEdition-#######.tar.gz
# Run the addRepBase.pl script (part of the RepeatMasker package) to merge the databases,
# specifying the new Libraries directory.
addRepBase.pl -libdir Libraries/
```

You can now specify this `Libraries/` directory by setting the `LIBDIR`
environment variable, for example with the `export LIBDIR=` command or `-e
LIBDIR=` depending on you are running the container. When you use a new version
of the TETools container (particularly a new RepeatMasker), you should
re-create the `Libraries` directory for the new version.

```sh
# Set the LIBDIR environment variable before running RepeatMasker
export LIBDIR=/path/to/Libraries
RepeatMasker genome.fa
```

## Building the Container

You will need:

* `curl`
* `docker`, with permissions to build containers
* `singularity` (optional) - if building a singularity container

```sh
# Download dependencies
./getsrc.sh

# Build a docker container
docker build -t org/name:tag .

# (optional) build a singularity container
singularity build dfam-tetools.sif dfam-tetools.def
```

## Included software

The following software is included in the Dfam TE Tools container (version `1.88`):

| | | |
| -------------- | -------- | --- |
| RepeatModeler  | 2.0.5    | <http://www.repeatmasker.org/RepeatModeler/>
| RepeatMasker   | 4.1.6    | <http://www.repeatmasker.org/RMDownload.html>
| coseg          | 0.2.3    | <http://www.repeatmasker.org/COSEGDownload.html>
| | | |
| RMBlast        | 2.14.1   | <http://www.repeatmasker.org/RMBlast.html>
| HMMER          | 3.3.2    | <http://hmmer.org/>
| TRF            | 4.09.1   | <https://github.com/Benson-Genomics-Lab/TRF> |
| RepeatScout    | 1.0.6    | <http://www.repeatmasker.org/RepeatScout-1.0.6.tar.gz>
| RECON          | 1.08     | <http://www.repeatmasker.org/RepeatModeler/RECON-1.08.tar.gz>
| cd-hit         | 4.8.1    | <https://github.com/weizhongli/cdhit>
| genometools    | 1.6.4    | <https://github.com/genometools/genometools>
| LTR\_retriever | 2.9.0    | <https://github.com/oushujun/LTR_retriever/>
| MAFFT          | 7.471    |  <https://mafft.cbrc.jp/alignment/software/>
| NINJA          | 0.97-cluster\_only | <https://github.com/TravisWheelerLab/NINJA>
| UCSC utilities\* | v413 | <http://hgdownload.soe.ucsc.edu/admin/exe/>>

\* Selected tools only: `faToTwoBit`, `twoBitInfo`, `twoBitToFa`

## License
The Dfam TE Tools container project (the `Dockerfile` and associated build and
run scripts) is licensed under the CC 1.0 Universal Public Domain Dedication.
The software packages included in the container have their own associated
license terms; see the individual software packages for details.

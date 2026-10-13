# Dfam TE Tools Container

Dfam TE Tools includes various Transposable Element discovery, annotation and
curation tools developed by various members of the Dfam consortium. This container is
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

Currently, RepeatMasker is installed with the Dfam 4.0 curated consensus FamDB component.
It will also support annotation with custom libraries (using the -lib mylib.fa command line option).  

#### Do I need an external FamDB?

The container's built in FamDB includes the complete set of Dfam 4.0 curated
consensus sequences and the TE protein library. For many uses no additional
setup is needed:

| Task | External FamDB needed? |
| ---- | ---------------------- |
| RepeatModeler / RepeatClassifier | No |
| RepeatMasker `-lib mylib.fa` | No |
| RepeatMasker `-species`, curated, w/consensus | No |
| RepeatMasker `-species`, w/pHMMs | Yes - Dfam curated HMM partitions |
| RepeatMasker `-species`, uncurated families | Yes - Dfam uncurated partitions |
| RepeatMasker `-species`, with RepBase | Yes - RepBase merged into FamDB |

#### Using an external FamDB installation

Additional setup is necesary to use TE libraries such as Dfam pHMMs, uncurated families, or RepBase.
Modifying the container can become a quite complex task, depending on
which software and versions are being used and how the system is configured. Instead
these instructions will demonstrate how to override the container's built in FamDB installation
and use an external one.

> **Note:** Earlier releases of TE Tools (1.x) used the `tetoolsDfamUpdate.pl`
> script and the wrapper's `--library` option to bind a modified
> `RepeatMasker/Libraries` directory into the container. Both were removed in
> 2.00 and are no longer needed. Do not bind anything over
> `/opt/RepeatMasker/Libraries`; use an external FamDB installation as
> described below instead.

To install FamDB and download Dfam data partitions, follow the instructions at
[https://github.com/Dfam-consortium/FamDB](https://github.com/Dfam-consortium/FamDB).
In short: download and unpack the FamDB release, then run its downloader
(`utils/download_dfam.py`) from inside the FamDB directory to fetch the
partitions you need into its `Libraries/famdb` folder. The FamDB README
describes the available partitions, how to download them, and how to verify
the installation (e.g. `./famdb.py check "<species>"`).

Once you have a FamDB installation directory (the directory containing
`famdb.py`) on the host filesystem, direct the container to
use it in one of three ways:

**Wrapper script flag** (recommended):
```sh
./dfam-tetools.sh --famdb /path/to/famdb -- RepeatMasker genome.fa
./dfam-tetools.sh --famdb /path/to/famdb -- RepeatModeler -database genome1
```

**Environment variable** (convenient for multiple runs or scripting):
```sh
export FAMDB_DIR=/path/to/famdb
./dfam-tetools.sh -- RepeatMasker genome.fa
```

**Command-line flag** (when running tools directly inside the container):
```sh
RepeatMasker --famdb_dir /path/to/famdb genome.fa
RepeatModeler --famdb_dir /path/to/famdb -database genome1
```

When using `--famdb` (or `FAMDB_DIR`) with the wrapper script, the directory is
mounted into the container at `/famdb` and `FAMDB_DIR` is set to `/famdb`
automatically; the wrapper prints a message to the screen when it does this.
If both are given, `--famdb` takes precedence. When running the
container manually, mount the directory yourself and set `FAMDB_DIR` or use
`--famdb_dir` directly:
```sh
# Docker
docker run -it --rm -v /path/to/famdb:/famdb -e FAMDB_DIR=/famdb dfam/tetools:<tag>

# Singularity
singularity exec --cleanenv -B /path/to/famdb:/famdb --env FAMDB_DIR=/famdb docker://dfam/tetools:<tag> /bin/bash --norc --noprofile
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

# or 
docker build --network host -t org/name:tag .

# (optional) build a singularity container
singularity build dfam-tetools.sif dfam-tetools.def
```

## Included software

The following software is included in the Dfam TE Tools container (version `2.01`):

| | | |
| -------------- | -------- | --- |
| RepeatModeler  | 2.0.9    | <https://github.com/Dfam-consortium/RepeatModeler>
| RepeatMasker   | 4.2.6    | <https://github.com/Dfam-consortium/RepeatMasker>
| FamDB          | 3.0.0    | <https://github.com/Dfam-consortium/FamDB>
| coseg          | 0.2.3    | <http://www.repeatmasker.org/COSEGDownload.html>
| RMBlast        | 2.17.1   | <http://www.repeatmasker.org/RMBlast.html>
| HMMER          | 3.4      | <http://hmmer.org/>
| TRF            | 4.09.1   | <https://github.com/Benson-Genomics-Lab/TRF> |
| RepeatScout    | 1.0.7    | <https://github.com/Dfam-consortium/RepeatScout>
| RECON          | 1.10     | <http://https://github.com/Dfam-consortium/RECON>
| cd-hit         | 4.8.1    | <https://github.com/weizhongli/cdhit>
| genometools    | 1.6.4    | <https://github.com/genometools/genometools>
| LTR\_retriever | 2.9.0    | <https://github.com/oushujun/LTR_retriever/>
| MAFFT          | 7.471    |  <https://mafft.cbrc.jp/alignment/software/>
| NINJA          | 1.00-cluster\_only | <https://github.com/TravisWheelerLab/NINJA>
| UCSC utilities\* | v413 | <http://hgdownload.soe.ucsc.edu/admin/exe/>
| RepeatAfterMe | 0.0.7 | <https://github.com/Dfam-consortium/RepeatAfterMe>

\* Selected tools only: `faToTwoBit`, `twoBitInfo`, `twoBitToFa`

## License
The Dfam TE Tools container project (the `Dockerfile` and associated build and
run scripts) is licensed under the CC 1.0 Universal Public Domain Dedication.
The software packages included in the container have their own associated
license terms; see the individual software packages for details.

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
## 1.93
### Updated
- RepeatMasker: `4.1.9` -> `4.2.0`
- RepeatModeler: `2.0.6` -> `2.0.7`
### Added
- RepeatAfterMe: `0.0.7`

## 1.92
### Updated
- RepeatMasker: `4.1.8` -> `4.1.9`

## 1.91
### Updated
- RepeatMasker: `4.1.7-p1` -> `4.1.8`

## 1.90
### Updated
- RepeatModeler: `2.0.5` -> `2.0.6`
- RepeatScout: `1.0.6` -> `1.0.7`

## 1.89.1
### Updated
- RepeatMasker: `4.1.7` -> `4.1.7-p1`

## 1.89
### Updated
- RepeatMasker: `4.1.6` -> `4.1.7`
- NINJA: `0.99-cluster_only` ->  `1.00-cluster_only`

## 1.88.5
### Updated
- HMMER: `3.3.2` -> `3.4`
- NINJA: `0.97-cluster_only` -> `0.99-cluster_only`

## 1.88 - 2023-12/11
### Updated
- RepeatMasker: `4.1.5` -> `4.1.6`

## 1.87 - 2023-10/17
### Updated
- genometools: `1.6.0` -> `1.6.4`
- coseg: `0.2.2` -> `0.2.3`

## 1.86 - 2023-10/09
### Updated
- RMBlast: `2.14.0` -> `2.14.1`
- RepeatModeler: `2.0.4` -> `2.0.5`

## 1.85 - 2023-5/09
### Updated
- RMBlast:  `2.13.0` -> `2.14.0`

## 1.8 - 2023-3/23
### Updated
- RepeatMasker:  `4.1.4` -> `4.1.5`

## 1.7 - 2022-11/29
### Updated
- RepeatMasker:  `4.1.3-p1` -> `4.1.4`
- RepeatModeler: `2.0.3` -> `2.0.4`
- RMBlast:       `2.11.0` -> `2.13.0`

## 1.6 - 2022-10-18
### Updated
- RepeatMasker: `4.1.2-p1` -> `4.1.3-p1`

## 1.5 - 2022-02-09
### Updated
- RepeatModeler: `2.0.2a` -> `2.0.3`
### Changed
- Updated and expanded upon several sections of the README

## 1.4 - 2021-05-03
### Added
- Installed `ps` in the container, for compatibility with Nextflow tracing/metrics
### Updated
- RepeatModeler: `2.0.1` -> `2.0.2`
- UCSC utilities: `v407` -> `v413`

## 1.3.1 - 2021-04-01
### Updated
- RepeatMasker: `4.1.2` -> `4.1.2-p1`

## 1.3 - 2021-03-23
### Added
- Installed `strace` in the container
- Added several of the UCSC utilities (`faToTwoBit`, `twoBitInfo`, `twoBitToFa`).
  These tools are used by some of the scripts in `RepeatModeler/util`.
### Updated
- HMMER: `3.3` -> `3.3.2`
- RepeatMasker: `4.1.1` -> `4.1.2`
- RMBlast: `2.10.0` -> `2.11.0`
    * Upstream BLAST+ 2.11.0 introduced opt-out reporting of usage statistics,
      which is also included in RMBlast 2.11.0. See
      <http://www.repeatmasker.org/RMBlast.html> for more details. To opt out
      of this, set the environment variable `BLAST_USAGE_REPORT=false` (e.g.
      with the `-e` option to `docker run`, or the `--env` option for
      `singularity exec`)
### Fixed
- coseg: set a working path to a perl interpreter in `.pl` scripts

## 1.2 - 2020-09-09
### Added
- TRF: `4.09.1`
### Updated
- LTR_retriever: `2.8` -> `2.9.0`
- MAFFT: `7.453` -> `7.471`
- RepeatMasker: `4.1.0` -> `4.1.1`
### Changed
- dfam-tetools.sh: `--trf_prgm` is no longer necessary and is ignored
### Fixed
- dfam-tetools.sh: Fix compatibility with macOS (fixes #3)
- dfam-tetools.sh: Use the '--init' option when running docker to avoid a zombie apocalypse (fixes #2)

## 1.1 - 2020-01-13
### Updated
- LTR_retriever: `2.7` -> `2.8`
- genometools: `1.5.10` -> `1.6.0`
- HMMER: `3.2.1` -> `3.3`
- RepeatModeler: `2.0` -> `2.0.1`
- RMBlast: `2.9.0-p2` -> `2.10.0`
- MAFFT: `7.429` -> `7.453`

### Changed
- Use the C locale for singularity when running via dfam-tetools.sh,
  silencing some warnings from perl programs.

### Fixed
- Fixed the HMMER path for RepeatMasker, so that -engine hmmer will work properly.

## 1.0 - 2019-11-15
### Added
- First release.

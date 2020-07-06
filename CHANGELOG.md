# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased
### Added
- TRF: `4.09.1`
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

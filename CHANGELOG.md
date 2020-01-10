# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased
### Updated
- LTR_retriever: `2.7` -> `2.8`
- genometools: `1.5.10` -> `1.6.0`
- HMMER: `3.2.1` -> `3.3`
- RepeatModeler: `2.0` -> `2.0.1`

### Changed
- Use the C locale for singularity when running via dfam-tetools.sh,
  silencing some warnings from perl programs.

### Fixed
- Fixed the HMMER path for RepeatMasker, so that -engine hmmer will work properly.

## 1.0 - 2019-11-15
### Added
- First release.

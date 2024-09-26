# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)

## Unreleased

### Added

- Added the `nqrun` operation
- Added BATS-enabled automated testing
- Added access to QAL 9000 via tergite SDK
- Added access to Helmi via qiskit-iqm
- Added `examples` folder with example scripts and Python requirements files

### Changed
- Updated `README.md` to contain example on how to run on Helmi

### Fixed

- Import of `qiskit_iqm` library in `sample.py` fixture
- Fix the `qiskit_iqm` library version to `13.15` which is currently supported by VTT quantum computers

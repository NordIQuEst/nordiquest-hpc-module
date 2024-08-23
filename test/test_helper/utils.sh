#!/bin/bash

# This code is part of NordIQuEst
#
# (C) Copyright Martin Ahindura 2024
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

# common utilities useful for all tests

load_nordiquest_sh() {
  # variables
  mocks=()
  # get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"

   # extract args
  while [[ $# -gt 0 ]]; do
    case $1 in
      --mock)
        mocks+="$2"
        shift # past argument
        shift # past value
        ;;
    esac
  done

  # load all mocks before loading the nordiquest script
  for mock in "${mocks[@]}"; do
    load "$mock";
  done

  # make the functions in nordiquest script available to tests
  load "$DIR/../nordiquest.sh" "$@"
}
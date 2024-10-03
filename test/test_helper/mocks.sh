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

# A collection of mocks

# A mock of slurm's srun command: https://slurm.schedmd.com/srun.html
function srun () {
  bash_script=""
  # extract args
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        echo " Some random stuff from srun";
        return 0
        ;;
      *)
        if [ -z "$2" ]; then 
          # current element is last thus it is the script file
          bash_script="$1";
        else 
          printf "%s " "$1"
        fi
        shift
        ;;
    esac
  done

  if [ -n "$bash_script" ]; then 
    # run the bash script wrapped around the python script
    $bash_script;
  fi
}


# A mock of the https://modules.readthedocs.io/en/latest/ modules utility
function module () {
  # extract args
  while [[ $# -gt 0 ]]; do
    case $1 in
      load)
        echo "$2 module loaded";
        return 0
        ;;
      unload)
        echo "$2 module unloaded";
        return 0
        ;;
    esac
  done
}


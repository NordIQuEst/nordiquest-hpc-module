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

# Bash script to run quantum computing jobs on SLURM-managed high-perfromance computers (HPC)
# Note that it prompts for API token
#
# Usage
# =====
# 
# nqrun
# -----
# 
# ./nordiquest.sh nqrun \
#  # environment variables accessible to python script
#   --env QAL9000_API_URL="https://api.qal9000.se" \
#   --env QAL9000_SERVICE_NAME="ex3" \
#   --env POLL_TIMEOUT=500 \
#   # requirements file for python packages
#   --requirements requirements.txt \
#   # srun-specific parameters
#   -p armq -N 1 -n 256 --pty \
#   quantum-example.py
#
# Options
# ---
# 
# - env: pair of environment name and value
# - requirements: the path to the requirements.txt file containing dependencies for python script
# - python: the python module to use
# - .... srun-specific params
#
# Required Args
# ---
#
# - python script path: the path to the python script to run
#
# Prompts
# ---
# 
# - QAL 9000 API token: the API token for running experiments on QAL 9000
#
# Environment
# ---
#
# - Your python script has access to the `QAL9000_API_TOKEN` variable

function nqrun () {
  # variables
  env_vars=()
  srun_args=()
  requirements_file=""
  py_script_path=""
  bash_script=""
  python_module=""
  source_code_dir="D1"

  # Docs
  function help()
  {
    printf " Usage: nqrun [OPTIONS] [SRUN-OPTIONS] PYTHON_SCRIPT\n"
    printf "\n"
    printf " Run quantum computing jobs on SLURM-managed high-perfromance computers (HPC)\n"
    printf " Note that it prompts for API token\n"
    printf "\n"
    printf " Options:\n"
    printf "  %-20s\t%s\n" "--env list" "Set environment variables like Var1=Value1"
    printf "  %-20s\t%s\n" "--requirements string" "Text file containing python dependencies in requirements.txt format"
    printf "  %-20s\t%s\n" "--python string" "Python module to load with 'module load [python module]'"
    printf "  %-20s\t%s\n" "--source-code-dir string" "the folder that stores source code on login node; default=D1"
    printf "\n"
    printf  " srun options:\n"
    srun --help
  }
  
  # extract args
  while [[ $# -gt 0 ]]; do
    case $1 in
      --env)
        env_vars+=("$2")
        shift # past argument
        shift # past value
        ;;
      --requirements)
        requirements_file="$2"
        shift # past argument
        shift # past value
        ;;
      --python)
        python_module="$2"
        shift # past argument
        shift # past value
        ;;
      --source-code-dir)
        source_code_dir="$2"
        shift # past argument
        shift # past value
        ;;
      -h|--help)
        help
        return 0
        ;;
      *)
        if [ -z "$2" ]; then 
          # current element is last thus it is the script file
          py_script_path="$1";
        else 
          # srun args and values can be anything
          srun_args+=("$1");
        fi
        shift
        ;;
    esac
  done

  # check required variables
  if [ -z "$py_script_path" ]; then
    echo "the last argument should be the path to the python script";
    exit 1;
  fi

  # Ask for QAL 9000 API token
  read -s -r -p "Enter a valid QAL 9000 API token: " qal9000_api_token
  if [ -n "$qal9000_api_token" ]; then
    env_vars+=("QAL9000_API_TOKEN='$qal9000_api_token'");
  else
    echo "QAL 9000 API token cannot be empty";
    exit 1;
  fi

  # important variables
  # ----
  python_env="$source_code_dir/nqenv";
  # path to bash script wrapper around the python script
  bash_script="${py_script_path%%\.py}$(date +%s).sh";

  # prepare the python environment in which sciript is
  function prepare_python_env () {
    # conditionally loading python module
    if [ -n "$python_module" ]; then
      module load $python_module;
    fi

    # creating and activate virtual environment
    python -m venv "$python_env";
    source "$python_env/bin/activate";

    # installing packages in python virtual environment
    if [ -n "$requirements_file" ]; then
      pip install -r $requirements_file;
    else
      # install the default required packages
      pip install tergite;
    fi

  }

  # generate the bash script to run in the compute-node
  function generate_bash_script () {
    # set up the shebang
    echo "#!/bin/bash" >> $bash_script;

    # setting environment variables
    for env_var in "${env_vars[@]}"; do
      echo "export $env_var;" >> $bash_script;
    done

    # running python script
    echo "python $py_script_path;" >> $bash_script;

    # unsetting environment variables
    for env_pair in "${env_vars[@]}"; do
      env_key="${env_pair%%=*}"
      echo "unset $env_key;" >> $bash_script;
    done
  }

  # Cleanup
  function cleanup () {
    # delete virtual environment
    rm -r "$python_env";
    
    # deleting bash script after?
    rm $bash_script;
  }

  # Run
  prepare_python_env;
  generate_bash_script;
  chmod +x $bash_script;
  srun $(for arg in ${srun_args[@]}; do printf "%s " "$arg"; done) $bash_script;
  cleanup;

  return 0;
}

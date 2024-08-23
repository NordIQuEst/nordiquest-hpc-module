#!/usr/bin/env bats

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  # get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"

  # make the functions in nordiquest script available to tests
  load "$DIR/../nordiquest.sh"
}

teardown() {
  : # cleanup
}

@test "can print help" {
  run nqrun --help;

  assert_output --partial "\
 Usage: nqrun [OPTIONS] [SRUN-OPTIONS] PYTHON_SCRIPT

 Run quantum computing jobs on SLURM-managed high-perfromance computers (HPC)
 Note that it prompts for API token

 Options:
  $(printf '%-20s\t%s\n' '--env list' 'Set environment variables like Var1=Value1')
  $(printf '%-20s\t%s\n' '--requirements string' 'Text file containing python dependencies in requirements.txt format')
  $(printf '%-20s\t%s\n' '--python string' $'Python module to load with \'module load [python module]\'')

  When srun is available, srun options can also be passed."

}
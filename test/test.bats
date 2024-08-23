#!/usr/bin/env bats

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  load 'test_helper/utils.sh'
}

teardown() {
  : # cleanup
}

@test "can print help" {
  load_nordiquest_sh --mock 'test_helper/mocks/srun.sh';

  run nqrun --help;

  assert_output --partial "\
 Usage: nqrun [OPTIONS] [SRUN-OPTIONS] PYTHON_SCRIPT

 Run quantum computing jobs on SLURM-managed high-perfromance computers (HPC)
 Note that it prompts for API token

 Options:
  $(printf '%-20s\t%s\n' '--env list' 'Set environment variables like Var1=Value1')
  $(printf '%-20s\t%s\n' '--requirements string' 'Text file containing python dependencies in requirements.txt format')
  $(printf '%-20s\t%s\n' '--python string' $'Python module to load with \'module load [python module]\'')

 srun options:
 Some random stuff from srun"
}
#!/usr/bin/env bats

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  load 'test_helper/mocks.sh'

  # make the functions in nordiquest script available to tests
  load "$(get_tests_folder)/../nordiquest.sh"
}

teardown() {
  : # cleanup
}

get_tests_folder() {
  # get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively
  echo "$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
}

@test "nqrun --help can print help" {
  run nqrun --help;

  assert_output --partial "\
 Usage: nqrun [OPTIONS] [SRUN-OPTIONS] PYTHON_SCRIPT

 Run quantum computing jobs on SLURM-managed high-perfromance computers (HPC)
 Note that it prompts for API token

 Options:
  $(printf '%-20s\t%s\n' '--env list' 'Set environment variables like Var1=Value1')
  $(printf '%-20s\t%s\n' '--requirements string' 'Text file containing python dependencies in requirements.txt format')
  $(printf '%-20s\t%s\n' '--python string' $'Python module to load with \'module load [python module]\'')
  $(printf '%-20s\t%s\n' '--source-code-dir string' 'the folder that stores source code on login node; default=D1')

 srun options:
 Some random stuff from srun"
}

@test "can run python script" {
  py_script="$(get_tests_folder)/test_helper/fixtures/sample.py";
  requirements_txt="$(get_tests_folder)/test_helper/fixtures/requirements.txt";
  api_token="some-token";
  
  run nqrun --env QAL9000_API_URL="https://example.se"\
   --env QAL9000_SERVICE_NAME="lami"\
   --env POLL_TIMEOUT=500\
   --requirements $requirements_txt\
   --python python-3.11\
   -p armq -N 1 -n 256 --pty $py_script <<< "$api_token";

  assert_output --partial "python-3.11 module loaded";

  assert_output --partial "D1/nqenv/bin/python";

  assert_output --partial "-p armq -N 1 -n 256 --pty";

  assert_output --partial "\
QAL9000_API_URL: https://example.se
QAL9000_API_TOKEN: $api_token
QAL9000_SERVICE_NAME: lami
POLL_TIMEOUT: 500"
}

@test "can run python script in different source code dir" {
  py_script="$(get_tests_folder)/test_helper/fixtures/sample.py";
  requirements_txt="$(get_tests_folder)/test_helper/fixtures/requirements.txt";
  api_token="some-token";
  source_code_dir="D2/etc"
  
  run nqrun --env QAL9000_API_URL="https://example.se"\
   --env QAL9000_SERVICE_NAME="lami"\
   --env POLL_TIMEOUT=500\
   --requirements $requirements_txt\
   --source-code-dir $source_code_dir\
   --python python-3.7.4\
   -p armq -N 1 -n 256 --pty $py_script <<< "$api_token";

  assert_output --partial "python-3.7.4 module loaded";

  assert_output --partial "$source_code_dir/nqenv/bin/python";

  assert_output --partial "-p armq -N 1 -n 256 --pty";

  assert_output --partial "\
QAL9000_API_URL: https://example.se
QAL9000_API_TOKEN: $api_token
QAL9000_SERVICE_NAME: lami
POLL_TIMEOUT: 500"
}

@test "nqrun errors when no empty api token is passed" {
  py_script="$(get_tests_folder)/test_helper/fixtures/sample.py";
  requirements_txt="$(get_tests_folder)/test_helper/fixtures/requirements.txt";
  
  run nqrun --env QAL9000_API_URL="https://example.se"\
   --env QAL9000_SERVICE_NAME="lami"\
   --env POLL_TIMEOUT=500\
   --requirements $requirements_txt\
   --python python-3.7.4\
   -p armq -N 1 -n 256 --pty $py_script <<< "";

  assert_output "QAL 9000 API token cannot be empty"
}

@test "nqrun errors when no script is passed" {
  py_script="$(get_tests_folder)/test_helper/fixtures/sample.py";
  requirements_txt="$(get_tests_folder)/test_helper/fixtures/requirements.txt";
  
  run nqrun <<< "";

  assert_output "the last argument should be the path to the python script"
}

@test "can run python script without requirements file" {
  py_script="$(get_tests_folder)/test_helper/fixtures/sample.py";
  requirements_txt="$(get_tests_folder)/test_helper/fixtures/requirements.txt";
  api_token="new-token";
  
  run nqrun\
    --env QAL9000_API_URL="https://example.se" \
    --env QAL9000_SERVICE_NAME="look" \
    --env POLL_TIMEOUT=600 \
    --python python-3.12 \
    -p armq -N 2 -n 256 \
    $py_script <<< "$api_token";

  assert_output --partial "python-3.12 module loaded";

  assert_output --partial "nqenv/bin/python";

  assert_output --partial "-p armq -N 2 -n 256";

  assert_output --partial "\
QAL9000_API_URL: https://example.se
QAL9000_API_TOKEN: $api_token
QAL9000_SERVICE_NAME: look
POLL_TIMEOUT: 600"
}

@test "can run python script without python module" {
  py_script="$(get_tests_folder)/test_helper/fixtures/sample.py";
  requirements_txt="$(get_tests_folder)/test_helper/fixtures/requirements.txt";
  api_token="other-token";
  
  run nqrun \
    --env QAL9000_API_URL="https://example.com" \
    --env QAL9000_SERVICE_NAME="lami" \
    --env POLL_TIMEOUT=5400 \
    --requirements $requirements_txt \
    -p armq -N 1 -n 512 --pty \
    $py_script <<< "$api_token";

  refute_output --partial "python-3.7.4 module loaded";

  assert_output --partial "D1/nqenv/bin/python";

  assert_output --partial "-p armq -N 1 -n 512 --pty";

  assert_output --partial "\
QAL9000_API_URL: https://example.com
QAL9000_API_TOKEN: $api_token
QAL9000_SERVICE_NAME: lami
POLL_TIMEOUT: 5400"
}
# NordIQuEst-HPC module

[![NordIQuEst-HPC module CI](https://github.com/NordIQuEst/nordiquest-hpc-module/actions/workflows/ci.yml/badge.svg)](https://github.com/NordIQuEst/nordiquest-hpc-module/actions/workflows/ci.yml)

The module for running quantum computing jobs on high-perfromance computers (HPC) that run [slurm](https://slurm.schedmd.com/overview.html)

## Quick Start (ex3)

- You need to have an account with [ex3](https://www.ex3.simula.no/) for you to move forward with these steps

- Login to the ex3

e.g.

```shell
ssh ex3
```

- Clone the repository

```shell
git clone https://github.com/NordIQuEst/nordiquest-hpc-module.git
```

- Install the module

```shell
cd nordiquest-hpc-module
mkdir -p /global/D1/homes/YOUR_USERNAME/modulefiles
cp nordiquest /global/D1/homes/YOUR_USERNAME/modulefiles/nordiquest
module use --append /global/D1/homes/YOUR_USERNAME/modulefiles
```

**Note: Replace `YOUR_USERNAME` with your username**

**One other option is to install the module in a projects folder so that it is accessible for multiple users. Contact <ex3-helpdesk@simula.no>**

- Load the module

```shell
module load nordiquest
```

- Create (or upload) a sample script: `quantum_example.py` in your ex3 data folder.

```python
# quantum_example.py
"""A sample script doing a very simple quantum operation"""
import time
import os

import qiskit.circuit as circuit
import qiskit.compiler as compiler

from tergite.qiskit.providers import Job, Tergite
from tergite.qiskit.providers.provider_account import ProviderAccount


# the Tergite API URL
API_URL = os.environ.get("QAL9000_API_URL", default="https://api.qal9000.se")
# The name of the Quantum Computer to use from the available quantum computers
BACKEND_NAME = "loke"
# the application token for logging in
API_TOKEN = os.environ.get("QAL9000_API_TOKEN")
# the name of this service. For your own bookkeeping.
SERVICE_NAME = os.environ.get("QAL9000_SERVICE_NAME", default="local")
# the timeout in seconds for how long to keep checking for results
POLL_TIMEOUT = int(os.environ.get("POLL_TIMEOUT", default="100"))

# create the Qiskit circuit
qc = circuit.QuantumCircuit(1)
qc.x(0)
qc.h(0)
qc.measure_all()

# create a provider
# provider account creation can be skipped in case you already saved
# your provider account to the `~/.qiskit/tergiterc` file.
# See below how that is done.
account = ProviderAccount(service_name=SERVICE_NAME, url=API_URL, token=API_TOKEN)
provider = Tergite.use_provider_account(account)
# to save this account to the `~/.qiskit/tergiterc` file, add the `save=True`
# provider = Tergite.use_provider_account(account, save=True)
# Get the tergite backend in case you skipped provider account creation
# provider = Tergite.get_provider(service_name=SERVICE_NAME)
backend = provider.get_backend(BACKEND_NAME)
backend.set_options(shots=1024)

# compile the circuit
tc = compiler.transpile(qc, backend=backend)

# run the circuit
job: Job = backend.run(tc, meas_level=2, meas_return="single")

# view the results
elapsed_time = 0
result = None
while result is None:
    if elapsed_time > POLL_TIMEOUT:
        raise TimeoutError(
            f"result polling timeout {POLL_TIMEOUT} seconds exceeded"
        )

    time.sleep(1)
    elapsed_time += 1
    result = job.result()

result.get_counts()
```

- Run an HPC-quantum-computer python script

```shell
# options:
# --env: environment variables accessible to python script
# --requirements: requirements file for python packages
# --python: python module you wish to load
# and other srun-specific parameters e.g. -p, -N etc.
nqrun \
  --env QAL9000_API_URL="https://api.qal9000.se" \
  --env QAL9000_SERVICE_NAME="ex3" \
  --env POLL_TIMEOUT=500 \
  --requirements requirements.txt \
  --python python-3.7.4 \
  -p armq -N 1 -n 256 --pty \
  /global/D1/homes/YOUR_USERNAME/quantum_example.py
```

**Dont forget to update `YOUR_USERNAME` to your ex3 username**

- Enter the QAL 9000 API token when it requests for one and wait for the job complete

## API

- `nqrun` - an equivalent of [slurm's `srun`](https://slurm.schedmd.com/srun.html)
  - Extension of the API as [slurm's `srun`](https://slurm.schedmd.com/srun.html)
  - `--env VARIABLE_NAME=VALUE` to pass environment variables to the python script e.g. `--env VAR1=value1 --env VAR2=value2`
  - `--requirements FILE_PATH` specifiying the `requirements.txt` containing the python dependencies the python script depends on
- `nqbatch` - an equivalent of [slurm's `sbatch`](https://slurm.schedmd.com/sbatch.html) [COMING SOON]

## How to Test

- Clone the repository

```shell
git clone --recurse-submodules https://github.com/NordIQuEst/nordiquest-hpc-module.git
```

- Run the tests

```shell
cd nordiquest-hpc-module
./test/bats/bin/bats test/test.bats
```

## How to Build

- Clone the repository

```shell
git clone --recurse-submodules https://github.com/NordIQuEst/nordiquest-hpc-module.git
```

- Build the shell script into a module

```shell
cd nordiquest-hpc-module
module sh-to-mod bash nordiquest.sh >nordiquest
```

## Authors

This project is a work of
[a number of contributors](https://github.com/NordIQuEst/nordiquest-hpc-module/graphs/contributors).

Special credit goes to the authors of this project as seen in the [CREDITS](./CREDITS.md) file.

## ChangeLog

To view the changelog for each version, have a look at the [CHANGELOG.md](./CHANGELOG.md) file.

## License

[Apache 2.0 License](./LICENSE)

## Acknowledgements

- This work was sponsored by [Nordic e-Infrastructure Collaboration (NeIC)](https://neic.no) and [NordForsk](https://www.nordforsk.org/sv) under the [NordIQuEst](https://neic.no/nordiquest/) project
- This work was initially created at [Chalmers Next Labs AB](https://chalmersnextlabs.se) in collaboration with Chalmers Technical University under the [NordIQuEst](https://neic.no/nordiquest/) project.

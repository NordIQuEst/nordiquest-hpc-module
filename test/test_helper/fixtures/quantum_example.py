# quantum-example.py
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
# API_TOKEN = "E2Q6qm7_JrzIJ_YwtWW9vhFrhpVtAcoeoDo26Pb5XPU"
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
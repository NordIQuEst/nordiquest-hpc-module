"""A sample script checking environment is set appropriately"""

import os
import sys

# Don't remove this as it ensures tergite is installed
import tergite

import qiskit

# Don't remove this as it ensures qiskit-iqm is installed
import qiskit_iqm

print(sys.executable)
print(f"QAL9000_API_URL: {os.environ.get('QAL9000_API_URL')}")
print(f"QAL9000_API_TOKEN: {os.environ.get('QAL9000_API_TOKEN')}")
print(f"QAL9000_SERVICE_NAME: {os.environ.get('QAL9000_SERVICE_NAME')}")
print(f"POLL_TIMEOUT: {os.environ.get('POLL_TIMEOUT')}")

print(f"HELMI_API_URL: {os.environ.get('HELMI_API_URL')}")
print(f"HELMI_API_TOKEN: {os.environ.get('HELMI_API_TOKEN')}")

import os

from qiskit import QuantumCircuit, execute
from iqm.qiskit_iqm import IQMProvider

# The VTT QX URL 
QX_URL = os.getenv('QX_URL', default="https://qc.vtt.fi/qx/api/devices/helmi")
# The application token to authenticate
QX_TOKEN = os.getenv('HELMI_API_TOKEN')

provider = IQMProvider(QX_URL, token=QX_TOKEN)
backend = provider.get_backend()

shots = 1000  # Set the number of shots you wish to run with

# Create your quantum circuit.
circuit = QuantumCircuit(2, 2)
circuit.h(0)
circuit.cx(0, 1)
circuit.measure_all()

# Draw the quantum circuit
print(circuit.draw(output='text'))

# Execute the circuit
job = execute(circuit, backend, shots=shots)

# Fetch the results and print the counts
counts = job.result().get_counts()
print(counts)

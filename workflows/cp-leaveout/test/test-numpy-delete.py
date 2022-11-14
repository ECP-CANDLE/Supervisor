import numpy as np

A = np.eye(4)
print(A)
A = np.delete(A, 1, axis=0)
print(A)

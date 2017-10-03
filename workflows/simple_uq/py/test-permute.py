
import permute

permute.configure(seed=10101, size=10, training=8)

for i in range(0,9):
   print permute.get()

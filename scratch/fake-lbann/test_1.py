import os

import fl_interface

comm = os.getenv("COMM")
print("comm: " + comm)

fl_interface.fl_interface(int(comm), 3)


# Performance test for pandas.read_csv()

import sys
import pandas as pd

F = sys.argv[1]

(pd.read_csv(F, header=None, low_memory=False, usecols=None).values).astype('float32')

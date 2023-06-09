# CLEAN TOP21
# Cleans the top21 file so only LINCS records are present
# File names are hard-coded but easy to change

import logging

logger = logging.getLogger("clean-top21")
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s %(message)s", datefmt="%H:%M:%S")
ch.setFormatter(formatter)
logger.addHandler(ch)
logger.info("Start")

import pandas as pd

logger.info("Pandas")

SCRATCH = "/gpfs/alpine/med106/scratch/wozniak"
CANDLE_DATA = SCRATCH + "/CANDLE-Data/ChallengeProblem"

# The original data from Yoo:
original = CANDLE_DATA + "/top21_2020Jul/top21.h5"
lincs1000 = CANDLE_DATA + "/top21_2020Jul/lincs1000"

# The file we are creating here:
output = CANDLE_DATA + "/top21_2020Jul/top21-cleaned-dd.h5"

# List of names in LINCS:
lincs = []
with open(lincs1000, "r") as fp:
    while True:
        line = fp.readline()
        if len(line) == 0:
            break
        lincs.append(line.strip())

logger.info("lincs length: %i" % len(lincs))

store_in = pd.HDFStore(original, "r")
df = store_in.get("df")

logger.info("HDF Opened.")

columns = df.columns.to_list()
logger.info("df columns original: %i" % len(columns))

# List of dataframe column names to delete:
delete_these = []

count_key = 0
count_GE_N = 0
count_GE_Y = 0
count_DD = 0
count_other = 0
for column in columns:
    if column.startswith("GE_"):
        # print("GE " + column)
        substring = column[3:]
        if substring in lincs:
            count_GE_Y += 1
        else:
            count_GE_N += 1
            delete_these.append(column)
    elif column.startswith("DD_"):
        # print("DD " + column)
        count_DD += 1
        # delete_these.append(column)
    elif column == "AUC" or column == "DRUG" or column == "CELL":
        count_key += 1
    else:
        print("NO '%s'" % column)
        count_other += 1

print("count_key:    %i" % count_key)
print("count_GE_Y:   %i" % count_GE_Y)
print("count_GE_N:   %i" % count_GE_N)
print("count_DD:     %i" % count_DD)
print("count_other:  %i" % count_other)

logger.info("Scanned.")
logger.info("delete_these: %i" % len(delete_these))
df.drop(columns=delete_these, inplace=True)
logger.info("df columns after: %i" % len(df.columns.to_list()))

logger.info("Dropped.")

df.to_hdf(output, key="df", mode="w")

logger.info("Wrote.")

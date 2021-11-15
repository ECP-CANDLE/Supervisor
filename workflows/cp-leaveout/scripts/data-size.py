
# DATA SIZE PY
# Get the training data size from the file

import argparse, logging, os, sys
import pandas as pd

from utils import fail

parser = argparse.ArgumentParser(description="Extract the data size")
parser.add_argument("input",
                    help="The training file")
args = parser.parse_args()

print("data-size.py: opening '%s' ..." % args.input)

_, ext = os.path.splitext(args.input)
if ext == ".h5" or ext == ".hdf5":
    store = pd.HDFStore(args.input, "r")
    # df = store.get("df")
    df_y_train = store.get("y_train")
    print("train " + str(df_y_train.shape))
    df_y_val = store.get("y_val")
    print("val   " + str(df_y_val.shape))
    df_x_train_0 = store.get("x_train_0")
    print("x0    " + str(df_x_train_0.shape))
    df_x_train_1 = store.get("x_train_1")
    print("x1    " + str(df_x_train_1.shape))

    print(df_x_train_0.index)

    clms = df_x_train_0.columns
    print(clms)
    for clm in clms:
        print(df_x_train_0.at[2,clm])
    # print(df_x_train_1.columns)

    store.close()

elif ext == ".feather":
    print("read feather " + str(args.input))
    df = pd.read_feather(args.input).fillna(0)
    print(df.shape)
    print(df.dtypes)
    print(str(df["CELL"]))
    C = {}
    for s in df["CELL"]:
        C[s] = ""
    D = {}
    for s in df["DRUG"]:
        D[s] = ""
    print("df.columns: " + str(df.columns))
    print("df.index: " + str(df.index))
    print("len(df): " + str(len(df)))
    print("len(C):  " + str(len(C)))
    print("len(D):  " + str(len(D)))
    print("len(AUC):  " + str(len(df["AUC"])))

    # print(str(df["CELL"][0:9]))
    # print(str(type(df["CELL"][0])))

print("data-size: OK.")

    # total size: (529940, 6215)

# store = pd.HDFStore(args.input, "r", complevel=9, complib="blosc:snappy")
# print(str(store))

# print(store.get("y_val"))


# f = h5py.File(args.file, "r")

# # print(f.name)

# K = list(f.keys())
# print(K)
# for g in K:
#     print(g)
#     if type(f[g]) == h5py._hl.group.Group:
#         D = f[g].keys()
#         print(list(D))
#     print("")

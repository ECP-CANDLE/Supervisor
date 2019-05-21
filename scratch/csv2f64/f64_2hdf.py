#!/usr/bin/env python3

import sys

import h5py
import numpy as np

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('input',
                    help='The input f64 file')
parser.add_argument('output',
                    help='The output HDF file')

args = parser.parse_args(sys.argv[1:])

print(args.input, args.output)


f = h5py.File(args.output, 'r+')

print(f.keys())
ds = f['conv1d_1']['conv1d_1']['kernel:0']
a = ds[:,:,:]
# print(ds.shape)
# print(ds.dtype)
a8 = a.astype('float64')
# print(a[0,0,0])

a8 = np.fromfile(args.input, dtype='float64')

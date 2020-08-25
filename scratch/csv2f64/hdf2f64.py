#!/usr/bin/env python3

import sys

import h5py

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('input',
                    help='The input H5 file')
parser.add_argument('output',
                    help='The output f64 file')
args = parser.parse_args(sys.argv[1:])

print(args)

f = h5py.File(args.input, 'r')

print(f.keys())
ds = f['conv1d_1']['conv1d_1']['kernel:0']
a = ds[:,:,:]
# print(ds.shape)
# print(ds.dtype)
a8 = a.astype('float64')

a8.tofile(args.output)

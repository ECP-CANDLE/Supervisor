#!/bin/bash
set -eu

which python pip

printf "Install LGBM dependencies?  Ctrl-C to cancel."

read -t 10 _

PKGS=(
  git+https://github.com/ECP-CANDLE/candle_lib@develop
  pandas==1.1.5
  openpyxl==3.0.9
  scikit-learn==0.24.2
  pyarrow==12.0.1 # saves and loads parquet files
  lightgbm==3.1.1
)

pip install ${A[@]}

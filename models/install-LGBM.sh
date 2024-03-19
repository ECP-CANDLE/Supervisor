#!/bin/bash
set -eu

# Install LGBM in non-container mode

which python pip
echo
echo "Install LGBM dependencies?  Hit enter or Ctrl-C to cancel."
read -t 10 _
echo "Installing..."

PKGS=(
  git+https://github.com/ECP-CANDLE/candle_lib@develop
  pandas==1.1.5
  openpyxl==3.0.9
  scikit-learn==0.24.2
  pyarrow==12.0.1 # saves and loads parquet files
  lightgbm==3.1.1
)

pip install ${PKGS[@]}

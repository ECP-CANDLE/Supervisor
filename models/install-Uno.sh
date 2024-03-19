#!/bin/bash
set -eu

# Install Uno in non-container mode

which python pip
echo
echo "Install Uno dependencies?  Hit enter or Ctrl-C to cancel."
read -t 10 _
echo "Installing..."

PKGS=(
 "pandas==2.0.3"
 "scikit-learn==1.3.2"
 "numpy==1.24.3"
 "joblib==1.3.2"
 "pillow==9.4.0"
 "kiwisolver==1.4.5"
 "pyyaml==6.0.1"
 "pyarrow==9.0.0"
)

pip install ${PKGS[@]}

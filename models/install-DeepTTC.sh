#!/bin/zsh -f
set -eu

# Install DeepTTC in non-container mode

which python
echo
echo "Install DeepTTC dependencies?  Hit enter or Ctrl-C to cancel."
read -t 10 _
echo "Installing..."

PKGS_CONDA=(
  pandas"<2.0.0"
  scikit-learn
  openpyxl
)

PKGS_CONDA_FORGE=(
  lifelines
  prettytable
)

PKGS_BIOCONDA=(
  pubchempy
)

PKGS_PIP=(
  subword-nmt
  wget
)

set -x

conda install -y                $PKGS_CONDA
conda install -y -c conda-forge $PKGS_CONDA_FORGE
conda install -y -c bioconda    $PKGS_BIOCONDA

python -m pip install subword-nmt wget

# candle does not import with scikit-learn 1.2.0
# /opt/conda/bin/pip install scikit-learn==1.1.3

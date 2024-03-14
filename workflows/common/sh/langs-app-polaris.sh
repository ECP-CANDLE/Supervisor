
# LANGS APP Polaris

set +eu
source /etc/profile
module load singularity
set -eu

PATH=/eagle/Candle_ECP/conda/2024-03-13-LGBM/bin:$PATH

export HTTP_PROXY=http://proxy.alcf.anl.gov:3128
export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
export http_proxy=http://proxy.alcf.anl.gov:3128
export https_proxy=http://proxy.alcf.anl.gov:3128

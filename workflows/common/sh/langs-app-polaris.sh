
# LANGS APP Polaris

set +eu
module use /soft/spack/gcc/0.6.1/install/modulefiles/Core
module load apptainer
apptainer version
set -eu

export HTTP_PROXY=http://proxy.alcf.anl.gov:3128
export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
export http_proxy=http://proxy.alcf.anl.gov:3128
export https_proxy=http://proxy.alcf.anl.gov:3128

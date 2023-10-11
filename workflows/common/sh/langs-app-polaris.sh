
# LANGS APP Polaris

PATH=/grand/CSC249ADOA01/public/sfw/polaris/Miniconda-2023-06-16/bin:$PATH

set +eu
source /etc/profile
module load singularity

export HTTP_PROXY=http://proxy.alcf.anl.gov:3128
export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
export http_proxy=http://proxy.alcf.anl.gov:3128
export https_proxy=http://proxy.alcf.anl.gov:3128

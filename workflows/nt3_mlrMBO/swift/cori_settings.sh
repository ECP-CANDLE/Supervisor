module load java
module load deeplearning
module swap PrgEnv-intel PrgEnv-gnu
# if PrgEnv-intel is not loaded then PrgEnv-gnu won't load via the swap
# so we load gcc explicitly
module load gcc
module load intel-tensorflow


export PATH=/global/homes/w/wozniak/Public/sfw/compute/swift-t-r/stc/bin:$PATH

chmod u+x ./bootstrap
./bootstrap
module load swig
module swap PrgEnv-intel PrgEnv-gnu
source cori_settings.sh
./configure
make
make install
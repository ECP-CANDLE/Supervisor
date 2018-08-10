#!/bin/bash -l
ifelse(getenv(PROJECT), `',,
#PBS -A getenv(PROJECT)
)
ifelse(getenv(QUEUE), `',,
#PBS -q getenv(QUEUE)
)
#PBS -l nodes=getenv(NODES)
#PBS -l walltime=getenv(WALLTIME)
#PBS -j oe
#PBS -o getenv_nospace(EXP_DIR)/output.txt
#PBS -N getenv(EXP_ID)

export PYTHONHOME="/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/"
PYTHON="$PYTHONHOME/bin/python"
export LD_LIBRARY_PATH=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/cuda/lib64:/opt/gcc/4.9.3/snos/lib64:/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R/lib

export PATH="$PYTHONHOME/bin:$PATH"
PYTHONPATH+=":$PYTHONHOME/lib/python3.6:"
PYTHONPATH+="$PYTHONHOME/lib/python3.6/site-packages"

export PYTHONPATH=$PP:$PYTHONPATH

#export KMP_BLOCKTIME=0
#export KMP_SETTINGS=1
#export KMP_AFFINITY="granularity=fine,verbose,compact,1,0"
#export OMP_NUM_THREADS=62
#export NUM_INTER_THREADS=1
#export NUM_INTRA_THREADS=62

echo "STARTING PYTHON PBT: $PBT_PY"
echo "PYTHON: $( which python )"
echo "PYTHONPATH: $PYTHONPATH"

aprun -n getenv(PROCS) -N getenv(PPN) python $PBT_PY $PARAMS_FILE $EXP_DIR tc1 $EXP_ID

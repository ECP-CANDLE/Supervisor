#!/bin/bash -l
ifelse(getenv_nospace(PROJECT), `',,#COBALT -A getenv_nospace(PROJECT)
)ifelse(getenv_nospace(QUEUE), `',,#COBALT -q getenv(QUEUE)
)#COBALT -n getenv(NODES)
#COBALT -t getenv(WALLTIME)
#COBALT -o getenv_nospace(EXP_DIR)/output.txt
#COBALT -e getenv_nospace(EXP_DIR)/output.txt          
#COBALT --cwd getenv(EXP_DIR)

export PYTHONPATH=$PP:$PYTHONPATH
export PATH=$PYTHONPATH:$PATH

export KMP_BLOCKTIME=0
#export KMP_SETTINGS=1
export KMP_AFFINITY="granularity=fine,verbose,compact,1,0"
export OMP_NUM_THREADS=62
export NUM_INTER_THREADS=1
export NUM_INTRA_THREADS=62

module load miniconda-3.6/conda-4.4.10

echo "STARTING PYTHON PBT: $PBT_PY"
echo "PYTHON: $( which python )"
echo "PYTHONPATH: $PYTHONPATH"

aprun -n getenv(PROCS) -N getenv(PPN) python $PBT_PY $PARAMS_FILE $EXP_DIR tc1 $EXP_ID

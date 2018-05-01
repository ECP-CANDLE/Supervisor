#!/bin/bash -l

#SBATCH -N 129

#SBATCH -q regular
#SBATCH -t 48:00:00
#SBATCH -C knl,quad,cache
#SBATCH --license=SCRATCH,project

module load tensorflow/intel-head

PP="$BENCHMARKS/Pilot1/common"
PP+=":$BENCHMARKS/common"
PP+=":$SUPERVISOR/workflows/common/python"
PP+=":$ROOT/models/tc1"

export PYTHONPATH=$PP:$PYTHONPATH
export PATH=$PYTHONPATH:$PATH

export KMP_BLOCKTIME=1
export KMP_SETTINGS=1
export KMP_AFFINITY="granularity=fine,verbose,compact,1,0"
export OMP_NUM_THREADS=68
export NUM_INTER_THREADS=1
export NUM_INTRA_THREADS=68

echo "STARTING PYTHON PBT: $PBT_PY"
echo "PYTHON: $( which python )"
echo "PYTHONPATH: $PYTHONPATH"

srun --export=ALL -n 129 -c 272 python $PBT_PY $PARAMS_FILE $EXP_DIR tc1 $EXP_ID

#!/bin/bash -l

#BSUB -P getenv(PROJECT)
#BSUB -nnodes getenv(NODES)
#BSUB -W getenv(WALLTIME)
#BSUB -J getenv(EXP_ID)
#BSUB -o getenv_nospace(EXP_DIR)/output.txt

module load gcc/4.8.5
module load spectrum-mpi/10.3.0.1-20190611
module load cuda/10.1.168
export btl_openib_warn_default_gid_prefix=0

export PATH="/ccs/proj/med106/gounley1/summit/miniconda37/bin:$PATH"
export LD_LIBRARY_PATH="/ccs/proj/med106/gounley1/summit/miniconda37/lib:$LD_LIBRARY_PATH"

PYTHONPATH=/ccs/proj/med106/gounley1/summit/miniconda37/lib/python3.7/site-packages:/ccs/proj/med106/gounley1/summit/miniconda37/lib/python3.7:$PYTHONPATH
export PYTHONPATH=$PP:$PYTHONPATH

echo "STARTING PYTHON PBT: $PBT_PY"
echo "PYTHON: $( which python )"
echo "PYTHONPATH: $PYTHONPATH"

echo "Params file: $PARAMS_FILE"
echo "Exp dir: $EXP_DIR"
echo "Exp id: $EXP_ID"

jsrun --nrs 6 --tasks_per_rs 1 --cpu_per_rs 1 --gpu_per_rs 1 --rs_per_host 6 --latency_priority cpu-cpu --launch_distribution cyclic --bind packed:1 python $PBT_PY $PARAMS_FILE $EXP_DIR p3b3 $EXP_ID



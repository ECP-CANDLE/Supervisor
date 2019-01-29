#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --mem=20G
#SBATCH --gres=gpu:v100:1
#SBATCH --time=24:00:00
#SBATCH --job-name=hpset_23

# Set up environment
module load python/3.6
CANDLE=/data/BIDS-HPC/public/candle

# Set the file that the Python script below will read in order to determine the model parameters
export DEFAULT_PARAMS_FILE=/home/weismanal/notebook/2019-01-28/jobs/not_candle/single_param_set.txt

# Run the model
python $CANDLE/Supervisor/workflows/examples/unet.py

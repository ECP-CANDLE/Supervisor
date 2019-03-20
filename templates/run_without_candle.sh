#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --mem=20G
#SBATCH --gres=gpu:k80:1
#SBATCH --time=00:05:00
#SBATCH --job-name=mnist_upf_test_no_candle

# Set up environment
module load python/3.6
CANDLE_DIR=/data/BIDS-HPC/public/candle

# Set the file that the Python script below will read in order to determine the model parameters
export DEFAULT_PARAMS_FILE="$CANDLE_DIR/Supervisor/templates/model_params/mnist1.txt"

# Run the model
python $CANDLE_DIR/Supervisor/templates/models/mnist/mnist_mlp.py
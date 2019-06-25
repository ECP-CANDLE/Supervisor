#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --mem=20G
#SBATCH --gres=gpu:k80:1
#SBATCH --time=00:05:00
#SBATCH --job-name=mnist_test_no_candle

# Always load the candle module for, e.g., finding the Benchmark class... DO NOT MODIFY
module load candle

# Load desired Python version or Conda environment
# Load other custom environment settings here
module load python/3.6

# Set the file that the Python script below will read in order to determine the model parameters
export DEFAULT_PARAMS_FILE="$CANDLE/Supervisor/templates/model_params/mnist1.txt"

# Run the model
python $CANDLE/Supervisor/templates/models/mnist/mnist_mlp.py
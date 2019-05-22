#!/bin/bash

# Note that another way to run the model without using CANDLE is to use an interactive node (e.g., sinteractive --constraint=gpuk20x --mem=20G --gres=gpu:k20x:1), in which you can set USE_CANDLE to 0 and run the same thing as usual: ./submit_candle_job.sh
#
# Otherwise, this script should be run like "sbatch run_wihtout_candle.sh"
#

#SBATCH --partition=gpu
#SBATCH --mem=20G
#SBATCH --gres=gpu:k80:1
#SBATCH --time=00:05:00
#SBATCH --job-name=mnist_test_no_candle

export USE_CANDLE=0
./submit_candle_job.sh
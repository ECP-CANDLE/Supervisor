#!/bin/bash

function error_occurred() {
    message=$1
    echo "ERROR: $message"
    echo 1
}

# Variables
submission_script="submit_candle_job.sh"
experiments_dir="experiments"

# Create the submission script if it doesn't already exist
ret1=0
if [ ! -f $submission_script ]; then
    cp $CANDLE/Supervisor/templates/$submission_script . && echo "Created $submission_script in the current directory" || ret1=$(error_occurred "Could not create $submission_script in the current directory")
else
    echo "WARNING: Could not create $submission_script, as it already exists"
fi

# Create the experiments directory if it doesn't already exist
ret2=0
if [ ! -d $experiments_dir ]; then
    mkdir $experiments_dir && echo "Created $experiments_dir directory in the current directory" || ret2=$(error_occurred "Could not create $experiments_dir directory in the current directory")
else
    echo "WARNING: Could not create $experiments_dir directory, as it already exists"
fi

# Output next steps
if [ "a$ret1" == "a0" ] && [ "a$ret2" == "a0" ]; then
    echo -e "\nYou are now ready to submit a CANDLE job! Either:\n"
    echo -e "  (1) Run './$submission_script' to submit a sample CANDLE job (no 'sbatch' needed)"
    echo -e "  (2) First modify $submission_script using https://cbiit.github.io/fnlcr-bids-hpc/documentation/candle/how_to_modify_the_candle_templates as a guide and then submit your own CANDLE job by running './$submission_script' (no 'sbatch' needed)\n"
else
    echo -e "\nAn error occurred; see error message(s) above\n"
fi
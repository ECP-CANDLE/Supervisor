Workflow for running CANDLE job (always in a working directory [set to $WORKINGDIR, e.g., /home/weismanal/notebook/2019-01-28/jobs/candle], i.e., not in the candle code tree):

1. Copy over the two necessary files:

     cp $EXAMPLEDIR/submit_candle_job.sh $EXAMPLEDIR/raw_params.txt $WORKINGDIR

2. Make an unrolled parameter file, e.g.:

  2a. Edit $WORKINGDIR/raw_params.txt to contain the "naked" parameters to be "clothed" in the unrolled parameter file we're about to make.  NOTE: This file format will be JSON so special Python variables (e.,g., True, False, None) must be in JSON format (e.g., true, false, null).  See e.g. https://docs.python.org/3/library/json.html#py-to-json-table.

  2b. Run a command like the following (which is the commented-out line in $EXAMPLEDIR/make_upf_file.sh) in order to "clothe" the raw parameters:

        awk '{printf("{""\"id""\": ""\"hpset_%s""\", ""\"nlayers""\": %s, ""\"conv_size""\": %s, ""\"activation""\": ""\"%s""\", ""\"num_filters""\": %s, ""\"initialize""\": ""\"%s""\", ""\"epochs""\": %s}\n",$1,$2,$3,$4,$5,$6,$7)}' $WORKINGDIR/raw_params.txt > $WORKINGDIR/upf.txt

  2c. Look through the created file $WORKINGDIR/upf.txt to make sure everything is reasonable, e.g., the quotation marks.  Modify if necessary, maybe even adding settings to some lines, e.g.,

        "batch_norm": true

3. Modify the parameters in $WORKINGDIR/submit_candle_job.sh, particularly making sure that the $WORKFLOW_SETTINGS variable points to the unrolled parameter file that was just created, e.g.,

     WORKFLOW_SETTINGS=$SCRIPTDIR/upf.txt

4. Submit the CANDLE job using, e.g.,

     $WORKINGDIR/submit_candle_job.sh


Workflow for running single training job not using CANDLE:

1. Copy over the two necessary files:

     cp $EXAMPLEDIR/run_without_candle.sh $EXAMPLEDIR/single_param_set.txt $WORKINGDIR

2. Modify the model parameters by editing $WORKINGDIR/single_param_set.txt as appropriate.

3. Ensure the $DEFAULT_PARAMS_FILE variable in $WORKINGDIR/run_without_candle.sh points to the parameters file that was just modified, e.g.,

     export DEFAULT_PARAMS_FILE=/home/weismanal/notebook/2019-01-28/jobs/not_candle/single_param_set.txt

4. Submit the CANDLE job using, e.g.,

     sbatch run_without_candle.sh


Original directories of files in this examples/ directory (set to $EXAMPLEDIR, e.g., /data/BIDS-HPC/public/candle/Supervisor/workflows/examples):

run_without_candle.sh:	/home/weismanal/notebook/2019-01-23/continuing_original_unet/continuation/run_without_candle.sh
single_param_set.txt:	/home/weismanal/notebook/2019-01-23/continuing_original_unet/continuation/default_params.txt
submit_candle_job.sh:	/home/weismanal/notebook/2019-01-20/upf_kedar_full/submit_candle_job.sh
upf.txt:		/home/weismanal/notebook/2019-01-20/upf_kedar_full/upf-5.txt
make_upf_file.sh:	/home/weismanal/notebook/2019-01-20/upf_kedar_full/make_upf_file.sh
raw_params.txt:		/home/weismanal/notebook/2019-01-20/upf_kedar_full/params_for_third_continuation_run.txt
unet.py			/home/weismanal/notebook/2019-01-20/upf_kedar_full/run_unet-min.py

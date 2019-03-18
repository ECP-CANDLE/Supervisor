# Summary

In a nutshell:

1. Copy the submission script `$CANDLE_DIR/Supervisor/templates/submit_candle_job.sh` to a working directory.
2. Modify the variables in this script as appropriate, using the files in the `$CANDLE_DIR/Supervisor/templates` directory as templates.
3. Run the script from a submit node like `./submit_candle_job.sh`.

# How-to

In more detail, here are the steps required for running an arbitrary workflow on an arbitrary model using CANDLE:

1. Copy the submission script `$CANDLE_DIR/Supervisor/templates/submit_candle_job.sh` to a working directory.
2. Specify the model in the submission script:
   1. Set the `$MODEL_PYTHON_SCRIPT` variable to one of the models in the `$CANDLE_DIR/Supervisor/templates/models` directory (currently either "resnet", "unet", "uno", or "mnist_mlp").  Or, specify your own [CANDLE-compliant](https://ecp-candle.github.io/Candle/html/tutorials/writing_candle_code.html) Python model by setting both the `$MODEL_PYTHON_DIR` and `$MODEL_PYTHON_SCRIPT` variables as appropriate.
   2. Specify the corresponding default model parameters by setting the `$DEFAULT_PARAMS_FILE` variable to one of the files in the `$CANDLE_DIR/Supervisor/templates/model_params` directory.  Or, copy one of these template files to the working directory, modify it accordingly, and point the `$DEFAULT_PARAMS_FILE` variable to this file.
3. Specify the workflow in the submission script:
   1. Set the `$WORKFLOW_TYPE` variable as appropriate (currently supported are "upf", and, to a less-tested extent, "mlrMBO").
   2. Specify the corresponding workflow settings by setting the `$WORKFLOW_SETTINGS_FILE` variable to one of the files in the `$CANDLE_DIR/Supervisor/templates/workflow_settings` directory.  Or, copy one of these template files to the working directory, modify it accordingly, and point the `$WORKFLOW_SETTINGS_FILE` variable to this file.
4. Adjust any other variables in the submission script such as the output directory (specified by `$EXPERIMENTS`), the scheduler settings, etc.
5. Run the script from a submit node like `./submit_candle_job.sh`.

# Background

In general, it would be nice to allow for an arbitrary model (U-Net, ResNet, etc.) to be run using an arbitrary workflow (UPF, mlrMBO, etc.), all in an external working directory.  For example, here is a sample submission script:

```bash
#!/bin/bash

# Site-specific settings
export CANDLE_DIR="/data/BIDS-HPC/public/candle"
export SITE="biowulf"

# Job specification
export EXPERIMENTS="/home/weismanal/notebook/2019-02-28/experiments" # ensure this directory exists
export MODEL_NAME="my_test_unet_using_upf"
export OBJ_RETURN="val_dice_coef"

# Scheduler settings
export PROCS="5" # remember that PROCS-2 are actually used for computation
export PPN="1"
export WALLTIME="04:00:00"
export GPU_TYPE="k80" # the choices on Biowulf are p100, k80, v100, k20x
export MEM_PER_NODE="20G"

# Model specification
export MODEL_PYTHON_DIR="/home/weismanal/notebook/2019-02-28/unet"
export MODEL_PYTHON_SCRIPT="customizable_unet"
export DEFAULT_PARAMS_FILE="/home/weismanal/notebook/2019-02-28/unet/default_params.txt"

# Workflow specification
export WORKFLOW_TYPE="upf"
export WORKFLOW_SETTINGS_FILE="/home/weismanal/notebook/2019-02-28/unet/upf1.txt"

# Call the workflow
export EMEWS_PROJECT_ROOT="$CANDLE_DIR/Supervisor/workflows/$WORKFLOW_TYPE"
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CANDLE_DIR/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh $WORKFLOW_SETTINGS_FILE
```

When this script is run (no arguments accepted) on a Biowulf submit node, the necessarily [CANDLE-compliant](https://ecp-candle.github.io/Candle/html/tutorials/writing_candle_code.html) file `$MODEL_PYTHON_DIR/$MODEL_PYTHON_SCRIPT.py` will be run using the default parameters specified in `$DEFAULT_PARAMS_FILE`.  The CANDLE workflow used will be UPF (specified by `$WORKFLOW_TYPE`) and will be run using the parameters specified in `$WORKFLOW_SETTINGS_FILE`.  The results of the job will be output in `$EXPERIMENTS`.  Note that we can choose a different workflow by simply changing the value of the `$WORKFLOW_TYPE` variable, e.g.,

```bash
export WORKFLOW_TYPE="mlrMBO"
```

In the sample submission script above, the Python script containing the model (customizable_unet.py), the default model parameters (default_params.txt), and the unrolled parameter file (upf1.txt) are all specified in the "unet" subdirectory of the working directory "/home/weismanal/notebook/2019-02-28".  However, often a model, its default parameters, and a workflow's settings can be reused.

Thus, we provide templates of these three types of files in the `$CANDLE_DIR/Supervisor/templates` directory, the current structure of which is:

```
model_params/:
mnist1.txt  resnet1.txt  unet1.txt  uno1.txt

models/:
mnist/  resnet.py  unet.py  uno.py

workflow_settings/:
mlrmbo1.R  mlrmbo2.R  mlrmbo3.R  mlrmbo4.R  upf1.txt  upf2.txt  upf3.txt  upf-default.txt
```

We could modify the submission script above to utilize these templates by making these example changes:

```bash
# Old model specification
export MODEL_PYTHON_DIR="/home/weismanal/notebook/2019-02-28/unet"
export MODEL_PYTHON_SCRIPT="customizable_unet"
# New model specification
export MODEL_PYTHON_DIR="$CANDLE_DIR/Supervisor/templates/models"
export MODEL_PYTHON_SCRIPT="unet"

# Old model default parameters
export DEFAULT_PARAMS_FILE="/home/weismanal/notebook/2019-02-28/unet/default_params.txt"
# New model default parameters
export DEFAULT_PARAMS_FILE="$CANDLE_DIR/Supervisor/templates/model_params/unet1.txt"

# Old workflow settings
export WORKFLOW_SETTINGS_FILE="/home/weismanal/notebook/2019-02-28/unet/upf1.txt"
# New workflow settings
export WORKFLOW_SETTINGS_FILE="$CANDLE_DIR/Supervisor/templates/workflow_settings/upf1.txt"
```

Indeed, the submission script modified as above is what we provide as our template submission script located  at `$CANDLE_DIR/Supervisor/templates/submit_candle_job.sh`.

# Note on CANDLE-compliance

Rather than hardcoding the default parameters file in the candle.Benchmark instantiation in the initialize_parameters() function of the [CANDLE-compliant](https://ecp-candle.github.io/Candle/html/tutorials/writing_candle_code.html) model, we should allow an arbitrary set of default parameters by allowing them to be set by the `$DEFAULT_PARAMS_FILE` environment variable, e.g.,

```python
# Old instantiation
mymodel_common = candle.Benchmark(file_path, 'default_params.txt', 'keras', prog='myprog', desc='My example')
# New instantiation
mymodel_common = candle.Benchmark(file_path, os.getenv("DEFAULT_PARAMS_FILE"), 'keras', prog='myprog', desc='My example')
```

I'd recommend this be added to the standard method for making a model [CANDLE-compliant](https://ecp-candle.github.io/Candle/html/tutorials/writing_candle_code.html).

Note further that `$DEFAULT_PARAMS_FILE` must be a full pathname.  Otherwise, if we just used the filename "default_params.txt" hardcoded into the `$MODEL_PYTHON_SCRIPT`, the script would look for this global parameter file in the same directory that it's in (i.e., `$MODEL_PYTHON_DIR`), but that would preclude using a `$MODEL_PYTHON_SCRIPT` that's a symbolic link.  In that case, we'd have to always copy the `$MODEL_PYTHON_SCRIPT` to the current working directory, which is inefficient because this leads to unnecessary duplication of code.
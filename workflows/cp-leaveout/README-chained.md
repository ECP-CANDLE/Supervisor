# Challenge Problem: Leave Out - Job Chained Workflow #

This workflow runs the CP Leave Out workflow using job chaining. Each stage
of the workflow will be submitted as a separate job where subsequent stages are
only run when the previous job on which they depend has successfully completed.
For example, if the workflow configuration consists of an initial 4 Uno model runs, and a 
subsequent 16 model runs where each of those model runs require the trained weights 
of one of the initial 4 as input, then the first 4 will be submitted as a job, and 
the second 16 as a job that will only begin running when the first has successfully 
completed.

## Requirements

* Check out Benchmarks branch loocv into a compute-node writeable directory,
    e.g., /gpfs/alpine/med106/scratch/$USER
  * Edit uno_baseline_keras2.py to replace uno_default_model.txt  with uno_auc_model.txt
  * Set `BENCHMARKS_ROOT` in your submission script (see below),
e.g., test-1.sh, to this compute node writable Benchmarks directory.
* The following data files are required:
  * A plan json file (e.g., `plangen_cell1593-p4_drug1779-p1.json`)
  * A dataframe file (e.g., `top_21.res_reg.cf_rnaseq.dd_dragon7.labled.feather`), a feather or parquet
  file will be faster.


## Running the Workflow ##

Sample files for configuring and running the workflow are in the `test-chained` directory. 
The workflow itself is launched using the python script `py/run_chained.py`. Essentially,
`run_chained.py` does the following:

1. Reads a configuration file specifying what data files to use, how many stages to run,
and how to configure each of those stages (e.g. PROCS, WALLTIME, etc.),
2. Generates a UPF file for each stage where each UPF file contains the node ids to run for that stage,
3. Runs each stage as a separate UPF-style workflow job, managing the job and parent model weight location dependencies appropriately. 

Each individual stage job submission launched by `run_chained.py` follows the pattern of the other Supervisor workflows where
a *test* submission script is executed which in turn sources *sys* and *prm* configurations, and then
calls another script (e.g., `swift/cpl-upf-workflow.sh`) that performs further configuration and executes the swift script 
(e.g., `swift/cpl-upf-workflow.swift`).

`run_chained.py` performs this individual job submission for each stage by:

1. Ading environment variables such as PROCS and WALLTIME to the environment
2. Running the submission script (e.g. test-1.sh) with this new environment

### Arguments

`run_chained.py` takes 3 arguments:

```
usage: run_chained.py [-h] [--stages STAGES] --config CONFIG [--dry_run]
```

* --config - the path of the workflow configuration file
* --stages - the number of stages to run. This will override the value specified in the configuration file
* --dry_run - executes the workflow, displaying the configuration for each stage, but does **not** submit any jobs

Of these only `--config` is required.

`run_chained.py` should be run from within the test-chained directory.

### Workflow Configuration File Format

The configuration file has the following json format (see `test-chained/cfg.json` for an example):

* site: the name of the hpc site (e.g. "summit")
* plan: the path to the challenge problem leave one out plan file
* submit_script: the script used for the individual stage job submission (e.g. test-chained/test-1.sh)
* upf_directory: the directory where the upf files are written out to
* stages: the number of stages to run. -1 = run all the stages
* stage_cfg_script: the staget configuration script (e.g. `test-chained/cfg-stage-sys.sh`) sourced by the 
submit script to set the configuration (WALLTIME etc.) for each individual stage run. 
Environment variables specified in the "stage_cfgs" (see below) will override those in this file.
* stage_cfgs: a list of optional stage configurations, where each configuration is a json map. By default, if no
stage configuration is defined for a particular stage or PROCS and PPN are not defined in that 
stage configuration, then PROCS will be set to the number of plan nodes to run (i.e., the length of the UPF file) + 1 and PPN will be set to 1. In this way, the default is to run all the Uno model runs 
concurrently. For the other environment variables in a stage configuration, the defaults in the
stage_cfg_script will be used. All the key value pairs in a stage configuration except for *stage* are preserved as environment variables when the submit_script is called and will override those (e.g., WALLTIME, etc.) in the stage_cfg_script. A stage configuration map can have the following entries. 
  * stage: the stage number
  * X: where X is an environment variable from the stage_cfg_script, e.g. WALLTIME, PROCS, PPN, etc.
  

### An Example Run

```
python ../py/run_chained.py --config cfg.json --stages 2

Total Jobs: 2
Total Stages: 2
Nodes: 4
Site: summit
Plan: /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1.json
Submit Script: ./test-1.sh
Stage Configuration Script:./cfg-sys.sh
UPF directory: /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs
	Stage: 1, UPF: plangen_cell1593-p4_drug1779-p1_s1_upf.txt, Model Runs: 4, PROCS: 5, PPN: 1
	Stage: 2, UPF: plangen_cell1593-p4_drug1779-p1_s2_upf.txt, Model Runs: 16, PROCS: 17, PPN: 1

########### JOB 1 - X134 - 704496 ##############
Running: ./test-1.sh summit -a ./cfg-sys.sh /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1.json /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1_s1_upf.txt 1 job0 ## JOB 0
mkdir: created directory '/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/cp-leaveout/experiments/X134'
Resovled Stage Configuration:
   PROCS: 5
   PPN: 1
   WALLTIME: 01:00:00
   TURBINE_DIRECTIVE: \n#BSUB -alloc_flags "NVME maximizegpfs"\n## JOB 0
   TURBINE_LAUNCH_OPTIONS: -a1 -c42 -g1 
   BENCHMARK_TIMEOUT: -1
   SH_TIMEOUT: 
   IGNORE_ERRORS: 0
CPL-UPF-WORKFLOW.SH: Running model: uno for EXPID: X134
sourcing /autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/common/sh/env-summit.sh

Lmod is automatically replacing "xl/16.1.1-3" with "gcc/7.4.0".


Due to MODULEPATH changes, the following have been reloaded:
  1) spectrum-mpi/10.3.0.1-20190611

sourcing /autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/common/sh/sched-summit.sh
WORKFLOW_SWIFT: cpl-upf-workflow.swift
WARN  /tmp/swift-t-cpl-upf-workflow.IpP.swift:63:17: Variable usage warning. Variable plan_id is not used
WARN  obj_app.swift:13:3: variable called turbine_output already defined at swift-t-cpl-upf-workflow.IpP.swift:246
WARN  obj_app.swift:36:3: variable called turbine_output already defined at swift-t-cpl-upf-workflow.IpP.swift:246
TURBINE-LSF SCRIPT
NODES=5
PROCS=5
PPN=1
TURBINE_OUTPUT=/gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X134
wrote: /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X134/turbine-lsf.sh
PWD: /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X134
Job <704496> is submitted to default queue <batch>.
JOB_ID=704496
WORKFLOW OK.
EXIT CODE: 0
test-1: SUCCESS

TURBINE_OUTPUT: /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X134
JOB_ID: 704496


########### JOB 2 - X135 - 704497 ##############
Running: ./test-1.sh summit -a ./cfg-sys.sh /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1.json /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1_s2_upf.txt 2 /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X134 #BSUB -w done(704496)
mkdir: created directory '/autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/cp-leaveout/experiments/X135'
Resovled Stage Configuration:
   PROCS: 17
   PPN: 1
   WALLTIME: 00:45:00
   TURBINE_DIRECTIVE: \n#BSUB -alloc_flags "NVME maximizegpfs"\n#BSUB -w done(704496)
   TURBINE_LAUNCH_OPTIONS: -a1 -c42 -g1 
   BENCHMARK_TIMEOUT: -1
   SH_TIMEOUT: 
   IGNORE_ERRORS: 0
CPL-UPF-WORKFLOW.SH: Running model: uno for EXPID: X135
sourcing /autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/common/sh/env-summit.sh

Lmod is automatically replacing "xl/16.1.1-3" with "gcc/7.4.0".


Due to MODULEPATH changes, the following have been reloaded:
  1) spectrum-mpi/10.3.0.1-20190611

sourcing /autofs/nccs-svm1_proj/med106/ncollier/repos/Supervisor/workflows/common/sh/sched-summit.sh
WORKFLOW_SWIFT: cpl-upf-workflow.swift
WARN  /tmp/swift-t-cpl-upf-workflow.CeR.swift:63:17: Variable usage warning. Variable plan_id is not used
WARN  obj_app.swift:13:3: variable called turbine_output already defined at swift-t-cpl-upf-workflow.CeR.swift:246
WARN  obj_app.swift:36:3: variable called turbine_output already defined at swift-t-cpl-upf-workflow.CeR.swift:246
TURBINE-LSF SCRIPT
NODES=17
PROCS=17
PPN=1
TURBINE_OUTPUT=/gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X135
wrote: /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X135/turbine-lsf.sh
PWD: /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X135
Job <704497> is submitted to default queue <batch>.
JOB_ID=704497
WORKFLOW OK.
EXIT CODE: 0
test-1: SUCCESS

TURBINE_OUTPUT: /gpfs/alpine/med106/scratch/ncollier/job-chain/experiments/X135
JOB_ID: 704497
```

### An Example Dry Run

```
python ../py/run_chained.py --config cfg.json --dry_run --stages 2

Total Jobs: 2
Total Stages: 2
Nodes: 4
Site: summit
Plan: /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1.json
Submit Script: ./test-1.sh
Stage Configuration Script:./cfg-sys.sh
UPF directory: /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs
	Stage: 1, UPF: plangen_cell1593-p4_drug1779-p1_s1_upf.txt, Model Runs: 4, PROCS: 5, PPN: 1
	Stage: 2, UPF: plangen_cell1593-p4_drug1779-p1_s2_upf.txt, Model Runs: 16, PROCS: 17, PPN: 1

########### DRY RUN JOB 1  ##############
Running: ./test-1.sh summit -a ./cfg-sys.sh /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1.json /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1_s1_upf.txt 1 job0 ## JOB 0
Resovled Stage Configuration:
   PROCS: 5
   PPN: 1
   WALLTIME: 01:00:00
   TURBINE_DIRECTIVE: \n#BSUB -alloc_flags "NVME maximizegpfs"\n## JOB 0
   TURBINE_LAUNCH_OPTIONS: -a1 -c42 -g1 
   BENCHMARK_TIMEOUT: -1
   SH_TIMEOUT: 
   IGNORE_ERRORS: 0


########### DRY RUN JOB 2  ##############
Running: ./test-1.sh summit -a ./cfg-sys.sh /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1.json /gpfs/alpine/med106/scratch/ncollier/job-chain/inputs/plangen_cell1593-p4_drug1779-p1_s2_upf.txt 2 <parent_turbine_output> #BSUB -w done(<parent_job_id>)
Resovled Stage Configuration:
   PROCS: 17
   PPN: 1
   WALLTIME: 00:45:00
   TURBINE_DIRECTIVE: \n#BSUB -alloc_flags "NVME maximizegpfs"\n#BSUB -w done(<parent_job_id>)
   TURBINE_LAUNCH_OPTIONS: -a1 -c42 -g1 
   BENCHMARK_TIMEOUT: -1
   SH_TIMEOUT: 
   IGNORE_ERRORS: 0
```
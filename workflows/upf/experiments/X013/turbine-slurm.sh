#!/bin/bash -l
# We changed the M4 comment to d-n-l, not hash
# We need 'bash -l' for the module system

# Copyright 2013 University of Chicago and Argonne National Laboratory
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# TURBINE-SLURM.SH

# Created: Fri Jan 18 19:07:23 EST 2019


# Define convenience macros
# This simply does environment variable substition when m4 runs



#SBATCH --output=/gpfs/gsfs9/users/BIDS-HPC/public/candle/Supervisor/workflows/upf/experiments/X013/output.txt
#SBATCH --error=/gpfs/gsfs9/users/BIDS-HPC/public/candle/Supervisor/workflows/upf/experiments/X013/output.txt

#SBATCH --partition=gpu




# TURBINE_SBATCH_ARGS could include --exclusive, --constraint=..., etc.
#SBATCH --gres=gpu:k20x:1 --mem=20g


#SBATCH --job-name=JOB:X013

#SBATCH --time=00:10:00
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=1
#SBATCH --workdir=/gpfs/gsfs9/users/BIDS-HPC/public/candle/Supervisor/workflows/upf/experiments/X013

# M4 conditional to optionally perform user email notifications


# User directives:


echo TURBINE-SLURM.SH

export TURBINE_HOME=$( cd "$(dirname "$0")/../../.." ; /bin/pwd )

VERBOSE=0
if (( ${VERBOSE} ))
then
 set -x
fi

TURBINE_HOME=/data/BIDS-HPC/public/candle/swift-t-install/turbine
source ${TURBINE_HOME}/scripts/turbine-config.sh

COMMAND="/usr/local/Tcl_Tk/8.6.8/gcc_7.2.0/bin/tclsh8.6 /gpfs/gsfs9/users/BIDS-HPC/public/candle/Supervisor/workflows/upf/experiments/X013/swift-t-workflow.NkB.tic -expid=X013 -benchmark_timeout=600 -f=upf-1.txt"

# Use this on Midway:
# module load openmpi gcc/4.9

# Use this on Bebop:
# module load icc
# module load mvapich2

TURBINE_LAUNCHER=srun

echo
set -x
${TURBINE_LAUNCHER}  \
                    ${TURBINE_INTERPOSER:-} \
                    ${COMMAND}
# Return exit code from mpirun

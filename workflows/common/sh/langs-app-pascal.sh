if [ -z "$SUPERVISOR_HOME" ]; then echo "SUPERVISOR_HOME is blank"; else echo "SUPERVISOR_HOME is set to '$SUPERVISOR_HOME'"; fi
source ${SUPERVISOR_HOME}/spack/loads

export PYTHONPATH=$PYTHONPATH

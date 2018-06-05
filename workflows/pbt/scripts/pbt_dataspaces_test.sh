set -eu

if [ "$#" -ne 3 ]; then
  script_name=$(basename $0)
  echo "Usage: ${script_name} PROCS EXPERIMENT_ID PARAMS_FILE"
  exit 1
fi

CLIENTS=$1

PATH=$HOME/sfw/dataspaces-1.6.5/bin:$PATH

rm -rf srv.clk conf *.log

dataspaces_server -s 1 -c $(( $CLIENTS - 1 )) &
DS_SERVER_PID=${!}
echo "dataspaces_server running: DS_SERVER_PID=$DS_SERVER_PID"

## Give some time for the servers to load and startup
while [ ! -f conf ]; do
    sleep 1s
done
sleep 5s

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
PBT_PY="$THIS/../python/tc1_pbt_ds.py"
source $THIS/cfg.sh $2 $3

cp  $THIS/dataspaces.conf $EXP_DIR/
cp $THIS/conf $EXP_DIR/

PARAMS_FILE=$( basename $PARAMS_PATH )
mpirun -n $CLIENTS python $PBT_PY $PARAMS_FILE $EXP_DIR tc1 $EXP_ID

cd $THIS

sleep 1

# Ensure dataspaces_server exited when Swift/T finalized the clients
if [ -f /proc/$DS_SERVER_PID ]
then
  echo "warning: dataspaces_server (PID=$DS_SERVER_PID) is still up"
fi

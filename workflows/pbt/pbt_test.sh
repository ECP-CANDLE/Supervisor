CLIENTS=2

PATH=$HOME/sfw/dataspaces-1.6.5/bin:$PATH

rm -rf srv.clk conf *.log

dataspaces_server -s 1 -c $CLIENTS &
DS_SERVER_PID=${!}
echo "dataspaces_server running: DS_SERVER_PID=$DS_SERVER_PID"

## Give some time for the servers to load and startup
while [ ! -f conf ]; do
    sleep 1s
done
sleep 5s

echo "starting main"
mpirun -n $CLIENTS python python/test.py

sleep 1

# Ensure dataspaces_server exited when Swift/T finalized the clients
if [ -f /proc/$DS_SERVER_PID ]
then
  echo "warning: dataspaces_server (PID=$DS_SERVER_PID) is still up"
fi

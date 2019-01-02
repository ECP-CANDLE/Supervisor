import eqpy
import sys
from mpi4py import MPI

def printf(s):
    print(s)
    sys.stdout.flush()

def init_comm(ranks):
    comm = MPI.COMM_WORLD 
    group = comm.Get_group()
    cache_group = group.Incl([int(x) for x in ranks])
    #printf("Cache Group size is {}".format(cache_group.size))
    return comm.Create_group(cache_group,1)

def run():
    ranks_str = eqpy.IN_get()
    ranks = ranks_str.split(',')
    # include only the al ranks
    task_ranks = ranks[2:]
   
    for r in task_ranks:
        eqpy.OUT_put(r)

    # include self and tasks in comm
    comm = init_comm(ranks[1:])
    rank = comm.rank
    #printf("task cache rank: {}".format(rank))

    while True:
        status = MPI.Status() 
        data = comm.recv(source=MPI.ANY_SOURCE, status=status)
        msg = data['msg']
        if msg == 'put':
            # this is its rank in the swift mpi communicator
            eqpy.OUT_put(data['rank'])
        elif msg == 'DONE':
            break

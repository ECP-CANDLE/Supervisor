import eqpy, sys
from mpi4py import MPI

def printf(s):
    print(s)
    sys.stdout.flush()

cache_comm = None

def init():
    global cache_comm
    ranks_str = eqpy.IN_get()
    ranks = ranks_str.split(',')[1:]
    #print(ranks)
    if cache_comm == None:
        comm = MPI.COMM_WORLD
        group = comm.Get_group()
        cache_group = group.Incl([int(x) for x in ranks])
        #printf("ME newgroup size is {}".format(cache_group.size))
        cache_comm = comm.Create_group(cache_group,1)

def run():
    # my swift-t MPI comm rank, and destination rank for cache_comm
    rank = eqpy.IN_get()
    #printf("AL Start on {}".format(rank))
    param = eqpy.IN_get()
    
    for _ in range(10):
        op = [param] * 5
        ps = ";".join(op)
        eqpy.OUT_put(ps)

        result = eqpy.IN_get()

    eqpy.OUT_put("DONE")
    eqpy.OUT_put("42")
    data = {'msg' : 'put', 'rank' : rank}
    cache_comm.send(data, dest=0, tag=1)

       




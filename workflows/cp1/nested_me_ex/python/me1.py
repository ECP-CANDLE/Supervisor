import eqpy
import random


# Generates parameters to be used by other MEs

def run():
    # gets dummy params for this me
    params = eqpy.IN_get()
    print("Params: {}".format(params))

    for _ in range(10):
        op = []
        for _ in range(5):
            p = "{},{},{},{}".format(random.randint(1, 10),
            random.randint(1, 10), random.randint(1, 10), 
            random.randint(1, 10))
            op.append(p)
        
        ps = ";".join(op)
        eqpy.OUT_put(ps)
        # wait to get result back
        eqpy.IN_get()
    
    eqpy.OUT_put("DONE")
    eqpy.OUT_put("final result")

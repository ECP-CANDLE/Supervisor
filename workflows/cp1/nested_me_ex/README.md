## An Example Nested Model Exploration (ME) Workflow ##

The workflow in `swift/workflow.swift` is a nested workflow where a *me1* resident
task provides parameters to any available *me2* resident tasks. The number of
*me2* resident tasks must be set before hand in `swift/workflow.sh` via
the *TURBINE_RESIDENT_WORK_WORKERS* variable. There must be at least 3
*TURBINE_RESIDENT_WORK_WORKERS*: one for the *me1* resident task, one for
the *task_cache* (see below) resident task and one for an *me2* 
resident task. Any more than 3 and the additional resident tasks are *me2*
resident tasks.

To run the workflow, edit `swift/workflow.sh` for your machine (i.e. edit
swift-t location, number of PROCS etc.), and 
run. The script takes a single argument: an experiment id. So, ```./workflow.sh t1```

Note that is work in progress and I have seen some seg faults when then entire
workflow has finished.

The implementation consists of two nested loops driven by these resident
tasks. The overall flow looks like:

1. Initialization
2. The *me1* produces sets of parameters
3. Each parameter set is consumed by an *me2* instance
4. An *me2* instance produces parameters for model runs
5. After some number of model runs, the *me2* returns a result to the *me1* and we go back to step 2.

Both loops are typical EMEWS style ME loops where some python code is intialized 
with an *EQPy_init_package* and an *EQPy_run* (this latter call is new and custom 
for this). For the *me1* we can see the initialization in line 133 and run in line 134. 
The *me1* package is in `python/me1.py` which constains some dummy code
to exercise the workflow.

The *me1* loop starts on line 151. The *EQPy_get* on line 157 produces the actual
parameters for the me2 to work on. THe *eqpy.OUT_put* on line 19 of 
me1.py is what is sending these parameters from *me1.py*.

The *me1* loops runs an me2 instance in lines 180-181.

```objc
string free_rank = EQPy_get(cache_loc);
results[j] = start_me2(p, i, j, free_rank);
```

The *EQPy_get* call gets the rank of an available resident task that can
be used to run the me2. *start_me2* then runs the
me2 loop using that resident task. 

The placeholder me2 ME is implemented in `python/me2.py`. 
As usual with EMEWS and like the *me1.py* above, this produces parameters and
passes them to swift for evaluation. The *eqpy.OUT_put(ps)* on line 32 in 
 `python/me2.py` produces the parameters and those parameters 
 are received by swift on line 72 in `swift/workflow.swift` in the *run_me2*
 loop. Note that currently the *run_model* call on line 95 that receives these parameters
 is just a placeholder. In the actual case, that would call the actual code to run the model.

 There's an additional swift resident task that runs the `python/task_cache.py` package.
 This keeps track of which me2 resident tasks are available for work. MPI is used to 
 communicate between `task_cache` and `me2`. `task_cache` contains a list of MPI ranks
 that can be used to run `me2` resident tasks. These ranks are pushed into an EQPY
 queue where they can be retreived by the swift workflow. When an `me2` instance completes, its rank is pushed into the queue, indicating that that rank is now free for work. `task_cache.init_comm` and `me2.init` create an MPI communicator that they
 use to communicate. I couldn't get this work without the back channel MPI. The code
 seemed to deadlock at various points. If there's a better way, please let me know.


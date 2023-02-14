import os
import subprocess
from pathlib import Path
import candle


class Comparator(candle.Benchmark):
    pass


file_path = os.path.dirname(os.path.realpath(__file__))


def initialize_parameters(default_model="cmp_default_model.txt"):
    global file_path
    bmk = Comparator(file_path,
                     default_model,
                     "keras",
                     prog="cmp_baseline",
                     desc="Meta-model to compare two models")
    # Initialize parameters
    gParameters = candle.finalize_parameters(bmk)
    return gParameters


def run(gParameters):
    print("COMPARATOR")
    print(str(gParameters))
    global file_path
    print("file_path: %s" % file_path)
    output_dir = gParameters["output_dir"]
    expid = gParameters["experiment_id"]
    runid = gParameters["run_id"]
    supervisor = Path(file_path).absolute().parent.parent
    workflows = supervisor / "workflows"
    print(model_sh)
    os.chdir(output_dir)
    cmd  = make_cmd(str(workflows), expid, runid)
    run_dir = Path(os.getenv("CANDLE_DATA_DIR")) \
        / model1 / "Output" / expid / runid
    print("env: " + str(env))
    print("cmd: " + str(cmd))
    results = {}
    for i in [ 1, 2 ]:
        result =
        model_name = gParameters["model%i" % i]
        env = make_env(str(workflows), model_name)
        with open(run_dir + "/start-%i.log" % i, "w") as fp:
            subprocess.run(cmd, env=env,
                           stdout=start_log,
                           stderr=subprocess.STDOUT)
        run_dir = Path(os.getenv("CANDLE_DATA_DIR")) \
            / model_name / "Output" / expid / runid
        with open(run_dir / "result.txt") as fp:
            line = fp.readline()
            results[i] = int(line)
            print("cmp: result %i: %f" % (i, results[i]))
    print("Comparator DONE.")


def make_env(workflows, model_name):
    env = { "WORKFLOWS_ROOT": workflows,
            "TURBINE_OUTPUT": output_dir,
            "EXPID": expid,
            "SITE": "lambda",
            "OBJ_RETURN": "loss",
            "BENCHMARK_TIMEOUT": "120",
            "MODEL_NAME": model_name,
            "CANDLE_MODEL_TYPE": "SINGULARITY",
            "CANDLE_DATA_DIR": os.getenv("CANDLE_DATA_DIR"),
            "ADLB_RANK_OFFSET": "0",
            "CANDLE_IMAGE": "/software/improve/images/GraphDRP.sif"
           }
    return env


def make_cmd(workflows, expid, runid):
    model_sh = workflows / "common" / "sh" / "model.sh"

    cmd = [ "bash", model_sh,
            "keras2", "{}", # empty JSON fragment
            expid,
            runid ]


def main():
    gParameters = initialize_parameters()
    run(gParameters)


if __name__ == "__main__":
    main()

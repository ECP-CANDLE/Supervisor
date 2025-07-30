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
    supervisor = Path(file_path).absolute().parent.parent
    workflows = supervisor / "workflows"
    model_sh = workflows / "common" / "sh" / "model.sh"
    print(model_sh)
    os.chdir(output_dir)

    # print("models: ", gParameters["models"])

    models = gParameters["models"]
    for model in models:

        env = { "WORKFLOWS_ROOT": str(workflows),
                "TURBINE_OUTPUT": output_dir,
                "EXPID": expid,
                "SITE": "lambda",
                "OBJ_RETURN": "loss",
                "BENCHMARK_TIMEOUT": "120",
                "MODEL_NAME": model,
                "CANDLE_MODEL_TYPE": "SINGULARITY",
                "CANDLE_DATA_DIR": os.getenv("CANDLE_DATA_DIR"),
                "ADLB_RANK_OFFSET": "0",
                # "CANDLE_IMAGE": "/software/improve/images/GraphDRP.sif",
                "CANDLE_IMAGE":f"/homes/ac.gpanapitiya/ccmg-mtg/Singularity/{model}.sif"
            }
        print("env: " + str(env))
        cmd = [ "bash", model_sh,
                "keras2", "{}", # empty JSON fragment
                expid,
                gParameters["run_id"] ]
        print("cmd: " + str(cmd))
        with open(f"{model}.log", "w") as model1_log:
            subprocess.run(cmd, env=env,
                        stdout=model1_log, stderr=subprocess.STDOUT)
    print("Comparator DONE.")

def main():
    gParameters = initialize_parameters(default_model='cmp_models.txt')
    run(gParameters)


if __name__ == "__main__":
    main()

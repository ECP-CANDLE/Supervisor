import csv
import datetime
import json
import subprocess
import sys
from os import path

TIME_FORMAT = "%Y/%m/%d %H:%M:%S"
START = 0
STOP = 1


def create_counts(timings_file):
    hpos = {"all": []}
    with open(timings_file) as f_in:
        reader = csv.reader(f_in)
        for row in reader:
            hpo_id = row[0]
            if hpo_id in hpos:
                hpos[hpo_id].append(row[1:])
            else:
                hpos[hpo_id] = [row[1:]]
            hpos["all"].append(row[1:])

    for k in hpos:
        sorted(hpos[k], itemgetter(0))

    counts = {"all": []}
    for k in hpos:
        count = 0
        for ts, ev in hpos[k]:
            if ev == START:
                count += 1
            else:
                count -= 1

            if k in counts:
                counts[k].append([ts, count])
            else:
                counts[k] = [[ts, count]]


def grep(model_log, rid, model_name):
    output = subprocess.check_output(
        ["grep", "-E", "RUN START|RUN STOP", model_log])
    lines = output.decode("utf-8")
    # id, start, end, train time, epochs
    result = [int(rid), model_name, -1, -1, -1, -1]
    complete = False
    for line in lines.split("\n"):
        idx = line.find(" __main")
        if idx != -1:
            ts = line[0:idx]
            dt = datetime.datetime.strptime(ts, TIME_FORMAT).timestamp()
            if line.endswith("START"):
                result[2] = dt
            elif line.endswith("STOP"):
                result[3] = dt
                complete = True

    # Current time ....1888.599
    # Epoch 2/100
    output = subprocess.check_output(["grep", "-E", "Current time", model_log])
    lines = output.decode("utf-8").strip().split("\n")
    line = lines[-1]
    ct = line[line.rfind(" ....") + len(" ...."):].strip()
    result[4] = float(ct)

    output = subprocess.check_output(["grep", "-E", "Epoch", model_log])
    lines = output.decode("utf-8").strip().split("\n")
    if complete:
        line = lines[-1]
    else:
        line = lines[-2]

    epochs = line[line.find(" "):line.find("/")]
    result[5] = int(epochs)

    return result


def write_results(results):
    with open("timings.txt", "w") as f_out:

        result = results[hpo_id]
        for r in result:
            for i in r:
                f_out.write("{} {}\n".format(i[0], i[1]))


def main(hpos_file, out_file):
    results = {}
    with open(out_file, "w") as f_out:
        writer = csv.writer(f_out)
        writer.writerow([
            "upf_id", "model_name", "start_ts", "end_ts", "total_train_time",
            "epochs"
        ])
        with open(hpos_file) as f_in:
            reader = csv.reader(f_in, delimiter="|")
            for i, row in enumerate(reader):
                if i % 1000 == 0:
                    print("ROW: {}".format(i))
                upf_id = row[0]
                params = json.loads(row[2])
                bname = path.basename(params["use_exported_data"])
                model_name = bname[:bname.find(".")]
                run_dir = params["save_path"]
                result = grep("{}/model.log".format(run_dir), upf_id,
                              model_name)
                writer.writerow(result)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])

import csv
import datetime
import os
import subprocess
import sys
from operator import itemgetter

TIME_FORMAT = "%Y/%m/%d %H:%M:%S"
START = 0
STOP = 1


def create_counts(timings_file, out_dir):
    hpos = {"all": []}
    with open(timings_file) as f_in:
        reader = csv.reader(f_in)
        for row in reader:
            hpo_id = row[0]
            line = [float(row[1]), int(row[2])]
            if hpo_id in hpos:
                hpos[hpo_id].append(line)
            else:
                hpos[hpo_id] = [line]
            hpos["all"].append(line)

    for k in hpos:
        hpos[k] = sorted(hpos[k], key=itemgetter(0))

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

    for k in counts:
        with open("{}/{}_counts.csv".format(out_dir, k), "w") as f_out:
            writer = csv.writer(f_out)
            for item in counts[k]:
                writer.writerow(item)


def grep(model_log):
    output = subprocess.check_output(
        ["grep", "-E", "RUN START|RUN STOP", model_log])
    lines = output.decode("utf-8")
    result = []
    for line in lines.split("\n"):
        idx = line.find(" __main")
        if idx != -1:
            ts = line[0:idx]
            dt = datetime.datetime.strptime(ts, TIME_FORMAT).timestamp()
            if line.endswith("START"):
                result.append((dt, START))
            else:
                result.append((dt, STOP))

    return result


def main(hpos_file, out_file):
    with open(out_file, "w") as f_out:
        with open(hpos_file) as f_in:
            reader = csv.reader(f_in, delimiter="|")
            for i, row in enumerate(reader):
                if i % 1000 == 0:
                    print("ROW: {}".format(i))
                # hpo_id = row[1]
                run_dir = row[3]
                rd = os.path.basename(run_dir)
                hpo_id = rd[:rd.find("_")]
                result = grep("{}/model.log".format(run_dir))
                for r in result:
                    f_out.write("{},{},{}\n".format(hpo_id, r[0], r[1]))


if __name__ == "__main__":
    # main(sys.argv[1], sys.argv[2])
    create_counts(sys.argv[1], sys.argv[2])

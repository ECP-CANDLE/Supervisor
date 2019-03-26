import sys
import csv
import subprocess
import datetime

TIME_FORMAT='%Y/%m/%d %H:%M:%S'
START = 0
STOP = 1

def grep(model_log):
    output = subprocess.check_output(['grep', '-E', "RUN START|RUN STOP", model_log])
    lines = output.decode("utf-8")
    result = []
    for line in lines.split('\n'):
        idx = line.find(' __main')
        if idx != -1:
            ts = line[0:idx]
            dt = datetime.datetime.strptime(ts, TIME_FORMAT)
            if line.endswith('START'):
                result.append((dt, START))
            else:
                result.append((dt, STOP))
    
    return result

def write_results(results):
    for hpo_id in results:
        with open('{}_timings.txt'.format(hpo_id), 'w') as f_out:
            result = results[hpo_id]
            for r in result:
                f_out.write('{} {}'.format(r[0], r[1]))

def main(hpos_file):
    results = {}
    with open(hpos_file) as f_in:
        reader = csv.reader(f_in, delimiter='|')
        for row in reader:
            hpo_id = row[1]
            run_dir = row[3]
            result = grep('{}/model.log'.format(run_dir))
            if len(result) > 0:
                if hpo_id in results:
                    results[hpo_id].append(result)
                else:
                    results[hpo_id] = [result]
    



            

if __name__ == "__main__":
    grep(sys.argv[1])
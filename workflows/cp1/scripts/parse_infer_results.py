
import sys
import csv
import subprocess
import datetime, json
from os import path
import numpy as np

  #mse: 0.2190,min,max,std
  #mae: 0.3251
  #r2: 0.4320
  #corr: 0.6584


def grep(infer_log):
    output = subprocess.check_output(['grep', '-E', "mse:|mae:|r2:|corr:", infer_log])
    lines = output.decode("utf-8").strip().split('\n')
    # print(lines)
    result = [np.nan] * 16
    # id, start, end, train time, epochs                                                                                                                        
    for line in lines:
        line = line.strip()
        if line.startswith('mse:') and line.find(',') != -1:
            l = line[5:]
            result[0], result[1], result[2], result[3] = [float(x) for x in l.split(',')]
        elif line.startswith('mae:') and line.find(',') != -1:
            l = line[5:]
            result[4], result[5], result[6], result[7] = [float(x) for x in l.split(',')]
        elif line.startswith('r2') and line.find(',') != -1:
            l = line[3:]
            result[8], result[9], result[10], result[11] = [float(x) for x in l.split(',')]
        elif line.startswith('corr') and line.find(',') != -1:
            l = line[6:]
            result[12], result[13], result[14], result[15] = [float(x) for x in l.split(',')]

    # print(result)
    return result

def create_params_map(training_file):
    param_map = {}
    with open(training_file) as f_in:
        reader = csv.reader(f_in, delimiter="|")
        for r in reader:
            params = json.loads(r[2])
            save_path = params['save_path']
            param_map[save_path] = params
    
    return param_map


def main(infer_log, training_file, out_file):
    param_map = create_params_map(training_file)
    with open(out_file, 'w') as f_out:
        writer = csv.writer(f_out)
        writer.writerow(['infer_id', 'model_class', 'instance_directory', 'params', 'model_path',
            'mse_mean', 'mse_min', 'mse_max', 'mse_std',
            'mae_mean', 'mae_min', 'mae_max', 'mae_std',
            'r2_mean', 'r2_min', 'r2_max', 'r2_std',
            'corr_mean', 'corr_min', 'corr_max', 'corr_std'])
        with open(infer_log) as f_in:
            reader = csv.reader(f_in, delimiter='|')
            # model class|data file|model|instance_dir
            for i, row in enumerate(reader):
                if i % 1000 == 0:
                    print('ROW: {}'.format(i))
                model_class = row[0]
                instance_dir = row[3]
                model_dir = path.dirname(row[2])
                params = param_map[model_dir]
                result = [i, model_class, instance_dir, params, row[2]] + grep('{}/infer.log'.format(instance_dir))
                writer.writerow(result)


if __name__ == '__main__':
    # inference directory, training file, output file, 
    main(sys.argv[1], sys.argv[2], sys.argv[3])

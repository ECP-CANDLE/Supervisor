import os

def initialize_parameters():
    return {}

def run(params):
    outdir = params['dirpath']
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    fname = '{}/model_out_{}.txt'.format(outdir, params['id'])
    with open(fname, 'w') as fout:
        for p in params:
            fout.write('{}: {}\n'.format(p, params[p]))

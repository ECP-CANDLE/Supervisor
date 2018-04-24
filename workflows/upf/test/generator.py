import json

MODEL_TEMPLATE="/project/projectdirs/m2924/hsyoo_/files/model.{}.json"

TEMPLATE='{"id": "combo.000", "sample_set": "GDSC", "drug_set": "NCI_IOA_AOA", "si":0, "ns": 1, "nd": 100, "n_pred": 30, "model_file": "/project/projectdirs/m2924/hsyoo_/files/uq.drop.10.model.h5", "weights_file": "/project/projectdirs/m2924/hsyoo_/files/uq.drop.10.weights.h5"}'
run=json.loads(TEMPLATE)

config_file = open('upf-combo.txt', 'w')

for dr in range(10, 30, 10):
    for i in range(0, 670, 1):
        run['id'] = "combo.%02d.%03d" % (dr, i)
        run['si'] = i
        run['model_file'] = MODEL_TEMPLATE.format(dr)
        print >> config_file, json.dumps(run)

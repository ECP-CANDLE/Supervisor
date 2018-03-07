
import json;

// Sample UPF fragment:
s = """
{ 'model_file':   '/project/projectdirs/m2924/brettin/combo-inference/uq.0/save/combo.A=relu.B=32.E=50.O=adam.LR=None.CF=r.DF=d.wu_lr.re_lr.res.D1=1000.D2=1000.D3=1000.D4=1000.model.h5', 'weights_file': '/project/projectdirs/m2924/brettin/combo-inference/uq.0/save/combo.A=relu.B=32.E=50.O=adam.LR=None.CF=r.DF=d.wu_lr.re_lr.res.D1=1000.D2=1000.D3=1000.D4=1000.weights.h5', 'drug_set':     'ALMANAC', 'sample_set':   'GDSC' }
""";

trace(s);
trace("model_file: ", json_get(s, "sample_set"));


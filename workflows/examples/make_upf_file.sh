#!/bin/bash

hpsets="10 11 16 17 22 23 28 34"

for hpset in $hpsets; do
    ls /home/weismanal/notebook/2019-01-20/upf_kedar_full/experiments/X008/run/hpset_${hpset}/model_weights.h5
done

# Then run something like:
#
#   awk '{printf("{""\"id""\": ""\"hpset_%s""\", ""\"nlayers""\": %s, ""\"conv_size""\": %s, ""\"activation""\": ""\"%s""\", ""\"num_filters""\": %s, ""\"initialize""\": ""\"%s""\", ""\"epochs""\": %s}\n",$1,$2,$3,$4,$5,$6,$7)}' raw_params.txt

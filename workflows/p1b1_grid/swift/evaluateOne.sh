#!/bin/bash
filename=$TURBINE_OUTPUT/result-$1.txt
python -u $EMEWS_PROJECT_ROOT/python/evaluateOne.py $1 $filename

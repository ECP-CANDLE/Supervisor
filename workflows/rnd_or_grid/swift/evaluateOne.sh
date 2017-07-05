#!/bin/bash
filename=$TURBINE_OUTPUT/result-$1.txt
python -u $APP_HOME/../python/evaluateOne.py $1 $filename $3

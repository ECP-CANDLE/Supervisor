#!/bin/bash
filename=result-$1.txt
python $APP_HOME/../python/evaluateOne.py $1 $filename

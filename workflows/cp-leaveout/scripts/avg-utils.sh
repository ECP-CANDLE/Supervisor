#!/bin/bash
set -eu

THIS=$( readlink --canonicalize $( dirname $0 ) )
SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

HELP="Provide an experiment DIR and measurement INTERVAL (seconds)!"
SIGNATURE -H "$HELP" DIR INTERVAL - ${*}

LOGS=$( find $DIR -name 'util-gpu.log' )

python3 $THIS/avg-utils.py $INTERVAL $LOGS

#!/bin/bash
set -eu

THIS=$( dirname $0 )

set -x
cd $THIS
jwplot plot.{cfg,eps,data}

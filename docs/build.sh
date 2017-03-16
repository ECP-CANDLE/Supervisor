#!/bin/sh
set -eu

THIS=$( cd $( dirname $0 ) ; /bin/pwd )

asciidoc --attribute stylesheet=$THIS/home.css \
         --attribute max-width=800px           \
         $*

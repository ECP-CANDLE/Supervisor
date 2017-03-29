#!/bin/sh

THIS=$( cd $( dirname $0 ) ; /bin/pwd )

set -x
asciidoc --attribute stylesheet=$THIS/format.css \
         --attribute max-width=800px \
         $*

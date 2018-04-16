puts [ ::pkg::create -name horovod \
                     -version 0.0 \
                     -load libhorovod.so \
                     -source horovod.tcl ]

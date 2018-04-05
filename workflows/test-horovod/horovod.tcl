namespace eval horovod {

    proc horovod_tcl { outputs inputs args } {
        set z [ lindex $outputs 0 ]
        set p [ lindex $inputs 0 ]
        rule $p "horovod::horovod_tcl_body $z $p" {*}$args type $turbine::WORK
    }

    proc horovod_tcl_body { z p } {
        # Retrieve p
        set p_value [ retrieve_string $p ]
        show p_value
        # Look up MPI information
        set comm [ turbine::c::task_comm ]
        set rank [ adlb::rank $comm ]
        # Run the user code
        set z_value [ controller $comm $p_value ]
        # Store result
        if { $rank == 0 } {
            store_integer $z $z_value
        }
    }
}

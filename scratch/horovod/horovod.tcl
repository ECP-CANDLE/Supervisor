
# HOROVOD TCL
# Glue interface from Swift/T to controller library

namespace eval horovod {

  proc horovod_tcl { outputs inputs args } {
    set z [ lindex $outputs 0 ]
    set code [ lindex $inputs 0 ]
    rule $code "horovod::horovod_tcl_body $z $code" {*}$args \
        type $turbine::WORK
  }

  proc horovod_tcl_body { z code } {

    # Retrieve code
    set code_value [ retrieve_string $code ]
    puts "running horovod"

    # Look up MPI information
    set comm [ turbine::c::task_comm ]
    set rank [ adlb::rank $comm ]

    # Set communicator for Horovod
    global env
    set env(HOROVOD_COMM) $comm

    # Run the Horovod controller
    set z_value [ controller $comm $code_value ]

    # Store result
    if { $rank == 0 } {
      store_float $z 0
      # $z_value
    }
  }
}

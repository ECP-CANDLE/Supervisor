
# HOROVOD TCL
# Glue interface from Swift/T to controller library

namespace eval horovod {

  proc horovod_tcl { outputs inputs args } {
    set z [ lindex $outputs 0 ]
    set k [ lindex $inputs 0 ]
    rule $k "horovod::horovod_tcl_body $z $k" {*}$args type $turbine::WORK
  }

  proc horovod_tcl_body { z k } {
    # Retrieve k
    set k_value [ retrieve_integer $k ]
    puts "running horovod k=$k"
    # Look up MPI information
    set comm [ turbine::c::task_comm ]
    set rank [ adlb::rank $comm ]
    # Run the Horovod controller
    set z_value [ controller $comm ]
      # $k_value
    # Store result
    if { $rank == 0 } {
      store_float $z 0
      # $z_value
    }
  }
}


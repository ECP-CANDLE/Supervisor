
# HOOK TCL
# This code runs on each leader rank,
#      i.e., once per node.

# Set a root data directory
set root $env(HOME)/data
puts "HOOK HOST: [exec hostname]"

# Get the leader communicator from ADLB
set comm [ adlb::comm_get leaders ]
# Get my rank among the leaders
set rank [ adlb::comm_rank $comm ]

# If I am rank=0, construct the list of files to copy
set EXPORTED_DATA_DIR  /ccs/home/hm0/med106_proj/Benchmarks/Pilot1/Uno
set EXPORTED_DATA_FILE top_21_auc_1fold.uno.h5

if { $rank == 0 } {
  set files [ list $EXPORTED_DATA_DIR/$EXPORTED_DATA_FILE ]
  puts "files: $files"
}

# Broadcast the file list to all leaders
turbine::c::bcast $comm 0 files

# Make a node-local data directory
set LOCAL_PREFIX /dev/shm

# Copy each file to the node-local directory
foreach f $files {
  if { $rank == 0 } {
    puts "copying: $f"
  }
  turbine::c::copy_to $comm $f $LOCAL_PREFIX
}

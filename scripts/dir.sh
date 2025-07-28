
D()
# Use
# $ D /path/to/EXP123
# to set up a directory for post-analysis
# Does some basic checking/reporting
# Sets global D
{
  if [[ ${#} != 1 ]]
  then
    echo "Provide DIR"
    return 1
  fi
  D=$1
  if [[ ! -d $D ]]
  then
    echo "Does not exist: D=$D"
    return 1
  fi
  if [[ ! -r $D/output.txt ]]
  then
    echo "No output.txt: D=$D"
    return 1
  fi
  grep "TURBINE_OUTPUT:"                  $D/turbine.log || return 1
  grep "SUBMITTED:\|STARTED:\|COMPLETED:" $D/turbine.log || return 1
  grep "EXIT CODE:" $D/turbine.log
}

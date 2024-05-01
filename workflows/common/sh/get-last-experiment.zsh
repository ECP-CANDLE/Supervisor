
# GET LAST EXPERIMENT
# A couple handy interactive functions

D()
# Find the latest experiment directory, assign to global variable D
{
  local R=""
  if (( ${#*} )) R=$1/
  D=( ${R}experiments/*(om[1]) )
  local _D
  _D=$D
  unset D
  D=$_D
  print "D=$D"
}

E()
# Inspect the outputs in $D ,
# assign to global variable E
{
  E=( $D/output.txt $D/out/out-*.txt )
}


# GET LAST EXPERIMENT
# A couple handy interactive functions

D()
# Find the latest experiment directory, assign to global variable D
{
<<<<<<< HEAD

  D=( experiments/*(om[1]) ) ; d D
  local _D
  _D=$D
  unset D
  export D=$_D
=======
  local R=""
  if (( ${#*} )) R=$1/
  D=( ${R}experiments/*(om[1]) )
  local _D
  _D=$D
  unset D
  D=$_D
  print "D=$D"
>>>>>>> ab33ab742faac840aa5fbcb2a938842243c466fe
}

E()
# Inspect the outputs in $D ,
# assign to global variable E
{
<<<<<<< HEAD
  e $D/output.txt $D/out/out-*.txt
=======
  E=( $D/output.txt $D/out/out-*.txt )
>>>>>>> ab33ab742faac840aa5fbcb2a938842243c466fe
}


# GET LAST EXPERIMENT
# A couple handy interactive functions

D()
# Find the latest experiment directory, assign to global variable D
{
  local _D
  case ${#*} {
    0) _D=( experiments/EXP*(om[1]) )
       if (( ${#_D} == 0 )) {
         print "D(): Nothing found!"
         return 1
       }
       ;;
    1) _D=$1
       if [[ ! -d $_D ]] {
         print "D(): Does not exist: $_D"
         return 1
       }
       ;;
    *) print "D(): Too many args!"
       return 1
       ;;
  }
  D=""
  export D=$_D
  d D
}

E()
# Inspect the outputs in $D ,
# assign to global variable E
{
  E=( $D/output.txt $D/out/out-*.txt )
}

deap()
# Report filename for the DEAP log, the 2nd-highest rank
{
  local DIR=$1
  local A=( $DIR/out/out-*.txt )
  print ${A[-2]}
}

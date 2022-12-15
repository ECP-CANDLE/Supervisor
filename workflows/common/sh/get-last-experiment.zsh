
# GET LAST EXPERIMENT
# A couple handy interactive functions

D()
# Find the latest experiment directory, assign to environment variable D
{
   D=( experiments/*(om[1]) ) ; d D
   local _D
   _D=$D
   unset D
   export D=$_D
}

E()
# Inspect the outputs in $D
{
   e $D/output.txt $D/out/out-*.txt
}

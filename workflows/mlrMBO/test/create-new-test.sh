#This relies on test-1.sh and related files
# requires two arguments 1. design size 2. wall clock time
# Please update or enhance as needed
cp test-1.sh test-$1.sh
cp cfg-prm-1.sh cfg-prm-$1.sh
cp cfg-sys-1.sh cfg-sys-$1.sh
NP=$(($1+2))
# setting the budget to be 10 times the number of evaluations
Budget=$(($1*10))
echo $NP
sed -i -e "s/sys-1/sys-$1/g" test-$1.sh
sed -i -e "s/prm-1/prm-$1/g" test-$1.sh

sed -i -e "s/PROCS:-3/PROCS:-$NP/g" cfg-sys-$1.sh
sed -i -e "s/WALLTIME:-00:10:00/WALLTIME:-$2/g" cfg-sys-$1.sh

sed -i -e "s/PROPOSE_POINTS:-5/PROPOSE_POINTS:-$1/g" cfg-prm-$1.sh
sed -i -e "s/MAX_CONCURRENT_EVALUATIONS:-1/MAX_CONCURRENT_EVALUATIONS:-$1/g" cfg-prm-$1.sh
sed -i -e "s/DESIGN_SIZE:-10/DESIGN_SIZE:-$1/g" cfg-prm-$1.sh
sed -i -e "s/MAX_BUDGET:-180/MAX_BUDGET:-$Budget/g" cfg-prm-$1.sh

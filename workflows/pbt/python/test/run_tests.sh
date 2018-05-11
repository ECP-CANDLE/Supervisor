

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
SUPERVISOR=$( cd "$PWD/../../../.."  ; /bin/pwd )
PP+=":$SUPERVISOR/workflows/common/python"

export PYTHONPATH=$PP

cd $THIS/..
python -m unittest -v test.pbt_tests
cd $THIS

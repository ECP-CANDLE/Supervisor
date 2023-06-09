
import io;
import python;

result_python = python("""
import sys, traceback
try:
    sys.argv = [ 'python' ]
    import tensorflow as tf
except Exception as e:
    info = sys.exc_info()
    s = traceback.format_tb(info[2])
    print(str(e) + ' ... \\n' + ''.join(s))
    sys.stdout.flush()
""",
     "repr(40+2)");
printf("result_python: %s", result_python);

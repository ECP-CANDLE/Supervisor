
import io;
import python;

r = python(----
import sys, traceback
try:
    sys.argv = ['python']
    import tensorflow as tf
except Exception as e:
  info = sys.exc_info()
  s = traceback.format_tb(info[2])
  sys.stdout.write('EXCEPTION in Python code: \\n' + repr(e) + ' ... \\n' + ''.join(s))
  sys.stdout.write('\\n')
  sys.stdout.flush()
----,
           "repr(tf.__version__)"); //
printf("TensorFlow version: %s", r);

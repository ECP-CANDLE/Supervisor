
import io;
import python;

r = python(----
import sys, traceback
try:
    sys.argv = ['python']
    import torch
except Exception as e:
  info = sys.exc_info()
  s = traceback.format_tb(info[2])
  sys.stdout.write('EXCEPTION in Python code: \\n' + repr(e) + ' ... \\n' + ''.join(s))
  sys.stdout.write('\\n')
  sys.stdout.flush()
----,
           "repr(torch.__version__)"); //
printf("PyTorch version: %s", r);

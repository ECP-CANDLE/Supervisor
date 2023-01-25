import launch;
import io;

string a1[] = [ "/home/nick/Documents/repos/horovod/examples/keras_mnist.py", "Instance_1" ];
int exitcode = @par=2 launch("python", a1);
printf("%i", exitcode);

string a2[] = [ "/home/nick/Documents/repos/horovod/examples/keras_mnist.py", "Instance_2" ];
int e2 = @par=2 launch("python", a2);

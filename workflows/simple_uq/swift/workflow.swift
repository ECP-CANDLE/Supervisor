
/**
   UQ WORKFLOW.SWIFT
*/

import files;
import io;
import location;
import python;

import obj_app;

samples = 10;

seed = 10101;
permute_size = 10;
training = 8;

ME = locationFromRank(0);

(string v)
configure(location ME, int seed, int size, int training)
{
  v = @location=ME
    python_persist("import permute",
                   "permute.configure(seed=%i, size=%i, training=%i)" %
                                     (seed,    size,    training));
}

(string tv)
get_tv(location ME)
{
  tv = @location=ME
    python_persist("import permute",
                   "permute.get_tv()");
}

(float loss)
obj_func(int index, string sets)
{
  file o<"run/%03i/loss.data"%index> = task(sets);
  loss_string = read(o);
  loss = string2float(loss_string);
}

(float loss)
loop(location ME, int samples)
{
  foreach i in [0:samples-1]
  {
    sets = get_tv(ME);
    printf("permutation sets: %s", sets);
    obj_func(i, sets);
  }
  loss = 0;
}

printf("HELLO")=>
  configure(ME, seed, permute_size, training) =>
  loop(ME, samples) =>
  printf("DONE!");

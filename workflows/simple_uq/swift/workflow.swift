
/**
   UQ WORKFLOW.SWIFT
*/

import io;
import python;

seed = 10101;
permute_size = 10;
training = 8;

(string v)
configure(int seed, int size, int training)
{
  v = python("import permute",
             "permute.configure(seed=%i, size=%i, training=%i)" %
                               (seed,    size,    training));
}

printf("HELLO");
configure(seed, permute_size, training) =>
  printf("DONE!");

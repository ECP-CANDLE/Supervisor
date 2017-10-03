
/**
   UQ WORKFLOW.SWIFT
*/

import files;
import io;
import python;
import stats;

import obj_app;

samples = 10;

seed = 10101;
permute_size = 10;
training = 8;

(float loss)
obj_func(int index)
{
  file o<"run/%03i/loss.data"%index> = task(index);
  loss_string = read(o);
  loss = string2float(loss_string);
}

(float avg_loss)
loop(int samples)
{
  float D[];
  foreach i in [0:samples-1]
  {
    D[i] = obj_func(i);
  }
  avg_loss = avg(D);
}

printf("WORKFLOW UQ")=>
  result = loop(samples);
printf("average loss: %f", result);

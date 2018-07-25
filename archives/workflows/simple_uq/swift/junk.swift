

import location;


ME = locationFromRank(0);

seed = 10101;
permute_size = 10;
training = 8;

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

  configure(ME, seed, permute_size, training) =>


/*
  I2.SWIFT

  The idea is to stuff all generated params combinations in a big
  array (params) indexed by the hash code of the params.  Then we pull
  out all the hash codes with keys(params) .  Then we can iterate over
  the hash codes, retrieve the params, and assign work to the ME_ranks
*/

import io;
import matrix;
import string;

int ME_ranks[];

string params[];

(string s) compute_string(int p)
{
  s = "my params are: " + int2string(p+5);
}

// Define ME_ranks
foreach i in [0:5]
{
  ME_ranks[i] = i;
}

// Compute all parameter strings
// Could be nested loops, whatever, the ordering does not matter
// because we have unique hashes
foreach i in [0:5]
{
  params_string = compute_string(i);
  int h = hash(params_string);
  // printf("hash: %i", h);
  params[h] = params_string;
}

// Get all hash codes in a contiguous array for looping
int K[] = keys_integer(params);

foreach hash_index, rank in K
{
  // printf("hash_index: %i", hash_index);
  params_string = params[hash_index];
  printf("run on ME rank: %i params: \"%s\"", rank, params_string);
}

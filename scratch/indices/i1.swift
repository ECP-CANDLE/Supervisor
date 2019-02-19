
import io;
import matrix;

// ME ranks?
int A[];

// mlrMBO parameters?
int B[string];

// integer form of B
int C[];

foreach i in [0:5]
{
  A[i] = i+5;
}

foreach i in [0:5]
{
  B[int2string(i+5)] = i+15;
}

printf("A:") =>
  vector_print_integer(A) =>
  {
    foreach v0, k0 in B
    {
      printf("B[\"%s\"]=%i", k0, v0);
      C[string2int(k0)] = v0;
    }
    
    foreach v1, k1 in C
    {
      printf("C[%i]=%i", k1, v1);
    }
  }
  

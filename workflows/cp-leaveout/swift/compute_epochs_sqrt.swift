(int result) compute_epochs(int stage)
{
  result = float2int(round(int2float(max_epochs) / sqrt(int2float(stage))));
}

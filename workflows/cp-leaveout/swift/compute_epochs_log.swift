(int result) compute_epochs(int stage)
{
  denominator = float2int(pow_integer(2, (stage - 1)));
  result = max_integer(max_epochs %/ denominator, 1);
}

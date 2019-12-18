(int result) compute_epochs(int stage)
{
  result = max_epochs * (S - stage + 1) %/ S;
}

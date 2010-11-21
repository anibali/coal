long long arithmetic(int n)
{
  int i = 1;
  long long x = 1;
  while(i <= n)
  {
    x = ((i + x * i) - i) / x;
    ++i;
  }
  return x;
}


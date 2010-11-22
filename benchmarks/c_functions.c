int prime(int n)
{
  if(n == 1) return 2;
  
  int x = 1;
  int y;
  int m = 1;
  
  while(m < n)
  {
    ++x;
    y = 2;
    while(x % y)
    {
      if(++y / x) ++m;
    }
  }
  
  return x;
}


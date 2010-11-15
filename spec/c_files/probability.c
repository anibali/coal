/* 
 * Calculates the number of ways to choose 'r' things from a group of 'n'.
 * See http://algorithm.isgreat.org/doku.php?id=combinations for more details.
 */
int choose(int n, int r)
{
  /* Take advantage of symmetry to keep 'r' low */
  if(n - r < r) r = n - r;
  
  if(r == 0) return 1;
  
  int result = n;
  int i = 1;
  while(i < r)
  {
    result = (result / i) * (n - i);
    ++i;
  }
  
  return result / r;
}

/* Really dodgy power function */
/* TODO: replace with an import */
float pow(float base, int index)
{
  float value = 1.0f;
  while(index > 0)
  {
    value *= base;
    --index;
  }
  return value;
}

/*
 * See http://algorithm.isgreat.org/doku.php?id=binomial_pdf for more details.
 */
float binom_pdf(int n, float p, int r)
{
  return choose(n, r) * pow(p, r) * pow(1 - p, n - r);
}


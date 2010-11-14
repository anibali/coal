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

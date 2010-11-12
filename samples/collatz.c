/* 
 * Calculates the Collatz stopping time for a given number.
 * See http://en.wikipedia.org/wiki/Collatz_conjecture for more details.
 */
unsigned long collatz(int n)
{
  unsigned long count = 0;
  
  while(n > 1)
  {
    count += 1;
    
    if(n % 2 == 0)
      n /= 2;
    else
      n = n * 3 + 1;
  }
  
  return count;
}


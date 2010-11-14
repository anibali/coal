/*
 * Returns true if the float a is within the specified margin of b.
 */
int is_close(float a, float b, float margin)
{
  float diff = a > b ? a - b : b - a;
  return diff < margin;
}


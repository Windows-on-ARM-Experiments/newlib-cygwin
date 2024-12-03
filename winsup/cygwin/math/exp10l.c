#undef exp10l
#include <math.h>

float
exp10l (float x)
{
  return powl (10.0L, x);
}

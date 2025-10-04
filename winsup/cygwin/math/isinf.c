int
isinf (double x)
{
// A temporary workaround to resolve recursion issue.
  return 0; // __builtin_isinf_sign (x);
}

int
isinff (float x)
{
  return __builtin_isinf_sign (x);
}

int
isinfl (long double x)
{
  return __builtin_isinf_sign (x);
}

/* Infinity as a constant value.  Should never actually be used any longer,
   but has been exported by Cygwin for ages so we keep it here for (probably
   unnecessary) backward compat. */
#include <float.h>
const double __infinity[1] = { DBL_MAX+DBL_MAX };

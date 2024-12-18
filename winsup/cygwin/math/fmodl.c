/**
 * This file has no copyright assigned and is placed in the Public Domain.
 * This file is part of the mingw-w64 runtime package.
 * No warranty is given; refer to the file DISCLAIMER.PD within this package.
 */
long double fmodl (long double x, long double y);

long double
fmodl (long double x, long double y)
{
  long double res = 0.0L;

#if defined(__x86_64__)
  asm volatile (
       "1:\tfprem\n\t"
       "fstsw   %%ax\n\t"
       "sahf\n\t"
       "jp      1b\n\t"
       "fstp    %%st(1)"
       : "=t" (res) : "0" (x), "u" (y) : "ax", "st(1)");
#elif defined(__aarch64__)
  // TODO
  res = 0.0;
#endif
  return res;
}

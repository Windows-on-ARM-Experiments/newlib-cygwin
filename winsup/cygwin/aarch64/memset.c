#include <stddef.h>

void *memset(void *s, int c, size_t n) {
    unsigned char *d = (unsigned char *)s;
    while (n--) {
        *d++ = (unsigned char)c;
    }
    return s;
}
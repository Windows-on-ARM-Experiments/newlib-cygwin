#include <stddef.h>

void *memchr(const void *s, int c, size_t n) {
    const unsigned char *ptr = (const unsigned char *)s;
    unsigned char char_c = (unsigned char)c;

    for (size_t i = 0; i < n; i++) {
        if (ptr[i] == char_c) {
            return (void *)(ptr + i);
        }
    }
    return NULL;
}
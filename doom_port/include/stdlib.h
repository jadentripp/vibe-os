#ifndef VIBE_DOOM_PORT_STDLIB_H
#define VIBE_DOOM_PORT_STDLIB_H

#include <stddef.h>

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1
#define RAND_MAX 0x7fffffff

static inline int abs(int value)
{
    return value < 0 ? -value : value;
}

long labs(long value);
int atoi(const char* text);
long atol(const char* text);
double atof(const char* text);
long strtol(const char* text, char** endptr, int base);
unsigned long strtoul(const char* text, char** endptr, int base);
double strtod(const char* text, char** endptr);
void qsort(void* base, size_t count, size_t size, int (*compar)(const void*, const void*));
void* bsearch(
    const void* key,
    const void* base,
    size_t count,
    size_t size,
    int (*compar)(const void*, const void*));
void* malloc(size_t size);
void* calloc(size_t count, size_t size);
void* realloc(void* ptr, size_t size);
void free(void* ptr);
void exit(int status);
char* getenv(const char* name);
int rand(void);
void srand(unsigned int seed);

#endif

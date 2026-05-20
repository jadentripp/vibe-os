#ifndef VIBE_DOOM_PORT_STDLIB_H
#define VIBE_DOOM_PORT_STDLIB_H

#include <stddef.h>

static inline int abs(int value)
{
    return value < 0 ? -value : value;
}

int atoi(const char* text);
long atol(const char* text);
void* malloc(size_t size);
void* calloc(size_t count, size_t size);
void* realloc(void* ptr, size_t size);
void free(void* ptr);
void exit(int status);
char* getenv(const char* name);
int rand(void);
void srand(unsigned int seed);

#endif

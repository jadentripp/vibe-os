#ifndef VIBE_DOOM_PORT_STRING_H
#define VIBE_DOOM_PORT_STRING_H

#include <stddef.h>

void* memcpy(void* dest, const void* src, size_t count);
void* memmove(void* dest, const void* src, size_t count);
void* memset(void* dest, int value, size_t count);
int memcmp(const void* left, const void* right, size_t count);
void* memchr(const void* data, int ch, size_t count);
size_t strlen(const char* text);
size_t strnlen(const char* text, size_t max_length);
char* strcpy(char* dest, const char* src);
char* strncpy(char* dest, const char* src, size_t count);
char* strcat(char* dest, const char* src);
char* strncat(char* dest, const char* src, size_t count);
int strcmp(const char* left, const char* right);
int strncmp(const char* left, const char* right, size_t count);
int strcasecmp(const char* left, const char* right);
int strncasecmp(const char* left, const char* right, size_t count);
char* strchr(const char* text, int ch);
char* strrchr(const char* text, int ch);
char* strpbrk(const char* text, const char* accept);
char* strstr(const char* text, const char* needle);
size_t strspn(const char* text, const char* accept);
size_t strcspn(const char* text, const char* reject);
char* strtok(char* text, const char* delimiters);
char* strtok_r(char* text, const char* delimiters, char** saveptr);
char* strdup(const char* text);
char* strndup(const char* text, size_t max_length);
char* strerror(int error);

#define strcmpi strcasecmp

#endif

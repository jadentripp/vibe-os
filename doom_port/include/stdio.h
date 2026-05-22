#ifndef VIBE_DOOM_PORT_STDIO_H
#define VIBE_DOOM_PORT_STDIO_H

#include <stdarg.h>
#include <stddef.h>

#define EOF (-1)
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

typedef struct vibe_doom_file FILE;

extern FILE* stdin;
extern FILE* stdout;
extern FILE* stderr;

int printf(const char* format, ...);
int fprintf(FILE* stream, const char* format, ...);
int sprintf(char* buffer, const char* format, ...);
int snprintf(char* buffer, size_t size, const char* format, ...);
int vprintf(const char* format, va_list args);
int vfprintf(FILE* stream, const char* format, va_list args);
int vsprintf(char* buffer, const char* format, va_list args);
int vsnprintf(char* buffer, size_t size, const char* format, va_list args);
int sscanf(const char* text, const char* format, ...);
int fscanf(FILE* stream, const char* format, ...);

FILE* fopen(const char* path, const char* mode);
size_t fread(void* ptr, size_t size, size_t count, FILE* stream);
size_t fwrite(const void* ptr, size_t size, size_t count, FILE* stream);
int fgetc(FILE* stream);
int getc(FILE* stream);
int ungetc(int ch, FILE* stream);
char* fgets(char* buffer, int size, FILE* stream);
int fputc(int ch, FILE* stream);
int putc(int ch, FILE* stream);
int putchar(int ch);
int fputs(const char* text, FILE* stream);
int puts(const char* text);
int fseek(FILE* stream, long offset, int whence);
long ftell(FILE* stream);
void rewind(FILE* stream);
int fclose(FILE* stream);
int fflush(FILE* stream);
int feof(FILE* stream);
int ferror(FILE* stream);
void clearerr(FILE* stream);
void setbuf(FILE* stream, char* buffer);
int getchar(void);
int remove(const char* path);
void perror(const char* text);

#endif

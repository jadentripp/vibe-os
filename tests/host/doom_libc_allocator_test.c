#define VIBE_LIBC_HOST_TEST 1

#define stdin vibe_test_stdin
#define stdout vibe_test_stdout
#define stderr vibe_test_stderr
#define abs vibe_test_abs
#define atoi vibe_test_atoi
#define atol vibe_test_atol
#define malloc vibe_test_malloc
#define calloc vibe_test_calloc
#define realloc vibe_test_realloc
#define free vibe_test_free
#define exit vibe_test_exit
#define getenv vibe_test_getenv
#define rand vibe_test_rand
#define srand vibe_test_srand
#define memcpy vibe_test_memcpy
#define memmove vibe_test_memmove
#define memset vibe_test_memset
#define memcmp vibe_test_memcmp
#define strlen vibe_test_strlen
#define strcpy vibe_test_strcpy
#define strncpy vibe_test_strncpy
#define strcat vibe_test_strcat
#define strncat vibe_test_strncat
#define strcmp vibe_test_strcmp
#define strncmp vibe_test_strncmp
#define strcasecmp vibe_test_strcasecmp
#define strncasecmp vibe_test_strncasecmp
#define strchr vibe_test_strchr
#define strrchr vibe_test_strrchr
#define strdup vibe_test_strdup
#define open vibe_test_open
#define read vibe_test_read
#define write vibe_test_write
#define close vibe_test_close
#define lseek vibe_test_lseek
#define access vibe_test_access
#define unlink vibe_test_unlink
#define mkdir vibe_test_mkdir
#define fstat vibe_test_fstat
#define stat vibe_test_stat
#define fopen vibe_test_fopen
#define fread vibe_test_fread
#define fwrite vibe_test_fwrite
#define fseek vibe_test_fseek
#define ftell vibe_test_ftell
#define fclose vibe_test_fclose
#define fflush vibe_test_fflush
#define feof vibe_test_feof
#define setbuf vibe_test_setbuf
#define getchar vibe_test_getchar
#define printf vibe_test_printf
#define fprintf vibe_test_fprintf
#define sprintf vibe_test_sprintf
#define snprintf vibe_test_snprintf
#define vprintf vibe_test_vprintf
#define vfprintf vibe_test_vfprintf
#define vsprintf vibe_test_vsprintf
#define vsnprintf vibe_test_vsnprintf
#define sscanf vibe_test_sscanf
#define fscanf vibe_test_fscanf

#include "../../doom_port/libc.c"

int vibe_syscall3(unsigned int number, unsigned int arg0, unsigned int arg1, unsigned int arg2)
{
    (void)number;
    (void)arg0;
    (void)arg1;
    (void)arg2;
    return -1;
}

static void fill_bytes(unsigned char* ptr, unsigned int count, unsigned char seed)
{
    unsigned int i;
    for (i = 0; i < count; ++i)
        ptr[i] = (unsigned char)(seed + i);
}

static int bytes_match(const unsigned char* ptr, unsigned int count, unsigned char seed)
{
    unsigned int i;
    for (i = 0; i < count; ++i)
        if (ptr[i] != (unsigned char)(seed + i))
            return 0;
    return 1;
}

int main(void)
{
    unsigned char* a;
    unsigned char* b;
    unsigned char* c;
    unsigned char* grown;
    unsigned char* reused;
    size_t used;
    char text[16];

    vibe_libc_host_heap_reset();
    a = malloc(64);
    b = malloc(32);
    if (!a || !b)
        return 1;
    used = vibe_libc_host_heap_used();

    free(a);
    c = malloc(48);
    if (c != a)
        return 2;
    if (vibe_libc_host_heap_used() != used)
        return 3;

    free(c);
    free(b);
    c = malloc(96);
    if (c != a)
        return 4;
    if (vibe_libc_host_heap_used() != used)
        return 5;

    vibe_libc_host_heap_reset();
    a = malloc(32);
    b = malloc(64);
    if (!a || !b)
        return 6;
    used = vibe_libc_host_heap_used();
    fill_bytes(a, 32, 17);
    free(b);
    grown = realloc(a, 80);
    if (grown != a)
        return 7;
    if (!bytes_match(grown, 32, 17))
        return 8;
    if (vibe_libc_host_heap_used() != used)
        return 9;

    vibe_libc_host_heap_reset();
    a = malloc(32);
    b = malloc(32);
    if (!a || !b)
        return 10;
    fill_bytes(a, 32, 91);
    grown = realloc(a, 96);
    if (!grown || grown == a)
        return 11;
    if (!bytes_match(grown, 32, 91))
        return 12;
    reused = malloc(16);
    if (reused != a)
        return 13;

    vibe_libc_host_heap_reset();
    a = malloc(32);
    if (!a)
        return 14;
    fill_bytes(a, 32, 43);
    used = vibe_libc_host_heap_used();
    grown = realloc(a, VIBE_LIBC_HOST_HEAP_SIZE * 2);
    if (grown)
        return 15;
    if (vibe_libc_host_heap_used() != used)
        return 16;
    if (!bytes_match(a, 32, 43))
        return 17;

    if (calloc((size_t)-1, 2))
        return 18;

    sprintf(text, "STCFN%.3d", 33);
    if (strcmp(text, "STCFN033"))
        return 19;
    sprintf(text, "WILV%d%d", 1, 2);
    if (strcmp(text, "WILV12"))
        return 20;

    return 0;
}

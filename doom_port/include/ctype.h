#ifndef VIBE_DOOM_PORT_CTYPE_H
#define VIBE_DOOM_PORT_CTYPE_H

static inline int isdigit(int ch)
{
    return ch >= '0' && ch <= '9';
}

static inline int isxdigit(int ch)
{
    return (ch >= '0' && ch <= '9')
        || (ch >= 'a' && ch <= 'f')
        || (ch >= 'A' && ch <= 'F');
}

static inline int islower(int ch)
{
    return ch >= 'a' && ch <= 'z';
}

static inline int isupper(int ch)
{
    return ch >= 'A' && ch <= 'Z';
}

static inline int isalpha(int ch)
{
    return islower(ch) || isupper(ch);
}

static inline int isspace(int ch)
{
    return ch == ' ' || (ch >= '\t' && ch <= '\r');
}

static inline int toupper(int ch)
{
    return islower(ch) ? ch - ('a' - 'A') : ch;
}

static inline int tolower(int ch)
{
    return isupper(ch) ? ch + ('a' - 'A') : ch;
}

#endif

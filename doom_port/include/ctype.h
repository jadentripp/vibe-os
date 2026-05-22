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

static inline int isalnum(int ch)
{
    return isalpha(ch) || isdigit(ch);
}

static inline int isspace(int ch)
{
    return ch == ' ' || (ch >= '\t' && ch <= '\r');
}

static inline int isblank(int ch)
{
    return ch == ' ' || ch == '\t';
}

static inline int iscntrl(int ch)
{
    return (ch >= 0 && ch < 0x20) || ch == 0x7f;
}

static inline int isgraph(int ch)
{
    return ch >= 0x21 && ch <= 0x7e;
}

static inline int isprint(int ch)
{
    return ch >= 0x20 && ch <= 0x7e;
}

static inline int ispunct(int ch)
{
    return isgraph(ch) && !isalnum(ch);
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

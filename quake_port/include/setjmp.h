#ifndef VIBE_QUAKE_PORT_SETJMP_H
#define VIBE_QUAKE_PORT_SETJMP_H

typedef unsigned long jmp_buf[6];

int setjmp(jmp_buf env);
void longjmp(jmp_buf env, int value);

#endif

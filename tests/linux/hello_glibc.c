#include <stdio.h>

int main(void) {
    puts("hello, glibc on vibe-os");
    if (fflush(stdout) != 0) {
        return 12;
    }
    return 11;
}

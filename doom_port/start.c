#include <stdlib.h>

#include "d_main.h"
#include "m_argv.h"

static char arg0[] = "vibe-doom";
static char* argv_storage[] = { arg0, 0 };

int user_main(void)
{
    myargc = 1;
    myargv = argv_storage;
    D_DoomMain();
    return 0;
}

void start(void)
{
    (void)user_main();
    exit(0);
    for (;;) {
    }
}

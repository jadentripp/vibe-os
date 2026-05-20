#include <stdlib.h>

#include "d_main.h"
#include "m_argv.h"
#include "vibe_os.h"

static char arg0[] = "vibe-doom";
static char arg_warp[] = "-warp";
static char arg_episode[] = "1";
static char arg_map[] = "1";
static char arg_skill[] = "-skill";
static char arg_skill_medium[] = "3";
static char* argv_storage[] = {
    arg0,
    arg_warp,
    arg_episode,
    arg_map,
    arg_skill,
    arg_skill_medium,
    0
};

int user_main(void)
{
    (void)vibe_syscall3(VIBE_SYS_GAMEPLAY_STATUS, VIBE_DOOM_INIT_STATUS | VIBE_DOOM_INIT_START, 0, 0);
    myargc = 6;
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

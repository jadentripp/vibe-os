# Agent Rules

This repo is a real OS project first. Agents working here must keep the work
centered on guest code: assembly, freestanding C, kernel subsystems, boot
loaders, drivers, user/runtime ABI, and Doom platform integration.

## Zero Python End State

- New legitimacy claims must start with assembly or tiny C code that runs in
  vibe-os. If the work can reasonably live in assembly, put it there.
- Assembly is the preferred implementation language for the OS itself: boot
  paths, CPU entry, interrupt/trap/syscall stubs, context switching, low-level
  drivers, paging entry, and ABI boundaries should move toward assembly first.
- C is allowed only when it keeps a surface small and understandable: Doom
  platform glue, freestanding runtime glue required by original Doom, tiny host
  tools that replace Python, and places where hand assembly would add bulk
  without improving the OS claim.
- Do not turn "replace Python" into "grow a large C proof-tool project." Prefer
  deleting obsolete proof code, moving proof into guest status fields, or
  strengthening assembly/kernel behavior before adding host C.
- C must stay modest. Do not replace a large Python proof script with a large C
  proof script unless the parent agent explicitly chooses that as a temporary
  bridge. Prefer deleting stale proof surfaces, moving checks into guest status,
  or writing tiny targeted host validators.
- Python is not part of the desired project architecture, build path, or proof
  path.
- Do not add new Python.
- Do not expand existing Python unless the parent agent explicitly allows a
  temporary compatibility edit during a C replacement.
- Replace Python tooling with the smallest practical host utilities, shell
  wrappers around compiled tools, Make targets, and guest-produced kernel/user
  status. Do not let replacement tooling become a second project.
- Existing Python is legacy debt to remove, not infrastructure to build on.
- Prefer guest status fields emitted by the OS over host-side inference.
- Track the language direction honestly: reduce Python, keep C modest, and make
  project-owned code trend majority assembly over time. The long-term shape
  should be boot/kernel/user assembly first, modest C second, Python absent.

## Git Ownership

- Subagents must not run Git state-changing commands.
- Only the parent/main agent stages, commits, rebases, stashes, merges, pulls,
  pushes, restores, or checks out files.
- Subagents may inspect files, edit their assigned files, run host-only tests,
  and report changed paths and results.

## Safety

- Do not run local QEMU or local VM proof on this Mac.
- QEMU proof belongs in disposable cloud/Codespaces/GitHub Actions lanes.
- Keep WADs, disk images, screenshots, raw audio, VM logs, and secrets out of
  git.

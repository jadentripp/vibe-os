# Codespaces Play Now

Use this path when you want to play vibe-os Doom quickly without running local
Mac QEMU. The Codespace is the disposable Linux host; QEMU, noVNC, and the WAD
stay there. Do not add WADs, disk images, screenshots, pixels, raw audio, or
other play artifacts to git.

## Create The Codespace

Fastest path from the Mac, with GitHub CLI authenticated:

```sh
./tools/play_now_codespaces.sh
```

The launcher creates a disposable Codespace from the current repo and branch,
starts `./tools/play_now_remote.sh` inside it, sets port `6080` private,
opens/prints the noVNC URL, and prints the log and delete commands. Codespaces
runs pushed git state, so push the branch first before treating the session as
current-head proof. QEMU, the shareware WAD, `build/disk.img`, pixel output, and
raw audio never run on or copy back to the Mac.

To reuse a specific existing Codespace:

```sh
./tools/play_now_codespaces.sh --codespace "<codespace-name>"
```

Delete the disposable play environment when done:

```sh
gh codespace delete -c "<codespace-name>" --force
```

Manual browser path:

1. Open the fork on GitHub.
2. Select the branch that contains the Doom play work.
3. Click `Code`.
4. Open the `Codespaces` tab.
5. Click `Create codespace on <branch>`.
6. Wait until the Codespace finishes building the dev container.

The dev container installs Python 3 plus the toolchain used by
`./tools/play_now_remote.sh`: `nasm`, `qemu-system-x86`, `clang`, `make`,
`netcat-openbsd`, `curl`, `novnc`, and `websockify`.

## Run The Play Script

In the Codespace terminal:

```sh
./tools/play_now_remote.sh --preflight
./tools/play_now_remote.sh
```

The preflight is a dry run: it checks host safety and dependencies, then exits
before fetching a WAD, building, or launching QEMU. The play script fetches and
validates the shareware `DOOM1.WAD` into `/tmp`, outside the repository. Leave
it outside git. The script refuses to run QEMU on macOS; this runbook uses
remote Codespaces QEMU only.

## Open noVNC

1. Keep the play script running.
2. In Codespaces, open the `Ports` tab.
3. Find port `6080`.
4. If it is not already forwarded, click `Forward a Port` and enter `6080`.
5. Set visibility to private unless you deliberately need otherwise.
6. Open the forwarded `6080` URL in the browser.

If the page does not connect automatically, use the forwarded Codespaces origin
with this path:

```text
/vnc.html?autoconnect=1
```

Do not open the raw `127.0.0.1:6080` noVNC URL in your local Mac browser unless
you created an SSH tunnel for that port. In Codespaces, the forwarded URL is the
bridge to the noVNC server. The QEMU VNC server stays bound to `127.0.0.1`
inside the Codespace.

Controls: arrows move and turn, Ctrl fires, Space uses, and Escape opens the
menu. noVNC does not carry game audio in this fast path.

## Destroy The Codespace

When finished:

1. Stop the play script with `Ctrl-C`.
2. Return to the repository on GitHub.
3. Open `Code`.
4. Open the `Codespaces` tab.
5. Click the `...` menu for the Codespace.
6. Click `Delete`.
7. Confirm deletion.

Deleting the Codespace removes the remote `/tmp` WAD and generated VM artifacts.
Do not copy them back into the repository.

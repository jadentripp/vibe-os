# id Software Doom Source

This directory vendors the official id Software Doom source release without
modifying the upstream files.

- Upstream repository: https://github.com/id-Software/DOOM
- Imported commit: `a77dfb96cb91780ca334d0d4cfd86957558007e0`
- License: GNU General Public License 2.0, as recorded in `LICENSE.TXT`
- Primary engine source: `linuxdoom-1.10`

`linuxdoom-1.10` is the closest lawful public source base for this project. The
top-level `README.TXT` says the released source is Linux-oriented and that id
could not release the DOS code because of a copyrighted sound library. The
`linuxdoom-1.10/README.b` file further states that this tree is based on a Doom
development directory snapshot that was stripped and changed, while still being
"the DOOM source."

Project policy: keep this vendor tree pristine and put all operating-system
port code, compatibility headers, and build glue outside `third_party/doom`.

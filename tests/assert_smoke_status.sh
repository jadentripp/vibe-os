#!/usr/bin/env sh
set -eu

BUILD_DIR="${BUILD_DIR:-build}"
SMOKE_SKIP_ASSERTIONS="${SMOKE_SKIP_ASSERTIONS:-0}"
SMOKE_CAPTURE_GFX="${SMOKE_CAPTURE_GFX:-1}"
SMOKE_EXPECT_PROBE_GFX="${SMOKE_EXPECT_PROBE_GFX:-1}"
SMOKE_REJECT_DOOMLOG="${SMOKE_REJECT_DOOMLOG:-}"
SMOKE_REQUIRE_DOOM_PRESENT="${SMOKE_REQUIRE_DOOM_PRESENT:-0}"
SMOKE_REQUIRE_DOOM_GAMEPLAY="${SMOKE_REQUIRE_DOOM_GAMEPLAY:-0}"
SMOKE_REQUIRE_REAL_WAD_PROOF="${SMOKE_REQUIRE_REAL_WAD_PROOF:-0}"
SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF="${SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF:-0}"
SMOKE_REQUIRE_AUDIO_CONTINUITY="${SMOKE_REQUIRE_AUDIO_CONTINUITY:-0}"
SMOKE_SENDKEYS="${SMOKE_SENDKEYS:-}"
SMOKE_REQUIRE_KEY_EVENT="${SMOKE_REQUIRE_KEY_EVENT:-0}"

status_txt="$BUILD_DIR/status.txt"
status_bin="$BUILD_DIR/status.bin"
gfx_bin="$BUILD_DIR/gfx.bin"

dump_diagnostics() {
  rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "Smoke assertion failed with status $rc."
    for status_file in "$BUILD_DIR"/status*.txt; do
      if [ -f "$status_file" ]; then
        echo "---- $status_file ----"
        cat "$status_file"
      fi
    done
    if [ -f "$BUILD_DIR/smoke.log" ]; then
      echo "---- smoke.log ----"
      tail -200 "$BUILD_DIR/smoke.log"
    fi
    if [ -f "$BUILD_DIR/qemu.log" ]; then
      echo "---- qemu.log ----"
      tail -200 "$BUILD_DIR/qemu.log"
    fi
    if [ -f "$BUILD_DIR/serial.log" ]; then
      echo "---- serial.log ----"
      tail -200 "$BUILD_DIR/serial.log"
    fi
  fi
  exit "$rc"
}

require_literal() {
  grep -F -q -- "$1" "$status_txt"
}

require_regex() {
  grep -E -q -- "$1" "$status_txt"
}

require_hex_gt_zero() {
  perl -ne 'BEGIN { $field = shift @ARGV } $ok = 1 if /(?:^| )\Q$field\E=([0-9A-Fa-f]+)/ && hex($1) > 0; END { exit($ok ? 0 : 1) }' "$1" "$status_txt"
}

require_hex_eq() {
  perl -ne 'BEGIN { $field = shift @ARGV; $want = hex(shift @ARGV) } $ok = 1 if /(?:^| )\Q$field\E=([0-9A-Fa-f]+)/ && hex($1) == $want; END { exit($ok ? 0 : 1) }' "$1" "$2" "$status_txt"
}

trap dump_diagnostics EXIT

test -s "$status_bin"
require_literal "vibe-os v0.2"

if [ "$SMOKE_SKIP_ASSERTIONS" = "1" ]; then
  trap - EXIT
  printf "Smoke capture OK: QEMU status snapshots captured; proof gates are expected to run separately.\n"
  exit 0
fi

while IFS= read -r needle; do
  require_literal "$needle"
done <<'EOF'
pg=ON
pmm=OK
vmm=OK
e820map=
pmmuse=
pmmtype=
pmmchk=OK
pmmalloc=
pmmdeny=
uguard=0000000F
vmmguard=0000000F/00000000
kreloc=HIGH
krelocstep=KPMAIN_HIGH
kerneip=
kernesp=
kerncr3=00090000
kernvirt=C0010000
kernphys=00010000
khiexec=OK
khieip=
khiesp=
khicr3=00090000
khiva=
khipa=
khistk=
khistkpa=
khipt=
khifree=
khixlat=
khisxlat=
khislot=
khislotpa=
khisword=48485354
khiret=
kpexec=OK
kpeip=
kpesp=
kpecr3=00090000
kpeva=
kpepa=
kpestk=
kpestkpa=
kpexlat=
kpesxlat=
kpeslot=
kpeslotpa=
kpesword=4B504558
kperet=
vmmhi=OK
vmmhva=C0000000
vmmhpa=
vmmhpt=
vmmhfree=
libc=OK
c=OK
fpu=OK
fpucr0=
fpucw=0000037F
fpusw=00000000/00000005/00000000
fpufault=
fpuctx=
usr=OK
wad=OK
lmp=OK
exec=OK
path=/APPS/DOOM/APP.ELF
uexec=OK
upath=/SYSTEM/INIT.ELF
upid=
uentry=
doom=OK
doomexit=
doomfault=
doomfaultip=
doomfaultv=
doomfaulterr=
 fault=
doomopen=OK
doomread=OK
doomwrite=
doomseek=
doomwad=
doomclose=
doomsbrk=
doomerr=
doomerrno=
doommode=
doomsav=
saverd=
savewr=
saveclose=
savemode=
saveact=
savedesc=
savestm=
savethk=
doomlog=
doompresent=
doompal=
doomframe=
doomnonzero=
doomcolors=
doomsamp=
doominit=
gameplay=
gstate=
gmap=
gtic=
leveltime=
dtick=
gflags=
gaction=
pflags=
pbuttons=
ppos=
pdelta=
pcmd=
pangle=
pangledelta=
pammo=
prefire=
pweapon=
doomsound=
sfxmix=
sfxq=
sfxbytes=
sfxdma=
sfxsrc=
sfxlast=
voices=
sfxvoices=
audioirq=
ack8=
ack16=
refill=
half=
mixwrap=
mixover=
mixunder=
mixclip=
steal=
pitchclamp=
panclamp=
musicvoices=
musicmix=
musicloop=
musicpos=
musicbuf=
musicunder=
musicdrops=
musicstream=
musicpull=
musicrend=
sb16=
dma=
play=
voiceq=
musicq=
adev=
pcm=
pcmbuf=
pcmstream=
pcmwrite=
pcmdev=
pcmqueue=
pcmpull=
pcmirq=
pcmdma=
inputqueue=
inputmods=
inputpoll=
keyirq=
keyqueue=
keypoll=
keyseen=
keylast=
mouseirq=
mousepkt=
mousepoll=
mousebtn=
mousedelta=
gfx=OK
heap=OK
EOF

while IFS= read -r pattern; do
  require_regex "$pattern"
done <<'EOF'
doomrun=(RUN|EXIT)
 pf=([0-9A-F]{8}/){4}[0-9A-F]{8}
faultsrc=(NONE|EXPECT|USER|DOOM|QUAKE|KERNEL)
faultmode=(NONE|USER|KERNEL)
faultcontain=([0-9A-F]{8}/){4}[0-9A-F]{8}
 regs=([0-9A-F]{8}/){7}[0-9A-F]{8}
 segs=([0-9A-F]{8}/){5}[0-9A-F]{8}
 proc=([0-9A-F]{8}/){8}[0-9A-F]{8}
panic=(NONE|KEXC)
shutdown=(NONE|HALT|REBOOT|POWEROFF)
audio=(SB16|NONE)
inputdepth=([0-9A-F]{8}:){1}[0-9A-F]{8}
inputstat=([0-9A-F]{8}:){3}[0-9A-F]{8}
inputpolicy=([0-9A-F]{8}:){1}[0-9A-F]{8}
inputdev=([0-9A-F]{8}:){1}[0-9A-F]{8}
inputdevices=([0-9A-F]{8}:){4}[0-9A-F]{8}
inputlast=([0-9A-F]{8}:){2}[0-9A-F]{8}
mouse=(OK|NONE)
fb=(LFB|M13)
fbpolicy=(ASP|SQ|M13)
fbgeom=([0-9A-F]{8}:){4}[0-9A-F]{8}
fbdirty=([0-9A-F]{8}:){4}[0-9A-F]{8}
EOF

if [ "$SMOKE_CAPTURE_GFX" = "1" ]; then
  test -s "$gfx_bin"
  if [ "$SMOKE_EXPECT_PROBE_GFX" = "1" ]; then
    if require_hex_gt_zero doompresent; then
      test "$(wc -c < "$gfx_bin")" -eq 64000
    else
      perl -e 'local $/; $d = <>; exit(length($d) == 64000 && ord(substr($d, 0, 1)) == 0 && ord(substr($d, 1, 1)) == 1 && ord(substr($d, 320, 1)) == 64 && ord(substr($d, 63999, 1)) == 255 ? 0 : 1)' "$gfx_bin"
    fi
  else
    test "$(wc -c < "$gfx_bin")" -eq 64000
  fi
fi

if [ -n "$SMOKE_REJECT_DOOMLOG" ]; then
  ! grep -E -q -- "$SMOKE_REJECT_DOOMLOG" "$status_txt"
fi

if [ "$SMOKE_REQUIRE_DOOM_PRESENT" = "1" ]; then
  require_hex_gt_zero doompresent
fi

if [ "$SMOKE_REQUIRE_DOOM_GAMEPLAY" = "1" ]; then
  require_literal "gameplay=OK"
  require_hex_eq gstate 0
  require_hex_eq gmap 00000101
  require_hex_gt_zero gtic
  require_hex_gt_zero leveltime
fi

if [ "$SMOKE_REQUIRE_REAL_WAD_PROOF" = "1" ]; then
  require_literal "path=/APPS/DOOM/APP.ELF"
  require_literal "doomopen=OK"
  require_literal "doomread=OK"
  require_literal "gameplay=OK"
  require_hex_eq gmap 00000101
  require_hex_gt_zero doomframe
fi

if [ "$SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF" = "1" ]; then
  echo "SMOKE_REQUIRE_HUMAN_PLAYABILITY_PROOF needs a C replacement before it can be used."
  exit 1
fi

if [ "$SMOKE_REQUIRE_AUDIO_CONTINUITY" = "1" ]; then
  require_literal "audio=SB16"
  require_hex_gt_zero sfxbytes
  require_hex_gt_zero musicpull
  require_hex_gt_zero pcmwrite
fi

if [ -n "$SMOKE_SENDKEYS" ] || [ "$SMOKE_REQUIRE_KEY_EVENT" = "1" ]; then
  require_hex_gt_zero inputqueue
  require_hex_gt_zero inputpoll
  require_hex_gt_zero keyirq
  require_hex_gt_zero keyqueue
  require_hex_gt_zero keypoll
  require_hex_gt_zero keyseen
fi

perl -ne '$ok = 1 if /heap=OK free=([0-9A-Fa-f]{8})/ && hex($1) >= 0x00700000; END { exit($ok ? 0 : 1) }' "$status_txt"
require_hex_gt_zero ticks

trap - EXIT
printf "Smoke boot OK: protected-mode kernel status, Ring 3 probe, primary payload ELF load, indexed-frame present, and PIT ticks verified in cloud VM memory.\n"

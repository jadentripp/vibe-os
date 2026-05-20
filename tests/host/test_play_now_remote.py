import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class PlayNowRemoteTests(unittest.TestCase):
    def test_play_now_script_is_remote_first_and_repo_safe(self):
        script = (ROOT / "tools" / "play_now_remote.sh").read_text()
        doc = (ROOT / "docs" / "runbooks" / "play-now-cloud.md").read_text()

        for needle in (
            'Usage: tools/play_now_remote.sh [--preflight|--dry-run]',
            '--preflight|--dry-run',
            'uname -s',
            'Refusing to run QEMU on macOS',
            'ALLOW_LOCAL_VM:-0',
            'python3 tools/check_play_now_remote.py',
            'if [ "$RUN_PREFLIGHT_ONLY" = "1" ]; then',
            '/tmp/vibe-os-DOOM1.WAD',
            'tools/prepare_shareware_wad.py',
            'make DOOM_WAD="$WAD_PATH"',
            'websockify --web=/usr/share/novnc',
            '/vnc.html?autoconnect=1',
            '-display "vnc=127.0.0.1:$VNC_DISPLAY"',
            '-drive file=build/disk.img,format=raw,if=ide,index=0,media=disk',
            '-audiodev none,id=snd0',
            '-device sb16,audiodev=snd0',
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, script)

        for forbidden in (
            'git add',
            'actions/upload-artifact',
            'build/gfx.bin',
            'build/doom-audio.wav',
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, script)

        for needle in (
            'Fastest safe path',
            'GitHub Codespaces',
            'forward port',
            'VNC does not carry game audio',
            'cloud `real-wad-smoke.yml` aggregate audio proof',
        ):
            with self.subTest(needle=needle):
                self.assertIn(needle, doc)

    def test_runbooks_do_not_document_local_mac_vm_override(self):
        for runbook in (
            "play-now-cloud.md",
            "codespaces-play-now.md",
            "cloud-interactive-playtest.md",
        ):
            text = (ROOT / "docs" / "runbooks" / runbook).read_text()
            with self.subTest(runbook=runbook):
                self.assertNotIn("ALLOW_LOCAL_VM=1", text)
                self.assertNotIn("brew install qemu", text)


if __name__ == "__main__":
    unittest.main()

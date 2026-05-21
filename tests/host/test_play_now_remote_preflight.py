import io
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
TOOLS = ROOT / "tools"
sys.path.insert(0, str(TOOLS))
try:
    import check_play_now_remote
finally:
    sys.path.pop(0)


def fake_tool_path(name):
    return f"/usr/bin/{name}"


class PlayNowRemotePreflightTests(unittest.TestCase):
    def test_macos_refuses_without_explicit_local_vm_opt_in(self):
        def fail_if_checked(name):
            raise AssertionError(f"tool lookup should not happen after macOS refusal: {name}")

        with self.assertRaisesRegex(
            check_play_now_remote.PreflightError,
            "Refusing to run QEMU on macOS",
        ):
            check_play_now_remote.check_preflight(
                env={},
                platform_name="Darwin",
                which=fail_if_checked,
            )

    def test_macos_main_reports_dry_run_refusal_without_tool_lookup(self):
        def fail_if_checked(name):
            raise AssertionError(f"tool lookup should not happen after macOS refusal: {name}")

        stdout = io.StringIO()
        stderr = io.StringIO()
        rc = check_play_now_remote.main(
            [],
            env={},
            platform_name="Darwin",
            which=fail_if_checked,
            stdout=stdout,
            stderr=stderr,
        )

        self.assertEqual(rc, 1)
        self.assertEqual(stdout.getvalue(), "")
        self.assertIn("Refusing to run QEMU on macOS", stderr.getvalue())
        self.assertIn("dry-run: QEMU was not launched", stderr.getvalue())

    def test_missing_required_tools_are_reported_before_play(self):
        present = {
            "python3": "/usr/bin/python3",
            "make": "/usr/bin/make",
        }

        with self.assertRaisesRegex(
            check_play_now_remote.PreflightError,
            "missing required tools: nasm, clang, qemu-system-x86_64",
        ):
            check_play_now_remote.check_preflight(
                env={},
                platform_name="Linux",
                which=present.get,
            )

    def test_invalid_novnc_port_is_reported_before_tool_lookup(self):
        def fail_if_checked(name):
            raise AssertionError(f"tool lookup should not happen after port refusal: {name}")

        with self.assertRaisesRegex(
            check_play_now_remote.PreflightError,
            "NOVNC_PORT must be between 1 and 65535",
        ):
            check_play_now_remote.check_preflight(
                env={"NOVNC_PORT": "0"},
                platform_name="Linux",
                which=fail_if_checked,
            )

    def test_invalid_vnc_display_is_reported_before_tool_lookup(self):
        def fail_if_checked(name):
            raise AssertionError(f"tool lookup should not happen after display refusal: {name}")

        with self.assertRaisesRegex(
            check_play_now_remote.PreflightError,
            "VNC_DISPLAY must be a non-negative integer",
        ):
            check_play_now_remote.check_preflight(
                env={"VNC_DISPLAY": "bad"},
                platform_name="Linux",
                which=fail_if_checked,
            )

    def test_novnc_port_must_not_overlap_qemu_vnc_port(self):
        def fail_if_checked(name):
            raise AssertionError(f"tool lookup should not happen after port conflict: {name}")

        with self.assertRaisesRegex(
            check_play_now_remote.PreflightError,
            "NOVNC_PORT and VNC_DISPLAY resolve to the same loopback TCP port",
        ):
            check_play_now_remote.check_preflight(
                env={"NOVNC_PORT": "5901", "VNC_DISPLAY": "1"},
                platform_name="Linux",
                which=fail_if_checked,
            )

    def test_success_on_linux_like_host_reports_optional_novnc_without_launching_qemu(self):
        looked_up = []

        def recording_which(name):
            looked_up.append(name)
            return fake_tool_path(name)

        stdout = io.StringIO()
        stderr = io.StringIO()
        rc = check_play_now_remote.main(
            [],
            env={},
            platform_name="Linux",
            which=recording_which,
            path_is_dir=lambda path: path == Path("/usr/share/novnc"),
            stdout=stdout,
            stderr=stderr,
        )

        self.assertEqual(rc, 0, stderr.getvalue())
        self.assertIn("play-now remote preflight OK", stdout.getvalue())
        self.assertIn("host CPUs:", stdout.getvalue())
        self.assertIn("noVNC port: 6080", stdout.getvalue())
        self.assertIn("QEMU VNC display: :1 (127.0.0.1:5901)", stdout.getvalue())
        self.assertIn("browser proxy: available", stdout.getvalue())
        self.assertIn("dry-run: QEMU was not launched", stdout.getvalue())
        self.assertIn("qemu-system-x86_64", looked_up)
        self.assertEqual(stderr.getvalue(), "")

    def test_success_uses_alternate_novnc_web_root_when_present(self):
        stdout = io.StringIO()
        stderr = io.StringIO()
        rc = check_play_now_remote.main(
            ["--require-novnc"],
            env={},
            platform_name="Linux",
            which=lambda name: fake_tool_path(name),
            path_is_dir=lambda path: path == Path("/usr/local/share/novnc"),
            stdout=stdout,
            stderr=stderr,
        )

        self.assertEqual(rc, 0, stderr.getvalue())
        self.assertIn("web root: /usr/local/share/novnc", stdout.getvalue())
        self.assertEqual(stderr.getvalue(), "")

    def test_explicit_novnc_web_root_must_exist(self):
        stdout = io.StringIO()
        stderr = io.StringIO()
        rc = check_play_now_remote.main(
            [],
            env={"NOVNC_WEB_ROOT": "/missing/novnc"},
            platform_name="Linux",
            which=lambda name: fake_tool_path(name),
            path_is_dir=lambda path: False,
            stdout=stdout,
            stderr=stderr,
        )

        self.assertEqual(rc, 1)
        self.assertEqual(stdout.getvalue(), "")
        self.assertIn("NOVNC_WEB_ROOT does not exist", stderr.getvalue())

    def test_success_without_novnc_reports_vnc_tunnel_fallback(self):
        stdout = io.StringIO()
        stderr = io.StringIO()
        rc = check_play_now_remote.main(
            [],
            env={},
            platform_name="Linux",
            which=lambda name: fake_tool_path(name) if name != "websockify" else None,
            path_is_dir=lambda path: False,
            stdout=stdout,
            stderr=stderr,
        )

        self.assertEqual(rc, 0, stderr.getvalue())
        self.assertIn("noVNC port: 6080", stdout.getvalue())
        self.assertIn("browser proxy: unavailable; use an SSH VNC tunnel", stdout.getvalue())
        self.assertIn("dry-run: QEMU was not launched", stdout.getvalue())
        self.assertEqual(stderr.getvalue(), "")

    def test_render_report_warns_on_two_core_hosts(self):
        report = check_play_now_remote.PreflightReport(
            platform_name="Linux",
            cpu_count=2,
            novnc_port=6080,
            vnc_display=1,
            vnc_port=5901,
            required_tools=tuple(
                check_play_now_remote.ToolStatus(name=name, path=f"/usr/bin/{name}")
                for name in check_play_now_remote.REQUIRED_TOOLS
            ),
            novnc=check_play_now_remote.NovncStatus(
                websockify="/usr/bin/websockify",
                web_root=Path("/usr/share/novnc"),
            ),
        )

        rendered = check_play_now_remote.render_report(report)

        self.assertIn("host CPUs: 2", rendered)
        self.assertIn("performance caveat: 2-core hosts can play Doom", rendered)
        self.assertIn("choose a 4-core+ Codespace", rendered)

    def test_render_report_marks_four_core_hosts_as_preferred(self):
        report = check_play_now_remote.PreflightReport(
            platform_name="Linux",
            cpu_count=4,
            novnc_port=6080,
            vnc_display=1,
            vnc_port=5901,
            required_tools=tuple(
                check_play_now_remote.ToolStatus(name=name, path=f"/usr/bin/{name}")
                for name in check_play_now_remote.REQUIRED_TOOLS
            ),
            novnc=check_play_now_remote.NovncStatus(
                websockify="/usr/bin/websockify",
                web_root=Path("/usr/share/novnc"),
            ),
        )

        rendered = check_play_now_remote.render_report(report)

        self.assertIn("host CPUs: 4", rendered)
        self.assertIn("4-core+ host detected", rendered)

    def test_require_novnc_fails_before_play_when_browser_proxy_is_missing(self):
        stdout = io.StringIO()
        stderr = io.StringIO()
        rc = check_play_now_remote.main(
            ["--require-novnc"],
            env={},
            platform_name="Linux",
            which=lambda name: fake_tool_path(name) if name != "websockify" else None,
            path_is_dir=lambda path: False,
            stdout=stdout,
            stderr=stderr,
        )

        self.assertEqual(rc, 1)
        self.assertEqual(stdout.getvalue(), "")
        self.assertIn("noVNC is required for this launch path", stderr.getvalue())
        self.assertIn("dry-run: QEMU was not launched", stderr.getvalue())


if __name__ == "__main__":
    unittest.main()

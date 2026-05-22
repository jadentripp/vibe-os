import os
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class LibcRuntimeReadinessTests(unittest.TestCase):
    def test_public_runtime_header_declares_generic_game_tool_wrappers(self):
        header = (ROOT / "doom_port" / "include" / "vibe_os.h").read_text()
        math_header = (ROOT / "doom_port" / "include" / "math.h").read_text()
        stdlib_header = (ROOT / "doom_port" / "include" / "stdlib.h").read_text()
        string_header = (ROOT / "doom_port" / "include" / "string.h").read_text()
        ctype_header = (ROOT / "doom_port" / "include" / "ctype.h").read_text()
        limits_header = (ROOT / "doom_port" / "include" / "limits.h").read_text()
        stdint_header = (ROOT / "doom_port" / "include" / "stdint.h").read_text()
        stdbool_header = (ROOT / "doom_port" / "include" / "stdbool.h").read_text()
        stdio_header = (ROOT / "doom_port" / "include" / "stdio.h").read_text()
        time_header = (ROOT / "doom_port" / "include" / "time.h").read_text()
        libc = (ROOT / "doom_port" / "libc.c").read_text()

        for token in (
            "int vibe_syscall_errno(int raw_result, int fallback_errno);",
            "int vibe_clock_monotonic(vibe_clock_time_t* out);",
            "unsigned long vibe_clock_ticks_to_milliseconds",
            "int vibe_file_size(const char* path, unsigned long* out_size);",
            "int vibe_file_read_all(",
            "int vibe_audio_device_start(void);",
            "int vibe_audio_mixer_start(unsigned long handle, const vibe_audio_voice_desc_t* desc);",
            "int vibe_audio_stream_info(unsigned long handle, vibe_audio_stream_info_t* info);",
            "int vibe_poll_input(vibe_input_event_t* event);",
            "int vibe_drain_input(vibe_input_event_t* events, unsigned long max_events);",
            "int vibe_input_status(vibe_input_status_t* status);",
            "int vibe_input_device_status(unsigned long device_id, vibe_input_device_status_t* status);",
            "int vibe_fb_get_info(vibe_fb_info_t* info);",
            "int vibe_fb_can_present_indexed(",
            "int vibe_present_indexed(const vibe_present_indexed_t* present);",
            "int vibe_present_indexed_checked(const vibe_present_indexed_t* present);",
            "unsigned long vibe_heap_capabilities(void);",
            "unsigned long vibe_vm_capabilities(void);",
            "void* vibe_mmap_anon(unsigned long length, int prot);",
            "VIBE_VM_CAP_FILE_PRIVATE_COPY",
            "The libc wrappers `vibe_poll_input`,",
            "`vibe_input_status`, and `vibe_input_device_status` pass the ABI byte sizes",
            "`vibe_drain_input` is a bounded nonblocking drain helper",
            "`vibe_fb_get_info` queries the reusable framebuffer contract",
            "`vibe_vm_capabilities` and `vibe_mmap_anon`",
        ):
            with self.subTest(token=token):
                self.assertIn(token, header)

        for token in (
            "double sin(double x);",
            "double cos(double x);",
            "double atan(double x);",
            "double atan2(double y, double x);",
            "double pow(double x, double y);",
            "double sqrt(double x);",
            "double floor(double x);",
            "double ceil(double x);",
            "double fabs(double x);",
        ):
            with self.subTest(token=token):
                self.assertIn(token, math_header)

        for token in (
            "#define EXIT_SUCCESS 0",
            "#define EXIT_FAILURE 1",
            "#define RAND_MAX 0x7fffffff",
            "long labs(long value);",
            "long strtol(const char* text, char** endptr, int base);",
            "unsigned long strtoul(const char* text, char** endptr, int base);",
            "double strtod(const char* text, char** endptr);",
            "double atof(const char* text);",
            "void qsort(void* base, size_t count, size_t size, int (*compar)(const void*, const void*));",
            "void* bsearch(",
        ):
            with self.subTest(token=token):
                self.assertIn(token, stdlib_header)

        self.assertIn("char* strerror(int error);", string_header)
        for token in (
            "void* memchr(const void* data, int ch, size_t count);",
            "size_t strnlen(const char* text, size_t max_length);",
            "char* strpbrk(const char* text, const char* accept);",
            "char* strstr(const char* text, const char* needle);",
            "size_t strspn(const char* text, const char* accept);",
            "size_t strcspn(const char* text, const char* reject);",
            "char* strtok(char* text, const char* delimiters);",
            "char* strtok_r(char* text, const char* delimiters, char** saveptr);",
            "char* strndup(const char* text, size_t max_length);",
        ):
            with self.subTest(token=token):
                self.assertIn(token, string_header)

        for token in (
            "static inline int isblank(int ch)",
            "static inline int iscntrl(int ch)",
            "static inline int isgraph(int ch)",
            "static inline int isprint(int ch)",
            "static inline int ispunct(int ch)",
        ):
            with self.subTest(token=token):
                self.assertIn(token, ctype_header)

        for token in (
            "#define CHAR_BIT 8",
            "#define INT_MAX 2147483647",
            "#define ULONG_MAX 4294967295UL",
        ):
            with self.subTest(token=token):
                self.assertIn(token, limits_header)

        for token in (
            "typedef int int32_t;",
            "typedef unsigned int uint32_t;",
            "typedef int intptr_t;",
            "#define UINT32_MAX 4294967295u",
        ):
            with self.subTest(token=token):
                self.assertIn(token, stdint_header)

        self.assertIn("#define bool _Bool", stdbool_header)

        for token in (
            "int fgetc(FILE* stream);",
            "int ungetc(int ch, FILE* stream);",
            "char* fgets(char* buffer, int size, FILE* stream);",
            "int fputc(int ch, FILE* stream);",
            "int fputs(const char* text, FILE* stream);",
            "int puts(const char* text);",
            "void rewind(FILE* stream);",
            "void perror(const char* text);",
        ):
            with self.subTest(token=token):
                self.assertIn(token, stdio_header)

        for token in (
            "#define CLOCKS_PER_SEC 1000L",
            "clock_t clock(void);",
            "time_t time(time_t* out);",
        ):
            with self.subTest(token=token):
                self.assertIn(token, time_header)

        for token in (
            "int vibe_syscall_errno(int raw_result, int fallback_errno)",
            "int vibe_clock_monotonic(vibe_clock_time_t* out)",
            "int vibe_file_size(const char* path, unsigned long* out_size)",
            "int vibe_file_read_all(",
            "int vibe_audio_device_start(void)",
            "int vibe_audio_mixer_start(unsigned long handle, const vibe_audio_voice_desc_t* desc)",
            "int vibe_audio_stream_info(unsigned long handle, vibe_audio_stream_info_t* info)",
            "int vibe_poll_input(vibe_input_event_t* event)",
            "VIBE_SYS_POLL_INPUT",
            "(unsigned long)sizeof(*event)",
            "int vibe_drain_input(vibe_input_event_t* events, unsigned long max_events)",
            "int vibe_input_status(vibe_input_status_t* status)",
            "VIBE_SYS_INPUT_STATUS",
            "(unsigned long)sizeof(*status)",
            "int vibe_input_device_status(unsigned long device_id, vibe_input_device_status_t* status)",
            "VIBE_SYS_INPUT_DEVICE_STATUS",
            "int vibe_fb_get_info(vibe_fb_info_t* info)",
            "VIBE_IOCTL_FBINFO",
            "int vibe_fb_can_present_indexed(",
            "int vibe_present_indexed(const vibe_present_indexed_t* present)",
            "ioctl(VIBE_DISPLAY_FD, VIBE_IOCTL_PRESENT_INDEXED",
            "int vibe_present_indexed_checked(const vibe_present_indexed_t* present)",
            "unsigned long vibe_heap_capabilities(void)",
            "unsigned long vibe_vm_capabilities(void)",
            "void* vibe_mmap_anon(unsigned long length, int prot)",
            "mmap_copy_file_private",
            "mmap_copy_file_private(fd,",
            "double sqrt(double x)",
            "double floor(double x)",
            "double ceil(double x)",
            "double fabs(double x)",
            "fsqrt",
            "frndint",
            "long strtol(const char* text, char** endptr, int base)",
            "unsigned long strtoul(const char* text, char** endptr, int base)",
            "double strtod(const char* text, char** endptr)",
            "double atof(const char* text)",
            "char* strerror(int error)",
            "scan_text_read_number",
            "scan_read_number",
            "size_t strspn(const char* text, const char* accept)",
            "size_t strcspn(const char* text, const char* reject)",
            "char* strpbrk(const char* text, const char* accept)",
            "char* strstr(const char* text, const char* needle)",
            "char* strtok(char* text, const char* delimiters)",
            "char* strtok_r(char* text, const char* delimiters, char** saveptr)",
            "void* memchr(const void* data, int ch, size_t count)",
            "size_t strnlen(const char* text, size_t max_length)",
            "char* strndup(const char* text, size_t max_length)",
            "long labs(long value)",
            "void qsort(void* base, size_t count, size_t size, int (*compar)(const void*, const void*))",
            "void* bsearch(",
            "left_align",
            "int fgetc(FILE* stream)",
            "char* fgets(char* buffer, int size, FILE* stream)",
            "int fputs(const char* text, FILE* stream)",
            "void rewind(FILE* stream)",
            "void perror(const char* text)",
            "clock_t clock(void)",
            "time_t time(time_t* out)",
            "errno = ENOSYS;",
        ):
            with self.subTest(token=token):
                self.assertIn(token, libc)

    def test_generic_runtime_contracts_have_host_proof(self):
        source = ROOT / "tests" / "host" / "libc_runtime_readiness_test.c"

        with tempfile.TemporaryDirectory() as tmp:
            binary = Path(tmp) / "libc_runtime_readiness_test"
            subprocess.run(
                [
                    os.environ.get("CLANG", "clang"),
                    "-std=gnu89",
                    "-Wall",
                    "-Wextra",
                    "-Wno-pointer-to-int-cast",
                    "-Wno-void-pointer-to-int-cast",
                    "-I",
                    str(ROOT / "doom_port" / "include"),
                    str(source),
                    "-o",
                    str(binary),
                ],
                check=True,
                cwd=ROOT,
            )
            subprocess.run([str(binary)], check=True, cwd=ROOT)


if __name__ == "__main__":
    unittest.main()

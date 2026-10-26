"""Fail the image build if its actual interpreter cannot use Linux memfd."""

import os
import pathlib
import sys


expected = os.environ["OFFLOADR_PYTHON_VERSION"]
actual = ".".join(map(str, sys.version_info[:3]))
if actual != expected:
    raise RuntimeError(f"Expected Python {expected}, got {actual}")
if not pathlib.Path(sys.base_prefix).is_relative_to("/opt/uv/python"):
    raise RuntimeError(f"Interpreter is not uv-managed: {sys.base_prefix}")

fd = os.memfd_create("offloadr-python-check", os.MFD_CLOEXEC)
try:
    payload = b"offloadr memfd round trip\n"
    if os.write(fd, payload) != len(payload):
        raise RuntimeError("Short write to memfd")
    os.lseek(fd, 0, os.SEEK_SET)
    if os.read(fd, len(payload)) != payload:
        raise RuntimeError("memfd round trip failed")
    if os.get_inheritable(fd):
        raise RuntimeError("memfd is missing close-on-exec")
finally:
    os.close(fd)

print(f"Python {actual}: memfd_create OK ({sys.executable} -> {sys.base_prefix})")

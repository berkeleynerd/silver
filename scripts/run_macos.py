#!/usr/bin/env python3
"""Set up native macOS tools, then prove, build and run a Silver application."""

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys

if __package__:
    from .platforms import native_layout
else:
    from platforms import native_layout


def main(arguments: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", nargs="?", type=Path,
                        help="Ada source (default: repository samples/hello_world.adb)")
    args = parser.parse_args(arguments)
    if sys.version_info < (3, 11):
        parser.error("Python 3.11 or newer is required")
    host = native_layout()
    if not host.key.startswith("macos-"):
        raise RuntimeError(f"run this script on macOS; detected {host.key}")

    # Resolve explicit paths before changing the subprocess working directory.
    source = (args.source if args.source is not None
              else host.root / "samples/hello_world.adb").resolve()
    if not source.is_file():
        raise RuntimeError(f"source file not found: {source}")

    scripts = host.root / "scripts"
    print(f"Setting up {host.key} tools (reusing installed packages)...", flush=True)
    subprocess.run([sys.executable, str(scripts / "bootstrap.py")],
                   cwd=host.root, check=True)
    print("Building the native Silver compiler...", flush=True)
    subprocess.run([sys.executable, str(scripts / "dev.py"), "build", "--", "-j0"],
                   cwd=host.root, check=True)
    executable = subprocess.run(
        [sys.executable, str(scripts / "dev.py"), "paths", "--field", "executable"],
        cwd=host.root, check=True, capture_output=True, text=True).stdout.strip()
    print(f"Proving, building and running {source}...", flush=True)
    # Silver owns admission, complete application/library proof checks and build.
    subprocess.run([executable, "run", str(source)], cwd=host.root, check=True)


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        print(f"macOS runner: command failed with status {error.returncode}",
              file=sys.stderr)
        raise SystemExit(error.returncode if error.returncode > 0
                         else 128 - error.returncode) from error
    except (OSError, RuntimeError) as error:
        raise SystemExit(f"macOS runner: {error}") from error
    except KeyboardInterrupt:
        raise SystemExit(130)

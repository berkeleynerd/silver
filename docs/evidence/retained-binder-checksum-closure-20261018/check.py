#!/usr/bin/env python3
"""Replay the unchanged checksum derivation in an isolated temporary directory."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
import sys
import tarfile
import tempfile

HERE = Path(__file__).resolve().parent


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def evaluate():
    pins = json.loads((HERE / "identity.json").read_bytes())
    archive = HERE / "reviewed-inputs.tar.gz"
    if identity(archive.read_bytes()) != pins["archive"]:
        raise ValueError("checksum evidence archive changed")
    with tempfile.TemporaryDirectory(prefix="silver-checksum-replay-") as directory:
        root = Path(directory)
        with tarfile.open(archive) as stream:
            seen = set()
            for member in stream:
                relative = PurePosixPath(member.name)
                if (not member.isfile() or relative.is_absolute()
                        or ".." in relative.parts or member.name in seen):
                    raise ValueError("unexpected archive member: " + member.name)
                seen.add(member.name)
                target = root.joinpath(*relative.parts)
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(stream.extractfile(member).read())
        for name, expected in pins["original_files"].items():
            if identity((root / name).read_bytes()) != expected:
                raise ValueError("original reviewed input changed: " + name)
        expected = (root / "result.json").read_bytes()
        run = subprocess.run([sys.executable, str(root / "check.py")],
                             check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if (root / "result.json").read_bytes() != expected:
            raise ValueError("reviewed checker result differs from retained result")
        result = json.loads(expected)
        if json.loads(run.stdout) != result:
            raise ValueError("checker stdout differs from retained result")
        if json.loads((HERE / "result.json").read_bytes()) != result:
            raise ValueError("published result differs from archived result")
        return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    encoded = json.dumps(evaluate(), indent=2) + "\n"
    if args.output:
        args.output.write_text(encoded)
    print(encoded, end="")


if __name__ == "__main__":
    main()

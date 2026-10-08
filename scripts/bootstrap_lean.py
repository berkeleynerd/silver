#!/usr/bin/env python3
"""Install the pinned external Lean proof tool, separately from the compiler.

Alire manages GNAT/GNATprove/GPRbuild. This script is development/CI setup only;
it is neither Silver compiler implementation code nor part of source admission.
Requires Python 3.11 or newer and uses only the Python standard library.
"""

from __future__ import annotations

import hashlib
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import subprocess
import sys
import urllib.request
import zipfile

if __package__:
    from .platforms import ROOT, HostLayout, native_layout
else:
    from platforms import ROOT, HostLayout, native_layout

LEAN_VERSION = "4.34.1"
# Published SHA256 digests from the upstream v4.34.1 GitHub release API.
ARCHIVES = {
    "linux-x86_64": (
        "linux", "3013aba02bb8bf31b1cf8c9d956d60fb95bb1c10920dfe91abcaa59cb461ddac"),
    "linux-aarch64": (
        "linux_aarch64", "b4bcf1d79f1b5859c04625058d3707701d87a65815f7f0686a1f14df821954c5"),
    "macos-x86_64": (
        "darwin", "60b45c76003a4561fb66d7ec2003569006d255d2860179445e56d3e2a029090e"),
    "macos-aarch64": (
        "darwin_aarch64", "9019fcd34e93fddf0ecf9d40d28f05a86ba563ac3b701a9c5116ce1c96379360"),
}


def lean_environment(host: HostLayout,
                     inherited: dict[str, str] | None = None) -> dict[str, str]:
    """Keep ambient toolchain/search/config settings outside this host's replay.

    Lake's Config/InstallPath and Config/Env modules honor these overrides even
    when Lake itself is called by absolute path. Its system config and caches
    also need explicit host-local paths, independent of the user's home.
    """
    original = os.environ if inherited is None else inherited
    environment = {name: value for name, value in original.items()
                   if name not in ("LEAN", "LAKE", "ELAN")
                   and not name.startswith(("LEAN_", "LAKE_", "ELAN_"))}
    environment.update({
        "LEAN": str(host.lean / "bin/lean"),
        "LEAN_SYSROOT": str(host.lean),
        "LAKE": str(host.lean / "bin/lake"),
        "LAKE_HOME": str(host.lean),
        "LAKE_OVERRIDE_LEAN": "false",
        "LAKE_CONFIG": str(host.proof / ".lake/system-config.toml"),
        "LAKE_CACHE_DIR": str(host.proof / ".lake/cache"),
        "LAKE_NO_CACHE": "true",
        "LAKE_ARTIFACT_CACHE": "false",
        "LAKE_RESTORE_ARTIFACTS": "false",
        "ELAN": "",
        "PATH": str(host.lean / "bin") + os.pathsep + original.get("PATH", ""),
    })
    return environment


def extract_archive(archive: Path, destination: Path, prefix: str) -> None:
    """Extract the authenticated distribution without accepting escaping paths."""
    with zipfile.ZipFile(archive) as bundle:
        for member in bundle.infolist():
            path = PurePosixPath(member.filename)
            if path.is_absolute() or ".." in path.parts or path.parts[0] != prefix:
                raise RuntimeError(f"unexpected archive path: {member.filename}")
            relative = Path(*path.parts[1:])
            target = destination / relative
            if member.is_dir():
                target.mkdir(parents=True, exist_ok=True)
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            mode = member.external_attr >> 16
            if stat.S_ISLNK(mode):
                link = bundle.read(member).decode("utf-8")
                resolved = (target.parent / link).resolve()
                if not resolved.is_relative_to(destination.resolve()):
                    raise RuntimeError(f"escaping archive link: {member.filename}")
                target.symlink_to(link)
            else:
                with bundle.open(member) as source, target.open("wb") as output:
                    shutil.copyfileobj(source, output)
                target.chmod(0o755 if mode & 0o111 else 0o644)


def main() -> None:
    if sys.version_info < (3, 11):
        raise RuntimeError("Lean setup requires Python 3.11 or newer")
    expected_pin = f"leanprover/lean4:v{LEAN_VERSION}"
    if (ROOT / "proof" / "lean-toolchain").read_text().strip() != expected_pin:
        raise RuntimeError("bootstrap and proof/lean-toolchain versions differ")
    host = native_layout()
    suffix, digest = ARCHIVES[host.key]
    tools = host.tools
    if tools.is_symlink() or host.lean.is_symlink():
        raise RuntimeError("host Lean installation directory must not be a symbolic link")
    tools.mkdir(parents=True, exist_ok=True)
    prefix = f"lean-{LEAN_VERSION}-{suffix}"
    archive = tools / f"{prefix}.zip"
    legacy_archive = ROOT / ".tools" / archive.name
    if not archive.exists() and legacy_archive.is_file():
        # The archive is authenticated below before extraction. Reuse it only
        # as immutable input; old installations and artifacts are untouched.
        archive = legacy_archive
    if not archive.exists():
        url = ("https://github.com/leanprover/lean4/releases/download/"
               f"v{LEAN_VERSION}/{archive.name}")
        print(f"Downloading {url}", flush=True)
        temporary = archive.with_suffix(".download")
        request = urllib.request.Request(url, headers={"User-Agent": "silver-proof-setup"})
        try:
            with urllib.request.urlopen(request, timeout=120) as source:
                with temporary.open("wb") as output:
                    shutil.copyfileobj(source, output)
            temporary.replace(archive)
        finally:
            temporary.unlink(missing_ok=True)
    with archive.open("rb") as source:
        actual = hashlib.file_digest(source, "sha256").hexdigest()
    if actual != digest:
        raise RuntimeError(f"SHA256 mismatch for {archive}; remove it and rerun setup")

    destination = host.lean
    marker = destination / ".silver-distribution-sha256"
    if not marker.exists() or marker.read_text().strip() != digest:
        staging = tools / "lean.install"
        if staging.exists():
            shutil.rmtree(staging)
        staging.mkdir()
        extract_archive(archive, staging, prefix)
        (staging / marker.name).write_text(digest + "\n")
        if destination.exists():
            shutil.rmtree(destination)
        staging.replace(destination)
    executable = destination / "bin" / "lean"
    result = subprocess.run([str(executable), "--version"], check=True,
                            text=True, capture_output=True,
                            env=lean_environment(host), cwd=host.tools)
    if not result.stdout.startswith(f"Lean (version {LEAN_VERSION},"):
        raise RuntimeError(f"unexpected Lean version: {result.stdout.strip()}")
    print(result.stdout.strip())
    print(f"Proof tool ready for {host.key}: {destination / 'bin' / 'lake'}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, zipfile.BadZipFile,
            subprocess.CalledProcessError) as error:
        raise SystemExit(f"bootstrap_lean: {error}") from error

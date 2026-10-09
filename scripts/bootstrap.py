#!/usr/bin/env python3
"""Install Alire and resolve Silver's development toolchain (Python 3.11+).

This is development setup, not any part of the Silver compiler. GNAT, GNATprove,
and GPRbuild are managed by Alire; native OS development libraries are required
separately (libc development files on Linux; Command Line Tools on macOS).
"""

from __future__ import annotations

import hashlib
import os
from pathlib import Path
import re
import shlex
import shutil
import tempfile
import subprocess
import sys
import urllib.request
import zipfile

if sys.version_info < (3, 11):
    raise SystemExit("bootstrap requires Python 3.11 or newer")

import tomllib

if __package__:
    from .platforms import (ROOT, TOOL_ENVIRONMENT_OVERRIDES, HostLayout,
                            alire_command, native_layout, require_native, tool_environment)
else:
    from platforms import (ROOT, TOOL_ENVIRONMENT_OVERRIDES, HostLayout,
                           alire_command, native_layout, require_native, tool_environment)

ALIRE_VERSION = "2.1.1"
# SHA256 digests published in the upstream v2.1.1 release API on 2026-10-08:
# https://api.github.com/repos/alire-project/alire/releases/tags/v2.1.1
ALIRE_SHA256 = {
    ("Linux", "aarch64"): "d76c93ad3dc631826144e10bdabc6b3bf98783805bebfd5e4a0e852dd524d812",
    ("Linux", "x86_64"): "09c66bcd8c35dd4b97b72c3d9b76e44caa6964a2db35aba069f396f00f1f64c7",
    ("Darwin", "aarch64"): "2c4867bfff3b95ecd9d846df460a52983d2b0072808b341f8fa5d82494fb309e",
    ("Darwin", "x86_64"): "d3e16cdfaf0cfb2da62853b79b62910189fdca9d5fddc5c3ac5974ffc7d9544b",
}
TOOL_FAMILIES = {"gnat_native": (16, 1), "gnatprove": (16, 1), "gprbuild": (26, 0)}
RUNTIME_SOURCES = {
    "IO_Specification": "silver_io.ads",
    "IO_Implementation": "silver_io.adb",
    "Imported_Interface": "silver_output_libc.ads",
    "Arguments_Specification": "silver_arguments.ads",
    "Arguments_Implementation": "silver_arguments.adb",
    "Runtime_Interface": "silver_runtime.ads",
}
MAX_RUNTIME_SOURCE_LENGTH = 16_384


def run(*args: str | Path, capture: bool = False,
        host: HostLayout | None = None) -> str:
    host = native_layout() if host is None else host
    command = [str(arg) for arg in args]
    print("+ " + " ".join(command), flush=True)
    result = subprocess.run(command, cwd=host.context,
                            env=tool_environment(host),
                            text=True, check=True,
                            stdout=subprocess.PIPE if capture else None)
    return result.stdout if capture else ""


def install_alire(host: HostLayout | None = None) -> Path:
    host = native_layout() if host is None else host
    require_native(host)
    # Even `alr --version` loads local/global settings before parsing switches.
    # Start it only after an isolated context and settings directory exist.
    prepare_context(host)
    os_name, architecture = host.key.split("-", 1)
    system = {"linux": "Linux", "macos": "Darwin"}[os_name]
    expected = ALIRE_SHA256[(system, architecture)]
    filename = f"alr-{ALIRE_VERSION}-bin-{architecture}-{os_name}.zip"
    directory = host.tools
    directory.mkdir(parents=True, exist_ok=True)
    archive = directory / filename
    if not archive.exists():
        legacy_archive = host.root / ".tools" / filename
        if legacy_archive.is_file():
            shutil.copyfile(legacy_archive, archive)
    if not archive.exists():
        url = f"https://github.com/alire-project/alire/releases/download/v{ALIRE_VERSION}/{filename}"
        print(f"Downloading {url}", flush=True)
        request = urllib.request.Request(url, headers={"User-Agent": "silver-bootstrap"})
        temporary = archive.with_suffix(".download")
        try:
            with urllib.request.urlopen(request, timeout=120) as response:
                with temporary.open("wb") as output:
                    while chunk := response.read(1024 * 1024):
                        output.write(chunk)
            temporary.replace(archive)
        finally:
            temporary.unlink(missing_ok=True)
    with archive.open("rb") as data:
        actual = hashlib.file_digest(data, "sha256").hexdigest()
    if actual != expected:
        raise RuntimeError(f"SHA256 mismatch for {archive}; remove it and rerun setup")
    # Extract only the two known members; never trust ZIP paths or permissions.
    target = directory / "alr"
    executable = target / "bin" / "alr"
    executable.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive) as bundle:
        for member in ("bin/alr", "LICENSE.txt"):
            destination = target / member
            temporary = destination.with_name(destination.name + ".new")
            temporary.write_bytes(bundle.read(member))
            if member == "bin/alr":
                temporary.chmod(0o755)
            temporary.replace(destination)
    version = run(executable, "--version", capture=True, host=host).strip()
    if version != f"alr {ALIRE_VERSION}":
        raise RuntimeError(f"unexpected Alire version: {version}")
    print(version)
    return executable


def verify_resolved_versions(host: HostLayout | None = None) -> dict[str, str]:
    host = native_layout() if host is None else host
    with (host.context / "alire" / "alire.lock").open("rb") as source:
        solution = tomllib.load(source)["solution"]
    if solution["context"].get("solved") is not True:
        raise RuntimeError("Alire did not resolve the toolchain")
    releases = {state["crate"]: state["release"] for state in solution["state"]}
    versions = {}
    for crate, family in TOOL_FAMILIES.items():
        release = releases[crate]
        version = release["version"]
        if tuple(map(int, version.split(".")[:2])) != family:
            raise RuntimeError(f"{crate} {version} is outside the supported version family")
        if not any(re.fullmatch(r"sha256:[0-9a-f]{64}", value)
                   for value in release["origin"].get("hashes", [])):
            raise RuntimeError(f"{crate} has no SHA256-verified Alire origin")
        versions[crate] = version
    return versions


def write_if_changed(destination: Path, contents: str) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.is_file() and destination.read_text() == contents:
        return
    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8",
                                     dir=destination.parent, delete=False) as output:
        temporary = Path(output.name)
        output.write(contents)
    try:
        temporary.replace(destination)
    finally:
        temporary.unlink(missing_ok=True)


def build_configuration(host: HostLayout) -> dict[str, str]:
    """Anchor runtime paths to this installation, with shell quoting at setup."""
    # Alire loads/migrates settings before -s/-C are parsed. Establish its
    # environment and working directory in the shell before starting it.
    prefix = (f"cd {shlex.quote(str(host.context))} && "
              f"unset {' '.join(TOOL_ENVIRONMENT_OVERRIDES)} && "
              f"ALIRE_SETTINGS_DIR={shlex.quote(str(host.alire_settings))} "
              f"{shlex.quote(str(host.alr))} -n exec -- ")
    fields = {"Host": host.key,
              "Artifacts_Directory": str(host.root / ".silver"),
              "Root_Directory": str(host.artifacts),
              "Source_Directory": str(host.root / "src"),
              "Quoted_Root_Directory": shlex.quote(str(host.artifacts)),
              "Alire_Exec": prefix}
    if any(b"\0" in os.fsencode(value) for value in fields.values()):
        raise RuntimeError("installation paths must not contain NUL bytes")
    # Match the SPARK path/command bounds before generating compiler constants.
    # Reserve the longest filesystem suffix and ample fixed driver command text;
    # shell quoting can make the command longer than the raw installation path.
    # Create_Workspace appends /program-XXXXXX (15 bytes), and the library
    # proof-evidence operation requires that directory to leave 45 bytes free.
    if len(os.fsencode(fields["Root_Directory"])) + 15 > 4096 - 45:
        raise RuntimeError("installation path exceeds the compiler's 4096-byte path bound")
    if len(os.fsencode(prefix + fields["Quoted_Root_Directory"])) + 512 > 16384:
        raise RuntimeError("quoted installation paths exceed the compiler's command bound")
    return fields


def ada_string(value: str) -> str:
    """Encode filesystem bytes exactly, without relying on Ada source encoding."""
    return ada_bytes(os.fsencode(value))


def ada_bytes(value: bytes) -> str:
    """Encode exact bytes using ASCII Ada literals and explicit control bytes."""
    pieces: list[str] = []
    literal = ""
    for byte in value:
        if 32 <= byte <= 126:
            literal += chr(byte).replace('"', '""')
        else:
            pieces.append(f'"{literal}"')
            pieces.append(f"Character'Val ({byte})")
            literal = ""
    pieces.append(f'"{literal}"')
    return " & ".join(pieces)


def runtime_source_configuration(source_dir: Path) -> bytes:
    """Embed precisely the reviewed runtime source bytes in the SPARK compiler.

    The auditor independently renders this definition from current source and
    compares the entire generated file. It does not trust a bootstrap timestamp.
    """
    declarations = []
    for name, filename in RUNTIME_SOURCES.items():
        data = (source_dir / filename).read_bytes()
        if not 1 <= len(data) <= MAX_RUNTIME_SOURCE_LENGTH:
            raise RuntimeError(f"{filename}: runtime source length is outside 1..{MAX_RUNTIME_SOURCE_LENGTH}")
        if not all(byte in (9, 10, 13) or 32 <= byte <= 126 for byte in data):
            raise RuntimeError(f"{filename}: unsupported runtime source byte")
        # Separate short concatenation operands also keep physical generated
        # source lines bounded, without transforming any original source byte.
        pieces = [ada_bytes(data[start:start + 64]) for start in range(0, len(data), 64)]
        declarations.append(f"   {name} : constant String :=\n      "
                            + "\n      & ".join(pieces) + ";\n")
    return ("-- Generated exact runtime source binding; bootstrap and rebuild after source changes.\n"
            "package Silver_Library_Sources with SPARK_Mode => On is\n"
            + "".join(declarations) + "end Silver_Library_Sources;\n").encode("ascii")


def prepare_context(host: HostLayout) -> Path:
    """Generate only this host's manifest and verified-SPARK constants."""
    fields = build_configuration(host)
    library_sources = runtime_source_configuration(host.root / "src")
    write_if_changed(host.context / "alire.toml",
                     (host.root / "alire.toml").read_text())
    host.alire_settings.mkdir(parents=True, exist_ok=True)
    host.alire_cache.mkdir(parents=True, exist_ok=True)
    host.alire_toolchains.mkdir(parents=True, exist_ok=True)
    declarations = "".join(
        f"   {name} : constant String := {ada_string(value)};\n"
        for name, value in fields.items())
    generated = host.generated / "silver_build.ads"
    write_if_changed(generated,
                     "-- Generated by scripts/bootstrap.py for this host only.\n"
                     "package Silver_Build with SPARK_Mode => On is\n"
                     + declarations + "end Silver_Build;\n")
    write_if_changed(host.generated / "silver_library_sources.ads", library_sources.decode("ascii"))
    return generated


def configure_alire(host: HostLayout) -> None:
    require_native(host)
    for setting, destination in (("cache.dir", host.alire_cache),
                                 ("toolchain.dir", host.alire_toolchains)):
        run(*alire_command(host, "settings", "--global", "--set", setting,
                           destination), host=host)


def main(host: HostLayout | None = None) -> None:
    host = native_layout() if host is None else host
    require_native(host)
    install_alire(host)
    prepare_context(host)
    configure_alire(host)
    run(*alire_command(host, "toolchain", "--select", "--local",
                       "gnat_native~16.1.0", "gprbuild~26.0.1"), host=host)
    # Executing in the isolated context also deploys GNATprove there.
    for executable, family in (("gnatls", (16, 1)), ("gnatprove", (16, 1)),
                               ("gprbuild", (26, 0))):
        output = run(*alire_command(host, "exec", "--", executable, "--version"),
                     capture=True, host=host)
        first_line = output.splitlines()[0]
        match = re.search(r"\b(\d+)\.(\d+)\.\d+\b", first_line)
        if match is None or tuple(map(int, match.groups())) != family:
            raise RuntimeError(f"unexpected {executable} version: {first_line}")
        print(first_line)
    versions = verify_resolved_versions(host)
    print("Alire packages: " + ", ".join(f"{name} {version}" for name, version in versions.items()))
    print(f"Native host: {host.key}")
    print(f"Toolchain ready: {host.alr}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, RuntimeError, subprocess.CalledProcessError,
            zipfile.BadZipFile) as error:
        raise SystemExit(f"bootstrap: {error}") from error

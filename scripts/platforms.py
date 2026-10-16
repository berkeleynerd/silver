"""Native host identities and disjoint development-tool/build paths.

This module is development setup only. It does not implement Silver admission,
source compilation, or any part of the executable SPARK compiler.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import os
import platform

ROOT = Path(__file__).resolve().parents[1]
HOST_KEYS = ("linux-aarch64", "linux-x86_64", "macos-aarch64", "macos-x86_64")
# These inherited settings can select another GPR configuration or project
# tree before the explicitly selected native project/toolchain is loaded.
TOOL_ENVIRONMENT_OVERRIDES = (
    "ALR_CONFIG", "GPR_CONFIG", "GPR_PROJECT_PATH", "GPR_PROJECT_PATH_FILE",
    "ADA_PROJECT_PATH",
)


def host_key(system: str | None = None, machine: str | None = None) -> str:
    system = platform.system() if system is None else system
    machine = platform.machine() if machine is None else machine
    os_name = {"Linux": "linux", "Darwin": "macos"}.get(system)
    architecture = {"arm64": "aarch64", "amd64": "x86_64"}.get(
        machine.lower(), machine.lower())
    result = f"{os_name}-{architecture}"
    if result not in HOST_KEYS:
        raise RuntimeError(f"unsupported platform: {system} {machine}")
    return result


@dataclass(frozen=True)
class HostLayout:
    root: Path
    key: str

    def __post_init__(self) -> None:
        if self.key not in HOST_KEYS:
            raise ValueError(f"unsupported host key: {self.key}")
        object.__setattr__(self, "root", Path(self.root).resolve())

    @property
    def tools(self) -> Path:
        return self.root / ".tools" / self.key

    @property
    def alr(self) -> Path:
        return self.tools / "alr/bin/alr"

    @property
    def lean(self) -> Path:
        return self.tools / "lean"

    @property
    def alire_settings(self) -> Path:
        return self.tools / "alire/settings"

    @property
    def alire_cache(self) -> Path:
        return self.tools / "alire/cache"

    @property
    def alire_toolchains(self) -> Path:
        return self.tools / "alire/toolchains"

    @property
    def artifacts(self) -> Path:
        return self.root / ".silver" / self.key

    @property
    def context(self) -> Path:
        return self.artifacts / "toolchain"

    @property
    def generated(self) -> Path:
        return self.artifacts / "generated"

    @property
    def compiler(self) -> Path:
        return self.artifacts / "compiler"

    @property
    def image_tools(self) -> Path:
        return self.artifacts / "image-tools"

    @property
    def image_adapter(self) -> Path:
        return self.compiler / "bin/silver_image_adapter"

    @property
    def proof(self) -> Path:
        return self.artifacts / "proof"


def layout(root: Path = ROOT, key: str | None = None) -> HostLayout:
    return HostLayout(root, host_key() if key is None else key)


def native_layout(root: Path = ROOT) -> HostLayout:
    return layout(root)


def require_native(host: HostLayout) -> None:
    native = host_key()
    if host.key != native:
        raise RuntimeError(f"refusing to execute {host.key} tools on {native}")


def alire_command(host: HostLayout, *arguments: str | Path) -> list[str]:
    # Alire 2.1.1 requires an absolute -s path when combined with -C: a
    # relative path causes its early and late configuration paths to differ.
    return [str(host.alr), "-s", str(host.alire_settings),
            "-C", str(host.context), "-n", "--no-tty",
            *(str(argument) for argument in arguments)]


def tool_environment(host: HostLayout) -> dict[str, str]:
    # Alire loads/migrates settings during elaboration, before processing -s.
    # Set this even for --version, and discard its deprecated alternative.
    environment = dict(os.environ)
    environment["ALIRE_SETTINGS_DIR"] = str(host.alire_settings)
    for variable in TOOL_ENVIRONMENT_OVERRIDES:
        environment.pop(variable, None)
    return environment

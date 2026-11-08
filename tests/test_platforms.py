"""Shared-checkout isolation, with foreign tools and downloads mocked.

These tests exercise setup and proof-workspace routing, not native macOS
execution or Lean proof validity. Concurrent workers use separate Python
processes so simulated host identities cannot race through global mocks.
"""
from __future__ import annotations

from contextlib import ExitStack
import hashlib
import io
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock
import zipfile

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts import bootstrap, bootstrap_lean, check_lean, dev, platforms, run_history

# Each worker prepares all project modules and generates every source certificate.
PLATFORM_SETUP_TIMEOUT_SECONDS = 180


def archive_bytes(members: dict[str, bytes]) -> bytes:
    output = io.BytesIO()
    with zipfile.ZipFile(output, "w") as archive:
        for name, contents in members.items():
            entry = zipfile.ZipInfo(name)
            entry.external_attr = 0o100755 << 16
            archive.writestr(entry, contents)
    return output.getvalue()


def mock_lockfile(host: platforms.HostLayout) -> None:
    text = "[solution.context]\nsolved = true\n"
    # Different patches are permitted; major/minor must remain the same.
    patch = platforms.HOST_KEYS.index(host.key)
    for crate, version in (("gnat_native", f"16.1.{patch}"),
                           ("gnatprove", f"16.1.{patch}"),
                           ("gprbuild", f"26.0.{patch}")):
        text += (f'[[solution.state]]\ncrate = "{crate}"\n'
                 f'[solution.state.release]\nversion = "{version}"\n'
                 '[solution.state.release.origin]\n'
                 f'hashes = ["sha256:{"a" * 64}"]\n')
    destination = host.context / "alire/alire.lock"
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(text)


def setup_worker(root: Path, key: str, concurrent: bool = False,
                 fail_proof: bool = False, lean_mode: str = "incremental",
                 omit_fresh_audit: bool = False, lean_workers: int | None = None,
                 lean_threads: int | None = None) -> None:
    """Run real setup code while replacing only network/external tool effects."""
    host = platforms.HostLayout(root, key)
    root = host.root
    os_name, architecture = key.split("-", 1)
    system = "Linux" if os_name == "linux" else "Darwin"
    alire_name = f"alr-{bootstrap.ALIRE_VERSION}-bin-{architecture}-{os_name}.zip"
    alire_data = archive_bytes({"bin/alr": f"mock Alire for {key}".encode(),
                               "LICENSE.txt": b"test fixture"})
    suffix = bootstrap_lean.ARCHIVES[key][0]
    lean_prefix = f"lean-{bootstrap_lean.LEAN_VERSION}-{suffix}"
    lean_data = archive_bytes({f"{lean_prefix}/bin/{tool}":
                               f"mock {tool} for {key}".encode()
                               for tool in ("lean", "lake", "leanchecker")})
    downloads = {alire_name: alire_data, f"{lean_prefix}.zip": lean_data}
    fetched: list[str] = []
    commands: list[list[str]] = []
    available_cpus = 3
    resolved_workers = lean_workers or available_cpus
    resolved_threads = lean_threads or available_cpus
    settings: dict[str, str] = {}
    real_run = subprocess.run
    foreign = root / "foreign-proof-toolchain"
    poisoned_lean = {
        "LEAN": str(foreign / "bin/lean"),
        "LEAN_SYSROOT": str(foreign),
        "LEAN_PATH": str(foreign / "objects"),
        "LEAN_SRC_PATH": str(foreign / "sources"),
        "LEAN_CC": str(foreign / "bin/compiler"),
        "LEAN_NUM_THREADS": "98",
        "LEAN_MAX_THREADS": "99",
        "LAKE": str(foreign / "bin/lake"),
        "LAKE_HOME": str(foreign),
        "LAKE_CONFIG": str(foreign / "system-config.toml"),
        "LAKE_CACHE_DIR": str(foreign / "cache"),
        "LAKE_OVERRIDE_LEAN": "true",
        "LAKE_NO_CACHE": "false",
        "LAKE_ARTIFACT_CACHE": "true",
        "LAKE_RESTORE_ARTIFACTS": "true",
        "ELAN": str(foreign / "bin/elan"),
        "ELAN_HOME": str(foreign / "elan"),
        "ELAN_TOOLCHAIN": "foreign/toolchain:old",
        "PATH": str(foreign / "bin") + os.pathsep + os.environ.get("PATH", ""),
    }

    def check_lean_environment(kwargs: dict[str, object], *, workers: bool = False) -> dict[str, str]:
        environment = kwargs.get("env")
        assert isinstance(environment, dict), "Lean/Lake must receive an isolated environment"
        expected = {
            "LEAN": str(host.lean / "bin/lean"), "LEAN_SYSROOT": str(host.lean),
            "LAKE": str(host.lean / "bin/lake"), "LAKE_HOME": str(host.lean),
            "LAKE_OVERRIDE_LEAN": "false",
            "LAKE_CONFIG": str(host.proof / ".lake/system-config.toml"),
            "LAKE_CACHE_DIR": str(host.proof / ".lake/cache"),
            "LAKE_NO_CACHE": "true", "LAKE_ARTIFACT_CACHE": "false",
            "LAKE_RESTORE_ARTIFACTS": "false", "ELAN": "",
        }
        if workers:
            expected["LEAN_NUM_THREADS"] = str(resolved_workers)
        actual = {name: value for name, value in environment.items()
                  if name in ("LEAN", "LAKE", "ELAN")
                  or name.startswith(("LEAN_", "LAKE_", "ELAN_"))}
        assert actual == expected, f"foreign Lean/Lake/Elan settings survived: {actual}"
        # Empty LEAN_PATH would add an empty search entry: both variables must
        # be absent so Lake constructs the native paths itself.
        assert "LEAN_PATH" not in environment and "LEAN_SRC_PATH" not in environment
        assert environment["PATH"] == str(host.lean / "bin") + os.pathsep + poisoned_lean["PATH"]
        assert environment["SILVER_PLATFORM_TEST_UNRELATED"] == "preserve"
        return environment

    def download(request: object, **_kwargs: object) -> io.BytesIO:
        name = str(getattr(request, "full_url", request)).rsplit("/", 1)[-1]
        if name not in downloads:
            raise AssertionError(f"unexpected network request: {name}")
        fetched.append(name)
        return io.BytesIO(downloads[name])

    def run(arguments: list[str], **kwargs: object) -> subprocess.CompletedProcess[str]:
        args = [str(arg) for arg in arguments]
        commands.append(args)
        executable = Path(args[0])
        output = ""
        if executable == host.alr:
            environment = kwargs.get("env")
            assert isinstance(environment, dict), "Alire must receive an isolated environment"
            assert environment.get("ALIRE_SETTINGS_DIR") == str(host.alire_settings)
            assert not any(name in environment for name in platforms.TOOL_ENVIRONMENT_OVERRIDES)
            assert environment.get("SILVER_PLATFORM_TEST_UNRELATED") == "preserve"
            assert Path(str(kwargs["cwd"])) == host.context
            assert host.alire_settings.is_dir(), "settings must exist before the initial version check"
            assert (host.context / "alire.toml").is_file()
            # Alire's Early_Load can migrate these locations before processing
            # -s/-C, even for --version. Model those writes before flags.
            (Path(environment["ALIRE_SETTINGS_DIR"]) / "early-load.json").write_text(key)
            early_context = Path(str(kwargs["cwd"])) / "alire/config.toml"
            early_context.parent.mkdir(parents=True, exist_ok=True)
            early_context.write_text(f'early_load_host = "{key}"\n')
            if args[1:] == ["--version"]:
                output = f"alr {bootstrap.ALIRE_VERSION}\n"
            else:
                assert Path(args[args.index("-s") + 1]) == host.alire_settings
                assert Path(args[args.index("-s") + 1]).is_absolute()
                assert Path(args[args.index("-C") + 1]) == host.context
                if "settings" in args:
                    setting, destination = args[args.index("--set") + 1:][:2]
                    expected = {"cache.dir": host.alire_cache,
                                "toolchain.dir": host.alire_toolchains}[setting]
                    assert Path(destination) == expected
                    settings[setting] = destination
                    (host.alire_settings / "settings.json").write_text(json.dumps(settings))
                elif "toolchain" in args:
                    assert "--local" in args
                    mock_lockfile(host)
                    (host.context / "alire/config.toml").write_text(f'host = "{key}"\n')
                elif "exec" in args:
                    tool = args[args.index("--") + 1]
                    patch = platforms.HOST_KEYS.index(key)
                    version = f"26.0.{patch}" if tool == "gprbuild" else f"16.1.{patch}"
                    if tool == sys.executable and "SILVER_GNATPROVE=" in args[-1]:
                        vendor = host.tools / "vendor-gnatprove"
                        for relative in ("bin/gnatprove", "libexec/spark/bin/gnatwhy3"):
                            path = vendor / relative
                            path.parent.mkdir(parents=True, exist_ok=True)
                            path.write_bytes((key + relative).encode())
                            path.chmod(0o755)
                        output = "SILVER_GNATPROVE=" + json.dumps(str(vendor / "bin/gnatprove")) + "\n"
                    else:
                        output = f"{tool} {version}\n"
                else:
                    raise AssertionError(f"unexpected Alire command: {args}")
        elif executable == host.lean / "bin/lean":
            check_lean_environment(kwargs)
            assert args[1:] in (["--version"], ["--short-version"])
            output = (f"{bootstrap_lean.LEAN_VERSION}\n" if "--short-version" in args
                      else f"Lean (version {bootstrap_lean.LEAN_VERSION}, test fixture)\n")
        elif executable == host.lean / "bin/lake":
            environment = check_lean_environment(kwargs, workers=True)
            assert Path(str(kwargs["cwd"])) == host.proof
            options = args[1:]
            if options and options[0] == "--rehash":
                assert options[:2] == ["--rehash", "--reconfigure"]
                options = options[2:]
            assert options[:2] == ["-K", f"silverThreads={resolved_threads}"]
            options = options[2:]
            if options == ["build", "Silver.Audit"]:
                if fail_proof:
                    return subprocess.CompletedProcess(args, 1, "simulated Lean failure\n")
                (host.proof / ".lake/build").mkdir(parents=True, exist_ok=True)
                (host.proof / ".lake/build/routing.olean").write_text(key)
                cache = Path(environment["LAKE_CACHE_DIR"])
                cache.mkdir(parents=True, exist_ok=True)
                (cache / "routing.json").write_text(json.dumps({"host": key}))
                Path(environment["LAKE_CONFIG"]).write_text(f'host = "{key}"\n')
                (host.proof / "lake-manifest.json").write_text(json.dumps({"test_host": key}))
                # Cached build messages must never substitute for fresh audit
                # execution, even if they claim all modules were checked.
                output = "Silver axiom audit passed: CACHED routing message only\n"
                output += "".join(f"SILVER_MODULE {module}\n"
                                  for module in sorted(check_lean.project_sources(host.proof)))
            elif options == ["env", str(host.lean / "bin/lean"), "-DwarningAsError=true",
                             f"-j{resolved_threads}", "Silver/Audit.lean"]:
                if not omit_fresh_audit:
                    output = "Silver axiom audit passed: FRESH MOCKED routing test only\n"
                    output += "".join(f"SILVER_MODULE {module}\n"
                                      for module in sorted(check_lean.project_sources(host.proof)))
            elif options == ["env", str(host.lean / "bin/leanchecker"),
                             "--fresh", "Silver.Audit"]:
                output = "Mocked kernel recheck: routing test only\n"
            else:
                raise AssertionError(f"unexpected Lake command: {args}")
        elif executable == Path(sys.executable):
            # The real native Python generator must write the isolated output.
            assert Path(args[1]) == root / "proof/generate_source_certificate.py"
            source = args[args.index("--source") + 1]
            candidates = {name: path for path, name in check_lean.CERTIFICATE_ROOTS.items()}
            assert source in candidates
            assert args[2:] == ["--source", source, "--output",
                               str((host.proof / candidates[source]).with_suffix(".lean.pending"))]
            return real_run(args, **kwargs)
        else:
            raise AssertionError(f"unexpected external executable: {args}")
        return subprocess.CompletedProcess(args, 0, output)

    def run_logged(arguments: list[str], *, cwd: Path, env: dict[str, str],
                   destination: io.TextIOBase, pass_fds: tuple[int, ...] = ()) -> subprocess.CompletedProcess[str]:
        assert pass_fds, "Lean/Lake must inherit the managed workspace lease"
        for descriptor in pass_fds:
            os.fstat(descriptor)
        result = run(arguments, cwd=cwd, env=env, pass_fds=pass_fds)
        destination.write(result.stdout)
        destination.flush()
        print(result.stdout, end="", flush=True)
        return result

    with ExitStack() as stack:
        inherited_settings = str(root / ".user-alire-settings")
        inherited_legacy = str(root / ".old-alire-settings")
        stack.enter_context(mock.patch.dict(os.environ, {
            **poisoned_lean,
            **{name: str(root / "foreign-project-configuration")
               for name in platforms.TOOL_ENVIRONMENT_OVERRIDES},
            "ALIRE_SETTINGS_DIR": inherited_settings,
            "ALR_CONFIG": inherited_legacy,
            "SILVER_PLATFORM_TEST_UNRELATED": "preserve",
        }))
        stack.enter_context(mock.patch.object(platforms.platform, "system", return_value=system))
        stack.enter_context(mock.patch.object(platforms.platform, "machine", return_value=architecture))
        stack.enter_context(mock.patch.dict(bootstrap.ALIRE_SHA256,
                            {(system, architecture): hashlib.sha256(alire_data).hexdigest()}))
        stack.enter_context(mock.patch.dict(bootstrap_lean.ARCHIVES,
                            {key: (suffix, hashlib.sha256(lean_data).hexdigest())}))
        for module in (bootstrap, bootstrap_lean, check_lean):
            stack.enter_context(mock.patch.object(module, "ROOT", root))
            stack.enter_context(mock.patch.object(module, "native_layout",
                                                   side_effect=lambda: platforms.native_layout(root)))
        stack.enter_context(mock.patch.object(check_lean, "PROOF", root / "proof"))
        stack.enter_context(mock.patch.object(check_lean, "available_cpus", return_value=available_cpus))
        stack.enter_context(mock.patch.object(run_history, "available_cpus", return_value=available_cpus))
        stack.enter_context(mock.patch.object(run_history, "registry", return_value=host.artifacts / "run-history"))
        stack.enter_context(mock.patch.object(bootstrap.urllib.request, "urlopen", side_effect=download))
        stack.enter_context(mock.patch.object(subprocess, "run", side_effect=run))
        stack.enter_context(mock.patch.object(check_lean, "run_logged", side_effect=run_logged))
        if concurrent:
            host.artifacts.mkdir(parents=True, exist_ok=True)
            (host.artifacts / "worker-ready").touch()
            deadline = time.monotonic() + 15
            while not all((platforms.HostLayout(root, other).artifacts / "worker-ready").exists()
                          for other in platforms.HOST_KEYS):
                if time.monotonic() >= deadline:
                    raise RuntimeError("concurrent setup workers did not reach barrier")
                time.sleep(0.01)
        bootstrap.main()
        bootstrap_lean.main()
        try:
            lean_arguments = [] if lean_mode == "incremental" else ["--" + lean_mode]
            if lean_workers is not None:
                lean_arguments.extend(["--workers", str(lean_workers)])
            if lean_threads is not None:
                lean_arguments.extend(["--threads", str(lean_threads)])
            check_lean.main(lean_arguments)
        except RuntimeError as error:
            expected = "freshly executed axiom audit" if omit_fresh_audit else "Lean check failed"
            if not (fail_proof or omit_fresh_audit) or expected not in str(error):
                raise
        else:
            if fail_proof or omit_fresh_audit:
                raise AssertionError("simulated proof failure was accepted")
        assert settings == {"cache.dir": str(host.alire_cache),
                            "toolchain.dir": str(host.alire_toolchains)}
        assert os.environ["ALIRE_SETTINGS_DIR"] == inherited_settings
        assert os.environ["ALR_CONFIG"] == inherited_legacy
        assert all(os.environ[name] == value for name, value in poisoned_lean.items())
        assert host.alr.read_bytes() == f"mock Alire for {key}".encode()
        assert (host.lean / "bin/lean").read_bytes() == f"mock lean for {key}".encode()
        assert (host.artifacts / "src").resolve() == (root / "src").resolve()
        assert (host.context / "alire.toml").read_bytes() == (root / "alire.toml").read_bytes()
        evidence = host.artifacts / "lean-evidence.json"
        assert evidence.exists() != (fail_proof or omit_fresh_audit)
        if evidence.exists():
            data = json.loads(evidence.read_text())
            assert data["host"] == key
            assert data["workspace"] == str(host.proof.relative_to(root))
            assert data["scope"] == "complete"
            assert data["mode"] == ("replay" if lean_mode == "full" else lean_mode)
            assert data["available_cpus"] == available_cpus
            assert data["lake_workers"] == resolved_workers
            assert data["threads_per_process"] == resolved_threads
            assert bool(data["kernel_recheck"]) == (lean_mode == "full")
            assert any(command[-1] == "Silver/Audit.lean" for command in commands)
            assert any("--fresh" in command for command in commands) == (lean_mode == "full")
        (host.artifacts / "setup-routing-test.json").write_text(
            json.dumps({"host": key, "downloads": fetched, "commands": commands,
                        "mocked_tools": True, "failed_proof": fail_proof}, indent=2))


class PlatformIsolationTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix="silver platform tests-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        for relative in ("alire.toml", "silver.gpr", "proof/silver_proof_containers.gpr",
                         "proof/lean-toolchain",
                         "proof/lakefile.lean", "proof/generate_source_certificate.py",
                         *("src/" + source for source in check_lean.CANDIDATES.values())):
            destination = self.root / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / relative, destination)
        for source in (ROOT / "proof").rglob("*.lean"):
            if ".lake" not in source.parts:
                destination = self.root / source.relative_to(ROOT)
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, destination)
        legacy = [".tools/alr/bin/alr", ".tools/lean/bin/lean", ".tools/lean.install/pending",
                  "alire/alire.lock", "alire/config.toml", "config/silver_config.ads",
                  "proof/.lake/build/shared.olean", "proof/lake-manifest.json",
                  ".silver/compiler/bin/silver", ".silver/program-legacy/main.adb",
                  ".silver/lean-evidence.json", ".silver/lean-proof.log",
                  ".user-alire-settings/config.toml", ".old-alire-settings/config.toml",
                  "foreign-proof-toolchain/bin/lean", "foreign-proof-toolchain/bin/lake",
                  "foreign-proof-toolchain/bin/elan", "foreign-proof-toolchain/bin/compiler",
                  "foreign-proof-toolchain/objects/foreign.olean",
                  "foreign-proof-toolchain/sources/foreign.lean",
                  "foreign-proof-toolchain/system-config.toml",
                  "foreign-proof-toolchain/cache/foreign-artifact",
                  "foreign-proof-toolchain/elan/settings.toml"]
        for key in platforms.HOST_KEYS:
            legacy.extend([f".tools/{key}/alr/bin/alr", f".tools/{key}/lean/bin/lean",
                           f".tools/{key}/alire/settings/prior.toml",
                           f".tools/{key}/alire/cache/prior", f".tools/{key}/alire/toolchains/prior",
                           f".silver/{key}/toolchain/alire/alire.lock",
                           f".silver/{key}/toolchain/alire/config.toml",
                           f".silver/{key}/generated/silver_build.ads",
                           f".silver/{key}/compiler/bin/silver",
                           f".silver/{key}/proof/.lake/build/prior.olean",
                           f".silver/{key}/program-prior/main.adb",
                           f".silver/{key}/lean-evidence.json"])
        for relative in legacy:
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(f"untouched sentinel: {relative}".encode())

    def snapshot(self, active: tuple[str, ...] = ()) -> dict[str, object]:
        result: dict[str, object] = {}
        for path in sorted(self.root.rglob("*")):
            relative = path.relative_to(self.root)
            if len(relative.parts) >= 2 and relative.parts[0] in (".tools", ".silver"):
                if relative.parts[1] in active:
                    continue
            if path.is_symlink():
                result[str(relative)] = ("link", path.readlink())
            elif path.is_file():
                stat = path.stat()
                result[str(relative)] = (path.read_bytes(), stat.st_mtime_ns, stat.st_mode, stat.st_ino)
            else:
                result[str(relative)] = "directory"
        return result

    def worker_command(self, key: str, *options: str) -> list[str]:
        return [sys.executable, str(Path(__file__).resolve()), "--setup-worker",
                str(self.root), key, *options]

    def run_worker(self, key: str, *options: str) -> None:
        result = subprocess.run(self.worker_command(key, *options), cwd=ROOT,
                                text=True, capture_output=True,
                                timeout=PLATFORM_SETUP_TIMEOUT_SECONDS)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_platform_aliases_and_disjoint_paths(self) -> None:
        cases = (("Linux", "aarch64", "linux-aarch64"),
                 ("Linux", "AMD64", "linux-x86_64"),
                 ("Darwin", "arm64", "macos-aarch64"),
                 ("Darwin", "x86_64", "macos-x86_64"))
        outputs: set[Path] = set()
        for system, machine, expected in cases:
            with self.subTest(system=system, machine=machine):
                self.assertEqual(platforms.host_key(system, machine), expected)
                host = platforms.HostLayout(self.root, expected)
                self.assertNotIn(host.tools, outputs)
                self.assertNotIn(host.artifacts, outputs)
                outputs.update((host.tools, host.artifacts))
                command = platforms.alire_command(host, "exec", "--", "gnatls", "--version")
                self.assertEqual(Path(command[0]), host.alr)
                self.assertEqual(Path(command[command.index("-s") + 1]), host.alire_settings)
                self.assertTrue(Path(command[command.index("-s") + 1]).is_absolute())
                self.assertEqual(Path(command[command.index("-C") + 1]), host.context)
        for system, architecture in (("Windows", "AMD64"), ("Linux", "riscv64")):
            with self.assertRaises(RuntimeError):
                platforms.host_key(system, architecture)
        with self.assertRaises(ValueError):
            platforms.HostLayout(self.root, "../../escape")

    def test_foreign_execution_is_rejected_before_side_effects(self) -> None:
        key = next(key for key in platforms.HOST_KEYS if key != platforms.host_key())
        host = platforms.HostLayout(self.root, key)
        before = self.snapshot()
        with mock.patch.object(subprocess, "run") as run, mock.patch.object(
                bootstrap.urllib.request, "urlopen",
                side_effect=AssertionError("foreign setup attempted a download")) as download:
            with self.assertRaisesRegex(RuntimeError, "refusing to execute"):
                bootstrap.main(host)
            with self.assertRaisesRegex(RuntimeError, "refusing to execute"):
                dev.invoke(host, [str(host.alr), "--version"])
            run.assert_not_called()
            download.assert_not_called()
        self.assertEqual(self.snapshot(), before)

    def test_each_host_setup_preserves_other_hosts_and_shared_inputs(self) -> None:
        for key in platforms.HOST_KEYS:
            with self.subTest(host=key):
                before = self.snapshot((key,))
                self.run_worker(key)
                self.assertEqual(self.snapshot((key,)), before,
                                 "setup changed another host, legacy path, or shared input")
                host = platforms.HostLayout(self.root, key)
                routing = json.loads((host.artifacts / "setup-routing-test.json").read_text())
                self.assertEqual(len(routing["downloads"]), 2)
                generation = [command for command in routing["commands"]
                              if Path(command[0]) == Path(sys.executable)]
                self.assertEqual(len(generation), len(check_lean.CERTIFICATE_ROOTS))
                self.assertEqual({command[command.index("--source") + 1] for command in generation},
                                 set(check_lean.CANDIDATES.values()))
                self.assertIn(key, (host.generated / "silver_build.ads").read_text())
                self.assertEqual((host.proof / ".lake/build/routing.olean").read_text(), key)

    def test_concurrent_different_host_setups_do_not_collide(self) -> None:
        before = self.snapshot(platforms.HOST_KEYS)
        workers = [subprocess.Popen(self.worker_command(key, "--concurrent"), cwd=ROOT,
                                    text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                   for key in platforms.HOST_KEYS]
        try:
            for key, process in zip(platforms.HOST_KEYS, workers):
                output, error = process.communicate(timeout=PLATFORM_SETUP_TIMEOUT_SECONDS)
                self.assertEqual(process.returncode, 0, f"{key}: {output}{error}")
        finally:
            for process in workers:
                if process.poll() is None:
                    process.kill()
                process.communicate()
        self.assertEqual(self.snapshot(platforms.HOST_KEYS), before)
        for key in platforms.HOST_KEYS:
            host = platforms.HostLayout(self.root, key)
            self.assertEqual(host.alr.read_bytes(), f"mock Alire for {key}".encode())
            self.assertEqual((host.proof / ".lake/build/routing.olean").read_text(), key)
            self.assertEqual(json.loads((host.artifacts / "lean-evidence.json").read_text())["host"], key)

    def test_failed_proof_invalidates_only_its_host_evidence(self) -> None:
        key = "linux-aarch64"
        before = self.snapshot((key,))
        self.run_worker(key, "--fail-proof")
        self.assertFalse((platforms.HostLayout(self.root, key).artifacts / "lean-evidence.json").exists())
        self.assertEqual(self.snapshot((key,)), before)

    def test_lean_full_and_clean_modes_record_their_actual_checks(self) -> None:
        key = platforms.host_key()
        for mode in ("full", "clean"):
            with self.subTest(mode=mode):
                before = self.snapshot((key,))
                self.run_worker(key, "--lean-mode=" + mode)
                self.assertEqual(self.snapshot((key,)), before)

    def test_cached_build_log_cannot_replace_fresh_lean_audit(self) -> None:
        key = platforms.host_key()
        before = self.snapshot((key,))
        self.run_worker(key, "--omit-fresh-audit")
        self.assertFalse((platforms.HostLayout(self.root, key).artifacts / "lean-evidence.json").exists())
        self.assertEqual(self.snapshot((key,)), before)

    def test_lean_auto_and_explicit_resources_are_recorded_and_isolated(self) -> None:
        key = platforms.host_key()
        for workers, threads in ((0, 0), (2, 4)):
            with self.subTest(workers=workers, threads=threads):
                before = self.snapshot((key,))
                self.run_worker(key, f"--lean-workers={workers}", f"--lean-threads={threads}")
                self.assertEqual(self.snapshot((key,)), before)

    def test_legacy_archives_are_read_only_inputs(self) -> None:
        key = "macos-x86_64"
        os_name, architecture = key.split("-", 1)
        alire = archive_bytes({"bin/alr": f"mock Alire for {key}".encode(),
                               "LICENSE.txt": b"test fixture"})
        suffix = bootstrap_lean.ARCHIVES[key][0]
        prefix = f"lean-{bootstrap_lean.LEAN_VERSION}-{suffix}"
        lean = archive_bytes({f"{prefix}/bin/{tool}": f"mock {tool} for {key}".encode()
                              for tool in ("lean", "lake", "leanchecker")})
        for name, contents in ((f"alr-{bootstrap.ALIRE_VERSION}-bin-{architecture}-{os_name}.zip", alire),
                               (f"{prefix}.zip", lean)):
            (self.root / ".tools" / name).write_bytes(contents)
        before = self.snapshot((key,))
        self.run_worker(key)
        self.assertEqual(self.snapshot((key,)), before)
        host = platforms.HostLayout(self.root, key)
        routing = json.loads((host.artifacts / "setup-routing-test.json").read_text())
        self.assertEqual(routing["downloads"], [])

    def test_development_commands_keep_project_outputs_and_audit_in_native_host(self) -> None:
        host = platforms.HostLayout(self.root, platforms.host_key())
        bootstrap.prepare_context(host)
        mock_lockfile(host)
        host.alr.parent.mkdir(parents=True, exist_ok=True)
        host.alr.write_text("mock Alire executable\n")
        prepared = {"inputs_sha256": {"src/fixture.adb": "fixture-input-hash"},
                    "tools": {"gnatprove": "mock-tool-identity"}}
        original_invoke = dev.invoke

        def invoke_fixture(selected_host, command, *, cwd=None, pass_fds=(), log=None):
            # Keep the actual subprocess environment/routing code under test;
            # the log-streaming implementation is covered by its own tests.
            self.assertIsNotNone(log)
            self.assertEqual(log.name, "native.log")
            self.assertTrue((log.parent / "events.jsonl").is_file())
            self.assertTrue(pass_fds)
            for descriptor in pass_fds:
                os.fstat(descriptor)
            log.write_text("mocked native routing output\n")
            original_invoke(selected_host, command, cwd=cwd, pass_fds=pass_fds)

        with mock.patch.object(dev, "native_layout", return_value=host), \
                mock.patch.object(run_history, "registry", return_value=host.artifacts / "run-history"), \
                mock.patch.object(run_history, "available_cpus", return_value=3), \
                mock.patch.object(dev, "preflight", return_value=prepared) as preflight, \
                mock.patch.object(dev, "input_hashes", return_value=prepared["inputs_sha256"]), \
                mock.patch.object(dev, "invoke", side_effect=invoke_fixture), \
                mock.patch.object(dev, "begin_proof") as begin, \
                mock.patch.object(dev, "audit_sources") as audit_reports, \
                mock.patch.object(dev, "complete_proof") as complete:
            for action in ("build", "prove"):
                with self.subTest(action=action), mock.patch.object(subprocess, "run") as run:
                    dev.main([action, *(["--full"] if action == "prove" else []),
                              "--", "--subdirs", "verification"])
                    command = run.call_args_list[0].args[0]
                    invocation = run.call_args_list[0].kwargs
                    self.assertEqual(Path(command[0]), host.alr)
                    self.assertEqual(invocation["cwd"], host.context)
                    self.assertEqual(invocation["env"]["ALIRE_SETTINGS_DIR"], str(host.alire_settings))
                    self.assertNotIn("ALR_CONFIG", invocation["env"])
                    self.assertTrue(invocation["pass_fds"])
                    preflight.assert_called_with(host, pass_fds=invocation["pass_fds"])
                    context = Path(command[command.index("-C") + 1])
                    project = Path(command[command.index("-P") + 1])
                    self.assertEqual((context / project).resolve(), self.root / "silver.gpr")
                    self.assertEqual(command[-1], f"-XSILVER_HOST={host.key}")
                    if action == "prove":
                        begin.assert_called_once_with(
                            host, command[command.index("--") + 1:],
                            host.compiler / "obj/verification/gnatprove", cold=False, prepared=prepared)
                        audit_reports.assert_called_once_with(
                            host.root / "src", host.compiler / "obj/verification/gnatprove",
                            host.generated, effective_command=command[command.index("--") + 1:])
                        complete.assert_called_once_with(
                            host, host.compiler / "obj/verification/gnatprove", begin.return_value,
                            pass_fds=invocation["pass_fds"])
                        self.assertEqual(run.call_count, 2)
                        audit = run.call_args_list[1].args[0]
                        self.assertEqual(Path(audit[audit.index("--generated-dir") + 1]), host.generated)
                        self.assertEqual(Path(audit[audit.index("--report-dir") + 1]),
                                         host.compiler / "obj/verification/gnatprove")
                    else:
                        self.assertEqual(run.call_count, 1)

    def test_development_output_overrides_fail_before_invoking_tools(self) -> None:
        host = platforms.HostLayout(self.root, platforms.host_key())
        bootstrap.prepare_context(host)
        before = self.snapshot()
        overrides = (["-XSILVER_HOST=macos-aarch64"], ["-P", "other.gpr"],
                     ["--relocate-build-tree=/tmp/shared"], ["--object-dir=../shared"],
                     ["--target=x86_64-apple-darwin"], ["--subdirs=../another-host"],
                     ["--subdirs", "/tmp/shared"], ["--subdirs"], ["-cargs", "-gnatp"])
        with mock.patch.object(dev, "native_layout", return_value=host):
            for action in ("build", "prove"):
                for arguments in overrides:
                    with self.subTest(action=action, arguments=arguments):
                        with mock.patch.object(subprocess, "run") as run:
                            with self.assertRaises(RuntimeError):
                                dev.main([action, "--", *arguments])
                            run.assert_not_called()
        self.assertEqual(self.snapshot(), before)

    def test_unchanged_context_setup_preserves_generated_file_mtimes(self) -> None:
        host = platforms.HostLayout(self.root, platforms.host_key())
        bootstrap.prepare_context(host)
        before = self.snapshot()
        bootstrap.prepare_context(host)
        self.assertEqual(self.snapshot(), before)


class InstallationEnvironmentTests(unittest.TestCase):
    def test_symlinked_tmpdir_preserves_platform_setup_and_routing(self) -> None:
        with tempfile.TemporaryDirectory(prefix="silver tmpdir regression-") as temporary:
            parent = Path(temporary).resolve()
            physical = parent / "physical"
            physical.mkdir()
            alias = parent / "alias"
            alias.symlink_to(physical, target_is_directory=True)
            environment = dict(os.environ, TMPDIR=str(alias), TEMP=str(alias), TMP=str(alias))
            # Select just the fixture suite to avoid recursively spawning this
            # regression. Its subprocesses inherit the symlinked TMPDIR too.
            # The full class runs eleven sequential setup workers and one
            # four-worker group, each generating all current certificates.
            result = subprocess.run(
                [sys.executable, str(Path(__file__).resolve()), "PlatformIsolationTests", "-v"],
                cwd=ROOT, env=environment, text=True, capture_output=True, timeout=900)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_generated_tool_command_anchors_and_quotes_installation(self) -> None:
        with tempfile.TemporaryDirectory(prefix="silver command regression-") as temporary:
            parent = Path(temporary).resolve()
            root = parent / "installation 'quote\" $dollar `tick` ;semi café"
            root.mkdir()
            shutil.copy2(ROOT / "alire.toml", root / "alire.toml")
            (root / "src").mkdir()
            for filename in bootstrap.RUNTIME_SOURCES.values():
                shutil.copy2(ROOT / "src" / filename, root / "src" / filename)
            host = platforms.HostLayout(root, platforms.host_key())
            bootstrap.prepare_context(host)
            configuration = bootstrap.build_configuration(host)
            probe = root / "record invocation.py"
            probe.write_text(
                "import json, os, sys\n"
                "print(json.dumps({'cwd': os.getcwd(), 'args': sys.argv[1:], "
                "'environment': dict(os.environ)}))\n")
            host.alr.parent.mkdir(parents=True, exist_ok=True)
            host.alr.write_text(
                "#!/bin/sh\nexec " + shlex.quote(sys.executable) + " "
                + shlex.quote(str(probe)) + ' "$@"\n')
            host.alr.chmod(0o755)
            caller = parent / "other working directory"
            caller.mkdir()
            project = host.artifacts / "program-Ab12cd/program.gpr"
            command = (configuration["Alire_Exec"] + configuration["Image_Gnatprove"] + " -P "
                       + configuration["Quoted_Root_Directory"]
                       + "/program-Ab12cd/program.gpr --mode=all")
            environment = dict(os.environ,
                               ALIRE_SETTINGS_DIR=str(parent / "foreign-settings"),
                               SILVER_PLATFORM_TEST_UNRELATED="preserve")
            environment.update({name: "foreign-configuration"
                                for name in platforms.TOOL_ENVIRONMENT_OVERRIDES})
            result = subprocess.run(command, shell=True, cwd=caller, env=environment,
                                    text=True, capture_output=True, timeout=15)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            observation = json.loads(result.stdout)
            self.assertEqual(observation["cwd"], str(host.context))
            self.assertEqual(observation["args"],
                             ["-n", "exec", "--", str(host.image_tools / "bin/gnatprove"),
                              "-P", str(project), "--mode=all"])
            actual_environment = observation["environment"]
            self.assertEqual(actual_environment["ALIRE_SETTINGS_DIR"], str(host.alire_settings))
            self.assertEqual(actual_environment["SILVER_PLATFORM_TEST_UNRELATED"], "preserve")
            for name in platforms.TOOL_ENVIRONMENT_OVERRIDES:
                self.assertNotIn(name, actual_environment)
            self.assertEqual(list(caller.iterdir()), [])

    def test_bootstrap_reserves_the_library_evidence_precondition_suffix(self) -> None:
        # Isolate filesystem-path length from the independently checked shell
        # command bound. The latter can be stricter for heavily quoted paths.
        host = mock.Mock(key="linux-aarch64", root=Path("/installation"),
                         context=Path("/context"), alire_settings=Path("/settings"), alr=Path("/alr"))
        host.artifacts = Path("/" + "x" * 4035)
        fields = bootstrap.build_configuration(host)
        self.assertEqual(len(os.fsencode(fields["Root_Directory"])), 4036)
        self.assertEqual(fields["Source_Directory"], "/installation/src")
        host.artifacts = Path("/" + "x" * 4036)
        with self.assertRaisesRegex(RuntimeError, "4096-byte path bound"):
            bootstrap.build_configuration(host)

    def test_bootstrap_requires_complete_bounded_runtime_sources(self) -> None:
        with tempfile.TemporaryDirectory(prefix="silver embedded sources-") as temporary:
            root = Path(temporary)
            shutil.copy2(ROOT / "alire.toml", root / "alire.toml")
            (root / "src").mkdir()
            host = platforms.HostLayout(root, platforms.host_key())
            with self.assertRaises(FileNotFoundError):
                bootstrap.prepare_context(host)
            for filename in bootstrap.RUNTIME_SOURCES.values():
                shutil.copy2(ROOT / "src" / filename, root / "src" / filename)
            bootstrap.prepare_context(host)
            generated = host.generated / "silver_library_sources.ads"
            self.assertEqual(generated.read_bytes(), bootstrap.runtime_source_configuration(root / "src"))
            before = generated.stat().st_mtime_ns
            bootstrap.prepare_context(host)
            self.assertEqual(generated.stat().st_mtime_ns, before)
            target = root / "src" / "silver_io.adb"
            for data in (b"", b" " * 16_385, b"--\xff\n"):
                target.write_bytes(data)
                with self.subTest(data_length=len(data)), self.assertRaises(RuntimeError):
                    bootstrap.prepare_context(host)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--setup-worker":
        setup_worker(Path(sys.argv[2]), sys.argv[3], "--concurrent" in sys.argv,
                     "--fail-proof" in sys.argv,
                     next((arg.split("=", 1)[1] for arg in sys.argv if arg.startswith("--lean-mode=")),
                          "incremental"), "--omit-fresh-audit" in sys.argv,
                     next((int(arg.split("=", 1)[1]) for arg in sys.argv
                           if arg.startswith("--lean-workers=")), None),
                     next((int(arg.split("=", 1)[1]) for arg in sys.argv
                           if arg.startswith("--lean-threads=")), None))
    else:
        unittest.main()

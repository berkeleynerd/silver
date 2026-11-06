"""Lean evidence, incremental workspace integrity and temporary-path regressions."""
from contextlib import ExitStack, redirect_stderr, redirect_stdout
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import time
from types import SimpleNamespace
import unittest
from unittest import mock

from scripts import check_lean
from scripts.bootstrap_lean import lean_environment
from scripts.check_lean import (CANDIDATES, CERTIFICATE_ROOTS, OUTPUT_BODY_LINES,
                               audit_import_closure, generate_certificate, lake_build_command,
                               prepare_tool_cache, prepare_workspace,
                               verify_workspace_inputs)
from scripts.platforms import HostLayout, native_layout
from tests.test_lean_source import EMBEDDED, GENERATOR

ROOT = Path(__file__).resolve().parents[1]


class LeanCPUSelectionTests(unittest.TestCase):
    def test_affinity_and_process_limits_both_constrain_available_cpus(self) -> None:
        for affinity, process_count, expected in (({2, 3}, 8, 2), (set(range(12)), 3, 3)):
            with self.subTest(affinity=affinity, process_count=process_count):
                operating_system = SimpleNamespace(
                    sched_getaffinity=lambda _pid: affinity,
                    process_cpu_count=lambda: process_count, cpu_count=lambda: 16)
                with mock.patch.object(check_lean, "os", operating_system):
                    self.assertEqual(check_lean.available_cpus(), expected)

    def test_python_311_and_non_affinity_platform_fallback(self) -> None:
        with mock.patch.object(check_lean, "os", SimpleNamespace(cpu_count=lambda: 6)):
            self.assertEqual(check_lean.available_cpus(), 6)

    def test_unavailable_affinity_does_not_prevent_cpu_detection(self) -> None:
        operating_system = SimpleNamespace(
            sched_getaffinity=mock.Mock(side_effect=OSError("affinity unavailable")),
            process_cpu_count=lambda: 4, cpu_count=lambda: 16)
        with mock.patch.object(check_lean, "os", operating_system):
            self.assertEqual(check_lean.available_cpus(), 4)

    def test_unknown_counts_still_allow_one_worker(self) -> None:
        for reported in (None, 0):
            with self.subTest(reported=reported), mock.patch.object(
                    check_lean, "os", SimpleNamespace(cpu_count=lambda: reported)):
                self.assertEqual(check_lean.available_cpus(), 1)


class LeanEvidenceTests(unittest.TestCase):
    def test_complete_environment_inventory(self) -> None:
        modules = {name: Path(name + ".lean") for name in ("Silver", "Silver.Audit", "Silver.Source")}
        output = "\n".join(f"info: Silver/Audit.lean:1:0: SILVER_MODULE {name}" for name in modules)
        self.assertEqual(audit_import_closure(modules, output), set(modules))

    def test_orphan_module_is_not_covered_by_a_comment_import(self) -> None:
        modules = {name: Path(name + ".lean") for name in ("Silver", "Silver.Audit", "Silver.Orphan")}
        output = "SILVER_MODULE Silver\nSILVER_MODULE Silver.Audit\n/- import Silver.Orphan -/\n"
        with self.assertRaisesRegex(RuntimeError, "missing=Silver.Orphan"):
            audit_import_closure(modules, output)

    def test_unexpected_loaded_project_module_is_rejected(self) -> None:
        with self.assertRaisesRegex(RuntimeError, "unexpected=Silver.Hidden"):
            audit_import_closure({"Silver.Audit": Path("Audit.lean")},
                                 "SILVER_MODULE Silver.Audit\nSILVER_MODULE Silver.Hidden\n")

    def test_focused_environment_checks_requested_modules_and_real_imports(self) -> None:
        modules = {name: Path(name + ".lean") for name in (
            "Silver.AxiomAudit", "Silver.Model", "Silver.Shared", "Silver.Unrelated")}
        imported = {"Silver.AxiomAudit", "Silver.Model", "Silver.Shared"}
        output = "".join(f"SILVER_MODULE {name}\n" for name in sorted(imported))
        self.assertEqual(audit_import_closure(modules, output, ["Silver.Model"]), imported)
        for missing in ("Silver.Model", "Silver.AxiomAudit"):
            with self.subTest(missing=missing), self.assertRaises(RuntimeError):
                audit_import_closure(modules, output.replace(f"SILVER_MODULE {missing}\n", ""),
                                     ["Silver.Model"])
        with self.assertRaisesRegex(RuntimeError, "Silver.Hidden"):
            audit_import_closure(modules, output + "SILVER_MODULE Silver.Hidden\n", ["Silver.Model"])

    def workspace(self) -> tuple[HostLayout, dict[Path, bytes]]:
        temporary = tempfile.TemporaryDirectory(prefix="silver-lean-binding-")
        self.addCleanup(temporary.cleanup)
        root = Path(temporary.name).resolve()
        (root / "src").mkdir()
        host = HostLayout(root, "linux-aarch64")
        inputs = {root / "proof" / path: contents for path, contents in (
            ("Silver/AuthoritativeSource.lean", b'def source := include_str "../../../src/main.adb"\n'),
            ("Silver/SourceBridge.lean", b"import Silver.AuthoritativeSource\n"),
            ("Silver/SourceCertificates.lean", b"-- protected import facade\n"),
            ("lakefile.lean", b"import Lake\n"),
            ("lean-toolchain", b"leanprover/lean4:v4.34.1\n"))}
        prepare_workspace(host, inputs)
        for candidate in CANDIDATES:
            (host.proof / candidate).write_text("-- untrusted candidate output\n")
        verify_workspace_inputs(host, inputs)
        return host, inputs

    def test_unchanged_workspace_preserves_inputs_and_cached_objects(self) -> None:
        host, inputs = self.workspace()
        cached = host.proof / ".lake/build/lib/lean/Silver/SourceBridge.olean"
        cached.parent.mkdir(parents=True)
        cached.write_bytes(b"cached object")
        before = {path: (path.read_bytes(), path.stat().st_mtime_ns, path.stat().st_ino)
                  for path in host.proof.rglob("*") if path.is_file()}
        prepare_workspace(host, inputs)
        self.assertEqual({path: (path.read_bytes(), path.stat().st_mtime_ns, path.stat().st_ino)
                          for path in before}, before)
        changed = dict(inputs)
        changed[host.root / "proof/Silver/SourceBridge.lean"] += b"-- changed proof\n"
        prepare_workspace(host, changed)
        self.assertEqual((host.proof / "Silver/SourceBridge.lean").read_bytes(),
                         changed[host.root / "proof/Silver/SourceBridge.lean"])
        self.assertEqual(cached.read_bytes(), b"cached object")

    def test_removed_module_cannot_survive_as_an_importable_cached_object(self) -> None:
        host, inputs = self.workspace()
        artifacts = [host.proof / ".lake/build" / directory / "Silver" / suffix
                     for directory, suffix in (
                         ("lib/lean", "SourceBridge.olean"),
                         ("lib/lean", "SourceBridge.olean.server"),
                         ("lib/lean", "SourceBridge.olean.private"),
                         ("lib/lean", "SourceBridge.ilean"),
                         ("lib/lean", "SourceBridge.olean.hash"),
                         ("lib/lean", "SourceBridge.trace"),
                         ("ir", "SourceBridge.c"),
                         ("ir", "SourceBridge.setup.json"))]
        for artifact in artifacts:
            artifact.parent.mkdir(parents=True, exist_ok=True)
            artifact.write_bytes(b"old removed module")
        unrelated = artifacts[0].with_name("SourceBridgeExtra.olean")
        unrelated.write_bytes(b"unrelated completed certificate")
        before = (unrelated.read_bytes(), unrelated.stat().st_mtime_ns, unrelated.stat().st_ino)
        del inputs[host.root / "proof/Silver/SourceBridge.lean"]
        prepare_workspace(host, inputs)
        self.assertFalse((host.proof / "Silver/SourceBridge.lean").exists())
        self.assertFalse(any(artifact.exists() for artifact in artifacts))
        self.assertEqual((unrelated.read_bytes(), unrelated.stat().st_mtime_ns,
                          unrelated.stat().st_ino), before)
        self.assertTrue((host.proof / "Silver/AuthoritativeSource.lean").is_file())

    def test_changed_tool_invalidates_cache_without_rewriting_sources(self) -> None:
        host, _inputs = self.workspace()
        source = host.proof / "Silver/AuthoritativeSource.lean"
        before = (source.read_bytes(), source.stat().st_mtime_ns)
        prepare_tool_cache(host, {"lean": "old hash"})
        cached = host.proof / ".lake/build/object.olean"
        cached.parent.mkdir(parents=True)
        cached.write_bytes(b"prior compiled configuration or object")
        prepare_tool_cache(host, {"lean": "old hash"})
        self.assertTrue(cached.is_file())
        prepare_tool_cache(host, {"lean": "new hash"})
        self.assertFalse(cached.exists())
        self.assertEqual((source.read_bytes(), source.stat().st_mtime_ns), before)

    def test_optional_checker_identity_does_not_discard_compiler_cache(self) -> None:
        host, _inputs = self.workspace()
        marker = host.proof / ".silver-cache-tools.json"
        marker.write_text(json.dumps({"tools/bin/lean": "compiler", "tools/bin/lake": "builder",
                                      "tools/bin/leanchecker": "old checker"}) + "\n")
        cached = host.proof / ".lake/build/object.olean"
        cached.parent.mkdir(parents=True)
        cached.write_bytes(b"valid compiler cache")
        before = (cached.read_bytes(), cached.stat().st_mtime_ns)
        for hashes in ({"tools/bin/lean": "compiler", "tools/bin/lake": "builder"},
                       {"tools/bin/lean": "compiler", "tools/bin/lake": "builder",
                        "tools/bin/leanchecker": "new checker"}):
            prepare_tool_cache(host, hashes)
            self.assertEqual((cached.read_bytes(), cached.stat().st_mtime_ns), before)

    def test_generator_cannot_replace_handwritten_inputs_before_hash_capture(self) -> None:
        host, inputs = self.workspace()
        for source, expected in inputs.items():
            destination = host.proof / source.relative_to(host.root / "proof")
            with self.subTest(path=destination):
                destination.write_bytes(b"-- replacement\n")
                with self.assertRaisesRegex(RuntimeError, "changed handwritten proof input"):
                    verify_workspace_inputs(host, inputs)
                destination.write_bytes(expected)
        verify_workspace_inputs(host, inputs)

    def test_each_generated_certificate_must_be_regular_and_present(self) -> None:
        host, inputs = self.workspace()
        for relative in CANDIDATES:
            with self.subTest(candidate=relative):
                candidate = host.proof / relative
                contents = candidate.read_bytes()
                candidate.unlink()
                with self.assertRaisesRegex(RuntimeError, "regular certificate"):
                    verify_workspace_inputs(host, inputs)
                outside = host.root / "candidate.lean"
                outside.write_bytes(contents)
                candidate.symlink_to(outside)
                with self.assertRaisesRegex(RuntimeError, "symbolic link"):
                    verify_workspace_inputs(host, inputs)
                candidate.unlink()
                candidate.write_bytes(contents)
        verify_workspace_inputs(host, inputs)

    def test_output_body_generation_stages_all_outputs_and_preserves_unchanged_files(self) -> None:
        host, _inputs = self.workspace()
        root = Path("Silver/OutputBodyCertificate.lean")
        outputs = (root, *OUTPUT_BODY_LINES)
        generated = {relative: f"-- generated {relative}\n".encode() for relative in outputs}

        def run(command, **_kwargs):
            self.assertEqual(Path(command[-1]), (host.proof / root).with_suffix(".lean.pending"))
            for relative, contents in generated.items():
                (host.proof / relative).with_suffix(".lean.pending").write_bytes(contents)

        def identities():
            return {relative: ((host.proof / relative).read_bytes(),
                               (host.proof / relative).stat().st_mtime_ns,
                               (host.proof / relative).stat().st_ino) for relative in CANDIDATES}

        with mock.patch.object(check_lean.subprocess, "run", side_effect=run):
            generate_certificate(host, root, "silver_output_profile.adb")
            before = identities()
            generate_certificate(host, root, "silver_output_profile.adb")
            self.assertEqual(identities(), before)
            generated[OUTPUT_BODY_LINES[2]] += b"-- changed line\n"
            generate_certificate(host, root, "silver_output_profile.adb")
        after = identities()
        self.assertNotEqual(after[OUTPUT_BODY_LINES[2]][0], before[OUTPUT_BODY_LINES[2]][0])
        self.assertEqual({path: value for path, value in after.items() if path != OUTPUT_BODY_LINES[2]},
                         {path: value for path, value in before.items() if path != OUTPUT_BODY_LINES[2]})
        self.assertFalse(list(host.proof.rglob("*.pending")))

    def test_missing_output_body_chunk_does_not_publish_partial_generation(self) -> None:
        host, _inputs = self.workspace()
        root = Path("Silver/OutputBodyCertificate.lean")
        outputs = (root, *OUTPUT_BODY_LINES)
        before = {relative: (host.proof / relative).read_bytes() for relative in outputs}
        # A retained pending file must not mask an omitted output this time.
        (host.proof / OUTPUT_BODY_LINES[-1]).with_suffix(".lean.pending").write_bytes(b"stale")

        def run(_command, **_kwargs):
            for relative in outputs[:-1]:
                (host.proof / relative).with_suffix(".lean.pending").write_bytes(b"new")

        with mock.patch.object(check_lean.subprocess, "run", side_effect=run), \
                self.assertRaisesRegex(RuntimeError, "regular certificate file"):
            generate_certificate(host, root, "silver_output_profile.adb")
        self.assertEqual({relative: (host.proof / relative).read_bytes() for relative in outputs}, before)
        self.assertFalse(list(host.proof.rglob("*.pending")))

    def test_removed_output_body_chunk_cleans_its_cached_artifact_family(self) -> None:
        host, inputs = self.workspace()
        removed = OUTPUT_BODY_LINES[-1]
        artifacts = [host.proof / ".lake/build" / directory / removed.with_suffix(suffix)
                     for directory, suffix in (("lib/lean", ".olean"),
                                               ("lib/lean", ".olean.private"),
                                               ("lib/lean", ".olean.server"),
                                               ("lib/lean", ".trace"), ("ir", ".c"))]
        for artifact in artifacts:
            artifact.parent.mkdir(parents=True, exist_ok=True)
            artifact.write_bytes(b"retired chunk")
        candidates = {path: source for path, source in CANDIDATES.items() if path != removed}
        with mock.patch.object(check_lean, "CANDIDATES", candidates):
            prepare_workspace(host, inputs)
        self.assertFalse((host.proof / removed).exists())
        self.assertFalse(any(path.exists() for path in artifacts))
        self.assertTrue((host.proof / OUTPUT_BODY_LINES[0]).is_file())

    def test_generator_cannot_replace_input_with_same_content_symlink(self) -> None:
        host, inputs = self.workspace()
        destination = host.proof / "Silver/AuthoritativeSource.lean"
        outside = host.root / "outside.lean"
        outside.write_bytes(destination.read_bytes())
        destination.unlink()
        destination.symlink_to(outside)
        with self.assertRaisesRegex(RuntimeError, "symbolic link"):
            verify_workspace_inputs(host, inputs)

    def test_generator_cannot_replace_parent_directory_with_symlink(self) -> None:
        host, inputs = self.workspace()
        directory = host.proof / "Silver"
        outside = host.root / "outside"
        directory.rename(outside)
        directory.symlink_to(outside, target_is_directory=True)
        with self.assertRaisesRegex(RuntimeError, "symbolic link"):
            verify_workspace_inputs(host, inputs)


class LeanKernelPolicyTests(unittest.TestCase):
    def test_bypass_options_and_unchecked_declaration_apis_are_rejected(self) -> None:
        cases = (
            b"set_option debug.skipKernelTC true in\nexample : 2 + 2 = 5 := by decide +kernel\n",
            b'set_option debug.skipKernelTC false\n',
            b'weakLeanArgs := #["-Ddebug.skipKernelTC=true"]\n',
            b'run_elab Lean.addDeclWithoutChecking declaration\n',
            b'run_elab Lean.addDeclCore declaration\n',
        )
        for path in (Path("Silver/Model.lean"), Path("lakefile.lean")):
            for contents in cases:
                with self.subTest(path=path, contents=contents), self.assertRaisesRegex(
                        RuntimeError, "kernel-check bypass"):
                    check_lean.check_proof_policy(path, contents)

    def test_only_the_exact_existing_audit_guard_is_exempted_once(self) -> None:
        guard = "  if debug.skipKernelTC.get (← getOptions) then\n".encode()
        allowed = Path("Silver/AxiomAudit.lean")
        check_lean.check_proof_policy(allowed, guard)
        check_lean.check_proof_policy(allowed, (ROOT / "proof" / allowed).read_bytes())
        for path, contents in ((Path("Silver/Model.lean"), guard),
                               (allowed, guard + guard),
                               (allowed, guard.replace(b"  if", b"  if false &&")),
                               (allowed, guard + b"set_option debug.skipKernelTC true\n")):
            with self.subTest(path=path, contents=contents), self.assertRaisesRegex(
                    RuntimeError, "kernel-check bypass"):
                check_lean.check_proof_policy(path, contents)


class LeanRunnerPhaseTests(unittest.TestCase):
    """Exercise final-run ordering without compiling the production proofs."""

    def fixture(self) -> SimpleNamespace:
        temporary = tempfile.TemporaryDirectory(prefix="silver lean phases-")
        self.addCleanup(temporary.cleanup)
        root = Path(temporary.name).resolve()
        host = HostLayout(root, "linux-x86_64")
        proof = root / "proof"
        (proof / "Silver").mkdir(parents=True)
        (root / "src").mkdir()
        (root / "scripts").mkdir()
        (root / "scripts/check_lean.py").write_text("# fixture runner input\n")
        (proof / "Silver.lean").write_text("namespace Silver\nend Silver\n")
        (proof / "Silver/Audit.lean").write_text("import Silver\n")
        (proof / "Silver/AxiomAudit.lean").write_text("-- shared fresh-audit command\n")
        (proof / "Silver/Shared.lean").write_text("example : True := True.intro\n")
        (proof / "Silver/Model.lean").write_text("import Silver.Shared\n")
        (proof / "Silver/ModelTwo.lean").write_text("import Silver.Shared\n")
        (proof / "lakefile.lean").write_text("import Lake\n")
        (proof / "lean-toolchain").write_text("leanprover/lean4:v4.34.1\n")
        (proof / "generate_source_certificate.py").write_text("# fixture generator\n")
        for relative, source in CANDIDATES.items():
            (proof / relative).write_text("-- shared candidate is deliberately not trusted\n")
            (root / "src" / source).write_text("-- authoritative source fixture\n")
        (host.lean / "bin").mkdir(parents=True)
        for tool in ("lean", "lake", "leanchecker"):
            (host.lean / "bin" / tool).write_text("fixture " + tool)
        state = SimpleNamespace(host=host, phases=[], commands=[], generated=0, after_generation=None,
                                after_phase=None, audit="valid", fail=None, interrupt=None)

        def run(command, **_kwargs):
            if command[1:] == ["--short-version"]:
                return subprocess.CompletedProcess(command, 0, "4.34.1\n")
            self.assertEqual(command[:2], [sys.executable, str(proof / "generate_source_certificate.py")])
            source = command[command.index("--source") + 1]
            destination = Path(command[command.index("--output") + 1])
            destination.write_text("-- candidate " + source + "\n")
            if source == "silver_output_profile.adb":
                for relative in OUTPUT_BODY_LINES:
                    (host.proof / relative).with_suffix(".lean.pending").write_text(
                        "-- candidate chunk " + relative.stem + "\n")
            state.generated += 1
            if state.generated == len(CERTIFICATE_ROOTS) and state.after_generation:
                state.after_generation(host)
            return subprocess.CompletedProcess(command, 0)

        def run_logged(command, *, cwd, env, destination, pass_fds=()):
            self.assertTrue(pass_fds, "Lean child must inherit the workspace lease")
            self.assertEqual(cwd, host.proof)
            self.assertEqual(env["LEAN_NUM_THREADS"], str(getattr(state, "expected_workers", 2)))
            phase = "build" if "build" in command else "audit" if command[-1].endswith(".lean") else "kernel"
            state.phases.append(phase)
            state.commands.append(command)
            output = "fixture " + phase + "\n"
            if phase == "build":
                for module in command[command.index("build") + 1:]:
                    module = module.removeprefix("+")
                    artifact = host.proof / ".lake/build/lib/lean" / Path(*module.split(".")).with_suffix(".olean")
                    artifact.parent.mkdir(parents=True, exist_ok=True)
                    artifact.write_bytes(b"compiled fixture")
                output += "Silver axiom audit passed: cached output is insufficient\n"
            if phase == "audit":
                if state.audit != "missing-marker":
                    output += "Silver axiom audit passed: fixture\n"
                names = sorted(check_lean.project_sources(host.proof))
                if command[-1].endswith("silver-focused-audit.lean"):
                    driver = (host.proof / command[-1]).read_text()
                    names = sorted({line.removeprefix("import ") for line in driver.splitlines()
                                    if line.startswith("import ")} | {"Silver.Shared"})
                if state.audit == "missing-module":
                    names = names[1:]
                if state.audit == "unexpected-module":
                    names.append("Silver.Unexpected")
                output += "".join("SILVER_MODULE " + name + "\n" for name in names)
            destination.write(output)
            destination.flush()
            if state.after_phase:
                state.after_phase(phase, host)
            if phase == state.interrupt:
                raise KeyboardInterrupt()
            return subprocess.CompletedProcess(command, 7 if phase == state.fail else 0, output)

        patches = ExitStack()
        self.addCleanup(patches.close)
        for name, value in (("ROOT", root), ("PROOF", proof)):
            patches.enter_context(mock.patch.object(check_lean, name, value))
        patches.enter_context(mock.patch.object(check_lean, "native_layout", return_value=host))
        patches.enter_context(mock.patch.object(check_lean, "available_cpus", return_value=2))
        patches.enter_context(mock.patch("scripts.run_history.available_cpus", return_value=2))
        patches.enter_context(mock.patch("scripts.run_history.registry",
                                         return_value=host.artifacts / "run-history"))
        patches.enter_context(mock.patch.object(check_lean, "lean_environment", return_value=dict(os.environ)))
        patches.enter_context(mock.patch.object(check_lean.subprocess, "run", side_effect=run))
        patches.enter_context(mock.patch.object(check_lean, "run_logged", side_effect=run_logged))
        return state

    def check_fails(self, state: SimpleNamespace, expected: str,
                    arguments: list[str] | None = None) -> None:
        with redirect_stdout(io.StringIO()), self.assertRaisesRegex(RuntimeError, expected):
            check_lean.main(["--full"] if arguments is None else arguments)
        self.assertFalse((state.host.artifacts / "lean-evidence.json").exists())

    def test_bypass_in_shared_module_or_lakefile_stops_before_workspace_or_lake(self) -> None:
        for arguments in ([], ["--target", "Silver.Model"]):
            for relative, contents in (
                    ("Silver/Shared.lean", "set_option debug.skipKernelTC true\n"),
                    ("lakefile.lean", 'weakLeanArgs := #["-Ddebug.skipKernelTC=true"]\n')):
                with self.subTest(arguments=arguments, path=relative):
                    state = self.fixture()
                    (state.host.root / "proof" / relative).write_text(contents)
                    state.host.artifacts.mkdir(parents=True)
                    name = "lean-focused-evidence.json" if arguments else "lean-evidence.json"
                    evidence = state.host.artifacts / name
                    evidence.write_text("prior success\n")
                    with redirect_stdout(io.StringIO()), self.assertRaisesRegex(
                            RuntimeError, "kernel-check bypass"):
                        check_lean.main(arguments)
                    self.assertFalse(evidence.exists())
                    self.assertFalse(state.host.proof.exists())
                    self.assertEqual(state.generated, 0)
                    self.assertEqual(state.phases, [])

    def test_generated_candidate_bypass_stops_before_lake(self) -> None:
        for arguments in ([], ["--target", "Silver.Model"]):
            with self.subTest(arguments=arguments):
                state = self.fixture()
                state.after_generation = lambda host: (host.proof / next(iter(CANDIDATES))).write_text(
                    "set_option debug.skipKernelTC true\n")
                with redirect_stdout(io.StringIO()), self.assertRaisesRegex(
                        RuntimeError, "kernel-check bypass"):
                    check_lean.main(arguments)
                self.assertEqual(state.phases, [])
                name = "lean-focused-evidence.json" if arguments else "lean-evidence.json"
                self.assertFalse((state.host.artifacts / name).exists())

    def test_cached_bypass_command_is_rejected_after_source_reversion_without_deleting_cache(self) -> None:
        for arguments in ([], ["--target", "Silver.Model"]):
            with self.subTest(arguments=arguments):
                state = self.fixture()
                with redirect_stdout(io.StringIO()):
                    check_lean.main(arguments)
                state.phases.clear()
                artifact = state.host.proof / ".lake/build/lib/lean/Silver/AxiomAudit.olean"
                if not artifact.exists():
                    artifact.write_bytes(b"retained cached object")
                before = (artifact.read_bytes(), artifact.stat().st_mtime_ns)
                trace = artifact.with_suffix(".trace")
                trace.write_text(json.dumps({"log": [{"message":
                    "lean -Ddebug.skipKernelTC=true Silver/AxiomAudit.lean"}]}))
                trace_before = trace.read_bytes()
                with redirect_stdout(io.StringIO()), self.assertRaisesRegex(
                        RuntimeError, "kernel-check bypass"):
                    check_lean.main(arguments)
                self.assertEqual(state.phases, [])
                self.assertEqual((artifact.read_bytes(), artifact.stat().st_mtime_ns), before)
                self.assertEqual(trace.read_bytes(), trace_before)
                name = "lean-focused-evidence.json" if arguments else "lean-evidence.json"
                self.assertFalse((state.host.artifacts / name).exists())

    def test_default_check_rejects_input_drift_after_each_phase(self) -> None:
        for changed_phase in ("build", "audit"):
            for target in ("shared-add", "shared-delete", "shared-bytes", "workspace-add",
                           "workspace-bytes", "candidate-bytes", "tool", "source-link"):
                with self.subTest(phase=changed_phase, target=target):
                    state = self.fixture()
                    state.host.artifacts.mkdir(parents=True)
                    (state.host.artifacts / "lean-evidence.json").write_text("prior success\n")

                    def change(phase, host):
                        if phase != changed_phase:
                            return
                        if target == "shared-add":
                            (host.root / "src/new.ads").write_text("-- new source\n")
                        elif target == "shared-delete":
                            (host.root / "proof/Silver/Shared.lean").unlink()
                        elif target == "shared-bytes":
                            (host.root / "src/silver_profile.adb").write_text("-- changed\n")
                        elif target == "workspace-add":
                            (host.proof / "Silver/New.lean").write_text("-- new module\n")
                        elif target == "workspace-bytes":
                            (host.proof / "Silver/Model.lean").write_text("-- changed\n")
                        elif target == "candidate-bytes":
                            (host.proof / next(iter(CANDIDATES))).write_text("-- changed candidate\n")
                        elif target == "tool":
                            (host.lean / "bin/lean").write_bytes(b"changed compiler")
                        else:
                            outside = host.root / "other-src"
                            outside.mkdir()
                            link = host.artifacts / "src"
                            link.unlink()
                            link.symlink_to(outside, target_is_directory=True)

                    state.after_phase = change
                    expected = ("shared inventory or bytes" if target.startswith("shared-") else
                                "workspace inventory or bytes" if target in ("workspace-add", "candidate-bytes") else
                                "changed handwritten proof input" if target == "workspace-bytes" else
                                "tools changed" if target == "tool" else "source link changed")
                    with mock.patch.object(check_lean, "compiled_artifacts",
                                           side_effect=AssertionError("optional collection ran")):
                        self.check_fails(state, expected, [])
                    self.assertEqual(state.phases, ["build"] + (["audit"] if changed_phase == "audit" else []))
                    self.assertTrue((state.host.proof / ".lake/build/lib/lean/Silver/Audit.olean").is_file())

    def test_default_check_cannot_publish_failed_or_incomplete_audit(self) -> None:
        for failure in ("exit", "missing-marker", "missing-module", "unexpected-module"):
            with self.subTest(failure=failure):
                state = self.fixture()
                state.host.artifacts.mkdir(parents=True)
                (state.host.artifacts / "lean-evidence.json").write_text("prior success\n")
                if failure == "exit":
                    state.fail = "audit"
                    expected = "Lean check failed"
                else:
                    state.audit = failure
                    expected = ("freshly executed axiom audit" if failure == "missing-marker" else
                                "actual Lean audit imports")
                self.check_fails(state, expected, [])
                self.assertEqual(state.phases, ["build", "audit"])
                self.assertIn("fixture audit", (state.host.artifacts / "lean-proof.log").read_text())

    def test_added_or_deleted_shared_inputs_stop_after_build_with_cache_retained(self) -> None:
        for relative, action in (("proof/Silver/New.lean", "add"), ("src/new.adb", "add"),
                                 ("scripts/new.py", "add"), ("proof/Silver.lean", "delete"),
                                 ("src/silver_profile.adb", "delete"), ("scripts/check_lean.py", "delete")):
            with self.subTest(path=relative, action=action):
                state = self.fixture()

                def change(_phase, host):
                    path = host.root / relative
                    path.write_text("new input\n") if action == "add" else path.unlink()

                state.after_phase = change
                self.check_fails(state, "shared inventory or bytes")
                self.assertEqual(state.phases, ["build"])
                self.assertTrue((state.host.proof / ".lake/build/lib/lean/Silver/Audit.olean").is_file())

    def test_added_workspace_module_stops_before_fresh_audit(self) -> None:
        state = self.fixture()
        state.after_phase = lambda _phase, host: (host.proof / "Silver/New.lean").write_text("-- new\n")
        self.check_fails(state, "workspace inventory or bytes")
        self.assertEqual(state.phases, ["build"])

    def test_generation_drift_stops_before_lake(self) -> None:
        state = self.fixture()
        state.after_generation = lambda host: (host.root / "src/new.ads").write_text("-- new\n")
        self.check_fails(state, "shared inventory or bytes")
        self.assertEqual(state.phases, [])

    def test_missing_fresh_audit_or_incomplete_closure_never_runs_kernel(self) -> None:
        for audit in ("missing-marker", "missing-module", "unexpected-module"):
            with self.subTest(audit=audit):
                state = self.fixture()
                state.audit = audit
                expected = "freshly executed axiom audit" if audit == "missing-marker" else "actual Lean audit imports"
                self.check_fails(state, expected)
                self.assertEqual(state.phases, ["build", "audit"])

    def test_input_drift_at_audit_or_kernel_cannot_publish_success(self) -> None:
        for changed_phase in ("audit", "kernel"):
            with self.subTest(phase=changed_phase):
                state = self.fixture()

                def change(phase, host):
                    if phase == changed_phase:
                        (host.root / "scripts/added.py").write_text("# new\n")

                state.after_phase = change
                self.check_fails(state, "shared inventory or bytes")
                self.assertEqual(state.phases, ["build", "audit"] + (["kernel"] if changed_phase == "kernel" else []))

    def test_tool_or_artifact_drift_stops_before_kernel(self) -> None:
        for target in ("tool", "artifact", "artifact.server", "artifact.private", "source-link"):
            with self.subTest(target=target):
                state = self.fixture()

                def change(phase, host):
                    artifact = host.proof / ".lake/build/lib/lean/Silver/Audit.olean"
                    if target.startswith("artifact."):
                        artifact = artifact.with_name(artifact.name + target.removeprefix("artifact"))
                        if phase == "build":
                            artifact.write_bytes(b"compiled sidecar fixture")
                    if phase == "audit":
                        if target == "source-link":
                            other = host.root / "other-src"
                            other.mkdir()
                            link = host.artifacts / "src"
                            link.unlink()
                            link.symlink_to(other, target_is_directory=True)
                        else:
                            path = host.lean / "bin/leanchecker" if target == "tool" else artifact
                            path.write_bytes(b"changed")

                state.after_phase = change
                expected = ("artifacts changed" if target.startswith("artifact") else
                            {"tool": "tools changed", "source-link": "source link changed"}[target])
                self.check_fails(state, expected)
                self.assertEqual(state.phases, ["build", "audit"])

    def test_shared_candidate_bytes_and_cache_files_are_not_new_proof_inputs(self) -> None:
        state = self.fixture()

        def change(phase, host):
            if phase == "build":
                (host.root / "proof" / next(iter(CANDIDATES))).write_text("-- unused shared candidate\n")
                (host.proof / ".lake/cache.lean").write_text("-- cache entry\n")

        state.after_phase = change
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--full"])
        self.assertEqual(state.phases, ["build", "audit", "kernel"])

    def test_phase_failure_and_interruption_preserve_partial_log(self) -> None:
        for interrupt in (False, True):
            with self.subTest(interrupt=interrupt):
                state = self.fixture()
                if interrupt:
                    state.interrupt = "audit"
                    with redirect_stdout(io.StringIO()), self.assertRaises(KeyboardInterrupt):
                        check_lean.main(["--full"])
                else:
                    state.fail = "audit"
                    self.check_fails(state, "Lean check failed")
                log = (state.host.artifacts / "lean-proof.log").read_text()
                self.assertIn("fixture audit", log)
                self.assertIn("interrupted" if interrupt else "exit 7", log)
                self.assertEqual(state.phases, ["build", "audit"])
                self.assertFalse((state.host.artifacts / "lean-evidence.json").exists())

    def test_success_records_actual_phase_times_and_current_inventories(self) -> None:
        state = self.fixture()
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--full"])
        evidence = json.loads((state.host.artifacts / "lean-evidence.json").read_text())
        self.assertEqual([phase["phase"] for phase in evidence["phases"]], ["build", "audit", "kernel"])
        for phase in evidence["phases"]:
            self.assertEqual(phase["exit_code"], 0)
            self.assertGreaterEqual(phase["elapsed_seconds"], 0)
            self.assertLessEqual(phase["started_at"], phase["finished_at"])
        self.assertEqual(set(evidence["modules"]), set(check_lean.project_sources(state.host.proof)))
        self.assertEqual(evidence["kernel_recheck"], "leanchecker --fresh Silver.Audit")

    def test_routine_and_clean_checks_skip_replay_and_detailed_artifact_collection(self) -> None:
        for arguments in ([], ["--clean"]):
            with self.subTest(arguments=arguments):
                state = self.fixture()
                (state.host.lean / "bin/leanchecker").unlink()
                with redirect_stdout(io.StringIO()), mock.patch.object(
                        check_lean, "compiled_artifacts", side_effect=AssertionError("optional collection ran")):
                    check_lean.main(arguments)
                self.assertEqual(state.phases, ["build", "audit"])
                evidence = json.loads((state.host.artifacts / "lean-evidence.json").read_text())
                self.assertEqual(evidence["scope"], "complete")
                self.assertIsNone(evidence["kernel_recheck"])
                self.assertRegex(evidence["inputs_digest_sha256"], r"^[0-9a-f]{64}$")
                self.assertTrue(evidence["tools_sha256"])
                for field in ("artifacts_sha256", "inputs_sha256",
                              "workspace_inputs_sha256"):
                    self.assertNotIn(field, evidence)

    def test_provenance_collects_detail_without_enabling_replay(self) -> None:
        state = self.fixture()
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--provenance"])
        self.assertEqual(state.phases, ["build", "audit"])
        evidence = json.loads((state.host.artifacts / "lean-evidence.json").read_text())
        self.assertIsNone(evidence["kernel_recheck"])
        self.assertTrue(evidence["artifacts_sha256"])
        self.assertIn("proof/Silver/Model.lean", evidence["inputs_sha256"])
        self.assertIn("Silver/Model.lean", evidence["workspace_inputs_sha256"])
        self.assertTrue(evidence["tools_sha256"])

    def test_replay_and_full_alias_request_kernel_after_fresh_audit(self) -> None:
        for option in ("--replay", "--full"):
            with self.subTest(option=option):
                state = self.fixture()
                with redirect_stdout(io.StringIO()):
                    check_lean.main([option])
                self.assertEqual(state.phases, ["build", "audit", "kernel"])
                self.assertIn("--fresh", state.commands[-1])

    def test_focused_check_syncs_targets_and_keeps_complete_evidence_and_unrelated_objects(self) -> None:
        state = self.fixture()
        host = state.host
        host.artifacts.mkdir(parents=True)
        complete_evidence = host.artifacts / "lean-evidence.json"
        complete_log = host.artifacts / "lean-proof.log"
        complete_evidence.write_text('{"historical": "complete evidence for earlier inputs"}\n')
        complete_log.write_text("historical complete log\n")
        (host.root / "proof/Silver/Model.lean").write_text("import Silver.Shared\n-- current source\n")
        before = (complete_evidence.read_bytes(), complete_log.read_bytes())
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--target", "Silver.Model", "--target", "Silver.ModelTwo",
                             "--target", "Silver.Model"])
        self.assertEqual(state.phases, ["build", "audit"])
        build = state.commands[0]
        self.assertEqual(build[build.index("build") + 1:],
                         ["+Silver.Model", "+Silver.ModelTwo", "+Silver.AxiomAudit"])
        self.assertEqual((host.proof / "Silver/Model.lean").read_bytes(),
                         (host.root / "proof/Silver/Model.lean").read_bytes())
        driver = (host.proof / ".lake/silver-focused-audit.lean").read_text()
        # A legacy driver loads private declarations through module boundaries.
        self.assertNotIn("module", driver.splitlines())
        self.assertIn("#silver_audit", driver)
        self.assertIn("import Silver.Model\n", driver)
        self.assertNotIn("import Silver\n", driver)
        self.assertNotIn("import Silver.Audit\n", driver)
        evidence = json.loads((host.artifacts / "lean-focused-evidence.json").read_text())
        self.assertEqual(evidence["scope"], "focused")
        self.assertEqual(evidence["targets"], ["Silver.Model", "Silver.ModelTwo"])
        self.assertEqual(set(evidence["modules"]),
                         {"Silver.Model", "Silver.ModelTwo", "Silver.Shared", "Silver.AxiomAudit"})
        self.assertIsNone(evidence["kernel_recheck"])
        self.assertEqual((complete_evidence.read_bytes(), complete_log.read_bytes()), before)
        cached = host.proof / ".lake/build/lib/lean/Silver/Unrelated.olean"
        cached.write_bytes(b"unrelated completed proof")
        prior = (cached.read_bytes(), cached.stat().st_mtime_ns)
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--target", "Silver.Model"])
        self.assertEqual((cached.read_bytes(), cached.stat().st_mtime_ns), prior)
        self.assertEqual((complete_evidence.read_bytes(), complete_log.read_bytes()), before)

    def test_failed_focused_audit_cannot_reuse_its_old_success_or_replace_complete_evidence(self) -> None:
        for audit in ("missing-marker", "missing-module", "unexpected-module"):
            with self.subTest(audit=audit):
                state = self.fixture()
                state.audit = audit
                state.host.artifacts.mkdir(parents=True)
                complete = state.host.artifacts / "lean-evidence.json"
                focused = state.host.artifacts / "lean-focused-evidence.json"
                complete.write_bytes(b"prior complete evidence\n")
                focused.write_bytes(b"prior focused evidence\n")
                with redirect_stdout(io.StringIO()), self.assertRaises(RuntimeError):
                    check_lean.main(["--target", "Silver.Model"])
                self.assertFalse(focused.exists())
                self.assertEqual(complete.read_bytes(), b"prior complete evidence\n")
                self.assertEqual(state.phases, ["build", "audit"])

    def test_root_target_selects_the_module_instead_of_the_lake_library(self) -> None:
        state = self.fixture()
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--target", "Silver"])
        build = state.commands[0]
        self.assertEqual(build[build.index("build") + 1:], ["+Silver", "+Silver.AxiomAudit"])
        driver = (state.host.proof / ".lake/silver-focused-audit.lean").read_text()
        self.assertIn("import Silver\n", driver)
        self.assertNotIn("import +Silver", driver)

    def test_invalid_target_or_focused_replay_does_not_mutate_workspace_or_evidence(self) -> None:
        for arguments in (["--target", "Silver.Missing"], ["--target", "../Silver"],
                          ["--target", "Silver.Model\nimport Silver"],
                          ["--target", "Silver.Model:olean"],
                          ["--target", "Silver.Model", "--replay"],
                          ["--target", "Silver.Model", "--full"]):
            with self.subTest(arguments=arguments):
                state = self.fixture()
                state.host.artifacts.mkdir(parents=True)
                for name in ("lean-evidence.json", "lean-focused-evidence.json"):
                    (state.host.artifacts / name).write_bytes(b"prior evidence\n")
                with redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()), \
                        self.assertRaises((RuntimeError, SystemExit)):
                    check_lean.main(arguments)
                self.assertFalse(state.host.proof.exists())
                self.assertEqual(state.generated, 0)
                self.assertEqual(state.phases, [])
                for name in ("lean-evidence.json", "lean-focused-evidence.json"):
                    self.assertEqual((state.host.artifacts / name).read_bytes(), b"prior evidence\n")

    def test_focused_result_digest_changes_with_protected_input_bytes(self) -> None:
        state = self.fixture()
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--target", "Silver.Model"])
        evidence = state.host.artifacts / "lean-focused-evidence.json"
        before = json.loads(evidence.read_text())["inputs_digest_sha256"]
        (state.host.root / "src/silver_profile.adb").write_text("-- changed authoritative bytes\n")
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--target", "Silver.Model"])
        self.assertNotEqual(json.loads(evidence.read_text())["inputs_digest_sha256"], before)

    def test_focused_input_drift_stops_before_audit_and_preserves_cache(self) -> None:
        state = self.fixture()
        state.after_phase = lambda _phase, host: (host.root / "src/new.ads").write_text("-- new\n")
        with redirect_stdout(io.StringIO()), self.assertRaisesRegex(RuntimeError, "shared inventory or bytes"):
            check_lean.main(["--target", "Silver.Model"])
        self.assertEqual(state.phases, ["build"])
        self.assertFalse((state.host.artifacts / "lean-focused-evidence.json").exists())
        self.assertTrue((state.host.proof / ".lake/build/lib/lean/Silver/Model.olean").is_file())

    def test_focused_driver_drift_stops_before_audit(self) -> None:
        state = self.fixture()
        state.after_phase = lambda _phase, host: (
            host.proof / ".lake/silver-focused-audit.lean").write_text("-- replaced audit driver\n")
        with redirect_stdout(io.StringIO()), self.assertRaisesRegex(RuntimeError, "audit.*changed|changed.*audit"):
            check_lean.main(["--target", "Silver.Model"])
        self.assertEqual(state.phases, ["build"])
        self.assertFalse((state.host.artifacts / "lean-focused-evidence.json").exists())


class LeanStreamingTests(unittest.TestCase):
    def test_interrupted_read_kills_and_reaps_the_child(self) -> None:
        child = mock.MagicMock()
        child.__enter__.return_value = child
        child.stdout.read1.side_effect = KeyboardInterrupt()
        with mock.patch.object(check_lean.subprocess, "Popen", return_value=child), \
                self.assertRaises(KeyboardInterrupt):
            check_lean.run_logged(["fixture-lean"], cwd=ROOT, env={}, destination=io.StringIO())
        child.kill.assert_called_once_with()
        child.wait.assert_called_once_with()

    def test_partial_lines_and_merged_stderr_are_logged_before_child_exit(self) -> None:
        with tempfile.TemporaryDirectory(prefix="silver lean stream-") as temporary:
            root = Path(temporary).resolve()
            release = root / "release"
            log = root / "phase.log"
            # Exit is gated on the parent observing a flushed, unterminated
            # UTF-8 message in the canonical log. Buffer-until-exit would fail.
            code = ("import os,time\nfrom pathlib import Path\n"
                    "os.write(1, b'partial \\xe2'); time.sleep(.05)\n"
                    "os.write(1, b'\\x9c\\x93'); os.write(2, b' stderr')\n"
                    f"release=Path({str(release)!r})\n"
                    "deadline=time.monotonic()+5\n"
                    "while not release.exists() and time.monotonic()<deadline: time.sleep(.01)\n"
                    "raise SystemExit(7 if release.exists() else 8)\n")
            results = []

            def run():
                with log.open("w") as destination:
                    results.append(check_lean.run_logged(
                        [sys.executable, "-c", code], cwd=root, env=dict(os.environ),
                        destination=destination))

            console = io.StringIO()
            with redirect_stdout(console):
                thread = threading.Thread(target=run)
                thread.start()
                try:
                    deadline = time.monotonic() + 4
                    while time.monotonic() < deadline:
                        if log.exists() and log.read_text() == "partial ✓ stderr":
                            break
                        time.sleep(.01)
                    self.assertEqual(log.read_text(), "partial ✓ stderr")
                    self.assertTrue(thread.is_alive())
                finally:
                    release.touch()
                    thread.join(timeout=6)
            self.assertFalse(thread.is_alive())
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0].returncode, 7)
            self.assertEqual(results[0].stdout, "partial ✓ stderr")
            self.assertEqual(console.getvalue(), results[0].stdout)


class LeanTemporaryDirectoryTests(unittest.TestCase):
    def test_fixture_suite_under_symlinked_tmpdir(self) -> None:
        with tempfile.TemporaryDirectory(prefix="silver lean tmpdir-") as temporary:
            parent = Path(temporary).resolve()
            physical = parent / "physical"
            physical.mkdir()
            alias = parent / "alias"
            alias.symlink_to(physical, target_is_directory=True)
            environment = dict(os.environ, TMPDIR=str(alias), TEMP=str(alias), TMP=str(alias),
                               PYTHONDONTWRITEBYTECODE="1")
            # A fresh process avoids tempfile's cached directory. Select only
            # the fixture class so this subprocess test cannot call itself.
            result = subprocess.run(
                [sys.executable, "-m", "unittest", "tests.test_lean_evidence.LeanEvidenceTests"],
                cwd=Path(__file__).resolve().parents[1], env=environment,
                text=True, capture_output=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class LeanNativeAxiomAuditTests(unittest.TestCase):
    def test_actual_audit_accepts_foundations_and_rejects_other_assumptions(self) -> None:
        native = native_layout(ROOT)
        lean = native.lean / "bin/lean"
        if not lean.is_file():
            self.skipTest("install the pinned native Lean tools to check the real axiom audit")
        with tempfile.TemporaryDirectory(prefix="silver lean axiom audit-") as temporary:
            root = Path(temporary).resolve()
            (root / "Silver").mkdir()
            (root / "Silver/AxiomAudit.lean").write_bytes(
                (ROOT / "proof/Silver/AxiomAudit.lean").read_bytes())
            environment = {**lean_environment(native), "LEAN_PATH": str(root)}

            def run(relative: str, *, compile_module: bool = False) -> subprocess.CompletedProcess[str]:
                command = [str(lean), "-j1"]
                if compile_module:
                    command.extend(["-o", str(Path(relative).with_suffix(".olean"))])
                return subprocess.run([*command, relative], cwd=root, env=environment,
                                      text=True, capture_output=True, timeout=60)

            compiled = run("Silver/AxiomAudit.lean", compile_module=True)
            self.assertEqual(compiled.returncode, 0, compiled.stdout + compiled.stderr)
            # Module ownership, rather than a Silver-prefixed declaration name,
            # must include this unused assumption in the imported audit scope.
            (root / "Silver/Foreign.lean").write_text("axiom OutsideSilver.unused : False\n")
            compiled = run("Silver/Foreign.lean", compile_module=True)
            self.assertEqual(compiled.returncode, 0, compiled.stdout + compiled.stderr)
            cases = {
                "foundations": (
                    "", "theorem Silver.ok : True := True.intro\n"
                    "noncomputable def Silver.choice (h : Nonempty Nat) : Nat := Classical.choice h\n"
                    "theorem Silver.ext (p q : Prop) (h : p ↔ q) : p = q := propext h\n"),
                "unused": ("", "axiom Silver.unused : False\n"),
                "private": ("", "private axiom hidden : False\n"),
                "imported": ("import Silver.Foreign\n", ""),
                "sorry": ("", "theorem Silver.bad : False := by sorry\n"),
                "native_decide": ("", "theorem Silver.arithmetic : 2 + 2 = 4 := by native_decide\n"),
            }
            for name, (imports, declarations) in cases.items():
                with self.subTest(case=name):
                    relative = f"Silver/Check_{name}.lean"
                    (root / relative).write_text(
                        "import Silver.AxiomAudit\n" + imports + declarations + "#silver_audit\n")
                    result = run(relative)
                    output = result.stdout + result.stderr
                    if name == "foundations":
                        self.assertEqual(result.returncode, 0, output)
                        self.assertIn("Silver axiom audit passed:", output)
                        for foundation in ("propext", "Quot.sound", "Classical.choice"):
                            self.assertIn(foundation, output)
                    else:
                        self.assertNotEqual(result.returncode, 0, output)
                        self.assertIn("Unapproved logical assumption", output)
                        self.assertNotIn("Silver axiom audit passed:", output)


class LeanNativeDependencyTests(unittest.TestCase):
    def test_removed_dependency_fails_closed_without_discarding_unrelated_objects(self) -> None:
        native = native_layout(ROOT)
        if not (native.lean / "bin/lake").is_file():
            self.skipTest("install the pinned native Lean tools to check module removal")
        with tempfile.TemporaryDirectory(prefix="silver lean removal-") as temporary:
            root = Path(temporary).resolve()
            host = HostLayout(root, native.key)
            host.lean.parent.mkdir(parents=True)
            host.lean.symlink_to(native.lean, target_is_directory=True)
            (root / "src").mkdir()
            inputs = {root / "proof" / name: contents.encode() for name, contents in (
                ("lakefile.lean", "import Lake\nopen Lake DSL\npackage probe\nlean_lib Silver\n"),
                ("lean-toolchain", (ROOT / "proof/lean-toolchain").read_text()),
                ("Silver/Removed.lean", "def Silver.removed : Nat := 42\n"),
                ("Silver/Importer.lean", "import Silver.Removed\n"
                 "def Silver.imported := Silver.removed\n"),
                ("Silver/Transitive.lean", "import Silver.Importer\n"
                 "def Silver.transitive := Silver.imported\n"),
                ("Silver/Independent.lean", "theorem Silver.independent : True := True.intro\n"),
                ("Silver.lean", "import Silver.Transitive\nimport Silver.Independent\n"))}
            prepare_workspace(host, inputs)
            environment = lean_environment(host)

            def lake(*arguments: str) -> subprocess.CompletedProcess[str]:
                return subprocess.run([str(host.lean / "bin/lake"), *arguments],
                                      cwd=host.proof, env=environment, text=True,
                                      capture_output=True, timeout=180)

            result = lake("build", "Silver")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            objects = host.proof / ".lake/build/lib/lean/Silver"
            retained = [objects / f"{name}.olean" for name in ("Importer", "Transitive", "Independent")]
            before = {path: (path.read_bytes(), path.stat().st_mtime_ns) for path in retained}
            del inputs[root / "proof/Silver/Removed.lean"]
            prepare_workspace(host, inputs)
            self.assertFalse((objects / "Removed.olean").exists())
            self.assertEqual({path: (path.read_bytes(), path.stat().st_mtime_ns)
                              for path in retained}, before)
            # Neither Lake nor a fresh Lean process may silently use the old
            # transitive importer after the dependency has disappeared.
            result = lake("build", "+Silver.Transitive")
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("Silver.Removed", result.stdout + result.stderr)
            probe = host.proof / "Probe.lean"
            probe.write_text("import Silver.Transitive\n#check Silver.transitive\n")
            result = lake("env", "lean", "Probe.lean")
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("Silver.Removed", result.stdout + result.stderr)
            result = lake("build", "+Silver.Independent")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            independent = objects / "Independent.olean"
            self.assertEqual((independent.read_bytes(), independent.stat().st_mtime_ns),
                             before[independent])

    def test_changed_resource_settings_apply_without_discarding_cached_objects(self) -> None:
        native = native_layout(ROOT)
        if not (native.lean / "bin/lake").is_file():
            self.skipTest("install the pinned native Lean tools to check Lake configuration")
        with tempfile.TemporaryDirectory(prefix="silver lean config-") as temporary:
            root = Path(temporary).resolve()
            host = HostLayout(root, native.key)
            host.lean.parent.mkdir(parents=True)
            host.lean.symlink_to(native.lean, target_is_directory=True)
            (root / "src").mkdir()
            for name in EMBEDDED:
                (root / "src" / name).write_bytes(b"original\n")
            audit_source = (
                'example : True := True.intro\n'
                '#eval (do IO.println ("lake workers=" ++ '
                '(← IO.getEnv "LEAN_NUM_THREADS").getD "missing") : IO Unit)\n').encode()
            inputs = {
                root / "proof/lakefile.lean": (ROOT / "proof/lakefile.lean").read_bytes(),
                root / "proof/lean-toolchain": (ROOT / "proof/lean-toolchain").read_bytes(),
                root / "proof/Silver/Audit.lean": audit_source,
            }
            prepare_workspace(host, inputs)
            environment = lean_environment(host)

            def build(workers: int, threads: int | None,
                      memory: int | None) -> subprocess.CompletedProcess[str]:
                settings = []
                if threads is not None:
                    settings.extend(["-K", f"silverThreads={threads}"])
                if memory is not None:
                    settings.extend(["-K", f"silverMemoryMb={memory}"])
                command = lake_build_command(host.lean / "bin/lake", settings)
                command.insert(1, "--verbose")
                result = subprocess.run(
                    command, cwd=host.proof,
                    env={**environment, "LEAN_NUM_THREADS": str(workers)}, text=True,
                    capture_output=True, timeout=180)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                return result

            first = build(1, 1, 256)
            self.assertRegex(first.stdout + first.stderr, r"\s-j1\s-M256\b")
            self.assertIn("lake workers=1", first.stdout + first.stderr)
            artifact = host.proof / ".lake/build/lib/lean/Silver/Audit.olean"
            before = (artifact.read_bytes(), artifact.stat().st_mtime_ns)
            build(3, 2, 512)
            self.assertEqual((artifact.read_bytes(), artifact.stat().st_mtime_ns), before)
            # Force a new Lean process after changing only the cached Lake
            # configuration. Without --reconfigure it still receives -j1/-M256.
            (host.proof / "Silver/Audit.lean").write_bytes(
                audit_source + b"example : 2 + 2 = 4 := rfl\n")
            changed = build(3, 2, 512)
            self.assertRegex(changed.stdout + changed.stderr, r"\s-j2\s-M512\b")
            self.assertIn("lake workers=3", changed.stdout + changed.stderr)
            # Returning to automatic settings preserves accepted objects and
            # removes both overrides from the next actual compiler invocation.
            before = (artifact.read_bytes(), artifact.stat().st_mtime_ns)
            build(3, None, None)
            self.assertEqual((artifact.read_bytes(), artifact.stat().st_mtime_ns), before)
            (host.proof / "Silver/Audit.lean").write_bytes(
                audit_source + b"example : 3 + 3 = 6 := rfl\n")
            automatic = build(3, None, None)
            self.assertNotRegex(automatic.stdout + automatic.stderr, r"\s-[jM]\d+\b")
            self.assertIn("lake workers=3", automatic.stdout + automatic.stderr)

    def test_lake_tracks_embedded_ada_bytes_and_preserves_unchanged_objects(self) -> None:
        native = native_layout(ROOT)
        if not (native.lean / "bin/lake").is_file():
            self.skipTest("install the pinned native Lean tools to check actual Lake invalidation")
        with tempfile.TemporaryDirectory(prefix="silver lean dependencies-") as temporary:
            root = Path(temporary).resolve()
            host = HostLayout(root, native.key)
            host.lean.parent.mkdir(parents=True)
            host.lean.symlink_to(native.lean, target_is_directory=True)
            (root / "src").mkdir()
            sources = [root / "src" / name for name in EMBEDDED]
            for source in sources:
                source.write_bytes(b"original\n")
            inputs = {
                root / "proof/lakefile.lean": (ROOT / "proof/lakefile.lean").read_bytes(),
                root / "proof/lean-toolchain": (ROOT / "proof/lean-toolchain").read_bytes(),
                root / "proof/Silver/Independent.lean": b"module\nexample : True := True.intro\n",
            }
            modules = {}
            imports = ["module", "public import Silver.Independent"]
            for filename, binding, _prefix in GENERATOR.SOURCE_BINDINGS:
                module = binding[0].upper() + binding[1:] + "Source"
                modules[filename] = module
                relative = Path("Silver") / f"{module}.lean"
                # Exercise the actual handwritten binding and exact library
                # ownership, with independent stale-value witnesses downstream.
                inputs[root / "proof" / relative] = (ROOT / "proof" / relative).read_bytes()
                inputs[root / f"proof/Silver/{module}Witness.lean"] = (
                    f"module\npublic import Silver.{module}\n"
                    f'example : Silver.Source.{binding} = "original\\n" := by decide\n'
                ).encode()
                imports.append(f"public import Silver.{module}Witness")
            inputs[root / "proof/Silver.lean"] = ("\n".join(imports) + "\n").encode()
            prepare_workspace(host, inputs)
            environment = lean_environment(host)
            command = [str(host.lean / "bin/lake"), "--rehash", "-K", "silverThreads=1",
                       "build", "Silver"]

            def build() -> subprocess.CompletedProcess[str]:
                return subprocess.run(command, cwd=host.proof, env=environment, text=True,
                                      capture_output=True, timeout=180)

            result = build()
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

            def objects() -> dict[str, tuple[bytes, int]]:
                return {str(path.relative_to(host.proof / ".lake/build/lib/lean")):
                        (path.read_bytes(), path.stat().st_mtime_ns)
                        for path in (host.proof / ".lake/build/lib/lean").rglob("*.olean*")
                        if path.name.endswith((".olean", ".olean.server", ".olean.private"))}

            before = objects()
            for module in ("Independent", *modules.values()):
                for suffix in (".olean", ".olean.server", ".olean.private"):
                    self.assertIn(f"Silver/{module}{suffix}", before)
            result = build()
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(objects(), before)
            for source in sources:
                with self.subTest(source=source.name):
                    before = objects()
                    original = source.read_bytes()
                    stat = source.stat()
                    # CRLF must differ even with a restored timestamp. A text
                    # input_file dependency would normalize it and miss this.
                    try:
                        source.write_bytes(original.replace(b"\n", b"\r\n"))
                        os.utime(source, ns=(stat.st_atime_ns, stat.st_mtime_ns))
                        self.assertEqual(source.stat().st_mtime_ns, stat.st_mtime_ns)
                        result = build()
                        self.assertNotEqual(result.returncode, 0, "changed included Ada bytes used a stale object")
                        output = result.stdout + result.stderr
                        self.assertIn("Tactic `decide` proved that the proposition", output)
                        self.assertIn("is false", output)
                        self.assertIn(f"{modules[source.name]}Witness.lean", output)
                        changed_module = f"Silver/{modules[source.name]}.olean"
                        after = objects()
                        self.assertNotEqual(after[changed_module][0], before[changed_module][0])
                        affected = {
                            module + suffix
                            for module in (f"Silver/{modules[source.name]}", "Silver",
                                           f"Silver/{modules[source.name]}Witness")
                            for suffix in (".olean", ".olean.server", ".olean.private")
                        }
                        for module, identity in before.items():
                            if module not in affected:
                                self.assertEqual(after[module], identity, module)
                    finally:
                        source.write_bytes(original)
                    result = build()
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()

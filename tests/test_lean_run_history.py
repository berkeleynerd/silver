"""Lean runner history integration; fixtures never execute project proofs."""
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

from scripts import check_lean, run_history
from tests import test_lean_evidence


class LeanRunHistoryTests(unittest.TestCase):
    fixture = test_lean_evidence.LeanRunnerPhaseTests.fixture

    def runs(self, state):
        return sorted(run_history.status(state.host)["runs"], key=lambda run: run["utc"])

    def invoke(self, arguments=()):
        with redirect_stdout(io.StringIO()):
            check_lean.main(list(arguments))

    def test_lease_precedes_workspace_changes_and_all_child_launches_inherit_it(self):
        state = self.fixture()
        prepare = check_lean.prepare_workspace
        subprocess_run = check_lean.subprocess.run
        inherited = []

        def prepare_locked(*args, **kwargs):
            active = self.runs(state)
            self.assertEqual(len(active), 1)
            self.assertTrue(active[0]["active"])
            self.assertEqual(active[0]["workers"], 2)
            self.assertEqual(active[0]["events"][-1]["event"], "preflight")
            return prepare(*args, **kwargs)

        def run_inherited(*args, **kwargs):
            inherited.append(kwargs.get("pass_fds"))
            for descriptor in kwargs["pass_fds"]:
                os.fstat(descriptor)
            return subprocess_run(*args, **kwargs)

        with mock.patch.object(check_lean, "prepare_workspace", side_effect=prepare_locked), \
                mock.patch.object(check_lean.subprocess, "run", side_effect=run_inherited):
            self.invoke(["--task", "#39"])
        self.assertEqual(len(inherited), 1 + len(check_lean.CERTIFICATE_ROOTS))
        self.assertTrue(all(inherited))
        run = self.runs(state)[0]
        self.assertEqual(run["state"], "success")
        self.assertEqual(run["task"], "#39")
        self.assertEqual(run["scope"], "complete")
        self.assertTrue(run["inputs"]["sources"])
        self.assertTrue(run["inputs"]["tools"])
        self.assertEqual([event["phase"] for event in run["events"]
                          if event["event"] == "phase_finished"], ["build", "audit"])
        evidence = json.loads((state.host.artifacts / "lean-evidence.json").read_text())
        self.assertEqual(evidence["run_id"], run["run_id"])

    def test_automatic_workers_use_remaining_budget_without_changing_process_threads(self):
        state = self.fixture()
        state.expected_workers = 1
        with run_history.ManagedRun(state.host, "fixture", [], {},
                                    [state.host.artifacts / "independent"], workers=1,
                                    resource_reason="fixture reserves one of two workers"):
            self.invoke()
        evidence = json.loads((state.host.artifacts / "lean-evidence.json").read_text())
        self.assertEqual(evidence["lake_workers"], 1)
        self.assertEqual(evidence["threads_per_process"], 2)
        first = next(run for run in self.runs(state) if run["kind"] == "lean")
        self.assertEqual(first["allocation"]["workers"], {"requested": None, "automatic": 1, "actual": 1})
        self.assertEqual(first["allocation"]["threads"], {"requested": None, "automatic": 2, "actual": 2})
        self.assertEqual((first["resource_reductions"], first["resource_reason"]), ([], ""))
        state.expected_workers = 2
        self.invoke()
        lean_runs = [run for run in self.runs(state) if run["kind"] == "lean"]
        self.assertNotEqual(first["fingerprint"], lean_runs[-1]["fingerprint"])

    def test_deliberate_lean_reduction_needs_a_retained_resource_reason(self):
        state = self.fixture()
        reason = "GNATprove audit shares this host"
        for arguments, refused in ((["--workers", "1"], "workers 1 < 2"),
                                   (["--workers", "1", "--reason", "Repeat a successful clean check"], "workers 1 < 2"),
                                   (["--threads", "1"], "threads 1 < 2"),
                                   (["--workers", "1", "--threads", "1"], "threads 1 < 2, workers 1 < 2")):
            with self.subTest(arguments=arguments), self.assertRaisesRegex(
                    run_history.RunHistoryError,
                    "deliberate reduction below the automatic allocation needs --resource-reason: "
                    + refused + "$"):
                self.invoke(arguments)
        self.assertEqual(self.runs(state), [])
        self.assertFalse(state.host.proof.exists())
        self.assertEqual((state.generated, state.phases), (0, []))
        state.expected_workers = 1
        output = io.StringIO()
        with redirect_stdout(output):
            check_lean.main(["--workers", "1", "--threads", "1", "--resource-reason", reason])
        with self.assertRaisesRegex(run_history.RunHistoryError, "--resource-reason: threads 1 < 2, workers 1 < 2$"):
            self.invoke(["--workers", "1", "--threads", "1"])
        run, = self.runs(state)
        self.assertEqual(run["state"], "success")
        self.assertEqual(run["allocation"], {"workers": {"requested": 1, "automatic": 2, "actual": 1},
                                             "threads": {"requested": 1, "automatic": 2, "actual": 1},
                                             "memory_mb": {"requested": None, "automatic": None, "actual": None}})
        self.assertEqual((run["resource_reductions"], run["resource_reason"]), (["threads", "workers"], reason))
        evidence = json.loads((state.host.artifacts / "lean-evidence.json").read_text())
        self.assertEqual((evidence["lake_workers"], evidence["threads_per_process"]), (1, 1))
        self.assertIn("silverThreads=1", state.commands[0])
        lines = output.getvalue().splitlines()
        concurrency = next(index for index, line in enumerate(lines) if line.startswith("Lean concurrency:"))
        self.assertEqual(lines[concurrency + 1],
                         "Resource allocation: threads requested=1 actual=1 automatic=2; "
                         "workers requested=1 actual=1 automatic=2; "
                         f"deliberate reduction: threads, workers; reason: {reason}")

    def test_default_and_full_requests_need_no_resource_reason(self):
        state = self.fixture()
        for arguments, workers, threads in (([], None, None), (["--workers", "0", "--threads", "0"], None, None),
                                            (["--workers", "2", "--threads", "2"], 2, 2),
                                            (["--threads", "3"], None, 3)):
            with self.subTest(arguments=arguments):
                self.invoke(arguments)
                run = self.runs(state)[-1]
                self.assertEqual(run["allocation"]["workers"], {"requested": workers, "automatic": 2, "actual": 2})
                self.assertEqual(run["allocation"]["threads"],
                                 {"requested": threads, "automatic": 2, "actual": threads or 2})
                self.assertEqual((run["state"], run["resource_reductions"], run["resource_reason"]),
                                 ("success", [], ""))
                self.assertIn(f"silverThreads={threads or 2}", state.commands[-2])

    def test_resource_only_change_preserves_lake_cache_and_clean_guard(self):
        state = self.fixture()
        reduced = ["--workers", "1", "--threads", "1", "--memory-mb", "2048"]
        marker = state.host.proof / ".lake/retained-cache-marker"
        tools = state.host.proof / ".silver-cache-tools.json"
        self.invoke()
        marker.write_text("accepted objects\n")
        accepted_tools = tools.read_bytes()
        state.expected_workers = 1
        self.invoke([*reduced, "--resource-reason", "GNATprove audit shares this host"])
        self.assertTrue(marker.is_file())
        self.assertEqual(tools.read_bytes(), accepted_tools)

        def without_resource_flags(command):
            kept = [argument for argument in command if not argument.startswith(("-j", "-M"))]
            settings = {index for index, argument in enumerate(kept) if argument == "-K"}
            return [argument for index, argument in enumerate(kept)
                    if index not in settings and index - 1 not in settings]

        automatic, two_workers = state.commands[:2], state.commands[2:]
        self.assertEqual([without_resource_flags(command) for command in automatic],
                         [without_resource_flags(command) for command in two_workers])
        self.assertTrue({"silverThreads=1", "silverMemoryMb=2048"} <= set(two_workers[0]))
        self.assertTrue({"-j1", "-M2048"} <= set(two_workers[1]))
        for build, audit in (automatic, two_workers):
            self.assertEqual(build[1:3], ["--rehash", "--reconfigure"])
            self.assertIn("-DwarningAsError=true", audit)
        self.assertEqual([sorted(run["inputs"]["configuration"]) for run in self.runs(state)],
                         [["clean", "memory_mb", "provenance", "replay", "threads", "workers"]] * 2)
        self.invoke(["--clean", *reduced, "--resource-reason", "GNATprove audit shares this host"])
        marker.write_text("accepted objects after the clean check\n")
        with self.assertRaisesRegex(run_history.RunHistoryError, "supply --reason"):
            self.invoke(["--clean", *reduced, "--resource-reason", "another check shares this host"])
        self.assertEqual(marker.read_text(), "accepted objects after the clean check\n")
        self.assertEqual(state.phases, ["build", "audit"] * 3)
        self.assertEqual([run["state"] for run in self.runs(state)], ["success"] * 3)

    def test_conflicting_lease_preserves_workspace_and_prior_evidence(self):
        state = self.fixture()
        state.host.artifacts.mkdir(parents=True)
        evidence = state.host.artifacts / "lean-evidence.json"
        evidence.write_text("prior evidence\n")
        with run_history.ManagedRun(state.host, "fixture", [], {}, [state.host.proof], workers=0):
            with self.assertRaisesRegex(RuntimeError, "resources are held"):
                self.invoke()
        self.assertEqual(evidence.read_text(), "prior evidence\n")
        self.assertFalse(state.host.proof.exists())
        self.assertEqual(state.generated, 0)
        self.assertEqual(state.phases, [])

    def test_routine_repeat_executes_fresh_audit_and_preserves_each_success(self):
        state = self.fixture()
        self.invoke(["--task", "first"])
        self.invoke(["--task", "second", "--reason", "inspect current evidence"])
        runs = self.runs(state)
        self.assertEqual(len(runs), 2)
        self.assertEqual(runs[0]["fingerprint"], runs[1]["fingerprint"])
        self.assertEqual(state.phases, ["build", "audit", "build", "audit"])
        for run in runs:
            retained = Path(run["directory"])
            self.assertIn("fixture audit", (retained / "lean-proof.log").read_text())
            evidence = json.loads((retained / "lean-evidence.json").read_text())
            self.assertEqual(evidence["run_id"], run["run_id"])

    def test_matching_clean_repeat_needs_reason_before_cache_mutation(self):
        state = self.fixture()
        self.invoke(["--clean"])
        marker = state.host.proof / ".lake/retained-cache-marker"
        marker.parent.mkdir(parents=True, exist_ok=True)
        marker.write_text("preserved until authorized runner invocation\n")
        with self.assertRaisesRegex(RuntimeError, "supply --reason"):
            self.invoke(["--clean", "--task", "different task metadata"])
        self.assertTrue(marker.is_file())
        self.assertEqual(state.phases, ["build", "audit"])
        self.invoke(["--clean", "--reason", "investigate a concrete cache concern"])
        self.assertFalse(marker.exists())
        self.assertEqual(state.phases, ["build", "audit", "build", "audit"])
        self.assertEqual(len(self.runs(state)), 2)

    def test_failures_and_interruptions_record_terminal_status_and_retained_output(self):
        for interruption in (False, True):
            with self.subTest(interruption=interruption):
                state = self.fixture()
                state.interrupt = "audit" if interruption else None
                state.fail = None if interruption else "audit"
                with self.assertRaises(KeyboardInterrupt if interruption else RuntimeError):
                    self.invoke()
                run = self.runs(state)[0]
                self.assertEqual(run["state"], "interrupted" if interruption else "failure")
                self.assertEqual(run["finish"]["returncode"], None if interruption else 7)
                reports = run["finish"]["retained_reports"]
                self.assertEqual(len(reports), 1)
                self.assertIn("fixture audit", Path(reports[0]["retained"]).read_text())
                self.assertFalse((state.host.artifacts / "lean-evidence.json").exists())

    def test_failed_preflight_does_not_relabel_an_earlier_log_as_current(self):
        state = self.fixture()
        self.invoke()
        (state.host.root / "proof/lean-toolchain").write_text("leanprover/lean4:v0.0.0\n")
        with self.assertRaisesRegex(RuntimeError, "does not match"):
            self.invoke()
        run = self.runs(state)[-1]
        self.assertEqual(run["state"], "failure")
        self.assertEqual(run["finish"]["retained_reports"], [])
        self.assertFalse((state.host.artifacts / "lean-proof.log").exists())
        self.assertEqual(state.phases, ["build", "audit"])

    def test_failed_source_diagnostics_become_repeatable_failure_keys(self):
        state = self.fixture()
        logged = check_lean.run_logged
        state.fail = "build"

        def fail_with_diagnostic(*args, **kwargs):
            result = logged(*args, **kwargs)
            error = "error: ./Silver/Model.lean:12:4: unsolved goals\n"
            kwargs["destination"].write(error)
            kwargs["destination"].flush()
            return subprocess.CompletedProcess(result.args, result.returncode, result.stdout + error)

        with mock.patch.object(check_lean, "run_logged", side_effect=fail_with_diagnostic), \
                self.assertRaises(RuntimeError):
            self.invoke(["--target", "Silver.Model"])
        run = self.runs(state)[0]
        self.assertEqual(run["scope"], ["Silver.Model"])
        self.assertEqual(run["finish"]["failure_keys"],
                         ["lean:build:Silver/Model.lean:12:4:unsolved goals"])


class LeanLeaseChildTests(unittest.TestCase):
    def test_run_logged_passes_a_real_descriptor_to_the_child(self):
        with tempfile.TemporaryFile() as lease, redirect_stdout(io.StringIO()):
            descriptor = lease.fileno()
            result = check_lean.run_logged(
                [sys.executable, "-c", f"import os; print(os.fstat({descriptor}).st_ino)"],
                cwd=Path.cwd(), env=dict(os.environ), destination=io.StringIO(),
                pass_fds=(descriptor,))
            self.assertEqual(result.returncode, 0)
            self.assertEqual(result.stdout.strip(), str(os.fstat(descriptor).st_ino))

    def test_diagnostic_keys_accept_lean_and_lake_errors_but_not_warnings(self):
        workspace = Path("/tmp/fixture-proof")
        keys = check_lean.lean_failure_keys(
            "Silver/Foo.lean:1:2: error: tactic failed\n"
            "error: ././Silver/Bar.lean:3:4: unsolved goals\n"
            "Silver/Foo.lean:5:6: warning: unused variable\n"
            "error: external tool crashed\n", "audit", workspace)
        self.assertEqual(keys, ["lean:audit:Silver/Bar.lean:3:4:unsolved goals",
                                "lean:audit:Silver/Foo.lean:1:2:tactic failed"])


if __name__ == "__main__":
    unittest.main()

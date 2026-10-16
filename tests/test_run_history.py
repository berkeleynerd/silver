"""Real process leases, durable outcomes, and bounded proof-loop policies."""
from __future__ import annotations

import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock

from scripts import run_history as history
from scripts.platforms import HostLayout

ROOT = Path(__file__).resolve().parents[1]


class RunHistoryTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix="silver run history ")
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.host = HostLayout(self.root, "linux-aarch64")
        self.resources = [self.root / "objects"]
        self.environment = dict(os.environ, PYTHONPATH=str(ROOT))

    def run_context(self, **options):
        arguments = dict(host=self.host, kind="proof", command=["prove"], inputs={"source": "a"},
                         resources=self.resources, workers=0, task="issue39")
        arguments.update(options)
        return history.ManagedRun(**arguments)

    def records(self):
        return history.status(self.host)["runs"]

    def holder(self, *, workers=0, resource=None, root=None, orphan=False):
        resource = resource or self.resources[0]
        program = """
import json, pathlib, subprocess, sys, time
from scripts import run_history as history
from scripts.platforms import HostLayout
history.available_cpus = lambda: 2
host = HostLayout(pathlib.Path(sys.argv[1]), 'linux-aarch64')
with history.ManagedRun(host, 'holder', ['test'], {}, [pathlib.Path(sys.argv[2])], workers=int(sys.argv[3])) as run:
    child = None
    if sys.argv[4] == 'True':
        child = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(30)'], pass_fds=run.pass_fds)
    print(json.dumps({'run_id': run.run_id, 'child': child.pid if child else None}), flush=True)
    sys.stdin.readline()
"""
        process = subprocess.Popen([sys.executable, "-c", program, str(root or self.root), str(resource),
                                    str(workers), str(orphan)], cwd=ROOT, env=self.environment,
                                   stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        def cleanup():
            if process.poll() is None:
                process.kill()
            process.communicate(timeout=10)
        self.addCleanup(cleanup)
        line = process.stdout.readline()
        self.assertTrue(line, process.stderr.read() if process.poll() is not None else "holder did not start")
        return process, json.loads(line)

    def release(self, process):
        process.communicate("done\n", timeout=10)
        self.assertEqual(process.returncode, 0)

    def test_start_is_durable_before_execution_and_failure_is_retained(self):
        report = self.root / "failed.spark"
        with self.assertRaises(subprocess.CalledProcessError):
            with self.run_context(failure_reports=[report]) as run:
                report.write_text(json.dumps({"proof": [{"file": "unit.adb", "line": 9, "col": 3,
                    "rule": "VC_RANGE_CHECK", "severity": "medium", "how_proved": "unproved"}]}))
                start = self.records()[0]
                self.assertEqual(start["state"], "active")
                self.assertEqual(start["resources"][0]["resolved"], str(self.resources[0]))
                self.assertIn("utc", start)
                run.event("phase", name="proof")
                raise subprocess.CalledProcessError(7, ["prove"])
        record = self.records()[0]
        self.assertEqual(record["state"], "failure")
        self.assertEqual(record["finish"]["returncode"], 7)
        self.assertEqual(record["finish"]["failure_keys"], ["unit.adb:9:3:VC_RANGE_CHECK"])
        self.assertGreaterEqual(record["finish"]["duration_seconds"], 0)
        retained = Path(record["finish"]["retained_reports"][0]["retained"])
        report.write_text("replacement")
        self.assertIn("VC_RANGE_CHECK", retained.read_text())

    def test_explicit_nonzero_and_interruptions_never_become_success(self):
        with self.run_context() as run:
            run.finish("failure", returncode=5)
        with self.assertRaises(KeyboardInterrupt):
            with self.run_context():
                raise KeyboardInterrupt()
        with self.assertRaises(history.RunHistoryError):
            with self.run_context() as run:
                run.finish("success", returncode=9)
        self.assertEqual(sorted(record["state"] for record in self.records()),
                         ["failure", "failure", "interrupted"])

    def test_torn_final_success_record_is_not_a_completed_run(self):
        with self.run_context() as run:
            pass
        journal = run.directory / "events.jsonl"
        journal.write_bytes(journal.read_bytes().rstrip(b"\n"))
        record = self.records()[0]
        self.assertEqual(record["state"], "interrupted")
        self.assertIsNone(record["finish"])

    def test_resolved_alias_and_ancestor_paths_contend_between_processes(self):
        self.resources[0].mkdir()
        alias = self.root / "alias"
        alias.symlink_to(self.resources[0], target_is_directory=True)
        process, info = self.holder()
        for resource in (alias, alias / "nested", self.root):
            with self.subTest(resource=resource), self.assertRaisesRegex(history.RunHistoryError, info["run_id"]):
                with self.run_context(resources=[resource]):
                    self.fail("conflicting process started")
        with self.run_context(resources=[self.root / "independent"]):
            pass
        self.release(process)
        with self.run_context(resources=[alias]):
            pass

    def test_child_keeps_lease_after_parent_is_killed(self):
        process, info = self.holder(orphan=True)
        self.addCleanup(lambda: self.kill_if_alive(info["child"]))
        process.kill()
        process.wait(timeout=10)
        self.assertEqual(self.records()[0]["state"], "active")
        with self.assertRaisesRegex(history.RunHistoryError, info["run_id"]):
            with self.run_context():
                self.fail("orphan child lost its lease")
        os.kill(info["child"], signal.SIGTERM)
        deadline = time.monotonic() + 5
        while self.records()[0]["state"] == "active" and time.monotonic() < deadline:
            time.sleep(0.01)
        self.assertEqual(self.records()[0]["state"], "interrupted")
        self.assertIsNone(self.records()[0]["finish"])
        with self.run_context():
            pass

    @staticmethod
    def kill_if_alive(pid):
        try:
            os.kill(pid, signal.SIGTERM)
        except ProcessLookupError:
            pass

    def test_closing_parent_context_does_not_unlock_surviving_child(self):
        process, info = self.holder(orphan=True)
        self.addCleanup(lambda: self.kill_if_alive(info["child"]))
        process.stdin.write("done\n")
        process.stdin.flush()
        process.wait(timeout=10)
        self.assertEqual(self.records()[0]["state"], "active")
        with self.assertRaises(history.RunHistoryError):
            with self.run_context():
                self.fail("close released a child's shared lock")
        os.kill(info["child"], signal.SIGTERM)

    def test_workers_coordinate_without_blocking_unreserved_commands(self):
        process, info = self.holder(workers=1)
        with mock.patch.object(history, "available_cpus", return_value=2):
            with self.run_context(resources=[], workers=None) as run:
                self.assertEqual(run.workers, 1)
                with self.assertRaisesRegex(history.RunHistoryError, "worker budget"):
                    with self.run_context(resources=[], workers=None):
                        self.fail("oversubscribed")
                with self.run_context(resources=[], workers=0):
                    self.assertEqual(history.status(self.host)["reserved_workers"], 2)
            with self.assertRaisesRegex(history.RunHistoryError, info["run_id"]):
                with self.run_context(resources=[], workers=2):
                    self.fail("oversubscribed")
        self.release(process)

    def test_worktrees_share_registry_and_resolved_resource_leases(self):
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        subprocess.run(["git", "-C", str(self.root), "-c", "user.name=Test", "-c", "user.email=test@example.invalid",
                        "commit", "--allow-empty", "-qm", "fixture"], check=True)
        other = self.root / "linked"
        subprocess.run(["git", "-C", str(self.root), "worktree", "add", "--detach", str(other)],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        linked_host = HostLayout(other, self.host.key)
        self.assertEqual(history.registry(self.host), history.registry(linked_host))
        process, info = self.holder(root=other)
        with self.assertRaisesRegex(history.RunHistoryError, info["run_id"]):
            with self.run_context():
                self.fail("worktree bypassed shared registry")
        self.release(process)
        self.assertTrue(history.registry(self.host).is_relative_to(self.root / ".git"))

    def test_expensive_success_requires_reason_and_does_not_skip_request(self):
        with self.run_context(expensive=True):
            pass
        with self.assertRaisesRegex(history.RunHistoryError, "--reason"):
            with self.run_context(expensive=True, command=["prove", "new-cold-directory"]):
                self.fail("duplicate lacked reason")
        with self.run_context(expensive=True, reason="investigate tool timing") as repeated:
            self.assertTrue(repeated.run_id)
        with self.run_context(expensive=True, inputs={"source": "changed"}):
            pass
        with self.run_context(expensive=False):
            pass
        self.assertEqual(len(self.records()), 4)

    def test_prepared_identity_enforces_duplicate_guard_and_records_preflight_failure(self):
        snapshot = {"source": "authoritative", "tool": "pinned", "scope": "all"}
        with self.run_context() as first:
            first.prepare(snapshot, expensive=True)
        with self.assertRaisesRegex(history.RunHistoryError, "--reason"):
            with self.run_context() as duplicate:
                duplicate.prepare(snapshot, expensive=True)
        with self.assertRaisesRegex(RuntimeError, "preflight failed"):
            with self.run_context():
                raise RuntimeError("preflight failed")
        records = self.records()
        self.assertEqual([run["state"] for run in records], ["success", "failure", "failure"])
        self.assertEqual(records[0]["inputs"], snapshot)
        self.assertEqual(records[0]["fingerprint"], records[1]["fingerprint"])

    def test_unchanged_failed_reports_are_retained_but_not_counted_again(self):
        report = self.root / "old.spark"
        report.write_text(json.dumps({"proof": [{"file": "unit.adb", "line": 1, "col": 1,
            "rule": "VC_RANGE_CHECK", "severity": "medium", "how_proved": "unproved"}]}))
        with self.run_context(failure_reports=[report]) as run:
            run.finish("failure", returncode=2)
        finish = self.records()[0]["finish"]
        self.assertEqual(finish["failure_keys"], [])
        self.assertEqual(len(finish["retained_reports"]), 1)

    def test_custom_workspace_reports_are_recursive_and_preserve_distinct_paths(self):
        workspace = self.root / "custom"
        stale = workspace / "old/obj/gnatprove/unit.spark"
        stale.parent.mkdir(parents=True)
        stale.write_text(json.dumps({"proof": [{"file": "old.adb", "line": 1, "col": 1,
            "rule": "VC_RANGE_CHECK", "severity": "medium", "how_proved": "unproved"}]}))
        with self.run_context(failure_reports=[workspace]) as run:
            current = workspace / "new/obj/gnatprove/unit.spark"
            current.parent.mkdir(parents=True)
            current.write_text(json.dumps({"proof": [{"file": "new.adb", "line": 1, "col": 1,
                "rule": "VC_RANGE_CHECK", "severity": "medium", "how_proved": "unproved"}]}))
            (current.parent / "gnatprove.out").write_text("new failure diagnostics")
            run.event("command", command=["actual-tool", "-j", "1"], cwd=str(workspace))
            run.finish("failure", returncode=1)
        record = self.records()[0]
        self.assertEqual(record["command"], ["actual-tool", "-j", "1"])
        self.assertEqual(record["cwd"], str(workspace))
        self.assertEqual(record["finish"]["failure_keys"], ["new.adb:1:1:VC_RANGE_CHECK"])
        retained = run.directory / "reports/0"
        self.assertEqual((retained / stale.relative_to(workspace)).read_bytes(), stale.read_bytes())
        self.assertEqual((retained / current.relative_to(workspace)).read_bytes(), current.read_bytes())
        self.assertEqual((retained / "new/obj/gnatprove/gnatprove.out").read_text(), "new failure diagnostics")

    def fail_obligation(self, **options):
        with self.run_context(**options) as run:
            run.finish("failure", returncode=1, failure_keys=["unit.adb:1:1:VC_RANGE_CHECK"])
        return run.run_id

    def test_three_recurrences_need_diagnosis_and_changed_inputs_do_not_hide_them(self):
        for value in range(3):
            run_id = self.fail_obligation(inputs={"source": str(value)})
        with self.assertRaisesRegex(history.RunHistoryError, "diagnostic"):
            with self.run_context(inputs={"source": "another edit"}):
                self.fail("fourth unchanged obligation attempt")
        history.diagnose(self.host, run_id, "guard is absent from VC context", "inspect generated VC")
        with self.run_context():
            pass
        self.assertEqual(history.status(self.host)["notes"][0]["event"], "diagnostic")

    def test_unrelated_success_does_not_clear_same_scope_failures(self):
        for _ in range(3):
            self.fail_obligation(inputs={"scope": ["A"]})
        with self.run_context(inputs={"scope": ["B"]}):
            pass
        with self.assertRaisesRegex(history.RunHistoryError, "diagnostic"):
            with self.run_context(inputs={"scope": ["A"]}):
                self.fail("different scope cleared failures")

    def test_success_and_diagnosis_reset_counts_but_generic_failures_do_not_add_them(self):
        for _ in range(2):
            self.fail_obligation()
        with self.run_context():
            pass
        for _ in range(2):
            self.fail_obligation()
        for _ in range(4):
            with self.run_context() as run:
                run.finish("failure", returncode=2)
        with self.run_context():
            pass

    def test_final_check_result_ignores_losing_solver_attempts(self):
        report = self.root / "unit.spark"
        report.write_text(json.dumps({"proof": [{"file": "unit.adb", "line": 1, "col": 2,
            "rule": "VC_RANGE_CHECK", "severity": "info", "how_proved": "prover",
            "unproved_status": {"status": "unknown"},
            "check_tree": [{"proof_attempts": {"Z3": {"result": "Timeout"}, "CVC5": {"result": "Valid"}}}]}]}))
        self.assertEqual(history.failed_obligations([report]), [])
        report.write_text("incomplete JSON")
        self.assertEqual(history.failed_obligations([report]), [])

    def test_notes_remain_outside_inputs_and_history_is_host_isolated(self):
        inputs = {"source": "stable", "scope": "complete"}
        with self.run_context(inputs=inputs) as first:
            fingerprint = first.record["fingerprint"]
        history.checkpoint(self.host, "issue39", "source snapshot stable", "focused model proof")
        with self.run_context(inputs=inputs) as second:
            self.assertEqual(fingerprint, second.record["fingerprint"])
        self.assertEqual(history.status(self.host, "other-task")["runs"], [])
        foreign = HostLayout(self.root, "macos-aarch64")
        self.assertEqual(history.status(foreign)["runs"], [])
        self.assertFalse((self.root / "scripts").exists())
        self.assertEqual(len(history.status(self.host)["notes"]), 1)


if __name__ == "__main__":
    unittest.main()

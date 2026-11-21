"""Real process leases, durable outcomes, and bounded proof-loop policies."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from unittest import mock

from scripts import run_history as history
from scripts import platforms
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
        # Allocation fixtures below model a host independently of the CPUs
        # assigned to this test process. Real inheritance is checked separately.
        patch = mock.patch.object(history, "process_cpus", return_value=8)
        patch.start()
        self.addCleanup(patch.stop)

    def run_context(self, **options):
        arguments = dict(host=self.host, kind="prove", command=["prove"], inputs={"source": "a"},
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
history.process_cpus = lambda: 2
host = HostLayout(pathlib.Path(sys.argv[1]), 'linux-aarch64')
with history.ManagedRun(host, 'holder', ['test'], {}, [pathlib.Path(sys.argv[2])], workers=int(sys.argv[3]),
                        resource_reason='fixture holder reserves part of the host') as run:
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

    def test_notes_recover_torn_appends_without_losing_original_fragments(self):
        run_id = self.fail_obligation()
        history.checkpoint(self.host, "issue39", "initial checkpoint", "inspect report")
        notes = history.registry(self.host) / "notes.jsonl"
        checkpoint_fragment = b'{"event":"checkpoint","summary":"interrupted'
        with notes.open("ab") as stream:
            stream.write(checkpoint_fragment)
        history.checkpoint(self.host, "issue39", "recovered checkpoint", "read VC")
        diagnostic_fragment = b'{"event":"diagnostic","summary":"also interrupted'
        with notes.open("ab") as stream:
            stream.write(diagnostic_fragment)
        history.diagnose(self.host, run_id, "VC needs a bound", "inspect bound propagation")
        report = history.status(self.host)
        self.assertEqual([note["event"] for note in report["notes"]],
                         ["checkpoint", "checkpoint", "diagnostic"])
        fragments = [path.read_bytes() for path in notes.parent.glob("notes.jsonl.interrupted-*")]
        self.assertCountEqual(fragments, [checkpoint_fragment, diagnostic_fragment])
        with self.run_context():
            pass

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

    def test_deliberate_worker_reduction_needs_a_retained_reason(self):
        reason = "GNATprove audit shares this host"
        with mock.patch.object(history, "available_cpus", return_value=4):
            for blank in ("", " \t "):
                with self.subTest(reason=blank), self.assertRaisesRegex(
                        history.RunHistoryError,
                        r"deliberate reduction below the automatic allocation needs "
                        r"--resource-reason: workers 2 < 4$"):
                    with self.run_context(workers=2, resource_reason=blank):
                        self.fail("deliberate reduction lacked a reason")
            self.assertEqual(self.records(), [])
            self.assertFalse((history.registry(self.host) / "runs").exists())
            with self.run_context(workers=2, resource_reason=reason) as run:
                self.assertEqual(run.workers, 2)
            with self.assertRaisesRegex(history.RunHistoryError, "--resource-reason: workers 2 < 4"):
                with self.run_context(workers=2):
                    self.fail("an earlier resource reason was inherited")
        record, = self.records()
        self.assertEqual(record["allocation"], {"workers": {"requested": 2, "automatic": 4, "actual": 2}})
        self.assertEqual(record["resource_reductions"], ["workers"])
        self.assertEqual(record["resource_reason"], reason)
        self.assertEqual({key: record[key] for key in ("schema", "requested_workers", "workers",
                                                      "available_cpus", "reason")},
                         {"schema": 1, "requested_workers": 2, "workers": 2, "available_cpus": 4, "reason": ""})

    def test_cpu_ceiling_and_narrow_affinity_have_distinct_budgets(self):
        with mock.patch.object(platforms.os, "cpu_count", return_value=32), \
                mock.patch.object(history, "process_cpus", return_value=1):
            self.assertEqual(history.available_cpus(), 8)
            with self.run_context(workers=None) as run:
                self.assertEqual(run.workers, 1)
                status = history.status(self.host)
                self.assertEqual((status["available_cpus"], status["reserved_workers"]), (8, 1))
            with self.assertRaisesRegex(history.RunHistoryError, "worker budget"):
                with self.run_context(workers=2):
                    self.fail("request exceeded the launch's visible CPUs")
        with mock.patch.object(platforms.os, "cpu_count", return_value=2):
            self.assertEqual(history.available_cpus(), 2)

    def test_resource_adjustment_preserves_launch_and_changes_accounting(self):
        process, info = self.holder(workers=2)
        with mock.patch.object(history, "available_cpus", return_value=2):
            before, = self.records()
            event = history.adjust_resources(self.host, info["run_id"], 1,
                                             platforms.CPU_LIMIT_REASON, cpu_affinity=[7])
            self.assertEqual(event["previous_effective_reserved_workers"], 2)
            record, = self.records()
            self.assertEqual(record["workers"], 2)
            self.assertEqual(record["command"], before["command"])
            self.assertEqual(record["events"][0], before["events"][0])
            self.assertEqual(record["effective_reserved_workers"], 1)
            self.assertEqual(record["effective_cpu_affinity"], [7])
            self.assertEqual(record["effective_resource_reason"], platforms.CPU_LIMIT_REASON)
            with self.run_context(resources=[], workers=None) as run:
                self.assertEqual(run.workers, 1)
                self.assertEqual(history.status(self.host)["reserved_workers"], 2)
                with self.assertRaisesRegex(history.RunHistoryError, "worker budget"):
                    history.adjust_resources(self.host, info["run_id"], 2,
                                             platforms.CPU_LIMIT_REASON, cpu_affinity=[6, 7])
        self.release(process)
        with self.assertRaisesRegex(history.RunHistoryError, "active run"):
            history.adjust_resources(self.host, info["run_id"], 1, platforms.CPU_LIMIT_REASON)

    @unittest.skipUnless(hasattr(os, "sched_getaffinity"), "requires Linux affinity")
    def test_active_worker_grants_prefer_disjoint_allowed_affinities(self):
        # Simulate eight allowed CPUs without consuming other live runs' CPUs.
        with mock.patch.object(history, "available_cpus", return_value=8), \
                mock.patch.object(os, "sched_getaffinity", return_value=set(range(8))), \
                mock.patch.object(os, "sched_setaffinity"):
            with self.run_context(resources=[], workers=4,
                                  resource_reason=platforms.CPU_LIMIT_REASON) as first:
                with self.run_context(resources=[], workers=4) as second:
                    self.assertEqual(first.record["cpu_affinity"], [0, 1, 2, 3])
                    self.assertEqual(second.record["cpu_affinity"], [4, 5, 6, 7])
                    self.assertEqual(history.status(self.host)["reserved_workers"], 8)
                with mock.patch.object(os, "sched_getaffinity", return_value={0, 1}), \
                        mock.patch.object(history, "process_cpus", return_value=2):
                    with self.run_context(resources=[], workers=2) as forced:
                        self.assertEqual(forced.record["cpu_affinity"], [0, 1])

    @unittest.skipUnless(hasattr(os, "sched_getaffinity"), "requires Linux affinity")
    def test_affinity_covers_existing_threads_and_inherited_children(self):
        original = os.sched_getaffinity(0)
        ready, release = threading.Event(), threading.Event()
        thread = threading.Thread(target=lambda: (ready.set(), release.wait(timeout=10)))
        thread.start()
        self.addCleanup(lambda: (release.set(), thread.join(timeout=10)))
        self.assertTrue(ready.wait(timeout=5))
        with self.run_context(workers=1, resource_reason=platforms.CPU_LIMIT_REASON) as run:
            selected = set(run.record["cpu_affinity"])
            self.assertEqual(len(selected), 1)
            self.assertLessEqual(selected, original)
            for task in Path("/proc/self/task").iterdir():
                self.assertEqual(os.sched_getaffinity(int(task.name)), selected)
            result = subprocess.run([sys.executable, "-c",
                                     "import json,os; print(json.dumps(sorted(os.sched_getaffinity(0))))"],
                                    check=True, text=True, capture_output=True)
            self.assertEqual(set(json.loads(result.stdout)), selected)
        self.assertEqual(os.sched_getaffinity(0), original)

    def test_automatic_grant_reduced_by_reservations_needs_no_reason(self):
        process, info = self.holder(workers=1)
        with mock.patch.object(history, "available_cpus", return_value=2):
            with self.run_context(resources=[], workers=None) as automatic:
                self.assertEqual(automatic.workers, 1)
            with self.run_context(resources=[], workers=1) as explicit:
                self.assertEqual(explicit.workers, 1)
            self.release(process)
            with self.assertRaisesRegex(history.RunHistoryError, "--resource-reason: workers 1 < 2$"):
                with self.run_context(resources=[], workers=1):
                    self.fail("released reservation still excused a reduction")
        records = {record["run_id"]: record for record in self.records()}
        self.assertEqual(len(records), 3)
        self.assertEqual(records[info["run_id"]]["resource_reductions"], ["workers"])
        for run, requested in ((automatic, None), (explicit, 1)):
            record = records[run.run_id]
            self.assertEqual(record["allocation"],
                             {"workers": {"requested": requested, "automatic": 1, "actual": 1}})
            self.assertEqual((record["resource_reductions"], record["resource_reason"],
                              record["available_cpus"]), ([], "", 2))

    def test_full_requests_queries_and_oversubscription_keep_their_behaviour(self):
        with mock.patch.object(history, "available_cpus", return_value=4):
            for workers, actual in ((None, 4), (4, 4), (0, 0)):
                with self.subTest(workers=workers), self.run_context(workers=workers) as run:
                    self.assertEqual(run.workers, actual)
            with self.assertRaisesRegex(history.RunHistoryError, "worker budget"):
                with self.run_context(workers=5):
                    self.fail("oversubscribed")
            with self.run_context(workers=4, resource_reason="nothing is reduced"):
                pass
        records = self.records()
        self.assertEqual([record["allocation"]["workers"] for record in records],
                         [{"requested": None, "automatic": 4, "actual": 4},
                          {"requested": 4, "automatic": 4, "actual": 4},
                          {"requested": 0, "automatic": 4, "actual": 0},
                          {"requested": 4, "automatic": 4, "actual": 4}])
        self.assertEqual([record["resource_reductions"] for record in records], [[], [], [], []])
        self.assertEqual([record["resource_reason"] for record in records], ["", "", "", "nothing is reduced"])

    def test_caller_allocation_is_checked_and_recorded_with_workers(self):
        self.assertEqual(history.deliberate_reductions({
            "missing": {}, "automatic": {"requested": None, "automatic": 4},
            "unbounded": {"requested": 2, "automatic": None}, "query": {"requested": 0, "automatic": 4},
            "equal": {"requested": 4, "automatic": 4}, "above": {"requested": 5, "automatic": 4},
            "z": {"requested": 1, "automatic": 2}, "a": {"requested": 3, "automatic": 4}}), ["a", "z"])
        threads = {"requested": 2, "automatic": 4, "actual": 2}
        memory = {"requested": 2048, "automatic": None, "actual": 2048}
        with mock.patch.object(history, "available_cpus", return_value=4):
            with self.assertRaisesRegex(history.RunHistoryError, r"--resource-reason: threads 2 < 4$"):
                with self.run_context(workers=None, allocation={"threads": threads}):
                    self.fail("thread reduction lacked a reason")
            with self.assertRaisesRegex(history.RunHistoryError,
                                        r"--resource-reason: threads 2 < 4, workers 3 < 4$"):
                with self.run_context(workers=3, allocation={"threads": threads}):
                    self.fail("two reductions lacked a reason")
            caller = {"threads": dict(threads), "memory_mb": dict(memory)}
            reduced = self.run_context(workers=3, allocation=caller, resource_reason="audit shares this host")
            caller["threads"]["actual"] = 99
            with reduced:
                pass
            for allocation in ({"threads": {"requested": None, "automatic": 4, "actual": 4}},
                               {"threads": {"requested": 6, "automatic": 4, "actual": 6}},
                               {"memory_mb": memory}):
                with self.subTest(allocation=allocation), self.run_context(workers=None, allocation=allocation):
                    pass
        with self.assertRaisesRegex(history.RunHistoryError, "workers"):
            self.run_context(allocation={"workers": {"requested": 1, "automatic": 4, "actual": 1}})
        records = self.records()
        self.assertEqual(records[0]["allocation"], {"threads": threads, "memory_mb": memory,
                                                    "workers": {"requested": 3, "automatic": 4, "actual": 3}})
        self.assertEqual(records[0]["resource_reductions"], ["threads", "workers"])
        self.assertEqual(records[0]["resource_reason"], "audit shares this host")
        self.assertEqual([record["resource_reductions"] for record in records[1:]], [[], [], []])
        self.assertEqual(len(records), 4)

    def test_resource_fields_stay_outside_run_identity_and_success_guard(self):
        reduced = dict(workers=2, resource_reason="another resource reason")
        with mock.patch.object(history, "available_cpus", return_value=4):
            with self.run_context(expensive=True, workers=2, resource_reason="audit shares this host"):
                pass
            for options in ({}, {"allocation": {"threads": {"requested": None, "automatic": 4, "actual": 4}}}):
                with self.subTest(options=options), self.assertRaisesRegex(
                        history.RunHistoryError, "identical expensive run already succeeded"):
                    with self.run_context(expensive=True, **reduced, **options):
                        self.fail("a resource-only change waived the success guard")
            with self.run_context(expensive=True, reason="measure at two workers", **reduced):
                pass
            with self.assertRaisesRegex(history.RunHistoryError, "identical expensive run already succeeded"):
                with self.run_context(**reduced) as duplicate:
                    duplicate.prepare({"source": "a"}, expensive=True)
            with self.run_context(reason="measure at two workers", **reduced) as repeated:
                repeated.prepare({"source": "a"}, expensive=True)
        records = self.records()
        self.assertEqual([record["state"] for record in records], ["success", "success", "failure", "success"])
        identity = json.dumps(dict(kind="prove", inputs={"source": "a"}, workers=2),
                              sort_keys=True, separators=(",", ":"))
        self.assertEqual({record["fingerprint"] for record in records},
                         {hashlib.sha256(identity.encode()).hexdigest()})

    def test_allocation_report_names_requested_actual_and_reason(self):
        unbounded = {"requested": None, "automatic": None, "actual": None}
        expected = [
            (dict(workers=None), "workers requested=automatic actual=4 automatic=4"),
            (dict(workers=2, resource_reason="GNATprove audit shares this host",
                  allocation={"threads": {"requested": 1, "automatic": 4, "actual": 1}, "memory_mb": unbounded}),
             "threads requested=1 actual=1 automatic=4; workers requested=2 actual=2 automatic=4; "
             "deliberate reduction: threads, workers; reason: GNATprove audit shares this host"),
            (dict(workers=None, resource_reason="  ",
                  allocation={"memory_mb": {"requested": 2048, "automatic": None, "actual": 2048}}),
             "memory_mb requested=2048 actual=2048; workers requested=automatic actual=4 automatic=4"),
            (dict(workers=0), "workers requested=0 actual=0 automatic=4"),
        ]
        with mock.patch.object(history, "available_cpus", return_value=4):
            for options, line in expected:
                with self.subTest(options=options), self.run_context(**options) as run:
                    self.assertEqual(history.allocation_report(run.record), "Resource allocation: " + line)
        self.assertEqual(history.allocation_report({}), "Resource allocation: not recorded")

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

    def test_unresolved_obligations_are_available_before_a_tool_exits_successfully(self):
        report = self.root / "unit.spark"
        failed = {"file": "unit.adb", "line": 1, "col": 1, "rule": "VC_RANGE_CHECK",
                  "severity": "medium", "how_proved": "unproved"}
        report.write_text(json.dumps({"proof": [failed]}))
        with self.run_context(failure_reports=[report]) as run:
            self.assertEqual(run.unresolved_obligations(), [])
            report.write_text(json.dumps({"proof": [dict(failed, line=2)]}))
            self.assertEqual(run.unresolved_obligations(), ["unit.adb:2:1:VC_RANGE_CHECK"])
            run.finish("failure", returncode=0)
        self.assertEqual(self.records()[0]["state"], "failure")
        self.assertEqual(self.records()[0]["finish"]["failure_keys"], ["unit.adb:2:1:VC_RANGE_CHECK"])
        with self.run_context(failure_keys=["explicit-key"]) as explicit:
            self.assertEqual(explicit.unresolved_obligations(), ["explicit-key"])

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
            required = history.status(self.host)["diagnostics_required"]
            self.assertEqual(bool(required), value == 2)
        self.assertEqual(required, [{"task": "issue39", "kind": "prove", "scope": "prove",
                                    "run_id": run_id,
                                    "failure_counts": {"unit.adb:1:1:VC_RANGE_CHECK": 3}}])
        self.assertEqual(history.status(self.host, "another-task")["diagnostics_required"], [])
        with self.assertRaisesRegex(history.RunHistoryError, "diagnostic"):
            with self.run_context(inputs={"source": "another edit"}):
                self.fail("fourth unchanged obligation attempt")
        history.diagnose(self.host, run_id, "guard is absent from VC context", "inspect generated VC")
        self.assertEqual(history.status(self.host)["diagnostics_required"], [])
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

    @staticmethod
    def spark_body(*checks, file="unit.adb"):
        """Shape failed checks as GNATprove does: leading-space entity keys, an entity per record."""
        entities, numbers, proof = {}, {}, []
        for helper, line, rule in checks:
            record = {"file": file, "line": line, "col": 3, "rule": rule,
                      "severity": "medium", "how_proved": "prover"}
            if helper is not None:
                number = numbers.setdefault(helper, len(numbers) + 1)
                entities[f" {number}"] = {"name": helper, "sloc": [{"file": file, "line": 2, "column": 14}]}
                record["entity"] = number
            proof.append(record)
        return {"entities": entities, "proof": proof}

    def fail_helper(self, scope, *checks, task="issue39"):
        """Record one failed tool-gnatprove attempt whose report is new to that run."""
        reports = self.root / "reports"
        with self.run_context(kind="tool-gnatprove", task=task, inputs={"scope": scope},
                              failure_reports=[reports]) as run:
            report = reports / run.run_id / "unit.spark"
            report.parent.mkdir(parents=True)
            report.write_text(json.dumps(self.spark_body(*checks)))
            run.finish("failure", returncode=1)
        return run.run_id

    def test_helper_names_come_from_report_metadata_and_exact_keys_are_unchanged(self):
        identity = "Unit.Helper:VC_RANGE_CHECK"

        def located(*lines):
            return [f"unit.adb:{line}:3:VC_RANGE_CHECK" for line in lines]

        # Expected lists are in sorted string order; five keys under one identity
        # make an unsorted set order fail on almost every hash seed.
        keys = located(11, 13, 2, 4, 6, 9)
        named = {identity: located(11, 13, 2, 4, 9)}
        body = self.spark_body(*[("Unit.Helper", line, "VC_RANGE_CHECK") for line in (9, 4, 13, 2, 11)],
                               (None, 6, "VC_RANGE_CHECK"), ("Unit.Helper", 7, "VC_RANGE_CHECK"))
        body["proof"][-1]["severity"] = "info"

        def result(rule, kind, line):
            return {"ruleId": rule, "kind": kind, "locations": [{
                "physicalLocation": {"artifactLocation": {"uri": "unit.adb"},
                                     "region": {"startLine": line, "startColumn": 3}},
                "logicalLocations": [{"name": "Unit.Helper"}, {"name": "Unit"}]}]}

        sarif = {"runs": [{"results": [
            result("VC_RANGE_CHECK", "open", 9), result("VC_RANGE_CHECK", "fail", 4),
            result("VC_RANGE_CHECK", "pass", 7), result("VC_RANGE_CHECK", "informational", 8),
            result("INITIALIZED", "open", 5)]}]}

        def write(directory):
            directory.mkdir(parents=True)
            (directory / "unit.spark").write_text(json.dumps(body))
            (directory / "gnatprove.sarif").write_text(json.dumps(sarif))

        reports = self.root / "metadata"
        write(reports)
        self.assertEqual(history.failed_obligations([reports / "unit.spark"]), keys)
        self.assertEqual(history.failed_identities([reports / "unit.spark"]), named)
        self.assertEqual(history.failed_obligations([reports / "gnatprove.sarif"]), located(4, 9))
        self.assertEqual(history.failed_identities([reports / "gnatprove.sarif"]), {identity: located(4, 9)})
        self.assertEqual(history.failed_obligations([reports]), keys)
        self.assertEqual(history.failed_identities([reports]), named)

        with self.run_context(kind="tool-gnatprove", failure_reports=[self.root / "failed"]) as run:
            write(self.root / "failed")
            run.finish("failure", returncode=0)
        with self.run_context(kind="tool-gnatprove", task="issue40", failure_reports=[self.root / "proved"]):
            write(self.root / "proved")
        self.fail_obligation(task="issue41")
        with self.run_context(task="issue42", failure_keys=["unit.adb:2:2:VC_RANGE_CHECK"]) as run:
            run.finish("failure", returncode=1)
        failed, succeeded, explicit, constructed = (record["finish"] for record in self.records())
        self.assertEqual((failed["failure_keys"], failed["failure_identities"]), (keys, named))
        self.assertEqual((succeeded["failure_keys"], succeeded["failure_identities"]), ([], {}))
        self.assertEqual((explicit["failure_keys"], explicit["failure_identities"]),
                         (["unit.adb:1:1:VC_RANGE_CHECK"], {}))
        self.assertEqual((constructed["failure_keys"], constructed["failure_identities"]),
                         (["unit.adb:2:2:VC_RANGE_CHECK"], {}))

    def test_missing_or_malformed_helper_metadata_yields_exact_keys_only(self):
        named = self.spark_body(("Unit.Helper", 9, "VC_RANGE_CHECK"))
        entity, record = named["entities"][" 1"], named["proof"][0]
        spark = {
            "no entities": {"proof": [record]},
            "entities not a dict": {"entities": [entity], "proof": [record]},
            "number absent": {"entities": {" 2": entity}, "proof": [record]},
            "entity a string": dict(named, proof=[dict(record, entity="1")]),
            # The table holds both spellings a bool could be read as, so only rejecting it gives no name.
            "entity a bool": dict(named, entities={" 1": entity, " True": entity},
                                  proof=[dict(record, entity=True)]),
            "entry not a dict": dict(named, entities={" 1": "Unit.Helper"}),
            "name empty": dict(named, entities={" 1": dict(entity, name="")}),
            "name not a string": dict(named, entities={" 1": dict(entity, name=["Unit", "Helper"])}),
        }
        location = {"physicalLocation": {"artifactLocation": {"uri": "unit.adb"},
                                         "region": {"startLine": 9, "startColumn": 3}}}
        sarif = {
            "no logicalLocations": location,
            "logicalLocations empty": dict(location, logicalLocations=[]),
            "logicalLocations not a list": dict(location, logicalLocations={"name": "Unit.Helper"}),
            "entry not a dict": dict(location, logicalLocations=["Unit.Helper"]),
            "entry unnamed": dict(location, logicalLocations=[{"kind": "function"}]),
            "name empty": dict(location, logicalLocations=[{"name": ""}]),
        }
        reports = {name: (self.root / "unit.spark", body) for name, body in spark.items()}
        reports.update({"sarif " + name: (self.root / "gnatprove.sarif", {"runs": [{"results": [
            {"ruleId": "VC_RANGE_CHECK", "kind": "open", "locations": [variant]}]}]})
            for name, variant in sarif.items()})
        for name, (report, body) in reports.items():
            with self.subTest(report=name):
                report.write_text(json.dumps(body))
                self.assertEqual(history.failed_obligations([report]), ["unit.adb:9:3:VC_RANGE_CHECK"])
                self.assertEqual(history.failed_identities([report]), {})
        unfiled = {key: value for key, value in record.items() if key != "file"}
        (self.root / "unit.spark").write_text(json.dumps(dict(named, proof=[unfiled])))
        (self.root / "gnatprove.sarif").write_text(json.dumps({"runs": [{"results": [
            {"ruleId": "VC_RANGE_CHECK", "kind": "open", "locations": [{
                "physicalLocation": {"artifactLocation": {}, "region": {"startLine": 9, "startColumn": 3}},
                "logicalLocations": [{"name": "Unit.Helper"}]}]}]}]}))
        for report in (self.root / "unit.spark", self.root / "gnatprove.sarif"):
            with self.subTest(unfiled=report.name):
                self.assertEqual(history.failed_obligations([report]), [])
                self.assertEqual(history.failed_identities([report]), {})

    def test_moved_line_is_one_helper_recurrence_and_reports_exact_locations(self):
        identity = "Unit.Helper:VC_RANGE_CHECK"
        scope = ["mode:all", "project:unit.gpr", "unit.adb"]
        attempts = ([9], [10, 11], [12])
        for index, lines in enumerate(attempts):
            run_id = self.fail_helper(scope, *[("Unit.Helper", line, "VC_RANGE_CHECK") for line in lines])
            required = history.status(self.host)["diagnostics_required"]
            self.assertEqual(bool(required), index == 2)
        keys = [[f"unit.adb:{line}:3:VC_RANGE_CHECK" for line in lines] for lines in attempts]
        locations = sorted(key for run_keys in keys for key in run_keys)
        self.assertEqual(required, [{"task": "issue39", "kind": "tool-gnatprove", "scope": scope,
                                     "run_id": run_id, "failure_counts": {identity: 3},
                                     "failure_locations": {identity: locations}}])
        self.assertEqual([record["finish"]["failure_keys"] for record in self.records()], keys)
        with self.assertRaisesRegex(history.RunHistoryError, "diagnostic") as refused:
            with self.run_context(kind="tool-gnatprove", inputs={"scope": scope}):
                self.fail("fourth attempt at a moved line")
        for text in (identity, *locations):
            self.assertIn(text, str(refused.exception))
        self.assertEqual(len(self.records()), 3)

    def test_selector_path_changes_are_one_helper_recurrence(self):
        identity = "Unit.Helper:VC_RANGE_CHECK"
        scopes = (["mode:all", "project:unit.gpr", "--limit-subp=unit.adb:3", "unit.adb"],
                  ["mode:all", "--limit-subp=unit.adb:5", "project:unit.gpr", "unit.adb"],
                  ["mode:all", "project:unit.gpr", "unit.adb", "--limit-name=Helper"])
        for line, scope in zip((3, 5, 7), scopes):
            run_id = self.fail_helper(scope, ("Unit.Helper", line, "VC_RANGE_CHECK"))
        entry, = history.status(self.host)["diagnostics_required"]
        self.assertEqual((entry["run_id"], entry["scope"], entry["failure_counts"]),
                         (run_id, scopes[2], {identity: 3}))
        for scope in (["mode:all", "project:unit.gpr", "--limit-line=unit.adb:14", "unit.adb"],
                      ["mode:all", "project:unit.gpr", "unit.adb"]):
            with self.subTest(scope=scope), self.assertRaisesRegex(history.RunHistoryError, "diagnostic"):
                with self.run_context(kind="tool-gnatprove", inputs={"scope": scope}):
                    self.fail("a pending helper's family started")
        self.assertEqual(len(self.records()), 3)
        with self.assertRaisesRegex(history.RunHistoryError, "diagnostic"):
            with self.run_context(kind="tool-gnatprove", inputs={"scope": ["mode:all", "project:other.gpr"]}) as run:
                run.prepare({"scope": ["mode:all", "project:unit.gpr", "--limit-subp=unit.adb:9", "unit.adb"]})
                self.fail("a prepared scope bypassed the pending helper's family")
        refused = self.records()[-1]
        self.assertEqual(refused["state"], "failure")
        self.assertEqual((refused["finish"]["failure_keys"], refused["finish"]["failure_identities"]), ([], {}))

    def test_unrelated_helpers_and_targets_are_separate_recurrences(self):
        scope = ["mode:all", "project:unit.gpr", "unit.adb"]
        for line, helper, rule in ((1, "Unit.First", "VC_RANGE_CHECK"), (2, "Unit.Second", "VC_RANGE_CHECK"),
                                   (3, "Unit.First", "VC_RANGE_CHECK"), (4, "Unit.First", "VC_OVERFLOW_CHECK")):
            self.fail_helper(scope, (helper, line, rule))
        self.assertEqual(history.status(self.host)["diagnostics_required"], [])
        self.fail_helper(scope, ("Unit.First", 5, "VC_RANGE_CHECK"))
        self.assertEqual([entry["failure_counts"] for entry in history.status(self.host)["diagnostics_required"]],
                         [{"Unit.First:VC_RANGE_CHECK": 3}])
        with self.assertRaisesRegex(history.RunHistoryError, "diagnostic") as refused:
            with self.run_context(kind="tool-gnatprove", inputs={"scope": scope}):
                self.fail("a pending helper started")
        self.assertIn("Unit.First:VC_RANGE_CHECK", str(refused.exception))
        self.assertNotIn("Unit.Second", str(refused.exception))
        self.assertNotIn("VC_OVERFLOW_CHECK", str(refused.exception))
        for options in ({"inputs": {"scope": ["mode:all", "project:other.gpr", "unit.adb"]}},
                        {"inputs": {"scope": ["mode:flow", "project:unit.gpr", "unit.adb"]}},
                        {"inputs": {"scope": ["mode:all", "project:unit.gpr", "other.adb"]}},
                        {"inputs": {"scope": [*scope, 7]}},
                        {"inputs": {"scope": scope}, "task": "issue40"},
                        {"inputs": {"scope": scope}, "kind": "tool-gprbuild"}):
            with self.subTest(options=options):
                with self.run_context(**{"kind": "tool-gnatprove", **options}) as run:
                    self.assertTrue(run.run_id)
        for project in ("first.gpr", "second.gpr", "third.gpr"):
            self.fail_helper(["mode:all", f"project:{project}"], ("Main", 4, "VC_RANGE_CHECK"), task="issue41")
        self.assertEqual(history.status(self.host, "issue41")["diagnostics_required"], [])

    def test_failures_without_helper_metadata_still_count_by_exact_key_only(self):
        scope = ["mode:all", "project:unit.gpr", "unit.adb"]
        for line in (1, 2, 3):
            self.fail_helper(scope, (None, line, "VC_RANGE_CHECK"))
        self.assertEqual(history.status(self.host)["diagnostics_required"], [])
        with self.run_context(kind="tool-gnatprove", inputs={"scope": scope}) as run:
            self.assertTrue(run.run_id)
        for line in (1, 2, 3):
            with self.run_context(kind="lean", task="issue40", inputs={"scope": "complete"}) as run:
                run.finish("failure", returncode=1,
                           failure_keys=[f"lean:build:Silver/Proof.lean:{line}:5:unsolved goals"])
        self.assertEqual(history.status(self.host, "issue40")["diagnostics_required"], [])
        with self.run_context(kind="lean", task="issue40", inputs={"scope": "complete"}) as run:
            self.assertTrue(run.run_id)

    def test_only_a_covering_success_resolves_a_helper_recurrence(self):
        identity = "Unit.Helper:VC_RANGE_CHECK"
        base = ["mode:all", "project:unit.gpr", "unit.adb"]
        first, moved = [*base, "--limit-name=Helper"], [*base, "--limit-subp=unit.adb:7"]

        def replay(task, *attempts):
            """Fail at the given line, or succeed when the line is None, in each scope in turn."""
            for scope, line in attempts:
                if line is None:
                    with self.run_context(kind="tool-gnatprove", task=task, inputs={"scope": scope}):
                        pass
                else:
                    self.fail_helper(scope, ("Unit.Helper", line, "VC_RANGE_CHECK"), task=task)
            return history.status(self.host, task)["diagnostics_required"]

        other = [*base, "--limit-name=Other"]
        pending = replay("a", (first, 1), (first, 2), (other, None), (moved, 3))
        self.assertEqual([entry["failure_counts"] for entry in pending], [{identity: 3}])
        self.assertEqual(replay("b", (first, 1), (first, 2), (first, None), (first, 3), (moved, 4)), [])
        self.assertEqual(replay("c", (moved, 1), (first, 2), (base, None), (first, 3), (moved, 4)), [])
        entry, = replay("d", (first, 1), (base, None), (moved, 2), (moved, 3), (first, None), (moved, 4))
        self.assertEqual(entry["failure_counts"], {identity: 3})
        self.assertEqual(entry["failure_locations"],
                         {identity: [f"unit.adb:{line}:3:VC_RANGE_CHECK" for line in (2, 3, 4)]})
        pending.append(entry)
        # A success in an earlier failed scope covers the helper, not only one in the latest.
        self.assertEqual(replay("e", (first, 1), (moved, 2), (first, None), (moved, 3), (moved, 4)), [])

        # An interrupted run, even with no limit selector, neither records nor clears anything.
        replay("f", (first, 1), (moved, 2))
        reports = self.root / "reports"
        with self.assertRaises(KeyboardInterrupt):
            with self.run_context(kind="tool-gnatprove", task="f", inputs={"scope": base},
                                  failure_reports=[reports]) as run:
                report = reports / run.run_id / "unit.spark"
                report.parent.mkdir(parents=True)
                report.write_text(json.dumps(self.spark_body(("Unit.Helper", 5, "VC_RANGE_CHECK"))))
                raise KeyboardInterrupt()
        interrupted = history.status(self.host, "f")["runs"][-1]
        self.assertEqual((interrupted["state"], interrupted["finish"]["failure_keys"],
                          interrupted["finish"]["failure_identities"]), ("interrupted", [], {}))
        entry, = replay("f", (first, 3))
        self.assertEqual((entry["failure_counts"], entry["failure_locations"]),
                         ({identity: 3}, {identity: [f"unit.adb:{line}:3:VC_RANGE_CHECK" for line in (1, 2, 3)]}))
        pending.append(entry)

        # Unfiltered, each task's pending family has its own entry, in the order the families first appear.
        self.assertEqual(history.status(self.host)["diagnostics_required"], pending)

    def test_diagnosis_resets_helper_recurrence_and_attempts_stay_unlimited(self):
        identity = "Unit.Helper:VC_RANGE_CHECK"
        scope = ["mode:all", "project:unit.gpr", "--limit-subp=unit.adb:3", "unit.adb"]
        for line in (1, 2, 3):
            self.fail_helper(scope, ("Unit.Helper", line, "VC_RANGE_CHECK"))
        entry, = history.status(self.host)["diagnostics_required"]
        for summary, next_step in ((" ", "inspect the generated VC"), ("bound is lost at the call", "")):
            with self.subTest(summary=summary, next_step=next_step):
                with self.assertRaisesRegex(history.RunHistoryError, "summary and next step"):
                    history.diagnose(self.host, entry["run_id"], summary, next_step)
        self.assertEqual(history.status(self.host)["diagnostics_required"], [entry])
        history.diagnose(self.host, entry["run_id"], "bound is lost at the call", "state it in the precondition")
        self.assertEqual(history.status(self.host)["diagnostics_required"], [])
        for line in (4, 5, 6):
            self.fail_helper(scope, ("Unit.Helper", line, "VC_RANGE_CHECK"))
            required = history.status(self.host)["diagnostics_required"]
            self.assertEqual(bool(required), line == 6)
        self.assertEqual((required[0]["failure_counts"], required[0]["failure_locations"]),
                         ({identity: 3}, {identity: [f"unit.adb:{line}:3:VC_RANGE_CHECK" for line in (4, 5, 6)]}))
        self.assertEqual(len(self.records()), 6)

    def test_records_without_helper_metadata_field_are_read_as_before(self):
        scope = ["mode:all", "project:unit.gpr", "unit.adb"]
        key = "unit.adb:9:3:VC_RANGE_CHECK"

        def rewrite(run_id, change):
            journal = history.registry(self.host) / "runs" / run_id / "events.jsonl"
            events = [json.loads(line) for line in journal.read_text().splitlines()]
            for event in events:
                if event["event"] == "finished":
                    change(event)
            journal.write_text("".join(json.dumps(event) + "\n" for event in events))

        def older(event):
            event.pop("failure_identities", None)

        def entry(task, run_id):
            return {"task": task, "kind": "tool-gnatprove", "scope": scope, "run_id": run_id,
                    "failure_counts": {key: 3}}

        runs = [self.fail_helper(scope, ("Unit.Helper", 9, "VC_RANGE_CHECK")) for _ in range(3)]
        for run_id in runs:
            rewrite(run_id, older)
        self.assertEqual(history.status(self.host)["diagnostics_required"], [entry("issue39", runs[-1])])
        with self.assertRaisesRegex(history.RunHistoryError, "diagnostic"):
            with self.run_context(kind="tool-gnatprove", inputs={"scope": scope}):
                self.fail("older records hid an exact recurrence")
        for _ in range(2):
            rewrite(self.fail_helper(scope, ("Unit.Helper", 9, "VC_RANGE_CHECK"), task="issue40"), older)
        latest = self.fail_helper(scope, ("Unit.Helper", 9, "VC_RANGE_CHECK"), task="issue40")
        self.assertEqual(history.status(self.host, "issue40")["diagnostics_required"], [entry("issue40", latest)])
        # Each shape fills three failed runs of its own task, so reading it as valid would reach the
        # boundary. None keeps the run's own valid field: beside an accepted [3], sorting would raise.
        identity = "Unit.Helper:VC_RANGE_CHECK"
        malformed = {
            "top-level list": [[identity]] * 3,
            "string value": [{identity: f"unit.adb:{line}:3:VC_RANGE_CHECK"} for line in (1, 2, 3)],
            "non-string in list": [{identity: [3]}] * 3,
            "empty list": [{identity: []}] * 3,
            "non-string beside a valid list": [{identity: [3]}, None, {identity: [3]}],
        }
        for task, shapes in malformed.items():
            with self.subTest(malformed=task):
                for line, shape in zip((1, 2, 3), shapes):
                    run_id = self.fail_helper(scope, ("Unit.Helper", line, "VC_RANGE_CHECK"), task=task)
                    if shape is not None:
                        rewrite(run_id, lambda event, shape=shape: event.update(failure_identities=shape))
                self.assertEqual(history.status(self.host, task)["diagnostics_required"], [])
                with self.run_context(kind="tool-gnatprove", task=task, inputs={"scope": scope}) as run:
                    self.assertTrue(run.run_id)

    def test_exact_key_reports_are_unchanged_beside_helper_reports(self):
        identity, key = "Unit.Helper:VC_RANGE_CHECK", "unit.adb:9:3:VC_RANGE_CHECK"
        scope = ["mode:all", "project:unit.gpr", "--limit-subp=unit.adb:3", "unit.adb"]
        for _ in range(3):
            run_id = self.fail_helper(scope, ("Unit.Helper", 9, "VC_RANGE_CHECK"))
        common = {"task": "issue39", "kind": "tool-gnatprove", "scope": scope, "run_id": run_id}
        self.assertEqual(history.status(self.host)["diagnostics_required"], [
            dict(common, failure_counts={key: 3}),
            dict(common, failure_counts={identity: 3}, failure_locations={identity: [key]})])
        with self.assertRaises(history.RunHistoryError) as refused:
            with self.run_context(kind="tool-gnatprove", inputs={"scope": scope}):
                self.fail("a pending recurrence started")
        compact = dict(sort_keys=True, separators=(",", ":"))
        self.assertEqual(str(refused.exception),
                         "repeated unresolved obligations need a diagnostic note before another run: "
                         + json.dumps({key: 3, identity: 3}, **compact)
                         + "; exact locations: " + json.dumps({identity: [key]}, **compact))
        history.diagnose(self.host, run_id, "bound is lost at the call", "state it in the precondition")
        self.assertEqual(history.status(self.host)["diagnostics_required"], [])

        task, base = "issue40", ["mode:all", "project:unit.gpr", "unit.adb"]
        first, moved = [*base, "--limit-name=Helper"], [*base, "--limit-subp=unit.adb:7"]
        for _ in range(2):
            self.fail_helper(first, ("Unit.Helper", 9, "VC_RANGE_CHECK"), task=task)
        with self.run_context(kind="tool-gnatprove", task=task, inputs={"scope": base}):
            pass
        exact_run = self.fail_helper(first, ("Unit.Helper", 9, "VC_RANGE_CHECK"), task=task)
        for line in (11, 12):
            helper_run = self.fail_helper(moved, ("Unit.Helper", line, "VC_RANGE_CHECK"), task=task)
        exact_entry = {"task": task, "kind": "tool-gnatprove", "scope": first, "run_id": exact_run,
                       "failure_counts": {key: 3}}
        self.assertEqual(history.status(self.host, task)["diagnostics_required"], [exact_entry, {
            "task": task, "kind": "tool-gnatprove", "scope": moved, "run_id": helper_run,
            "failure_counts": {identity: 3},
            "failure_locations": {identity: ["unit.adb:11:3:VC_RANGE_CHECK", "unit.adb:12:3:VC_RANGE_CHECK", key]}}])
        history.diagnose(self.host, helper_run, "selector moved with the helper", "inspect the loop invariant")
        self.assertEqual(history.status(self.host, task)["diagnostics_required"], [exact_entry])
        with self.assertRaisesRegex(history.RunHistoryError, "diagnostic"):
            with self.run_context(kind="tool-gnatprove", task=task, inputs={"scope": first}):
                self.fail("a helper note lifted the exact-key block")
        history.diagnose(self.host, exact_run, "guard is absent from the VC", "inspect the generated VC")
        self.assertEqual(history.status(self.host, task)["diagnostics_required"], [])


if __name__ == "__main__":
    unittest.main()

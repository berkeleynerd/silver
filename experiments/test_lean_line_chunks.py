"""Cheap scratch-harness invariants; these tests never execute Lean."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
from pathlib import Path
import signal
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location("lean_line_chunks", Path(__file__).with_name("lean_line_chunks.py"))
chunks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(chunks)


class LineChunksTests(unittest.TestCase):
    def test_exact_extraction_and_rejection(self):
        original = (chunks.ROOT / "proof/Silver/OutputBodyCertificate.lean").read_bytes()
        header, declarations, suffix = chunks.extract(original)
        self.assertEqual(len(declarations), 4915)
        self.assertEqual(header + b"".join(declarations) + suffix, original)
        for bad in [original.replace(b"noNewline := by decide +kernel", b"noNewline := by sorry", 1),
                    original.replace(b"outputBodyTokens_line_0 :", b"outputBodyTokens_line_9 :", 1)]:
            with self.assertRaises(ValueError):
                chunks.extract(bad)

    def test_prepared_full_suffix_and_micro_imports(self):
        output = chunks.DEFAULT_OUTPUT
        manifest = json.loads((output / "manifest.json").read_text())
        chunks.verify(output, manifest)
        original = (chunks.ROOT / "proof/Silver/OutputBodyCertificate.lean").read_bytes()
        header, declarations, suffix = chunks.extract(original)
        imports = b"".join(f"public import {module}\n".encode() for module in chunks.CHUNKS)
        self.assertEqual((output / "full/proof/Silver/OutputBodyCertificate.lean").read_bytes(),
                         header.replace(chunks.AUTHORITATIVE, chunks.AUTHORITATIVE + imports) + suffix)
        for kind in ["full", "micro"]:
            recovered = []
            for module in chunks.CHUNKS:
                data = (output / kind / "proof" / (module.replace(".", "/") + ".lean")).read_bytes()
                self.assertEqual(chunks.IMPORT.findall(data), [b"Silver.SourceLexer", b"Silver.CertificateWitness"])
                recovered.extend(m[0] for m in chunks.DECLARATION.finditer(data))
            indices = list(range(4915)) if kind == "full" else [i * 4914 // 511 for i in range(512)]
            self.assertEqual(recovered, [declarations[i] for i in indices])
        self.assertEqual(list(map(len, manifest["groups"]["micro"])), [128] * 4)
        self.assertEqual(manifest["groups"]["micro"][0][0], 0)
        self.assertEqual(manifest["groups"]["micro"][-1][-1], 4914)

    def test_force_rebuild_removes_all_candidate_sidecars_only(self):
        with tempfile.TemporaryDirectory() as name:
            output = Path(name)
            build = output / "micro/proof/.lake/build"
            candidates = []
            for directory in ["lib/lean/Silver", "ir/Silver"]:
                target = build / directory
                target.mkdir(parents=True)
                (target / "SourceLexer.olean").write_bytes(b"common")
                (target / "SourceLexer.trace").write_bytes(b"metadata-v1")
                for module in [*chunks.CHUNKS, chunks.MICRO_ROOT]:
                    for suffix in ["olean", "olean.private", "olean.server", "trace", "ir", "c", "setup.json"]:
                        path = target / (module.split(".")[-1] + "." + suffix)
                        path.write_bytes(b"candidate")
                        candidates.append(path)
            baseline = chunks.common_artifacts(output)
            self.assertEqual(len(chunks.force_candidate(output)), len(candidates))
            self.assertTrue(all(not p.exists() for p in candidates))
            self.assertEqual(chunks.common_artifacts(output), baseline)
            self.assertEqual(len(baseline), 2)
            for trace in build.rglob("SourceLexer.trace"):
                trace.write_bytes(b"legitimate-metadata-rewrite")
            self.assertEqual(chunks.common_artifacts(output), baseline)
            next(build.rglob("SourceLexer.olean")).write_bytes(b"changed-object")
            self.assertNotEqual(chunks.common_artifacts(output), baseline)

    def test_context_excludes_own_run_but_counts_actual_reservation(self):
        runs = [dict(run_id="own", task="#8", workers=4, active=True),
                dict(run_id="production", task="#delivery", workers=8, active=True),
                dict(run_id="finished", task="#other", workers=1, active=False)]
        with patch.object(chunks, "status", return_value=dict(available_cpus=12, reserved_workers=12, runs=runs)), \
                patch.object(chunks, "host_sample", return_value={"available_bytes": 30 * 1024**3}):
            context = chunks.capacity("own")
        self.assertEqual(context["free_workers"], 0)
        self.assertEqual(context["other_active_runs"], [dict(run_id="production", task="#delivery", workers=8)])

    def test_low_ram_stops_only_experiment_and_records_interrupted(self):
        run = Mock(pass_fds=())
        # The direct child is already exited; its group still has a descendant.
        process = Mock(pid=424242, returncode=0)
        process.poll.return_value = 0
        sample = dict(available_bytes=7 * 1024**3, group_rss_bytes=1024,
                      process_group=process.pid, pids=[424243])
        with tempfile.TemporaryDirectory() as name:
            evidence = Path(name)
            with patch.object(chunks.subprocess, "Popen", return_value=process), \
                    patch.object(chunks, "host_sample", return_value={"available_bytes": 20 * 1024**3}), \
                    patch.object(chunks, "group_sample", return_value=sample), \
                    patch.object(chunks.os, "killpg") as kill:
                with self.assertRaises(chunks.ExperimentPressureInterrupt) as caught:
                    chunks.execute(["unused"], Path("unused"), evidence, 4, run)
            kill.assert_called_once_with(process.pid, signal.SIGKILL)
            process.wait.assert_called_once_with()
            self.assertEqual(json.loads((evidence / "interruption.json").read_text())["threshold_bytes"], 8 * 1024**3)
            self.assertEqual(json.loads((evidence / "result.json").read_text())["outcome"], "interrupted")
            self.assertTrue((evidence / "samples.jsonl").read_text())
            self.assertTrue(any(c.args[0] == "pressure-interruption" for c in run.event.call_args_list))
        # Exercise the actual ManagedRun terminal classification without registry writes.
        managed = object.__new__(chunks.ManagedRun)
        managed._lease = None
        managed.finish = Mock()
        managed.__exit__(type(caught.exception), caught.exception, None)
        self.assertEqual(managed.finish.call_args.args[0], "interrupted")

    def test_cpu_deltas_wrap_direct_child_without_time_wrapper(self):
        run = Mock(pass_fds=())
        process = Mock(pid=424242, returncode=0)
        process.poll.return_value = 0
        sample = dict(available_bytes=30 * 1024**3, group_rss_bytes=1234, process_group=process.pid)
        before = SimpleNamespace(ru_utime=10.0, ru_stime=2.0, ru_maxrss=999999)
        after = SimpleNamespace(ru_utime=12.5, ru_stime=3.5, ru_maxrss=999999)
        with tempfile.TemporaryDirectory() as name:
            evidence = Path(name)
            with patch.object(chunks.subprocess, "Popen", return_value=process) as spawn, \
                    patch.object(chunks.subprocess, "check_output", side_effect=AssertionError("other child tool")), \
                    patch.object(chunks, "host_sample", return_value={"available_bytes": 30 * 1024**3}), \
                    patch.object(chunks, "group_sample", return_value=sample), \
                    patch.object(chunks.resource, "getrusage", side_effect=[before, after]) as usage:
                result = chunks.execute(["direct-lake"], Path("unused"), evidence, 4, run)
            self.assertEqual(spawn.call_args.args[0], ["direct-lake"])
            self.assertEqual([c.args for c in usage.call_args_list], [(chunks.resource.RUSAGE_CHILDREN,)] * 2)
            self.assertEqual(result["user_cpu_seconds"], 2.5)
            self.assertEqual(result["system_cpu_seconds"], 1.5)
            self.assertEqual(result["sampled_peak_group_rss_bytes"], 1234)
            self.assertNotIn("max_individual_rss_bytes", result)
            self.assertNotIn("ru_maxrss", result)
            self.assertFalse((evidence / "time.txt").exists())
            self.assertEqual(json.loads((evidence / "result.json").read_text()), result)

    def test_queue_holds_no_reservation_before_both_gates(self):
        calls = []

        class FakeRun:
            def __init__(self, *args, **kwargs):
                calls.append(("reservation", kwargs["workers"]))

            def __enter__(self):
                return self

            def event(self, *args, **kwargs):
                pass

            def __exit__(self, *args):
                calls.append(("release",))

        observations = [dict(free_workers=0, available_bytes=30 * 1024**3),
                        dict(free_workers=4, available_bytes=7 * 1024**3),
                        dict(free_workers=4, available_bytes=30 * 1024**3)]
        with patch.object(chunks, "capacity", side_effect=observations), \
                patch.object(chunks, "ManagedRun", FakeRun), \
                patch.object(chunks.time, "sleep", side_effect=lambda seconds: calls.append(("wait", seconds))), \
                redirect_stdout(io.StringIO()):
            with chunks.acquire(Path("unused"), 1, {}, ["unused"], 20):
                calls.append(("entered",))
        self.assertEqual(calls, [("wait", 30), ("wait", 30), ("reservation", 1), ("entered",), ("release",)])

    def test_dry_run_never_spawns_tool(self):
        with patch.object(chunks.sys, "argv", ["lean_line_chunks.py", "--dry-run"]), \
                patch.object(chunks.subprocess, "Popen", side_effect=AssertionError("tool launch")), \
                patch.object(chunks, "capacity", return_value={"free_workers": 0}), \
                redirect_stdout(io.StringIO()) as capture:
            chunks.main()
        self.assertTrue(json.loads(capture.getvalue())["no_lean_launch"])


if __name__ == "__main__":
    unittest.main()

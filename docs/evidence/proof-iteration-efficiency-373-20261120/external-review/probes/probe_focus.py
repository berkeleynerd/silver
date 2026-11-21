"""Reviewer probes for the focused native entry point, using the target's own test fixture.

The fixture (tests/test_dev_runs.DevRunTests) builds a throwaway repository in a temporary
directory and mocks the native tool, so nothing here touches the worktree, ledger or tools.
Each probe prints what the target does; assertions only pin the behaviour reported in the
review so a changed result is visible.

Usage: python3 -B probes/probe_focus.py <worktree>
"""
from __future__ import annotations

import json
from pathlib import Path
import sys
import unittest
from unittest import mock

worktree = Path(sys.argv[1]).resolve()
sys.path.insert(0, str(worktree))

from scripts import dev, run_history  # noqa: E402
from scripts.check_evidence import EvidenceError  # noqa: E402
from tests.test_dev_runs import DevRunTests  # noqa: E402


class FocusProbes(DevRunTests):
    def report_path(self, name="main.spark"):
        return dev.focused_workspace(self.host.compiler / "obj") / "gnatprove" / name

    def mutated(self, change=None, *, sarif=None, **fixture):
        def produce(host, command, **options):
            self.focused_output(host, command, **fixture)
            if change:
                path = self.report_path()
                report = json.loads(path.read_text())
                change(report)
                path.write_text(json.dumps(report))
            if sarif:
                path = self.report_path("gnatprove.sarif")
                document = json.loads(path.read_text())
                sarif(document)
                path.write_text(json.dumps(document))
        return mock.patch.object(dev, "invoke", side_effect=produce)

    # ---- 1. every acceptance condition of check_report fails closed
    def probe_report_conditions_fail_closed(self):
        flow_warning = {"rule": "INEFFECTIVE", "severity": "warning", "how_proved": "flow",
                        "file": "main.adb", "line": 4, "col": 1, "entity": 1}
        cases = {
            "flow analysis only": lambda r: r.__setitem__("progress", "PROGRESS_FLOW"),
            "progress missing": lambda r: r.pop("progress"),
            "stopped early": lambda r: r.__setitem__("stop_reason", "STOP_REASON_ERROR_MARKING"),
            "skip_proof nonempty": lambda r: r["skip_proof"].append(1),
            "skip_flow_proof nonempty": lambda r: r["skip_flow_proof"].append(1),
            "pragma_assume nonempty": lambda r: r["pragma_assume"].append({"file": "main.adb"}),
            "skip_proof missing": lambda r: r.pop("skip_proof"),
            "coverage missing": lambda r: r.pop("spark"),
            "entities missing": lambda r: r.pop("entities"),
            "flow list missing": lambda r: r.pop("flow"),
            "flow record is a warning": lambda r: r["flow"].append(flow_warning),
            "proved check carries a justification": lambda r: r["proof"][0].__setitem__("justification", "reviewed"),
            "proved check is suppressed": lambda r: r["proof"][0].__setitem__("suppressed", "x"),
            "check proved by review": lambda r: r["proof"][0].__setitem__("how_proved", "review"),
            "selected entity only spec": lambda r: r["spark"].__setitem__(" 1", "spec"),
        }
        sarif_cases = {
            "exit code nonzero": lambda d: d["runs"][0]["invocations"][0].__setitem__("exitCode", 1),
            "execution unsuccessful": lambda d: d["runs"][0]["invocations"][0].__setitem__("executionSuccessful", False),
            "other command line": lambda d: d["runs"][0]["invocations"][0].__setitem__(
                "commandLine", d["runs"][0]["invocations"][0]["commandLine"].replace("--timeout=30", "--timeout=60")),
            "two invocations": lambda d: d["runs"][0]["invocations"].append(d["runs"][0]["invocations"][0]),
            "two runs": lambda d: d["runs"].append(d["runs"][0]),
            "no invocation": lambda d: d["runs"][0].__setitem__("invocations", []),
        }
        outcomes = {}
        for selection in (["--subprogram", "main.adb:3"], ["--unit", "main.adb"]):
            for label, change in cases.items():
                with self.mutated(change):
                    try:
                        self.main(["prove", *selection])
                        outcomes[(selection[0], label)] = "ACCEPTED"
                    except (EvidenceError, RuntimeError) as error:
                        outcomes[(selection[0], label)] = f"{type(error).__name__}: {error}"
                self.assertEqual(self.records()[-1]["state"], "failure", (selection, label))
                self.assertNotIn("focused_report", self.records()[-1]["finish"])
            for label, change in sarif_cases.items():
                with self.mutated(sarif=change):
                    try:
                        self.main(["prove", *selection])
                        outcomes[(selection[0], "sarif " + label)] = "ACCEPTED"
                    except (EvidenceError, RuntimeError) as error:
                        outcomes[(selection[0], "sarif " + label)] = f"{type(error).__name__}: {error}"
                self.assertEqual(self.records()[-1]["state"], "failure", (selection, label))
        for key, value in outcomes.items():
            print(f"   {key[0]:13} {key[1]:40} -> {value[:95]}")
        self.assertNotIn("ACCEPTED", outcomes.values())

    # ---- 2. source drift during a focused run
    def probe_source_edit_during_focused_run_is_rejected(self):
        def produce(host, command, **options):
            self.focused_output(host, command)
            (self.root / "src/main.adb").write_text("edited while GNATprove ran\n")
        with mock.patch.object(dev, "invoke", side_effect=produce):
            with self.assertRaisesRegex(RuntimeError, "run inputs changed during execution"):
                self.main(["prove", "--subprogram", "main.adb:3"])
        record = self.records()[-1]
        print("   state:", record["state"], "| focused_report recorded:", "focused_report" in record["finish"])
        self.assertEqual(record["state"], "failure")

    # ---- 3. a selection that emits no checks is reported as a success with zero counts
    def probe_zero_check_selection_is_a_success(self):
        with self.mutated(lambda r: r.__setitem__("proof", [])):
            self.main(["prove", "--subprogram", "main.adb:3"])
        finish = self.records()[-1]["finish"]
        print("   focused_report:", finish["focused_report"])
        self.assertEqual(finish["focused_report"]["proof_checks"], 0)

    # ---- 4. spec and body spellings of one unit
    def probe_unit_spellings_split_recurrence(self):
        (self.root / "src/main.ads").write_text("fixture package specification")
        commands = []

        def failing(host, command, **options):
            commands.append(command)
            self.focused_output(host, command, unproved=True)

        attempts = ["main.ads", "main.adb", "main.ads", "main.adb"]
        with mock.patch.object(dev, "invoke", side_effect=failing):
            for name in attempts:
                with self.assertRaisesRegex(RuntimeError, "unresolved proof obligations"):
                    self.main(["prove", "--unit", name])
            # A fifth attempt is still admitted: neither spelling reached three.
            with self.assertRaisesRegex(RuntimeError, "unresolved proof obligations"):
                self.main(["prove", "--unit", "main.adb"])
            # The body spelling now has three and is held; the spec spelling is not.
            with self.assertRaisesRegex(run_history.RunHistoryError, "diagnostic"):
                self.main(["prove", "--unit", "main.adb"])
            with self.assertRaisesRegex(RuntimeError, "unresolved proof obligations"):
                self.main(["prove", "--unit", "main.ads"])
        selectors = {tuple(command[command.index("-u"):command.index("-u") + 2]) for command in commands}
        records = self.records()
        print("   effective selectors:", selectors)
        print("   recorded scopes:", sorted({json.dumps(r["scope"]) for r in records}))
        print("   failed attempts on the same helper before any hold:", 5,
              "| identities:", records[0]["finish"]["failure_identities"])
        self.assertEqual(selectors, {("-u", "main.adb")})

    # ---- 5. subprogram selected by its body line (entity is reported at its declaration)
    def probe_body_line_selection_is_rejected(self):
        (self.root / "src/main.ads").write_text("fixture package specification")

        def declared_in_spec(report):
            report["entities"][" 1"]["sloc"] = [{"file": "main.ads", "line": 2}]

        with self.mutated(declared_in_spec, declaration=7):
            try:
                self.main(["prove", "--subprogram", "main.adb:7"])
                result = "ACCEPTED"
            except EvidenceError as error:
                result = str(error)
        print("   body-line selection of a spec-declared subprogram ->", result)
        with self.mutated(declared_in_spec, declaration=7):
            self.main(["prove", "--subprogram", "main.ads:2"])
        print("   declaration-line selection -> success:", self.records()[-1]["finish"]["focused_report"])

    # ---- 6. documented conservative holds, confirmed through the CLI
    def probe_family_holds(self):
        (self.root / "src/main.ads").write_text("fixture package specification")
        for line in (3, 6, 9):
            with mock.patch.object(dev, "invoke", side_effect=lambda host, cmd, **kw:
                                   self.focused_output(host, cmd, declaration=line, unproved=True)):
                with self.assertRaisesRegex(RuntimeError, "unresolved proof obligations"):
                    self.main(["prove", "--subprogram", f"main.adb:{line}", "--task", "t1"])
        held = {}
        with self.simulated_proof() as invoke:
            for label, arguments in (("plain prove", ["prove"]), ("prove --full", ["prove", "--full"]),
                                     ("--unit main.adb", ["prove", "--unit", "main.adb"]),
                                     ("build", ["build"]), ("other task", ["prove", "--task", "t2"])):
                try:
                    self.main([*arguments] if "--task" in arguments else [*arguments, "--task", "t1"])
                    held[label] = "started"
                except run_history.RunHistoryError as error:
                    held[label] = "held: " + str(error)[:60]
                except (EvidenceError, RuntimeError) as error:
                    held[label] = "started (fixture: " + type(error).__name__ + ")"
        for label, value in held.items():
            print(f"   after three --subprogram failures, {label:16} -> {value}")
        self.assertTrue(held["plain prove"].startswith("held"))
        self.assertTrue(held["prove --full"].startswith("held"))
        self.assertFalse(held["--unit main.adb"].startswith("held"))

    def probe_unit_success_does_not_clear_subprogram_failures(self):
        for line in (3, 6):
            with mock.patch.object(dev, "invoke", side_effect=lambda host, cmd, **kw:
                                   self.focused_output(host, cmd, declaration=line, unproved=True)):
                with self.assertRaisesRegex(RuntimeError, "unresolved proof obligations"):
                    self.main(["prove", "--subprogram", f"main.adb:{line}"])
        with mock.patch.object(dev, "invoke", side_effect=self.focused_output):
            self.main(["prove", "--unit", "main.adb"])          # containing unit now proves
        with mock.patch.object(dev, "invoke", side_effect=lambda host, cmd, **kw:
                               self.focused_output(host, cmd, declaration=9)):
            self.main(["prove", "--subprogram", "main.adb:9"])  # helper proves at its moved line
        with mock.patch.object(dev, "invoke", side_effect=lambda host, cmd, **kw:
                               self.focused_output(host, cmd, declaration=12, unproved=True)):
            with self.assertRaisesRegex(RuntimeError, "unresolved proof obligations"):
                self.main(["prove", "--subprogram", "main.adb:12"])
        try:
            with mock.patch.object(dev, "invoke", side_effect=lambda host, cmd, **kw:
                                   self.focused_output(host, cmd, declaration=12)):
                self.main(["prove", "--subprogram", "main.adb:12"])
            result = "started"
        except run_history.RunHistoryError as error:
            result = "held: " + str(error)[:110]
        print("   two failures, containing-unit success, moved-line success, one later failure ->", result)

    # ---- 7. selector spellings a developer might type
    def probe_selector_spellings(self):
        results = {}
        with mock.patch.object(dev, "invoke", side_effect=self.focused_output) as invoke:
            for arguments in (["--unit", "src/main.adb"], ["--unit", "Main.adb"], ["--unit", "main"],
                              ["--subprogram", "main.adb"], ["--subprogram", "src/main.adb:3"],
                              ["--unit", "main.adb", "--jobs", "4"], ["--unit", "main.adb", "--", "-j4"]):
                try:
                    self.main(["prove", *arguments])
                    results[" ".join(arguments)] = "ran"
                except (EvidenceError, RuntimeError) as error:
                    results[" ".join(arguments)] = f"{type(error).__name__}: {error}"
        for key, value in results.items():
            print(f"   prove {key:32} -> {value[:90]}")
        print("   records created by refused spellings:",
              sum(1 for record in self.records() if record["state"] != "success"))


if __name__ == "__main__":
    names = [name for name in dir(FocusProbes) if name.startswith("probe_")]
    failures = 0
    for name in names:
        print(f"== {name} ==")
        result = unittest.TestResult()
        FocusProbes(name).run(result)
        for _, trace in result.errors + result.failures:
            failures += 1
            print("   PROBE DID NOT BEHAVE AS RECORDED:\n" + trace)
    print("probe methods:", len(names), "| not as recorded:", failures)
    sys.exit(1 if failures else 0)

"""Source-specific runtime report policy, exercised by the native SPARK code."""
from __future__ import annotations

import copy
import json
from itertools import product
from pathlib import Path
import subprocess
import tempfile
import unittest

from scripts.platforms import alire_command, native_layout, tool_environment

ROOT = Path(__file__).resolve().parents[1]


def entity(name: str) -> dict:
    package = name.split('.')[0]
    filename = {'Silver_IO': 'silver_io.ads', 'Silver_Output_Libc': 'silver_output_libc.ads',
                'Silver_Arguments': 'silver_arguments.ads', 'Silver_Runtime': 'silver_runtime.ads'}[package]
    if name == 'Silver_Arguments.Is_Message':
        filename = 'silver_arguments.adb'
    return {"name": name, "sloc": [{"file": filename, "line": 1, "column": 1}]}


def report(interface: bool = False) -> dict:
    names = (["Silver_Output_Libc", "Silver_Output_Libc.Put_Byte",
              "Silver_Output_Libc.Flush", "Silver_Output_Libc.Set_Exit_Status"] if interface else
             ["Silver_IO.Put_Line", "Silver_IO", "Silver_Output_Libc.Set_Exit_Status",
              "Silver_Output_Libc.Flush", "Silver_Output_Libc.Put_Byte"])
    return {"entities": {f" {i}": entity(name) for i, name in enumerate(names, 1)},
            "spark": ({" 1": "all", " 2": "spec", " 3": "spec", " 4": "spec"}
                      if interface else {" 1": "all", " 2": "all"}),
            "progress": "PROGRESS_PROOF", "stop_reason": "STOP_REASON_NONE",
            "flow": [] if interface else [dict(check(), how_proved="flow")],
            "proof": [] if interface else [check()], "skip_flow_proof": [], "skip_proof": [],
            "pragma_assume": [], "warn_error": [], "assumptions": []}


def check() -> dict:
    return {"severity": "info", "how_proved": "prover", "entity": 1,
            "rule": "VC_POSTCONDITION", "file": "silver_io.adb", "line": 12, "col": 3,
            "message": {"text": 'postcondition proved, escaped "quote", {nested}'}}


def argument_report(interface: bool = False) -> dict:
    names = (["Silver_Runtime", "Silver_Runtime.Argument_Count", "Silver_Runtime.Argument",
              "Silver_Runtime.Set_Exit_Status"] if interface else
             ["Silver_Arguments.First_Or_Default", "Silver_Arguments", "Silver_Arguments.Input_Is_Valid",
              "Silver_Arguments.Reject", "Silver_Arguments.Is_Message", "Silver_Runtime.Argument_Count",
              "Silver_Runtime.Argument", "Silver_Output_Libc.Set_Exit_Status"])
    obligation = dict(check(), file="silver_arguments.adb")
    return {"entities": {f" {i}": entity(name) for i, name in enumerate(names, 1)},
            "spark": ({" 1": "all", " 2": "spec", " 3": "spec", " 4": "spec"} if interface else
                      {f" {i}": "all" for i in range(1, 6)}),
            "progress": "PROGRESS_PROOF", "stop_reason": "STOP_REASON_NONE",
            "flow": [] if interface else [dict(obligation, how_proved="flow")],
            "proof": [] if interface else [obligation], "skip_flow_proof": [], "skip_proof": [],
            "pragma_assume": [], "warn_error": [], "assumptions": []}


def main_report(count: int = 2) -> dict:
    names = ["Main", "Silver_Arguments.First_Or_Default", "Silver_Arguments.Input_Is_Valid",
             "Silver_Arguments.Reject", "Silver_IO.Put_Line"]
    data = report(True)
    data["entities"] = {f" {i}": ({"name": name, "sloc": [
        {"file": "main.adb", "line": 1, "column": 1}]} if name == "Main" else entity(name))
        for i, name in enumerate(names, 1)}
    data["spark"] = {" 1": "all"}
    data["proof"] = [dict(check(), rule="VC_RANGE_CHECK", file="main.adb") for _ in range(count)]
    data["assumptions"] = [{"claim": {"predicate": "CLAIM_AORTE", "arg": 1},
        "assumptions": [{"predicate": "CLAIM_POST", "arg": 2},
                        {"predicate": "CLAIM_EFFECTS", "arg": 3}]}]
    return data


def assignment_report(warning: bool = True) -> dict:
    data = main_report(0)
    data["entities"] = {" 1": data["entities"][" 1"]}
    data["assumptions"] = []
    data["flow"] = ([dict(check(), severity="warning", how_proved="flow",
                         rule="INEFFECTIVE", file="main.adb",
                         message={"text": 'initialization of "Message" has no effect'})]
                    if warning else [])
    return data


def assignment_call_report() -> dict:
    data = assignment_report(False)
    data["entities"][" 2"] = entity("Silver_IO.Put_Line")
    data["assumptions"] = [{"claim": {"arg": 1, "predicate": "CLAIM_EFFECTS"},
                             "assumptions": [{"arg": 2, "predicate": "CLAIM_EFFECTS"}]}]
    return data


class LibraryReportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.temp = tempfile.TemporaryDirectory(prefix="silver-library-reports-")
        cls.directory = Path(cls.temp.name)
        host = native_layout()
        (cls.directory / "probe.gpr").write_text(f'''project Probe is
   for Source_Dirs use ("{ROOT / 'src'}", "{ROOT / 'tests'}");
   for Source_Files use ("library_reports_probe.adb", "silver_library_reports.ads",
                         "silver_library_reports.adb");
   for Object_Dir use "obj";
   for Exec_Dir use ".";
   for Main use ("library_reports_probe.adb");
   package Compiler is
      for Default_Switches ("Ada") use ("-gnat2022", "-gnata", "-gnato");
   end Compiler;
end Probe;
''')
        result = subprocess.run(alire_command(host, "exec", "--", "gprbuild", "-P",
                                             cls.directory / "probe.gpr", "-j2"),
                                cwd=host.context, env=tool_environment(host),
                                capture_output=True, text=True, timeout=120)
        if result.returncode:
            raise AssertionError(result.stdout + result.stderr)

    @classmethod
    def tearDownClass(cls) -> None:
        cls.temp.cleanup()

    def accepts(self, value: dict | str, interface: bool = False, *, kind: str | None = None) -> bool:
        source = value if isinstance(value, str) else json.dumps(value)
        result = subprocess.run([self.directory / "library_reports_probe",
                                 kind if kind else "interface" if interface else "body"],
                                input=source + "\n", capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(result.stdout, ("accepted\n", "rejected\n"))
        return result.stdout == "accepted\n"

    def test_main_complete_reports_and_optimized_empty_checks(self) -> None:
        for count in (0, 1, 2, 9):
            with self.subTest(count=count):
                self.assertTrue(self.accepts(main_report(count), kind="main"))
                self.assertFalse(self.accepts(main_report(count), kind="body"))
        self.assertFalse(self.accepts(report(), kind="main"))

    def test_main_entity_preserves_admitted_procedure_casing(self) -> None:
        for letters in product(*[(c.lower(), c.upper()) for c in "main"]):
            data = main_report()
            data["entities"][" 1"]["name"] = "".join(letters)
            self.assertTrue(self.accepts(data, kind="main"))
        for name in ("Mai", "Maine", "Main ", " Main", "Maix", "Other.Main"):
            data = main_report()
            data["entities"][" 1"]["name"] = name
            self.assertFalse(self.accepts(data, kind="main"))

    def test_large_main_report_erases_recursive_ghost_models(self) -> None:
        # At -gnata the Static models must still be absent from execution.
        # This traverses enough bytes to expose accidentally executable ghost
        # recursion, while staying inside the documented report domain.
        data = main_report(120)
        self.assertGreater(len(json.dumps(data)), 20_000)
        self.assertLess(len(json.dumps(data)), 262_144)
        self.assertTrue(self.accepts(data, kind="main"))

    def test_main_failed_records_and_unapproved_obligations(self) -> None:
        for section in ("flow", "proof"):
            for field, value in (("severity", "low"), ("severity", "warning"),
                                 ("how_proved", "unknown"), ("how_proved", "flow"),
                                 ("rule", "VC_PRECONDITION"), ("rule", ""),
                                 ("file", "silver_io.adb"), ("entity", 2),
                                 ("entity", 99), ("line", 0), ("col", 0)):
                data = main_report(1)
                data[section] = [dict(data["proof"][0], **{field: value})]
                with self.subTest(section=section, field=field, value=value):
                    self.assertFalse(self.accepts(data, kind="main"))
            for field in ("justification", "justified", "suppressed", "annot_kind", "justif_msg"):
                data = main_report(1)
                data[section] = [dict(data["proof"][0], **{field: False})]
                self.assertFalse(self.accepts(data, kind="main"))

    def test_main_exact_coverage_dependencies_and_completion(self) -> None:
        for field in ("skip_flow_proof", "skip_proof", "pragma_assume", "warn_error"):
            data = main_report()
            data[field] = [{}]
            self.assertFalse(self.accepts(data, kind="main"))
        for field, value in (("spark", {}), ("spark", {" 1": "spec"}),
                             ("spark", {" 1": "all", " 2": "spec"}),
                             ("progress", "PROGRESS_FLOW"), ("stop_reason", "STOP_REASON_ERROR")):
            data = main_report()
            data[field] = value
            self.assertFalse(self.accepts(data, kind="main"))
        for key in (" 1", " 2", " 3", " 4", " 5"):
            data = main_report()
            del data["entities"][key]
            self.assertFalse(self.accepts(data, kind="main"))
        for predicate in ("CLAIM_ASSUME", "CLAIM_PRE", "UNKNOWN"):
            data = main_report()
            data["assumptions"][0]["assumptions"][0]["predicate"] = predicate
            self.assertFalse(self.accepts(data, kind="main"))

    def test_assignment_advisory_is_separate_from_required_checks(self) -> None:
        for warning in (False, True):
            data = assignment_report(warning)
            self.assertTrue(self.accepts(data, kind="assignment"))
            for wrong in ("body", "interface", "arguments", "runtime"):
                self.assertFalse(self.accepts(data, kind=wrong))
        for name in ("Message", "M", "Main", "Name_2_A", "Silver_Arguments", "X" * 1300):
            data = assignment_report()
            data["flow"][0]["message"]["text"] = f'initialization of "{name}" has no effect'
            self.assertTrue(self.accepts(data, kind="assignment"))
        for name in ("main", "mAiN", "MAIN"):
            data = assignment_report()
            data["entities"][" 1"]["name"] = name
            self.assertTrue(self.accepts(data, kind="assignment"))

    def test_assignment_rejects_other_diagnostics_and_proof_records(self) -> None:
        changes = (("severity", "info"), ("severity", "low"), ("severity", "high"),
                   ("how_proved", "prover"), ("how_proved", "unknown"),
                   ("rule", "UNINITIALIZED"), ("rule", "VC_LENGTH_CHECK"),
                   ("file", "silver_io.adb"), ("entity", 2), ("entity", 0),
                   ("line", 0), ("col", 0), ("line", "1"))
        for field, value in changes:
            data = assignment_report()
            data["flow"][0][field] = value
            with self.subTest(field=field, value=value):
                self.assertFalse(self.accepts(data, kind="assignment"))
        for text in ('unused assignment ', 'unused assignment to "Message"',
                     'initialization of "" has no effect',
                     'initialization of "1Message" has no effect',
                     'initialization of "Message_" has no effect',
                     'initialization of "Message__2" has no effect',
                     'initialization of "' + 'X' * 4097 + '" has no effect',
                     'initialization of "Message" has no effect (suppressed)',
                     'initialization of "Message" has no effect\n'):
            data = assignment_report()
            data["flow"][0]["message"]["text"] = text
            self.assertFalse(self.accepts(data, kind="assignment"))
        for field in ("severity", "how_proved", "rule", "entity", "file", "line", "col", "message"):
            data = assignment_report()
            del data["flow"][0][field]
            self.assertFalse(self.accepts(data, kind="assignment"))
        for field in ("justification", "justified", "suppressed", "annot_kind", "justif_msg"):
            data = assignment_report()
            data["flow"][0][field] = False
            self.assertFalse(self.accepts(data, kind="assignment"))
        data = assignment_report()
        data["flow"] *= 2
        self.assertTrue(self.accepts(data, kind="assignment"))
        for rule in ("VC_LENGTH_CHECK", "VC_RANGE_CHECK", "INEFFECTIVE"):
            data = assignment_report()
            data["proof"] = [dict(check(), rule=rule, file="main.adb")]
            self.assertFalse(self.accepts(data, kind="assignment"))

    def test_assignment_requires_exact_coverage_and_completed_analysis(self) -> None:
        for field in ("skip_flow_proof", "skip_proof", "pragma_assume", "warn_error", "assumptions"):
            data = assignment_report()
            data[field] = [{}]
            self.assertFalse(self.accepts(data, kind="assignment"))
        for field, value in (("spark", {}), ("spark", {" 1": "spec"}),
                             ("spark", {" 1": "all", " 2": "all"}),
                             ("progress", "PROGRESS_FLOW"), ("stop_reason", "STOP_REASON_ERROR")):
            data = assignment_report()
            data[field] = value
            self.assertFalse(self.accepts(data, kind="assignment"))
        for field in ("flow", "proof", "entities", "spark", "progress", "stop_reason", "warn_error"):
            data = assignment_report()
            del data[field]
            self.assertFalse(self.accepts(data, kind="assignment"))
        for field, value in (("name", "Main2"), ("sloc", []),
                             ("sloc", [{"file": "other.adb", "line": 1, "column": 1}])):
            data = assignment_report()
            data["entities"][" 1"][field] = value
            self.assertFalse(self.accepts(data, kind="assignment"))
        data = assignment_report()
        data["entities"][" 2"] = entity("Silver_Arguments.Reject")
        self.assertFalse(self.accepts(data, kind="assignment"))
        source = json.dumps(assignment_report())
        for field in ("severity", "rule", "message"):
            value = assignment_report()["flow"][0][field]
            entry = f'"{field}": {json.dumps(value)}'
            self.assertFalse(self.accepts(source.replace(entry, entry + ", " + entry), kind="assignment"))

    def test_assignment_output_dependencies_have_approved_references(self) -> None:
        self.assertTrue(self.accepts(assignment_call_report(), kind="assignment"))
        for predicate in ("CLAIM_AORTE", "CLAIM_POST", "CLAIM_EFFECTS", "CLAIM_ASSUME", "UNKNOWN"):
            for where in ("claim", "assumptions"):
                data = assignment_call_report()
                reference = data["assumptions"][0][where]
                if isinstance(reference, list):
                    reference = reference[0]
                reference["predicate"] = predicate
                self.assertEqual(self.accepts(data, kind="assignment"),
                                 predicate in ("CLAIM_AORTE", "CLAIM_POST", "CLAIM_EFFECTS"))
        for where in ("claim", "assumptions"):
            for arg in (0, 3, -1, "1", True):
                data = assignment_call_report()
                reference = data["assumptions"][0][where]
                if isinstance(reference, list):
                    reference = reference[0]
                reference["arg"] = arg
                self.assertFalse(self.accepts(data, kind="assignment"))
        for modification in ("callee_coverage", "missing_callee", "location"):
            data = assignment_call_report()
            if modification == "callee_coverage":
                data["spark"][" 2"] = "all"
            elif modification == "missing_callee":
                del data["entities"][" 2"]
            else:
                data["entities"][" 2"]["sloc"][0]["file"] = "main.adb"
            self.assertFalse(self.accepts(data, kind="assignment"))
        data = assignment_call_report()
        data["entities"] = {" 8": data["entities"][" 2"], " 7": data["entities"][" 1"]}
        data["spark"] = {" 7": "all"}
        data["assumptions"][0]["claim"]["arg"] = 7
        data["assumptions"][0]["assumptions"][0]["arg"] = 8
        self.assertTrue(self.accepts(data, kind="assignment"))

    def test_composed_reports_select_entities_and_advisory_permission(self) -> None:
        for kind in ("static", "main", "assignment", "selected"):
            for count in (0, 1, 15, 30):
                for warning in (False, True):
                    data = (main_report(count) if kind in ("main", "selected") else
                            assignment_call_report())
                    data["proof"] = [dict(check(), rule="VC_RANGE_CHECK", file="main.adb")
                                     for _ in range(count)]
                    data["flow"] = assignment_report(warning)["flow"]
                    with self.subTest(kind=kind, count=count, warning=warning):
                        self.assertTrue(self.accepts(data, kind=kind))
                    for wrong in (("static", "assignment") if kind in ("main", "selected")
                                  else ("main", "selected")):
                        self.assertFalse(self.accepts(data, kind=wrong))
        for warning in (False, True):
            self.assertTrue(self.accepts(assignment_report(warning), kind="selected"))

    def test_composed_mutable_reports_reject_failed_ranges_and_other_advisories(self) -> None:
        for kind in ("assignment", "selected"):
            base = assignment_call_report() if kind == "assignment" else main_report(1)
            base["flow"] = assignment_report()["flow"]
            base["proof"] = [dict(check(), rule="VC_RANGE_CHECK", file="main.adb")]
            self.assertTrue(self.accepts(base, kind=kind))
            for field, value in (("severity", "low"), ("how_proved", "trivial"),
                                 ("rule", "VC_OVERFLOW_CHECK"), ("entity", 2),
                                 ("file", "silver_io.adb"), ("line", 0), ("col", 0),
                                 ("suppressed", False), ("justification", "approved")):
                data = copy.deepcopy(base)
                data["proof"][0][field] = value
                with self.subTest(kind=kind, field=field):
                    self.assertFalse(self.accepts(data, kind=kind))
            for text in ("unused assignment ", "statement has no effect "):
                data = copy.deepcopy(base)
                data["flow"][0]["message"]["text"] = text
                self.assertFalse(self.accepts(data, kind=kind))
            data = copy.deepcopy(base)
            data["flow"] *= 2
            self.assertTrue(self.accepts(data, kind=kind))
            for section in ("skip_flow_proof", "skip_proof", "pragma_assume", "warn_error"):
                data = copy.deepcopy(base)
                data[section] = [{}]
                self.assertFalse(self.accepts(data, kind=kind))
            for field in ("flow", "proof", "spark", "assumptions"):
                data = copy.deepcopy(base)
                del data[field]
                self.assertFalse(self.accepts(data, kind=kind))

    def test_shared_bindings_advisory_lists_and_assignment_scope(self) -> None:
        for kind in ("static", "main", "assignment", "selected"):
            for bare in (False, True):
                data = (assignment_report(False) if bare else
                        main_report(0) if kind in ("main", "selected") else assignment_call_report())
                advisory = assignment_report()["flow"][0]
                data["flow"] = [dict(advisory, message={
                    "text": f'initialization of "Value_{i}" has no effect'}) for i in range(268)]
                with self.subTest(kind=kind, bare=bare):
                    self.assertTrue(self.accepts(data, kind=kind))
                    data["flow"].append(dict(advisory, message={"text": "unused assignment"}))
                    self.assertEqual(self.accepts(data, kind=kind), kind in ("assignment", "selected"))
                for text in ('unused assignment ', 'unused assignment to "Value"',
                             '"Written_Count" is set by "Put_Line" but not used after the call',
                             '"Flushed" is set by "Put_Line" but not used after the call',
                             '"Succeeded" is set by "Put_Line" but not used after the call',
                             '"Written_Bytes" is set by "Put_Line" but not used after the call'):
                    data["flow"][-1]["message"]["text"] = text
                    self.assertFalse(self.accepts(data, kind=kind))

    def test_comparison_advisories_have_exact_route_and_message_policy(self) -> None:
        pairs = (("INEFFECTIVE", "statement has no effect"),
                 ("DEAD_CODE", "this statement is never reached"))
        mutations = (("severity", "info"), ("how_proved", "prover"),
                     ("file", "./main.adb"), ("entity", 2), ("line", 0), ("col", 0),
                     ("suppressed", False), ("justification", ""))
        for kind in ("static", "main", "assignment", "selected"):
            for bare in (False, True):
                for rule, message in pairs:
                    data = (assignment_report() if bare else
                            main_report(1) if kind in ("main", "selected") else assignment_call_report())
                    data["flow"] = [dict(assignment_report()["flow"][0],
                                         rule=rule, message={"text": message})]
                    with self.subTest(kind=kind, bare=bare, rule=rule):
                        self.assertEqual(self.accepts(data, kind=kind), kind in ("main", "selected"))
                    if kind not in ("main", "selected"):
                        continue
                    changes = (*mutations, ("message", {"text": message + " "}),
                               ("rule", "DEAD_CODE" if rule == "INEFFECTIVE" else "INEFFECTIVE"))
                    for field, value in changes:
                        changed = copy.deepcopy(data)
                        changed["flow"][0][field] = value
                        with self.subTest(kind=kind, bare=bare, rule=rule, field=field):
                            self.assertFalse(self.accepts(changed, kind=kind))
        for rule, message in pairs:
            data = report()
            data["flow"] = [dict(data["flow"][0], severity="warning", rule=rule,
                                 message={"text": message})]
            self.assertFalse(self.accepts(data))

    def test_nonassignment_bare_fallback_requires_an_advisory(self) -> None:
        for kind in ("static", "main"):
            self.assertFalse(self.accepts(assignment_report(False), kind=kind))
            self.assertTrue(self.accepts(assignment_report(True), kind=kind))

    def test_length_checks_have_the_same_complete_safety_policy(self) -> None:
        changes = (("severity", "warning"), ("severity", "low"),
                   ("how_proved", "flow"), ("how_proved", "trivial"),
                   ("rule", "VC_OVERFLOW_CHECK"), ("entity", 2),
                   ("file", "silver_io.adb"), ("line", 0), ("col", 0),
                   ("suppressed", False), ("justification", ""),
                   ("justified", False), ("annot_kind", ""), ("justif_msg", ""))
        for kind in ("static", "main", "assignment", "selected"):
            data = main_report(0) if kind in ("main", "selected") else assignment_call_report()
            data["proof"] = [dict(check(), rule="VC_LENGTH_CHECK", file="main.adb")]
            self.assertTrue(self.accepts(data, kind=kind))
            for field, value in changes:
                bad = copy.deepcopy(data)
                bad["proof"][0][field] = value
                with self.subTest(kind=kind, field=field, value=value):
                    self.assertFalse(self.accepts(bad, kind=kind))
            for field in ("severity", "how_proved", "rule", "file", "entity", "line", "col"):
                bad = copy.deepcopy(data)
                del bad["proof"][0][field]
                self.assertFalse(self.accepts(bad, kind=kind))
            bare = assignment_report(False)
            bare["proof"] = data["proof"]
            self.assertFalse(self.accepts(bare, kind=kind))

    def test_both_selected_schemas_and_wrong_kind(self) -> None:
        self.assertTrue(self.accepts(report()))
        self.assertTrue(self.accepts(report(True), True))
        self.assertFalse(self.accepts(report(True)))
        self.assertFalse(self.accepts(report(), True))

    def test_argument_schemas_and_coverage(self) -> None:
        for interface, kind in ((False, "arguments"), (True, "runtime")):
            data = argument_report(interface)
            self.assertTrue(self.accepts(data, kind=kind))
            for wrong in ("body", "interface", "runtime" if not interface else "arguments"):
                self.assertFalse(self.accepts(data, kind=wrong))
            for key in data["spark"]:
                bad = copy.deepcopy(data)
                del bad["spark"][key]
                self.assertFalse(self.accepts(bad, kind=kind))
                bad = copy.deepcopy(data)
                bad["spark"][key] = "no"
                self.assertFalse(self.accepts(bad, kind=kind))
            for key in data["entities"]:
                bad = copy.deepcopy(data)
                del bad["entities"][key]
                self.assertFalse(self.accepts(bad, kind=kind))
            for section in ("skip_proof", "pragma_assume", "warn_error"):
                bad = copy.deepcopy(data)
                bad[section] = [{}]
                self.assertFalse(self.accepts(bad, kind=kind))
        for section in ("proof", "flow"):
            for field, value in (("severity", "high"), ("how_proved", "unproved"), ("entity", 999)):
                bad = argument_report()
                bad[section][0][field] = value
                self.assertFalse(self.accepts(bad, kind="arguments"))
        bad = argument_report()
        bad["proof"][0]["rule"] = "VC_RANGE_CHECK"
        self.assertFalse(self.accepts(bad, kind="arguments"))

    def test_obligation_count_is_not_pinned(self) -> None:
        for count in (1, 3, 26):
            data = report()
            data["proof"] = [check() for _ in range(count)]
            data["flow"] = [dict(check(), how_proved="flow")]
            self.assertTrue(self.accepts(data))

    def test_argument_and_runtime_entity_locations_are_exact(self) -> None:
        for interface, kind in ((False, "arguments"), (True, "runtime")):
            baseline = argument_report(interface)
            for key, declaration in baseline["entities"].items():
                bad = copy.deepcopy(baseline)
                expected_file = declaration["sloc"][0]["file"]
                # Choose another selected source, so the check must enforce
                # the entity's own declaration file, not merely an allow-list.
                wrong_file = ("silver_arguments.adb" if expected_file != "silver_arguments.adb"
                              else "silver_arguments.ads")
                bad["entities"][key]["sloc"][0]["file"] = wrong_file
                with self.subTest(kind=kind, entity=declaration["name"]):
                    self.assertFalse(self.accepts(bad, kind=kind))

    def test_argument_postcondition_belongs_to_initializer(self) -> None:
        for key in (2, 3, 4, 5):
            bad = argument_report()
            bad["proof"][0]["entity"] = key
            with self.subTest(entity=key):
                self.assertFalse(self.accepts(bad, kind="arguments"))
        bad = argument_report()
        bad["proof"] = [dict(check(), file="silver_arguments.adb", entity=3),
                        dict(check(), file="silver_arguments.adb", entity=1, rule="VC_RANGE_CHECK")]
        self.assertFalse(self.accepts(bad, kind="arguments"))
        good = argument_report()
        good["proof"].append(dict(check(), file="silver_arguments.adb", entity=3,
                                  rule="VC_RANGE_CHECK"))
        self.assertTrue(self.accepts(good, kind="arguments"))

    def test_known_but_unselected_entities_are_rejected(self) -> None:
        cases = ((report(), "body", "Silver_Arguments.Reject"),
                 (report(True), "interface", "Silver_Arguments.Reject"),
                 (argument_report(), "arguments", "Silver_IO.Put_Line"),
                 (argument_report(True), "runtime", "Silver_IO.Put_Line"))
        for data, kind, extra in cases:
            data["entities"][" 99"] = entity(extra)
            with self.subTest(kind=kind, extra=extra):
                self.assertFalse(self.accepts(data, kind=kind))
        # The argument wrapper uses the output interface's returning setter.
        bad = argument_report()
        bad["entities"][" 8"] = entity("Silver_Runtime.Set_Exit_Status")
        self.assertFalse(self.accepts(bad, kind="arguments"))

    def test_every_record_is_audited(self) -> None:
        for field, value in (("severity", "warning"), ("how_proved", "unproved"),
                             ("how_proved", "justified"), ("entity", 999),
                             ("file", "other.adb"), ("line", "12"), ("col", 0)):
            for section in ("flow", "proof"):
                data = report()
                data[section] = [check(), dict(check(), **{field: value}), check()]
                with self.subTest(field=field, section=section):
                    self.assertFalse(self.accepts(data))

    def test_justification_and_suppression_rejected(self) -> None:
        for field in ("justification", "justified", "suppressed", "annot_kind", "justif_msg"):
            data = report()
            data["proof"] = [dict(check(), **{field: "reason"})]
            self.assertFalse(self.accepts(data))
            # A duplicate disallowed field must not look like an absent field.
            source = json.dumps(data).replace(f'"{field}": "reason"',
                                             f'"{field}": "reason", "{field}": "again"')
            self.assertFalse(self.accepts(source))

    def test_complete_analysis_and_empty_exclusions(self) -> None:
        for key in ("progress", "stop_reason", "flow", "proof", "entities", "spark",
                    "skip_flow_proof", "skip_proof", "pragma_assume", "warn_error", "assumptions"):
            data = report()
            del data[key]
            self.assertFalse(self.accepts(data), key)
        for key in ("skip_flow_proof", "skip_proof", "pragma_assume", "warn_error"):
            data = report()
            data[key] = [{}]
            self.assertFalse(self.accepts(data), key)
        for key, value in (("progress", "PROGRESS_FLOW"), ("stop_reason", "STOP_REASON_ERROR")):
            data = report()
            data[key] = value
            self.assertFalse(self.accepts(data), key)

    def test_owned_coverage_and_import_exceptions_are_exact(self) -> None:
        for interface in (False, True):
            for key in report(interface)["spark"]:
                data = report(interface)
                del data["spark"][key]
                self.assertFalse(self.accepts(data, interface))
                data = report(interface)
                data["spark"][key] = "no"
                self.assertFalse(self.accepts(data, interface))
            data = report(interface)
            data["entities"][" 1"]["name"] = "Other_Package"
            self.assertFalse(self.accepts(data, interface))
            data = report(interface)
            data["entities"][" 1"]["sloc"][0]["file"] = "other.ads"
            self.assertFalse(self.accepts(data, interface))
        data = report(True)
        data["spark"][" 2"] = "all"
        self.assertFalse(self.accepts(data, True))
        data = report()
        data["spark"][" 1"] = "spec"
        self.assertFalse(self.accepts(data))

    def test_entity_map_cannot_hide_extra_owned_declarations(self) -> None:
        data = report()
        data["entities"][" 6"] = entity("Silver_IO.Hidden_Helper")
        self.assertFalse(self.accepts(data))
        data["entities"][" 6"] = entity("Silver_IO.Put_Line")
        self.assertFalse(self.accepts(data))
        data = report()
        del data["entities"][" 5"]
        self.assertFalse(self.accepts(data))

    def test_entity_numbers_and_order_are_not_pinned(self) -> None:
        data = report()
        mapping = {key: str(90 - i) for i, key in enumerate(data["entities"])}
        data["entities"] = {mapping[key]: value for key, value in reversed(list(data["entities"].items()))}
        data["spark"] = {mapping[key]: value for key, value in reversed(list(data["spark"].items()))}
        for key in ("flow", "proof"):
            data[key][0]["entity"] = int(mapping[" 1"])
        self.assertTrue(self.accepts(data))

    def test_assumptions_resolve_only_selected_entities(self) -> None:
        data = report()
        data["assumptions"] = [{"claim": {"arg": 1, "predicate": "CLAIM_POST"},
                                "assumptions": [{"arg": 5, "predicate": "CLAIM_EFFECTS"}]}]
        self.assertTrue(self.accepts(data))
        for reference in ("claim", "assumptions"):
            for field, value in (("arg", 999), ("predicate", "CLAIM_OTHER")):
                bad = copy.deepcopy(data)
                target = bad["assumptions"][0][reference]
                if isinstance(target, list):
                    target = target[0]
                target[field] = value
                self.assertFalse(self.accepts(bad))
        bad = copy.deepcopy(data)
        bad["entities"][" 5"]["name"] = "Unapproved.Output"
        self.assertFalse(self.accepts(bad))

    def test_body_requires_checks_and_put_line_postcondition(self) -> None:
        for section in ("flow", "proof"):
            data = report()
            data[section] = []
            self.assertFalse(self.accepts(data))
        data = report()
        data["proof"][0]["rule"] = "VC_RANGE_CHECK"
        self.assertFalse(self.accepts(data))
        data = report()
        data["proof"][0]["entity"] = 2
        self.assertFalse(self.accepts(data))

    def test_nested_decoys_do_not_satisfy_fields(self) -> None:
        data = report()
        del data["progress"]
        data["timings"] = {"progress": "PROGRESS_PROOF"}
        self.assertFalse(self.accepts(data))
        data = report()
        data["proof"] = [dict(check(), severity="warning", stats={"severity": "info"})]
        self.assertFalse(self.accepts(data))

    def test_duplicate_required_fields_and_bad_delimiters(self) -> None:
        source = json.dumps(report())
        duplicate = source.replace('"progress": "PROGRESS_PROOF"',
                                   '"progress": "PROGRESS_PROOF", "progress": "PROGRESS_PROOF"')
        self.assertFalse(self.accepts(duplicate))
        for malformed in (source[:-1], source + " garbage", source.replace('"flow": [', '"flow": [}', 1),
                          source.replace('"proof": [', '"proof": [{},', 1), "", "[" * 65 + "]" * 65):
            with self.subTest(malformed=malformed[:80]):
                self.assertFalse(self.accepts(malformed))

    def test_report_bound(self) -> None:
        self.assertFalse(self.accepts(" " * 262_145))


if __name__ == "__main__":
    unittest.main()

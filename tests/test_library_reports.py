"""Source-specific runtime report policy, exercised by the native SPARK code."""
from __future__ import annotations

import copy
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from scripts.platforms import alire_command, native_layout, tool_environment

ROOT = Path(__file__).resolve().parents[1]


def entity(name: str) -> dict:
    return {"name": name, "sloc": [{"file": "silver_io.ads" if name.startswith("Silver_IO")
                                  else "silver_output_libc.ads", "line": 1, "column": 1}]}


def report(interface: bool = False) -> dict:
    names = (["Silver_Output_Libc", "Silver_Output_Libc.Put_Byte",
              "Silver_Output_Libc.Flush", "Silver_Output_Libc.Fail"] if interface else
             ["Silver_IO.Put_Line", "Silver_IO", "Silver_Output_Libc.Fail",
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

    def accepts(self, value: dict | str, interface: bool = False) -> bool:
        source = value if isinstance(value, str) else json.dumps(value)
        result = subprocess.run([self.directory / "library_reports_probe",
                                 "interface" if interface else "body"],
                                input=source + "\n", capture_output=True, text=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(result.stdout, ("accepted\n", "rejected\n"))
        return result.stdout == "accepted\n"

    def test_both_selected_schemas_and_wrong_kind(self) -> None:
        self.assertTrue(self.accepts(report()))
        self.assertTrue(self.accepts(report(True), True))
        self.assertFalse(self.accepts(report(True)))
        self.assertFalse(self.accepts(report(), True))

    def test_obligation_count_is_not_pinned(self) -> None:
        for count in (1, 3, 26):
            data = report()
            data["proof"] = [check() for _ in range(count)]
            data["flow"] = [dict(check(), how_proved="flow")]
            self.assertTrue(self.accepts(data))

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

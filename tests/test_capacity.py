"""Format-derived storage guards for the current producer's retained report."""
from __future__ import annotations

import json
from pathlib import Path
import re
import unittest

from tests.test_library_reports import assignment_call_report
from tests import test_silver

ROOT = Path(__file__).resolve().parents[1]
SOURCE_BYTES = 4096
NATURAL_MAX = 2_147_483_647
MAIN_RECORD_BYTES = 2048
FLOW_RECORD_BYTES = 1024
METADATA_BYTES = 65_536
ARRAY_NOTE_BYTES = 512


def dense_source() -> bytes:
    source = (b'with Silver_IO;procedure Main is pragma SPARK_Mode(On);'
              b'A:String:="";B:String:=A;begin Silver_IO.Put(B);'
              + b'A:=B&B;' * 63 + b'A:=B;' * 708 + b'end Main;')
    assert len(source) <= SOURCE_BYTES
    return source + b' ' * (SOURCE_BYTES - len(source))


def dense_mutable_source() -> tuple[bytes, int]:
    """Fill the source domain with static subtypes and overwritten initializers."""
    header = (b'with Silver_IO;procedure Main is pragma SPARK_Mode(On);'
              b'L:constant Integer:=0;H:constant Integer:=9;')
    footer = b"Silver_IO.Put_Line(Integer'Image(A0));end Main;"
    declarations = b''
    assignments = b''
    count = 0
    while True:
        name = f'A{count}'.encode()
        declaration = name + b':Integer range L..H:=0;'
        assignment = name + b':=H;'
        candidate = (header + declarations + declaration + b'begin '
                     + assignments + assignment + footer)
        if len(candidate) > SOURCE_BYTES:
            break
        declarations += declaration
        assignments += assignment
        count += 1
    source = header + declarations + b'begin ' + assignments + footer
    return source + b' ' * (SOURCE_BYTES - len(source)), count


def maximal_retained_record(*, flow: bool = False, runtime: bool = False) -> dict:
    # Natural-width coordinates account for tab-expanded columns and generated
    # message counters. Float32 stats fit within64 decimal bytes even using
    # fixed notation; a quoted64-byte placeholder strictly overcounts that.
    data = dict(check_tree={}, col=NATURAL_MAX, entity=NATURAL_MAX,
                file="main.adb", how_proved="flow" if flow else "prover",
                line=NATURAL_MAX, msg_id=NATURAL_MAX,
                message={"text": ('"Written_Count" is set by "Put_Line" but not used after the call'
                                  if flow else "overflow check proved")},
                rule="INEFFECTIVE" if flow else "VC_OVERFLOW_CHECK",
                severity="warning" if flow else "info",
                unproved_status=dict(status="limit", time=False, steps=False, memory=False))
    if flow:
        data["tracefile"] = "main__flow__2147483647.trace"
    else:
        data.update(check_col=NATURAL_MAX, check_line=NATURAL_MAX, check_file="main.adb",
                    stats={p: dict(count=NATURAL_MAX, max_steps=NATURAL_MAX, max_time="9" * 64)
                           for p in ("CVC5", "Z3", "altergo", "Checker")})
    if runtime:
        # Independent maxima across both selected runtime bodies, not a claim
        # that one real record combines all these fields and check kinds.
        data["file"] = "silver_arguments.adb"
        if flow:
            data["rule"] = "SUBPROGRAM_TERMINATION"
            data["message"]["text"] = (
                'implicit aspect Always_Terminates on "First_Or_Default" '
                'has been proved, subprogram will terminate')
            data["tracefile"] = "silver_arguments__flow__2147483647.trace"
        else:
            data["check_file"] = "silver_arguments.ads"
            data["rule"] = "VC_LOOP_INVARIANT_PRESERV"
            data["message"]["text"] = "loop invariant initialization proved"
    return data


def maximal_image_advisory() -> dict:
    # The pinned producer emits this complete warning schema without an entity,
    # statistics, user-name payload or nonempty check tree.
    return dict(check_tree={}, col=NATURAL_MAX, file="main.adb", how_proved="trivial",
                line=NATURAL_MAX, rule="imprecise-image", severity="warning", suppressed="",
                unproved_status={"status": "unknown"}, message={"text": (
                    'references to the "Image" attribute are handled in an imprecise way, '
                    'so nothing will be known about the evaluation of the attribute reference '
                    'apart from a bound on its length [imprecise-image]')})


def embedded_record_bytes(data: dict) -> int:
    encoded = json.dumps(data, indent=2)
    # Four spaces at every line: a record inside the top-level section array.
    # Add the comma/newline, including the last record as an overestimate.
    return len(encoded) + 4 * len(encoded.splitlines()) + 2


def main_envelope() -> int:
    # The joint two-byte charge covers roots, comparisons, components and indices.
    # Nested loops can repeat the array note once per enclosing loop/write pair;
    # 24*loops + 8*writes <= source bytes. Each element reference and the
    # generated component renaming can add an index check; each reference
    # consumes an identifier byte and a following separator. Named subtype
    # objects can use seven-byte declarations (A:S:=0;). See
    # docs/named-integer-subtypes-report-capacity.md.
    checks = (SOURCE_BYTES // 2 + 3 * 63 + SOURCE_BYTES // 7
              + 3 * (SOURCE_BYTES // 15) + SOURCE_BYTES // 2)
    image_warnings = 2 * (SOURCE_BYTES // 16)
    array_warnings = SOURCE_BYTES ** 2 // (4 * 24 * 8)
    return (checks * MAIN_RECORD_BYTES + (2 * SOURCE_BYTES + image_warnings) * FLOW_RECORD_BYTES
            + 2 * SOURCE_BYTES + METADATA_BYTES + array_warnings * ARRAY_NOTE_BYTES)


def metadata_envelope() -> int:
    # See docs/report-capacity.md for the source cardinality ledger. These
    # charges include quoted keys, indentation, separators and numeric spelling.
    return (8 * 256 + 5 * 32 + 10 * (24 * 96 + 192)
            + (5 * 32 + 12) * 160 + 1024)


def subprogram_envelope() -> int:
    # Functions and procedures share the source-bound entity budget. Procedure
    # calls can be five bytes; writable actuals add a separate copy-back check.
    # Named selectors add source bytes; each actual still reserves its own
    # opening delimiter and payload byte, so the same maxima cover #392.
    # Charge output initialization separately instead of relying on overlap
    # with the older flow allowance. See scalar-procedures-report-capacity.md.
    subprograms = SOURCE_BYTES // 32
    calls = SOURCE_BYTES // 5
    writable_actuals = SOURCE_BYTES // 2
    outputs = SOURCE_BYTES // 7
    # The two new dependence rules are mutually exclusive for each scalar
    # formal. UNUSED_VARIABLE can coexist with INOUT_ONLY_READ and remains
    # charged in the older flow allowance; charge the new record separately.
    formal_advisories = SOURCE_BYTES // 7
    return (main_envelope() + subprograms * (1024 + 512 + 2 * 256 + 32 * 160)
            + 3 * 256 * calls + 4 * SOURCE_BYTES
            + writable_actuals * MAIN_RECORD_BYTES
            + outputs * FLOW_RECORD_BYTES + 2 * SOURCE_BYTES
            + writable_actuals * (FLOW_RECORD_BYTES + SOURCE_BYTES) + SOURCE_BYTES
            + formal_advisories * FLOW_RECORD_BYTES + SOURCE_BYTES)



def package_envelope() -> int:
    # Disjoint original source charge: five package-name occurrences,
    # declaration+write occurrence per writable state, and each source call.
    # See docs/bounded-library-packages-report-capacity.md.
    hidden = max(states * ((SOURCE_BYTES - 5 * name - 9 * states) // 2) * (768 + 2 * name)
                 for name in range(1, SOURCE_BYTES // 5 + 1)
                 for states in range((SOURCE_BYTES - 5 * name) // 9 + 1))
    names = SOURCE_BYTES ** 2 // 2 + 2 * (SOURCE_BYTES ** 2 // 9)
    ordinary_prefixes = max(2 * name * (7 * (SOURCE_BYTES - 5 * name) + 189)
                            for name in range(1, SOURCE_BYTES // 5 + 1))
    metadata_prefixes = 40 * (SOURCE_BYTES ** 2 // (4 * 5 * 32))
    extra_edges = (SOURCE_BYTES // 2 - SOURCE_BYTES // 5) * 3 * 256
    return (subprogram_envelope() + hidden + names + ordinary_prefixes
            + metadata_prefixes + extra_edges + METADATA_BYTES)


def dense_report() -> str:
    """A producer-shaped adversarial witness, not universal proof evidence."""
    result = assignment_call_report()
    result["entities"][" 2"]["name"] = "Silver_IO.Put"
    provers = ("CVC5", "Z3", "altergo")

    def obligation(length: bool) -> dict:
        roots = 3 if length else 2
        item = maximal_retained_record()
        item.update(entity=1, line=1, col=1, check_line=1, check_col=1,
                    rule="VC_LENGTH_CHECK" if length else "VC_RANGE_CHECK",
                    message={"text": "length check proved" if length else "range check proved"})
        item["stats"] = {p: dict(count=1, max_steps=100_000, max_time=0.123456789012345)
                         for p in provers[:roots]}
        item["check_tree"] = [dict(transformations={}, proof_attempts={
            p: dict(result="Valid" if index == winner else "High failure (unrecognized prover answer)",
                    steps=100_000, time=0.123456789012345)
            for index, p in enumerate(provers)}) for winner in range(roots)]
        return item

    result["proof"] = [obligation(True) for _ in range(771)] + [obligation(False) for _ in range(63)]
    warning = maximal_retained_record(flow=True)
    warning.update(entity=1, line=1, col=1, message={"text": "unused assignment"})
    result["flow"] = [warning for _ in range(771)]
    return json.dumps(result, indent=2)


class CapacityEnvelopeTests(unittest.TestCase):
    def test_retained_record_and_whole_report_envelopes(self) -> None:
        self.assertLessEqual(embedded_record_bytes(maximal_retained_record()), MAIN_RECORD_BYTES)
        self.assertLessEqual(embedded_record_bytes(maximal_retained_record(flow=True)), FLOW_RECORD_BYTES)
        self.assertLessEqual(embedded_record_bytes(maximal_retained_record(runtime=True)), MAIN_RECORD_BYTES)
        self.assertLessEqual(embedded_record_bytes(maximal_retained_record(flow=True, runtime=True)),
                             FLOW_RECORD_BYTES)
        self.assertLessEqual(embedded_record_bytes(maximal_image_advisory()), FLOW_RECORD_BYTES)
        division = maximal_retained_record()
        division['rule'] = 'VC_DIVISION_CHECK'
        division['message']['text'] = 'division check proved'
        self.assertLessEqual(embedded_record_bytes(division), MAIN_RECORD_BYTES)
        array_note = maximal_image_advisory()
        array_note.update(rule="array-initialization", message={"text":
            "initialization of an array in FOR loop is handled imprecisely [array-initialization]"})
        self.assertLessEqual(embedded_record_bytes(array_note), ARRAY_NOTE_BYTES)
        index = maximal_retained_record()
        index.update(rule="VC_INDEX_CHECK", message={"text": "index check proved"})
        self.assertLessEqual(embedded_record_bytes(index), MAIN_RECORD_BYTES)
        self.assertEqual(main_envelope(), 31_822_336)
        self.assertEqual(subprogram_envelope(), 49_279_744)
        self.assertEqual(package_envelope(), 254_557_666)
        self.assertEqual(metadata_envelope(), 55_712)
        self.assertLessEqual(metadata_envelope(), METADATA_BYTES)
        specification = (ROOT / "src/silver_library_reports.ads").read_text()
        report_limit = int(re.search(r"Max_Report_Length\s*:\s*constant Positive\s*:=\s*([\d_]+)",
                                    specification)[1].replace("_", ""))
        runtime_limit = int(re.search(r"Max_Runtime_Report_Length\s*:\s*constant Positive\s*:=\s*([\d_]+)",
                                     specification)[1].replace("_", ""))
        platform_limit = int(re.search(r"Max_File_Length\s*:\s*constant Positive\s*:=\s*([\d_]+)",
                                      (ROOT / "src/silver_platform.ads").read_text())[1].replace("_", ""))
        self.assertLessEqual(main_envelope(), report_limit)
        self.assertLessEqual(subprogram_envelope(), report_limit)
        self.assertLessEqual(package_envelope(), report_limit)
        self.assertEqual(report_limit, 256 * 1024 * 1024)
        self.assertGreaterEqual(platform_limit, report_limit)
        for proof_count, flow_count in ((36, 12), (11, 7), (0, 0)):
            self.assertLessEqual(proof_count * MAIN_RECORD_BYTES + flow_count * FLOW_RECORD_BYTES
                                 + METADATA_BYTES, runtime_limit)

    def test_hidden_state_record_schema_and_source_product(self) -> None:
        record = maximal_retained_record(flow=True)
        record.update(file=".adb", tracefile="__flow__2147483647.trace",
                      message={"text": '\"\" is set by \"\" but not used after the call'})
        self.assertEqual(embedded_record_bytes(record), 526)
        # Qualified state dot and indexed trace suffix add three fixed bytes.
        self.assertLessEqual(embedded_record_bytes(record) + 3, 768)
        maximum = max((states * calls * (768 + 2 * name), name, states, calls)
                      for name in range(1, SOURCE_BYTES // 5 + 1)
                      for states in range((SOURCE_BYTES - 5 * name) // 9 + 1)
                      for calls in [(SOURCE_BYTES - 5 * name - 9 * states) // 2])
        self.assertEqual(maximum, (179_203_692, 17, 223, 1002))
        prefixes = max((2 * name * (7 * (SOURCE_BYTES - 5 * name) + 189), name)
                       for name in range(1, SOURCE_BYTES // 5 + 1))
        self.assertEqual(prefixes, (11_899_384, 412))

    def test_subprogram_record_allowances_exclude_separately_charged_names(self) -> None:
        initialization = maximal_retained_record(flow=True)
        initialization.update(rule="UNINITIALIZED", severity="info",
                              message={"text": 'initialization of "" proved'})
        self.assertLessEqual(embedded_record_bytes(initialization), FLOW_RECORD_BYTES)
        termination = maximal_retained_record(flow=True)
        termination.update(rule="SUBPROGRAM_TERMINATION", severity="info", message={"text":
            'implicit aspect Always_Terminates on "" has been proved, subprogram will terminate'})
        self.assertLessEqual(embedded_record_bytes(termination), FLOW_RECORD_BYTES)
        unused_output = maximal_retained_record(flow=True)
        unused_output.update(rule="INEFFECTIVE", severity="warning", message={"text":
            '"" is set by "" but not used after the call'})
        self.assertLessEqual(embedded_record_bytes(unused_output), FLOW_RECORD_BYTES)
        for rule, message in (
                ("INOUT_ONLY_READ", '"" is not modified, could be IN'),
                ("UNUSED_INITIAL_VALUE", 'unused initial value of ""')):
            formal_advisory = maximal_retained_record(flow=True)
            formal_advisory.update(rule=rule, message={"text": message})
            with self.subTest(rule=rule):
                self.assertLessEqual(embedded_record_bytes(formal_advisory), FLOW_RECORD_BYTES)
                # One exact declaration-name payload per record, no escaping.
                formal_advisory["message"]["text"] = message.replace('""', '"' + 'N' * SOURCE_BYTES + '"')
                self.assertLessEqual(embedded_record_bytes(formal_advisory),
                                     FLOW_RECORD_BYTES + SOURCE_BYTES)
        copyback = maximal_retained_record()
        copyback.update(rule="VC_RANGE_CHECK", message={"text": "range check proved"})
        self.assertLessEqual(embedded_record_bytes(copyback), MAIN_RECORD_BYTES)

    def test_dense_review_source_is_admitted_and_maximal_credit_report_exceeds_old_limit(self) -> None:
        import tempfile
        with tempfile.TemporaryDirectory(prefix="silver-capacity-source-") as directory:
            path = Path(directory) / "main.adb"
            path.write_bytes(dense_source())
            checked = test_silver.invoke("check", path)
            self.assertEqual(checked.returncode, 0, checked.stdout)
        report = dense_report()
        self.assertGreater(len(report), 2_097_152)
        self.assertLess(len(report), main_envelope())

    def test_dense_static_subtypes_and_mutable_assignments_are_admitted(self) -> None:
        import tempfile
        source, declarations = dense_mutable_source()
        self.assertEqual(len(source), SOURCE_BYTES)
        self.assertGreater(declarations, 100)
        # The extra declaration allowance must cover the new 13-byte minimum;
        # the assignment allowance already covers both scalar and String forms.
        self.assertEqual(len(b'A:Integer:=0;'), 13)
        self.assertEqual(len(b'A:=B;'), 5)
        with tempfile.TemporaryDirectory(prefix='silver-mutable-capacity-') as directory:
            path = Path(directory) / 'main.adb'
            path.write_bytes(source)
            checked = test_silver.invoke('check', path)
            self.assertEqual(checked.returncode, 0, checked.stdout)

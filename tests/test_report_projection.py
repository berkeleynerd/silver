"""The native stream projection retains audit evidence and validates skipped bytes."""
from __future__ import annotations

import json
from pathlib import Path
import random
import subprocess
import tempfile
import unittest

from scripts.platforms import alire_command, native_layout, tool_environment

ROOT = Path(__file__).resolve().parents[1]


class ReportProjectionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.temporary = tempfile.TemporaryDirectory(prefix="silver-projection-")
        cls.addClassCleanup(cls.temporary.cleanup)
        cls.directory = Path(cls.temporary.name)
        cls.project_file = cls.directory / "probe.gpr"
        cls.project_file.write_text(f'''with "{ROOT / 'proof/silver_proof_containers.gpr'}";
project Probe is
   for Source_Dirs use ("{ROOT / 'src'}", "{ROOT / 'tests'}");
   for Object_Dir use "obj";
   for Exec_Dir use ".";
   for Main use ("report_projection_probe.adb");
   package Compiler is
      for Default_Switches ("Ada") use ("-gnat2022", "-gnata", "-gnato");
   end Compiler;
end Probe;
''')
        host = native_layout()
        built = subprocess.run(
            alire_command(host, "exec", "--", "gprbuild", "-P", cls.project_file, "-j2", "-p",
                          "-XSILVER_HOST=" + host.key),
            cwd=host.context, env=tool_environment(host), capture_output=True,
            text=True, timeout=120)
        if built.returncode:
            raise AssertionError(built.stdout + built.stderr)

    def project(self, source: str, *, accepted: bool = True) -> str:
        input_file = self.directory / "input.json"
        output_file = self.directory / "output.json"
        raw = source.encode("ascii")
        input_file.write_bytes(raw)
        result = subprocess.run(
            [self.directory / "report_projection_probe", input_file, output_file],
            capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0 if accepted else 1,
                         result.stdout + result.stderr)
        self.assertEqual(result.stdout, "accepted\n" if accepted else "rejected\n")
        self.assertEqual(input_file.read_bytes(), raw)
        return output_file.read_bytes().decode("ascii")

    def test_all_json_values_project_only_at_immediate_record_scope(self) -> None:
        values = ({}, [], None, True, False, 0, -1, 123456789, 1.25, -3e120,
                  "text", 'quote" and backslash\\ and controls\n\t',
                  {"proof_attempts": {"Z3": {"result": "Failure\n(interrupted)"}}},
                  [{"nested": [False, None, {"check_tree": 23}]}])
        for section in ("flow", "proof"):
            for value in values:
                with self.subTest(section=section, value=value):
                    opaque = json.dumps(value, ensure_ascii=True)
                    source = (' { "' + section + '": [ {"check_tree": ' + opaque
                              + ', "severity":"info", "message":{"check_tree":'
                              + opaque + '} } ], "check_tree":' + opaque + ' }\n')
                    expected = source.replace('"check_tree": ' + opaque, '"check_tree": {}', 1)
                    self.assertEqual(self.project(source), expected)

    def test_duplicates_forbidden_fields_and_escaped_key_spelling_survive(self) -> None:
        source = (r'{"proof":[{"check_tree":[1],"severity":"info","severity":"high",'
                  r'"check_tree":{"severity":"high"},"suppressed":false,'
                  r'"check_\u0074ree":[2],"justified":true,"annot_kind":"review"}],'
                  r'"proof":[],"entities":{"check_tree":[3]}}')
        expected = source.replace('"check_tree":[1]', '"check_tree":{}').replace(
            '"check_tree":{"severity":"high"}', '"check_tree":{}')
        self.assertEqual(self.project(source), expected)

    def test_nesting_bound_and_long_opaque_reason_do_not_use_report_storage(self) -> None:
        # 3 report-container levels plus 61 opaque arrays reaches the same
        # 64-level ceiling as the existing whole-report scanner.
        source = '{"proof":[{"check_tree":' + '[' * 61 + '0' + ']' * 61 + '}]}'
        self.assertEqual(self.project(source), '{"proof":[{"check_tree":{}}]}')
        self.project(source.replace('0', '[0]'), accepted=False)
        source = '{"proof":[{"check_tree":{"result":"' + 'x' * 17_000_000 + '"}}]}'
        self.assertEqual(self.project(source), '{"proof":[{"check_tree":{}}]}')

    def test_malformed_opaque_values_and_truncated_tokens_are_rejected(self) -> None:
        invalid = ('', '[', '{', '"unterminated', '"bad\\q"', '"bad\\u123x"',
                   '"bad\\u123"', '"raw\nnewline"', '[1,]', '{"x":1,}',
                   '[1}', '{"x" 1}', '{"x":}', '01', '+1', '-01', '-',
                   '1.', '1e', '1e+', 'tru', 'falsee', 'nulll', 'true false')
        for value in invalid:
            with self.subTest(value=value):
                self.project('{"proof":[{"check_tree":' + value + '}]}', accepted=False)
        valid = '{"proof":[{"check_tree":{"result":"a\\\"b"},"severity":"info"}]}'
        for length in range(len(valid)):
            with self.subTest(truncated_at=length):
                self.project(valid[:length], accepted=False)

    def test_other_sections_are_byte_identical(self) -> None:
        for source in ('null', 'true', 'false', '1', '-1.23e+45',
                       r'"text\u1234"', ' {}\n', '[0,1,2]',
                       '{"entities":{"x":{"check_tree":[1,2]}}}',
                       '{"proof":[[{"check_tree":3}]],"flow":{"check_tree":4}}'):
            with self.subTest(source=source):
                self.assertEqual(self.project(source), source)

    def test_raw_key_scope_and_surrounding_whitespace_are_preserved(self) -> None:
        source = (r'{"pr\u006fof":[{"check_tree":1}],'
                  r'"fl\u006fw":[{"check_tree":2}],'
                  r'"proof":[{"check_tre":3,"check_treeX":4,'
                  r'"check_tree":{"proof":[{"check_tree":5}]},'
                  r'"flow":{"check_tree":6}}]}')
        expected = source.replace(
            '"check_tree":{"proof":[{"check_tree":5}]}', '"check_tree":{}')
        self.assertEqual(self.project(source), expected)
        source = ' \r\n{\t"flow" : [ { "check_tree" : \r\n[1, 2]\t, "x" : 3 } ] }\r\n'
        self.assertEqual(self.project(source), source.replace('[1, 2]', '{}'))

    def test_generated_documents_preserve_every_other_value(self) -> None:
        # Python's JSON encoder/decoder supplies an independent structural
        # oracle; it does not reproduce the native byte-state machine.
        generator = random.Random(343)

        def value(depth: int):
            scalars = (None, True, False, 0, -134, 1.25e-27,
                       'quoted "check_tree": [{]} and \\ escapes', '\n\t\u1234')
            choice = generator.randrange(4 if depth else 2)
            if choice < 2:
                return generator.choice(scalars)
            if choice == 2:
                return [value(depth - 1) for _ in range(generator.randrange(4))]
            return {name: value(depth - 1) for name in
                    generator.sample(('check_tree', 'proof', 'flow', 'suppressed', 'x'),
                                     generator.randrange(5))}

        for case in range(80):
            document = {'proof': [], 'flow': [], 'entities': value(3),
                        'warn_error': value(2), 'check_tree': value(3)}
            for section in ('proof', 'flow'):
                for _ in range(generator.randrange(1, 5)):
                    document[section].append({'check_tree': value(4),
                                              'message': value(3),
                                              'severity': generator.choice(('info', 'high')),
                                              'suppressed': value(1)})
            source = json.dumps(document, ensure_ascii=True,
                                indent=generator.choice((None, 1, 2, 4)))
            expected = json.loads(source)
            for section in ('proof', 'flow'):
                for record in expected[section]:
                    record['check_tree'] = {}
            with self.subTest(case=case):
                self.assertEqual(json.loads(self.project(source)), expected)

"""The producer's serialized counter and the adapter's fresh IDs are distinct."""
from __future__ import annotations

import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from scripts.platforms import alire_command, native_layout, tool_environment

ROOT = Path(__file__).resolve().parents[1]


def node_ids(value):
    if isinstance(value, list):
        if value and isinstance(value[0], str) and value[0].startswith("W_"):
            yield value[1]
        for child in value:
            yield from node_ids(child)


class ImageModelTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.temporary = tempfile.TemporaryDirectory(prefix="silver-image-model-")
        cls.addClassCleanup(cls.temporary.cleanup)
        cls.directory = Path(cls.temporary.name)
        host = native_layout()
        project = cls.directory / "probe.gpr"
        project.write_text(f'''project Probe is
   for Source_Dirs use ("{ROOT / 'src'}", "{ROOT / 'tests'}");
   for Object_Dir use "obj";
   for Exec_Dir use ".";
   for Main use ("image_model_probe.adb");
   package Compiler is
      for Default_Switches ("Ada") use ("-gnat2022", "-gnata", "-gnato");
   end Compiler;
end Probe;
''')
        built = subprocess.run(alire_command(host, "exec", "--", "gprbuild", "-P", project,
                                             "-j2", "-p"), cwd=host.context,
                               env=tool_environment(host), capture_output=True,
                               text=True, timeout=120)
        if built.returncode:
            raise AssertionError(built.stdout + built.stderr)

    def scan(self, node_id: int, *, nested: bool = False):
        declarations = (
            [['W_NAMESPACE_DECLARATION', node_id, 3, None, 'Scope']]
            if nested else None
        )
        theory = ['W_THEORY_DECLARATION', 1 if nested else node_id, 3,
                  declarations, 'Unselected_Theory', 0, None, '']
        raw = json.dumps({'theory_declarations': [theory]}).encode()
        path = self.directory / "input.json"
        path.write_bytes(raw)
        result = subprocess.run([self.directory / "image_model_probe", path],
                                capture_output=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        lines = result.stdout.splitlines()
        self.assertEqual(len(lines), 5, result.stdout)
        return lines, raw

    def test_full_producer_counter_domain_is_accepted(self) -> None:
        # Xtree_Why_Ast serializes a Natural counter, not the narrower
        # internal Why_Node_Id. Exercise both top-level and nested counters.
        for value in (1073741823, 1073741824, 2147483646, 2147483647):
            for nested in (False, True):
                with self.subTest(value=value, nested=nested):
                    lines, raw = self.scan(value, nested=nested)
                    self.assertEqual(lines[0], b'UNCHANGED')
                    self.assertEqual(int(lines[1]), len(raw))
                    self.assertEqual(int(lines[2]), value)

    def test_ids_outside_producer_domain_are_rejected(self) -> None:
        for value in (-1, 2147483648, 4611686018427387903):
            for nested in (False, True):
                with self.subTest(value=value, nested=nested):
                    lines, _ = self.scan(value, nested=nested)
                    self.assertEqual(lines[0], b'INVALID_MODEL')

    def test_inserted_nodes_are_unique_above_every_producer_id(self) -> None:
        lines, _ = self.scan(2147483647)
        fragments = []
        for fragment in lines[3:]:
            self.assertTrue(fragment.startswith(b','), fragment)
            fragments.append(json.loads(fragment[1:]))
        ids = list(node_ids(fragments))
        self.assertEqual(sorted(ids), list(range(2147483648, 2147483671)))
        self.assertLess(max(ids), 2 ** 62)


if __name__ == '__main__':
    unittest.main()

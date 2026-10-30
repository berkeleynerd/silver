"""Run retained finite deepest-loop fixtures using their original observer."""
from pathlib import Path
import json
import subprocess
import sys
import unittest

ROOT = Path.cwd()
ASSETS = Path(__file__).with_name("_boolean_stack_assets")
OBSERVER = ASSETS / "observe.py"
FIXTURES = ASSETS
RESULTS = ROOT / "tmp/boolean-final-loop-observations"
BINARY = ROOT / ".silver/linux-x86_64/compiler/bin/silver"

class RetainedStackObservations(unittest.TestCase):
    def test_retained_finite_deepest_loops(self):
        RESULTS.mkdir(exist_ok=True)
        for name in ("counted", "foreach-singleton"):
            with self.subTest(fixture=name):
                subprocess.run([sys.executable, str(OBSERVER), str(BINARY),
                    str(FIXTURES / (name + ".adb")), str(RESULTS / name)], check=True)
                record = json.loads((RESULTS / name / "observation.json").read_text())
                self.assertEqual([item["name"] for item in record["observations"]],
                                 ["check", "compile", "execute"])
                generated = Path(record["workspace"]) / "main.adb"
                self.assertEqual(generated.read_bytes(), (FIXTURES / (name + ".adb")).read_bytes())

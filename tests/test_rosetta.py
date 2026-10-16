"""Rosetta render determinism, independent of compiler/proof tooling."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from rosetta import refresh


class RosettaRenderTests(unittest.TestCase):
    def test_render_is_identical_across_hash_seeds(self):
        """Exercise the real CLI and all current assessments without downloaded pages."""
        manifest = json.loads((ROOT / "rosetta/manifest.json").read_text())
        coverage = json.loads((ROOT / "rosetta/coverage.json").read_text())
        assessed_count = sum(task["title"] in coverage["tasks"] for task in manifest["tasks"])
        results = []
        with tempfile.TemporaryDirectory(prefix="silver-rosetta-render-") as temporary:
            for seed in (1, 2):
                run = Path(temporary) / str(seed)
                output = run / "rosetta"
                output.mkdir(parents=True)
                for name in ("manifest.json", "coverage.json"):
                    shutil.copyfile(ROOT / "rosetta" / name, output / name)
                for task in manifest["tasks"]:
                    (output / task["path"]).mkdir(parents=True, exist_ok=True)
                subprocess.run(
                    [sys.executable, str(ROOT / "rosetta/refresh.py"), "--render",
                     "--output", str(output), "--list", str(run / "rosetta.md")],
                    env={**os.environ, "PYTHONHASHSEED": str(seed)},
                    check=True, capture_output=True, text=True,
                )
                generated = [run / "rosetta.md", output / "progression.md",
                             *sorted(output.rglob("silver.md"))]
                self.assertEqual(len(generated), assessed_count + 2)
                results.append({str(path.relative_to(run)): hashlib.sha256(path.read_bytes()).hexdigest()
                                for path in generated})
        self.assertEqual(results[0], results[1])

    def test_risk_counts_are_per_sample_and_ties_are_alphabetical(self):
        """A duplicated risk cannot crowd a tied risk out of the four-item summary."""
        task = {"title": "Fixture", "path": "f/fixture", "silver": {"verdict": "likely"}}
        assessed = {"risks": [{"obligation": name} for name in
                               ("stack", "range", "index", "length", "heap", "stack")],
                    "outlook": "likely", "effects": [], "size": 1}
        page = refresh.progression_page([task], [({"task": task, "assessed": assessed}, [])], [])
        self.assertIn("The assessments flag heap in 1, index in 1, length in 1 and range in 1", page)
        self.assertNotIn("stack in", page)


if __name__ == "__main__":
    unittest.main()

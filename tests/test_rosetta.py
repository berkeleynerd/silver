"""Rosetta refresh safety and render determinism, independent of compiler/proof tooling."""
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
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from rosetta import refresh


class RosettaRefreshTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="silver-rosetta-refresh-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.cache = self.root / "cache"
        self.output = self.root / "rosetta"
        self.listing = self.root / "rosetta.md"
        (self.cache / "pages").mkdir(parents=True)
        categories = {name: [] for name in refresh.CATEGORIES}
        categories.update({refresh.TASKS: ["Alpha", "Zulu"], "Ada": ["Alpha", "Zulu"],
                           "SPARK": ["Alpha", "Zulu"]})
        stamp = "2026-11-09T00:00:00Z"
        metadata = {
            "categories.json": {"retrieved": "2026-11-09", "categories": categories},
            "info.json": {"Alpha": {"revision": 11}, "Zulu": {"revision": 22}},
            "pages.json": {str(revision): {"timestamp": stamp} for revision in (11, 22, 33, 44)},
            "subpages.json": {"aliases": {"Zulu/ADA": "Zulu/Ada"}, "pages": {
                "Zulu/Ada": {"revision": 33, "timestamp": stamp},
                "Zulu/SPARK": {"revision": 44, "timestamp": stamp},
                "Alpha/SPARK": {"revision": 55, "timestamp": stamp}}},
        }
        for name, value in metadata.items():
            (self.cache / name).write_text(json.dumps(value), encoding="utf-8")
        pages = {
            11: "Alpha fixture.\n=={{header|Ada}}{{header|SPARK}}==\n"
                "<syntaxhighlight lang=\"ada\">procedure Alpha is begin null; end Alpha;"
                "</syntaxhighlight>\n{{:/SPARK}}\n",
            22: "Zulu fixture.\n=={{header|Ada}}==\n{{:/ADA}}\n"
                "=={{header|SPARK}}==\n{{:/SPARK}}\n",
            33: "<syntaxhighlight lang=\"ada\">procedure Zulu is begin null; end Zulu;"
                "</syntaxhighlight>\n",
            44: "<syntaxhighlight lang=\"spark\">procedure Proof is begin null; end Proof;"
                "</syntaxhighlight>\n",
        }
        for revision, text in pages.items():
            (self.cache / "pages" / f"{revision}.wiki").write_text(text, encoding="utf-8")
        for name in ("a/old/task.wiki", "z/old/silver.md", "0-9/old/local-notes.txt",
                     "manifest.json", "progression.md", "README.md"):
            path = self.output / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(f"Existing {name}\n", encoding="utf-8")
        self.listing.write_text("Existing listing\n", encoding="utf-8")
        self.original = self.snapshot()

    def snapshot(self):
        return {str(path.relative_to(self.root)): path.read_bytes()
                for path in [*self.output.rglob("*"), self.listing] if path.is_file()}

    def run_refresh(self, *, render=False):
        mode = ["--render"] if render else ["--offline", "--cache", str(self.cache)]
        return subprocess.run(
            [sys.executable, str(ROOT / "rosetta/refresh.py"), *mode,
             "--output", str(self.output), "--list", str(self.listing)],
            capture_output=True, text=True,
        )

    def assert_cache_failure_preserves_output(self, path):
        result = self.run_refresh()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertIn(str(path), result.stderr)
        self.assertIn("without --offline", result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        self.assertEqual(self.snapshot(), self.original)

    def test_missing_late_task_page_preserves_output(self):
        path = self.cache / "pages/22.wiki"
        path.unlink()
        self.assert_cache_failure_preserves_output(path)

    def test_online_incomplete_download_reports_page_and_preserves_output(self):
        path = self.cache / "pages/22.wiki"
        path.unlink()
        categories = json.loads((self.cache / "categories.json").read_text())["categories"]
        info = json.loads((self.cache / "info.json").read_text())
        with (patch.object(refresh, "members", side_effect=categories.__getitem__),
              patch.object(refresh, "page_info", return_value=info),
              patch.object(refresh, "download"),
              self.assertRaises(SystemExit) as failure):
            refresh.main(["--cache", str(self.cache), "--output", str(self.output),
                          "--list", str(self.listing)])
        self.assertIn(f"cannot read cached page {path}", str(failure.exception))
        self.assertIn("without --offline", str(failure.exception))
        self.assertEqual(self.snapshot(), self.original)

    def test_invalid_utf8_late_task_page_preserves_output(self):
        path = self.cache / "pages/22.wiki"
        path.write_bytes(b"\xff")
        self.assert_cache_failure_preserves_output(path)

    def test_missing_late_solution_subpage_preserves_output(self):
        path = self.cache / "pages/44.wiki"
        path.unlink()
        self.assert_cache_failure_preserves_output(path)

    def test_invalid_utf8_late_solution_subpage_preserves_output(self):
        path = self.cache / "pages/44.wiki"
        path.write_bytes(b"\xff")
        self.assert_cache_failure_preserves_output(path)

    def test_malformed_json_metadata_preserves_output(self):
        for name in ("categories.json", "info.json", "pages.json", "subpages.json"):
            with self.subTest(name=name):
                path = self.cache / name
                original = path.read_bytes()
                try:
                    path.write_text("{", encoding="utf-8")
                    self.assert_cache_failure_preserves_output(path)
                finally:
                    path.write_bytes(original)

    def test_incomplete_late_subpage_metadata_preserves_output(self):
        path = self.cache / "subpages.json"
        value = json.loads(path.read_text())
        del value["pages"]["Zulu/SPARK"]["timestamp"]
        path.write_text(json.dumps(value), encoding="utf-8")
        self.assert_cache_failure_preserves_output(path)

    def test_missing_late_task_index_metadata_preserves_output(self):
        path = self.cache / "pages.json"
        value = json.loads(path.read_text())
        del value["22"]
        path.write_text(json.dumps(value), encoding="utf-8")
        self.assert_cache_failure_preserves_output(path)

    def test_complete_cache_rebuilds_groups_and_still_renders_without_cache(self):
        result = self.run_refresh()
        self.assertEqual(result.returncode, 0, result.stderr)
        manifest = json.loads((self.output / "manifest.json").read_text())
        self.assertEqual([task["title"] for task in manifest["tasks"]], ["Alpha", "Zulu"])
        self.assertEqual(manifest["tasks"][0]["solutions"][1]["same_section_as"], "Ada")
        self.assertEqual((self.output / "a/alpha/task.wiki").read_text(), "Alpha fixture.\n")
        self.assertEqual((self.output / "z/zulu/ada-1.ada").read_text(),
                         "procedure Zulu is begin null; end Zulu;\n")
        self.assertEqual((self.output / "z/zulu/spark-1.ada").read_text(),
                         "procedure Proof is begin null; end Proof;\n")
        self.assertEqual(manifest["tasks"][1]["solutions"][1]["subpages"][0]["revision"], 44)
        self.assertFalse((self.output / "0-9").exists())
        self.assertFalse((self.output / "a/old").exists())
        self.assertFalse((self.output / "z/old").exists())
        self.assertEqual((self.output / "README.md").read_bytes(), self.original["rosetta/README.md"])
        self.assertIn("Alpha", self.listing.read_text())
        self.assertIn("Zulu", self.listing.read_text())
        generated = self.snapshot()
        shutil.rmtree(self.cache)
        result = self.run_refresh(render=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.snapshot(), generated)


class RosettaRenderTests(unittest.TestCase):
    def test_pending_design_has_no_stage_and_is_not_an_oracle_exclusion(self):
        """An unsettled design must not silently become a zero-construct candidate."""
        manifest = json.loads((ROOT / "rosetta/manifest.json").read_text())["tasks"][:2]
        coverage = {"policy": {"allowed_effects": []}, "tasks": {}}
        for index, task in enumerate(manifest):
            assessed = {"revision": task["revision"], "assessed": "2026-10-25",
                        "model": "fixture", "effort": "high", "confidence": "medium",
                        "conflicts": [], "effects": [], "surface": [], "outlook": "likely",
                        "risks": [], "summary": "Fixture.", "approach": "An example approach."}
            if index == 0:
                assessed["assessment_status"] = "design-pending"
            else:
                assessed["size"] = 1
            coverage["tasks"][task["title"]] = assessed
        with tempfile.TemporaryDirectory(prefix="silver-rosetta-pending-") as temporary:
            output = Path(temporary) / "rosetta"
            for task in manifest:
                (output / task["path"]).mkdir(parents=True)
            (output / "coverage.json").write_text(json.dumps(coverage))
            refresh.apply_coverage(manifest, output)
            listing = Path(temporary) / "rosetta.md"
            refresh.render(manifest, "2026-10-25", output, listing)
            pending, candidate = manifest
            self.assertEqual(pending["silver"]["verdict"], "design-pending")
            self.assertEqual(pending["silver"]["reasons"], [])
            self.assertNotIn("stage", pending["silver"])
            self.assertEqual(candidate["silver"]["stage"], 1)
            page = (output / pending["path"] / "silver.md").read_text()
            self.assertIn("Design pending", page)
            self.assertNotIn("About", page)
            self.assertNotIn("Oracle conflicts", page)
            progression = (output / "progression.md").read_text()
            self.assertIn("1 candidates in 1 stages", progression)
            self.assertIn("## Design pending", progression)
            self.assertIn("[design pending]", listing.read_text())

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

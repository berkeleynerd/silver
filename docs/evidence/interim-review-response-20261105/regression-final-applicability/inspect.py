"""Read-only source/evidence inspection; imports no tests and launches no checks."""
import ast
from collections import Counter
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[4]
PACKET = ROOT / "docs/evidence/interim-review-response-20261105"
FINAL = "ddb183a918c78c8636b94961172dc923e7d88d30"
BASE = "fb89b3653accef6c08a49f88625144c108ad2432"
REPLACEMENT = "test_lean_evidence.LeanNativeDependencyTests.test_changed_resource_settings_apply_without_discarding_cached_objects"


def sha(data):
    return hashlib.sha256(data).hexdigest()


GIT_BLOBS = {}


def git_bytes(revision, relative):
    if revision not in GIT_BLOBS:
        paths = subprocess.check_output([
            "git", "ls-tree", "-r", "--name-only", revision, "--", "tests", "src", "proof",
            "samples", "catalogue", "scripts", "alire.toml", "silver.gpr", "rosetta/refresh.py",
            "rosetta/manifest.json", "rosetta/coverage.json"], cwd=ROOT, text=True).splitlines()
        output = subprocess.check_output(["git", "cat-file", "--batch"], cwd=ROOT,
                                         input="".join(f"{revision}:{p}\n" for p in paths).encode())
        blobs, position = {}, 0
        for path in paths:
            end = output.index(b"\n", position)
            _, kind, length = output[position:end].split()
            assert kind == b"blob"
            position = end + 1
            blobs[path] = output[position:position + int(length)]
            position += int(length) + 1
        assert position == len(output)
        GIT_BLOBS[revision] = blobs
    return GIT_BLOBS[revision][relative]


def read_run(name):
    rows = [json.loads(line) for line in gzip.open(PACKET / name / "events.jsonl.gz", "rt")]
    started = next(row for row in rows if row["event"] == "started")
    prepared = next(row for row in rows if row["event"] == "prepared")
    finished = next(row for row in rows if row["event"] == "finished")
    assert finished["outcome"] == "success" and not finished["failure_keys"]
    assert any(row.get("phase") == "test" and row["event"] == "phase-end"
               and row.get("returncode") == 0 for row in rows)
    original = Path(started["worktree"]["resolved"])
    inputs = prepared["inputs"]["inputs_sha256"]
    assert all(Path(path).is_file() and sha(Path(path).read_bytes()) == digest
               for path, digest in inputs.items())
    repo = {str(Path(path).relative_to(original)): digest for path, digest in inputs.items()
            if Path(path).is_relative_to(original)
            and Path(path).relative_to(original).parts[0] != ".silver"}
    changed = [{"path": rel, "captured_sha256": digest,
                "final_sha256": sha((ROOT / rel).read_bytes())}
               for rel, digest in repo.items() if sha((ROOT / rel).read_bytes()) != digest]
    assert all(sha((ROOT / rel).read_bytes()) == sha(git_bytes(FINAL, rel)) for rel in repo)
    return {"run_id": started["run_id"], "worktree": str(original),
            "captured_inputs": len(inputs), "captured_repository_inputs": len(repo),
            "original_live_mismatches": [], "final_vs_governed_commit_mismatches": [],
            "repository_changes": changed, "prepared_fingerprint": prepared["fingerprint"],
            "finished": finished}, original, repo


full, original, base_inputs = read_run("regression")
focused, focus_root, _ = read_run("lean-cpu-defaults")
assert all(sha(git_bytes(BASE, rel)) == digest for rel, digest in base_inputs.items())
selected = [ROOT / name for name in ("tests", "src", "proof", "samples", "catalogue", "scripts")]
current_files = {str(path.relative_to(ROOT)) for directory in selected
                 for path in directory.rglob("*") if path.is_file() and "__pycache__" not in path.parts}
current_files |= {"alire.toml", "silver.gpr", "rosetta/refresh.py", "rosetta/manifest.json", "rosetta/coverage.json"}
assert current_files == set(base_inputs)

# Reconstruct the final static discovery graph, including inheritance and the
# imported SharedBindingsTests class; do not import unittest test modules.
classes = {}
imports = {}
files = sorted((ROOT / "tests").glob("test_*.py"))
for path in files:
    tree = ast.parse(path.read_text())
    classes[path.stem] = {}
    imports[path.stem] = []
    for node in tree.body:
        assert not (isinstance(node, ast.FunctionDef) and node.name == "load_tests")
        if isinstance(node, ast.ClassDef):
            classes[path.stem][node.name] = (
                [ast.unparse(base) for base in node.bases],
                {f.name: f"{path.stem}.{node.name}.{f.name}" for f in node.body
                 if isinstance(f, (ast.FunctionDef, ast.AsyncFunctionDef)) and f.name.startswith("test_")})
        if isinstance(node, ast.ImportFrom):
            imports[path.stem] += [(node.module, a.name) for a in node.names if a.name.endswith("Tests")]


def methods(module, cls):
    bases, local = classes[module][cls]
    inherited = {}
    for base in bases:
        if base != "unittest.TestCase":
            inherited.update(methods(module, base))
    return inherited | local


ids = {}
for module, module_classes in classes.items():
    for cls in module_classes:
        ids.update({f"{module}.{cls}.{name}": definition for name, definition in methods(module, cls).items()})
    for source, cls in imports[module]:
        ids.update({f"{source}.{cls}.{name}": definition
                    for name, definition in methods(source.removeprefix("tests."), cls).items()})
inventory = json.load(gzip.open(PACKET / "regression/inventory.json.gz", "rt"))
assert ids == {row["id"]: row["definition"] for row in inventory}
log = gzip.open(PACKET / "regression/native.log.gz", "rt").read().splitlines()
headers = [re.match(r"^(test\w+) \(([\w.]+)\)(.*)$", line) for line in log]
assert Counter(match[2] for match in headers if match) == Counter(ids.keys())
for row in inventory:
    assert len(row["executions"]) == 1
    execution = row["executions"][0]
    assert row["id"] in log[execution["start_line"] - 1]
    assert len(execution["statuses"]) == 1 and execution["statuses"][0]["status"] == "ok"
    status_line = log[execution["statuses"][0]["line"] - 1]
    assert re.search(r"(?:^|\.\.\. )ok$", status_line)
assert log[-1] == "OK" and "Ran 595 tests in 3919.144s" in log
focus_log = gzip.open(PACKET / "lean-cpu-defaults/native.log.gz", "rt").read()
focus_ids = re.findall(r"^test\w+ \(([\w.]+)\) \.\.\. ok$", focus_log, re.MULTILINE)
assert len(focus_ids) == 7 and REPLACEMENT in focus_ids and set(focus_ids) <= set(ids)
assert "Ran 7 tests in 59.176s" in focus_log and focus_log.rstrip().endswith("OK")
old = ast.parse(git_bytes(BASE, "tests/test_lean_evidence.py"))
new = ast.parse((ROOT / "tests/test_lean_evidence.py").read_bytes())
changed_methods = []
for left, right in zip(old.body, new.body, strict=True):
    if ast.dump(left) != ast.dump(right):
        assert isinstance(left, ast.ClassDef) and isinstance(right, ast.ClassDef)
        for a, b in zip(left.body, right.body, strict=True):
            if ast.dump(a) != ast.dump(b):
                changed_methods.append(f"test_lean_evidence.{left.name}.{a.name}")
assert changed_methods == [REPLACEMENT]

lean_paths = sorted(rel for rel in base_inputs if rel.startswith("proof/") and rel.endswith(".lean"))
old_lean = {rel: git_bytes(BASE, rel).decode() for rel in lean_paths}
new_lean = {rel: (ROOT / rel).read_text() for rel in lean_paths}
import_pattern = r"^(?:public )?(?:meta )?import(?: all)? (Silver(?:\.\w+)*)\b"


def projections(tree):
    return {
        "include_str_counts": {rel: len(re.findall(r'\binclude_str\s*"', text))
                               for rel, text in tree.items() if re.search(r'\binclude_str\s*"', text)},
        "legacy_modules": [rel for rel, text in tree.items() if rel != "proof/lakefile.lean"
                           and not re.search(r"^module\s*$", text, re.MULTILINE)],
        "imports": {rel: re.findall(import_pattern, text, re.MULTILINE) for rel, text in tree.items()},
    }


old_projection, new_projection = projections(old_lean), projections(new_lean)
assert old_projection == new_projection
for change in full["repository_changes"]:
    rel = change["path"]
    if rel in new_lean:
        assert not re.search(r"skipKernelTC|addDeclWithoutChecking|addDeclCore", new_lean[rel])
lake_old, lake_new = old_lean["proof/lakefile.lean"], new_lean["proof/lakefile.lean"]
assert lake_old[lake_old.index("lean_lib Silver\n"):] == lake_new[lake_new.index("lean_lib Silver\n"):]
assert new_lean["proof/Silver/ReviewedOutputShape.lean"].replace(
    "set_option maxHeartbeats 10000000 in\n", "", 1) == old_lean["proof/Silver/ReviewedOutputShape.lean"]
assert new_lean["proof/Silver/ComposeEquations.lean"].replace(
    "set_option maxHeartbeats 3000000 in\n", "", 1) == old_lean["proof/Silver/ComposeEquations.lean"]

generated = []
for rel in (".silver/linux-x86_64/generated/silver_build.ads", ".silver/linux-x86_64/generated/silver_image_config.ads"):
    before, after = (original / rel).read_bytes(), (ROOT / rel).read_bytes()
    assert before.replace(str(original).encode(), str(ROOT).encode()) == after
    generated.append({"path": rel, "original_sha256": sha(before), "integration_sha256": sha(after),
                      "only_installation_root_changed": True})
identities = json.loads((ROOT / "tmp/pin-budget-repair-20261105T170452Z/lint-repair/source-identities.json").read_text())
shared = identities["shared_inputs_after"]
assert all(sha((ROOT / rel).read_bytes()) == digest for rel, digest in shared.items())
evidence = json.loads((ROOT / "tmp/pin-budget-repair-20261105T170452Z/lint-repair/lean-evidence.json").read_text())
assert evidence["scope"] == "complete" and evidence["axiom_audit"] == "passed"
result = {
    "generated_utc": datetime.now(timezone.utc).isoformat(), "base_commit": BASE, "final_commit": FINAL,
    "selected_reviewer_model": "GPT-6 Astra", "selected_reviewer_effort": "Extra High",
    "runtime_model_effort_and_token_cost": "Not exposed", "full_regression": full, "focused_cpu": focused,
    "inventory": {"files": len(files), "local_methods": sum(len(c[1]) for cs in classes.values() for c in cs.values()),
                  "runtime_ids": len(ids), "new_or_removed_ids": [], "changed_methods": changed_methods,
                  "source_definition_map_sha256": sha(json.dumps(ids, sort_keys=True).encode()),
                  "reused_original_results": 594, "required_replacement_results": 1,
                  "replacement_id": REPLACEMENT, "focused_passed_ids": focus_ids, "uncovered_ids": []},
    "static_projections": {"production_lean_files": len(lean_paths), "include_str_counts_equal": True,
                           "legacy_module_markers_equal": True, "all_imports_equal": True,
                           "lake_library_and_dependency_declarations_equal": True,
                           "changed_files_kernel_policy_equal": True,
                           "output_literal_and_other_bytes_equal_after_removing_local_option": True},
    "installation_configs": generated,
    "compiler_binaries": {"original": sha((original / ".silver/linux-x86_64/compiler/bin/silver").read_bytes()),
                          "integration": sha((ROOT / ".silver/linux-x86_64/compiler/bin/silver").read_bytes()),
                          "claim": "Original tested build retained; no integration binary verification claim."},
    "final_lean": {"run_id": evidence["run_id"], "scope": evidence["scope"], "mode": evidence["mode"],
                   "axiom_audit": evidence["axiom_audit"], "modules": len(evidence["modules"]),
                   "shared_inputs_checked": len(shared), "shared_input_mismatches": []},
    "review_disposition": "594 original results plus the changed method's focused pass cover all 595 final IDs. No additional regression rerun required for this exact delta.",
    "limits": ["Static source/evidence review only; no test, native or Lean run launched.",
               "Original fingerprints retained, not relabelled as a fresh final full-suite run.",
               "Final native proof/audit remains lead-owned and was active when review began."]}
(Path(__file__).parent / "summary.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"final_commit": FINAL, "ids": len(ids), "focused_ids": len(focus_ids),
                  "source_differences": len(full["repository_changes"]), "uncovered": []}))

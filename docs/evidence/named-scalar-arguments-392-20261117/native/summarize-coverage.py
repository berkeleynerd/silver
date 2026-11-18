"""Summarize retained whole-helper runs without claiming complete assurance."""

from __future__ import annotations

import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile


EVIDENCE = Path(__file__).resolve().parent
ROOT = EVIDENCE.parents[3]
SOURCE = ROOT / "src/silver_output_profile.adb"
HELPERS = (
    "Mark_Formal", "Function_Formal_Model", "Function_Formal_At",
    "Procedure_Formal_Model", "Procedure_Formal_At", "Function_Association",
    "Procedure_Association", "Function_Actuals_Tail_Model", "Actuals_Model",
    "Lemma_Function_Actuals_Advance", "Actuals_After", "Procedure_Actuals_Tail_Model",
    "Procedure_Actuals_Model", "Procedure_Actuals_After", "Procedure_Payloads_Free_Model",
    "Procedure_Payloads_Free", "Procedure_Update_Step", "Procedure_Updates_Tail_Model",
    "Procedure_Updates_Model", "Procedure_Updates", "Call_Model", "Read_Call",
    "Procedure_Call_Body", "Call_Assignment_Model", "Call_Assignment_Body", "Basic_Body",
)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def subprogram(text: str, name: str) -> str:
    declarations = list(re.finditer(r"^   (?:function|procedure) (\w+)\b", text, re.M))
    start = next(i for i, match in enumerate(declarations) if match[1] == name)
    end = next((match.start() for match in declarations[start + 1:] if match[1] != name), len(text))
    return text[declarations[start].start():end]


def main() -> None:
    snapshots: dict[str, bytes] = {}
    with tarfile.open(EVIDENCE / "failures/actuals-after-r1.tar.gz") as archive:
        data = archive.extractfile("source/silver_output_profile.adb").read()
        snapshots[digest(data)] = data
        initial_hash = digest(data)
    for snapshot in EVIDENCE.glob("*/source.adb.gz"):
        data = gzip.decompress(snapshot.read_bytes())
        snapshots[digest(data)] = data
    current = SOURCE.read_bytes()
    snapshots[digest(current)] = current

    successes: dict[str, dict] = {}
    for path in sorted(EVIDENCE.glob("*/*/result.json")):
        result = json.loads(path.read_text())
        if result["returncode"] != 0 or not result["source_unchanged"]:
            continue
        helper = result["helper"]
        if helper not in successes or result["managed_run"] > successes[helper]["managed_run"]:
            successes[helper] = {**result, "result_path": str(path.relative_to(ROOT))}
    # The first complete lookup-model invocation preceded the batch driver.
    example = next(iter(successes.values()))
    registry_runs = Path(example["managed_directory"]).parent
    successes["Function_Formal_Model"] = {
        "managed_run": "20261117T021119-5307e68878d2",
        "managed_directory": str(registry_runs / "20261117T021119-5307e68878d2"),
        "source_sha256": initial_hash,
        "returncode": 0,
        "result_path": "initial manual whole-helper run; managed evidence retained",
    }

    coverage = []
    for helper in HELPERS:
        if helper not in successes:
            continue
        result = successes[helper]
        folder = Path(result["managed_directory"]) / "exploratory-evidence/0"
        report = folder / "silver_output_profile.spark"
        data = json.loads(report.read_text())
        entities = {int(key): item["name"] for key, item in data["entities"].items()}
        checked_entities = {entities[item["entity"]] for item in data["proof"] + data["flow"]}
        assert checked_entities == {"Silver_Output_Profile." + helper}, (helper, checked_entities)
        assert not data["pragma_assume"] and not data["skip_flow_proof"] and not data["skip_proof"]
        assert all(item["severity"] == "info" for item in data["proof"] + data["flow"])
        summary = (folder / "gnatprove.out").read_text()
        total = int(re.search(r"^Total\s+(\d+)", summary, re.M)[1])
        captured = snapshots[result["source_sha256"]].decode()
        original_helper = subprogram(captured, helper)
        current_helper = subprogram(current.decode(), helper)
        coverage.append({
            "helper": helper,
            "managed_run": result["managed_run"],
            "original_returncode": result["returncode"],
            "source_sha256": result["source_sha256"],
            "result_path": result["result_path"],
            "native_report_sha256": digest(report.read_bytes()),
            "summary_total_checks": total,
            "helper_text_matches_current": original_helper == current_helper,
            "helper_text_sha256": digest(original_helper.encode()),
        })
    output = {
        "scope": "Whole-helper focused checks over declared domains; not complete native or feature assurance",
        "current_source_sha256": digest(current),
        "coverage": coverage,
        "pending": [name for name in HELPERS if name not in successes],
        "applicability": "Helper text comparison records the local declaration/body only; dependency applicability and final complete audits remain required.",
    }
    (EVIDENCE / "coverage.json").write_text(json.dumps(output, indent=2) + "\n")
    print(json.dumps({"covered": len(coverage), "pending": output["pending"],
                      "changed_since_success": [row["helper"] for row in coverage
                                                if not row["helper_text_matches_current"]]}))


if __name__ == "__main__":
    main()

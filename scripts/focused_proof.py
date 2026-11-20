"""Whole-compiler-unit and whole-subprogram checks in the managed native runner."""

from __future__ import annotations

from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re

if __package__:
    from .check_evidence import PROOF_OPTIONS, read_json, require
else:
    from check_evidence import PROOF_OPTIONS, read_json, require


@dataclass(frozen=True)
class FocusedProof:
    file: str
    line: int | None = None

    @classmethod
    def select(cls, unit: str | None, subprogram: str | None) -> FocusedProof | None:
        if unit is None and subprogram is None:
            return None
        filename = r"([a-zA-Z][a-zA-Z0-9_-]*\.ad[bs])"
        if unit is not None:
            require(re.fullmatch(filename, unit), "--unit requires a compiler source filename")
            return cls(unit)
        match = re.fullmatch(filename + r":([1-9][0-9]*)", subprogram)
        require(match, "--subprogram requires a compiler declaration FILE:LINE")
        return cls(match[1], int(match[2]))

    def scope(self) -> list[str]:
        selector = self.file if self.line is None else f"--limit-subp={self.file}:{self.line}"
        return ["compiler", selector]

    def options(self, source: Path) -> list[str]:
        if self.line is not None:
            return [*PROOF_OPTIONS, f"--limit-subp={self.file}:{self.line}"]
        # Select the entire unit, including its body when given a spec.
        body = source.with_suffix(".adb")
        return [*(arg for arg in PROOF_OPTIONS if arg != "-U"), "-u",
                body.name if body.is_file() else self.file]

    def check_report(self, reports: Path, command: list[str]) -> dict:
        """Check that this invocation actually analyzed the requested selection."""
        report = read_json(reports / (Path(self.file).stem + ".spark"))
        require(report.get("progress") == "PROGRESS_PROOF" and report.get("stop_reason") == "STOP_REASON_NONE",
                "focused proof did not finish analysis")
        require(all(report.get(key) == [] for key in ("skip_flow_proof", "skip_proof", "pragma_assume")),
                "focused proof has skipped checks or assumptions")
        coverage = report.get("spark", {})
        selected = [entity["name"] for key, entity in report.get("entities", {}).items()
                    if coverage.get(key) == "all" and any(
                        (Path(loc["file"]).stem == Path(self.file).stem if self.line is None
                         else (loc["file"], loc["line"]) == (self.file, self.line))
                        for loc in entity.get("sloc", []))]
        require(selected, "no fully analyzed entity at the requested focused selection")
        for category in ("flow", "proof"):
            checks = report.get(category)
            require(isinstance(checks, list) and all(
                item.get("severity") == "info" and item.get("how_proved") in ("flow", "prover", "trivial")
                and not any(item.get(key) for key in ("justification", "justified", "suppressed", "annot_kind", "justif_msg"))
                for item in checks), f"missing or unresolved focused {category} checks")
        runs = read_json(reports / "gnatprove.sarif").get("runs", [])
        invocations = runs[0].get("invocations", []) if len(runs) == 1 else []
        require(len(invocations) == 1 and invocations[0].get("executionSuccessful") is True
                and invocations[0].get("exitCode") == 0 and invocations[0].get("commandLine") == " ".join(command),
                "focused reports do not match the effective GNATprove invocation")
        summary = {"entity_count": len(selected), "flow_checks": len(report["flow"]),
                   "proof_checks": len(report["proof"])}
        if self.line is not None:
            summary["subprograms"] = selected
        return summary


def focused_workspace(objects: Path) -> Path:
    policy = json.dumps(PROOF_OPTIONS).encode()
    return objects / "focused" / hashlib.sha256(policy).hexdigest()[:16]


def prepare_focused_workspace(workspace: Path) -> None:
    """Only reuse the reserved state initialized empty for this exact policy."""
    marker = workspace / "proof-options.json"
    if workspace.exists():
        require(marker.is_file() and json.loads(marker.read_text()) == PROOF_OPTIONS,
                "unrecognized focused proof workspace; preserve it separately before initializing")
    else:
        workspace.mkdir(parents=True)
        marker.write_text(json.dumps(PROOF_OPTIONS) + "\n")

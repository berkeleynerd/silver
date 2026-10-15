#!/usr/bin/env python3
"""Prepare and import Silver coverage assessments of the Rosetta Code tasks.

`prepare` writes a runnable copy of assess.js listing the tasks that still need
an assessment, each with its model tier. Run that copy with Claude Code's
Workflow tool, then pass the run's transcript directory to `import`, which
merges each task's final verdict into coverage.json. Then run refresh.py to
update rosetta.md and the per-task silver.md files.
"""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sys
import tempfile

HERE = Path(__file__).resolve().parent
TEMPLATE = HERE / "assess.js"
COVERAGE = HERE / "coverage.json"
MANIFEST = HERE / "manifest.json"
PLACEHOLDER = "const TASKS = [] // assess.py prepare fills this in"
ROOT_PLACEHOLDER = "const ROOT = '' // assess.py prepare fills this in"
MODELS = {"light": ("claude-haiku-5-5", "low"), "standard": ("claude-sonnet-5-5", "medium"),
          "deep": ("claude-opus-5-5", "high")}
# Rubric 2 adds the language surface, proof outlook, risks, size and approach to each assessment.
RUBRIC = 2
FIELDS = ("conflicts", "effects", "surface", "outlook", "risks", "size", "approach", "features", "summary",
          "confidence")
DEFAULT_POLICY = {"allowed_effects": ["console-output", "arguments", "exit-status", "stdin", "files"],
                  "excluded_constructs": []}
# A workflow runs at most 1000 agents; leave room for escalations.
CHUNK = 800

DEEP_CATEGORIES = {"programming language concepts", "programming environment operations", "concurrency",
                   "recursion", "object oriented", "control structures", "basic data operations"}
DEEP_REQUIRES = {"concurrency", "first class functions", "objects", "mutable state", "signal handling"}
DEEP_TITLE = re.compile(r"(exception|assert|overflow|undefined|run.?time|pointer|reference|memory|garbage|"
                        r"stack|recursion|closure|eval|introspection|reflection|metaprogram|pragma|contract|"
                        r"unit test|compile.?time|dynamic|variadic|polymorph|inherit|dispatch|first.class|"
                        r"higher.order|generic|null object|scope|variables|signal|exit|termination|"
                        r"environment|program name|shell|foreign|machine code|assembly|inline|concurren|"
                        r"thread|parallel|synchron|semaphore|mutex|atomic|singleton|delegat|anonymous|"
                        r"currying|partial function|function composition|y combinator|extend your language|"
                        r"modulino|interactive|enforced immutability|constrained|subtype|safe |unsafe|address|"
                        r"flow.control|goto|jump|continuation|coroutine|generator|iterator|lazy|"
                        r"call a function|named parameters|optional parameters|return multiple|"
                        r"special characters|string interpolation|literals|integer sequence|loops/infinite|"
                        r"arithmetic/integer|reverse words|command-line|program termination|deepcopy|"
                        r"copy a string)", re.I)
REQUIRES = re.compile(r"\{\{requires\|([^}|]+)", re.I)
TASK_CATEGORY = re.compile(r"\{\{(?:draft )?task\|([^}|]+)", re.I)


def tier(title: str, description: str) -> str:
    """Pick a model tier: deep for tasks near the Oracle's limits, standard otherwise."""
    requires = {r.strip().lower() for r in REQUIRES.findall(description)}
    categories = {c.strip().lower() for c in TASK_CATEGORY.findall(description)}
    if DEEP_TITLE.search(title) or categories & DEEP_CATEGORIES or requires & DEEP_REQUIRES:
        return "deep"
    return "standard"


def candidate(entry: dict, policy: dict) -> bool:
    return (not entry["conflicts"]
            and all(effect["effect"] in policy["allowed_effects"] for effect in entry["effects"]))


def needs_assessment(task: dict, entry: dict | None, policy: dict) -> bool:
    """New and changed tasks need an assessment, and so do candidates assessed under an older rubric."""
    if not entry or entry["revision"] != task["revision"]:
        return True
    return candidate(entry, policy) and entry.get("rubric", 1) < RUBRIC


def read_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def load_coverage(path: Path) -> dict:
    if path.is_file():
        return read_json(path)
    return {"schema_version": 1, "policy": DEFAULT_POLICY, "supported": [], "tasks": {}}


def prepare(args: argparse.Namespace) -> None:
    coverage = load_coverage(args.coverage)
    chosen = []
    for task in read_json(MANIFEST)["tasks"]:
        if args.title and task["title"] not in args.title:
            continue
        done = coverage["tasks"].get(task["title"])
        if not (args.all or args.title or needs_assessment(task, done, coverage["policy"])):
            continue
        description = (HERE / task["path"] / "task.wiki").read_text(encoding="utf-8")
        files = ["task.wiki"]
        for solution in task["solutions"]:
            if "wiki" in solution:
                files += [solution["wiki"], *(page["wiki"] for page in solution.get("subpages", []))]
        chosen.append({"title": task["title"], "path": task["path"], "revision": task["revision"],
                       "status": task["status"], "files": files, "tier": tier(task["title"], description)})
    if args.limit:
        chosen = chosen[:args.limit]
    template = TEMPLATE.read_text(encoding="utf-8")
    for line in (PLACEHOLDER, ROOT_PLACEHOLDER):
        if template.count(line) != 1:
            raise SystemExit(f"{TEMPLATE} must contain the line: {line}")
    script = (template.replace(PLACEHOLDER, "const TASKS = " + json.dumps(chosen, ensure_ascii=False))
              .replace(ROOT_PLACEHOLDER, "const ROOT = " + json.dumps(str(HERE) + "/")))
    args.output.write_text(script, encoding="utf-8")
    tiers = {name: sum(t["tier"] == name for t in chosen) for name in MODELS}
    print(f"{len(chosen)} tasks {tiers} written to {args.output}")
    for start in range(0, len(chosen), CHUNK):
        print(f'  run with args {{"start": {start}, "end": {min(start + CHUNK, len(chosen))}}}')


def import_runs(args: argparse.Namespace) -> None:
    coverage = load_coverage(args.coverage)
    coverage.setdefault("policy", DEFAULT_POLICY)
    current = {task["title"]: task["revision"] for task in read_json(MANIFEST)["tasks"]}
    today = datetime.now(timezone.utc).date().isoformat()
    imported, missing, unknown = 0, [], []
    for run in args.runs:
        started: dict[str, tuple[str, str]] = {}
        results: dict[str, dict] = {}
        for line in (run / "journal.jsonl").read_text(encoding="utf-8").splitlines():
            entry = json.loads(line)
            if entry.get("type") == "started":
                started[entry["agentId"]] = (entry["label"], entry.get("phase", "Assess"))
            elif entry.get("type") == "result" and isinstance(entry.get("result"), dict):
                results[entry["agentId"]] = entry["result"]
        by_task: dict[tuple[str, int], dict[str, tuple[str, dict | None]]] = {}
        for agent_id, (label, phase) in started.items():
            name, rest = label.split(":", 1)
            title, revision = rest.rsplit("@", 1)
            by_task.setdefault((title, int(revision)), {})[phase] = (name, results.get(agent_id))
        for (title, revision), phases in sorted(by_task.items()):
            first, second = phases.get("Assess"), phases.get("Escalate")
            final = second if second and second[1] else first
            if not final or not final[1]:
                missing.append(title)
                continue
            if title not in current:
                unknown.append(title)
                continue
            name, result = final
            model, effort = MODELS[name]
            entry = {"revision": revision, "assessed": today, "rubric": RUBRIC if "outlook" in result else 1,
                     "tier": name, "model": model, "effort": effort}
            if final is second and first:
                entry["escalated_from"] = MODELS[first[0]][0]
            entry.update({key: result[key] for key in FIELDS if key in result})
            coverage["tasks"][title] = entry
            imported += 1
    coverage["tasks"] = dict(sorted(coverage["tasks"].items(), key=lambda item: (item[0].casefold(), item[0])))
    args.coverage.write_text(json.dumps(coverage, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    pending = [task["title"] for task in read_json(MANIFEST)["tasks"]
               if needs_assessment(task, coverage["tasks"].get(task["title"]), coverage["policy"])]
    print(f"imported {imported}; coverage holds {len(coverage['tasks'])} tasks; "
          f"{len(pending)} still need an assessment")
    if missing:
        print(f"warning: no usable result for {len(missing)} tasks: {missing[:10]}", file=sys.stderr)
    if unknown:
        print(f"warning: {len(unknown)} titles are no longer in the manifest: {unknown[:10]}", file=sys.stderr)


def main(arguments: list[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)
    make = commands.add_parser("prepare", help="write a runnable assessment workflow")
    make.add_argument("--all", action="store_true", help="reassess every task, not only new or changed ones")
    make.add_argument("--title", action="append", help="assess only this task (repeatable)")
    make.add_argument("--limit", type=int, help="assess at most this many tasks")
    make.add_argument("--output", type=Path, default=Path(tempfile.gettempdir()) / "rosetta-assess.js",
                      help="where to write the workflow (default: %(default)s)")
    take = commands.add_parser("import", help="merge workflow results into coverage.json")
    take.add_argument("runs", nargs="+", type=Path, help="workflow transcript directories")
    for command in (make, take):
        command.add_argument("--coverage", type=Path, default=COVERAGE,
                             help="assessment file to read and update (default: %(default)s)")
    args = parser.parse_args(arguments)
    if sys.version_info < (3, 11):
        parser.error("Python 3.11 or newer is required")
    prepare(args) if args.command == "prepare" else import_runs(args)


if __name__ == "__main__":
    main()

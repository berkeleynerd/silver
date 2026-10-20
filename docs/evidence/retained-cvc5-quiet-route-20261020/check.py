#!/usr/bin/env python3
"""Offline identity, configuration-difference and local-length checks.

This never invokes native tools, reads live installation files or proves C++/
OCaml control-flow semantics. The accompanying note states those arguments.
"""
from __future__ import annotations

import difflib
import hashlib
import json
from pathlib import Path
import re
import tarfile
import time


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
ARCHIVES: dict[str, tarfile.TarFile] = {}


def read_json(name):
    return json.loads((HERE / name).read_text())


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def member(archive, name):
    if archive not in ARCHIVES:
        ARCHIVES[archive] = tarfile.open(ROOT / archive)
    stream = ARCHIVES[archive].extractfile(name)
    assert stream is not None
    return stream.read()


def assert_identity(data, expected):
    assert identity(data) == {key: expected[key] for key in ("bytes", "sha256")}


def growth(lengths):
    capacity = 17
    reached = [capacity]
    for length in lengths:
        while capacity < length:
            capacity *= 2
            reached.append(capacity)
    return reached


def main():
    start = time.monotonic()
    inputs = read_json("inputs.json")
    for path, expected in inputs["files"].items():
        assert_identity((ROOT / path).read_bytes(), expected)

    sources = read_json("sources.json")
    for row in sources:
        data = member(row["archive"], row["member"])
        assert_identity(data, row)
        lines = data.decode().splitlines(keepends=True)
        for witness in row["witnesses"]:
            assert "".join(lines[witness["begin"] - 1:witness["end"]]) == witness["text"]

    route = read_json("route.json")
    baseline = route["baseline"]
    base = member(baseline["archive"], baseline["member"])
    assert_identity(base, baseline)
    candidate = (HERE / route["candidate"]["path"]).read_bytes()
    assert_identity(candidate, route["candidate"])
    old, new = route["command"]["old"], route["command"]["new"]
    base_sections = base.decode().split("[prover]")
    new_sections = candidate.decode().split("[prover]")
    assert len(base_sections) == len(new_sections) == 10
    differences = []
    for before, after in zip(base_sections, new_sections):
        if before != after:
            differences.append(before)
            assert '\nname = "CVC5"\n' in before
            assert '\nshortcut = "cvc5"\n' in before
            assert '\nversion = "0.0.7-gnatprove"\n' in before
            needle = f'command = "{old}"'
            assert before.count(needle) == 1
            assert after == before.replace(needle, f'command = "{new}"')
    assert len(differences) == 1
    expected_diff = "".join(difflib.unified_diff(
        base.decode().splitlines(True), candidate.decode().splitlines(True),
        fromfile=baseline["archive"] + "!" + baseline["member"],
        tofile="prospective-cwd/why3.conf"))
    assert (HERE / "candidate-base.diff").read_text() == expected_diff
    assert (HERE / "candidate-extra-why3.conf").read_bytes() == member(
        baseline["archive"], "overlay/why3.conf") == b"[main]\nmagic = 14\n"

    # The exact strings use only the normal/unquoted cmdline_split path.
    assert not any(c in new for c in "\t\r\n\x00;'\"\\")
    argv = new.split(" ")
    assert argv == route["command"]["argv_template"]
    assert argv == [route["command"]["executable"], "--prenex-quant=none", "--quiet", "%f"]
    assert Path(argv[0]).is_absolute() and Path(argv[0]).name == "cvc5"
    assert (len(old), len(new), len(argv[0]), len(new) - len(old)) == (44, 167, 136, 123)
    assert (len(base), len(candidate)) == (1946, 2069)
    old_strings = re.findall(r'= "([^"\n]*)"', base.decode())
    new_strings = re.findall(r'= "([^"\n]*)"', candidate.decode())
    assert len(old_strings) == len(new_strings) == 56
    assert len(base.splitlines()) == len(candidate.splitlines()) == 71
    assert (max(map(len, old_strings)), max(map(len, new_strings))) == (61, 167)
    assert growth(list(map(len, old_strings))) == [17, 34, 68]
    assert growth(list(map(len, new_strings))) == [17, 34, 68, 136, 272]
    assert sum(map(len, old.split())) == 41 and sum(map(len, argv)) == 164
    assert max(map(len, old.split())) == 19 and max(map(len, argv)) == 136
    assert route["complete_q"] is None and route["weighted_O"] is None
    assert route["global_budget"] == {"save_entering_callbacks": 2, "save_attempts": 3, "e_max": 2}

    occurrence_record = read_json("option-occurrences.json")
    occurrence_actual = {key: [] for key in occurrence_record["patterns"]}
    cvc5_archive = "docs/evidence/retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz"
    prefix = "cvc5-86cecd83b685f59e884094693b9a4c5c90a62e03/src/"
    for item in ARCHIVES[cvc5_archive].getmembers():
        if not item.isfile() or not item.name.startswith(prefix):
            continue
        try:
            lines = member(cvc5_archive, item.name).decode().splitlines()
        except UnicodeDecodeError:
            continue
        for key, pattern in occurrence_record["patterns"].items():
            for line_number, line in enumerate(lines, 1):
                if re.search(pattern, line):
                    occurrence_actual[key].append({"member": item.name, "line": line_number, "text": line})
    assert occurrence_actual == occurrence_record["matches"]

    drivers = read_json("driver-response-directives.json")
    directives = []
    for row in drivers:
        data = member(row["archive"], row["member"])
        assert_identity(data, row)
        actual = [{"line": i, "text": line} for i, line in enumerate(data.decode().splitlines(), 1)
                  if re.match(r"\s*(?:valid|invalid|unknown|failure|outofmemory|timeout|steplimitexceeded|time|steps|exitcode|filename|printer)\b", line)]
        assert actual == row["directives"]
        directives.extend(x["text"].strip() for x in actual)
    assert not any(line.startswith("steps ") for line in directives)
    assert [line for line in directives if line.startswith("time ")] == ['time "why3cpulimit time : %s s"']
    assert 'filename "%f-%t-%g.smt2"' in directives
    assert 'printer "smtv2.6"' in directives

    checked_links = 0
    for doc in [ROOT / "docs/research/retained-cvc5-quiet-route.md", HERE / "README.md"]:
        for target in re.findall(r"\]\(([^)]+)\)", doc.read_text()):
            if "://" in target or target.startswith("#"):
                continue
            assert (doc.parent / target.split("#")[0]).resolve().exists(), target
            checked_links += 1
    print(json.dumps({"status": "passed", "source_files": len(sources),
                      "input_files": len(inputs["files"]), "cvc5_driver_files": len(drivers),
                      "option_occurrences": {key: len(rows) for key, rows in occurrence_actual.items()},
                      "checked_local_link_targets": checked_links,
                      "elapsed_seconds": round(time.monotonic() - start, 6)}, indent=2))


if __name__ == "__main__":
    main()

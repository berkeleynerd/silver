#!/usr/bin/env python3
"""Offline source/capture projection and bounded Hashtbl resize model.

No native program, disassembler, solver, old checker, or network is invoked.
The hypothetical repair pass is deliberately NOT a selected-control witness.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import tarfile


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CAPTURE = "docs/evidence/retained-why-save-state-capture-20261020"
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
OLD = "docs/evidence/retained-why-save-hashtbl-prefix-20261020"
CASES = ["put-line", "put", "first-or-default", "is-message", "input-is-valid"]
SOURCE_RANGES = [
    (OCAML, "stdlib/hashtbl.ml", 20, 43, "layout-and-inplace"),
    (OCAML, "stdlib/hashtbl.ml", 113, 152, "resize"),
    (OCAML, "stdlib/hashtbl.ml", 345, 363, "index-and-add"),
    (OCAML, "stdlib/hashtbl.ml", 439, 455, "replace"),
    (OCAML, "stdlib/hashtbl.ml", 477, 485, "unseeded-functor"),
    (WHY, "src/core/ident.ml", 159, 172, "hid"),
    (WHY, "src/util/wstdlib.ml", 60, 100, "tag-functors"),
    (WHY, "src/util/weakhtbl.ml", 50, 58, "tag-hash"),
    (WHY, "src/util/exthtbl.ml", 40, 48, "exthtbl"),
    (WHY, "src/session/session_itp.ml", 750, 758, "theory-query"),
    (WHY, "src/session/session_itp.ml", 798, 828, "theory-file-updates"),
    (WHY, "src/session/session_itp.ml", 833, 878, "status-commit-order"),
    (WHY, "src/session/session_itp.ml", 2150, 2172, "serializer"),
    (WHY, "src/util/loc.ml", 302, 306, "loc-error"),
    (WHY, "src/util/loc.ml", 338, 341, "loc-errorm"),
    (WHY, "src/session/controller_itp.ml", 409, 440, "build-catch"),
    (WHY, "src/session/controller_itp.ml", 517, 536, "idle-catch"),
    (WHY, "src/session/controller_itp.ml", 592, 617, "failure-status-update"),
    (WHY, "src/gnat/gnat_main.ml", 94, 120, "gnat-result"),
    (WHY, "src/gnat/gnat_main.ml", 298, 309, "nonreturning-save"),
]


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def encode(value):
    return json.dumps(value, indent=2, sort_keys=True) + "\n"


def sources():
    result = []
    for archive in [OCAML, WHY]:
        with tarfile.open(ROOT / archive) as tar:
            for arc, suffix, first, last, name in SOURCE_RANGES:
                if arc != archive:
                    continue
                members = [m for m in tar.getmembers() if m.name.endswith("/" + suffix)]
                assert len(members) == 1
                member = members[0]
                raw = tar.extractfile(member).read()
                result.append({
                    "id": name, "archive": archive, "member": member.name,
                    "member_identity": identity(raw), "first_line": first,
                    "last_line": last,
                    "text": "\n".join(raw.decode().splitlines()[first - 1:last]) + "\n",
                })
    return result


def captures():
    manifest = json.loads((ROOT / CAPTURE / "capture-manifest.json").read_text())
    result = []
    for case in CASES:
        name = f"capture-{case}.tar.gz"
        entry = next(a for a in manifest["archives"] if a["path"] == name)
        raw_archive = (ROOT / CAPTURE / name).read_bytes()
        assert identity(raw_archive) == {k: entry[k] for k in ["bytes", "sha256"]}
        with tarfile.open(ROOT / CAPTURE / name) as tar:
            members = [m for m in tar.getmembers() if m.name.endswith("/capture/save-missing-state.json")]
            assert len(members) == 1
            member = members[0]
            raw = tar.extractfile(member).read()
        recorded = next(m for m in entry["members"] if m["path"] == member.name)
        assert identity(raw) == {k: recorded[k] for k in ["bytes", "sha256"]}
        value = json.loads(raw)["sections"]
        table = value["theory_state"]["value"]
        assert table["size"] == table["binding_visits"] == 0
        assert table["bucket_capacity"] == table["initial_size"] == 16
        assert table["seed"] == 0 and table["bucket_heads"] == [1] * 16
        assert table["disjoint_finite_chains"] and not table["entries"]
        files = value["serializer"]["value"]["files"]
        assert len(files) == 1 and not files[0]["detached"]
        theories = files[0]["theories"]
        keys = [t["name"]["id_tag"] for t in theories]
        assert len(set(keys)) == len(keys) and all(k >= 0 for k in keys)
        assert all(not t["detached"] for t in theories)
        assert all(not t["goals"] for t in theories[:-1])
        assert len(theories[-1]["goals"]) == 1
        bound = len(keys) + 2
        result.append({
            "case": case, "archive": f"{CAPTURE}/{name}",
            "archive_identity": identity(raw_archive), "member": member.name,
            "member_identity": identity(raw),
            "entry": {k: table[k] for k in ["size", "binding_visits", "bucket_capacity", "seed", "initial_size", "bucket_heads", "disjoint_finite_chains"]},
            "ordered_theory_tags": keys, "theory_count": len(keys),
            "sole_nonempty_theory_tag": keys[-1],
            "pre_first_publication_N_upper": bound,
            "initial_no_resize_guard": bound <= 32,
            "conditional_first_resize_visits_upper": 2 * bound,
            "conditional_save_only_size_upper": bound + 3,
            "conditional_save_only_visits_upper": 2 * bound + 3,
        })
    return result


class Table:
    """Identity-preserving mutable links; integer cell IDs are not keys."""
    def __init__(self):
        self.roots = [None] * 16
        self.cells = []
        self.size = 0

    def add(self, key):
        idx = key & (len(self.roots) - 1)
        self.cells.append([key, self.roots[idx]])
        self.roots[idx] = len(self.cells) - 1
        self.size += 1

    def chains(self):
        result = []
        for head in self.roots:
            seen = []
            while head is not None and head not in seen:
                seen.append(head)
                head = self.cells[head][1]
            result.append((seen, head))
        return result

    def find(self, key):
        cur = self.roots[key & (len(self.roots) - 1)]
        seen = set()
        while cur is not None:
            assert cur not in seen, "cyclic model lookup"
            seen.add(cur)
            if self.cells[cur][0] == key:
                return True
            cur = self.cells[cur][1]
        return False

    def snapshot(self):
        return {"size": self.size, "capacity": len(self.roots),
                "roots": self.roots[:], "cells_key_next": copy.deepcopy(self.cells)}

    def resize(self):
        old = self.roots
        self.roots = [None] * (len(old) * 2)
        tails = [None] * len(self.roots)
        yield {"event": "published_empty_array", "native_poll": "0x981526"}
        for bucket, head in enumerate(old):
            cur = head
            seen = set()
            while cur is not None:
                # A shared input may become cyclic during relinking. Report
                # rather than treating finite model execution as termination.
                if cur in seen:
                    yield {"event": "revisited_input_cell", "old_bucket": bucket}
                    return
                seen.add(cur)
                key, nxt = self.cells[cur]  # source saves next BEFORE writes
                idx = key & (len(self.roots) - 1)
                if tails[idx] is None:
                    self.roots[idx] = cur
                else:
                    self.cells[tails[idx]][1] = cur
                tails[idx] = cur
                yield {"event": "inserted_cell", "old_bucket": bucket,
                       "cell": cur, "key": key, "new_bucket": idx,
                       "native_poll": "0x981684"}
                cur = nxt
        for idx, tail in enumerate(tails):
            if tail is not None:
                self.cells[tail][1] = None
            yield {"event": "finalized_tail", "bucket": idx,
                   "native_poll": "0x98163e" if idx < len(tails) - 1 else None}


def first_resize_model(case):
    keys = case["ordered_theory_tags"]
    nonempty = keys[-1]
    table = Table()
    insertion_order = [nonempty] + keys[:-1]
    for key in insertion_order:
        table.add(key)
        if table.size == 33:
            break
    assert table.size == 33
    initial = table.snapshot()
    ranks = {}
    for bucket, (chain, repeated) in enumerate(table.chains()):
        assert repeated is None
        for rank, cell in enumerate(chain):
            assert cell not in ranks
            ranks[cell] = (bucket, rank)
    prefixes = []
    for event in table.resize():
        assert event["event"] != "revisited_input_cell"
        for cell, (_, nxt) in enumerate(table.cells):
            if nxt is not None:
                assert ranks[cell][0] == ranks[nxt][0]
                assert ranks[cell][1] < ranks[nxt][1]
        chains = table.chains()
        assert all(repeated is None for _, repeated in chains)
        visits = sum(len(chain) for chain, _ in chains)
        assert visits <= 2 * 33
        prefixes.append((event, copy.deepcopy(table), visits))
    assert all(table.find(key) for key in insertion_order[:33])
    assert sum(len(c) for c, _ in table.chains()) == 33
    witness = None
    trigger_count = 0
    for index, (first_event, prefix, _) in enumerate(prefixes):
        repair = copy.deepcopy(prefix)
        log = []
        for origin, query_keys in [("nested-save-query", [nonempty]),
                                   ("HYPOTHETICAL-later-file-query", keys)]:
            for key in query_keys:
                found = repair.find(key)
                if not found:
                    repair.add(key)
                log.append({"origin": origin, "key": key,
                            "added": not found, "size_after": repair.size})
                if repair.size > 2 * len(repair.roots):
                    trigger_count += 1
                    assert repair.size == 65
                    second_start = repair.snapshot()
                    for second_event in repair.resize():
                        cycles = [(i, c, r) for i, (c, r) in enumerate(repair.chains()) if r is not None]
                        if cycles:
                            if witness is None:
                                bucket, cells, repeated = cycles[0]
                                witness = {
                                    "selected_control_reachability_proved": False,
                                    "first_prefix_index": index,
                                    "first_event": first_event,
                                    "first_prefix": prefix.snapshot(),
                                    "query_log": log,
                                    "second_start": second_start,
                                    "second_event": second_event,
                                    "cyclic_state": repair.snapshot(),
                                    "cycle_bucket": bucket, "cycle_path_cells": cells,
                                    "cycle_path_keys": [repair.cells[c][0] for c in cells],
                                    "repeated_cell": repeated,
                                }
                            break
                    break
            else:
                continue
            break
    assert witness is not None
    return {"case": case["case"], "initial_before_resize": initial,
            "initial_order": insertion_order[:33], "first_prefixes_checked": len(prefixes),
            "all_first_prefixes_acyclic": True,
            "first_prefix_max_visits": max(v for _, _, v in prefixes),
            "first_prefixes_with_shared_cells": sum(v > len({c for chain, _ in t.chains() for c in chain}) for _, t, v in prefixes),
            "hypothetical_repair_prefixes_triggering_second_resize": trigger_count,
            "countermodel": witness}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="write deterministic projections/results")
    args = parser.parse_args()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs["files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    projection = captures()
    results = {"scope": "offline first-resize checks and hypothetical repair countermodels",
               "selected_route_capacity_closed": False,
               "models": [first_resize_model(c) for c in projection if not c["initial_no_resize_guard"]]}
    outputs = {"capture-projection.json": projection,
               "source-excerpts.json": sources(), "model-result.json": results}
    for filename, value in outputs.items():
        actual = encode(value)
        if args.write:
            (HERE / filename).write_text(actual)
        else:
            assert (HERE / filename).read_text() == actual, filename
    print(encode({"status": "pass", "captures": len(projection),
                  "model_cases": len(results["models"]),
                  "first_prefixes": sum(m["first_prefixes_checked"] for m in results["models"]),
                  "selected_control_reachability_proved": False}).strip())


if __name__ == "__main__":
    main()

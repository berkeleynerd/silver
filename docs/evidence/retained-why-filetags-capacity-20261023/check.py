#!/usr/bin/env python3
"""New FileTags source/arithmetic checks; no predecessor or target execution."""
import hashlib
import itertools
import json
import pathlib
import re
import tarfile
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EVIDENCE = ROOT / "docs/evidence"
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
LIBS = "docs/evidence/retained-producer-import-context-20261018/sources.tar.gz"
OP = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
ORDER = ["put_line", "put", "first_or_default", "is_message", "input_is_valid"]
checks = 0
archives = {}


def require(condition, label):
    global checks
    checks += 1
    if not condition:
        raise AssertionError(label)


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def load(path):
    return json.loads(path.read_text())


def dump(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def archive(path):
    if path not in archives:
        archives[path] = tarfile.open(ROOT / path)
    return archives[path]


def member(path, name):
    f = archive(path).extractfile(name)
    require(f is not None, f"regular member {path}:{name}")
    return f.read()


def chain(root, links):
    visited = []
    while root is not None:
        require(root not in visited, "acyclic physical chain")
        visited.append(root)
        root = links[root]
    return visited


def find(key, hashes, keys, roots, links):
    return any(keys[cell] == key for cell in chain(roots[hashes[key] % len(roots)], links))


def rehash_prefixes(hashes, keys, old_roots, old_links):
    """Literal pointer model of inplace insert_all_buckets, at every store.

    A snapshot after publishing empty data covers failure allocating tails.
    Stores to roots/next and tails are separate snapshots, overapproximating
    the admitted native polls. This is finite corroboration, not the proof.
    """
    roots = [None] * (2 * len(old_roots))
    tails = roots.copy()
    links = old_links.copy()
    yield roots.copy(), links.copy(), "empty-published"
    for root in old_roots:
        cell = root
        while cell is not None:
            nxt = links[cell]
            idx = hashes[keys[cell]] % len(roots)
            if tails[idx] is None:
                roots[idx] = cell
            else:
                links[tails[idx]] = cell
            yield roots.copy(), links.copy(), "root-or-link-store"
            tails[idx] = cell
            yield roots.copy(), links.copy(), "tail-store"
            cell = nxt
    for tail in tails:
        if tail is not None:
            links[tail] = None
            yield roots.copy(), links.copy(), "tail-cut"


def small_prefix_checks():
    configurations = snapshots = continuations = second_resizes = shared = 0
    witness = None
    for b in (1, 2):  # abstract small powers; the actual table starts at 16
        n = 2*b
        for hashes in itertools.product(range(2*b), repeat=n):
            for duplicate in range(n):
                configurations += 1
                keys = list(range(n)) + [duplicate]
                roots = [None]*b
                links = {}
                for cell, key in enumerate(keys):
                    idx = hashes[key] % b
                    links[cell], roots[idx] = roots[idx], cell
                for r, l, phase in rehash_prefixes(hashes, keys, roots, links):
                    snapshots += 1
                    chains = [chain(root, l) for root in r]
                    cells = set(itertools.chain.from_iterable(chains))
                    occurrences = sum(map(len, chains))
                    require(occurrences <= 2*(n+1), "first split at most two occurrences per old cell")
                    is_shared = occurrences > len(cells)
                    if is_shared:
                        shared += 1
                        if witness is None:
                            witness = {"initial_backing": b, "hashes": hashes,
                                       "duplicate_key": duplicate, "phase": phase,
                                       "roots": r, "links": l, "keys": keys,
                                       "physical_reachable_cells": len(cells),
                                       "summed_root_occurrences": occurrences}
                    found = {k for k in range(n) if find(k, hashes, keys, r, l)}
                    require(not cells or bool(found), "nonempty prefix retains a correctly routed D0 key")
                    for order in (range(n), reversed(range(n))):
                        continuations += 1
                        rr, ll, kk = r.copy(), l.copy(), keys.copy()
                        size, restored, grows = n+1, 0, 0
                        known = found.copy()
                        for k in order:
                            if find(k, hashes, kk, rr, ll):
                                continue
                            restored += 1
                            idx = hashes[k] % len(rr)
                            c = len(kk)
                            kk.append(k)
                            ll[c], rr[idx] = rr[idx], c
                            size += 1
                            if size > 2*len(rr):
                                require(not cells, "second resize only after empty publication")
                                before = [chain(x, ll) for x in rr]
                                require(sum(map(len, before)) == len(set(itertools.chain.from_iterable(before))), "second resize input disjoint")
                                for rr, ll, _ in rehash_prefixes(hashes, kk, rr, ll):
                                    pass
                                grows += 1
                                second_resizes += 1
                            known.add(k)
                            require(all(find(x, hashes, kk, rr, ll) for x in known), "repair preserves found keys")
                        require(restored <= n-int(bool(cells)), "finite restoration bound")
                        require(grows <= 1 and len(rr) <= 4*b, "at most safe second growth")
                        require(size <= 2*n+1 and len(kk) <= 2*n+1, "counter/cell envelope")
                        require(all(find(k, hashes, kk, rr, ll) for k in range(n)), "D0 completely restored")
                        if is_shared:
                            require(grows == 0, "no second resize from shared roots")
    require(shared > 0 and second_resizes > 0, "both nontrivial branches exercised")
    return {"status": "passed", "role": "finite corroboration, not universal proof",
            "initial_backings": [1, 2], "initial_size": "2*backing",
            "hashes": "every assignment in range(2*backing)",
            "duplicate": "each D0 key", "repair_orders": ["ascending", "descending"],
            "configurations": configurations, "store_prefixes": snapshots,
            "repair_continuations": continuations, "shared_prefixes": shared,
            "safe_second_resizes": second_resizes, "shared_tail_witness": witness}


def main():
    started = time.monotonic()
    inputs = load(HERE / "inputs.json")
    for path, expected in inputs.items():
        require(identity((ROOT/path).read_bytes()) == expected, f"input {path}")
    ranges = load(HERE / "source-ranges.json")
    witnesses = []
    for row in ranges:
        data = member(row["archive"], row["member"])
        require(identity(data) == row["identity"], f"complete source {row['member']}")
        lines = data.decode().splitlines(keepends=True)
        witnesses.append(f"## {row['archive']} :: {row['member']}\n")
        for span in row["ranges"]:
            lo, hi = span["start"], span["end"]
            require(1 <= lo <= hi <= len(lines), f"strict range {row['member']}:{lo}-{hi}")
            excerpt = "".join(lines[lo-1:hi])
            require(identity(excerpt.encode()) == span["identity"], "strict range identity")
            witnesses.append(f"### Lines {lo}–{hi}\n\n```text\n{excerpt}```\n")
    (HERE/"source-witnesses.md").write_text("# FileTags source witnesses\n\n" + "\n".join(witnesses))

    # Complete archive census, including bare names and aliases rather than
    # assuming that qualified Loc.user_position exhausts source spellings.
    pattern = re.compile(r"\b(?:FileTags|get_file_tag|tag_counter|user_position|position_of_sexp)\b|\bLoc\.extract\b|\b(?:open|include)\s+(?:Why3\.)?Loc\b|\bmodule\s+\w+\s*=\s*(?:Why3\.)?Loc\b")
    census = []
    counted = 0
    for info in archive(WHY).getmembers():
        if info.isfile() and info.name.startswith(("why3/src/", "why3/plugins/")) and pathlib.Path(info.name).suffix in {".ml", ".mli", ".mll", ".mly"}:
            counted += 1
            data = member(WHY, info.name)
            hits = [{"line": i, "text": line} for i, line in enumerate(data.decode().splitlines(), 1) if pattern.search(line)]
            if hits:
                census.append({"member": info.name, "identity": identity(data), "hits": hits})
    expected = load(HERE/"census-baseline.json")
    require(census == expected["files"] and counted == expected["source_files_scanned"], "complete call/private/alias census")
    dump("call-census.json", {"source_files_scanned": counted, "files": census})
    loc = member(WHY, "why3/src/util/loc.ml").decode()
    mli = member(WHY, "why3/src/util/loc.mli").decode()
    require("FileTags" not in mli and "tag_counter" not in mli, "private table/ref interface")
    require(loc.count("FileTags.get_file_tag") == 2, "only dummy and user-position direct local callers")
    private = loc[loc.index("module FileTags = struct"):loc.index("type position =")]
    for forbidden in (".remove", ".clear", ".reset", ".replace", ".iter", ".fold", ".copy"):
        require(forbidden not in private, f"no private {forbidden}")

    startup = load(EVIDENCE/"retained-combined-parallel-startup-20261020/projection.json")
    origins = load(EVIDENCE/"retained-why-report-path-inputs-20261023/projection.json")
    libraries = load(EVIDENCE/"retained-why-report-path-inputs-20261023/library-projection.json")
    warnings = load(EVIDENCE/"retained-why-diagnostic-warnings-20261023/library-projection.json")
    roles = load(EVIDENCE/"retained-parallel-logging-prefix-20261020/input-role-projection.json")
    require(len(libraries) == 21, "complete initial library domain")
    later = warnings["later_real_root_file_parse_counts"]
    require(set(later) == {"int", "real", "algebra", "relations"}, "accepted later library family")
    library_joins = {}
    for domain in ORDER:
        opens = roles[domain]["captures"][1]["ordered_opens"]
        rows = []
        for name in later:
            suffix = "libexec/spark/share/why3/theories/" + name + ".mlw"
            candidates = [r for r in libraries if r["member"] == "installed/"+suffix]
            require(len(candidates) == 1, "later file belongs to initial complete family")
            row = candidates[0]
            data = member(LIBS, row["member"])
            require(identity(data) == row["identity"], "complete library identity")
            require(not any(row["raw_origin_token_counts"].values()), "accepted no virtual filename/raw location attribute")
            require(re.search(rb"(?m)^\s*(?:theory|module)\s+[A-Z]", data) is not None, "nonempty module/theory creates parser location")
            matches = [r for r in opens if r["path"].endswith("/"+suffix)]
            require(len(matches) == 1 and matches[0]["identity"] == row["identity"], "exact initial library role identity")
            rows.append({"library": name, "path": matches[0]["path"], "identity": row["identity"]})
        library_joins[domain] = rows
    dump("library-domain-join.json", library_joins)

    n = startup["candidate_filetags_names_upper"]
    require(n == 945214 and startup["baseline_major_words"] == 945213, "accepted common initial count bound")
    b = 1 << max(16, n).bit_length()-1
    require(b == 524288 and b <= max(16,n) < 2*b, "power-of-two initial backing upper")
    require(origins["all_FileTags_filename_upper"] == 180 and origins["alias_robust_warning_entry_upper"] == 436, "R69 unchanged filename/warning exports")
    require(origins["global_e_upper"] == 2 and origins["save_entering_callbacks_upper"] == 2 and origins["saves_upper"] == 3 and not origins["renewed_failure_budget"], "one global budget")
    cap, cells = 4*b, 2*n+2
    values = {"initial_names_upper": n, "initial_backing_upper": b,
              "suffix_forward_add_attempts_upper": n+2,
              "suffix_reverse_add_attempts_upper": n+2,
              "suffix_counter_increments_upper": n+2,
              "counter_upper": cells, "size_upper_per_table": cells,
              "physical_cells_allocated_upper_per_table": cells,
              "lookup_chain_cells_upper": cells,
              "backing_and_tail_extent_upper": cap,
              "threshold_and_attempted_doubling_upper": 2*cap,
              "single_array_bytes_including_header_upper": 8*(cap+1),
              "summed_root_occurrences_upper_per_table": cap*cells,
              "suffix_bucket_request_words_both_tables": 8*(n+2),
              "suffix_backing_tail_request_words_both_tables": 2*(2*(2*b+1)+2*(4*b+1))}
    values["suffix_bucket_array_request_words_both_tables"] = values["suffix_bucket_request_words_both_tables"] + values["suffix_backing_tail_request_words_both_tables"]
    require(cells < 2**62 and 2*cap < 2**62 and cap < 2**54-1, "integer and strict array guards")
    require(8*(cap+1) < 2**63 and cap-1 < 2**62, "byte extent and mask operands")
    for exponent in range(4, 20):
        exact_b = 2**exponent
        exact_n = 2*exact_b
        require(exact_n+1+exact_n-1 == 4*exact_b, "nonempty-prefix no-second-resize boundary")
        require(exact_n+1+exact_n == 4*exact_b+1 <= 8*exact_b, "empty-prefix safe second but no third resize")
        require(2*exact_n+2 <= 8*exact_b, "uniform no-third-growth envelope")
    domains = {}
    for domain in ORDER:
        require(startup["domains"][domain]["bounds"]["minor_words"] < 2**28, f"protected startup minor guard {domain}")
        domains[domain] = {**values, "representation_guards_pass": True,
                           "actual_N0": None, "actual_B0": None}
    dump("projection.json", {"domains": domains, "global_e_upper": 2,
                            "save_entering_callbacks_upper": 2, "saves_upper": 3,
                            "renewed_failure_budget": False,
                            "all_FileTags_filename_upper": 180,
                            "alias_robust_warning_entry_upper": 436,
                            "resource_premise": "Inherited sufficient physical resources and faithful valid native services; ordinary physical failures are not e events.",
                            "arbitrary_resumed_resource_failure_closure": False,
                            "whole_routine_allocation_bound": None,
                            "whole_process_capacity_established": False,
                            "admission_changed": False})
    small = small_prefix_checks()
    dump("small-prefix-check.json", small)
    result = {"status": "passed", "checks": checks,
              "elapsed_seconds": round(time.monotonic()-started, 6),
              "provider_files": len(inputs), "source_members": len(ranges),
              "source_ranges": sum(len(r["ranges"]) for r in ranges),
              "source_files_censused": counted, "small_model_store_prefixes": small["store_prefixes"],
              "target_runs": 0, "predecessor_checker_runs": 0,
              "proof_solver_compiler_capture_runs": 0}
    dump("result.json", result)
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()

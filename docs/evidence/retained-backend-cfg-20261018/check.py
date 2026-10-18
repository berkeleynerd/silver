#!/usr/bin/env python3
"""Reconcile pinned sources/excerpts and component arithmetic, offline.

Finite checks do not prove branch exclusion, matcher termination, dominance
correctness, or the report's universally quantified manual bounds.
"""
import argparse
import hashlib
import json
import random
from pathlib import Path

PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
RANGES = {
    "gcc/tree-cfg.cc": [(326,347), (1230,1323), (1710,1852),
                        (1853,1935), (2017,2160), (6057,6081),
                        (6083,6278), (8983,9123), (9636,9653)],
    "gcc/tree-cfgcleanup.cc": [(85,254), (292,387), (476,780),
                               (850,896), (994,1103), (1118,1267)],
    "gcc/tree-cfgcleanup.h": [(20,28)],
    "gcc/tree-ssa.cc": [(45,168)],
    "gcc/cfghooks.cc": [(502,520), (842,937)],
    "gcc/gimple-fold.cc": [(11005,11058), (11287,11296)],
    "gcc/gimple-fold.h": [(85,103), (176,186)],
    "gcc/basic-block.h": [(353,365)],
    "gcc/dominance.cc": [(48,55), (148,219), (302,391), (516,545),
                         (637,686), (720,765), (873,892), (947,984),
                         (1165,1200), (1232,1558)],
    "gcc/dominance.h": [(67,79)],
    "gcc/et-forest.cc": [(37,83), (114,135), (295,445), (463,774)],
    "gcc/et-forest.h": [(62,81)],
    "gcc/alloc-pool.h": [(160,198), (261,307), (351,430)],
    "gcc/memory-block.h": [(25,84)],
    "gcc/graphds.h": [(22,49)],
    "gcc/graphds.cc": [(47,111), (198,330), (357,478)],
    "gcc/cfgloop.cc": [(225,313), (338,379), (416,529),
                       (1392,1565), (1630,1747), (2129,2186)],
    "gcc/cfgloop.h": [(306,323), (639,656), (685,843)],
    "gcc/loop-init.cc": [(42,134)],
    "gcc/cfganal.cc": [(979,1088)],
}


def collect(root):
    upstream = json.loads((root / "manifest.json").read_text())
    assert upstream["commit"] == PIN
    upstream_files = {row["path"]: row for row in upstream["files"]}
    manifest, sources = [], {}
    excerpts = ["# Pinned CFG cleanup and loop source excerpts\n\n",
                "Full-file SHA256 identities are in source-manifest.json.\n",
                "LF line numbering; tabs expanded and trailing space trimmed.\n"]
    for name, ranges in RANGES.items():
        data = (root / name).read_bytes()
        identity = {"path": name, "bytes": len(data),
                    "sha256": hashlib.sha256(data).hexdigest()}
        assert identity == upstream_files[name], f"upstream mismatch: {name}"
        manifest.append(identity)
        sources[name] = data.decode()
        lines = sources[name].splitlines()
        for lo, hi in ranges:
            assert 1 <= lo <= hi <= len(lines), (name, lo, hi, len(lines))
            excerpts.append(f"\n## {name}:{lo}–{hi}\n\n```text\n")
            excerpts.extend((f"{n}: " + lines[n-1].expandtabs(8)).rstrip()+"\n"
                            for n in range(lo, hi+1))
            excerpts.append("```\n")
    return sources, {"commit": PIN, "files": manifest}, "".join(excerpts)


def source_checks(s):
    cfg = s["gcc/tree-cfg.cc"]
    start = cfg.index("execute_build_cfg (void)")
    run = cfg[start:start+800]
    assert run.index("cleanup_tree_cfg ();") < run.index(
        "loop_optimizer_init (AVOID_CFG_MODIFICATIONS);") < run.index(
        "replace_loop_annotate ();")
    assert "extern bool cleanup_tree_cfg (unsigned = 0);" in s[
        "gcc/tree-cfgcleanup.h"]
    assert "#define AVOID_CFG_MODIFICATIONS (LOOPS_MAY_HAVE_MULTIPLE_LATCHES)" in s[
        "gcc/cfgloop.h"]
    assert "if (can_split && has_phi)" in s["gcc/tree-cfgcleanup.cc"]
    assert "if (ssa_update_flags)" in s["gcc/tree-cfgcleanup.cc"]
    assert "e = redirect_edge_succ_nodup (e, dest);" in s["gcc/tree-ssa.cc"]
    assert "index = gimple_convert (&seq, utype, index);" in cfg
    assert "*lhs = gimple_build (&seq, MINUS_EXPR, utype, index, low);" in cfg
    assert "res = make_ssa_name (type);" in s["gcc/gimple-fold.cc"]
    assert "int mark = 1, i, v, idom;" in s["gcc/graphds.cc"]
    assert "idom = tree_nca (idom, e->src, parent, marks, mark++);" in s[
        "gcc/graphds.cc"]
    assert "n->dfs_num_in = (*num)++;" in s["gcc/dominance.cc"]
    assert "static const size_t block_size = 64 * 1024;" in s["gcc/memory-block.h"]
    assert "m_elts_per_block = (TBlockAllocator::block_size - header_size) / size;" in s[
        "gcc/alloc-pool.h"]
    assert "unsigned depth = loop_depth (father) + 1;" in s["gcc/cfgloop.cc"]
    assert "vec_alloc (loop->superloops, depth);" in s["gcc/cfgloop.cc"]
    return {"full_file_identities": len(s), "structural_guards": 16,
            "meaning": "guards plus manual source analysis, not a semantic proof"}


def graph_iteration_checks():
    """Small source-shape model checks; not the universal sweep argument."""
    count = 0
    max_sweeps = 0
    max_marks = 0

    def run(n, edges):
        nonlocal count, max_sweeps, max_marks
        succ = [[] for _ in range(n)]
        pred = [[] for _ in range(n)]
        # add_edge prepends to both linked lists.
        for a, b in edges:
            succ[a].insert(0, b)
            pred[b].insert(0, a)
        seen, postorder = set(), []

        def dfs(v):
            if v in seen:
                return
            seen.add(v)
            for w in succ[v]:
                dfs(w)
            postorder.append(v)

        dfs(0)
        if len(seen) != n:
            return
        parent, marks = [-1]*n, [0]*n
        mark = 1

        def chain(v):
            result = set()
            while v != -1:
                assert v not in result
                result.add(v)
                v = parent[v]
            return result

        def tree_nca(x, y, tag):
            if x == -1 or x == y:
                return y
            marks[x] = marks[y] = tag
            while True:
                x = parent[x]
                if x == -1:
                    break
                if marks[x] == tag:
                    return x
                marks[x] = tag
                y = parent[y]
                if y == -1:
                    break
                if marks[y] == tag:
                    return y
                marks[y] = tag
            if x == -1:
                y = parent[y]
                while marks[y] != tag:
                    assert y != -1
                    y = parent[y]
                return y
            x = parent[x]
            while marks[x] != tag:
                assert x != -1
                x = parent[x]
            return x

        old = [{0} if v == 0 else set(range(n)) for v in range(n)]
        sweeps = 0
        while True:
            changed = False
            sweeps += 1
            for v in reversed(postorder[:-1]):
                idom = -1
                for source in pred[v]:
                    if source != 0 and parent[source] == -1:
                        continue
                    idom = tree_nca(idom, source, mark)
                    mark += 1
                if idom != parent[v]:
                    parent[v] = idom
                    changed = True
                now = [chain(w) if w == 0 or parent[w] != -1
                       else set(range(n)) for w in range(n)]
                assert all(now[w] <= old[w] for w in range(n))
                old = now
            assert all(parent[v] != -1 for v in range(1,n))
            assert sweeps <= n+1
            if not changed:
                break
        assert mark <= 1+len(edges)*(n+1)
        # Independent set representation, rather than another parent-chain walk.
        reference = [{0} if v == 0 else set(range(n)) for v in range(n)]
        while True:
            before = [value.copy() for value in reference]
            for v in range(1,n):
                reference[v] = {v} | set.intersection(
                    *(reference[p] for p in pred[v]))
            if before == reference:
                break
        assert old == reference
        count += 1
        max_sweeps = max(max_sweeps, sweeps)
        max_marks = max(max_marks, mark)

    for n in range(2,5):
        possible = [(a,b) for a in range(n) for b in range(1,n) if a != b]
        for bits in range(1 << len(possible)):
            run(n, [edge for i,edge in enumerate(possible) if bits >> i & 1])
    exhaustive = count
    generator = random.Random(261018)
    for _ in range(256):
        n = generator.randrange(2,17)
        edges = {(generator.randrange(b),b) for b in range(1,n)}
        edges.update((a,b) for a in range(n) for b in range(1,n)
                     if a != b and generator.random() < 0.13)
        edges = sorted(edges)
        generator.shuffle(edges)
        run(n, edges)
    return {"exhaustive_reachable_graphs_2_to_4_vertices": exhaustive,
            "additional_seeded_graphs_2_to_16_vertices": count-exhaustive,
            "maximum_observed_sweeps": max_sweeps,
            "maximum_observed_final_marker": max_marks,
            "general_sweep_bound": "V+1 (manual source/path argument)",
            "meaning": "finite transcription and invariant checks only"}


def arithmetic():
    imax = 2**31 - 1
    bmax = imax // 2 - 2
    assert bmax == 1073741821
    assert 2*(bmax+2) <= imax < 2*(bmax+3)
    et_bmax = imax // 4 - 2
    assert et_bmax == 536870909
    assert 4*(et_bmax+2) <= imax < 4*(et_bmax+3)
    repair_bmax = 0
    while 1+(1+3*(repair_bmax+1))*(repair_bmax+3) <= imax:
        repair_bmax += 1
    assert repair_bmax == 26753
    assert 1+(1+3*repair_bmax)*(repair_bmax+2) <= imax
    assert 1+(1+3*(repair_bmax+1))*(repair_bmax+3) > imax
    for n in [1, 2, 3, 100, et_bmax+2]:
        # Conservative helper envelopes, including stale min before recompute.
        for old_depth in [-n, 0, n]:
            for old_min in [-n, 0, n]:
                for target in [-2*n, 0, 2*n]:
                    assert abs(target-old_depth) <= 3*n
                    assert abs(old_min+target-old_depth) <= 4*n
                for shift in [-2*n, 0, 2*n]:
                    assert abs(old_depth+shift) <= 3*n
                    assert abs(old_min+shift) <= 3*n
    payloads = []
    for b in [1, 2, 3, 7, 31, 63, 64, 100, 255, 1024, bmax]:
        n = b+2
        assert 9*4*n + 8*n + 4*(n+1) + 16*(n+1) == 64*n+20
        assert b*(b+1)//2 <= b*b
        for k in [0, 1, b, 3*b]:
            e = min(1+2*b+k, 1+3*b)
            s = b
            m = b+e+4*s
            w = b+(m+1)*(b+1)**2+m
            assert w >= b and e <= 1+3*b
            if b <= 100:
                payloads.append({"S": s, "B": b, "K": k, "E": e,
                                 "label_lifetime_ceiling": b*e,
                                 "worklist_matcher_entries": w,
                                 "ancestor_requested_slots": b*(b+1)//2,
                                 "dominator_array_payload_bytes": 64*n+20})
    # Integer layout arithmetic for the selected LP64 C++ fields, not a
    # compiler sizeof probe. Pool checking includes one aligned 8-byte ID.
    pools = []
    for checking in [False, True]:
        for name, size in [("et_node", 64), ("et_occ", 48)]:
            slot = size + (8 if checking else 0)
            capacity = (65536-8)//slot
            assert capacity*slot+8 <= 65536 < (capacity+1)*slot+8
            pools.append({"type": name, "checking": checking,
                          "slot_bytes": slot, "slots_per_block": capacity})
    assert [p["slots_per_block"] for p in pools] == [1023,1365,910,1170]
    # Exhaustively enumerate tiny rooted loop trees. Each real loop i chooses
    # an earlier parent. This checks the sum-of-depth formula, not discovery.
    trees_checked = 0
    for length in range(1,8):
        states = [[0]]
        for i in range(1,length+1):
            states = [depths+[depths[parent]+1]
                      for depths in states for parent in range(i)]
        for depths in states:
            assert max(depths) <= length
            assert sum(depths) <= length*(length+1)//2
            trees_checked += 1
    return {"int_max": imax, "dfs_local_B_limit": bmax,
            "et_lazy_depth_local_B_limit": et_bmax,
            "repair_marker_worst_edge_local_B_limit": repair_bmax,
            "graph_iteration_checks": graph_iteration_checks(),
            "pool_layout_arithmetic": pools,
            "tiny_loop_trees_checked": trees_checked,
            "representative_arithmetic": payloads,
            "open_interfaces": [
                "range matcher sequences, SSA_NAME and tree allocations",
                "generic containers and allocation lifetime composition",
                "enabled verifier helper allocation and loop object layout",
                "downstream SSA, RTL, machine code and linker composition"]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gcc-root", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--capture", action="store_true",
                        help="create initial retained artifacts; not compiler evidence")
    parser.add_argument("--refresh", action="store_true",
                        help="refresh derived text after an intentional analysis change")
    args = parser.parse_args()
    assert not (args.capture and args.refresh)
    here = Path(__file__).resolve().parent
    sources, manifest, excerpts = collect(args.gcc_root)
    result = {"source_commit": PIN, "source_checks": source_checks(sources),
              "arithmetic": arithmetic(),
              "validation_kind": "offline source identity and finite arithmetic only"}
    artifacts = {"source-manifest.json": json.dumps(manifest, indent=2)+"\n",
                 "source-excerpts.md": excerpts,
                 "checks.json": json.dumps(result, indent=2)+"\n"}
    for name, expected in artifacts.items():
        path = here/name
        if args.capture:
            assert not path.exists(), f"refusing to overwrite existing capture: {path}"
            path.write_text(expected)
        elif args.refresh:
            assert path.exists(), f"no existing derived artifact: {path}"
            path.write_text(expected)
        else:
            assert path.read_text() == expected, f"retained artifact differs: {name}"
    if args.output:
        args.output.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({"status": "pass", "source_files": len(sources),
                      "artifacts": len(artifacts), "capture": args.capture, "refresh": args.refresh,
                      "validation_kind": result["validation_kind"]}))


if __name__ == "__main__":
    main()

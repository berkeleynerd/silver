#!/usr/bin/env python3
"""Reconcile pinned sources/excerpts and component arithmetic, offline.

Finite checks do not prove branch exclusion, matcher termination, dominance
correctness, or the report's universally quantified manual bounds.
"""
import argparse
import hashlib
import json
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
    "gcc/et-forest.cc": [(37,83), (114,135), (295,445), (463,620)],
    "gcc/et-forest.h": [(62,81)],
    "gcc/alloc-pool.h": [(160,198), (261,307), (351,430)],
    "gcc/memory-block.h": [(25,84)],
    "gcc/graphds.h": [(22,49)],
    "gcc/graphds.cc": [(47,111), (198,330), (407,478)],
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


def arithmetic():
    imax = 2**31 - 1
    bmax = imax // 2 - 2
    assert bmax == 1073741821
    assert 2*(bmax+2) <= imax < 2*(bmax+3)
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
            "pool_layout_arithmetic": pools,
            "tiny_loop_trees_checked": trees_checked,
            "representative_arithmetic": payloads,
            "open_interfaces": [
                "range matcher sequences, SSA_NAME and tree allocations",
                "generic containers and allocation lifetime composition",
                "ET lazy-depth signed intermediates",
                "graphds_domtree convergence sweeps and cumulative mark",
                "enabled verifier helper allocation and loop object layout",
                "downstream SSA, RTL, machine code and linker composition"]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gcc-root", type=Path, required=True)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--capture", action="store_true",
                        help="create initial retained artifacts; not compiler evidence")
    args = parser.parse_args()
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
        else:
            assert path.read_text() == expected, f"retained artifact differs: {name}"
    if args.output:
        args.output.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({"status": "pass", "source_files": len(sources),
                      "artifacts": len(artifacts), "capture": args.capture,
                      "validation_kind": result["validation_kind"]}))


if __name__ == "__main__":
    main()

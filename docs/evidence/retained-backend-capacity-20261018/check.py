#!/usr/bin/env python3
"""Reproduce source identities and local backend arithmetic, without compiling.

The handwritten report supplies reachability and composition reasoning. This
script checks inputs, excerpts and its stated arithmetic; it is not a proof of
the complete compiler or a compiler-success membership test.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile


RANGES = {
    "gcc/tree-cfg.cc": [(72, 79), (145, 214), (488, 555), (631, 666),
                        (810, 1024), (1085, 1220), (1325, 1405),
                        (1507, 1698), (1710, 1852), (2633, 2666)],
    "gcc/cfg.cc": [(65, 83), (214, 231), (278, 342)],
    "gcc/cfg.h": [(38, 70)],
    "gcc/input.cc": [(1045, 1059)],
    "gcc/passes.def": [(25, 47)],
    "gcc/gimple-low.cc": [(122, 214), (1178, 1223)],
    "gcc/gimplify.cc": [(1270, 1282), (1699, 1830)],
    "gcc/tree-eh.cc": [(618, 655), (710, 877), (940, 1095),
                       (1107, 1283), (1289, 1800), (2333, 2356), (3318, 3349)],
    "gcc/gimple.cc": [(1563, 1577), (1901, 1931), (2045, 2095), (2297, 2333)],
    "gcc/tree-inline.cc": [(5861, 5940), (6008, 6060)],
    "gcc/langhooks-def.h": [(145, 158)],
    "gcc/ada/back_end.adb": [(123, 130), (155, 175)],
    "gcc/ada/gcc-interface/trans.cc": [(87, 91), (346, 363), (6705, 6732),
                                       (1201, 1289), (1330, 1369), (4911, 5015),
                                       (5688, 5691), (6779, 6881), (7086, 7116),
                                       (7291, 7342), (7415, 7470), (7605, 7616),
                                       (7756, 7821), (7944, 7974), (8603, 8622),
                                       (8968, 8996), (9298, 9305), (3301, 3306),
                                       (9889, 10025), (11006, 11030)],
    "gcc/ada/gcc-interface/decl.cc": [(400, 445), (697, 718), (754, 766), (1278, 1291),
                                      (3142, 3177)],
    "gcc/ada/gcc-interface/misc.cc": [(376, 377)],
    "gcc/ada/gcc-interface/utils.cc": [(259, 280), (430, 450), (770, 783)],
    "gcc/toplev.cc": [(761, 767), (1141, 1150)],
    "gcc/ggc-page.cc": [(1250, 1290), (1292, 1327), (1883, 1922)],
    "gcc/ggc.h": [(230, 258)],
    "gcc/tree.cc": [(2616, 2636)],
    "gcc/tree-core.h": [(1138, 1253), (1565, 1595)],
    "gcc/varasm.cc": [(870, 920), (2304, 2335), (2665, 2667), (3953, 3965),
                       (5627, 5635), (8518, 8527), (76, 85), (2069, 2086),
                       (2976, 2987), (3537, 3553), (3720, 3753), (3804, 3893),
                       (4001, 4038), (4150, 4168), (4184, 4253), (4476, 4523)],
    "gcc/function.h": [(34, 70), (162, 169)],
    "gcc/function.cc": [(203, 218), (5133, 5144)],
    "gcc/vec.h": [(220, 260), (302, 325), (393, 425), (599, 660), (1394, 1415)],
    "gcc/vec.cc": [(150, 169)],
    "gcc/expr.cc": [(1096, 1176), (1506, 1590), (2024, 2169),
                     (2237, 2329), (2540, 2579)],
    "gcc/expr.h": [(85, 105)],
    "gcc/targhooks.cc": [(2156, 2220)],
    "gcc/defaults.h": [(977, 995)],
    "gcc/config/i386/i386.h": [(1916, 1966)],
    "gcc/config/i386/i386.cc": [(11580, 11596)],
    "gcc/config/i386/i386-expand.cc": [(9135, 9294), (9510, 9586),
                                      (10010, 10715)],
    "gcc/config/i386/x86-tune-costs.h": [(4139, 4157), (4208, 4220)],
    "gcc/emit-rtl.cc": [(80, 85), (1184, 1232), (1239, 1262), (5980, 6005)],
    "gcc/rtl.h": [(4091, 4146)],
    "gcc/bb-reorder.cc": [(2616, 2641), (2665, 2672), (2977, 3011)],
    "gcc/config/i386/i386.md": [(500, 515), (25924, 25962)],
    "gcc/read-rtl-function.cc": [(1435, 1450)],
    "gcc/genmodes.cc": [(828, 845), (1012, 1023)],
    "gcc/config/elfos.h": [(114, 132)],
    "gcc/hash-table.h": [(295, 355), (599, 617), (656, 679), (755, 778),
                         (788, 821), (833, 895), (1026, 1093)],
    "gcc/hash-table.cc": [(44, 78), (87, 110)],
    "include/hashtab.h": [(32, 46)],
    "gcc/opts.cc": [(470, 560), (596, 605), (819, 825)],
    "gcc/common.opt": [(2080, 2094), (2411, 2420)],
    "gcc/config/i386/i386-options.cc": [(2275, 2286)],
    "gcc/common/config/i386/i386-common.cc": [(2033, 2059)],
    "libcpp/include/line-map.h": [(48, 55), (295, 324), (425, 471), (747, 777)],
    "libcpp/line-map.cc": [(469, 543), (570, 608), (662, 680), (890, 999), (1009, 1077)],
}


def read_tar(archive, name):
    with tarfile.open(archive) as src:
        with src.extractfile(name) as member:
            return member.read()


def check_cleanup_transfers(all_bytes):
    """Arithmetic on the report's manually established cleanup frontier.

    Counts are constructor calls, not final live instructions. Source checks
    corroborate the branch selection; they do not establish reachability.
    """
    passes = all_bytes["gcc/passes.def"].decode()
    assert passes.index("NEXT_PASS (pass_lower_cf)") < passes.index(
        "NEXT_PASS (pass_lower_eh)")
    assert re.search(r"#define\s+LANG_HOOKS_EH_PROTECT_CLEANUP_ACTIONS\s+NULL\b",
                     all_bytes["gcc/langhooks-def.h"].decode())
    assert "LANG_HOOKS_EH_PROTECT_CLEANUP_ACTIONS" not in all_bytes[
        "gcc/ada/gcc-interface/misc.cc"].decode()
    eh = all_bytes["gcc/tree-eh.cc"].decode()
    start = eh.index("\ndecide_copy_try_finally (")
    body = eh[start:eh.index("\n}\n", start)]
    gate = body[body.index("if (!optimize)"):body.index(
        "/* Finally estimate N times")]
    for expression in ("is_gimple_debug (stmt)", "gimple_clobber_p (stmt)",
                       "gimple_call_builtin_p (stmt, BUILT_IN_STACK_RESTORE)"):
        assert expression in gate
    low = all_bytes["gcc/gimple-low.cc"].decode()
    start = low.index("\nlower_gimple_return (")
    body = low[start:low.index("\n}\n", start)]
    assert body.count("gimple_build_goto (") == 1
    assert body.count("create_artificial_label (") == 1
    assert "gimple_build_return (" not in body

    # Each tuple names independently inspected source allocations. Enumerate
    # flags and Q/D pairs only to check the symbolic sums and stated maxima.
    copy_rows = {
        "fallthrough_branch_and_end_label": 2,
        "exception_landing_label_and_resx": 2,
        "queued_goto_continuation_and_redirection": 2,
        "distinct_destination_label": 1,
    }
    switch_rows = {
        "common_finally_label_and_switch": 2,
        "fallthrough_assignment_case_branch_end_label": 4,
        "exception_landing_assignment_branch_case_resx": 5,
        "queued_goto_assignment_continuation_redirection": 3,
        "distinct_destination_label": 1,
    }
    cases = []
    for q, d in ((0, 0), (1, 1), (2, 1), (2, 2), (7, 1), (7, 7)):
        for f in (0, 1):
            for e in (0, 1):
                copy_controls = 2*f+2*e+2*q+d
                switch_controls = 2+4*f+5*e+3*q+d
                assert copy_controls <= 2*q+d+4
                assert switch_controls <= 11+3*q+d
                assert d+f+e <= d+2
                assert 1+2*f+2*e+d <= 5+d
                assert 2*f+2*e+q+d <= 4+q+d
                cases.append(dict(queued_gotos=q, destinations=d,
                                  fallthrough=f, exception=e,
                                  cleanup_copies=d+f+e,
                                  copy_control_statements=copy_controls,
                                  switch_control_statements=switch_controls))
    main_cases = [c for c in cases if c["queued_gotos"] <= 1]
    assert max(c["cleanup_copies"] for c in main_cases) == 3
    assert max(c["copy_control_statements"] for c in main_cases) == 7
    assert max(c["switch_control_statements"] for c in main_cases) == 15
    return {
        "scope": "O0 cleanup GIMPLE allocations; operand trees and later passes separate",
        "cf_precedes_eh": True,
        "implicit_return_cf_new_gimple": 2,
        "implicit_return_cf_new_label_declarations": 1,
        "simple_cleanup_copy_control_rows": copy_rows,
        "switch_cleanup_control_rows": switch_rows,
        "copy_bounds": {"cloned_statements": "(D+2)*C",
                        "other_statements": "2*Q+D+4",
                        "artificial_labels": "D+2"},
        "switch_bounds": {"new_statements": "11+3*Q+D",
                          "temporary_requests": 1,
                          "artificial_labels": "5+D",
                          "case_labels_and_entries": "2+D",
                          "integer_constant_requests": "4+Q+D",
                          "continuation_map_entries": "D"},
        "Main_Q_D_at_most_one": {
            "copy_statements": "3*C+7", "copy_labels": 3,
            "inner_copy_statements": "2*C+4", "inner_copy_labels": 2,
            "switch_statements": 15, "switch_temporaries": 1,
            "switch_labels": 6, "switch_cases": 3,
            "switch_integer_requests": 6, "goto_queue_capacity": 32},
        "enumerated_arithmetic_cases": cases,
        "source_frontier_requires_manual_argument": True,
    }


def check_initial_cfg(all_bytes):
    source = all_bytes["gcc/tree-cfg.cc"].decode()
    assert "static const int initial_cfg_capacity = 20;" in source
    start = source.index("\ncall_can_make_abnormal_goto (")
    body = source[start:source.index("\n}\n", start)]
    assert re.search(r"if \(!cfun->has_nonlocal_label\s*&& !cfun->calls_setjmp\)"
                     r"\s*return false;", body)
    rows = []
    # Direct per-terminal edge requests. Ordinary selected switches come only
    # from cleanup lowering, with at most three destinations.
    terminal_requests = dict(cond=2, call=2, throwing_assign=2, ordinary=1,
                             direct_goto=1, resx=1, return_stmt=1, switch=3)
    assert max(terminal_requests.values()) == 3
    for s in (0, 1, 20, 100, 1000000):
        b = max(1, s)
        for switches in (0, min(1, s), s):
            k = 3*switches
            edges = min(1+2*b+k, 1+3*b)
            assert edges <= 1+3*b
            rows.append(dict(statements=s, switch_labels=k, blocks=b+2,
                             edges=edges, pointer_vector_demand=max(20,b+2,s,edges),
                             discriminator_requests=s+edges,
                             discriminator_block_ids=s+2*b+edges))
    return dict(scope="build_gimple_cfg before CFG cleanup and loop discovery",
                blocks="max(1,S)+2", edge_requests="min(1+2*max(1,S)+K,1+3*max(1,S))",
                label_map_entries="S", vector_initial_demand=20,
                pointer_vector_demand_bound=1431655765,
                discriminator_requests="S+E_graph",
                discriminator_block_ids="S+2*max(1,S)+E_graph",
                new_adhoc_location_requests="S+E_graph",
                terminal_edge_requests=terminal_requests, cases=rows,
                excludes="CFG cleanup/loop discovery, ad-hoc-location allocator, SSA, RTL")


def check_block_transfers(all_bytes, bundle):
    source = all_bytes["gcc/config/i386/i386-expand.cc"].decode()
    primitives = ("gen_reg_rtx", "emit_move_insn", "gen_label_rtx", "emit_label",
                  "emit_cmp_and_jump_insns", "emit_jump_insn", "emit_barrier",
                  "expand_simple_binop", "change_address", "offset_address",
                  "ix86_copy_addr_to_reg")
    expected = {
        "ix86_expand_movmem": (3, 11, 8, 8, 8, 6, 6, 8, 4, 2, 2),
        "ix86_expand_less_move_movmem": (1, 2, 6, 6, 6, 11, 11, 0, 2, 0, 0),
    }
    bodies, direct = {}, {}
    for name, counts in expected.items():
        start = re.search(r"\n" + name + r"\s*\(", source).start()
        end = source.index("\n}\n", start)
        bodies[name] = source[start:end]
        observed = tuple(len(re.findall(r"\b" + p + r"\s*\(", bodies[name]))
                         for p in primitives)
        assert observed == counts
        direct[name] = dict(zip(primitives, counts))
    # The report derives bounded loop multiplicities in these helpers.
    # Rows are (fresh explicit pseudos, move requests, address changes, offsets,
    #           adjust_address requests). Callee expansions remain separate.
    helpers = {
        "unroll_at_most_8_plus_tail": (9, 18, 2, 20, 2),
        "three_outer_overlap_helpers_moves_2_8_4": (14, 28, 6, 28, 0),
        "five_small_overlap_helpers_moves_2": (10, 20, 10, 20, 0),
        "two_load_helpers_moves_4": (8, 8, 2, 8, 0),
        "two_store_helpers_moves_4": (0, 8, 2, 8, 0),
        "two_move_helpers_moves_4": (8, 16, 0, 12, 0),
    }
    aggregate = {p: sum(row[p] for row in direct.values()) for p in primitives}
    aggregate["adjust_address"] = 0
    helper_fields = ("gen_reg_rtx", "emit_move_insn", "change_address",
                     "offset_address", "adjust_address")
    for row in helpers.values():
        for p, value in zip(helper_fields, row):
            aggregate[p] += value
    assert tuple(aggregate[p] for p in helper_fields) == (53, 111, 28, 98, 2)
    for name in ("ix86_expand_movmem", "ix86_expand_set_or_cpymem"):
        start = re.search(r"\n" + name + r"\s*\(", source).start()
        end = source.index("\n}\n", start)
        body = source[start:end]
        guard = "if (count > (HOST_WIDE_INT_1U << 30))\n    return false;"
        assert body.index(guard) < body.index("decide_alg (")
        assert body.index(guard) < body.index("ix86_copy_addr_to_reg (")
    query = json.loads((bundle / "target-options-query.json").read_text())
    for pattern in (r"-mtune=\s+generic", r"-march=\s+x86-64",
                    r"-minline-all-stringops\s+\[disabled\]",
                    r"-minline-stringops-dynamically\s+\[disabled\]"):
        assert re.search(pattern, query["stdout"])
    return {
        "scope": "local primitive requests, not transitive RTL or machine instructions",
        "ordinary_piecewise_move_ratio_upper_bound": 17,
        "ordinary_piecewise_estimated_pieces_maximum": 16,
        "universal_x86_piece_bytes_upper_bound": 64,
        "ordinary_piecewise_input_bytes_upper_bound": 16*64,
        "constant_pattern_early_return_above": 2**30,
        "large_constant_normal_copy_libcall_requests": 1,
        "libcall_arguments": 3,
        "pattern_mode_attempts_upper_bound": 2,
        "direct_lexical_primitive_inventory": direct,
        "manually_derived_helper_bounds": dict(zip(helpers, (
            dict(zip(helper_fields, row)) for row in helpers.values()))),
        "movmem_transitive_over_named_helpers_only": aggregate,
    }


def check_configuration_inventory(bundle, gcc_root, plugin):
    record = json.loads((bundle / "configuration-inventory.json").read_text())
    if gcc_root:
        seen = []
        found = {k: [] for k in record["results"]}
        patterns = {
            "assemble_static_space": r"\bassemble_static_space\s*\(",
            "partition_writers": r"\bhas_bb_partition\s*=",
            "register_writers": r"\breg_rtx_no\s*(?:\+\+|--|[-+*/]?=)",
        }
        for path in sorted((gcc_root / "gcc").rglob("*")):
            if path.suffix not in (".cc", ".c", ".h") or "testsuite" in path.parts:
                continue
            data = path.read_bytes()
            name = str(path.relative_to(gcc_root))
            seen.append((name, hashlib.sha256(data).hexdigest()))
            source = data.decode(errors="replace")
            for kind, pattern in patterns.items():
                for match in re.finditer(pattern, source):
                    found[kind].append(dict(path=name, line=source.count(
                        "\n", 0, match.start())+1, text=match.group()))
        assert len(seen) == record["source_file_count"]
        assert hashlib.sha256(json.dumps(seen, separators=(",", ":")).encode()
                              ).hexdigest() == record["source_file_list_sha256"]
        assert found == record["results"]
    if plugin:
        headers, hits = [], []
        for path in sorted(plugin.rglob("*.h")):
            data = path.read_bytes()
            name = str(path.relative_to(plugin))
            headers.append((name, hashlib.sha256(data).hexdigest()))
            if b"PCC_STATIC_STRUCT_RETURN" in data:
                hits.append(name)
        expected = record["plugin_headers"]
        assert len(headers) == expected["files"]
        assert hashlib.sha256(json.dumps(headers, separators=(",", ":")).encode()
                              ).hexdigest() == expected["list_sha256"]
        assert hits == expected["pcc_static_struct_return_hits"] == []
        assert (plugin / "tm.h").read_text() == expected["tm_h"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ada", required=True, type=Path,
                        help="Pinned gcc/ada directory")
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--gcc-root", type=Path,
                        help="Optional complete pinned GCC source for caller inventory")
    parser.add_argument("--plugin-include", type=Path,
                        help="Optional selected compiler headers for configuration inventory")
    args = parser.parse_args()
    bundle = Path(__file__).resolve().parent
    check_configuration_inventory(bundle, args.gcc_root, args.plugin_include)
    evidence = bundle.parent
    manifest = json.loads((bundle / "source-manifest.json").read_text())
    assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
    prior = evidence / "unbounded-programs/frontend-deferred-20261017"
    prior_files = {row["path"]: row for row in json.loads(
        (prior / "gcc-emission-source-manifest.json").read_text())["files"]}
    ada_record = evidence / ("unbounded-programs/continuation-20261017/"
                             "frontend-lifetimes/complete-source-manifest.json")
    ada_files = {"gcc/ada/" + row["path"]: row for row in
                 json.loads(ada_record.read_text())["files"]}
    excerpts = ["# Pinned native backend source excerpts\n",
                "LF line numbering; complete file identities checked.\n"]
    verified = []
    all_bytes = {}
    for row in manifest["files"]:
        name = row["path"]
        if name.startswith("gcc/ada/"):
            data = (args.ada / name.removeprefix("gcc/ada/")).read_bytes()
            assert hashlib.sha256(data).hexdigest() == ada_files[name]["sha256"]
        elif name in prior_files:
            data = read_tar(prior / "gcc-emission-sources.tar.gz",
                            prior_files[name]["file"])
            assert hashlib.sha256(data).hexdigest() == prior_files[name]["sha256"]
        else:
            data = read_tar(bundle / row.get("archive", "new-sources.tar.gz"), name)
        assert len(data) == row["bytes"], name
        assert hashlib.sha256(data).hexdigest() == row["sha256"], name
        blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data)
        assert blob.hexdigest() == row["git_blob_sha1"], name
        all_bytes[name] = data
        verified.append({"path": name, "sha256": row["sha256"]})
        lines = data.decode().split("\n")
        for first, last in RANGES[name]:
            excerpts.extend([f"\n## {name}:{first}–{last}\n", "```text\n"])
            excerpts.extend(f"{i}: {lines[i-1]}".rstrip() + "\n"
                            for i in range(first, last + 1))
            excerpts.append("```\n")

    # Negative source searches corroborate the inspected override scope.
    assert b"flag_merge_constants" not in all_bytes["gcc/ada/gcc-interface/misc.cc"]
    assert b"OPT_fmerge_constants" not in all_bytes[
        "gcc/common/config/i386/i386-common.cc"]

    line_bits, column_bits = 32, 8
    maximum_lines = 1 << (line_bits - column_bits)
    assert maximum_lines - 1 < 1 << (line_bits - column_bits)
    assert not maximum_lines < 1 << (line_bits - column_bits)
    location_charge = 256 * (maximum_lines - 1) + 252
    int_max = (1 << 31) - 1
    map_cases = []
    for demand in sorted({0, 1, 255, 256, 257, int_max} |
                         {2**k+delta for k in range(9,31) for delta in (-1,0,1)}):
        capacity = 0 if demand == 0 else max(256,1 << (demand-1).bit_length())
        assert demand <= capacity <= 2**31
        assert capacity*32 <= 2**36
        if capacity:
            assert capacity*32 == 1 << (capacity.bit_length()-1+5)
        map_cases.append(dict(demand=demand, capacity=capacity, bytes=32*capacity))
    header_offset = 20
    constructor_bytes = int_max + header_offset + 1
    assert constructor_bytes <= (1 << 32) - 1

    # The constant-label counter is file-local: inventory every increment and
    # reset in its complete source, not just a selected emitter excerpt.
    varasm = all_bytes["gcc/varasm.cc"].decode().split("\n")
    label_increments = [i for i, line in enumerate(varasm, 1)
                        if re.search(r"const_labelno\s*\+\+|\+\+\s*const_labelno", line)]
    label_resets = [i for i, line in enumerate(varasm, 1)
                    if re.search(r"\bconst_labelno\s*=\s*0", line)]
    assert label_increments == [2085, 2984, 3733, 4252]
    assert label_resets == [9077]
    deferred_updates = [i for i, line in enumerate(varasm, 1)
                        if re.search(r"n_deferred_constants\s*(?:\+\+|--)", line)]
    assert deferred_updates == [3888, 4519]

    prime_source = all_bytes["gcc/hash-table.cc"].decode()
    prime_text = prime_source.split("prime_tab[] = {", 1)[1].split("};", 1)[0]
    primes = [int(x, 0) for x in re.findall(r"\{\s*(0x[0-9a-f]+|[0-9]+),", prime_text)]
    assert len(primes) == 30 and primes[-2:] == [int_max, 2**32-5]
    live_limit = int_max // 2
    hash_cases = []
    for demand in sorted({0, 1, 23, 24, 765, 766, live_limit} |
                         {p//2+delta for p in primes[:-1] for delta in (0,1)
                          if 0 <= p//2+delta <= live_limit}):
        request = max(1009, 2*demand)
        capacity = next(p for p in primes if p >= request)
        assert capacity <= int_max
        assert 2*capacity-3 <= 2**32-1  # index + secondary step
        assert 8*capacity <= 8*int_max < 2**34
        hash_cases.append(dict(live=demand, request=request, capacity=capacity))
    # Search the exact selected macro lengths; the shortest caller array is LF.
    label_lengths = {prefix: 2+len(prefix)+len(str(int_max-1))+1
                     for prefix in ("LF", "LC", "LHOTB", "LCOLDB", "LHOTE", "LCOLDE")}
    assert label_lengths["LF"] <= 17
    assert max(label_lengths.values()) <= 100

    # Heap capacity remains valid even when its unsigned growth heuristic wraps.
    heap_cases = []
    for old in (0, 4, 8, 15, 16, int_max//2, (2**32-1)//3,
                (2**32-1)//3+1, int_max-1):
        desired = old+1
        raw = 4 if not old else (old*2 if old < 16 else
                                ((old*3) & (2**32-1))//2)
        capacity = max(raw, desired)
        assert desired <= capacity <= int_max
        heap_cases.append(dict(old=old, desired=desired, capacity=capacity))
    gc_vectors = []
    for element_size in (1, 2, 4, 8, 16, 24, 32, 40, 64, 128):
        bound_bytes = 8+element_size*int_max
        rounding_ceiling = 1 << (bound_bytes.bit_length()-1)
        capacity = (rounding_ceiling-8)//element_size
        demand = 2*capacity//3+1
        assert demand <= capacity <= int_max
        assert 3*(demand-1)//2 <= capacity
        assert 8+element_size*capacity <= rounding_ceiling <= 2**63
        assert (rounding_ceiling-8)//element_size <= int_max
        gc_vectors.append(dict(element_bytes=element_size,
                               rounding_ceiling_bytes=rounding_ceiling,
                               recovered_capacity_bound=capacity,
                               sufficient_requested_total=demand))
    request = 8+4*int_max
    rounded = 1 << (request-1).bit_length()
    recovered = (rounded-8)//4
    assert request == 2**33+4 and rounded == 2**34
    assert recovered == 2**32-2 and (recovered & int_max) < int_max
    reg_capacities = [198]
    while 2*reg_capacities[-1] <= int_max:
        reg_capacities.append(2*reg_capacities[-1])
    assert reg_capacities[-1] == 1660944384
    assert reg_capacities[-1]-98 == 1660944286
    # The alignment mask is unsigned int before conversion to HOST_WIDE_INT.
    # genmodes emits BITS_PER_UNIT as a plain decimal int literal.
    mode_generator = all_bytes["gcc/genmodes.cc"].decode()
    assert '#define BITS_PER_UNIT (%d)' in mode_generator
    varasm_text = all_bytes["gcc/varasm.cc"].decode()
    assert varasm_text.count("pool->offset &= ~ ((align / BITS_PER_UNIT) - 1);") == 2
    uint_max = 2**32-1
    byte_alignment = 8
    before = 2**32
    unsigned_mask = (~(byte_alignment-1)) & uint_max
    narrowed = (before+byte_alignment-1) & unsigned_mask
    mathematical = (before+byte_alignment-1) & ~(byte_alignment-1)
    assert narrowed == 0 and mathematical == 2**32
    assert before+byte_alignment-1+8 <= 2**63-1
    # Below the 32-bit mask ceiling, zero-extension changes no significant bit.
    mask_cases = []
    for alignment in (1, 2, 4, 8, 16, 32, 64):
        mask = (~(alignment-1)) & uint_max
        for unaligned in sorted({0, alignment-1, alignment, uint_max-1, uint_max}):
            actual = unaligned & mask
            expected = unaligned & ~(alignment-1)
            assert actual == expected and 0 <= actual <= unaligned
            mask_cases.append({"alignment_bytes": alignment,
                               "pre_mask_offset": unaligned, "aligned_offset": actual})
    results = {
        "scope": "local source-derived arithmetic; no native compiler/prover run",
        "verified_sources": verified,
        "block_operations": check_block_transfers(all_bytes, bundle),
        "cleanup_lowering": check_cleanup_transfers(all_bytes),
        "initial_cfg": check_initial_cfg(all_bytes),
        "ordinary_vectors": {
            "heap_maximum_requested_total": int_max,
            "heap_modular_growth_examples": heap_cases,
            "gc_header_bytes": 8,
            "gc_sufficient_regions": gc_vectors,
            "gc_counterexample": dict(element_bytes=4, requested_total=int_max,
                                      requested_bytes=request, rounded_bytes=rounded,
                                      recovered_capacity=recovered,
                                      stored_capacity=recovered & int_max),
            "scope": "ordinary reserve preconditions; element alignment at most eight bytes",
        },
        "pseudo_register_backbones": {
            "initial_next_number": 98, "capacity_sequence": reg_capacities,
            "maximum_fresh_register_events": reg_capacities[-1]-98,
            "maximum_byte_array_request": reg_capacities[-1],
            "maximum_pointer_array_request": 8*reg_capacities[-1],
            "scope": "ordinary non-RTL-reader Ada path; source-to-event bound separate",
        },
        "line_map": {
            "location_bits": 64, "line_bits": line_bits,
            "column_bits": column_bits, "range_bits": 0,
            "maximum_lines_without_extra_map": maximum_lines,
            "first_line_count_requiring_extra_map": maximum_lines + 1,
            "preallocation_charge_at_maximum": location_charge,
            "later_column_headroom": 4,
            "normal_region_exclusive_limit": 0x50000000 << 31,
            "ordinary_map_bytes_lp64": 32,
            "growth_transitions": map_cases,
            "maximum_map_vector_bytes_from_nat_file_count": 2**36,
        },
        "gnat_node_associations": {
            "array_count": 2,
            "maximum_count_from_int_interface": int_max,
            "maximum_requested_bytes_per_array": 8*int_max,
            "maximum_rounded_bytes_per_array": 2**34,
            "scope": "backbone arithmetic; pointed-to GCC trees are separate",
        },
        "constant_pools": {
            "label_increment_lines": label_increments,
            "label_reset_lines": label_resets,
            "maximum_total_label_events": int_max,
            "selected_O0_exclusions": {"C_space": 0, "C_part": 0},
            "label_buffers_including_nul": label_lengths,
            "deferred_update_lines": deferred_updates,
            "deferred_counter_bits": 32,
            "maximum_deferred_increments_per_function": 2**32-1,
            "decrement_bound_required_separately": True,
            "hash_prime_table": primes,
            "maximum_live_hash_entries_for_bounded_probe_arithmetic": live_limit,
            "maximum_hash_capacity": int_max,
            "maximum_pointer_backbone_bytes": 8*int_max,
            "hash_capacity_cases": hash_cases,
            "RTL_pool_offsets": {
                "offset_bits": 64, "offset_signed": True,
                "align_and_mask_bits": 32, "mask_unsigned": True,
                "sufficient_per_pool_charge": "sum(a_i-1+s_i) <= 2^32-1",
                "maximum_charge": uint_max,
                "witness_above_mask_width": {
                    "incoming_offset": before, "alignment_bytes": byte_alignment,
                    "unsigned_mask": unsigned_mask,
                    "actual_aligned_offset": narrowed,
                    "mathematical_aligned_offset": mathematical,
                    "fits_old_signed64_sum_bound": True,
                },
                "mask_boundary_cases": mask_cases,
                "scope": "local arithmetic; actual source-to-descriptor/mode counts remain open",
            },
            "scope": "local event-to-representation transfers; source event counts remain required",
        },
        "string": {
            "lp64_header_offset_premise": header_offset,
            "maximum_signed_length": int_max,
            "constructor_request_at_endpoint": constructor_bytes,
            "coexisting_temporary_plus_node_at_endpoint": int_max + constructor_bytes,
            "largest_stack_temporary": 999,
            "maximum_chunk_callbacks_at_endpoint": (int_max + 1999) // 2000,
            "normal_chunk_size": 2000, "base64_chunk_size": 16384,
            "emission_extra_nul_under_o0_no_override": False,
            "ordinary_Main_gigi_lowering": {
                "maximum_visits_per_expanded_literal_identity": 2,
                "events": "2*N_lit <= 2*A_Main",
                "payload_bytes": "2*W_lit <= 2*A_Main*L_max",
                "constructor_bytes": "2*W_lit+42*N_lit",
                "premises": "current normalized Main grammar; cached entity/lazy initialization; scalar literal subtype bounds; selected no-inlining native invocation",
                "excluded": "later GCC copies and constant-pool requests; named objects; diagnostic/filename/fixed dependency Strings",
            },
        },
    }
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "checks.json").write_text(json.dumps(results, indent=2) + "\n")
    (args.output / "source-excerpts.md").write_text("".join(excerpts))
    print(f"Verified {len(verified)} source files and local arithmetic")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Reproject this packet's source spans and finite recurrence; no native run.

The semantic transfer is in the companion research note. This checker does not
turn a lexical inventory into a parser proof, or prove the initial-state lemma.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INVENTORY = ROOT / "docs/evidence/retained-why-path-input-inventory-20261020/library-inventory.json"
WHY = ROOT / "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
FIXED = ROOT / "docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz"
OCAML = ROOT / "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
OCAML_MEMBER = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/hashtbl.ml"
OCAML_SPANS = [(115, 152), (344, 362), (381, 399), (477, 484)]

SPANS = {
    "why3/src/core/env.ml": [(82, 123), (157, 162), (191, 222)],
    "why3/src/core/theory.ml": [(472, 516), (549, 580), (920, 963), (1047, 1054)],
    "why3/src/core/ty.ml": [(75, 104), (278, 292)],
    "why3/src/core/term.ml": [(1037, 1057)],
    "why3/src/util/exthtbl.ml": [(40, 50)],
    "why3/src/util/wstdlib.ml": [(13, 22)],
    "why3/src/mlw/pmodule.ml": [(221, 243), (278, 317), (345, 378),
        (481, 486), (527, 569), (739, 833), (902, 912), (1031, 1082),
        (1163, 1178), (1222, 1250), (1252, 1348), (1365, 1377),
        (1448, 1485), (1491, 1505), (1590, 1634), (1662, 1702)],
    "why3/src/mlw/pdecl.ml": [(77, 101), (186, 213), (258, 265),
        (379, 506), (531, 638), (683, 687)],
    "why3/src/mlw/expr.ml": [(112, 153), (781, 844), (938, 946),
        (1038, 1057), (1229, 1249)],
    "why3/src/mlw/ity.ml": [(768, 798), (818, 823), (1491, 1501),
        (1624, 1652)],
    "why3/src/mlw/dexpr.ml": [(251, 278), (957, 960), (1309, 1324),
        (1374, 1387), (1406, 1444), (1517, 1527),
        (1732, 1736), (1773, 1789)],
    "why3/src/parser/typing.ml": [(149, 160), (218, 226), (389, 397),
        (589, 599), (683, 690), (998, 1006), (1227, 1235), (1469, 1477),
        (1495, 1580), (1675, 1754), (1790, 1825), (1895, 1905),
        (1936, 1966)],
    "why3/src/parser/lexer.mll": [(215, 234), (259, 279)],
    "why3/src/parser/parser.mly": [(61, 98), (140, 168)],
}


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def project():
    inv_bytes = INVENTORY.read_bytes()
    inv = json.loads(inv_bytes)
    assert inv["total_source_bytes"] == 38678
    assert inv["module_count"] == 69
    assert inv["dependency_declaration_count"] == 102
    assert inv["source_dependency_graph_acyclic"]
    assert inv["same_file_dependencies_reference_prior_module_heads"]
    modules, file_modules, external_reads, file_ids = {}, {}, {}, {}
    with tarfile.open(FIXED) as archive:
        for row in inv["files"]:
            lib = row["library"]
            data = archive.extractfile(row["member"]).read()
            assert identity(data) == row["identity"], row["member"]
            file_ids[lib] = {"member": row["member"], **identity(data)}
            lines = data.splitlines(keepends=True)
            offsets = [0]
            for line in lines:
                offsets.append(offsets[-1] + len(line))
            file_modules[lib], external_reads[lib] = [], []
            for i, module in enumerate(row["modules"]):
                start = offsets[module["line"] - 1]
                end = (offsets[row["modules"][i + 1]["line"] - 1]
                       if i + 1 < len(row["modules"]) else len(data))
                body = data[start:end]
                name = module["qualified"]
                # Deliberately count comment-contained meta heads too. They are
                # harmless extra allowance, not executable declarations.
                metas = len(re.findall(rb"^\s*meta\b", body, re.M))
                modules[name] = {
                    "library": lib, "first_byte": start,
                    "past_last_byte": end, "source_bytes": end - start,
                    "clone_targets": [], "meta_head_upper_count": metas,
                }
                file_modules[lib].append(name)
            for dep in row["dependencies"]:
                target = dep["target"]
                if dep["kind"] == "clone":
                    modules[dep["module"]]["clone_targets"].append(target)
                target_lib = target.split(".", 1)[0]
                if target_lib != lib and target_lib != "why3":
                    external_reads[lib].append(target_lib)
    visiting = set()

    def expand(name):
        row = modules[name]
        if "expanded_source_bytes" in row:
            return row["expanded_source_bytes"], row["expanded_marker_upper_count"]
        assert name not in visiting
        visiting.add(name)
        children = [expand(child) for child in row["clone_targets"]]
        row["expanded_source_bytes"] = row["source_bytes"] + sum(x for x, _ in children)
        row["expanded_marker_upper_count"] = (
            row["meta_head_upper_count"] + len(row["clone_targets"])
            + sum(y for _, y in children))
        visiting.remove(name)
        return row["expanded_source_bytes"], row["expanded_marker_upper_count"]

    for name in modules:
        expand(name)
    sums = {
        lib: {
            "module_count": len(names),
            "expanded_source_bytes": sum(modules[n]["expanded_source_bytes"] for n in names),
            "expanded_marker_upper_count": sum(modules[n]["expanded_marker_upper_count"] for n in names),
        } for lib, names in file_modules.items()
    }

    def reads(lib):
        counts = {key: int(key == lib) for key in file_modules}
        for child in external_reads[lib]:
            for key, value in reads(child).items():
                counts[key] += value
        return counts

    roots = {}
    for lib in ["int", "real"]:
        count = reads(lib)
        weighted = lambda field: sum(count[key] * sums[key][field] for key in count)
        b = weighted("expanded_source_bytes")
        c = weighted("module_count")
        a = weighted("expanded_marker_upper_count")
        roots[lib] = {
            "whole_file_parse_upper_counts": count,
            "whole_file_parse_upper_total": sum(count.values()),
            "expanded_source_bytes": b, "declaration_head_upper_count": 4 * b,
            "ordinary_theory_close_upper_count": c,
            "namespace_clone_path_visit_upper_count": 0,
            "swallowed_clone_marker_upper_count": a,
            "non_tuple_publication_upper_count": 4 * b + c,
            "c_base_constant_excluding_8I": 4 * b + c + 4 * (38679 + a + 1),
        }
    assert roots["int"]["expanded_source_bytes"] == 147480
    assert roots["real"]["expanded_source_bytes"] == 807447
    assert roots["real"]["ordinary_theory_close_upper_count"] == 1203
    assert roots["real"]["swallowed_clone_marker_upper_count"] == 4698
    assert roots["real"]["c_base_constant_excluding_8I"] == 3404503
    source = []
    with tarfile.open(WHY) as archive:
        for member, spans in SPANS.items():
            data = archive.extractfile(member).read()
            lines = data.decode().splitlines(keepends=True)
            for lo, hi in spans:
                excerpt = "".join(lines[lo - 1:hi])
                source.append({"archive": str(WHY.relative_to(ROOT)),
                    "member": member, "first_line": lo,
                    "last_line": hi, "member_identity": identity(data),
                    "excerpt_identity": identity(excerpt.encode()), "excerpt": excerpt})
    with tarfile.open(OCAML) as archive:
        data = archive.extractfile(OCAML_MEMBER).read()
        lines = data.decode().splitlines(keepends=True)
        for lo, hi in OCAML_SPANS:
            excerpt = "".join(lines[lo - 1:hi])
            source.append({"archive": str(OCAML.relative_to(ROOT)),
                "member": OCAML_MEMBER, "first_line": lo, "last_line": hi,
                "member_identity": identity(data),
                "excerpt_identity": identity(excerpt.encode()), "excerpt": excerpt})
    result = {
        "schema": "silver.retained-why-library-publication-bound.v1",
        "why3_revision": inv["why3_revision"],
        "inventory_identity": identity(inv_bytes),
        "source_file_identities": file_ids,
        "source_bytes_all_files": 38678,
        "source_bytes_in_module_spans": sum(x["source_bytes"] for x in modules.values()),
        "module_recurrence": modules, "file_recurrence": sums,
        "external_read_actions": external_reads, "direct_root_bounds": roots,
        "implicit_tuple": {"lexical_arity_ceiling": 38678,
            "lexical_arity_domain_size": 38679,
            "initial_arity_domain_cardinality_upper": "2*I",
            "tuple_module_and_theory_publications_per_key": 4,
            "global_escaping_signal_exception_upper": 2,
            "final_escaping_incomplete_construction_allowance": 1,
            "memo_tables": 2,
            "resize_assignments_per_table_global_upper": 64,
            "resize_assignments_both_tables_global_upper": 128,
            "resize_loss_publication_allowance_global": "4*128*K",
            "signal_publication_allowance_global": "4*e*(K+1)"},
        "common_c_base_formula": "3404503 + 8*I",
        "whole_suffix_writer_formula": "E*(3*T_prepared + 2*C_base) + 4*128*K + 4*e*(K+1)",
        "C_base_is_not_standalone_C_lib": True,
        "semantic_transfer_is_not_established_by_lexical_checker": True,
    }
    return result, source


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    bound, source = project()
    outputs = [("bound.json", bound), ("source-witness.json", source)]
    for name, value in outputs:
        path = HERE / name
        if args.write:
            path.write_text(json.dumps(value, indent=2) + "\n")
        else:
            assert json.loads(path.read_text()) == value, name
    print(json.dumps({"status": "pass", "module_rows": len(bound["module_recurrence"]),
        "source_slices": len(source), "source_members": len(SPANS) + 1,
        "int_parse_count": bound["direct_root_bounds"]["int"]["whole_file_parse_upper_total"],
        "real_parse_count": bound["direct_root_bounds"]["real"]["whole_file_parse_upper_total"],
        "c_base_formula": bound["common_c_base_formula"],
        "whole_suffix_writer_formula": bound["whole_suffix_writer_formula"],
        "initial_registration_attachment_checked": False,
        "native_execution": False, "predecessor_checker_replay": False}, indent=2))


if __name__ == "__main__":
    main()

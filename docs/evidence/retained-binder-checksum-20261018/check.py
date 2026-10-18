"""Replay local checksum arithmetic and source identities, not a whole-run bound."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

ROOT = Path(__file__).resolve().parent


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    manifest = json.loads((ROOT / "manifest.json").read_bytes())
    assert identity((ROOT / "inputs.tar.gz").read_bytes()) == manifest["archive"]
    with tarfile.open(ROOT / "inputs.tar.gz") as archive:
        assert sorted(archive.getnames()) == sorted(r["path"] for r in manifest["files"])
        files = {}
        for row in manifest["files"]:
            raw = archive.extractfile(row["path"]).read()
            assert identity(raw) == {k: row[k] for k in ("bytes", "sha256")}
            files[row["path"]] = raw
    for tag in ("ada", "gcc"):
        corpus = json.loads(files["corpus/" + tag + "-manifest.json"])
        assert corpus["commit"] == manifest["upstream_commit"]
        rows = {r["path"]: r for r in corpus["files"]}
        for name, raw in files.items():
            if not name.startswith("gcc/") or (name.startswith("gcc/ada/") != (tag == "ada")):
                continue
            source_name = name.removeprefix("gcc/ada/") if tag == "ada" else name
            assert identity(raw) == {k: rows[source_name][k] for k in ("bytes", "sha256")}
    for name, markers in {
        "gcc/ada/scng.adb": [b"UI_Int_Value := UI_Int_Value * UI_Base + Extended_Digit_Value;", b"if UI_Scale = 0 then\n               Int_Literal_Value := UI_Num_Value;"],
        "gcc/ada/uintp.ads": [b"Base_Bits : constant := 15;", b"Max_Direct : constant Int := (Base - 1) * (Base - 1);"],
        "gcc/ada/uintp.adb": [b"Uints.Append ((Length => Size, Loc => Udigits.Last + 1));", b"UI_Ints.Set (Input, U);", b"return Vector_To_Uint (Product, Neg);"],
        "gcc/ada/gcc-interface/trans.cc": [b"gnu_result = UI_To_gnu (Intval (gnat_node), gnu_type);"],
        "gcc/ada/gcc-interface/cuintp.cc": [b"gnu_base = build_cst_from_int (comp_type, Base);", b"if (!TREE_OVERFLOW (next_ret) || type)", b"gnu_ret = convert (type, gnu_ret);"],
        "gcc/tree.cc": [b"TYPE_CACHED_VALUES (type) = make_tree_vec (max_slots);", b"int_cst_hash_table->find_slot (int_cst_node, INSERT)", b"int_cst_hash_table->remove_elt (TYPE_MAX_VALUE (type));", b"int_cst_node = make_int_cst (1, 1);"],
        "gcc/hash-table.h": [b"if (insert == INSERT && m_size * 3 <= m_n_elements * 4)", b"m_n_deleted--;", b"m_n_elements++;", b"m_n_elements -= m_n_deleted;", b"value_type *nentries = alloc_entries (nsize);", b"ggc_free (oentries);"],
        "gcc/params.opt": [b"Var(param_integer_share_limit) Init(251)"],
        "gcc/fold-const.cc": [b"if (CONSTANT_CLASS_P (arg0) && CONSTANT_CLASS_P (arg1))"]}.items():
        assert all(m in files[name] for m in markers), name
    predecessor_manifest = json.loads(files["predecessor/manifest.json"])
    predecessor_rows = {r["path"]: r for r in predecessor_manifest["archives"]["artifacts.tar.gz"]["members"]}
    for name in ("output/output/b__main~1.ads", "output/invocation.json"):
        assert identity(files["predecessor/" + name]) == {k: predecessor_rows[name][k] for k in ("bytes", "sha256")}
    ads = files["predecessor/output/output/b__main~1.ads"]
    declarations = re.findall(rb"u\d+ : constant Version_32 := 16#([0-9a-fA-F]{8})#;", ads)
    checksum, = re.findall(rb"u00001 : constant Version_32 := 16#([0-9a-fA-F]{8})#;", ads)
    assert len(declarations) == 140 and checksum == b"d02a2ed5"
    assert b'"mainB"' in ads
    prior = json.loads(files["predecessor/result.json"])
    lifetime = prior["cases"]["output"]["lifetime"]
    observed = lifetime["counters"]["ggc_bytes"]["positive_sum"]
    threshold = prior["fixed_source_path_family_no_collection_threshold_bytes"]
    assert observed == 4481000 and threshold == 5242880
    assert not prior["varying_output_checksum_lifetime_bound_established"]
    bits, width = 32, 8
    base = 2**15
    uint_digits = (bits + 14) // 15
    assert uint_digits == 3 and 0 <= 16**width - 1 < base**uint_digits
    # The maximum of each prefix, product and sum occurs for all hexadecimal F.
    prefix = 0
    for _ in range(width):
        product = 16 * prefix
        prefix = product + 15
        assert product <= prefix <= 2**bits - 1
    constructor_requests = 2 + (uint_digits - 1) * 3
    result = {
        "scope": "Source-only local checksum ingress bounds and exact missing lifetime transfer",
        "source_files_verified": sum(n.startswith("gcc/") for n in files), "new_native_executions": 0,
        "checksum_domain": {"bits": bits, "hex_digits": width, "baseline": int(checksum, 16)},
        "scanner_local_only": {"arithmetic_calls_upper": 2 * width,
                               "Uint_rows_upper": 2 * width,
                               "Udigit_entries_upper": 2 * width * uint_digits,
                               "UI_From_Int_cache_misses_upper": 2 * width,
                               "whole_Ada_semantic_pass_bound": False},
        "one_UI_To_gnu_call_only": {"required_type": "nonbiased unsigned 32-bit integer",
                                    "constant_constructor_or_fold_requests_upper": constructor_requests,
                                    "global_int_cst_hash_lookups_upper": constructor_requests - 1,
                                    "new_integer_types": 0,
                                    "global_cumulative_cache_allocation_delta_bound": None},
        "fixed_capture_GGC_bytes": observed, "conservative_no_collection_threshold_bytes": threshold,
        "headroom_bytes": threshold - observed,
        "whole_output_checksum_family_GGC_bound_established": False,
        "missing_transfer": "Bound cumulative global int_cst cache backing allocations, including later tombstone reuse and compaction, after the checksum-dependent requests; also discharge other semantic consumers and call multiplicity.",
        "production_flags_or_admission_changed": False,
    }
    rendered = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.write_text(rendered)
    else:
        assert json.loads((ROOT / "result.json").read_bytes()) == result
    print(json.dumps(result))


if __name__ == "__main__":
    main()

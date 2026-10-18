#!/usr/bin/env python3
"""Focused independent emission-review evidence; no native execution."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import runpy
import subprocess
import sys
import time

REPO = Path(__file__).resolve().parents[2]
PACKET = REPO / "docs/evidence/retained-literal-emission-closure-20261018"
FREEZE = "a937eaede5b01b438b2b2fb4dccc49cb3a8469d5"


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--gcc-root", type=Path, required=True)
    args = parser.parse_args()
    sys.dont_write_bytecode = True
    start = time.monotonic()
    for name in ("derive.py", "source-manifest.json", "result.json", "check-results.json"):
        path = PACKET / name
        assert path.read_bytes() == subprocess.check_output(
            ["git", "show", f"{FREEZE}:{path.relative_to(REPO)}"], cwd=REPO)
    manifest = json.loads((PACKET / "source-manifest.json").read_text())
    selected = {"gcc/emit-rtl.cc", "gcc/varasm.cc", "gcc/gengenrtl.cc", "gcc/rtl.cc",
                "gcc/final.cc", "gcc/toplev.cc", "gcc/ada/gcc-interface/utils.cc",
                "gcc/coretypes.h", "gcc/config/elfos.h"}
    sources = {}
    for row in manifest["files"]:
        if row["path"] not in selected:
            continue
        raw = (args.gcc_root / row["path"]).read_bytes()
        assert identity(raw) == {key: row[key] for key in ("bytes", "sha256")}
        assert hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest() == row["git_blob_sha1"]
        sources[row["path"]] = raw.decode()
    assert set(sources) == selected
    generator = next(row for row in manifest["files"] if row["path"] == "gcc/gengenrtl.cc")
    fetched = json.loads((args.gcc_root / "manifest.json").read_text())
    assert fetched["commit"] == manifest["gcc_revision"]
    assert fetched["url"] == generator["upstream_origin"]["url"]
    assert generator["upstream_origin"]["manifest_entry"] in fetched["files"]
    assert gzip.decompress((PACKET / generator["retained_copy"]).read_bytes()).decode() == sources["gcc/gengenrtl.cc"]
    # Check the generated constructor is neither an excluded nor cached wrapper.
    gen = sources["gcc/gengenrtl.cc"]
    special = gen[gen.index("special_rtx (int idx)"):gen.index("find_formats (void)")]
    assert '"CODE_LABEL"' not in special
    assert 'rt = rtx_alloc (code PASS_MEM_STAT);' in gen
    assert 'ggc_alloc_rtx_def_stat (RTX_CODE_SIZE (code) + extra' in sources["gcc/rtl.cc"]
    emit = sources["gcc/emit-rtl.cc"]
    assert len(re.findall(r"\blabel_num\+\+", emit)) == 1
    assert len(re.findall(r"\blabel_num\s*=(?!=)", emit)) == 2
    varasm = sources["gcc/varasm.cc"]
    assert len(re.findall(r"\bconst_labelno\+\+|\+\+const_labelno\b", varasm)) == 4
    assert len(re.findall(r"\bconst_labelno\s*=(?!=)", varasm)) == 1
    final = sources["gcc/final.cc"]
    assert final.count("insn_counter++;") == 1
    assert "final_start_function_1 (&first, asm_out_file, &seen, optimize);" in final
    assert "final_1 (first, asm_out_file, seen, optimize);" in final
    # The pending-list source is not silently replaced with null Main's case.
    assert "assemble_external_real (TREE_VALUE (list));" in varasm
    external = varasm.split("\ndefault_elf_asm_output_external (", 1)[1].split("\n/*", 1)[0]
    assert "maybe_assemble_visibility (decl);" in external
    assert not re.search(r"\b(?:fprintf|fputs|putc|assemble_name)\s*\(", external)
    visibility = varasm.split("\nmaybe_assemble_visibility (", 1)[1].split("\n/*", 1)[0]
    assert "if (vis != VISIBILITY_DEFAULT)" in visibility and "return false;" in visibility

    historical_paths = {
        "docs/research/retained-output-rtl.md", "docs/research/retained-native-expansion.md",
        "docs/research/retained-backend-gigi.md",
        "docs/evidence/retained-literal-assembler-20261018/compose.py"}
    for row in manifest["historical_silver_inputs"]:
        if row["path"] not in historical_paths:
            continue
        raw = subprocess.check_output(["git", "show",
            manifest["reviewed_silver_revision"] + ":" + row["path"]], cwd=REPO)
        assert identity(raw) == {key: row[key] for key in ("bytes", "sha256")}
        assert raw == (REPO / row["path"]).read_bytes()
    module = runpy.run_path(str(PACKET / "derive.py"))
    evaluate = module["evaluate"]
    assembler = runpy.run_path(str(REPO /
        "docs/evidence/retained-literal-assembler-20261018/compose.py"))["interface"]
    limit = 2**31-1
    # Solve the ordinary endpoint independently, fixing C while varying N.
    n = (limit - 39258 - 7*3 - 45)//7
    for offset, fits in ((0, True), (1, False)):
        result = evaluate(3, n+offset, 0, 0)
        assert result["counter_and_emission_guards"]["ordinary_label_next_signed_int"] is fits
        assert result["counter_bounds"]["ordinary_label_next_at_exit_upper"] == 39303+7*(3+n+offset)
    c = (limit-39257)//2
    for offset, fits in ((0, True), (1, False)):
        assert evaluate(c+offset, 0, 0, 0)["counter_and_emission_guards"]["constant_label_next_signed_int"] is fits
    t = (limit-22)//31
    assert evaluate(t, 0, 0, 0)["counter_and_emission_guards"]["text_and_CFI_location_signed_int"]
    assert not evaluate(t+1, 0, 0, 0)["counter_and_emission_guards"]["text_and_CFI_location_signed_int"]
    for counts in ((1, 0, 0, 0), (2, 9, 3, 3), (17, 4, 1001, 1000)):
        result, old = evaluate(*counts), assembler(*counts)
        assert result["assembly"] == old["assembly"]
        assert result["final_chain"] == old["final_chain"]
        assert result["text_bytes_upper"] == old["text_bytes_upper"]
        assert result["emission"]["rodata_bytes_upper"] == old["GAS"]["rodata_bytes_upper"]
        assert not result["production_invocation_and_materialization_established"]
        assert not result["complete_non_label_global_counter_lifetime_closed"]
        assert not result["complete_shared_backing_and_collector_capacity_closed"]
        assert not result["whole_literal_pipeline_capacity_established"]
    raw = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin Silver_IO.Put ("Put_Line -- ""quoted"""); null; Silver_IO.Put_Line (""); end Main;'
    result = module["evaluate_source"](raw)
    assert result["source_counts"]["decoded_literal_lengths"] == [20, 0]
    assert result["emission"]["external_pending_declarations_upper"] == 2
    invalid = raw.replace(b'null;', b'pragma Import (C, Other);')
    try:
        module["evaluate_source"](invalid)
    except ValueError:
        pass
    else:
        raise AssertionError("accepted foreign declaration route")
    recorded = json.loads((PACKET / "check-results.json").read_text())
    assert recorded["checks_passed"] == 302
    print(json.dumps({"status": "passed", "freeze": FREEZE,
        "focused_source_identities": len(selected), "historical_shape_inputs": len(historical_paths),
        "supplemental_generator_origin_matches_retained_fetch": True,
        "independent_endpoint_pairs": 3, "unchanged_assembler_compositions": 3,
        "actual_source_cases": 2, "broad_302_check_success_replayed": False,
        "native_execution": False, "elapsed_seconds": time.monotonic()-start}, indent=2))


if __name__ == "__main__":
    main()

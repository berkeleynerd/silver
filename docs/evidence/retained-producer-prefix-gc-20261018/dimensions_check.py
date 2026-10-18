#!/usr/bin/env python3
"""Replay additional fixed-prefix storage/count dimensions, offline only."""
import argparse
import hashlib
import json
import struct
from pathlib import Path

from check import identity, read_archive

HERE = Path(__file__).resolve().parent


def integers(value):
    if isinstance(value, int) and not isinstance(value, bool):
        yield value
    elif isinstance(value, list):
        for child in value:
            yield from integers(child)
    elif isinstance(value, dict):
        for child in value.values():
            yield from integers(child)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    inputs = json.loads((HERE / "dimensions-inputs.json").read_bytes())
    for filename, key in (("identity.json", "prior_identity_sha256"),
                          ("result.json", "prior_result_sha256")):
        assert hashlib.sha256((HERE / filename).read_bytes()).hexdigest() == inputs[key]
    previous = json.loads((HERE / "result.json").read_bytes())
    manifest = inputs["archive"]
    archive = HERE / manifest["filename"]
    assert identity(archive.read_bytes()) == {k: manifest[k] for k in ("bytes", "sha256")}
    source = read_archive(archive)
    assert {n: identity(b) for n, b in source.items()} == manifest["members"]
    original = json.loads((HERE / "identity.json").read_bytes())
    raw_path = HERE / "observations.tar.gz"
    assert identity(raw_path.read_bytes()) == original["archives"][raw_path.name]["archive"]
    raw = read_archive(raw_path)
    plan = json.loads(raw["success/plan.json"])
    static_bytes = 0
    for path, row in inputs["images"].items():
        assert row["identity"] == plan["file_identities"][path]
        header = source["elf/" + Path(path).name + ".header"]
        assert header[:6] == b"\x7fELF\x02\x01"
        offset = struct.unpack_from("<Q", header, 32)[0]
        size, count = struct.unpack_from("<HH", header, 54)
        values = [struct.unpack_from("<IIQQQQQQ", header, offset + i * size) for i in range(count)]
        loads = [dict(type=h[0], flags=h[1], offset=h[2], vaddr=h[3],
                      filesz=h[5], memsz=h[6], align=h[7]) for h in values if h[0] == 1]
        assert loads == row["program_headers"]
        total = sum(h["memsz"] for h in loads)
        assert total == row["load_memory_bytes"]
        static_bytes += total
    static_words = (static_bytes + 7) // 8
    startup = []
    numeric = []
    for case in plan["inputs"]:
        name = case["name"]
        summary = json.loads(raw["success/" + name + "/capture/summary.json"])
        base = summary["baseline"]
        # Deliberately double-count promoted words and all earlier garbage.
        # This safely covers live pre-Why3 objects as well as current arenas.
        old = (base["state"]["stat_minor_words"] + base["state"]["stat_major_words"]
               + base["minor_allocated_words"] + base["caml_allocated_words"])
        assert old == int(old)
        startup.append(int(old))
        value = json.loads(raw["success/" + name + "/" + case["argv"][-1]])
        numbers = list(integers(value))
        assert all(-(2**62) <= n <= 2**62 - 1 for n in numbers)
        numeric.append(dict(name=name, integer_fields=len(numbers), minimum=min(numbers), maximum=max(numbers)))
    dynamic = previous["maximum_prefix_allocation_words"]
    budget = dynamic + max(startup) + static_words
    text_rows = []
    for path, row in inputs["installed_text"].items():
        data = source[row["member"]]
        assert identity(data) == {k: row[k] for k in ("bytes", "sha256")}
        assert identity(data) == plan["file_identities"][path]
        # A full raw-byte absence check also excludes markers in comments.
        assert b"[#" not in data, path
        lines = data.split(b"\n")
        text_rows.append(dict(member=row["member"], bytes=len(data),
                              lines=len(lines), maximum_line_bytes=max(map(len, lines))))
    checks = dict(
        combined_word_budget_below_2_pow_27=budget < 2**27,
        single_byte_payload_below_2_pow_30=8 * budget < 2**30,
        double_byte_payload_arithmetic_fits_signed_OCaml=16 * budget + 1 < 2**62 - 1,
        scalar_collection_counts_fit_signed_OCaml=2 * budget + 1 < 2**62 - 1,
        synthetic_locations_fit_47_bits=dynamic + 1 < 2**47 - 1,
        fixed_imported_lines_fit_47_bits=max(r["lines"] for r in text_rows) < 2**47 - 1,
        fixed_imported_byte_columns_fit_16_bits=max(r["maximum_line_bytes"] for r in text_rows) < 2**16 - 1)
    assert all(checks.values())
    result = dict(scope="additional fixed-prefix counter and container dimensions",
                  dynamic_allocation_words=dynamic,
                  startup_managed_word_overcount=max(startup),
                  loaded_image_memory_bytes=static_bytes,
                  loaded_image_word_overcount=static_words,
                  combined_managed_and_static_word_budget=budget,
                  byte_payload_upper=8 * budget,
                  fixed_text_files=len(text_rows),
                  fixed_text_maximum_bytes=max(r["bytes"] for r in text_rows),
                  fixed_text_maximum_lines=max(r["lines"] for r in text_rows),
                  fixed_text_maximum_line_bytes=max(r["maximum_line_bytes"] for r in text_rows),
                  native_JSON_integer_fields=numeric, checks=checks,
                  semantic_free_variable_multiplicity_bound_established=False,
                  complete_prefix_capacity_established=False,
                  whole_pipeline_capacity_established=False,
                  native_executions=0)
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + "\n")
    else:
        assert result == json.loads((HERE / "dimensions-result.json").read_bytes())
        print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()

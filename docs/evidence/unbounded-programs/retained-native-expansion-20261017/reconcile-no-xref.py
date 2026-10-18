#!/usr/bin/env python3
"""Reconcile a proposed native-only -gnatx class without changing the baseline.

This records source inspection and arithmetic, not a compiler/binder execution
or a production configuration change. The current descriptors remain intact.
"""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

parser = argparse.ArgumentParser()
parser.add_argument("--ada", type=Path, required=True)
parser.add_argument("--gpr-archive", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
evidence = Path(__file__).resolve().parent
repo = evidence.parents[3]
manifest = json.loads((repo / "docs/evidence/unbounded-programs/"
    "continuation-20261017/frontend-lifetimes/complete-source-manifest.json").read_text())
driver = json.loads((repo / "docs/evidence/unbounded-programs/"
    "retained-source-closure-20261017/driver-reconciliation.json").read_text())
expected = {entry["path"]: entry for entry in manifest["files"]}
identities = {}

def record(name, raw, digest=None):
    sha = hashlib.sha256(raw).hexdigest()
    if digest is not None:
        assert sha == digest, name
    identities[name] = dict(bytes=len(raw), sha256=sha,
        git_blob_sha1=hashlib.sha1(b"blob "+str(len(raw)).encode()+b"\0"+raw).hexdigest())
    return raw.decode()

ada = {}
for name in ("switch-c.adb", "gnat1drv.adb", "lib-xref.adb", "lib-writ.adb",
             "ali.adb", "ali.ads", "gnatbind.adb", "alloc.ads", "opt.ads",
             "lib.ads", "lib.adb", "gcc-interface/lang-specs.h", "back_end.adb",
             "backend_utils.adb", "gcc-interface/misc.cc"):
    ada[name] = record("gcc/ada/"+name, (args.ada/name).read_bytes(), expected[name]["sha256"])
archive_raw = args.gpr_archive.read_bytes()
assert hashlib.sha256(archive_raw).hexdigest() == driver["gpr_source_archive"]["sha256"]
gpr = {}
with tarfile.open(args.gpr_archive) as archive:
    for name in ("gpr/src/gpr-ali.adb", "gpr/src/gpr-ali.ads",
                 "src/gprbuild-compile.adb", "src/gprbuild-post_compile.adb",
                 "src/gprbind.adb", "gpr/src/gpr-util.adb", "src/gprlib.adb"):
        member, = [item for item in archive.getmembers() if item.name.endswith("/"+name)]
        gpr[name] = record("gprbuild/"+name, archive.extractfile(member).read())

assert "when 'x' =>\n               Ptr := Ptr + 1;\n               Xref_Active := False;" in ada["switch-c.adb"]
assert ada["gnat1drv.adb"].count("Xref_Active := True;") == 2
assert "if Opt.Xref_Active then\n         Output_References;" in ada["lib-writ.adb"]
assert "This ALI parser does not care about Xref lines." in ada["ali.adb"]
assert "if C = EOF then\n         return Id;" in ada["ali.adb"]
assert "if C = EOF then\n         --  Check that gnatprove generated .ali files ended with right marker" in gpr["gpr/src/gpr-ali.adb"]
assert '(Argv\'Last <= 5 or else Argv (1 .. 5) /= "-gnat")' in gpr["src/gprbind.adb"]
assert "Xrefs_Initial                    : constant := 5_000;" in ada["alloc.ads"]
assert "Num_Buckets : constant := 2**16;" in ada["lib-xref.adb"]
assert "if not Scan_Common_Back_End_Switch (Switch_Chars) then" in ada["back_end.adb"]
assert "Store_Compilation_Switch (Switch_Chars);" in ada["back_end.adb"]
assert "else\n         return False;" in ada["backend_utils.adb"]

baseline = json.loads(record("baseline/native-invocation-inputs.json",
    (evidence/"native-invocation-inputs.json").read_bytes()))
programs = json.loads(record("baseline/local-envelope.json",
    (evidence/"local-envelope.json").read_bytes()))["representative_current_programs"]
argc = baseline["gnat1_argc_bound"]+1
stored = baseline["Compilation_Switches"]+["-gnatx"]
assert argc == 20 and len(stored) == 7
rows = []
for program in programs["programs"]:
    previous = program["ali_backing"]
    record_bounds = previous["record_character_bounds_before_LF"]
    without_xref = {key: value for key, value in record_bounds.items()
                    if not key.startswith("xref_")}
    xrefs = program["logical_join"]["tables"]["Xrefs_entries"]
    xref_bytes = xrefs*(record_bounds["xref_section"]
        +max(record_bounds["xref_Main_entity"],record_bounds["xref_fixed_entity"])
        +record_bounds["xref_continuation"]-72+4)
    # Only this new A record is added to the baseline non-X serializer rows.
    bytes_without_xref = previous["serialized_file_byte_bound"]-xref_bytes+9
    rows.append(dict(source=program["source"], sha256=program["sha256"],
        max_record_bytes_including_LF=max(without_xref.values())+1,
        serialized_file_byte_bound=bytes_without_xref,
        per_record_reserve_fits=max(without_xref.values())+1 <= 2112,
        source_identifier_length_in_remaining_ALI_records=False,
        baseline_non_xref_ALI_bounds_reused=True))

result = dict(
    scope="Proposed Linux x86_64 native Main -gnatx configuration; not selected, executed or implemented",
    gcc_commit=manifest["commit"], gpr_commit=driver["gpr_source_commit"],
    source_inputs=identities, added_native_switch="-gnatx",
    native_GCC_argument_count=baseline["native_GCC_argument_count"]+1,
    gnat1_argc_bound=argc, decoded_option_count_bound=argc,
    decoded_option_object_bytes=96*argc,
    canonical_save_argc_bound=2*argc,
    canonical_save_argv_pointer_count_including_sentinel=2*argc+1,
    Ada_argument_pointer_count_bound=2*argc-1,
    Compilation_Switches=stored, Compilation_Switches_count=len(stored),
    ALI_A_record_max_characters=max(2+len(s) for s in stored),
    ALI_A_total_bytes_including_LF=sum(3+len(s) for s in stored),
    Xrefs_lifetime_appends=0, Xrefs_initial_slots=5000,
    Xref_hash_header_bytes=65536*4,
    Xref_sort_vector_objects=0, Xref_current_name_objects=0,
    Xref_serialized_records=0,
    comparison_examples=rows,
    GNATprove_configuration_changed=False,
    existing_descriptors_or_production_flags_changed=False,
    compiler_binder_or_test_execution=False,
    semantic_reference_marking="Generate_Reference work before Xref_Active guard remains; do not delete its semantic/warning transfers",
    remaining="actual native configuration selection/implementation and validation, descriptor and provenance updates, complete tool-route capacity")
warning = "-Wno-free-nonheap-object"
combined_stored = stored+[warning]
assert len(warning) == 24
result["combined_with_native_warning_option"] = dict(
    scope="Arithmetic and forwarding consequences of the separately justified optional native warning-pass selector",
    added_switches=["-gnatx",warning], native_GCC_argument_count=12,
    gnat1_argc_bound=21, decoded_option_count_bound=21,
    decoded_option_object_bytes=96*21,
    canonical_save_argc_bound=42,
    canonical_save_argv_pointer_count_including_sentinel=43,
    Ada_argument_pointer_count_bound=41,
    Compilation_Switches=combined_stored, Compilation_Switches_count=8,
    ALI_A_record_max_characters=max(2+len(s) for s in combined_stored),
    ALI_A_total_bytes_including_LF=sum(3+len(s) for s in combined_stored),
    largest_argument_characters="max(24,P+7)",
    gprbind_drops_from_replayed_Main_A_records=["-gnatx"],
    gprbind_retains_from_replayed_Main_A_records=[warning],
    comparison_examples=[dict(row,
        serialized_file_byte_bound=row["serialized_file_byte_bound"]+3+len(warning))
        for row in rows],
    warning_pass_semantics_proved_by_this_reconciler=False,
    production_or_proof_options_changed=False,
    binder_compile_descriptor_update_required=True)
args.output.write_text(json.dumps(result, indent=2, sort_keys=True)+"\n")
print(json.dumps(dict(source_inputs=len(identities), examples=len(rows),
    proposed_gnat1_argc=argc, complete_capacity_result=False)))

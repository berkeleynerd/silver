#!/usr/bin/env python3
"""Reconcile historical unindexed native launch shapes; no tool is executed.

Source assertions preserve reviewed premises, not a verified GPR/GCC evaluator.
The historical GPR launch environment was not retained. The output separates
the source-derived class, retained actual observations and required enforcement.
The indexed Main repair has a separate reconcile-indexed-invocation.py; this
checker rejects that writer rather than regenerating an outdated descriptor.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser()
parser.add_argument("--ada", type=Path, required=True)
parser.add_argument("--gcc", type=Path, required=True, help="GCC directory containing gcc.cc")
parser.add_argument("--gpr-archive", type=Path, required=True)
parser.add_argument("--fixed-capture", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
repo = Path(__file__).resolve().parents[4]
closure = repo / "docs/evidence/unbounded-programs/retained-source-closure-20261017"
driver = json.loads((closure / "driver-reconciliation.json").read_text())
manifest = json.loads((repo / "docs/evidence/unbounded-programs/continuation-20261017/"
                       "frontend-lifetimes/complete-source-manifest.json").read_text())
expected = {entry["path"]: entry for entry in manifest["files"]}
identities = {}

def record(name, raw, expected_hash=None):
    digest = hashlib.sha256(raw).hexdigest()
    if expected_hash is not None:
        assert digest == expected_hash, name
    identities[name] = dict(bytes=len(raw),sha256=digest,
        git_blob_sha1=hashlib.sha1(b"blob "+str(len(raw)).encode()+b"\0"+raw).hexdigest())
    return raw.decode()

ada = {}
for name in ("gcc-interface/lang-specs.h","gcc-interface/misc.cc","back_end.adb",
             "switch-c.adb","lib.ads","lib.adb","lib-util.adb","osint.adb","osint.ads"):
    ada[name] = record("gcc/ada/"+name,(args.ada/name).read_bytes(),expected[name]["sha256"])
gcc = {}
# These three retained files were byte-compared with raw.githubusercontent.com
# at the manifest's exact commit on 2026-10-18. Regeneration is offline.
for name,digest in {
    "gcc.cc":"59ac02bc5147a8a4d79473edc41b8d1af8bd75628e00bfafab0c80eb36614346",
    "opts-common.cc":"9b08d0eab835c3720cb37120282ed10b270f881d37acd40733a8d12c6abb448a",
    "opts.h":"ec66640207dd0a237d42e6743c8d2416095f862f9b252535e780c03d5f2d75f0",
}.items():
    gcc[name] = record("gcc/"+name,(args.gcc/name).read_bytes(),digest)

archive_raw = args.gpr_archive.read_bytes()
assert hashlib.sha256(archive_raw).hexdigest() == driver["gpr_source_archive"]["sha256"]
gpr = {}
with tarfile.open(args.gpr_archive) as archive:
    for name in ("src/gprbuild-compile.adb","gpr/src/gpr-opt.ads","gpr/src/gpr.ads"):
        member, = [item for item in archive.getmembers() if item.name.endswith("/"+name)]
        gpr[name] = record("gprbuild/"+name,archive.extractfile(member).read())

native_xml = record("retained/native-gnat.xml",(closure/"driver-snapshots/native-gnat.xml").read_bytes())
project = record("retained/program.gpr",(closure/"driver-snapshots/program-Z0j19G/program.gpr").read_bytes())
production = record("silver/src/silver.adb",(repo/"src/silver.adb").read_bytes())
assert 'for Body (""Main"") use ""main.adb"" at 1;' not in production, (
    'historical unindexed descriptor only; use reconcile-indexed-invocation.py')
platforms = record("silver/scripts/platforms.py",(repo/"scripts/platforms.py").read_bytes())
main_ali = record("retained/main.ali",(closure/"driver-snapshots/program-Z0j19G/obj/main.ali").read_bytes())
first_compiler = re.search(r"package Compiler is(.*?)end Compiler;",native_xml,re.S).group(1)
leading = re.search(r'Leading_Required_Switches\s*\("Ada"\)\s*use\s*\((.*?)\)',first_compiler,re.S).group(1)
leading = re.findall(r'"([^"]*)"',leading)
defaults = re.search(r'Default_Switches\s*\("Ada"\)\s*use\s*\((.*?)\)',project,re.S).group(1)
defaults = re.findall(r'"([^"]*)"',defaults)
assert leading == ["-c","-x","ada","-gnatA"]
assert defaults == ["-gnat2022","-gnata","-gnato"]
assert '""-gnat2022"", ""-gnata"", ""-gnato""' in production
assert 'gprbuild -P ' in production and '/program.gpr -p' in production
assert 'Mapping_File_Switches' in first_compiler and '"-gnatem="' in first_compiler
assert 'Config_File_Switches' in first_compiler and '"-gnatec="' in first_compiler
assert 'Object_Path_Switches' not in native_xml
assert 'Use_Include_Path_File : Boolean := False;' in gpr["gpr/src/gpr-opt.ads"]
for name in ("Source_File_Switches","Object_File_Switches","Object_Path_Switches",
             "Compiler_Trailing_Required_Switches"):
    assert re.search(name+r"\s*:\s*Name_List_Index\s*:=\s*No_Name_List",gpr["gpr/src/gpr.ads"])
assert ('Id.Language.Config.Mapping_File_Switches = No_Name_List\n'
        '                 or else Opt.Use_Include_Path_File') in gpr["src/gprbuild-compile.adb"]
stored = [line[2:] for line in main_ali.splitlines() if line.startswith("A ")]
assert stored == ["-gnatA"]+defaults+["-mtune=generic","-march=x86-64"]
for name in ("ADA_INCLUDE_PATH","ADA_OBJECTS_PATH","ADA_PRJ_INCLUDE_FILE",
             "ADA_PRJ_OBJECTS_FILE","GNSA_ROOT","GCC_EXEC_PREFIX","COMPILER_PATH"):
    assert name not in platforms

with tarfile.open(args.fixed_capture/"capture.tar.gz") as archive:
    raw = archive.extractfile("all-roots/invocation.json").read()
    capture = json.loads(raw)
    record("retained/direct-native-invocation.json",raw)
assert len(capture["argv"]) == 20
assert set(capture["environment"]) == {"ADA_INCLUDE_PATH","ADA_OBJECTS_PATH"}
assert len(capture["driver_dry_run"]) == 10

launch = leading+defaults+["-gnatec={configuration}","-gnatem={mapping}","{workspace}/main.adb"]
assert len(launch) == 10
gnat1 = dict(executable=1,quiet=1,dump_option_pairs=6,GNAT_flags_and_configuration=6,
             selected_target_defaults=2,source=1,assembly_output_pair=2)
assert sum(gnat1.values()) == 19
result = dict(
    scope="Selected Linux x86_64 native Main class, conditional on controlled invocation and search; not production enforcement",
    gcc_commit=manifest["commit"],gpr_commit=driver["gpr_source_commit"],source_inputs=identities,
    native_GCC_argv_excluding_executable=launch,native_GCC_argument_count=10,
    native_GCC_cwd="{workspace}/obj",
    source_derived_gnat1_argv_allowance=gnat1,gnat1_argc_bound=19,
    decoded_option_count_bound=19,decoded_option_component_bytes_upper_bound=96,
    canonical_save_argv_pointer_count_including_sentinel=39,
    canonical_save_argc_bound=38,Ada_argument_pointer_count_bound=37,
    Compilation_Switches=stored,Compilation_Switches_count=len(stored),
    ALI_A_record_characters=[2+len(s) for s in stored],
    ALI_A_record_max_characters=max(2+len(s) for s in stored),
    ALI_A_total_bytes_including_LF=sum(3+len(s) for s in stored),
    source_derived_native_project_include_path_file_count=0,
    source_derived_native_object_path_switch_count=0,
    required_controlled_environment=dict(
        ADA_INCLUDE_PATH="exact selected native adainclude directory",
        ADA_OBJECTS_PATH="exact selected native adalib directory",
        absent=["ADA_PRJ_INCLUDE_FILE","ADA_PRJ_OBJECTS_FILE","GNSA_ROOT",
                "GCC_EXEC_PREFIX","COMPILER_PATH","LIBRARY_PATH","LPATH","GCC_COMPARE_DEBUG"],
        other_inputs="Use a complete controlled environment; pin PATH, temporary-directory selection and locale, and prohibit user specs/plugins or alternate tool/config inputs"),
    required_default_search="Validate actual relocated search-prefix and adainclude/adalib paths; require ada_source_path/ada_object_path absent for this class, or price their exact contents in a different descriptor",
    required_path_premise="P bounds every raw/normalized/resolved complete path, including argv[0], GCC temporary assembly, selected default directories and default-search probe names",
    retained_observations=dict(direct_capture_argv_count=20,
        direct_capture_environment_keys=sorted(capture["environment"]),
        native_ALI_stored_switches=stored,
        historical_native_GPR_argv_or_environment_retained=False),
    limitations=["GPR installed executable/source identity is not established; the proposed pre-launch validator must check actual generated data",
        "The existing runtime clears only project/config overrides; the full controlled environment above is not implemented",
        "The complete GCC driver prefix/spec/temporary storage and default-search path realization remain separate",
        "The direct successful capture and source-derived GPR class are distinct evidence",
        "No compiler, proof, test or new capture is run by this script"],
    complete_capacity_result=False)
args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+"\n")
print(json.dumps(dict(source_files=len(identities),native_GCC_arguments=10,
                      gnat1_argc_bound=19,stored_switches=len(stored))))

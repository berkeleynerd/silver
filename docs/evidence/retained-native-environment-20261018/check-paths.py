#!/usr/bin/env python3
"""Reconcile the selected GCC path/temp transfer without running GCC.

The optional first capture reads filesystem metadata only. Ordinary checking
uses retained bytes and makes no claim about the present installation.
The handwritten phase/path argument in retained-native-environment.md is needed.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import tarfile


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--capture-configuration", action="store_true")
args = parser.parse_args()
bundle = Path(__file__).resolve().parent


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read_archive(name, manifest_name):
    manifest = json.loads((bundle / manifest_name).read_text())
    raw_archive = (bundle / name).read_bytes()
    if "archive_sha256" in manifest:
        assert sha(raw_archive) == manifest["archive_sha256"]
    values = {}
    with tarfile.open(bundle / name) as archive:
        assert set(archive.getnames()) == {row["path"] for row in manifest["files"]}
        for row in manifest["files"]:
            raw = archive.extractfile(row["path"]).read()
            assert len(raw) == row["bytes"] and sha(raw) == row["sha256"]
            values[row["path"]] = raw.decode()
    return values


sources = read_archive("sources.tar.gz", "sources.json")
artifacts = read_archive("artifacts.tar.gz", "identity.json")
capture = json.loads(artifacts["capture/capture/result.json"])
assert capture == json.loads((bundle / "capture.json").read_text())
gcc = sources["gcc/gcc.cc"]
temp = sources["libiberty/make-temp-file.c"]
assert "int max_len;" in gcc and "len = strlen (prefix);" in gcc
assert "len = paths->max_len + extra_space + 1;" in gcc
assert "len += MAX (MAX (suffix_len, multi_os_dir_len), multiarch_len);" in gcc
assert 'specs_file = find_a_file (&startfile_prefixes, "specs", R_OK, true);' in gcc
assert 'strlen (exec_prefix) + strlen (spec_machine_suffix) + sizeof ("specs")' in gcc
assert gcc.index("  set_multilib_dir ();", gcc.index("driver::set_up_specs")) > gcc.index("if (access (specs_file, R_OK) == 0)")
assert "len = strlen (base);" in temp and "len + 2" in temp
assert "int base_len, suffix_len, prefix_len;" in temp
assert "#define TEMP_FILE_LEN (sizeof(TEMP_FILE) - 1)" in temp
assert '#define TEMP_FILE "XXXXXX"' in temp

driver = capture["commands"][0]["argv"][0]
driver_bin = driver.rsplit("/", 1)[0] + "/"
host = "x86_64-pc-linux-gnu"
version = "16.1.0"
machine = host + "/" + version + "/"
just_machine = host + "/"
multiarch = "x86_64-linux-gnu/"
multi_os = "../lib64/"
exec_prefix = driver_bin + "../lib/gcc/"
libexec_prefix = driver_bin + "../libexec/gcc/"
tooldir = exec_prefix + machine + "../../../../" + host + "/"
# Source's two prefix insertions before the initial specs search.  Neither
# selected entry requires a machine suffix; multilib state is still unset.
early = [(exec_prefix, False), (tooldir + "lib/", True)]
initial_specs = [base + suffix + "specs" for base, _ in early
                 for suffix in (machine, "")]
override_specs = exec_prefix + just_machine + "specs"


def selected_paths(prefixes, do_multi):
    """Selected for_each_path specialization; no nontrivial multilib_dir."""
    result = []
    for prefix, os_multilib in prefixes:
        result.extend((prefix + machine, prefix + multiarch))
        result.append(prefix + (multi_os if do_multi and os_multilib else ""))
    if do_multi:
        result.extend(prefix for prefix, os_multilib in prefixes if os_multilib)
    return result


program_prefixes = [(libexec_prefix, False), (tooldir + "bin/", False)]
library_prefixes = early + [(exec_prefix + machine + "../../../", True),
                            ("/lib/", True), ("/usr/lib/", True)]
programs = selected_paths(program_prefixes, False)
libraries = selected_paths(library_prefixes, True)
printed = {}
for line in artifacts["capture/capture/search-dirs.stdout"].split("\n"):
    if ": =" in line:
        name, value = line.split(": =", 1)
        printed[name] = value.split(":")
assert printed == {"programs": programs, "libraries": libraries}
assert len(programs) == 6 and len(libraries) == 19
assert all(path in {p + "specs" for p in libraries} for path in initial_specs)

path_inputs = {
    "driver": driver,
    "early_startfile_prefixes": [p for p, _ in early],
    "initial_specs_search": initial_specs,
    "separate_specs_override": override_specs,
    "program_prefixes": [p for p, _ in program_prefixes],
    "library_prefixes": [p for p, _ in library_prefixes],
    "machine_suffix": machine,
    "multiarch_suffix": multiarch,
    "multilib_os_suffix": multi_os,
    "TMPDIR": capture["environment"]["TMPDIR"],
}
config_file = bundle / "path-configuration.json"
if args.capture_configuration:
    # Exclusive creation preserves any existing capture, including failures.
    with config_file.open("x") as output:
        rows = []
        for path in initial_specs + [override_specs]:
            try:
                st = os.lstat(path)
                state = {"exists_without_following_symlinks": True,
                         "mode": st.st_mode, "bytes": st.st_size}
            except FileNotFoundError:
                state = {"exists_without_following_symlinks": False}
            rows.append({"path": path, **state, "readable": os.access(path, os.R_OK)})
        output.write(json.dumps({
            "captured_at": datetime.now(timezone.utc).isoformat(),
            "method": "Python lstat/access only; no compiler or subprocess execution",
            "inputs": path_inputs,
            "implicit_specs_candidates": rows,
            "production_configuration_check_implemented": False,
        }, indent=2, sort_keys=True) + "\n")
config = json.loads(config_file.read_text())
assert config["inputs"] == path_inputs
assert [r["path"] for r in config["implicit_specs_candidates"]] == initial_specs + [override_specs]
assert all(not r["exists_without_following_symlinks"] and not r["readable"]
           for r in config["implicit_specs_candidates"])

INT_MAX = 2**31 - 1
PTRDIFF_MAX = 2**63 - 1
M = max(map(len, path_inputs["library_prefixes"] + path_inputs["program_prefixes"]))
S = max(map(len, (machine, multiarch, multi_os)))
N = max(map(len, ("specs", "gnat1", "as")))
search_buffer = M + S + N + 1
assert M <= INT_MAX and N <= INT_MAX and search_buffer <= PTRDIFF_MAX
assert max(map(len, initial_specs + [override_specs])) + 1 <= search_buffer
assert max(len(p) + N + 1 for p in programs + libraries) <= search_buffer
P = search_buffer - 1
# quote_string uses signed-int loop variables and a signed allocation sum.
# At most one escape precedes each input byte. dumps_spec_func concatenates
# at most three quoted values and these three fixed option spellings.
quote_object = 2 * P + 1
dump_prefixes = (" -dumpdir ", " -dumpbase ", " -dumpbase-ext ")
assert sum(map(len, dump_prefixes)) == 36
dump_spec_object = 6 * P + 37
assert quote_object <= INT_MAX and dump_spec_object <= INT_MAX
assert "xmalloc (len + number_of_space + 1)" in gcc
assert "const char *ret = concat (args[0], args[1], args[2], NULL);" in gcc
for prefix in dump_prefixes:
    assert 'concat ("' + prefix + '"' in gcc

# Include actual known Linux fallback strings.  P_tmpdir is /tmp on this
# selected host descriptor.  No TMP or TEMP variable is inherited.
T = max(map(len, (capture["environment"]["TMPDIR"], "/tmp", "/var/tmp", ".")))
tmpdir_object = T + 2
# choose_tmpdir adds one slash, prefix cc is two bytes, six random characters,
# suffix .s two bytes, and one terminating NUL.
assembly_name_object = T + 12
assert T <= 2**32 - 1 - 2
assert assembly_name_object - 1 <= INT_MAX
assert assembly_name_object <= PTRDIFF_MAX

result = {
    "scope": "Selected native GCC initial specs paths and local path/temp arithmetic",
    "retained_run_id": "20261018T063601-938bdebc01d5",
    "configuration_capture_sha256": sha(config_file.read_bytes()),
    "verified_existing_sources": len(sources),
    "initial_specs_search_paths": len(initial_specs),
    "separate_specs_override_paths": 1,
    "reconstructed_program_candidates": len(programs),
    "reconstructed_library_candidates": len(libraries),
    "max_prefix_bytes": M, "max_suffix_bytes": S,
    "max_probe_basename_bytes": N,
    "individual_search_buffer_bytes": search_buffer,
    "individual_spec_quoted_path_bytes": quote_object,
    "individual_dump_spec_result_bytes": dump_spec_object,
    "separate_specs_override_object_bytes": len(override_specs) + 1,
    "max_selected_temp_base_bytes": T,
    "individual_temp_directory_object_bytes": tmpdir_object,
    "individual_assembly_temp_name_bytes": assembly_name_object,
    "no_aggregate_RAM_or_address_span_gate": True,
    "compiler_or_prover_execution": False,
    "source_argument_required": True,
    "complete_driver_or_program_capacity_established": False,
}
expected_file = bundle / "path-checks.json"
if args.capture_configuration:
    with expected_file.open("x") as output:
        output.write(json.dumps(result, indent=2, sort_keys=True) + "\n")
else:
    assert result == json.loads(expected_file.read_text())
print(json.dumps(result, indent=2, sort_keys=True))

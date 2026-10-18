#!/usr/bin/env python3
"""Reconcile retained driver-only evidence and local environment arithmetic."""
import hashlib
import json
from pathlib import Path
import shlex
import tarfile


def digest(data):
    return hashlib.sha256(data).hexdigest()


bundle = Path(__file__).resolve().parent
identity = json.loads((bundle / "identity.json").read_text())
assert digest((bundle / "artifacts.tar.gz").read_bytes()) == identity["archive_sha256"]
retained = {}
with tarfile.open(bundle / "artifacts.tar.gz") as archive:
    assert set(archive.getnames()) == {r["path"] for r in identity["files"]}
    for row in identity["files"]:
        data = archive.extractfile(row["path"]).read()
        assert len(data) == row["bytes"] and digest(data) == row["sha256"]
        retained[row["path"]] = data
result = json.loads(retained["capture/capture/result.json"])
assert result == json.loads((bundle / "capture.json").read_text())
assert all(row["returncode"] == 0 for row in result["commands"])
assert not result["compiler_frontend_or_assembler_executed"]
assert len(result["native_arguments_excluding_driver"]) == 12

manifest = json.loads((bundle / "sources.json").read_text())
source = {}
with tarfile.open(bundle / "sources.tar.gz") as archive:
    assert set(archive.getnames()) == {r["path"] for r in manifest["files"]}
    for row in manifest["files"]:
        data = archive.extractfile(row["path"]).read()
        assert len(data) == row["bytes"] and digest(data) == row["sha256"]
        source[row["path"]] = data.decode()
assert 'getenv (temp = concat (key, "_ROOT", NULL))' in source["gcc/prefix.cc"]
assert 'Component_Name : aliased String := "GCC" & ASCII.NUL;' in source["gcc/ada/osint.adb"]
assert 'Std_Prefix := String_Ptr (Getenv ("GNSA_ROOT"));' in source["gcc/ada/osint.adb"]
assert 'if (access (specs_file, R_OK) == 0)' in source["gcc/gcc.cc"]
assert 'if (vec.is_empty ())\n     return;' in source["gcc/gcc.cc"]

env = result["environment"]
assert set(env) == {"PATH", "LC_ALL", "LANG", "TERM", "TMPDIR",
                    "ADA_INCLUDE_PATH", "ADA_OBJECTS_PATH"}
assert env["LC_ALL"] == env["LANG"] == "C" and env["TERM"] == "dumb"
assert not any(result["default_search_file_exists"].values())
for row in result["installed_defaults"].values():
    for key in ("compiled_prefix", "compiled_path"):
        assert row[key]["bounds"] == [1, len(row[key]["text"])]
    assert row["compiled_path"]["text"].startswith(row["compiled_prefix"]["text"])
assert result["installed_defaults"]["include_dir_default_name"]["relocated"].rstrip("/") == env["ADA_INCLUDE_PATH"]
assert result["installed_defaults"]["object_dir_default_name"]["relocated"].rstrip("/") == env["ADA_OBJECTS_PATH"]

text = retained["capture/capture/driver-expansion.stderr"].decode()
assert text.startswith("Using built-in specs.\n")
assert retained["capture/capture/specs.stdout"] == b"specs\n"
commands = [shlex.split(line) for line in text.split("\n") if line.startswith(" ")]
assert [Path(row[0]).name for row in commands] == ["gnat1", "as"]
assert len(commands[0]) <= 21 and len(commands[1]) == 5
assert not any("-###" in row for row in commands)
assert "-gnatx" in commands[0] and "-Wno-free-nonheap-object" in commands[0]

search = {}
for line in retained["capture/capture/search-dirs.stdout"].decode().split("\n"):
    if ": =" in line:
        name, value = line.split(": =", 1)
        search[name] = value.split(":")
assert {name: len(paths) for name, paths in search.items()} == {"programs": 6, "libraries": 19}
candidate_paths = [p + name for paths in search.values() for p in paths
                   for name in ("gnat1", "as", "specs")]
candidate_paths += list(result["default_search_file_exists"])
candidate_paths += [r["relocated"] for r in result["installed_defaults"].values()]
candidate_paths += [arg for row in commands for arg in row if arg.startswith("/")]
raw_path_max = max(map(len, candidate_paths))
assert raw_path_max == 222  # Captured installation; not a universal path cap.

# Bound the *individual* generated strings, not aggregate memory consumption.
P = raw_path_max
quote_bound = 20 + 21 * (4 * (P + 7) + 3) + 4 * P + 14
env_lengths = {}
for key in ("COMPILER_PATH", "LIBRARY_PATH", "COLLECT_GCC_OPTIONS"):
    values = [line[len(key)+1:] for line in text.split("\n") if line.startswith(key+"=")]
    env_lengths[key] = max(map(len, values))
assert env_lengths["COMPILER_PATH"] + len("COMPILER_PATH=") + 1 <= 14 + 6 * (P + 1)
assert env_lengths["LIBRARY_PATH"] + len("LIBRARY_PATH=") + 1 <= 14 + 19 * (P + 1)
assert env_lengths["COLLECT_GCC_OPTIONS"] + len("COLLECT_GCC_OPTIONS=") + 1 <= quote_bound
summary = {
    "run_id": identity["run_id"], "retained_files": len(retained),
    "pinned_sources": len(source), "environment_entries": len(env),
    "initial_environment_bytes_including_NULs": sum(len(k)+len(v)+2 for k,v in env.items()),
    "gnat1_argv_positions": len(commands[0]), "as_argv_positions": len(commands[1]),
    "search_candidate_counts": {name: len(paths) for name, paths in search.items()},
    "captured_candidate_raw_path_max": P,
    "observed_generated_environment_value_lengths": env_lengths,
    "collect_options_individual_object_bound": quote_bound,
    "source_argument_required": True, "production_launcher_implemented": False,
    "complete_capacity_established": False,
}
expected = json.loads((bundle / "checks.json").read_text()) if (bundle / "checks.json").exists() else None
if expected is not None:
    assert summary == expected
print(json.dumps(summary, indent=2))

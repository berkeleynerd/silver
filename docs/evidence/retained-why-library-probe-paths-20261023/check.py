#!/usr/bin/env python3
"""Check retained provider identities, native witnesses and local arithmetic."""
import json
import pathlib
import re
import tarfile
import time

from elf_reader import Elf, identity

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
ORDER = ["put_line", "put", "first_or_default", "is_message", "input_is_valid"]
EXTENSIONS = ["adb", "gnat-json", "mlw", "sexp", "why"]
BASES = ["int", "real", "algebra", "relations"]
checks = 0
archives = {}


def require(condition, label):
    global checks
    checks += 1
    if not condition:
        raise AssertionError(label)


def read_json(path):
    return json.loads(path.read_text())


def write_json(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def member(archive, name):
    if archive not in archives:
        archives[archive] = tarfile.open(ROOT / archive)
    handle = archives[archive].extractfile(name)
    require(handle is not None, f"regular archive member {name}")
    return handle.read()


def main_fields(text):
    inside = False
    result = {}
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("["):
            inside = line == "[main]"
        elif inside and line and not line.startswith("#"):
            key, value = line.split("=", 1)
            require(key.strip() not in result, "unique retained main field")
            result[key.strip()] = value.strip()
    return result


def string_words(length):
    return 1 + (length + 8)//8


def main():
    start = time.monotonic()
    inputs = read_json(HERE / "inputs.json")
    for path, expected in inputs.items():
        require(identity((ROOT / path).read_bytes()) == expected, path)
    ranges = read_json(HERE / "source-ranges.json")
    witnesses = ["# Raw pathname source witnesses\n"]
    for row in ranges:
        data = member(row["archive"], row["member"])
        require(identity(data) == row["identity"], row["member"])
        lines = data.decode().splitlines(keepends=True)
        witnesses.append(f"## {row['archive']} :: {row['member']}\n")
        for span in row["ranges"]:
            lo, hi = span["start"], span["end"]
            require(1 <= lo <= hi <= len(lines), f"strict source range {row['member']}:{lo}-{hi}")
            text = "".join(lines[lo - 1:hi])
            require(identity(text.encode()) == span["identity"], f"range identity {row['member']}:{lo}-{hi}")
            witnesses.append(f"### Lines {lo}–{hi}\n\n```text\n{text}```\n")
    (HERE / "source-witnesses.md").write_text("\n".join(witnesses))

    native = read_json(HERE / "native-inspection.json")
    binary = pathlib.Path(native["target"]).read_bytes()
    require(identity(binary) == native["target_identity"], "pinned installed ELF")
    elf = Elf(binary)
    for name, row in native["functions"].items():
        require(elf.symbols[name] == {k: row[k] for k in ["address", "bytes", "section_index", "info"]}, f"exact symbol {name}")
        code = elf.function(name)
        require(code.hex() == row["hex"] and identity(code) == row["identity"], f"native code identity {name}")
    for name, row in native["literals"].items():
        require(elf.literal(name) == row, f"static OCaml string block {name}")
    require([native["literals"][f"camlWhy3__Config__{i}"]["value"] for i in [3, 4, 5]] == ["lib", "why3", "share"], "generated Config literals")
    disassembly = (HERE / "native-disassembly.txt").read_text()
    native_lines = 0
    for line in disassembly.splitlines():
        match = re.match(r"\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}\s+)+)", line)
        if match:
            address = int(match[1], 16)
            data = bytes.fromhex(match[2])
            require(elf.at(address, len(data)) == data, f"retained disassembly bytes {address:x}")
            native_lines += 1
    require(native_lines > 2000, "complete native instruction witness coverage")
    for site, target in [(0x5277c4, "camlWhy3__Lexer__entry"), (0x5277e4, "camlWhy3__Sexp_parser__entry")]:
        code = elf.at(site, 5)
        require(code[0] == 0xe8 and site + 5 + int.from_bytes(code[1:], "little", signed=True) == elf.symbols[target]["address"], f"initialized registration {target}")
    require(elf.at(0x543030, 4).hex() == "48894318", "Config stores generated datadir at field3")
    require(elf.at(0x5cb208, 8).hex() == "488b771848897308", "Whyconf imports Config datadir field")
    require(elf.at(0x9a54be, 5)[0] == 0xe9, "Unix dirname wrapper tail call")
    require(native["target_executions"] == 0 and len(native["invocations"]) == 12, "target-free extraction only")

    census = []
    archive = archives[WHY]
    for entry in archive.getmembers():
        if entry.isfile() and entry.name.startswith(("why3/src/", "why3/plugins/")) and entry.name.endswith((".ml", ".mll")):
            text = archive.extractfile(entry).read().decode()
            for i, line in enumerate(text.splitlines(), 1):
                if "register_format" in line:
                    census.append({"member": entry.name, "line": i, "text": line})
    selected = {"why3/src/parser/lexer.mll", "why3/src/parser/sexp_parser.ml", "why3/plugins/ada_terms/ada_main.ml", "why3/plugins/gnat_json/gnat_ast_to_ptree.ml"}
    calls = {r["member"] for r in census if "Env.register_format" in r["text"]}
    require(selected <= calls, "all selected extension registration source bodies")
    require(calls - selected == {"why3/plugins/parser/genequlin.ml", "why3/plugins/parser/dimacs.mll", "why3/plugins/python/py_main.ml", "why3/plugins/microc/mc_main.ml", "why3/plugins/coma/coma_main.ml", "why3/plugins/cfg/cfg_main.ml", "why3/plugins/tptp/tptp_lexer.mll"}, "complete unselected plugin registration census")
    write_json("registration-census.json", census)

    roles = read_json(ROOT / "docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json")
    combined = read_json(ROOT / "docs/evidence/retained-combined-parallel-startup-20261020/projection.json")["domains"]
    providers = {}
    all_dirs = None
    for case in ORDER:
        cap = roles[case]["captures"][1]
        process_name = next(n for n in cap["members_sha256"] if n.endswith("/process.json"))
        data = member(cap["archive"], process_name)
        require(identity(data)["sha256"] == cap["members_sha256"][process_name], f"process identity {case}")
        process = json.loads(data)
        require(process["argv"] == cap["argv"], f"argv provider {case}")
        require(process["executable"] == process["argv"][0] == native["target"], f"resolved executable and absolute fallback argument {case}")
        require(cap["mapped_files"][process["executable"]] == native["target_identity"], f"actual loaded ELF {case}")
        env = process["environment"]
        require(set(env) == {"PATH", "LC_ALL", "TMPDIR", "OCAMLRUNPARAM"}, f"complete controlled environment {case}")
        plugins = {pathlib.PurePosixPath(k).name: v for k, v in cap["mapped_files"].items() if k.endswith(".cmxs")}
        require(set(plugins) == {"gnat_json.cmxs", "ada_terms.cmxs"}, f"complete dynamically mapped plugin set {case}")
        argv = combined[case]["candidate_argv"]
        require(argv[argv.index("--prover") + 1] == "cvc5,z3,altergo" and "--proof-dir" not in argv, f"builtins only/no proof dir {case}")
        configs = {}
        for name in [f"{case}/why3.conf", "overlay/why3.conf"]:
            content = member(cap["archive"], name)
            expected = cap["ordered_opens"][0 if name.startswith(case + "/") else 1]["identity"]
            require(identity(content) == expected, f"actual complete config identity {case}:{name}")
            fields = main_fields(content.decode())
            require(not set(fields) & {"datadir", "loadpath", "stdlib", "plugin", "load_default_plugins"}, f"no main provider override {case}:{name}")
            configs[name] = {"identity": identity(content), "main_fields": fields}
        collector = member(cap["archive"], "collector/probe.py")
        require(b"'executable':str((proc/'exe').resolve())" in collector, f"resolved executable collector {case}")
        require(b"proc = pathlib.Path('/proc') / str(INF.pid)" in collector or b"proc=Path('/proc')/str(INF.pid)" in collector or b"proc = Path('/proc') / str(INF.pid)" in collector, f"collector proc path {case}")
        executable = pathlib.PurePosixPath(process["executable"])
        why_prefix = executable.parent.parent
        spark_prefix = why_prefix.parent.parent
        datadir = why_prefix / "share" / "why3"
        dirs = [str(why_prefix / "share/why3/theories"), str(why_prefix / "share/why3/modules"), str(spark_prefix / "share/spark/theories"), str(datadir / "stdlib")]
        require([len(d) for d in dirs] == [147, 146, 134, 145] and len(set(dirs)) == 4, f"actual directory strings {case}")
        if all_dirs is None:
            all_dirs = dirs
        require(dirs == all_dirs, f"same exact provider across cases {case}")
        providers[case] = {"archive": cap["archive"], "process_member": process_name, "process_identity": identity(data), "collector_identity": identity(collector), "executable": str(executable), "mapped_plugins": plugins, "configs": configs, "Config_datadir": str(datadir), "loadpath_sorted": sorted(dirs)}
    write_json("providers.json", providers)

    per_base = {}
    for base in BASES:
        b = len(base)
        suffixes = [base + "." + ext for ext in EXTENSIONS]
        candidates = [d + "/" + suffix for d in sorted(all_dirs) for suffix in suffixes]
        lengths = [b, b]
        lengths += [len(ext) + 1 for ext in EXTENSIONS] + [len(s) for s in suffixes]
        for d in all_dirs:
            for suffix in suffixes:
                lengths += [1 + len(suffix), len(d) + 1 + len(suffix)]
        require(len(candidates) == 20 and len(set(candidates)) == 20, f"complete candidates {base}")
        require(len(lengths) == 52 and max(lengths) == max(map(len, candidates)) <= 167, f"all intermediate strings {base}")
        require(all(s.isascii() and "\0" not in s for s in candidates), f"C-safe candidates {base}")
        words = sum(map(string_words, lengths))
        cells = 5 + 5 + 4 + 4 + 20 + 20 + 40
        fixed_closures = 4 + 4 + 4*5 + 9 + 10
        total_words = words + 3*cells + fixed_closures + 4
        require(cells == 98 and fixed_closures == 47 and total_words <= 870, f"local managed accounting {base}")
        require(max(lengths) < 2**62 - 1 and string_words(max(lengths)) <= 22 and max(lengths) + 1 <= 168, f"representation operands {base}")
        per_base[base] = {"candidates": candidates, "candidate_count": 20, "maximum_path_bytes": max(map(len, candidates)), "all_string_allocation_lengths": lengths, "string_blocks_upper": 52, "summed_string_payload_bytes": sum(lengths), "summed_string_allocation_words": words, "new_cons_cells_upper": cells, "closure_words_upper": fixed_closures, "exception_record_words_upper": 4, "managed_words_per_invocation_upper": total_words, "C_copy_bytes_per_invocation_upper": sum(len(s) + 1 for s in candidates), "C_copy_single_request_upper": max(map(len, candidates)) + 1}
    write_json("projection.json", {"scope": "one selected Env.locate_library invocation, including failed prefixes", "extensions": EXTENSIONS, "loadpath_sorted": sorted(all_dirs), "logical_bases": BASES, "per_base": per_base, "P_stat": 167, "loadpath_cardinality": 4, "registered_extension_cardinality": 5, "candidate_count_upper": 20, "managed_words_per_invocation_upper": 870, "C_copy_single_request_upper": 168, "C_copy_bytes_per_invocation_upper": 3188, "representation_guards_established": True, "global_locate_call_count": None, "whole_process_capacity_established": False, "FileTags_counter_or_table_capacity_established": False, "diagnostic_path_theorem_changed": False, "global_e_upper": 2, "save_entering_callbacks_upper": 2, "saves_upper": 3, "admission_changed": False})
    result = {"status": "PASS", "checks": checks, "elapsed_seconds": round(time.monotonic() - start, 6), "provider_files": len(inputs), "source_members": len(ranges), "strict_source_ranges": sum(len(r["ranges"]) for r in ranges), "native_functions": len(native["functions"]), "native_instruction_lines_checked": native_lines, "actual_cases": 5, "target_or_predecessor_executions": 0, "disassembler_invocations_in_this_check": 0}
    write_json("result.json", result)
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    finally:
        for archive in archives.values():
            archive.close()

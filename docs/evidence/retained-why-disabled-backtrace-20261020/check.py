#!/usr/bin/env python3
"""Check retained inputs and arithmetic; the source/control argument is reviewed prose.

Reads retained archives, metadata, disassembly and ELF bytes. Never executes the
target, a disassembler, a predecessor checker, a solver or a proof tool.
"""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent
inputs = {}


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def read(path):
    path = Path(path)
    raw = path.read_bytes()
    key = str(path.relative_to(REPO)) if path.is_relative_to(REPO) else str(path)
    inputs[key] = identity(raw)
    return raw


def js(path):
    return json.loads(read(path))


def write(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


archives = {
    "why": E / "retained-why-session-helper-source-20261019/sources.tar.gz",
    "ocaml": E / "retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz",
}
archive_hashes = {
    "why": "2dd835cb251c82766ba7808f4cb2d384f91e0101468fd22d5810919072863749",
    "ocaml": "04686c5bc81d09e89d2885326924206b028f05e9518f45fd5d56113ce36db7a7",
}
sources = {}
for key, path in archives.items():
    assert identity(read(path))["sha256"] == archive_hashes[key]
    with tarfile.open(path) as tar:
        sources[key] = {m.name: tar.extractfile(m).read()
                        for m in tar.getmembers() if m.isfile()}
OC = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
why = {n: raw for n, raw in sources["why"].items() if n.startswith("why3/")}
assert len(why) == 603

# Explicit scope; lexical inventories are not a reachability proof.
scan_sets = {"why": why, "ocaml": {
    n: raw for n, raw in sources["ocaml"].items()
    if n.startswith(tuple(OC + x for x in ["runtime/", "stdlib/", "otherlibs/", "utils/"]))}}
package_inputs = js(E / "retained-why-sexplib-converter-prefix-20261019/inputs.json")
for package in ["sexplib", "sexplib0", "parsexp"]:
    path = E / f"retained-why-sexplib-converter-prefix-20261019/{package}.tar.gz"
    assert identity(read(path)) == package_inputs["local_inputs"][package + ".tar.gz"]
    with tarfile.open(path) as tar:
        scan_sets[package] = {m.name: tar.extractfile(m).read()
                             for m in tar.getmembers() if m.isfile()}
patterns = {
    "all_printexc_identifier_lines": r"\bPrintexc\b",
    "recording_api": r"\brecord_backtraces?\b|\bcaml_record_backtraces?\b",
    "active_field": r"\bbacktrace_active\b|\bcaml_backtrace_active\b",
    "printexc_alias_or_local_open": r"\b(?:open|include)\s+Printexc\b|\bmodule\s+\w+\s*=\s*Printexc\b|Printexc\.\(",
    "diagnostic_and_callstack_clients": r"\b(?:raw_backtrace_to_string|print_raw_backtrace|print_backtrace|get_backtrace|get_callstack)\b",
}
inventory = {}
for group, members in scan_sets.items():
    eligible = {n: raw.decode() for n, raw in members.items()
                if n.endswith((".ml", ".mli", ".mll", ".mly", ".c", ".h", ".S"))}
    inventory[group] = {"members": len(eligible), "matches": {
        key: [{"member": n, "line": i, "text": line}
              for n, source in sorted(eligible.items())
              for i, line in enumerate(source.splitlines(), 1) if re.search(pattern, line)]
        for key, pattern in patterns.items()}}
assert [(x["member"], x["line"]) for x in inventory["why"]["matches"]["recording_api"]] == [
    ("why3/src/gnat/gnat_config.ml", 231), ("why3/src/gnat/gnat_config.ml", 238),
    ("why3/src/trywhy3/why3_worker.ml", 50), ("why3/src/util/debug.ml", 143)]
assert not any(re.search(r"\b(?:open|include)\s+Printexc\b|\bmodule\s+\w+\s*=\s*Printexc\b",
                        raw.decode()) for raw in why.values())
for key in ["sexplib", "sexplib0", "parsexp"]:
    assert not inventory[key]["matches"]["recording_api"]
    assert not inventory[key]["matches"]["printexc_alias_or_local_open"]
write("source-client-inventory.json", inventory)

RANGES = {
    "why": {
        "why3/src/gnat/gnat_config.ml": [(214,244)],
        "why3/src/util/debug.ml": [(117,144)],
        "why3/src/trywhy3/why3_worker.ml": [(42,54)],
        "why3/src/gnat/gnat_util.ml": [(1,24)],
        "why3/src/mlw/pinterp.ml": [(35,51)],
    },
    "ocaml": {
        OC + "runtime/domain.c": [(72,82)],
        OC + "runtime/startup_nat.c": [(106,124)],
        OC + "runtime/startup_aux.c": [(103,125)],
        OC + "runtime/backtrace.c": [(32,63),(155,211),(260,299)],
        OC + "runtime/backtrace_nat.c": [(293,301)],
        OC + "runtime/printexc.c": [(103,135)],
        OC + "runtime/alloc.c": [(35,60),(78,95)],
        OC + "runtime/str.c": [(71,79)],
        OC + "otherlibs/systhreads/st_stubs.c": [(187,221),(677,687)],
        OC + "otherlibs/systhreads/thread.ml": [(46,73)],
        OC + "stdlib/printexc.ml": [(95,104),(126,188),(263,275),(307,365)],
        OC + "stdlib/buffer.ml": [(16,38)],
        OC + "stdlib/bytes.ml": [(24,39),(64,74)],
        OC + "stdlib/printf.ml": [(16,32)],
        OC + "stdlib/camlinternalFormat.ml": [(120,140),(1510,1523),(1559,1566),(1604,1605),(1897,1914)],
        OC + "stdlib/camlinternalFormatBasics.ml": [(402,412)],
    },
}
witnesses = []
for key, ranges_by_member in RANGES.items():
    for member, ranges in ranges_by_member.items():
        raw = sources[key][member]
        lines = raw.decode().splitlines(keepends=True)
        for lo, hi in ranges:
            assert 1 <= lo <= hi <= len(lines), (member, lo, hi, len(lines))
            witnesses.append(dict(archive=str(archives[key].relative_to(REPO)), member=member,
                member_identity=identity(raw), first_line=lo, last_line=hi,
                text="".join(lines[lo-1:hi])))
write("source-witnesses.json", witnesses)

# Reuse accepted first-use/prefix attachment without replaying its checker.
debug_attachment = js(E / "retained-why-debug-formatter-control-20261020/input-attachment.json")
prefix = js(E / "retained-why-path-initial-state-20261020/prefix-attachment.json")
for path in ["retained-why-debug-formatter-control-20261020/result.json",
             "retained-why-path-initial-state-20261020/result.json",
             "retained-why-save-stack-helper-closure-20261020/result.json"]:
    read(E / path)
for name in ["retained-why-debug-formatter-control.md", "retained-why-path-initial-state.md",
             "retained-why-save-stack-helper-closure.md", "retained-why-save-owned-stack-join.md",
             "retained-why-save-exit-charge.md", "retained-tool-source-identity.md"]:
    read(REPO / "docs/research" / name)
attached = []
for d, p in zip(debug_attachment, prefix, strict=True):
    assert (d["case"], d["pid"], d["argv"], d["environment"]) == (
        p["case"], p["pid"], p["argv"], p["environment"])
    assert p["initial_threads"] == 1 and not p["new_threads"]
    assert p["same_images_as_native_initialization_argument"]
    assert p["environment"]["OCAMLRUNPARAM"] == "s=256M,h=16M,M=1000"
    assert not any(x.startswith("--debug") for x in p["argv"])
    assert "WHY3DEBUG" not in p["environment"]
    attached.append({k: p[k] for k in ["case","pid","argv","environment","cut_symbol",
        "cut_elf_relative_pc","initial_threads","new_threads","mapped_image_count"]})
assert [(p["case"],p["pid"]) for p in attached] == [
    ("put_line",17310),("put",17514),("first_or_default",17631),
    ("is_message",17704),("input_is_valid",17869)]
write("input-attachment.json", attached)

DIS = Path("/tmp/silver-why-callback-closure-disassembly-20261018.txt")
ELF = Path("/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3")
raw = read(DIS)
assert identity(raw)["sha256"] == "f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5"
bodies = {m[1]: m[0] for m in re.finditer(r"^\w+ <([^>]+)>:\n.*?(?=^\w+ <|^Disassembly of section |\Z)",raw.decode(),re.M|re.S)}
elf = read(ELF)
assert identity(elf)["sha256"] == "7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368"
h = struct.unpack_from("<16sHHIQQQIHHHHHH",elf)
segments = [struct.unpack_from("<IIQQQQQQ",elf,h[5]+i*h[9]) for i in range(h[10])]


def at(addr, size):
    s = next(s for s in segments if s[0] == 1 and s[3] <= addr and addr+size <= s[3]+s[5])
    return elf[s[2]+addr-s[3]:s[2]+addr-s[3]+size]


def word(addr):
    return struct.unpack("<Q",at(addr,8))[0]


# Own frame bytes include the incoming return slot and any local OCaml trap.
# These are inspected maxima for the selected arms, not a generic stack parser.
FRAMES = {
    "camlStdlib__Printexc__convert_raw_backtrace_482": (32,1),
    "camlStdlib__Printexc__print_exception_backtrace_493": (48,1),
    "camlStdlib__Printexc__print_raw_backtrace_547": (16,1),
    "camlStdlib__Printexc__print_backtrace_551": (16,1),
    "camlStdlib__Printexc__backtrace_to_string_554": (48,1),
    "camlStdlib__Printexc__raw_backtrace_to_string_643": (16,1),
    "camlStdlib__Printexc__get_backtrace_692": (16,1),
    "camlStdlib__Printexc__try_get_raw_backtrace_727": (32,1),
    "caml_get_exception_raw_backtrace": (128,1),
    "caml_convert_raw_backtrace": (224,1),
    "caml_debug_info_available": (8,1),
    "caml_alloc": (48,1),
    "camlStdlib__Buffer__create_272": (16,1),
    "camlStdlib__Bytes__sub_302": (32,1),
    "caml_create_bytes": (8,1),
    "caml_alloc_string": (32,1),
    "caml_blit_bytes": (16,1),
    "camlStdlib__Printf__fprintf_422": (8,1),
    "camlStdlib__Printf__kfprintf_319": (16,1),
    "camlStdlib__Printf__fun_480": (16,1),
    "camlStdlib__Printf__fun_497": (8,1),
    "camlCamlinternalFormat__make_printf_3510": (48,1),
    "camlCamlinternalFormat__output_acc_4363": (32,2),
    "camlStdlib__output_string_250": (16,1),
}
CONTROL = ["caml_init_domain","caml_startup_common","caml_parse_ocamlrunparam",
    "caml_record_backtraces","caml_record_backtrace","caml_restore_raw_backtrace",
    "caml_backtrace_status","caml_debug_info_status","caml_fatal_uncaught_exception",
    "camlGnat_config__fun_13685","camlGnat_config__fun_13687",
    "camlWhy3__Debug__set_flags_selected_inner_3027","camlStdlib__Printexc__fun_832",
    "camlStdlib__Printexc__handle_uncaught_exception$27_730"]
NATIVE = list(FRAMES) + CONTROL
checked = 0
for name in NATIVE:
    for line in bodies[name].splitlines()[1:]:
        m = re.match(r"\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)",line)
        if not m:
            assert not line.strip(), line
            continue
        bs = bytes.fromhex(m[2])
        assert at(int(m[1],16),len(bs)) == bs
        checked += len(bs)
write("native-bodies.json", {n:bodies[n] for n in NATIVE})
for name, (frame, _) in FRAMES.items():
    body = bodies[name]
    reservations = re.findall(r"\bsub\s+\$0x([0-9a-f]+),%rsp",body)
    assert len(reservations) <= 1, name
    pushes = len(re.findall(r"\bpush\s",body))
    if name == "caml_create_bytes":
        # The sole push is after the valid-size tail transfer; its failure
        # branch is excluded by the separately checked 0/1024-byte arguments.
        assert pushes == 1 and body.index("jmp    9c8ae0") < body.index("push")
        pushes = 0
    assert frame == 8 + sum(int(x,16) for x in reservations) + 8*pushes, name
write("native-frames.json", {n:dict(own_frame_bytes=f,instances=m) for n,(f,m) in FRAMES.items()})

# Actual direct/first-class native symbol references complement typed source ownership.
refs = [{"body":n,"line":line} for n,b in bodies.items() for line in b.splitlines()[1:]
        if re.search(r"<(?:caml_record_backtrace|caml_record_backtraces)>",line)]
assert {x["body"] for x in refs} == {
    "camlGnat_config__fun_13685","camlGnat_config__fun_13687",
    "camlWhy3__Debug__set_flags_selected_inner_3027","camlStdlib__Printexc__fun_832",
    "caml_parse_ocamlrunparam"}
assert "0xe8(%rax)" in bodies["caml_get_exception_raw_backtrace"]
assert "9dd7cb:" in bodies["caml_get_exception_raw_backtrace"]
assert "mov    $0x1,%eax" in bodies["caml_debug_info_available"]
assert "mov    $0x1,%eax" in bodies["caml_debug_info_status"]
write("native-control.json", {"recording_symbol_references":refs,
    "active_field_offset":"0xe8", "init_zero_store":"0x9e36bd",
    "getter_inactive_branch":"0x9dd7af -> 0x9dd7c7",
    "getter_zero_allocation_call":"0x9dd7cb", "native_debug_info_available":1,
    "not_a_generic_binary_alias_or_write_proof":True})

# Decode the precise fallback format object and its selected switch branches.
literal = b"(Program not linked with -g, cannot print stack backtrace)\n"
assert len(literal) == 59
fmt_addr, node_addr, str_addr = 0xf80c30, 0xf80c48, 0xf80c60
assert word(fmt_addr-8) >> 10 == 2
assert word(fmt_addr) == node_addr and word(fmt_addr+8) == str_addr
assert (word(node_addr-8) & 255, word(node_addr-8) >> 10) == (11,2)
assert word(node_addr) == str_addr and word(node_addr+8) == 1
assert word(str_addr-8) & 255 == 252
storage = (word(str_addr-8) >> 10)*8
length = storage-1-at(str_addr+storage-1,1)[0]
assert length == 59 and at(str_addr,length) == literal
make_target = 0x9ef1a4+struct.unpack("<i",at(0x9ef1a4+4*11,4))[0]
output_target = 0x9ef2a8+struct.unpack("<i",at(0x9ef2a8+4*2,4))[0]
assert (make_target,output_target) == (0x96f7c8,0x972ec8)
assert word(0xf7d070) == 0x97a7d0  # selected ignore continuation
assert "sub    $0x18,%r15" in bodies["camlCamlinternalFormat__make_printf_3510"]
assert "sub    $0x28,%r15" in bodies["camlStdlib__Printf__kfprintf_319"]
write("fallback-layout.json",dict(format_address=hex(fmt_addr),node_address=hex(node_addr),
    node_tag=11,node_fields=[hex(str_addr),1],literal_address=hex(str_addr),
    literal=literal.decode(),literal_bytes=59,storage_bytes=storage,
    make_printf_selected_arm=hex(make_target),output_acc_selected_arm=hex(output_target),
    output_acc_tag=2,ignore_closure="0xf7d070",ignore_code="0x97a7d0"))

def string_request(n):
    return 8+8*((n+8)//8)

direct_string = 16+40+string_request(1024)+string_request(0)
direct_print = 16+40+24
frame_sum = sum(f*m for f,m in FRAMES.values())
assert direct_string == 1112 and direct_print == 80
write("result.json",dict(
    kind="Conditional selected source/control result and per-call resource interface",
    cases=[p["case"] for p in attached],inactive_at_cuts_and_selected_suffix_under_named_relation=True,
    raw_input_origin="get_exception_raw_backtrace or the standard empty-backtrace constant",
    arbitrary_raw_backtrace_inputs_covered=False,returned_string_lengths=[0,59],
    print_direct_requested_bytes_upper=59,print_direct_channel_calls_upper=1,
    raw_string_direct_object_request_bytes_upper=direct_string,
    raw_print_direct_object_request_bytes_upper=direct_print,
    empty_raw_getter_direct_object_request_bytes=0,
    conservative_native_own_frame_projection_bytes=frame_sum,
    imported_direct_bridge_high_water_bytes=4104,
    per_active_diagnostic_native_projection_with_bridge_bytes=frame_sum+4104,
    direct_dynamic_buffer_capacity=1024,private_buffer_mutated_after_create=False,
    native_bodies=len(NATIVE),native_instruction_bytes_checked=checked,
    source_witnesses=len(witnesses),why_source_members=603,
    service_frontier=["caml_call_gc and caml_alloc_small_dispatch interiors",
        "caml_raise_exn, stack/failure handling", "caml_ml_output channel/locking/OS interiors",
        "memmove@plt zero-length call", "service-owned nested crossings and classified pending clients"],
    asynchronous_Failure_fallback_included=True,global_postcut_signals_upper=2,
    global_postcut_saves_upper=3,whole_suffix_report_count=None,
    cumulative_requests_not_physical_memory=True,ambient_A_pre_separate=True,
    R_separate=True,complete_exit_capacity=False,complete_save_capacity=False,
    complete_process_stack=False,semantic_theorem_proved_by_checker=False,
    target_runs=0,new_captures=0,new_disassembly=0,source_fetches=0,predecessor_replays=0))
read(__file__)
write("inputs.json",inputs)
print(json.dumps(dict(ok=True,native_bodies=len(NATIVE),native_instruction_bytes_checked=checked,
    source_witnesses=len(witnesses),string_request_bytes=direct_string,
    print_request_bytes=direct_print,native_own_frames=frame_sum,
    native_projection_with_bridge=frame_sum+4104,complete_exit_capacity=False),sort_keys=True))

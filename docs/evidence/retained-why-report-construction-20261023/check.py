#!/usr/bin/env python3
"""Focused retained-source/identity/arithmetic check; no native or model run."""
from pathlib import Path
import hashlib
import json
import re
import tarfile
import time

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
START = time.monotonic()
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
CP = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
CANON = "docs/evidence/retained-why-canonical-json-input-20261023/result.json"
WARN = "docs/evidence/retained-why-diagnostic-warnings-20261023/bounds.json"
DIRECTIVES = "docs/evidence/retained-adapter-outcome-interface-20261020/loaded-response-directives.json"
TERMINAL = "docs/evidence/retained-why-terminal-diagnostic-bytes-20261023/source-witnesses.json"
PATH_PROVIDER = "docs/evidence/retained-why-report-construction-20261023/path-provider.json"


def ident(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read(path):
    return json.loads((ROOT / path).read_bytes())


def write(name, obj):
    (OUT / name).write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n")


def archive(path):
    with tarfile.open(ROOT / path) as tf:
        return {m.name: tf.extractfile(m).read() for m in tf.getmembers() if m.isfile()}


sources = {WHY: archive(WHY), OCAML: archive(OCAML)}
providers = [
    CANON, WARN, DIRECTIVES, TERMINAL, PATH_PROVIDER,
    "docs/evidence/retained-adapter-outcome-interface-20261020/canonical-table.json",
    "docs/evidence/retained-why-diagnostic-warnings-20261023/warning-census.json",
    "docs/research/retained-why-canonical-json-input.md",
    "docs/research/retained-why-diagnostic-warnings.md",
    "docs/research/retained-why-standard-json-inputs.md",
    "docs/research/retained-why-format-accumulator.md",
    "docs/research/retained-why-json-byte-escape.md",
    "docs/research/retained-why-exit-timing-format.md",
    "docs/research/retained-why-terminal-diagnostic-bytes.md",
    "docs/research/retained-why-save-hashtbl-prefix.md",
    "docs/research/retained-why-save-table-contract-join.md",
    "docs/research/retained-tool-source-identity.md",
]
write("inputs.json", {p: ident((ROOT / p).read_bytes()) for p in [WHY, OCAML] + providers})

spans = {
    WHY: {
        "why3/src/gnat/gnat_report.ml": [(4,86), (127,234)],
        "why3/src/gnat/gnat_checks.ml": [(235,261), (769,861), (938,979)],
        "why3/src/gnat/gnat_main.ml": [(213,279)],
        "why3/src/gnat/gnat_expl.ml": [(646,660)],
        "why3/src/gnat/gnat_config.ml": [(577,625)],
        "why3/src/util/json_base.ml": [(13,104)],
        "why3/src/util/loc.ml": [(67,86), (187,195), (252,277)],
        "why3/src/util/pp.ml": [(29,40), (117,121), (208,208)],
        "why3/src/driver/call_provers.ml": [(150,158), (279,307), (342,402)],
        "why3/src/driver/driver.ml": [(108,132), (264,270)],
        "why3/src/core/theory.ml": [(880,896)],
        "why3/src/core/dterm.ml": [(589,594)],
        "why3/src/mlw/dexpr.ml": [(1398,1406), (1631,1638)],
        "why3/src/session/session_itp.ml": [(849,860)],
    },
    OCAML: {
        CP+"stdlib/format.ml": [(205,225), (248,288), (294,340), (387,440),
            (460,535), (592,618), (782,814), (936,977), (1005,1014), (1030,1034),
            (1249,1256), (1280,1393)],
        CP+"stdlib/camlinternalFormat.ml": [(1786,1886), (1968,2015)],
        CP+"stdlib/buffer.ml": [(31,43), (77,100), (164,170)],
        CP+"stdlib/hashtbl.ml": [(68,76), (354,362), (477,484)],
        CP+"stdlib/list.ml": [(320,389)],
    },
}
witnesses = []
for ar, members in spans.items():
    for name, ranges in members.items():
        data = sources[ar][name]
        lines = data.decode().splitlines()
        for first, last in ranges:
            assert 1 <= first <= last <= len(lines), (name, first, last, len(lines))
            witnesses.append({"archive": ar, "member": name, "first": first,
                              "last": last, "member_identity": ident(data),
                              "text": "\n".join(lines[first-1:last]) + "\n"})
# Retain correspondence of the imported terminal formatter interface too.
for row in read(TERMINAL):
    ar, name = row["archive"], row["member"]
    if ar not in sources:
        sources[ar] = archive(ar)
    data = sources[ar][name]
    lines = data.decode().splitlines()
    a, b = row["start"], row["end"]
    assert 1 <= a <= b <= len(lines)
    assert "\n".join(lines[a-1:b]) + "\n" == row["text"]
    assert ident(data)["sha256"] == row["member_sha256"]
write("source-witnesses.json", witnesses)

# A conservative literal census, not a semantic reachability proof: all candidates
# in complete files containing a reviewed warning reference, plus reporting and
# terminal witness regions. Disabled warning callbacks are not invoked.
texts = [(w["member"], w["first"], w["text"]) for w in witnesses if w["archive"] == WHY]
texts += [(w["member"], w["start"], w["text"]) for w in read(TERMINAL)]
warning_members = sorted({w["member"] for w in read(
    "docs/evidence/retained-why-diagnostic-warnings-20261023/warning-census.json")["references"]
    if w["member"].endswith((".ml", ".mly", ".mll"))})
for name in warning_members:
    texts.append((name, 1, sources[WHY][name].decode()))
tokens = []
for name, first, txt in texts:
    # Start at EVERY quote, including quotes inside char syntax/comments. An
    # earlier false candidate cannot swallow the start of a real literal.
    for m in re.finditer(r'(?=("(?:[^"\\]|\\[\s\S])*"))', txt):
        tokens.append({"member": name, "line": first+txt[:m.start()].count("\n"),
                       "source_bytes": len(m.group(1).encode()), "candidate": m.group(1)})
largest = max(tokens, key=lambda t:t["source_bytes"])
fmt_nodes = 4*(largest["source_bytes"]+1)
assert fmt_nodes < 1 << 20
write("format-census.json", {"scope": "overlapping quote-start candidates contain all selected double-quoted literals; char/comment false candidates are deliberate; semantic selection is in the note",
      "warning_members": warning_members, "candidate_count": len(tokens),
      "largest": largest, "fixed_format_nodes_upper": fmt_nodes})

directives = read(DIRECTIVES)
assert set(directives) == {"cvc5_gnatprove.drv", "z3_gnatprove.drv", "alt_ergo_gnatprove_smt2.drv"}
assert all("step" not in r["directive"].lower() or r["directive"] == "steplimitexceeded"
           for rows in directives.values() for r in rows)
steps = []
for c in [-1,0,1]:
    for add, mult in [(15000,35),(450000,800),(0,1),(2000,1)]:
        result = max(0,c-add)//mult+1
        assert -(1<<62) <= c-add <= (1<<62)-1 and 1 <= result <= 2
        steps.append({"c": c, "add": add, "mult": mult, "result": result})

warn = {x["case"]: x for x in read(WARN)["cases"]}
cases = []
for c in read(CANON)["cases"]:
    R,G,A,N,O = [c[k] for k in ["R","G","A","N","O"]]
    wo = warn[c["case"]]["W_o"]
    W = wo+O+N+1
    S,K = 5*R,26
    C = 4+6*R+S+3*G+A
    V = C+9*R+3*S+3*A+K+W+1
    F = 4+14*R+4*S+2*G+4*A+K
    assert R <= 22 < 2*32 and 5 < 2*16
    assert max(W,V,F,G,A,fmt_nodes) < (1<<62)-1
    cases.append({"case": c["case"], "R":R,"G":G,"A":A,"N":N,"O":O,
        "W":W,"S":S,"K":K,"C":C,"V":V,"F":F,
        "msg_bucket_capacity":32,"stats_bucket_capacity":16,
        "stats_count_upper":G,"stats_steps_domain":[-1,0,1],
        "reported_converted_steps_domain":[1,2],"per_answer_bytes_upper":368,
        "per_Loc_warning_bytes_upper":1024,"per_Loc_warning_events_upper":128,
        "representation_guards_pass":True})

# Private default-margin caller instances; Loc has the separate proof below.
private = []
for name,B,E,initial,capacity in [("answer",368,32,512,512),
       ("located_warning",436,32,512,512),("abort_annotation",6,2,16,16),
       ("annotation_error",46,0,256,256)]:
    assert B+E+79 <= 1000000010 and max(initial,capacity) < 1<<57
    private.append({"owner":name,"B":B,"E":E,"initial_buffer":initial,
                    "buffer_capacity_upper":capacity,"default_margin_guard":True})
loc = {"margin":1000000000,"max_indent":68,"segment_input_bytes_upper":1024,
       "events_upper":128,"left_before_flush":1,"sentinel":1000000010,
       "initial_pending_minus_margin":1000000010-1-1000000000,
       "no_user_box_segment_unresolved_breaks_upper":1,
       "initial_buffer":100,"buffer_capacity_upper":1600}
assert loc["initial_pending_minus_margin"] == 9
assert 1024 < loc["margin"] and 1600 >= 1024
layout=[]
for n in [0,1,4,6,16,20,46,100,256,317,368,436,512,1024,1600,26619]:
    w=(n+8)//8
    assert 1 <= w <= (1<<54)-1 and 0 <= 8*w-1-n <= 7
    layout.append({"bytes":n,"payload_words":w,"header_and_payload_bytes":8*(w+1)})
write("bounds.json", {"cases":cases,"private_default_margin":private,
      "Loc_margin_specialization":loc,"steps_conversions":steps,"string_layouts":layout,
      "fixed_object_payload_words_upper":128,"shared_e":2,
      "save_entering_callbacks":2,"saves":3,
      "located_warning_source":{"provider_commit":read(PATH_PROVIDER)["commit"],
          "filename_bytes_upper":180,"nonfilename_bytes_upper":256,
          "total_bytes_upper":436,"FileTags_counter_and_storage_owners_closed":False},
      "aggregate_RAM_or_stack_quota":False,"production_refinement_established":False})
write("check-result.json", {"status":"pass","source_spans":len(witnesses),
      "imported_terminal_spans":len(read(TERMINAL)),"cases":len(cases),
      "elapsed_seconds":time.monotonic()-START,
      "claims":"identities, strict source spans, literal census and displayed arithmetic; source proof remains reviewable prose",
      "native_runs":0,"solver_runs":0,"model_runs":0,"source_fetches":0})
print(json.dumps(read(str(OUT.relative_to(ROOT)/"check-result.json")), sort_keys=True))

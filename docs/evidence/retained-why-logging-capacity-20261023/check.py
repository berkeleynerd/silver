#!/usr/bin/env python3
"""One focused retained-source/name-origin/logging arithmetic check."""
from pathlib import Path
import hashlib
import json
import re
import tarfile
import time

START = time.monotonic()
ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
CP = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"
CANON = "docs/evidence/retained-why-canonical-json-input-20261023/result.json"
PREFIX = "docs/evidence/retained-parallel-logging-prefix-20261020/cut-projection.json"
PATHS = "docs/evidence/retained-why-report-path-inputs-20261023/projection.json"


def ident(data):
    return {"bytes":len(data), "sha256":hashlib.sha256(data).hexdigest()}


def read(path):
    return json.loads((ROOT/path).read_bytes())


def write(name, value):
    (OUT/name).write_text(json.dumps(value,indent=2,sort_keys=True)+"\n")


def archive(path):
    with tarfile.open(ROOT/path) as tf:
        return {m.name:tf.extractfile(m).read() for m in tf.getmembers() if m.isfile()}


sources = {WHY:archive(WHY), OCAML:archive(OCAML)}
providers = [CANON,PREFIX,PATHS,
    "docs/research/retained-parallel-logging-prefix.md",
    "docs/research/retained-combined-parallel-startup.md",
    "docs/research/retained-why-canonical-json-input.md",
    "docs/research/retained-why-callback-demand.md",
    "docs/evidence/retained-why-callback-demand-20261023/result.json",
    "docs/research/retained-why-save-attempt-growth.md",
    "docs/research/retained-why-report-construction.md",
    "docs/research/retained-why-format-accumulator.md",
    "docs/research/retained-why-json-byte-escape.md",
    "docs/research/retained-why-exit-timing-format.md",
    "docs/research/retained-why-standard-channel-capacity.md",
    "docs/research/retained-why-save-service-contract.md",
    "docs/research/retained-why-channel-exit-bound.md",
    "docs/research/retained-why-report-path-inputs.md",
    "docs/research/retained-why-reporting-composition.md",
    "docs/research/retained-tool-source-identity.md",
    "docs/evidence/retained-parallel-logging-prefix-20261020/installed-byte-witnesses.json",
    "docs/reviews/review-report-path-construction-20261023.md",
]
inputs = {p:ident((ROOT/p).read_bytes()) for p in [WHY,OCAML]+providers}
spans = {
    WHY:{
        "why3/src/gnat/gnat_checks.ml":[(26,113),(235,261),(380,415),(985,1032),(1049,1084)],
        "why3/src/gnat/gnat_main.ml":[(95,124),(298,309),(323,360)],
        "why3/src/gnat/gnat_scheduler.ml":[(1,28)],
        "why3/src/session/controller_itp.ml":[(412,440),(448,491),(517,577),(592,652)],
        "why3/src/session/session_itp.ml":[(20,58),(645,675),(887,899)],
        "why3/src/driver/call_provers.ml":[(478,498),(541,560)],
        "why3/src/util/json_base.ml":[(13,32),(74,103)],
    },
    OCAML:{
        CP+"stdlib/format.ml":[(205,225),(248,264),(325,340),(430,455),
            (936,977),(1000,1007),(1280,1311),(1354,1367)],
        CP+"stdlib/queue.ml":[(19,54),(71,94),(126,134)],
        CP+"stdlib/stdlib.ml":[(330,356),(358,386)],
        CP+"runtime/io.c":[(94,123),(185,218),(234,263),(505,561),(714,739)],
        CP+"runtime/unix.c":[(88,109)],
        CP+"runtime/caml/io.h":[(26,49)],
        CP+"otherlibs/unix/gettimeofday.c":[(23,33)],
    },
}
witnesses=[]
for ar,members in spans.items():
    for name,ranges in members.items():
        data=sources[ar][name]; lines=data.decode().splitlines()
        for a,b in ranges:
            assert 1<=a<=b<=len(lines),(name,a,b,len(lines))
            witnesses.append({"archive":ar,"member":name,"member_identity":ident(data),
                "first":a,"last":b,"text":"\n".join(lines[a-1:b])+"\n"})
write("source-witnesses.json",witnesses)

census={"logging_calls":[],"prover_field_writers":[],"controller_interrupt_clients":[],"logging_module_aliases":[]}
for name,data in sources[WHY].items():
    if not name.endswith((".ml",".mli",".mly",".mll")):continue
    for i,line in enumerate(data.decode().splitlines(),1):
        entry={"member":name,"line":i,"text":line}
        if re.search(r'\bLogging\.(init|log)\b',line):census["logging_calls"].append(entry)
        if re.search(r'\.prover\s*<-',line):census["prover_field_writers"].append(entry)
        if re.search(r'\b(?:C|Controller_itp)\.interrupt\s',line):census["controller_interrupt_clients"].append(entry)
        if re.search(r'\bmodule\s+\w+\s*=\s*(?:Gnat_checks\.)?Logging\b',line):census["logging_module_aliases"].append(entry)
assert [(x['member'],x['line']) for x in census['logging_calls']] == [
    ('why3/src/gnat/gnat_checks.ml',415),('why3/src/gnat/gnat_checks.ml',1064)]
assert [(x['member'],x['line']) for x in census['prover_field_writers']] == [('why3/src/session/session_itp.ml',893)]
assert all(x['member']=='why3/src/session/itp_server.ml' for x in census['controller_interrupt_clients'])
assert not census['logging_module_aliases']
write("writer-census.json",census)

# Retained configuration bytes, not a new process capture or config execution.
names=[]
prefix=read(PREFIX)
for case,row in read(PATHS)['domains'].items():
    ar=row['capture_archive']; member=f'{case}/why3.conf'
    inputs[ar]=ident((ROOT/ar).read_bytes())
    with tarfile.open(ROOT/ar) as tf:data=tf.extractfile(member).read()
    conf=data.decode()
    records=[]
    for block in re.split(r'(?m)^\[prover\]\s*$',conf)[1:]:
        fields=dict(re.findall(r'(?m)^([a-z_]+)\s*=\s*"([^"\n]*)"\s*$',block))
        records.append({k:fields[k] for k in ['name','shortcut']})
    assert len(records)==9
    assert {r['shortcut']:r['name'] for r in records if r['shortcut'] in ['cvc5','z3','altergo']} == {
        'cvc5':'CVC5','z3':'Z3','altergo':'altergo'}
    assert max(len(r['name'].encode()) for r in records)==8
    assert len('Trivial')<=8
    assert all(r['name'].isascii() for r in records)
    assert prefix[case]['log_path_bytes']==row['configured_name_bytes']['log']
    names.append({"case":case,"archive":ar,"member":member,"member_identity":ident(data),
        "configured_provers":records,"initial_synthetic_name":"Trivial",
        "all_name_bytes_upper":8,"log_path":prefix[case]['log_path'],
        "log_path_bytes":prefix[case]['log_path_bytes']})
write("name-origin-projection.json",names)
write("inputs.json",inputs)

keys=['timestamp','goal_id','prover','pas','kind','answer','time']
statuses=['undone','scheduled','running','done','interrupted','detached','internalfailure','uninstalled','upgradeprover','removed']
answers=['valid','invalid','timeout','outofmemory','steplimitexceeded','unknown','failure','highfailure']
L=sum(map(len,keys))+20+8+max(map(len,statuses))+max(map(len,answers))
assert L==99
C,F,M,Ns,Nf=2,7,5,4,2
B=2*C+M+3*F+2*Ns+6*L+317*Nf
E=2*C+M+3*F+2*Ns+2*L+Nf
assert B==1266 and E==238
assert B<=1280 and E<=256 and 1280+256+79<1000000010
rows=[]
for row in read(CANON)['cases']:
    Q=row['E']; H=Q*Q+4*Q; X=1281*H
    name=next(n for n in names if n['case']==row['case'])
    assert H < (1<<62)-1 and X < (1<<63)-1
    rows.append({"case":row['case'],"Q":Q,"scheduled_callbacks_upper":Q,
        "build_idle_failure_callbacks_upper":2*Q,"terminal_update_callbacks_upper":Q,
        "queue_interruption_callbacks_upper":Q*Q,"log_invocations_upper_H":H,
        "formatter_text_bytes_upper":1280*H,"formatter_events_upper":256*H,
        "direct_newline_bytes_upper":H,"channel_offered_bytes_upper_X":X,
        "initial_debt_P0":0,"initial_cached_offset_O0":0,
        "cached_offset_upper":X,"signed_offset_margin":(1<<63)-1-X,
        "native_buffer_bytes":65536,"native_channel_record_bytes":65616,
        "postcut_log_channel_creations":0,"postcut_log_channel_wrapper_increments_upper":6,
        "log_channel_refcount_upper":7,"per_entry_buffer_objects":0,
        "log_path_bytes":name['log_path_bytes'],"numeric_guards_pass":True,
        "channel_capacity_condition":"log-specific positive-write, stable descriptor/lifetime and selected native/returning-client contracts",
        "complete_JSON_lines_or_delivery_established":False,
        "syscall_attempt_count_upper":None})
layout=[]
for n in [1,4,8,9,15,17,20,317,42]:
    w=(n+8)//8
    assert w<1<<54 and 0<=8*w-1-n<=7
    layout.append({"string_bytes":n,"payload_words":w,"header_and_payload_bytes":8*(w+1)})
write("bounds.json",{"cases":rows,"maximum_log_tree":{"containers":C,"fields":F,"commas":M,
    "string_values":Ns,"float_values":Nf,"all_key_and_string_bytes":L,"exact_schema_B":B,"exact_schema_E":E},
    "per_entry":{"B":1280,"E":256,"direct_newline":1,"default_margin":78,
        "max_indent":68,"guard_lhs":1280+256+79,"formatter_flushes":0,
        "Buffer_objects":0,"fixed_object_payload_words_upper":128},
    "string_layouts":layout,"shared_e":2,"save_entering_callbacks":2,"saves":3,
    "aggregate_RAM_or_stack_quota":False,"production_or_whole_goal_complete":False})
write("check-result.json",{"status":"pass","source_spans":len(witnesses),"cases":len(rows),
    "elapsed_seconds":time.monotonic()-START,"native_runs":0,"compiler_runs":0,
    "solver_runs":0,"proof_runs":0,"capture_runs":0,"source_fetches":0,"predecessor_runs":0,
    "claim":"strict source/identity/name inventory and local arithmetic; semantic source argument and conditional service attachment require review"})
print(json.dumps(read(str(OUT.relative_to(ROOT)/'check-result.json')),sort_keys=True))

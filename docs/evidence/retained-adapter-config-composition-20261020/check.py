#!/usr/bin/env python3
"""Compose retained source credits and identical capture attachments only."""
from __future__ import annotations
import argparse
import gzip
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
TIMING="docs/evidence/retained-response-timing-config-20261020/"


def identity(raw):
    return {"bytes":len(raw),"sha256":hashlib.sha256(raw).hexdigest()}


def encode(obj):
    return (json.dumps(obj,indent=2,sort_keys=True)+"\n").encode()


def derive():
    manifest=json.loads((HERE/"accepted-quiet.json").read_text())
    q={}
    consumed={"accepted-quiet.json":identity((HERE/"accepted-quiet.json").read_bytes())}
    for name,rec in manifest["files"].items():
        stored=(HERE/rec["retained_path"]).read_bytes();raw=gzip.decompress(stored)
        assert identity(raw)=={k:rec[k] for k in ("bytes","sha256")}
        consumed[rec["retained_path"]]=identity(stored)
        q[name]=json.loads(raw) if name.endswith(".json") else raw
    frozen=json.loads((HERE/"timing-freeze.json").read_text())
    consumed["timing-freeze.json"]=identity((HERE/"timing-freeze.json").read_bytes())
    t={}
    for path,expected in frozen["files"].items():
        raw=(ROOT/path).read_bytes();assert identity(raw)==expected,path
        t[path.removeprefix(TIMING)]=json.loads(raw) if path.endswith(".json") else raw
    old=t["base-why3.conf"]
    candidate=q["candidate-base-why3.conf"]
    before=b'command = "cvc5 --prenex-quant=none --stats-internal %f"'
    after=(b'command = "/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/'
           b'gnatprove_16.1.0_82528bef/libexec/spark/bin/cvc5 --prenex-quant=none --quiet %f"')
    assert old.count(before)==2
    assert candidate==old.replace(before,after,1)
    assert len(old)==1946 and len(candidate)==2069
    assert q["candidate-extra-why3.conf"]==t["overlay/why3.conf"]
    assert q["candidate-extra-why3.conf"]==b"[main]\nmagic = 14\n"
    # Both imported certificates bind the same source and raw capture inputs.
    qi=q["prefix-inputs.json"]["files"];ti=t["inputs.json"]["files"]
    shared={p:rec for p,rec in qi.items() if p in ti}
    for path,rec in shared.items(): assert rec==ti[path],path
    raw_archives=[p for p in shared if "retained-why-save-state-capture" in p]
    assert len(raw_archives)==6
    qresult=q["prefix-result.json"];tresult=t["result.json"]
    assert qresult["allocation_delta_upper_words"]==qresult["remembered_entry_allowance"]==4096
    assert q["lexer-account.json"]["selected_delta_words"]==4096
    assert q["lexer-account.json"]["new_command_queue_elements_before_cuts"]==0
    credits={"minor_words":tresult["minor_credit_words"]+4096,
             "major_words":tresult["major_credit_words"],
             "remembered_entries":tresult["reference_credit_entries"]+4096,
             "ephemeron_entries_added":0,"custom_entries_added":0,
             "custom_resource_fraction_added":0,"dependent_words_added":0,
             "identifier_registrations_added":0,"driver_registrations_added":0,
             "FileTags_distinct_names_added_upper":1,
             "command_queue_elements_before_cuts_added":0}
    assert credits["minor_words"]==7582192 and credits["major_words"]==7578096
    assert credits["remembered_entries"]==18924760
    qr={r["case"]:r for r in qresult["later_capture_cases"]}
    qc={r["case"]:r for r in q["capture-resources.json"]}
    tc={r["case"]:r for r in t["capture-resources.json"]}
    inv={r["case"]:r for r in t["invocations.json"]}
    rows=[]
    for row in tresult["rows"]:
        name=row["case"];a=qc[name];b=tc[name]
        assert a["pid"]==b["pid"]
        assert a["start"]==b["start"] and a["end"]==b["end"]
        assert a["invocation"]==inv[name]["invocation"]
        assert qr[name]["minor_words"]==row["minor"]
        assert qr[name]["major_words_unchanged"]==row["major"]
        assert qr[name]["initial_registration_count_preserved"]==row["I"]
        assert qr[name]["table_used"]==row["tables"]
        candidate_minor=row["minor"]+credits["minor_words"]
        candidate_major=row["major"]+credits["major_words"]
        candidate_arena=candidate_major+row["prior_major_words"]
        candidate_refs=row["tables"]["ref_table"]+credits["remembered_entries"]
        assert candidate_minor<2**28 and candidate_major<2**28
        assert candidate_arena<2**24 and candidate_refs<2**25
        assert 5*row["I"]<=candidate_minor<5*2**62
        rows.append({"case":name,"pid":a["pid"],"cut":row["cut"],"I":row["I"],
                     "candidate_minor_upper":candidate_minor,"candidate_major_upper":candidate_major,
                     "candidate_arena_upper":candidate_arena,"candidate_reference_upper":candidate_refs,
                     "ephemeron_entries_unchanged":row["tables"]["ephe_ref_table"],
                     "custom_entries_unchanged":row["tables"]["custom_table"],
                     "identical_raw_start_and_cut":True})
    result={"quiet_author_freeze":manifest["author_freeze"],"timing_author_freeze":frozen["author_freeze"],
            "source_claim":"Composed serial prefix under both packets' named source/runtime relations",
            "credits":credits,"rows":rows,"configured_queued_limits":[0.0,0,0],"native_server_limits":[0,0],
            "new_native_runs":0,"predecessor_replays":0,"parallel_transfer_claimed":False,
            "source_simulation_machine_checked":False,"depends_on_proxy_design":False,"complete_q":None}
    recipe={"base_config":identity(candidate),"extra_config":identity(q["candidate-extra-why3.conf"]),
            "overlay_files":{p:rec for p,rec in frozen["files"].items() if "/overlay/" in p},
            "changed_base_line_before":before.decode(),"changed_base_line_after":after.decode(),
            "extra_prover_records_changed":0,"parallelism_or_path_spelling_changed":False}
    consumed["check.py"]=identity(Path(__file__).read_bytes())
    return {"result.json":encode(result),"recipe.json":encode(recipe),
            "candidate-base-why3.conf":candidate,
            "inputs.json":encode({"local_files":consumed,"timing_files":frozen["files"],
                                  "shared_bound_source_and_capture_inputs":shared})}


def main():
    p=argparse.ArgumentParser();p.add_argument("--write",action="store_true");args=p.parse_args()
    output=derive()
    for name,data in output.items():
        path=HERE/name
        if args.write:path.write_bytes(data)
        else:assert path.read_bytes()==data,"evidence differs: "+name
    print(json.dumps({"passed":True,"same_raw_capture_attachments":5,"native_runs":0,"predecessor_replays":0}))


if __name__=="__main__":main()

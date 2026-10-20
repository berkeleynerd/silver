#!/usr/bin/env python3
"""Check retained bytes and the new finite projection, without writes/reruns."""
import hashlib
import json
import platform
import re
import sys
import tarfile
import time

sys.dont_write_bytecode = True
from project import HERE, ROOT, COUNTS, project

COUNTERS = {}

def sha(b):
    return hashlib.sha256(b).hexdigest()

def check(group, condition):
    assert condition, group
    COUNTERS[group] = COUNTERS.get(group, 0) + 1

def main():
    start = time.perf_counter()
    pins = json.loads((HERE / 'inputs.json').read_bytes())
    for group in ('archives', 'context_files', 'packet_files'):
        base = HERE if group == 'packet_files' else ROOT
        for path, digest in pins[group].items():
            check(group, sha((base / path).read_bytes()) == digest)
    witnesses = json.loads((HERE / 'source-witnesses.json').read_bytes())
    inventory = json.loads((HERE / 'source-use-inventory.json').read_bytes())
    for archive in sorted({w['archive'] for w in witnesses}):
        with tarfile.open(ROOT / archive) as t:
            for w in witnesses:
                if w['archive'] != archive:
                    continue
                raw = t.extractfile(w['member']).read()
                excerpt = ''.join(raw.decode().splitlines(keepends=True)[w['first_line']-1:w['last_line']])
                check('source_slices', sha(raw) == w['member_sha256'] and excerpt == w['text'] and sha(excerpt.encode()) == w['slice_sha256'])
            if 'why-session-helper' in archive:
                scan = []
                for m in t.getmembers():
                    if not m.isfile() or not m.name.endswith(('.ml', '.mli')):
                        continue
                    raw = t.extractfile(m).read()
                    hits = [{'line':i,'text':line} for i,line in enumerate(raw.decode().splitlines(),1) if re.search(inventory['pattern'],line)]
                    scan.append({'member':m.name,'sha256':sha(raw),'hits':hits})
                check('complete_source_inventory', scan == inventory['files'])
                check('no_Why3_temp_directory_setter', not any('set_temp_dir_name' in hit['text'] for row in scan for hit in row['hits']))
                hit_members = [row['member'] for row in scan if row['hits']]
                check('encoding_dispatch_inventory', hit_members == ['why3/src/transform/encoding_guards.ml', 'why3/src/transform/encoding_guards_full.ml', 'why3/src/transform/encoding_tags.ml', 'why3/src/transform/encoding_tags_full.ml', 'why3/src/transform/encoding_twin.ml'])
    result = project()
    check('new_projection_equality', result == json.loads((HERE / 'projection.json').read_bytes()))
    for profile, constants in [('original',[150,150,155,153,153]),('quiet',[273,273,278,276,276])]:
        for (case, n), constant in zip(COUNTS.items(), constants):
            row = result['domains'][case]['profiles'][profile]
            check('domain_bound', row['L_d'] == {'A':1,'tau':1,'constant':constant} and row['m_d'] == 14)
            check('interrupt_bound', 2+constant >= row['interrupt_wire_bytes'])
    check('inherited_counts', result['aggregate']['N'] == 459 and result['aggregate']['sum_N_times_digits'] == 1257)
    check('output_path_operands', result['output_paths']['P_b'] == {'C':1,'constant':11} and result['output_paths']['P_c'] == {'R':1,'constant':24} and result['output_paths']['backend_getcwd_captured'] is False)
    return {'status':'pass', 'platform':platform.system()+' '+platform.machine(), 'elapsed_seconds':round(time.perf_counter()-start,6), 'checks':COUNTERS, 'enumerated_wrapped_serializations':sum(COUNTS.values())*3*2*2*2, 'raw_goal_labels_joined':sum(r['raw_goals'] for r in result['domains'].values()), 'driver_files':14, 'source_slices':len(witnesses), 'inventoried_ML_MLI_members':len(inventory['files']), 'source_semantics_machine_proved':False, 'combined_quiet_timeless_J12_logging_startup_proved_here':False, 'native_target_solver_proof_runs':0, 'predecessor_checker_replays':0, 'complete_q':None, 'production_adopted':False}

if __name__ == '__main__':
    print(json.dumps(main(),indent=2,sort_keys=True))

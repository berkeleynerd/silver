#!/usr/bin/env python3
"""Only the changed GPR Name_Entry width; preserve the first result."""
import json,re,tarfile,time,hashlib
from pathlib import Path
import capacity as C
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[3]
start=time.monotonic()
old=json.loads((HERE/'first-check/result.json').read_text())
assert old['all_changed_concrete_checks_pass']
path='docs/evidence/retained-producer-orchestration-20261018/observations.tar.gz'
m=json.loads((HERE/'source-manifest.json').read_text())
assert hashlib.sha256((REPO/path).read_bytes()).hexdigest()==m['providers'][path]
widths=[]
with tarfile.open(REPO/path) as t:
    for name in old['GPR']['configurations']:
        s=t.extractfile('complete_configs/retained-temporaries/'+name).read().decode()
        prefix=re.search(r'for Runtime_Dir\s+\("Ada"\) use "([^"]+)"',s).group(1)
        literal=re.search(r'"(-Wl,-rpath-link,[^"]+)"',s).group(1)
        new=literal.replace(prefix,C.R+'/')
        widths.append(len(new))
assert widths==[185,185,185]
rows=C.gpr_unit_transfer_conditions()
assert rows['endpoint_arithmetic']['Name_Vector']['longest_new_element_bytes']==max(widths+[len(C.RTS),len(C.R)+1])+48==233
assert rows['endpoint_arithmetic']['passed']
old['GPR']['context_transfer']=rows
old['GPR']['longest_changed_literal_bytes']=185
old['GPR']['longest_new_Name_Entry_object_bytes']=233
old['check_history']={'first_check_seconds':old.pop('elapsed_seconds'),
    'first_result':'first-check/result.json',
    'first_result_superseded_reason':'Manual audit found the185-byte linker rpath literal exceeds the168-byte RTS literal.',
    'focused_correction_seconds':round(time.monotonic()-start,6),
    'identical_success_replayed':False,'changed_check_runs':2}
(HERE/'result.json').write_text(json.dumps(old,indent=2,sort_keys=True)+'\n')
print(json.dumps({'linker_literal_bytes':185,'Name_Entry_object_bytes':233,
    'passed':True,'elapsed_seconds':old['check_history']['focused_correction_seconds']}))

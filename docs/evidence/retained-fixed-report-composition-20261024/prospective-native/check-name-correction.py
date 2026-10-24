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
assert widths==[186,186,186]
rows=C.gpr_unit_transfer_conditions()
assert rows['endpoint_arithmetic']['Name_Vector']['longest_new_element_bytes']==max(widths+[len(C.RTS),len(C.R)+1])+48==234
assert rows['endpoint_arithmetic']['passed']
old['GPR']['context_transfer']=rows
old['GPR']['longest_changed_literal_bytes']=186
old['GPR']['longest_new_Name_Entry_object_bytes']=234
old['check_history']={'first_check_seconds':old.pop('elapsed_seconds'),
    'first_result':'first-check/result.json',
    'first_result_superseded_reason':'Manual audit found the186-byte linker rpath literal exceeds the168-byte RTS literal.',
    'focused_correction_seconds':round(time.monotonic()-start,6),
    'identical_success_replayed':False,'changed_check_runs':3,
    'correction_first_attempt':'name-correction-failed/check-name-correction.stderr',
    'correction_first_attempt_reason':'Handwritten width expectation185 was one byte short; source template is186. Formula already evaluated234; only expected/result labels changed.'}
(HERE/'result.json').write_text(json.dumps(old,indent=2,sort_keys=True)+'\n')
print(json.dumps({'linker_literal_bytes':186,'Name_Entry_object_bytes':234,
    'passed':True,'elapsed_seconds':old['check_history']['focused_correction_seconds']}))

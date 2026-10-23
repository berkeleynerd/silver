"""Only the changed FileTags operand and provider join; no graph replay."""
from pathlib import Path
import hashlib,json,time
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];start=time.perf_counter();checks=0
def check(p,msg):
    global checks
    checks+=1;assert p,msg
provider=json.loads((HERE/'filetag-provider.json').read_text())
for p,e in provider['providers'].items():
    b=(ROOT/p).read_bytes();check(dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())==e,p)
check(provider['all_FileTags_origin_bound']==180,'reviewed filename bound')
old=json.loads((HERE/'result-before-filetag-repair.json').read_text())
raw={r['case']:r for r in json.loads((ROOT/'docs/evidence/retained-fixed-ptree-capture-20261023/result.json').read_text())['cases']}
rows=[]
for c in old['cases']:
    locs=raw[c['case']]['position_candidate_occurrences'];extra=4*180*locs
    B=c['all_option_modes_byte_bound']+extra;cap=1024
    while cap<B:cap*=2
    check(c['maximum_atom_bytes']>=180,'existing individual max covers returned filename')
    check(cap<=2**57-9 and 2*cap<=2**62-1 and B+4*c['maximum_atom_bytes']+2<=2**62-1 and B<=2**63-1,'changed Buffer/channel guards')
    c.update(FileTags_filename_bound=180,FileTags_replacement_extra_bytes=extra,complete_failure_byte_bound=B,buffer_backing_bound=cap)
    rows.append(dict(case=c['case'],Loc_candidates=locs,extra_bytes=extra,B=B,capacity=cap))
old.update(source_transfer_requires_review=True,filetag_repair='Separate changed-provider/arithmetic check; prior graph/native checks retained',
           graph_check_elapsed_seconds=old.pop('elapsed_seconds'))
(HERE/'result.json').write_text(json.dumps(old,indent=2)+'\n')
out=dict(status='pass',checks=checks,scope='R69 alias-robust filename provider and changed byte/Buffer arithmetic only',
         cases=rows,graph_replays=0,native_runs=0,elapsed_seconds=time.perf_counter()-start)
(HERE/'filetag-repair-result.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))

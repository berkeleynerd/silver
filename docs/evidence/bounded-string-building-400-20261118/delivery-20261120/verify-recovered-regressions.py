#!/usr/bin/env python3
"""Independent read-only recount/hash comparison of recovered #403 records."""
from pathlib import Path
import collections,hashlib,json,re,subprocess
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
R=HERE/'recovered-records'
PR='001c50dce1bcf3ad2d174b4426f684fe78cb2e64'
PREFIX='/home/agent/silver-review/runs/pr402-9b5b2d99aa/checkout/'
RUNS={
 '20261118T173931-305d1781f71e':'suite.log',
 '20261118T173513-f3c45b223d1e':'test_string_characters.py.log',
 '20261118T173536-c2d8662ad230':'test_samples.py.log',
 '20261118T173927-90b8193aa993':'test_rosetta.py.log'}
W=R/'workflow-packet/runs/dev400-a03c7987bb'
checks=W/'artifacts/checks-1'
results={}; inventories=[]
for run,file in RUNS.items():
 d=R/'managed-runs-403'/run
 events=[json.loads(l) for l in (d/'events.jsonl').read_text().splitlines()]
 get=lambda e:next(x for x in events if x['event']==e)
 inv=get('prepared')['inputs']['inputs_sha256'];inventories.append(inv)
 log=(d/'native.log').read_bytes(); lines=log.decode().splitlines(); heads=[]
 for i,line in enumerate(lines):
  m=re.match(r'^test_\w+ \(([\w.]+)\)(.*)$',line)
  if m:heads.append((i,m[1],m[2]))
 parsed=[];split_output=[]
 for n,(i,ident,tail) in enumerate(heads):
  end=heads[n+1][0] if n+1<len(heads) else len(lines)
  block=lines[i:end]
  if tail.startswith(' ... skipped '):status='skipped'
  else:
   assert tail==' ... ok' or any(x=='ok' or x.endswith(' ... ok') for x in block[1:]),(ident,block[-3:])
   status='passed'
  if tail.startswith(' ... ') and tail!=' ... ok' and status=='passed':split_output.append(ident)
  parsed.append({'id':ident,'status':status,'line':i+1})
 assert len({x['id'] for x in parsed})==len(parsed)
 phase=[x for x in events if x['event']=='phase-end' and x.get('phase')=='test'];assert len(phase)==1 and phase[0]['returncode']==0
 assert get('finished')['outcome']=='success'
 wlog=(checks/file).read_bytes();assert wlog.split(b'\n',1)[1]==log
 trailer=re.search(r'Ran (\d+) tests in ([0-9.]+)s\n\n(OK[^\n]*)$',log.decode().rstrip());assert trailer
 assert len(parsed)==int(trailer[1])
 results[run]={'log_sha256':hashlib.sha256(log).hexdigest(),'counts':dict(collections.Counter(x['status'] for x in parsed)),
  'trailer':trailer[0], 'tests':parsed,'parser_missed_ids':split_output,
  'start':get('started')['utc'],'finish':get('finished')['utc'],'managed_duration_seconds':get('finished')['duration_seconds'],
  'test_duration_seconds':float(trailer[2]),'phase_returncode':phase[0]['returncode'],'final_outcome':get('finished')['outcome'],
  'final_returncode':get('finished')['returncode'],'available_cpus':get('started')['available_cpus'],
  'workers':get('started')['workers'],'command':get('command')['command'],'cwd':get('command')['cwd'],
  'original_workflow_log_matches':True,'input_count':len(inv)}
assert all(x==inventories[0] for x in inventories)
inv=inventories[0];repo={k.removeprefix(PREFIX):v for k,v in inv.items() if k.startswith(PREFIX) and not k.startswith(PREFIX+'.silver/')};support={k:v for k,v in inv.items() if k.removeprefix(PREFIX) not in repo}
# Query Git blobs directly in this session, independent of collection summaries.
comparisons=[]
with subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE) as p:
 for name,expected in sorted(repo.items()):
  p.stdin.write(f'{PR}:{name}\n'.encode());p.stdin.flush();header=p.stdout.readline().decode().split();assert header[1]=='blob',header
  data=p.stdout.read(int(header[2]));assert p.stdout.read(1)==b'\n';actual=hashlib.sha256(data).hexdigest();assert actual==expected,name
  comparisons.append({'path':name,'sha256':actual})
 p.stdin.close();assert p.wait()==0
support_rows=[]
for name,expected in sorted(support.items()):
 path=R/'managed-runs-403/supporting-inputs'/name.removeprefix(PREFIX) if name.startswith(PREFIX) else R/'arm-tools'/name.removeprefix('/')
 actual=hashlib.sha256(path.read_bytes()).hexdigest();assert actual==expected,(name,actual,expected)
 support_rows.append({'recorded_path':name,'recovered_file':str(path.relative_to(HERE)),'sha256':actual})
assert len(repo)==1340 and len(support)==8
# Independent final inventory correspondence, including existing imported duplicate bodies under distinct IDs.
full=results['20261118T173931-305d1781f71e'];discovery=json.loads((HERE/'final-test-inventory.json').read_text())['tests']
assert sorted(x['id'] for x in full['tests'])==sorted(discovery)
assert full['counts']=={'passed':722,'skipped':2};assert len(full['parser_missed_ids'])==12
# The recovered Git commit object is self-identifying and binds the check to the final tracked tree.
commit=(R/'managed-runs-403/checked-identity/commit.txt').read_bytes();sha=hashlib.sha1(f'commit {len(commit)}\0'.encode()+commit).hexdigest()
assert sha=='7d5967240779a46f73d1c29746d77e530f81f906'
tree=subprocess.check_output(['git','rev-parse',PR+'^{tree}'],cwd=ROOT).decode().strip();assert commit.startswith(('tree '+tree+'\n').encode())
subprocess.run(['git','diff','--quiet','9b5b2d99aaf6f4bfca5226b36af744502b095990',PR,'--','src','proof','scripts','alire.toml','silver.gpr','catalogue/silver.json','oracle.md'],cwd=ROOT,check=True)
out={'reviewed_pr':PR,'same_input_inventory_all_four_runs':True,'repository_input_count':len(comparisons),'supporting_input_count':len(support_rows),'repository_inputs':comparisons,'supporting_inputs':support_rows,'runs':results,'checked_commit':sha,'shared_tree':tree,'compiler_source_comparison':'matching governed inputs versus build head 9b5b2d99aaf6f4bfca5226b36af744502b095990'}
(HERE/'recovered-regression-verification.json').write_text(json.dumps(out,indent=2)+'\n')
print('Repository hashes',len(comparisons),'matching; support hashes',len(support_rows),'matching; checked commit/tree valid')
for run,x in results.items():print(run,x['counts'],x['test_duration_seconds'],x['managed_duration_seconds'],x['start'],x['finish'])
print('Parser missed IDs',*full['parser_missed_ids'],sep='\n')

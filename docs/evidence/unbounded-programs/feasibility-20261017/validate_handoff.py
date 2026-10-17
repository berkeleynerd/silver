from pathlib import Path
import hashlib,json,re,subprocess,datetime,argparse
parser=argparse.ArgumentParser()
parser.add_argument('--root',type=Path,default=Path.cwd())
parser.add_argument('--shared-start',type=Path)
parser.add_argument('--shared-end',type=Path)
args=parser.parse_args()
root=args.root.resolve()
p=root/'docs/evidence/unbounded-programs/feasibility-20261017'
results={'checked_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'manifest_files':{},'json_files':0,'local_markdown_paths':0,'errors':[]}
for child in ['source-capacity','static-data']:
 d=json.loads((p/child/'MANIFEST.json').read_text()); entries=d if isinstance(d,list) else d['files']
 for e in entries:
  q=p/child/e['path']; b=q.read_bytes()
  if hashlib.sha256(b).hexdigest()!=e['sha256'] or len(b)!=e['bytes']: results['errors'].append(str(q))
 results['manifest_files'][child]=len(entries)
for q in p.rglob('*.json'):
 try:json.loads(q.read_text());results['json_files']+=1
 except Exception as e:results['errors'].append(f'{q}: {e}')
for q in list((root/'docs/research').glob('*.md'))+[root/'docs/unbounded-programs.md',root/'docs/session-memory.md',root/'roadmap.md']:
 for target in re.findall(r'\]\(([^)]+)\)',q.read_text()):
  if re.match(r'^[a-zA-Z][a-zA-Z0-9+.-]*:',target) or target.startswith('#'):continue
  path=target.split('#',1)[0]
  if not path:continue
  dest=(q.parent/path).resolve()
  results['local_markdown_paths']+=1
  if not dest.exists():results['errors'].append(f'{q.relative_to(root)}: {target}')
r=subprocess.run(['git','diff','--check'],cwd=root,capture_output=True,text=True)
results['git_diff_check_exit']=r.returncode
if r.returncode:results['errors'].append(r.stdout+r.stderr)
results['shared_status_unchanged']=(args.shared_start.read_bytes()==args.shared_end.read_bytes()) if args.shared_start and args.shared_end else None
print(json.dumps(results,indent=2))
assert not results['errors']
assert results['shared_status_unchanged'] is not False

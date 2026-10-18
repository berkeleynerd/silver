from pathlib import Path
import hashlib,json,os,subprocess,time
root=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/retained-tool-capacity')
r=Path(__file__).parent
m=json.loads((root/'docs/evidence/retained-link-inputs-20261018/capture/result.json').read_text())
ld=Path(m['source_link_argv'][0]).parent/'ld'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
before=sha(ld); argv=[str(ld),'--help']; env={'PATH':str(ld.parent)+':/usr/bin:/bin','LC_ALL':'C'}
t=time.monotonic();p=subprocess.run(argv,cwd=r,env=env,capture_output=True);seconds=time.monotonic()-t
(r/'stdout').write_bytes(p.stdout);(r/'stderr').write_bytes(p.stderr)
rows=[x for x in p.stdout.decode().splitlines() if 'compress-debug-sections' in x or 'Pack relative relocations' in x or 'Do not pack relative relocations' in x]
record=dict(argv=argv,environment=env,cwd=str(r),returncode=p.returncode,duration_seconds=seconds,executable_sha256=before,executable_unchanged=before==sha(ld),relevant_help_lines=rows)
(r/'result.json').write_text(json.dumps(record,indent=2)+'\n')
assert record['executable_unchanged'];p.check_returncode();print(json.dumps(record))

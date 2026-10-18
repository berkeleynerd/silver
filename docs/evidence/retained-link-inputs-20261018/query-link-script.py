from pathlib import Path
import json, subprocess, time
r=Path(__file__).resolve().parent
meta=json.loads((r/'capture/result.json').read_text())
gcc=Path(meta['source_link_argv'][0]);ld=gcc.parent/'ld'
out=r/'link-script';out.mkdir()
argv=[str(ld),'--eh-frame-hdr','-m','elf_x86_64','-dynamic-linker','/lib64/ld-linux-x86-64.so.2','-pie','-z','origin','--verbose']
t=time.monotonic();result=subprocess.run(argv,cwd=out,env=meta['environment'],capture_output=True)
(out/'stdout').write_bytes(result.stdout);(out/'stderr').write_bytes(result.stderr)
record={'argv':argv,'cwd':str(out),'environment':meta['environment'],'returncode':result.returncode,'duration_seconds':time.monotonic()-t,'outputs_before_metadata':sorted(x.name for x in out.iterdir())}
(out/'result.json').write_text(json.dumps(record,indent=2)+'\n')
assert not (out/'a.out').exists()
result.check_returncode()
print(json.dumps(record))

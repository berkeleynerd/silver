"""Focused byte replay of the new typed capture; no target or predecessor run."""
import argparse,hashlib,importlib.util,json,tempfile,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('--output',type=Path);args=p.parse_args();start=time.monotonic()
root=args.capture
reads={};count=0
for line in (root/'metadata-memory-reads.jsonl').open():
 r=json.loads(line);key=(r['address'],r['bytes']);value=bytes.fromhex(r['hex']);assert len(value)==r['bytes']
 if key in reads:assert reads[key]==value
 reads[key]=value;count+=1
requests=0
def read(address,size):
 global requests
 requests+=1
 return reads[address,size]
symbols=json.loads((root/'session-symbols.json').read_text())['checks']
def address(name):return symbols[name]['address']
def module(name,file):
 s=importlib.util.spec_from_file_location(name,file);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
session=module('r53_session',HERE/'collector/inherited-session_observer.py')
metadata=module('r53_meta',HERE/'collector/metadata.py')
expected=['session-root.json','session-tables.json','session-task-chains.json','session-forest.json','session-result.json','metadata.json','session-blocks.jsonl','session-task-graph-addresses.jsonl','metadata-payload-addresses.jsonl']
with tempfile.TemporaryDirectory(prefix='silver-r53-replay-') as out:
 s=session.SessionCapture(read,address,Path(out))
 try:
  assert s.capture_roots()['complete'];assert s.capture_session()['complete'];assert metadata.Projection(s).collect()['complete']
 finally:s.close()
 for name in expected:
  assert (Path(out)/name).read_bytes()==(root/name).read_bytes(),name
summary=json.loads((root/'summary.json').read_text());assert summary['completed'] and not summary['failures'] and not summary['guard_hits'];assert not any(r['hits'] for r in summary['forbidden_calls'].values())
process=json.loads((root/'process.json').read_text());server=json.loads((root/'server.json').read_text());assert process['argv'][process['argv'].index('-j')+1]=='12' and server['argv'][server['argv'].index('-j')+1]=='12'
result=dict(status='pass',elapsed_seconds=time.monotonic()-start,read_rows=count,distinct_reads=len(reads),replay_read_requests=requests,exact_output_files=len(expected),native_J=12,solver_launches=0,preparation_entries=0,full_Hsdecl_captured=False)
print(json.dumps(result,indent=2))
if args.output:args.output.write_text(json.dumps(result,indent=2)+'\n')

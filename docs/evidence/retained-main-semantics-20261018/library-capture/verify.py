#!/usr/bin/env python3
"""Reconcile fixed library frontend captures without executing the producer."""
from pathlib import Path
import hashlib,json,tarfile
root=Path(__file__).resolve().parent
summary=json.loads((root/'summary.json').read_text())
manifest=json.loads((root/'archive-manifest.json').read_text())
tools=json.loads((root/'tool-identities.json').read_text())
producer=next(v['sha256'] for k,v in tools.items() if k.endswith('/gnat2why'))
coverage=json.loads((root.parent/'fixed-capture/address-coverage.json').read_text())
assert coverage['sha256']==producer
with tarfile.open(root/'captures.tar.gz') as t:
 names=t.getnames();assert set(names)==set(manifest) and len(names)==len(set(names))
 for name,row in manifest.items():
  data=t.extractfile(name).read();assert len(data)==row['bytes']
  assert hashlib.sha256(data).hexdigest()==row['sha256']
 for case in summary['cases']:
  name=case['case'];read=lambda n:json.loads(t.extractfile(name+'/'+n).read())
  x=read('pool-counters.json');result=read('result.json');options=read('options.json')
  assert result['returncode']==0 and result['producer_sha256']==producer
  assert x['unexpected_collect']==0 and x['backend_calls']==case['backend_calls']
  assert x['range_mutations']==0 and x['cache_calls']=={'discrete':0,'real':0}
  assert all(r['why3_args']==['/usr/bin/false'] for r in options['file_specific'].values())
  phase=x['phases'][-1];assert phase['phase']=='before_symbol_free'
  pools=phase['pools'];assert len(pools)==121
  for key,row in pools.items():
   assert row['positive']==row['position']-row['initial']+row['negative']>=0
   assert row['positive']==case['fixed_logical_growth'][key]
  node=pools['atree__atree_private_part__node_offsets__last_val']
  assert node['initial']==-1 and node['negative']==0
  assert node['positive']==case['A_total']==case['E_total_bound']
  assert len(x['stores'])==1265
  assert result['elapsed_seconds']==case['runtime_seconds']
print('Verified four complete fixed library frontend domains and retained vectors')

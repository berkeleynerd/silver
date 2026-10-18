#!/usr/bin/env python3
"""Reconcile retained capture arithmetic/coverage; does not prove root reduction."""
from pathlib import Path
from collections import Counter
import json, hashlib
ROOT=Path(__file__).resolve().parent
read=lambda p:json.loads((ROOT/p).read_text())
x=read('pool-counters.json');scan=read('static-all-tables.json')
assert x['coherence_failures']==[] and x['unexpected_collect']==0 and x['backend_calls']==0
assert x['cache_calls']=={'discrete':179,'real':0}
assert len(x['queries'])==len(x['returns'])==x['range_mutations']==179
coherence={}
for r in x['returns']:
 key=(r['n'],r['original'],r['valid']);value=r['returned']
 assert key not in coherence or coherence[key]==value
 coherence[key]=value
assert len(coherence)==152
coverage=read('address-coverage.json')
assert coverage['sha256']==scan['sha256'] and coverage['elf_type']=='ET_DYN'
for key in ('immediate_candidates','absolute_candidates','relocations',
            'dynamic_symbols','symbol_aliases','data_pointer_candidates',
            'additional_direct_instructions','original_direct_missing'):
 assert coverage[key]==[],key
assert len(coverage['direct_overlaps'])==4375
assert not any(r['address_take'] for r in coverage['direct_overlaps'])
assert all(r['bytes']==r['decoded_bytes'] for r in coverage['executable_sections'])
stores={int(r['address'],16):r for r in scan['references'] if r['write']}
kept={r['address']:r for r in read('decrease-hooks.json')}
excluded={r['address']:r for r in read('excluded-positive-stores.json')}
assert not kept.keys()&excluded.keys() and kept.keys()|excluded.keys()==stores.keys()
assert (len(stores),len(kept),len(excluded))==(2299,1265,1034)
assert all(r['target']=='checks__determine_range_cache_n' for r in scan['references'] if r['address_take'])
assert len(read('all-last-symbols.json'))==121
assert all(r['size']==4 for r in read('all-last-symbols.json'))
last=x['phases'][-1];assert last['phase']=='before_symbol_free'
for name,row in last['pools'].items():
 assert row['positive']==row['position']-row['initial']+row['negative']>=0
fixed={k:r['positive'] for k,r in last['pools'].items()}
assert fixed['atree__atree_private_part__node_offsets__last_val']==12784
assert fixed['atree__atree_private_part__slots__last_val']==151749
assert fixed['uintp__uints__last_val']==1820
assert fixed['uintp__udigits__last_val']==42087
base=read('baseline-pool-counters.json')['phases'][-1]
for name,row in base['pools'].items():assert fixed[name]>=row['positive']
result=dict(scope='fixed light-mode whole-witness logical-growth vector; source root/cache/freezing argument separate',table_count=len(fixed),all_miss_queries=179,coherent_keys=len(coherence),fixed_logical_growth=fixed,source_map_rows=len(x['source_map']['rows']),runtime_seconds=read('result.json')['elapsed_seconds'],artifact_sha256={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(ROOT.iterdir()) if p.is_file() and p.name not in ('summary.json',)})
(ROOT/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
print('Verified 121 positions, 2299-store partition, 179 coherent returns, and lifetime arithmetic')
print('summary.json sha256',hashlib.sha256((ROOT/'summary.json').read_bytes()).hexdigest())

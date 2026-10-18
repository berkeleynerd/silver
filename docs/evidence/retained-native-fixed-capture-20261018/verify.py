#!/usr/bin/env python3
"""Check retained native capture arithmetic/coverage; no compiler execution."""
from pathlib import Path
import hashlib,json,tarfile
root=Path(__file__).resolve().parent
manifest=json.loads((root/'archive-manifest.json').read_text())
summary=json.loads((root/'summary.json').read_text())
with tarfile.open(root/'capture.tar.gz') as t:
 names=t.getnames();assert set(names)==set(manifest) and len(names)==len(set(names))
 for name,row in manifest.items():
  data=t.extractfile(name).read();assert len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256'],name
 read=lambda name:json.loads(t.extractfile(name).read())
 x=read('all-roots/pool-counters.json');scan=read('static-all-tables.json');coverage=read('address-coverage.json')
 assert read('all-roots/result.json')['returncode']==0
 assert scan['sha256']==coverage['sha256']==summary['binary_sha256']
 assert coverage['elf_type']=='ET_EXEC' and len(coverage['dynamic_symbols'])==120
 for key in ('immediate_candidates','absolute_candidates','relocations','symbol_aliases','additional_direct_instructions','original_direct_missing'):
  assert coverage[key]==[],key
 assert all(r['bytes']==r['decoded_bytes'] for r in coverage['executable_sections'])
 assert len(coverage['direct_overlaps'])==3822
 assert not any(r['address_take'] for r in coverage['direct_overlaps'])
 data=coverage['data_pointer_candidates']
 assert len(data)==241 and sum(r['section']=='.dynsym' for r in data)==240
 assert all(r['offset']%24==8 for r in data if r['section']=='.dynsym')
 # The remaining pattern straddles two 4-byte EH-table fields, not a pointer.
 assert [r for r in data if r['section']!='.dynsym']==[dict(section='.eh_frame_hdr',offset=33130,address=52361778,width=4,target='lib__writ__interrupt_states__last_val')]
 assert 33130%4==2
 stores={int(r['address'],16) for r in scan['references'] if r['write']}
 keep={r['address'] for r in read('decrease-hooks.json')};omit={r['address'] for r in read('excluded-positive-stores.json')}
 assert not keep&omit and keep|omit==stores
 assert (len(stores),len(keep),len(omit))==(2160,1144,1016)
 assert len(x['queries'])==len(x['returns'])==x['range_mutations']==summary['all_miss_queries']==26524
 assert x['cache_calls']==dict(discrete=26524,real=0) and not x['coherence_failures']
 coherence={}
 for row in x['returns']:
  key=(row['n'],row['original'],row['valid']);value=row['returned']
  assert key not in coherence or coherence[key]==value
  coherence[key]=value
 assert len(coherence)==summary['coherent_keys']==2374
 assert x['phases'][-1]['phase']=='main_return'
 for phase in x['phases']:
  for key,row in phase['pools'].items():
   assert row['positive']==row['position']-row['initial']+row['negative']>=0
  if phase['phase'] in summary['phases']:
   assert summary['phases'][phase['phase']]=={k:v['positive'] for k,v in phase['pools'].items()}
 decoded=json.loads((root/'decoded-names.json').read_text())
 last=x['phases'][-1]['pools']['namet__name_entries__last_val']['position']
 assert decoded['corrected_names']==[dict(id=r['id']+2,value=r['value']) for r in x['names'] if r['id']+2<=last]
 lookup={r['id']:r['value'] for r in decoded['corrected_names']}
 assert decoded['corrected_source_map']==[dict(r,file=lookup[r['file_id']]) for r in x['source_map']['rows']]
 files={r['file'] for r in decoded['corrected_source_map']}
 assert {f's-conca{i}.ads' for i in range(2,10)}<=files
 assert {'s-secsta.ads','s-parame.ads','s-stoele.ads','s-imgint.ads','s-imagei.ads'}<=files
 assert {'TdS','TTdSP1','main__TdS','main__TTdSP1'}<=set(lookup.values())
print('Verified native 120-position vectors, 2160-store coverage, 26524 coherent returns and decoded roots')

#!/usr/bin/env python3
"""Incremental arithmetic/attachment audit; does not replay earlier checks."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
COMPOSITION=ROOT/'docs/evidence/retained-adapter-config-composition-20261020'
TIMING=ROOT/'docs/evidence/retained-response-timing-config-20261020'


def load(p):return json.loads(p.read_bytes())


def main():
    ap=argparse.ArgumentParser();ap.add_argument('--write',action='store_true');args=ap.parse_args()
    inputs=load(HERE/'composition-inputs.json')
    for path,expected in inputs['files'].items():
        data=(ROOT/path).read_bytes()
        assert {'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}==expected,path
    combined=load(COMPOSITION/'result.json')
    timing=load(TIMING/'result.json')
    quiet=json.loads(gzip.decompress((COMPOSITION/'accepted-quiet/prefix-result.json.gz').read_bytes()))
    old_snapshots=json.loads(gzip.decompress((COMPOSITION/'accepted-quiet/capture-resources.json.gz').read_bytes()))
    new_snapshots=load(TIMING/'capture-resources.json')
    old={r['case']:r for r in old_snapshots};new={r['case']:r for r in new_snapshots}
    credits=combined['credits']
    assert quiet['allocation_delta_upper_words']==quiet['remembered_entry_allowance']==4096
    assert credits['minor_words']==timing['minor_credit_words']+4096==7582192
    assert credits['major_words']==timing['major_credit_words']==7578096
    assert credits['remembered_entries']==timing['reference_credit_entries']+4096==18924760
    rows=[]
    for c,t in zip(combined['rows'],timing['rows']):
        name=c['case'];assert name==t['case']
        assert old[name]['pid']==new[name]['pid']==c['pid']
        assert old[name]['start']==new[name]['start'] and old[name]['end']==new[name]['end']
        assert c['candidate_minor_upper']==t['candidate_minor_upper']+4096<2**28
        assert c['candidate_major_upper']==t['candidate_major_upper']<2**28
        assert c['candidate_arena_upper']==t['candidate_arena_allocation_upper']<2**24
        assert c['candidate_reference_upper']==t['candidate_reference_upper']+4096<2**25
        assert c['I']==t['I']
        rows.append({k:c[k] for k in ('case','pid','I','candidate_minor_upper','candidate_arena_upper','candidate_reference_upper')})
    assert combined['configured_queued_limits']==[0.0,0,0]
    assert combined['native_server_limits']==[0,0]
    assert combined['parallel_transfer_claimed'] is False
    assert combined['depends_on_proxy_design'] is False and combined['complete_q'] is None
    result={'frozen_input_files':len(inputs['files']),'rows':rows,'credits':credits,
            'same_full_raw_start_and_end_snapshots':5,'parallel_transfer_claimed':False,
            'scope':'Incremental identity and arithmetic; disjoint Rc/Lexlib source effects reviewed separately',
            'earlier_checkers_replayed':0}
    data=json.dumps(result,indent=2,sort_keys=True)+'\n'
    if args.write:(HERE/'composition-result.json').write_text(data)
    else:assert (HERE/'composition-result.json').read_text()==data
    print(json.dumps(result,sort_keys=True))


if __name__=='__main__':main()

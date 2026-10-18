#!/usr/bin/env python3
"""Check variable growth/lifetime interfaces and source-boundary composition."""
import argparse
import json
from pathlib import Path
import runpy

HERE=Path(__file__).resolve().parent


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    m=runpy.run_path(str(HERE/'storage.py'));ctx=m['Context']()
    cases=[]
    # Earlier arithmetic/interface result is bound by storage-inputs.json.
    prior=json.loads((HERE/'result.json').read_bytes())
    for row in prior['cases']:
        if 'result' not in row: continue
        base=row['result'];r=m['storage'](base,ctx,512)
        assert r['selected_GAS_BFD_storage_fits']==base['local_interface_fits']
        s=base['GAS']['symbol_allocations_upper'];rel=base['GAS']['relocations_upper']
        assert r['BFD_main_arena_raw_lifetime_bytes_upper']==512+136*s+24*rel+13792
        assert r['notes_chunk_bytes_upper']>=r['notes_request_bytes_upper']+250
        cases.append(dict(case=row['case'],result=r))
    raw=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin Silver_IO.Put ("x"); end Main;'
    joined=m['evaluate'](raw,ctx)
    assert joined['storage']['selected_GAS_BFD_storage_fits']
    assert joined['interface']['source_identity']==m['identity'](raw)
    cases.append(dict(case='same_source_join',result=joined))
    # Exact individual-allocation boundaries use synthetic configuration inputs.
    base=joined['interface']
    largest_path=m['I64']-250
    assert m['storage'](base,ctx,largest_path)['selected_GAS_BFD_storage_fits']
    assert not m['storage'](base,ctx,largest_path+1)['local_checks']['notes_growth']
    cases.append(dict(case='notes_growth_path_boundary',last_path=largest_path))
    # BFD changes capacity on insertion above the old load threshold.
    def strtab(d):
        changed=json.loads(json.dumps(base))
        changed['ELF']['symbols_including_null_upper']=d+1
        return m['storage'](changed,ctx,512)['ELF_string_tables'][0]
    assert strtab(3038)['hash_capacities']==[4051]
    assert strtab(3039)['hash_capacities']==[4051,4093]
    assert strtab(3070)['hash_capacities']==[4051,4093,8191]
    assert strtab(63)['pointer_array_capacity_upper']==64
    assert strtab(64)['pointer_array_capacity_upper']==128
    cases.append(dict(case='BFD_growth_and_pointer_boundaries'))
    result=dict(case_count=len(cases),cases=cases,all_checks_pass=True,
        verified_additional_inputs=ctx.inputs,verified_supplementary_sources=ctx.extra_sources,
        native_tool_executions=0,whole_literal_pipeline_capacity_established=False)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='cases'}))


if __name__=='__main__': main()

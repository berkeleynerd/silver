#!/usr/bin/env python3
"""Replay the source-derived literal link examples and focused boundary checks."""
import argparse
import json
from pathlib import Path
import runpy

HERE=Path(__file__).resolve().parent
API=runpy.run_path(str(HERE/'compose.py'))


def program(body):
    return (b'with Silver_IO;\nprocedure Main is\n pragma SPARK_Mode (On);\n'
            b'begin\n'+body+b'\nend Main;\n')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    context=API['Context']()
    sources={
        'Hello':program(b'Silver_IO.Put_Line ("Hello");'),
        'literal_8192':program(b'Silver_IO.Put ("'+b'a'*8192+b'");'),
        'calls_5000':program(b'\n'.join([b'Silver_IO.Put ("a");']*5000)),
    }
    examples={k:API['evaluate'](raw,context) for k,raw in sources.items()}
    assert examples['Hello']['selected_literal_assembler_and_linker_representation_fits']
    assert examples['literal_8192']['selected_literal_assembler_and_linker_representation_fits']
    assert examples['calls_5000']['assembler_storage_fits']
    assert examples['calls_5000']['link']['failed_sufficient_checks']==[
        'fixed_signed_relocation_reach']
    # Names and ELF section structure stay bounded across literal byte growth;
    # logical data still increases the original and rewritten payload join.
    hello, large=(examples[n]['link'] for n in ('Hello','literal_8192'))
    assert hello['counts']==large['counts']
    assert large['Main_original_section_bytes']-hello['Main_original_section_bytes']==8192-5
    assert large['payload_union_bytes']-hello['payload_union_bytes']==8192-5
    # The public entry point always derives counts from the entire source.
    invalid=[b'Silver_IO.Put ("a");',program(b'for I in 1..2 loop null; end loop;'),
             program(b'Silver_IO.Put ("a");').replace(b'pragma SPARK_Mode (On);',b'')]
    rejected=0
    for raw in invalid:
        try:
            API['evaluate'](raw,context)
        except (ValueError,AssertionError):
            rejected+=1
    assert rejected==len(invalid)
    mixed=API['evaluate'](program(b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("a""b");'),context)
    assert mixed['counts']==dict(calls=2,nulls=1,decoded_bytes=3,maximum_literal_length=3)
    assert mixed['selected_literal_assembler_and_linker_representation_fits']
    page=API['evaluate'](sources['Hello'],context,host_page_bytes=65536)
    assert page['selected_literal_assembler_and_linker_representation_fits']
    assert page['link']['layout']==hello['layout']
    assert page['link']['individual_request_upper_bytes']['input_mmap_span']==hello['payload_union_bytes']+131072
    huge_page=API['evaluate'](sources['Hello'],context,host_page_bytes=2**62)
    assert not huge_page['selected_literal_assembler_and_linker_representation_fits']
    assert 'host_page_arithmetic' in huge_page['link']['failed_sufficient_checks']
    # Replay exact sign-boundary comparisons with the same computed payload
    # formulas through source-recognized inputs near the first failure.
    lo,hi=1,5000
    while lo+1<hi:
        mid=(lo+hi)//2
        r=API['evaluate'](program(b'\n'.join([b'Silver_IO.Put ("a");']*mid)),context)
        if r['selected_literal_assembler_and_linker_representation_fits']:
            lo=mid
        else:
            hi=mid
    boundary={}
    for c in (lo,hi):
        r=API['evaluate'](program(b'\n'.join([b'Silver_IO.Put ("a");']*c)),context)
        boundary[str(c)]=dict(common_signed32=r['link']['relocation_bounds']['common_signed32'],
            failed_sufficient_checks=r['link']['failed_sufficient_checks'])
    assert not boundary[str(lo)]['failed_sufficient_checks']
    assert boundary[str(hi)]['failed_sufficient_checks']==['fixed_signed_relocation_reach']
    output=dict(scope='Callable literal assembler/output-link representation research predicate',
        prior_inputs_verified=context.input_count,source_files_verified=len(context.sources),
        fixed_generated_projection=context.fixed_projection,examples=examples,
        focused_checks=dict(invalid_complete_sources_rejected=rejected,
            mixed_empty_escaped_and_null=True,host_page_parameter_independent_of_layout=True,
            oversized_host_page_rejected=True,adjacent_unit_literal_call_boundary=boundary),
        independent_review_accepted=False,whole_literal_pipeline_capacity_established=False,
        aggregate_RAM_gate=False,native_tool_executions=0)
    args.output.write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps({k:dict(fits=v['selected_literal_assembler_and_linker_representation_fits'],
              failed=v['link']['failed_sufficient_checks'],
              common_signed32=v['link']['relocation_bounds']['common_signed32'])
                      for k,v in examples.items()}))


if __name__=='__main__':
    main()

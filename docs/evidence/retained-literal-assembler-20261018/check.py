#!/usr/bin/env python3
"""Replay source counting, independent sums and finite-field boundaries offline."""
import argparse
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    m = runpy.run_path(str(HERE/'compose.py'))
    context = m['Context']()
    shell = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    tail = b'\nend Main;\n'
    cases = []
    for name,body,expected in [
        ('hello',b'Silver_IO.Put_Line ("Hello, world!");',(1,0,13)),
        ('empty_and_quote',b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("a""b");',(2,1,3)),
        ('large_literal',b'Silver_IO.Put ("'+b'x'*8192+b'");',(1,0,8192)),
        ('5000_calls',b'Silver_IO.Put ("x");\n'*5000,(5000,0,5000)),
        ('last_sufficient_region',b'Silver_IO.Put ("");\n'*32767,(32767,0,0)),
        ('region_exceeded',b'Silver_IO.Put ("");\n'*32768,(32768,0,0)),
    ]:
        result=m['evaluate'](shell+body+tail,context)
        counts=result['counts']
        assert (counts['calls'],counts['nulls'],counts['decoded_bytes']) == expected
        assert result['local_interface_fits'] == (name != 'region_exceeded')
        assert not result['whole_literal_pipeline_capacity_established']
        c,n,w=expected
        # Compare independent producer/consumer decompositions with the transfer.
        assert result['text_bytes_upper'] == 2*c*7+4*c*3+c*5+(4*n+14)+8
        assert result['GAS']['fragment_allocations_upper'] == (
            2*result['GAS']['reservation_bytes_upper'] + 12 + 14+9+1+11+2*c+1 + 14)
        assert result['ELF']['symbols_including_null_upper'] == result['GAS']['output_symbols_upper']+10+1
        assert result['ELF']['object_bytes_upper'] == sum(result['ELF']['file_parts'].values())
        cases.append(dict(case=name,result=result))
    hello=cases[0]['result']
    assert hello['GAS']['rodata_bytes_upper']==35
    assert hello['ELF']['object_bytes_upper']==17592
    for raw in (shell+b'null;'+tail,shell+b'Silver_IO.Put ("a" & "b");'+tail,
                b'\v'+shell+b'Silver_IO.Put ("x");'+tail):
        try: m['evaluate'](raw,context)
        except ValueError: cases.append(dict(case='outside_family_rejected'))
        else: raise AssertionError('out-of-family source admitted')
    n=(m['I32']-22-31)//4
    assert m['interface'](1,n,0,0)['local_checks']['text_and_CFI']
    assert not m['interface'](1,n+1,0,0)['local_checks']['text_and_CFI']
    cases.append(dict(case='signed_text_boundary',last_nulls=n))
    result=dict(all_checks_pass=True,case_count=len(cases),cases=cases,
                verified_inputs=context.input_count,verified_sources=context.source_count,
                native_tool_executions=0,whole_literal_pipeline_capacity_established=False)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='cases'}))


if __name__=='__main__':
    main()

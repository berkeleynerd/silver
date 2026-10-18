#!/usr/bin/env python3
"""Focused ALI source/interface checks, without native execution."""
import argparse
import json
from pathlib import Path
import runpy

HERE=Path(__file__).resolve().parent
api=runpy.run_path(str(HERE/'compose.py'))
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--ada-root',type=Path,required=True)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args()
context=api['Context'](args.ada_root)
def program(body):
    return b'with Silver_IO;\nprocedure Main is\npragma SPARK_Mode (On);\nbegin\n'+body+b'\nend Main;\n'
rows=[]
sources=[('hello',(api['REPO']/'samples/hello_world.adb').read_bytes()),
    ('both_calls_empty_and_quotes',program(b'Silver_IO.Put ("a""b"); null; Silver_IO.Put_Line ("");')),
    ('large_literal',program(b'Silver_IO.Put ("'+b'a'*8192+b'");')),
    ('repeated_calls',program(b'Silver_IO.Put ("a");\n'*5000)),
    ('case_and_CR_comments',program(b'-- Put_Line ("ignored");\rSILVER_IO.pUt ("a");'))]
base=None
for name,raw in sources:
    r=api['evaluate'](raw,context)
    assert r['selected_Main_ALI_interface_fits'] and not r['whole_literal_pipeline_capacity_established']
    selected=(r['Main_invocation_interface'],r['Main_ALI_reader_bytes_including_EOF_upper'])
    if base is None: base=selected
    assert selected==base
    rows.append(dict(case=name,calls=r['source_counts']['output_calls'],
        reader_bytes=r['Main_ALI_reader_bytes_including_EOF_upper'],fits=True))
raw=sources[0][1]
for p in (976,977,2**31-1):
    r=api['evaluate'](raw,context,p)
    rows.append(dict(case='path_'+str(p),conditions=r['conditions'],
                     fits=r['selected_Main_ALI_interface_fits']))
assert rows[-3]['fits'] and not rows[-2]['fits'] and not rows[-1]['fits']
for name,raw in [('nonliteral',program(b'Silver_IO.Put (Unknown);')),
                 ('forbidden_VT',sources[0][1]+b'\v')]:
    try: api['evaluate'](raw,context)
    except ValueError: rows.append(dict(case=name,rejected=True))
    else: raise AssertionError(name)
r=api['evaluate'](program(b'--'+b'a'*32767+b'\nSilver_IO.Put ("a");'),context)
assert not r['conditions']['source_byte_and_coordinate_representations']
rows.append(dict(case='physical_column_overflow',conditions=r['conditions']))
result=dict(cases=rows,all_checks_pass=True,native_tool_executions=0)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(cases=len(rows),all_checks_pass=True,native_tool_executions=0)))

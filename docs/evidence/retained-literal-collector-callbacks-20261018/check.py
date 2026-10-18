#!/usr/bin/env python3
"""Check source selection and reject corrupted callback/frontier interfaces."""
import argparse
import copy
import json
from pathlib import Path
import time
from derive import Context, evaluate

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--ada-root', type=Path, required=True)
parser.add_argument('--plugin-include', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
start = time.monotonic()
context = Context(args.gcc_root, args.ada_root, args.plugin_include)
prefix = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin '
suffix = b' end Main;'
rows = []
for name, body in [
    ('empty_literal', b'Silver_IO.Put ("");'),
    ('both_imports', b'Silver_IO.Put_Line ("a"); null; Silver_IO.Put ("b");'),
    ('repeated_calls', b'Silver_IO.Put ("x");'*128),
    ('large_literal', b'Silver_IO.Put ("'+b'x'*8192+b'");'),
    ('comment_variation', b'-- comment\rSilver_IO.Put_Line ("a""b");')]:
    result = evaluate(prefix+body+suffix, context)
    assert result['collector_callback_additional_GGC_events'] == 0
    assert result['total_GGC_events'] is None
    assert result['collector_page_and_finalizer_backing'] is None
    assert not result['whole_literal_pipeline_capacity_established']
    rows.append(dict(name=name, passed=True))

def rejected(name, callback):
    try:
        callback()
    except ValueError:
        rows.append(dict(name=name, passed=True))
    else:
        raise AssertionError('invalid source/interface accepted: '+name)

for name, raw in [
    ('null_family_not_substituted', prefix+b'null;'+suffix),
    ('variable_argument', prefix+b'Silver_IO.Put (X);'+suffix),
    ('declaration', prefix.replace(b'begin',b'X : Integer; begin')+b'Silver_IO.Put ("x");'+suffix),
    ('FF_alphabet', prefix+b'--\f\nSilver_IO.Put ("x");'+suffix)]:
    rejected(name, lambda raw=raw: evaluate(raw,context))

raw = prefix+b'Silver_IO.Put ("x");'+suffix
for name, member, path, value in [
    ('frontier_open','frontier',('selected_generated_FUNCTION_DECL_body_frontier_closed',),False),
    ('extra_body','frontier',('other_generated_FUNCTION_DECL_bodies',),1),
    ('elaboration_gimplifies','frontier',('empty_elaboration','initial_gimplifications'),1),
    ('helper_RTL','frontier',('cold_string_size_helpers','RTL_expansions'),1),
    ('different_parameters','cold',('size_function_parameter_counts',),[3,2]),
    ('different_result','cold',('size_function_return_precision_bits',),[256,64]),
    ('allocating_finalizer','old',('selected_finalizer_effects','additional_GGC_events'),1),
    ('erased_marker_backing','old',('selected_mark_and_cache_effects','value_expression_marker','individual_ordinary_hash_backing_bytes'),0)]:
    altered=copy.copy(context)
    setattr(altered,member,copy.deepcopy(getattr(context,member)))
    item=getattr(altered,member)
    for key in path[:-1]:
        item=item[key]
    item[path[-1]]=value
    rejected(name,lambda altered=altered:evaluate(raw,altered))

result=dict(cases=rows,all_passed=True,input_identities_verified=context.inputs_verified,
            native_tool_executions=0,elapsed_seconds=time.monotonic()-start)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(cases=len(rows),passed=True,elapsed_seconds=result['elapsed_seconds'])))

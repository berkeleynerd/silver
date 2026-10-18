#!/usr/bin/env python3
"""Check shared source counters, descriptor binding and the honest open verdict."""
import argparse
import copy
import importlib.util
import json
from pathlib import Path
import tempfile

HERE = Path(__file__).resolve().parent


def main():
    spec=importlib.util.spec_from_file_location('literal_pipeline',HERE/'compose.py')
    module=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    parser=argparse.ArgumentParser(description=__doc__)
    module.arguments(parser)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    context=module.Context(args.gcc_root,args.ada_root,args.plugin_include)
    fixture=module.read(HERE/'fixture.json')
    fixture['source']=str((HERE/fixture['source']).resolve())
    fixture['shared_inputs']={role:str((HERE/path).resolve())
                              for role,path in fixture['shared_inputs'].items()}
    original=Path(fixture['source']).read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    tail=b'\nend Main;\n'
    rows=[]
    with tempfile.TemporaryDirectory(prefix='silver-literal-aggregate-check-') as temporary:
        root=Path(temporary)
        descriptor, source=root/'descriptor.json',root/'main.adb'

        def evaluate(raw, changed=None):
            descriptor.write_text(json.dumps(changed or fixture))
            source.write_bytes(raw)
            result=module.evaluate(descriptor,context,source)
            assert not result['whole_literal_pipeline_capacity_established']
            assert result['next_repair']=='native_remaining_lifetime_and_collector'
            assert result['native_tool_executions']==0
            return result

        variants=[
            ('retained',original,1,0,13),
            ('case_CRLF',original.upper().replace(b'\n',b'\r\n'),1,0,13),
            ('equal_literals_are_distinct',shell+b'Silver_IO.Put ("x");\nnull;\nSilver_IO.Put_Line ("x");'+tail,2,1,2),
            ('quotes_empty_and_comment',shell+b'-- Silver_IO.Put ("ignored");\nSilver_IO.Put ("a""b"); Silver_IO.Put_Line ("");'+tail,2,0,3),
            ('comments_above_old_cap',b'-- ordinary comment\n'*300+original,1,0,13),
            ('literal_above_old_cap',shell+b'Silver_IO.Put ("'+b'a'*8192+b'");'+tail,1,0,8192),
            ('5000_calls',shell+b'Silver_IO.Put ("x");\n'*5000+tail,5000,0,5000),
        ]
        for name,raw,c,n,characters in variants:
            result=evaluate(raw)
            counts=result['source_counts']
            assert (counts['output_calls'],counts['null_statements'],counts['decoded_literal_bytes']) == (c,n,characters)
            assert result['Why_core']['K']==result['Why_core']['K_literal']==c
            assert result['Why_source_counts']['H_chars']==characters
            assert result['Why_core']['V']==2*c
            assert result['RTL_shape']['first_unused_pseudo_number_upper']==99+5*c
            pools=result['native_pool_lifetime']
            assert pools['source_input'] == dict(
                bounds_finalize_calls_upper=c,pool_entries_upper=2*c,insertion_capable_pool_lookups_upper=3*c)
            assert pools['incoming_tree_pool']['live_upper']==39257
            assert pools['incoming_tree_pool']['capacity_upper']==131071
            assert pools['tree_pool']['live_upper']==39257+2*c
            assert pools['tree_pool']['replacement_requests_upper']==3*c
            assert pools['symbols']['next_uid_upper']==c+5
            assert pools['bounds_lifecycle']['initializer_outgoing_references']==0
            assert pools['additional_GGC_request_events_upper']==5*c+5
            assert pools['named_consumer_closed']
            assert 'native_varpool_and_shared_tree_pool' not in result['open_joins']
            expected=name not in ('literal_above_old_cap','5000_calls')
            assert result['evaluated_predicates_pass']==expected,(name,result['failed_predicates'])
            if not expected:
                assert result['failed_predicates']==['Why_core']
            rows.append(dict(case=name,source_bytes=len(raw),calls=c,nulls=n,decoded_characters=characters,
                             evaluated_predicates_pass=expected,
                             failed_predicates=result['failed_predicates'],
                             Why_JSON_byte_bound=result['Why_core']['json_bytes'],
                             whole_pipeline_closed=False))
        result=evaluate(b'--'+b'x'*32764+b'\n'+original)
        assert 'Main_expanded_columns' in result['failed_predicates']
        rows.append(dict(case='physical_column_overflow',failed_predicates=result['failed_predicates']))
        changed=copy.deepcopy(fixture);changed['complete_path_bound']=16
        result=evaluate(original,changed)
        assert 'shared_launch_paths' in result['failed_predicates']
        rows.append(dict(case='path_envelope_overflow',failed_predicates=result['failed_predicates']))

        rejections=[('VT_rejected',b'\v'+original,fixture),
                    ('concat_rejected',shell+b'Silver_IO.Put ("a" & "b");'+tail,fixture),
                    ('name_actual_rejected',shell+b'Silver_IO.Put (X);'+tail,fixture),
                    ('no_output_rejected',shell+b'null;'+tail,fixture)]
        changed=copy.deepcopy(fixture);changed['launch']['native_options'].remove('-fsplit-wide-types')
        rejections.append(('split_option_required',original,changed))
        changed=copy.deepcopy(fixture);changed['launch']['phase2_Main']='/tmp/different/main.adb'
        rejections.append(('common_Main_required',original,changed))
        bad=root/'bad-input';bad.write_bytes(b'changed input\n')
        for role in ('configuration','System','silver_io.ads'):
            changed=copy.deepcopy(fixture);changed['shared_inputs'][role]=str(bad)
            rejections.append((role+'_mismatch',original,changed))
        for name,raw,changed in rejections:
            try:
                evaluate(raw,changed)
            except ValueError as error:
                rows.append(dict(case=name,rejected=str(error)))
            else:
                raise AssertionError(name)
        boundary=(1073741823-context.pool_seed)//2
        for c,expected in ((boundary,True),(boundary+1,False)):
            pools=module.native_pool_lifetime(c,context)
            assert pools['named_consumer_closed']==expected
            assert pools['local_representation_checks']['tree_pool_live_and_probe']==expected
            rows.append(dict(case='tree_pool_prime_region_'+str(c),calls=c,
                             capacity=pools['tree_pool']['capacity_upper'],
                             named_consumer_closed=expected))
        # Expansion happens before lookup equality: even an existing key
        # at the first 13-slot load boundary incurs a backing request.
        size,occupied=13,10
        assert 3*size <= 4*occupied
        replacement=next(p for p in context.primes if p >= 2*occupied)
        assert replacement==31 and occupied==10
        rows.append(dict(case='pre_hit_expansion',before_slots=size,
                         after_slots=replacement,fresh_entries=0))
    result=dict(case_count=len(rows),cases=rows,all_checks_pass=True,
                native_tool_executions=0,whole_literal_pipeline_capacity_established=False)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(cases=len(rows),all_checks_pass=True,native_tool_executions=0)))


if __name__=='__main__':
    main()

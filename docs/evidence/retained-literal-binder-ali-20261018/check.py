#!/usr/bin/env python3
"""Reconcile the literal/fixed consumer join without invoking native tools."""
import argparse
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
api = runpy.run_path(str(HERE/'compose.py'))


def program(body):
    return b'with Silver_IO;\nprocedure Main is\npragma SPARK_Mode (On);\nbegin\n'+body+b'\nend Main;\n'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    context = api['Context'](args.ada_root)
    cases = []
    sources = [('hello', (api['REPO']/'samples/hello_world.adb').read_bytes()),
        ('large_literal', program(b'Silver_IO.Put ("'+b'a'*8192+b'");')),
        ('repeated_calls', program(b'Silver_IO.Put ("a");\n'*5000)),
        ('both_calls_empty_and_quotes', program(b'Silver_IO.Put ("a""b"); null; Silver_IO.Put_Line ("");')),
        ('case_and_CR_comments', program(b'-- Put_Line ("ignored");\rSILVER_IO.pUt ("a");'))]
    baseline = None
    for name, raw in sources:
        result = api['evaluate'](raw, context)
        assert result['selected_ALI_consumer_local_interfaces_fit']
        assert not result['whole_binder_or_parent_capacity_established']
        assert not result['parent_GPRbuild_DW_reader_capacity_established']
        assert not result['whole_literal_pipeline_capacity_established']
        assert not result['aggregate_RAM_gate']
        assert result['native_tool_executions'] == 0
        projection = {k: result[k] for k in ('native_parser_tables', 'native_signature_map',
            'native_raw_buffers', 'native_parser_name_contribution', 'native_argument_strings',
            'Gprbind_Main_reader')}
        if baseline is None:
            baseline = projection
        assert projection == baseline
        counts = {k: result['source_counts'][k] for k in ('output_calls', 'Put', 'Put_Line',
            'null_statements', 'decoded_literal_bytes', 'maximum_literal_length')}
        cases.append(dict(case=name, source=result['source'], source_counts=counts,
                          selected_ALI_consumer_local_interfaces_fit=True))
    assert baseline['native_parser_tables']['Units']['capacities'] == [100, 300]
    assert {k: v['demand_upper'] for k, v in baseline['native_parser_tables'].items()} == dict(
        ALIs=83, Units=180, Withs=2220, Args=833, Sdep=1048, Source=204,
        Invocation_Constructs=1290, Invocation_Relations=367, Invocation_Signatures=1290,
        Linker_Options=2, Notes=8, No_Deps=0)
    assert baseline['native_signature_map']['nodes_and_coexisting_buckets_bytes_upper'] == 178560
    assert baseline['native_parser_name_contribution']['entry_events_upper'] == 16611
    assert baseline['native_parser_name_contribution']['character_slots_including_NUL_upper'] == 10229999
    assert baseline['native_argument_strings'] == dict(count=833, payload_bytes=6089, maximum_payload_bytes=27)
    assert baseline['Gprbind_Main_reader']['name_entry_events_upper'] == 84
    assert baseline['Gprbind_Main_reader']['name_value_bytes_upper'] == 24381
    assert not baseline['native_parser_name_contribution']['complete_pool_backing_established']
    assert not baseline['Gprbind_Main_reader']['complete_name_vector_backing_established']
    cases.append(dict(case='consumer_join_expected_totals', matches=True))
    raw = sources[0][1]
    for path, expected in ((976, True), (977, False), (2**31-1, False)):
        result = api['evaluate'](raw, context, path)
        assert result['selected_ALI_consumer_local_interfaces_fit'] == expected
        cases.append(dict(case='path_'+str(path), conditions=result['conditions'], fits=expected))
    overflow = api['evaluate'](program(b'--'+b'a'*32767+b'\nSilver_IO.Put ("a");'), context)
    assert not overflow['selected_ALI_consumer_local_interfaces_fit']
    cases.append(dict(case='physical_column_overflow', conditions=overflow['conditions'], fits=False))
    for name, invalid in [('nonliteral', program(b'Silver_IO.Put (Unknown);')),
                          ('forbidden_VT', raw+b'\v'), ('negative_path', None)]:
        try:
            api['evaluate'](raw if invalid is None else invalid, context, -1 if invalid is None else 512)
        except ValueError:
            cases.append(dict(case=name, rejected=True))
        else:
            raise AssertionError(name)
    # The relational row adds seven name events but no new signature here.
    assert context.fixed['invocation_records']['r'] == 6
    assert context.fixed['distinct_signatures'] == context.fixed['invocation_records']['c'] == 1271
    assert context.fixed['parser_name_entry_events'] == 8779
    assert len(context.fixed['subunit_names']) == 7
    cases.append(dict(case='fixed_relation_names_and_signature_reuse', matches=True))
    result = dict(cases=cases, consumer_projection_at_P512=baseline, fixed_closure=context.fixed,
        all_checks_pass=True, native_tool_executions=0, whole_binder_or_parent_capacity_established=False,
        whole_literal_pipeline_capacity_established=False)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(cases=len(cases), all_checks_pass=True, native_tool_executions=0)))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Check the local parent DW interface without executing native tools."""
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
    sources = [('hello', (api['REPO']/'samples/hello_world.adb').read_bytes()),
        ('large_literal', program(b'Silver_IO.Put ("'+b'a'*8192+b'");')),
        ('repeated_calls', program(b'Silver_IO.Put ("a");\n'*5000)),
        ('both_calls_empty_and_quotes', program(b'Silver_IO.Put ("a""b"); null; Silver_IO.Put_Line ("");')),
        ('case_and_CR_comments', program(b'-- Put_Line ("ignored");\rSILVER_IO.pUt ("a");'))]
    cases, baseline = [], None
    for label, raw in sources:
        r = api['evaluate'](raw, context)
        assert r['selected_parent_DW_reader_local_interface_fits']
        assert not r['whole_native_parent_capacity_established']
        assert not r['whole_literal_pipeline_capacity_established']
        assert not r['complete_GPR_Names_backing_established']
        assert not r['output_parent_source_buffers_established']
        assert not r['fixed_child_regeneration_correspondence_established']
        assert not r['output_launch_descriptor_materialized']
        assert not r['aggregate_RAM_gate'] and r['native_tool_executions'] == 0
        projection = {k: r[k] for k in ('schedule', 'parser_tables_per_scan',
            'table_append_counts_cumulative_upper', 'parser_tables_without_inter_scan_reset',
            'raw_buffers', 'parser_name_contribution', 'fixed_native_stored_switch_envelope')}
        if baseline is None:
            baseline = projection
        assert projection == baseline
        counts = {k: r['source_counts'][k] for k in ('output_calls', 'Put', 'Put_Line',
            'null_statements', 'decoded_literal_bytes', 'maximum_literal_length')}
        cases.append(dict(case=label, source=r['source'], source_counts=counts,
                          selected_parent_DW_reader_local_interface_fits=True))
    assert baseline['table_append_counts_cumulative_upper'] == dict(ALIs=3, Units=44, Withs=1694, Sdep=99, Args=0)
    assert {k: t['demand_upper'] for k, t in baseline['parser_tables_per_scan'].items()} == dict(
        ALIs=1, Units=41, Withs=1681, Sdep=41, Args=0)
    assert {k: t['capacities'] for k, t in baseline['parser_tables_per_scan'].items()} == dict(
        ALIs=[500], Units=[100], Withs=[5000], Sdep=[5000], Args=[])
    assert baseline['parser_name_contribution']['entry_events_upper'] == 5470
    assert baseline['parser_name_contribution']['value_bytes_upper'] == 6225037
    assert baseline['raw_buffers'] == dict(Main_including_EOF_upper=2152397,
        fixed_including_EOF_upper={'silver_io.ali': 4501, 'silver_output_libc.ali': 2991},
        peak_local_reader_bytes_upper=2152397, cumulative_local_reader_bytes_upper=2159889,
        cumulative_is_not_peak_live_or_RAM_gate=True)
    cases.append(dict(case='expected_local_totals', matches=True))
    for path, expected in ((976, True), (977, False), (2**31-1, False)):
        r = api['evaluate'](sources[0][1], context, path)
        assert r['selected_parent_DW_reader_local_interface_fits'] == expected
        cases.append(dict(case='path_'+str(path), conditions=r['conditions'], fits=expected))
    r = api['evaluate'](program(b'--'+b'a'*32767+b'\nSilver_IO.Put ("a");'), context)
    assert not r['selected_parent_DW_reader_local_interface_fits']
    cases.append(dict(case='physical_column_overflow', conditions=r['conditions'], fits=False))
    for label, raw, path in [('nonliteral', program(b'Silver_IO.Put (Unknown);'), 512),
                              ('forbidden_VT', sources[0][1]+b'\v', 512),
                              ('negative_path', sources[0][1], -1)]:
        try:
            api['evaluate'](raw, context, path)
        except ValueError:
            cases.append(dict(case=label, rejected=True))
        else:
            raise AssertionError(label)
    for name, raw in context.fixed_raw.items():
        original = api['fixed_scan'](raw)
        changed_A = raw.replace(b'P ZX', b'A -fsplit-wide-types\nP ZX', 1)
        projection_keys = ['table_demands_upper', 'consumed_name_row_bytes_upper',
            'parser_name_entry_events_upper', 'parser_name_value_bytes_upper',
            'withed_units', 'invocation_signature_records_consumed', 'Xref_records_consumed']
        assert api['fixed_scan'](changed_A)['complete_bytes'] == len(raw)+21
        assert api['fixed_scan'](changed_A)['non_A_complete_bytes'] == original['non_A_complete_bytes']
        changed_G = raw.replace(b'G a e', b'G r nonsense [name scope '+b'9'*5000+b' 1 none]', 1)
        no_Xref = raw[:raw.index(b'X ')]
        for changed in (changed_A, changed_G, no_Xref):
            actual = api['fixed_scan'](changed)
            assert {k: actual[k] for k in projection_keys} == {k: original[k] for k in projection_keys}
        w = api['fixed_scan'](raw, 'W')
        assert w['table_demands_upper']['Sdep'] == 0
        assert w['table_demands_upper']['Withs'] == original['table_demands_upper']['Withs']
        assert w['table_demands_upper']['Args'] == 0
        assert original['table_demands_upper']['Withs'] == (
            original['records_before_X'].get('W', 0)+original['records_before_X'].get('Z', 0))
        cases.append(dict(case=name+'_policy_and_ignored_records', matches=True,
            huge_ignored_G_coordinate_allocated_signature=False, added_split_A_raw_bytes=21,
            raw_charge_is_separate_from_parser_projection=True))
    # Check actual retained project metadata only as an inventory witness. It
    # is not a successful exact literal/indexed/split launch descriptor.
    project = context.artifacts['indexed/program.gpr']
    assert b'"main.adb", "silver_io.ads", "silver_io.adb", "silver_output_libc.ads",' in project
    assert b'library' not in project.lower() and b'with ' not in project.lower()
    io_names = context.fixed['silver_io.ali']['withed_units']
    libc_names = context.fixed['silver_output_libc.ali']['withed_units']
    assert 'silver_output_libc%s' in io_names
    assert all(not x.startswith('silver_') for x in libc_names)
    assert all(not x.startswith(('silver_arguments', 'silver_runtime')) for x in io_names+libc_names)
    cases.append(dict(case='retained_Silver_edges_and_project_inventory', matches=True,
        actual_fresh_literal_launch_established=False))
    result = dict(cases=cases, local_projection_at_P512=baseline, all_checks_pass=True,
        native_tool_executions=0, whole_native_parent_capacity_established=False,
        whole_literal_pipeline_capacity_established=False)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(cases=len(cases), all_checks_pass=True, native_tool_executions=0)))


if __name__ == '__main__':
    main()

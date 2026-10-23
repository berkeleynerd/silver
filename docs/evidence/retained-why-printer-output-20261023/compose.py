"""Evaluate the new conditional interface, without replaying predecessors."""
import json
from pathlib import Path
from transfer import request, MAX_INT, MAX_STRING

HERE = Path(__file__).resolve().parent


def evaluate(census):
    cases = []
    for row in census['cases']:
        drivers = {}
        for name, source_bytes in census['driver_expanded_source_bytes'].items():
            value = request(row['dimensions'], source_bytes,
                            census['maximum_quoted_source_token_bytes'],
                            row['raw_name_bytes'], row['raw_comment_name_bytes'])
            assert value['printed_name_bytes_upper'] == row['printed_name_bytes_provider']
            drivers[name] = value
        cases.append(dict(case=row['case'], drivers=drivers))
    return dict(scope='conditional selected per-request output and native Format/Buffer operands',
                base=census['base'],
                providers=dict(raw_names=census['raw_names_provider'],
                               hsattr=census['hsattr_provider']),
                selected_max_int=MAX_INT, selected_max_string_length=MAX_STRING,
                global_escape_budget=2, save_entering_callbacks=2, saves_upper=3,
                budget_renewed=False, cases=cases,
                source_argument='author source reasoning, pending independent review',
                source_semantics_machine_checked=False,
                fresh_drain_requires_no_system_scope_break=True,
                all_scoped_numeric_guards_pass=all(
                    all(value[owner]['guards'].values())
                    for case in cases for value in case['drivers'].values()
                    for owner in ('request_formatter','request_buffer',
                                  'each_temporary_name_formatter','each_temporary_name_buffer',
                                  'each_annotation_formatter','each_annotation_buffer')),
                private_maps_native_layout_and_stack_closed=False,
                shared_stderr_whole_interval_closed=False,
                whole_printer_capacity=False, whole_process_capacity=False,
                aggregate_RAM_gate=False)


if __name__ == '__main__':
    result = evaluate(json.loads((HERE/'census.json').read_text()))
    (HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps(dict(cases=len(result['cases']),
                         all_scoped_numeric_guards_pass=result['all_scoped_numeric_guards_pass'])))

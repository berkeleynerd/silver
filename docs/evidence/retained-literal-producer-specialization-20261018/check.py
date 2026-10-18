#!/usr/bin/env python3
"""Offline grammar, source-identity and producer-specialization checks."""
import argparse
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from compose import Context, HERE, REPO, evaluate


def source(body):
    return (b'with Silver_IO;\nprocedure Main is\npragma SPARK_Mode (On);\n'
            b'begin\n' + body + b'end Main;\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=HERE / 'result.json')
    args = parser.parse_args()
    context = Context()
    checks, cases = [], []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    inputs = [
        ('hello_world', (REPO / 'samples/hello_world.adb').read_bytes()),
        ('empty_string', source(b'Silver_IO.Put ("");\n')),
        ('escaped_quotes', source(b'Silver_IO.Put_Line ("a""b");\n')),
        ('mixed_sequence', source(b'null;\nSilver_IO.Put ("a");\n'
                                  b'Silver_IO.Put_Line ("b");\nnull;\n')),
        ('literal_8192', source(b'Silver_IO.Put ("' + b'a'*8192 + b'");\n')),
        ('calls_5000', source(b'Silver_IO.Put ("a");\n'*5000)),
        ('comments_above_4096', source(b'--' + b'x'*5000 + b'\nSilver_IO.Put ("a");\n')),
        ('case_and_CRLF', source(b'SILVER_IO.PUT ("a");\n').upper().replace(b'\n', b'\r\n'))]
    for name, raw in inputs:
        result = evaluate(raw, context)
        check(name + '_selected_core_fits', result['literal_Main_core_fits'])
        check(name + '_no_Main_emission', result['Main_gnat_json_files'] == 0 and
              result['Main_gnat_json_bytes'] == 0 and result['Main_Why3_launches'] == 0)
        check(name + '_other_obligations_retained',
              result['fixed_library_Why3_inputs'] == 5 and
              result['fixed_library_capacity_still_required'] and
              result['native_frontend_and_flow_capacity_still_required'] and
              result['final_spark_report_capacity_still_required'] and
              not result['whole_literal_pipeline_capacity_established'])
        if name in ('literal_8192', 'calls_5000'):
            check(name + '_general_JSON_bound_would_reject',
                  not result['general_core']['producer_core_fits'] and
                  result['hypothetical_general_JSON_bytes'] > 2147483646)
        cases.append(dict(name=name, source=result['source'],
            calls=result['source_counts']['output_calls'],
            literal_bytes=result['source_counts']['decoded_literal_bytes'],
            general_core_fits=result['general_core']['producer_core_fits'],
            literal_Main_core_fits=result['literal_Main_core_fits'],
            hypothetical_general_JSON_bytes=result['hypothetical_general_JSON_bytes'],
            actual_Main_JSON_bytes=result['Main_gnat_json_bytes'],
            retained_conditions=result['conditions']))

    rejected = {
        'concat': source(b'Silver_IO.Put ("a" & "b");\n'),
        'variable_actual': source(b'Silver_IO.Put (A);\n'),
        'loop': source(b'for I in 1 .. 2 loop Silver_IO.Put ("a"); end loop;\n'),
        'branch': source(b'if True then Silver_IO.Put ("a"); end if;\n'),
        'null_only': source(b'null;\n'),
        'trailing_tokens': source(b'Silver_IO.Put ("a");\n') + b'null;',
        'vertical_tab': source(b'\x0bSilver_IO.Put ("a");\n'),
        'form_feed': source(b'\x0cSilver_IO.Put ("a");\n'),
        'non_ASCII_literal': source(b'Silver_IO.Put ("\xff");\n')}
    for name, raw in rejected.items():
        try:
            evaluate(raw, context)
        except ValueError:
            check(name + '_outside_specialization', True)
        else:
            raise AssertionError(name + ' was accepted by specialization')

    large_path = evaluate(inputs[0][1], context, path_bytes=600000000)
    check('construction_string_envelope_still_rejects',
          not large_path['literal_Main_core_fits'] and
          'retained_string_length_envelope' in large_path['failed_predicates'])
    for value in (True, -1, 1.5):
        try:
            evaluate(inputs[0][1], context, path_bytes=value)
        except ValueError:
            check('invalid_path_bound_' + repr(value), True)
        else:
            raise AssertionError('invalid path bound accepted')
    output = dict(scope='Literal Main producer core only; source argument and premises in linked research record',
        checks=checks, checks_passed=len(checks), cases=cases,
        verified_local_inputs=context.verified_local_inputs,
        verified_external_sources=context.verified_external_sources,
        native_tool_executions=0, whole_literal_pipeline_capacity_established=False,
        production_admission_changed=False)
    args.output.write_text(json.dumps(output, indent=2) + '\n')
    print(json.dumps(dict(checks_passed=len(checks), cases=len(cases),
                         native_tool_executions=0, whole_literal_pipeline_capacity_established=False)))


if __name__ == '__main__':
    main()

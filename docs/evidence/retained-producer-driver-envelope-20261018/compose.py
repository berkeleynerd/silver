#!/usr/bin/env python3
"""Finite selected-driver dispatch envelope; no printer-capacity certificate."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verified_inputs():
    """Check the retained manifest's exact dependencies and source joins once."""
    inputs = json.loads((HERE/'inputs.json').read_bytes())
    dependencies = {}
    for path, expected in inputs['dependencies'].items():
        content = (REPO/path).read_bytes()
        assert identity(content) == expected, path
        dependencies[path] = content
    assert identity((HERE/'sources.tar.gz').read_bytes()) == inputs['archive_identity']
    with tarfile.open(HERE/'sources.tar.gz') as archive:
        members = archive.getmembers()
        assert all(m.isfile() for m in members)
        assert len(members) == len({m.name for m in members})
        data = {m.name:archive.extractfile(m).read() for m in members}
    assert {n:identity(b) for n,b in data.items()} == inputs['source_identities']
    previous = HERE.parent/'retained-producer-prefix-composition-20261018/sources.tar.gz'
    with tarfile.open(previous) as archive:
        for name in inputs['why3_sources_joined_to_accepted_archive']:
            assert data[name] == archive.extractfile(name).read(), name
    dimensions = HERE.parent/'retained-producer-prefix-gc-20261018'
    dimensions_inputs = json.loads(dependencies[str((dimensions/'dimensions-inputs.json').relative_to(REPO))])
    float_row = dimensions_inputs['installed_text'][inputs['installed_float_path']]
    with tarfile.open(dimensions/'dimensions-sources.tar.gz') as archive:
        assert data['installed/ieee_float.mlw'] == archive.extractfile(float_row['member']).read()
    prior_path = str((HERE.parent/'retained-producer-fixed-tail-20261018/result.json').relative_to(REPO))
    return inputs, json.loads(dependencies[prior_path]), data['installed/ieee_float.mlw'].decode()


def compose():
    inputs, prior, text = verified_inputs()
    selected = prior['driver_dispatch']
    assert set(selected) == {'cvc5', 'z3', 'altergo'}
    assert {p:len(d['transformations']) for p,d in selected.items()} == {'cvc5':15, 'z3':13, 'altergo':12}
    classified = prior['input_is_valid_registration']
    assert classified['source_filter_join_established'] and classified['raw_tasks'] == 4
    assert classified['registered_toplevel_goals'] == classified['reported_G_bound'] == 1
    rows = []
    for case in prior['cases']:
        raw = case['raw_split_tasks']
        registered = classified['registered_toplevel_goals'] if case['name'] == 'input_is_valid' else raw
        assert 0 <= registered <= raw
        per_driver = {
            p:dict(attempt_entries=registered, prepare_task_entries=registered,
                   configured_transform_applications=registered*len(d['transformations']),
                   print_task_prepared_entries=registered, printer=d['printer'])
            for p,d in selected.items()
        }
        rows.append(dict(name=case['name'], input_sha256=case['input_sha256'],
                         raw_initial_tasks=raw, registered_task_upper=registered,
                         distinct_task_driver_pair_upper=3*registered,
                         configured_transform_application_upper=sum(r['configured_transform_applications'] for r in per_driver.values()),
                         per_driver=per_driver))
    floats = []
    for number,line in enumerate(text.splitlines(),1):
        match = re.search(r'type\s+t\s*=\s*<\s*float\s+(\d+)\s+(\d+)\s*>',line)
        if match:
            eb,sb = map(int,match.groups())
            emax = 2**(eb-1)
            power2 = emax-sb
            assert power2 >= 0
            significand = 2**sb-1
            numerator = significand*2**power2
            pow5 = 0
            while significand % 5 == 0:
                significand //= 5
                pow5 += 1
            assert significand*2**power2*5**pow5 == numerator
            bits = numerator.bit_length()
            # Exact powers, avoiding floating-point logarithm rounding.
            digits=1; threshold=10
            while numerator>=threshold: digits+=1; threshold*=10
            assert 10**(digits-1) <= numerator < 10**digits
            floats.append(dict(line=number,exponent_digits=eb,significand_digits=sb,
                               constructor_significand_bits=sb,constructor_pow2=power2,
                               constructor_pow5=0,normalized_significand_bits=significand.bit_length(),
                               normalized_pow2=power2,normalized_pow5=pow5,expanded_numerator_bits=bits,
                               expanded_numerator_decimal_digits=digits,expanded_denominator=1))
    assert [(f['exponent_digits'],f['significand_digits']) for f in floats] == [(8,24),(11,53),(15,64)]
    result = dict(
        schema=1, platform='linux-x86_64', scope=inputs['scope'],
        accepted_initial_registration=inputs['accepted_initial_registration'],
        cases=rows, sum_raw_initial_tasks=sum(r['raw_initial_tasks'] for r in rows),
        sum_registered_task_upper=sum(r['registered_task_upper'] for r in rows),
        sum_task_driver_pair_upper=sum(r['distinct_task_driver_pair_upper'] for r in rows),
        sum_configured_transform_application_upper=sum(r['configured_transform_application_upper'] for r in rows),
        selected_driver_dispatch=selected,
        finite_dispatch_envelope_established=True,
        bounds_independent_of_solver_answers=True,
        source_control_flow_machine_checked=False,
        source_claims_required=inputs['source_claims'],
        relevant_source_behavior_required=True,
        ordinary_external_protocol_contract_required=True,
        direct_imported_float_declarations=floats,
        float_subcalculation_scope='eliminate_literal maximum-value construction for these three direct imported type declarations only',
        all_reachable_numeric_literals_bounded=False,
        prepared_task_domain_capacity_established=False,
        shared_preparation_lifetime_established=False,
        backend_task_printer_capacity_established=False,
        solver_output_bytes_bounded=False,
        whole_tail_capacity_established=False,
        whole_pipeline_capacity_established=False,
        production_configuration_adopted=False,
        new_native_runs=0,
        remaining_requirements=inputs['remaining_requirements'])
    assert result['sum_raw_initial_tasks']==156
    assert result['sum_registered_task_upper']==153
    assert result['sum_task_driver_pair_upper']==459
    assert result['sum_configured_transform_application_upper']==6120
    return result


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path)
    args=parser.parse_args(); result=compose()
    if args.output: args.output.write_text(json.dumps(result,indent=2)+'\n')
    else: print(json.dumps(result,indent=2))

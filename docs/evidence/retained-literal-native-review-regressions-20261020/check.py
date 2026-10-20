#!/usr/bin/env python3
"""Focused mutation inputs to the frozen, actual aggregate attach function.

This is a join-logic regression, not a fresh source-capacity evaluation. All
component callbacks return explicit copies of retained successful outputs.
The original review probe's fault_api pattern is adapted here; see inputs.json.
No Context, tool, compiler, prover or broad predecessor suite is executed.
"""
import argparse
from copy import deepcopy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import runpy
import tarfile
import time
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO / 'docs/evidence'
TARGET = 'a3af18004743d36328a499760699305357389fb8'


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_bytes())


def check_inputs():
    inputs = read(HERE / 'inputs.json')
    for row in inputs['files']:
        assert identity((REPO / row['path']).read_bytes()) == row['identity'], row['path']
    pins = read(E / 'retained-literal-native-completion-20261019/inputs.json')['repository']
    assert len(pins) == 94
    for row in pins:
        assert identity((REPO / row['path']).read_bytes()) == {
            k: row[k] for k in ('bytes', 'sha256')}, row['path']
    origin = read(HERE / 'sources.json')
    assert identity((HERE / 'sources.tar.gz').read_bytes()) == origin['archive_identity']
    with tarfile.open(HERE / 'sources.tar.gz') as archive:
        assert archive.getnames() == [row['path'] for row in origin['files']]
        for row in origin['files']:
            assert identity(archive.extractfile(row['path']).read()) == row['identity']
            for ref in row['matching_manifest_entries']:
                manifest = read(REPO / ref['manifest'])
                assert any(x['path'] == row['path'] and all(x[k] == row['identity'][k]
                    for k in ('bytes', 'sha256')) for x in manifest[ref['array']])
    return len(pins)


def cached_context(register, parts, manifest):
    """Only test substitutes; preserve attach's own checks and computation."""
    graph = register['predecessor_result']['selected_native_invocation']
    def result(name):
        def cached(*args, **kwargs):
            out = deepcopy(parts[name])
            if name in ('parent', 'driver'):
                # Keep the synthetic component metadata consistent with this
                # mutation's synthetic graph to reach the later stage checks.
                out['invocation_identity'] = identity(json.dumps(dict(graph, path_bytes=512),
                    sort_keys=True, separators=(',', ':')).encode())
            return out
        return cached
    return SimpleNamespace(
        register_schema=register['conditions'].keys(), manifest=manifest,
        shell_sources_checked=0,  # no compiler-source check is run by these stubs
        parent_context=SimpleNamespace(invocation=None, api={
            'build': lambda *args, **kwargs: dict(deepcopy(graph), path_bytes=512)}),
        driver_context=None, binder_context=None, ada_context=None,
        parent={'evaluate': result('parent')}, driver={'evaluate': result('driver')},
        binder={'evaluate': result('binder')}, ada={'apply': result('Ada')},
        shell_inputs=None, shells={'compiler_shells': result('compiler_shells'),
                                  'binder_compiler': result('binder_compiler')},
        assembler_context=SimpleNamespace(result=deepcopy(parts['binder_assembler'])))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    started = datetime.now(timezone.utc).isoformat()
    timer = time.perf_counter()
    pins = check_inputs()
    api = runpy.run_path(str(E / 'retained-literal-native-completion-20261019/compose.py'))
    baseline = read(E / 'retained-literal-native-completion-20261019/result.json')
    register, parts = baseline['register_result'], baseline['components']
    raw = (REPO / 'samples/hello_world.adb').read_bytes()
    assert api['identity'](raw) == baseline['source'] == register['source']
    manifest = read(E / 'retained-literal-native-completion-20261019/inputs.json')
    records = []

    def attach(r, p):
        return api['attach'](r, raw, cached_context(r, p, manifest))

    out = attach(register, parts)
    assert out['complete_native_capacity'] is True and out['native_residuals'] == []
    assert out['conditions'] == baseline['conditions']
    records.append(dict(case='retained_success_join_replay', outcome='true_verdict',
        input_kind='retained Hello register and cached component outputs'))

    def status_case(case, mutation, stage, value):
        r, p = deepcopy(register), deepcopy(parts)
        mutation(r, p, value)
        out = attach(r, p)
        key = 'complete_native_stage_' + stage
        assert out['complete_native_capacity'] is False
        assert out['coverage'][stage] is value
        assert all(out[field][key] is value for field in ('conditions', 'conditional_conditions'))
        assert key in out['native_residuals']
        records.append(dict(case=case, injected_value=value, stage=stage,
            outcome='false_verdict', stage_value=out['coverage'][stage],
            named_residual=key, input_kind='explicit synthetic mutation'))

    # The original probe covered stages1-4,10,11. Exercise both operands at
    # each previously uncovered conjunction, not merely a stored stage map.
    def invocation_flag(key):
        return lambda r, p, v: r['predecessor_result']['selected_native_invocation'].__setitem__(key, v)
    def linker_flag(key):
        return lambda r, p, v: r['predecessor_result']['core_result']['literal_output_linker'].__setitem__(key, v)
    def binder_field(key):
        return lambda r, p, v: p['binder'].__setitem__(key, v)
    mutations = [
        ('stage7_emission_route', invocation_flag('selected_main_emission_to_GAS_object_route_bound'), 'Main_emission_GAS_BFD'),
        ('stage7_assembler_storage', linker_flag('assembler_storage_fits'), 'Main_emission_GAS_BFD'),
        ('stage9_source_coverage', binder_field('binder_source_coverage_complete'), 'GNATBIND'),
        ('stage9_capacity', binder_field('binder_capacity_established'), 'GNATBIND'),
        ('stage12_materialization', invocation_flag('selected_fixed_link_input_materialization_computable'), 'fixed_bundle_and_ld_BFD'),
        ('stage12_linker', linker_flag('selected_literal_assembler_and_linker_representation_fits'), 'fixed_bundle_and_ld_BFD')]
    for name, mutation, stage in mutations:
        for value in (False, None):
            status_case(name, mutation, stage, value)

    # Stage8 is a typed component guard: False yields a verdict; None is
    # rejected by require(), never misreported as an observed false verdict.
    status_case('stage8_ALI_guard', lambda r, p, v: p['binder']['conditions'].__setitem__(
        'accepted_native_ALI_local_interfaces', v), 'Main_ALI_writer', False)

    def rejects(case, r, p, message, context=None):
        try:
            api['attach'](r, raw, context or cached_context(r, p, manifest))
        except ValueError as error:
            assert str(error) == message, (case, str(error))
            records.append(dict(case=case, outcome='malformed_input_ValueError',
                error=str(error), input_kind='explicit synthetic mutation'))
        else:
            raise AssertionError('malformed mutation accepted: ' + case)

    for name in ('parent', 'binder', 'Ada', 'compiler_shells', 'binder_compiler', 'binder_assembler'):
        field = 'checks' if name == 'Ada' else 'conditions'
        key = ('accepted_native_ALI_local_interfaces' if name == 'binder'
               else next(iter(parts[name][field])))
        r, p = deepcopy(register), deepcopy(parts)
        p[name][field][key] = False
        out = attach(r, p)
        guard = 'complete_native_' + name + '_' + key
        assert out['complete_native_capacity'] is False
        assert all(out[m][guard] is False for m in ('conditions', 'conditional_conditions'))
        assert guard in out['native_residuals']
        records.append(dict(case='component_guard_false_' + name, outcome='false_verdict',
            guard=guard, named_residual=guard, input_kind='explicit synthetic mutation'))
        p[name][field][key] = None
        rejects('component_guard_null_' + name, r, p, 'typed nonempty ' + name + ' guards')

    # Schema and predecessor maps are changed together only in this malformed
    # test input, so execution reaches the real collision check in attach.
    r, p = deepcopy(register), deepcopy(parts)
    old_key = next(iter(r['conditions']))
    collision = 'complete_native_parent_' + next(iter(p['parent']['conditions']))
    for field in ('conditions', 'conditional_conditions'):
        r[field][collision] = r[field].pop(old_key)
    context = cached_context(r, p, manifest)
    rejects('predecessor_guard_key_collision', r, p, 'no predecessor guard overwritten', context)

    result = dict(status='passed', target_commit=TARGET,
        implementation_freeze='4f29a3bf85', research_base='19b26ac8a15d7c356b03a25e41096d882bf4dbe0',
        model=dict(selected='GPT-6.1 Sol', effort='Extra High', runtime_confirmation=False),
        input_kind='retained baseline and explicit cached-component mutation inputs; not public source evaluation',
        cases=len(records), false_verdict_cases=sum(x['outcome']=='false_verdict' for x in records),
        malformed_input_cases=sum(x['outcome']=='malformed_input_ValueError' for x in records),
        records=records, frozen_repository_inputs_checked=pins, retained_GCC_files_checked=2,
        source=identity(raw), host=platform.platform(), native_tool_executions=0,
        broad_suite_replayed=False, new_universal_claim=False,
        started_UTC=started, finished_UTC=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer)
    if args.output:
        args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ('status', 'cases', 'false_verdict_cases', 'malformed_input_cases', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()

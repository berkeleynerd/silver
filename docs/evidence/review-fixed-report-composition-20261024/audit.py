#!/usr/bin/env python3
"""Independent offline review of the exact #212 partial source packet.

This checks its frozen inputs and numerical transfer, not Ada reachability.
The source reasoning is recorded in the companion review. No author or
predecessor checker is executed, and no author evidence is overwritten.
"""
from dataclasses import asdict
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import re
import subprocess
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT / 'docs/evidence/retained-fixed-report-composition-20261024'
AUTHOR = '057d60cb8e1ff4938bf01667f643d35fc4eb7f0f'
started = time.monotonic()


def digest(data):
    return hashlib.sha256(data).hexdigest()


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


inputs = [ROOT / 'docs/research/retained-fixed-report-composition.md']
inputs += [PACKET / name for name in
           ('README.md', 'capacity.py', 'check.py', 'result.json',
            'round.json', 'source-manifest.json')]
input_hashes = {}
for path in inputs:
    relative = path.relative_to(ROOT).as_posix()
    expected = subprocess.check_output(['git', 'show', f'{AUTHOR}:{relative}'],
                                       cwd=ROOT)
    actual = path.read_bytes()
    assert expected == actual, relative
    input_hashes[relative] = digest(actual)

manifest = json.loads((PACKET / 'source-manifest.json').read_text())
for path, expected in manifest['repository_files'].items():
    assert digest((ROOT / path).read_bytes()) == expected, path
archive = ROOT / manifest['archive']['path']
assert digest(archive.read_bytes()) == manifest['archive']['sha256']
with tarfile.open(archive) as source:
    for member, expected in manifest['archive']['members'].items():
        assert digest(source.extractfile(member).read()) == expected, member

f = load(PACKET / 'capacity.py', 'reviewed_fixed_report')
retained = json.loads((PACKET / 'result.json').read_text())
cases = {
    'Silver_Output_Libc': (18575, 0, 8714, 34, 180960386, 191652),
    'Silver_Runtime': (1510, 1, 7376, 30, 251273906, 233394),
}
reviewed = {}
for unit, (frontend, states, warnings, name_bound, constant, slope) in cases.items():
    source = (ROOT / 'src' / (unit.lower() + '.ads')).read_text()
    declared = re.findall(r'^\s*(?:function|procedure)\s+(\w+)', source, re.M)
    names = [unit] + [unit + '.' + name for name in declared]
    assert len(names) == 4 and max(map(len, names)) == name_bound
    assert tuple(declared) == f.CALLABLES[unit][1:]

    # Sum the accepted emitter-table rows separately. A_expr = 0 is the
    # manually reviewed package-declaration frontier, not a measured graph.
    vertices = 6 + 2 * states
    objects = 1 + 2 * states
    rows = [1, objects, 0, 6 * objects, 2 * vertices * objects,
            vertices, 2 * objects, vertices + 1, vertices,
            2 * vertices * objects + 2 * objects, objects,
            2 * vertices * objects, states, 0,
            vertices * objects + 1, vertices + 1, 2]
    flow = sum(rows)
    assert flow == (84 if states == 0 else 243)
    endpoint = None
    for path_bytes in (0, 1, 4096):
        report = f.spec_report(unit, path_bytes=path_bytes)
        incoming = report['incoming']
        assert incoming['frontend_nodes'] == frontend
        assert incoming['frontend_entities'] == frontend
        assert incoming['constructor_vertices'] == frontend + 12
        assert incoming['eligible_vertices'] == vertices
        assert incoming['flow_ids'] == objects
        assert incoming['flow_records'] == flow
        assert incoming['warning_records'] == warnings
        assert incoming['trace_attempts'] == vertices + 2 * vertices * objects
        assert incoming['trace_lines_per_file'] == vertices
        assert incoming['outside_flow_records'] == 0
        assert incoming['message_bytes'] == 7894 + 5 * path_bytes
        assert report['full'].pretty == constant + slope * path_bytes
        assert report['claim_domain'] == {'claims': 20, 'edges': 0}
        assert report['third_pool']['find_calls'] == 2 * (36 + flow)
        assert report['full'] == report['projected']
        assert report['source_counts_bound']
        assert not report['path_configuration_bound']
        assert not report['native_warning_location_join_complete']
        assert not report['whole_process_capacity_bound']
        assert all(incoming['guards'].values())
        assert all(report['writer']['guards'].values())
        assert all(report['flow_brief']['guards'].values())
        if path_bytes == 4096:
            endpoint = report
    parsed = f.c.parsed_report(endpoint['full'], path_bytes=4096,
                               max_path=4096, page_size=65536)
    assert parsed['all_guards']
    saved = retained['specification_processes'][unit]
    assert saved['incoming'] == endpoint['incoming']
    assert saved['interval_writer'] == endpoint['writer']
    assert saved['interval_reader'] == parsed
    assert saved['interval_flow_brief'] == endpoint['flow_brief']
    assert saved['third_pool'] == endpoint['third_pool']
    assert saved['report_entity_names'] == names
    assert saved['pretty_affine'] == dict(constant=constant,
                                         path_coefficient=slope)
    reviewed[unit] = dict(frontend=frontend, eligible_vertices=vertices,
        objects=objects, flow=flow, warnings=warnings, names=names,
        pretty_affine=saved['pretty_affine'], endpoint_pretty=endpoint['full'].pretty,
        endpoint_writer_allocation=endpoint['writer']['unbounded_allocation'],
        endpoint_writer_guards=endpoint['writer']['guards'],
        endpoint_reader_guards=parsed['guards'])

# Differential against the accepted configuration provider: preserve order
# and every unrelated option, while applying exactly the prospective choices.
for workers in (3, f.p.I):
    old = f.c.configuration(project_path_bytes=7, object_dir_bytes=9)['argv']
    expected = [x for x in old if x != '--level=2']
    for before, after in [('--steps=100000', '--steps=0'),
                          ('--memlimit=1000', '--memlimit=0'),
                          ('-j0', '-j' + str(workers))]:
        expected[expected.index(before)] = after
    expected.insert(expected.index('-j' + str(workers)), '--counterexamples=off')
    config = f.prospective_configuration(project_path_bytes=7,
                object_dir_bytes=9, workers=workers)
    assert config['argv'] == expected and config['argv_count'] == 18
    concrete = [x if x is not None else 'p' * 7 for x in expected]
    witness = dict(obj_dirs=['o' * 9], cmdline=concrete, proof_switches={},
                   mode='GPM_ALL', has_errors=False, colors=False)
    encoded = json.dumps(witness, separators=(',', ':')) + '\n'
    assert len(encoded) <= config['config_file_bytes']
    assert len(' '.join(concrete)) == config['joined_command_bytes']
    assert not config['launcher_implemented']
    assert not config['concrete_path_join_complete']

result = dict(reviewed_commit=AUTHOR, exact_inputs=input_hashes,
    manifest_repository_files=len(manifest['repository_files']),
    manifest_archive_members=len(manifest['archive']['members']),
    status='PASS: frozen inputs, arithmetic, endpoint guards and argv differential',
    specification_processes=reviewed,
    endpoint_conditions=dict(path_bytes_upper=4096, max_path_upper=4096,
                             page_size_upper=65536),
    source_reachability='manual review; lexical census is corroboration only',
    author_checker_runs=0, predecessor_checker_runs=0, native_or_prover_runs=0,
    host=platform.platform(), utc=datetime.now(timezone.utc).isoformat(),
    elapsed_seconds=round(time.monotonic()-started, 3))
(HERE / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True)+'\n')
print(json.dumps({key: result[key] for key in
                 ('reviewed_commit', 'status', 'elapsed_seconds')}, indent=2))

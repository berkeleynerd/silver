"""Focused offline projection and rejection tests; no native target runs."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import time
from project import HERE, compose, read_archive, validate_graph, validate_table, input_isomorphism, project, ENTRY, REFINEMENT

start = time.monotonic()
result, graph, table = compose()
assert json.loads(json.dumps(result)) == json.loads((HERE / 'result.json').read_text())
assert result['representative_contract_instantiated_for_retained_entry']
assert result['local_structural_and_registration_transfer_established_under_existing_runtime_and_freshness_premises']
assert not result['complete_transform_capacity_established']
assert not result['whole_pipeline_capacity_established']
assert result['attached_local_demands']['events']['all_fresh_identifier_registrations_upper'] == 1145
assert result['Decl.Hsdecl_counter_transfer']['final_upper'] == 6979
assert result['Decl.Hsdecl_backing_transfer']['individual_outer_array_length_upper'] == 36336
assert result['projection']['remaining_old_representatives_are_input_roots'] == 142
assert result['projection']['kind_or_symbol_excluded_old_declarations'] + 145 == 6704
checks = []

def reject(label, fn, message=None):
    try:
        fn()
    except AssertionError as exc:
        if message is not None:
            assert message in str(exc), (label, str(exc))
        checks.append(label)
    else:
        raise AssertionError(label + ' unexpectedly accepted')

bad = copy.deepcopy(table)
bad['buckets'].pop()
reject('omitted weak bucket', lambda: validate_table(bad, graph))

bad = copy.deepcopy(table)
row = next(r for r in bad['buckets'] if len(r['payload']) > 2)
row['hash_array']['fields'].pop()
reject('truncated cached-hash array', lambda: validate_table(bad, graph))

bad = copy.deepcopy(table)
row = next(r for r in bad['buckets'] if any(k != bad['ephe_none_value'] for k in r['payload'][2:]))
j = next(i for i, k in enumerate(row['payload'][2:]) if k != bad['ephe_none_value'])
row['hash_array']['fields'][j] += 2
reject('wrong bucket hash', lambda: validate_table(bad, graph), 'cached hash in wrong bucket')

bad_graph = dict(graph, blocks=dict(graph['blocks']))
missing = graph['input_declaration_roots'][0]
del bad_graph['blocks'][str(missing)]
reject('missing stored graph block', lambda: validate_graph(bad_graph))

old = json.loads(read_archive(ENTRY / 'capture.tar.gz')['capture/inline-entry-graph.json'])
bad_graph = dict(graph, blocks=dict(graph['blocks']))
key = next(k for k, r in graph['blocks'].items() if r['tag'] == 252 and r['payload_hex'])
# Alter an actual input string, not an arbitrary unrelated table payload.
key = next(str(input_isomorphism(old, graph)[int(k)]) for k, r in old['blocks'].items() if r['tag'] == 252)
bad_graph['blocks'][key] = dict(graph['blocks'][key], payload_hex='00' * graph['blocks'][key]['words'] * 8)
reject('changed input opaque bytes', lambda: input_isomorphism(old, bad_graph), 'input opaque bytes changed')

# Make an extra same-key old representation fit the semantic envelope. The
# current exclusion proof must fail; it cannot silently certify its maps.
bad_graph = dict(graph, blocks=dict(graph['blocks']))
extra = result['projection']['strict_shape_exclusions'][0]
original = graph['input_declaration_roots'][extra['declaration_index']]
bad_graph['blocks'][str(extra['address'])] = dict(graph['blocks'][str(original)])
details = json.loads((REFINEMENT / 'details.json').read_text())
reject('unexcluded extra representative', lambda: project(bad_graph, details), 'cannot be excluded by strict shape')

# Replay the diagnosed decoder fix against a memory model that forbids all
# zero-byte reads, including shared empty buckets and mixed nonempty slots.
archive = read_archive(HERE / 'capture.tar.gz')
with tempfile.TemporaryDirectory() as tmp:
    root = Path(tmp)
    for name in ('test-empty-arrays.py', 'table-observer.py', 'plan.json'):
        (root / name).write_bytes(archive[name])
    p = subprocess.run([sys.executable, '-B', str(root / 'test-empty-arrays.py')], check=True, capture_output=True, text=True)
    assert p.stdout.startswith('PASS:')
checks.append('zero-length read regression and inconsistent bucket/hash length rejection')
print(json.dumps({'status': 'pass', 'elapsed_seconds': round(time.monotonic() - start, 6),
                  'new_native_runs': 0, 'negative_checks': checks}))

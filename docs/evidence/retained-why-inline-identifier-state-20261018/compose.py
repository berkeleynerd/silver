"""Offline retained-ref binding and one continuing invocation's counter transfer."""
from pathlib import Path
import hashlib
import importlib.util
import json
import struct
import tarfile
import tempfile

from counter import registration_transfer

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
STATE = HERE.parent / 'retained-why-inline-representative-state-20261018'
ENTRY = HERE.parent / 'retained-why-preparation-entry-20261018'
REFINEMENT = HERE.parent / 'retained-why-inline-refinement-20261018'
COMPARAND = HERE.parent / 'retained-why-inline-comparand-capacity-20261018'


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def archive(path):
    with tarfile.open(path) as stream:
        return {m.name: stream.extractfile(m).read() for m in stream.getmembers() if m.isfile()}


def replay(capture, plan, ident, auxiliary):
    """Run only the raw observer against retained bytes; no native target."""
    spans = {}
    reads = 0
    for line in capture['capture/memory-reads.jsonl'].splitlines():
        row = json.loads(line)
        raw = bytes.fromhex(row['hex'])
        assert len(raw) == row['bytes']
        spans[row['address'], row['bytes']] = raw
        reads += 1
    # The inferior stays stopped throughout both snapshots. Last reads supply
    # the retained entry values, rather than earlier startup/prepare values.
    addresses = {n: row['address'] for n, row in ident['instruction_checks'].items()}
    addresses['camlWhy3__Ident'] = ident['module']['address']
    for row in auxiliary['hashcons'].values():
        addresses[row['module']['symbol']] = row['module']['address']
    addresses['caml_ephe_none'] = auxiliary['ephe_none_symbol']
    assert addresses['camlWhy3__Task'] == auxiliary['Task.Stdecl']['module']['address']
    def raw(address, size=8):
        return spans[address, size]
    def decode(n):
        assert type(n) is int and n & 1
        return (n-(1 << 64) if n >= 1 << 63 else n) >> 1
    with tempfile.TemporaryDirectory(prefix='silver-identifier-replay-') as tmp:
        out = Path(tmp)
        env = dict(OUT=out, PLAN=plan, SUMMARY={}, save=lambda: None, data=raw,
                   address=lambda n: addresses[n], decode_tagged=decode,
                   json=json, struct=struct, identity=lambda p: identity(p.read_bytes()))
        exec(capture['snapshot-observer.py'].decode(), env)
        assert env['capture_identifier']() == ident, 'private-ref raw replay differs'
        assert env['capture_auxiliary']() == auxiliary, 'auxiliary raw replay differs'
        env['_memory_log'].close()
    return reads


def auxiliary_observations(aux, decoded):
    """Decode counters/backing dimensions only; no continuing capacity claim."""
    blocks = aux['blocks']
    def fields(p, tag=0, words=None):
        row = blocks[str(p)]
        assert row['address'] == p and row['header'] & 255 == row['tag'] == tag
        assert row['header'] >> 10 == row['words'] == len(row['fields'])
        if words is not None:
            assert len(row['fields']) == words
        assert int.from_bytes(bytes.fromhex(row['header_hex']), 'little') == row['header']
        assert list(struct.unpack('<'+'Q'*row['words'], bytes.fromhex(row['payload_hex']))) == row['fields']
        return row['fields']
    def counter(p):
        n = decoded(fields(p, 0, 1)[0]); assert n >= 0
        return n
    out = {}
    for name, row in aux['hashcons'].items():
        hs = fields(row['module']['value'], 0, 4); cl = fields(hs[0], 247, 6)
        record = fields(cl[4], 0, 5); outer = fields(record[0]); hashes = fields(record[1])
        assert len(outer) == len(hashes)
        slots = nonempty = maximum = 0
        for bp, hp in zip(outer, hashes):
            bucket = fields(bp, 251); h = fields(hp)
            assert len(bucket) >= 2 and bucket[1] == aux['ephe_none_value']
            assert len(h) == len(bucket)-2
            slots += len(h); maximum = max(maximum, len(h))
            nonempty += sum(p != aux['ephe_none_value'] for p in bucket[2:])
        out[name] = {'counter': counter(cl[3]), 'outer_length': len(outer),
                     'allocated_key_slots': slots, 'nonempty_key_slots': nonempty,
                     'maximum_bucket_length': maximum,
                     'limit': decoded(record[2]), 'oversize': decoded(record[3]), 'rover': decoded(record[4]),
                     'continuing_capacity_established': False}
    s = fields(aux['Task.Stdecl']['module']['value'], 0, 31)
    singleton = fields(s[7], 247, 3); m = fields(singleton[2], 0, 56)
    cl = fields(m[5], 247, 5); assert cl[3:] == [m[3], m[4]]
    record = fields(m[3], 0, 4); outer = fields(record[1]); seen = set(); variants = set()
    for p in outer:
        while p != 1:
            assert p not in seen, 'overlapping/cyclic ephemeron lists'
            seen.add(p); h, ep, p = fields(p, 0, 3); decoded(h)
            e = fields(ep, 251, 3)
            for key in e[1:]:
                if key == aux['ephe_none_value'] or key & 1:
                    continue
                r = blocks[str(key)]; assert (r['tag'], r['words']) in [(0, 3), (1, 5)]
                fields(key, r['tag'], r['words']); variants.add((r['tag'], r['words']))
    assert len(seen) == decoded(record[0])
    out['Task.Stdecl'] = {'counter': counter(m[4]), 'outer_length': len(outer),
                          'bucket_nodes': len(seen), 'seed': decoded(record[2]),
                          'initial_size': decoded(record[3]), 'retained_variants': sorted(variants),
                          'continuing_capacity_established': False}
    return out


def compose():
    manifest = json.loads((HERE/'inputs.json').read_text())
    for name, expected in manifest['dependencies'].items():
        assert identity((REPO/name).read_bytes()) == expected, name
    for name, expected in manifest['local_inputs'].items():
        assert identity((HERE/name).read_bytes()) == expected, name
    contents = {}
    for name, spec in manifest['archives'].items():
        assert identity((HERE/name).read_bytes()) == spec['identity'], name
        content = archive(HERE/name)
        assert {n: identity(b) for n, b in content.items()} == spec['members'], name
        contents[name] = content
    runtime = contents['runtime-sources.tar.gz']
    references = json.loads(runtime['registration-references.json'])
    assert {r['function'] for r in references['references']} == {
        'camlStdlib__Gc__fun_641', 'camlStdlib__Gc__fun_643',
        'camlStdlib__Gc__call_alarm_519', 'camlStdlib__Gc__create_alarm_521'}
    assert b'caml_callback_exn (f.fun, f.val + f.offset)' in runtime['runtime/finalise.c']
    assert b'caml_channel_mutex_free = caml_io_mutex_free;' in runtime['otherlibs/systhreads/st_stubs.c']
    capture = contents['capture.tar.gz']
    state = load('identifier_representative', STATE/'project.py')
    prior, _, _ = state.compose()
    plan = json.loads(capture['plan.json']); summary = json.loads(capture['capture/summary.json'])
    result = json.loads(capture['capture/result.json']); process = json.loads(capture['capture/process.json'])
    assert summary['completed'] and not summary['failures'] and not summary['guard_hits'] and not summary['new_threads']
    assert process['initial_threads'] == 1
    assert result['completed'] and not result['timed_out'] and not result['failures'] and result['returncode'] == 0
    g = json.loads(capture['capture/inline-entry-graph.json']); table = json.loads(capture['capture/hsdecl-table.json'])
    ident = json.loads(capture['capture/identifier-state.json']); aux = json.loads(capture['capture/auxiliary-state.json'])
    for filename, spec in [('inline-entry-graph.json', summary['inline_entry']['graph']),
                           ('hsdecl-table.json', summary['hsdecl_table']['identity']),
                           ('identifier-state.json', summary['identifier_state']['identity']),
                           ('auxiliary-state.json', summary['auxiliary_state']['identity'])]:
        assert identity(capture['capture/'+filename]) == spec
    assert aux['complete'] and not summary.get('auxiliary_failures')
    for name, row in ident['instruction_checks'].items():
        assert row['first32'] == plan['shared_observer']['symbols'][name]['first32']
    for name, row in table['instruction_checks'].items():
        assert row['first32'] == plan['table_observer']['symbols'][name]['first32']
    state.validate_graph(g); state.validate_table(table, g)
    old = archive(STATE/'capture.tar.gz'); old_plan = json.loads(old['plan.json'])
    old_case, case = old_plan['inputs'][0], plan['inputs'][0]
    old_root, new_root = str(Path(old_case['cwd']).parent), str(Path(case['cwd']).parent)
    assert json.loads(json.dumps(old_case).replace(old_root, new_root)) == case
    assert process['argv'] == case['argv'] and process['environment'] == case['environment']
    assert identity(capture['input/'+case['argv'][-1]]) == case['input'] == old_case['input']
    binary = case['argv'][0]
    assert plan['file_identities'][binary] == old_plan['file_identities'][binary] == summary['mapped_files'][binary]
    assert capture['run.py'].decode() == old['run.py'].decode().replace(old_root, new_root)
    assert capture['table-observer.py'] == old['table-observer.py']
    probe = old['probe.py'].decode().replace(old_root, new_root)
    marker = '# Existing entry observer, extended to complete table roots.'
    probe = probe.replace(marker, capture['snapshot-observer.py'].decode()+'\n'+marker)
    probe = probe.replace('table_roots=read_table_state()', 'capture_identifier()\n   table_roots=read_table_state()')
    marker = '   # Reuse the retained final GC/resource invariants, now at the actual entry.'
    probe = probe.replace(marker, '   save()\n   capture_auxiliary()\n'+marker)
    assert probe == capture['probe.py'].decode(), 'accepted guards/observer unexpectedly changed'
    assert plan['guards'] == old_plan['guards'] and plan['forbidden_calls'] == old_plan['forbidden_calls']
    original = json.loads(archive(ENTRY/'capture.tar.gz')['capture/inline-entry-graph.json'])
    joined = state.input_isomorphism(original, g)
    projection = state.project(g, json.loads((REFINEMENT/'details.json').read_text()))
    demands = prior['attached_local_demands']; registrations = demands['events']['all_fresh_identifier_registrations_upper']
    assert registrations == 1145
    # Comparison/hash traversals add no identifier registrations (accepted source
    # argument). This is not a claim that their native resource work is free.
    comparand = json.loads((COMPARAND/'result.json').read_text())
    assert comparand['joined_local_demands']['events']['all_fresh_identifier_registrations_upper'] == registrations
    reads = replay(capture, plan, ident, aux)
    assert ident['counter']['decoded'] == state.decoded(ident['counter']['fields'][0]) == summary['identifier_state']['counter']
    transfer = registration_transfer(ident['counter']['decoded'], registrations)
    auxiliary = auxiliary_observations(aux, state.decoded)
    failed = contents['failed-attempts.tar.gz']
    attempts = []
    for prefix in ['attempt1','attempt2']:
        r = json.loads(failed[prefix+'/capture/result.json'])
        assert not r['completed'] and r['failures'] and not r['guard_hits'] and not r['timed_out']
        ev = [json.loads(line) for line in failed[prefix+'/managed/events.jsonl'].splitlines()]
        end = next(e for e in ev if e['event'] == 'finished')
        attempts.append({'managed_run': end['run_id'], 'outcome': end['outcome'],
                         'managed_seconds': end['duration_seconds'], 'debugger_seconds': r['duration_seconds'],
                         'failure': r['failures']})
    events = [json.loads(line) for line in capture['managed/events.jsonl'].splitlines()]
    end = next(e for e in events if e['event'] == 'finished')
    attempts.append({'managed_run': end['run_id'], 'outcome': end['outcome'],
                     'managed_seconds': end['duration_seconds'], 'debugger_seconds': result['duration_seconds'], 'failure': []})
    return {'scope':'this retained first Input_Is_Valid/cvc5 inline entry and one bounded continuing invocation',
            'private_counter_observed':True,'same_run_graph_and_complete_Hsdecl_binding_checked':True,
            'exact_input_graph_isomorphism_blocks':len(joined),'input_roots':len(g['input_declaration_roots']),
            'Hsdecl_unique_old_objects':len(g['hsdecl_declaration_roots']),
            'Hsdecl_next_tag':table['next_tag'], 'representative_envelope':prior['representative_envelope'],
            'same_run_representative_projection': {k:v for k,v in projection.items() if k != 'groups'},
            'registration_transfer':transfer,
            'private_counter_plus_accounted_source_increment_fit':True,
            'complete_continuing_call_counter_capacity_established':False,
            'runtime_identifier_reentrancy_closure_established':False,
            'selected_C_destructor_source_and_native_bodies_retained':True,
            'complete_OCaml_callback_registration_reachability_established':False,
            'source_transfer_premises_and_open_runtime_boundary':['accepted relevant source/runtime correspondence and valid caches',
              'accepted well-formed input and existing noncolliding freshness',
              'extension to all continuing runtime behavior requires separately closing uncharged identifier-producing callbacks, finalizers and returning signal handlers; this packet leaves that obligation open'],
            'prior_history_no_overflow_established':False,'family_wide_counter_invariance_established':False,
            'future_or_other_invocations_bounded':False,
            'auxiliary_observations':auxiliary,'auxiliary_raw_blocks':len(aux['blocks']),
            'raw_memory_read_records':reads,'auxiliary_continuing_capacity_established':False,
            'native_inlining_executed':False,'complete_transform_capacity_established':False,
            'whole_pipeline_capacity_established':False,'source_argument_machine_checked':False,
            'managed_capture_attempts':attempts,'solver_runs':0}


if __name__ == '__main__':
    print(json.dumps(compose(),indent=2))

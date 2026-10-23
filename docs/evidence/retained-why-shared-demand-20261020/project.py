"""New small metadata projection; never replay a capture or predecessor checker."""
import ast
import hashlib
import json
from pathlib import Path
import struct
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = HERE.parent
CASES = ('put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid')
SOURCES = EVIDENCE / 'retained-why-inline-operations-20261018/sources.tar.gz'
CAPTURE = EVIDENCE / 'retained-why-session-save-state-20261019/capture.tar.gz'


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def pure_functions(path, names, namespace=None):
    """Load only named, pinned pure definitions, not their module's composition."""
    tree = ast.parse(path.read_text())
    defs = [n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in names]
    assert {n.name for n in defs} == set(names)
    scope = {} if namespace is None else dict(namespace)
    exec(compile(ast.Module(body=defs, type_ignores=[]), str(path), 'exec'), scope)
    return scope


def decoded(n):
    assert type(n) is int and n & 1
    return (n - (1 << 64) if n >= 1 << 63 else n) >> 1


def input_projection():
    manifest = read(CAPTURE.parent / 'capture-identities.json')
    assert identity(CAPTURE.read_bytes()) == manifest['identity']
    with tarfile.open(CAPTURE) as archive:
        def get(name):
            name = 'input_is_valid/capture/' + name + '.json'
            raw = archive.extractfile(name).read()
            assert identity(raw) == manifest['members'][name]
            return json.loads(raw)
        process, summary = get('process'), get('summary')
        ident, hs, aux = get('identifier-state'), get('hsdecl-table'), get('auxiliary-state')
    assert process['pid'] == 97103 and process['initial_threads'] == 1
    assert summary['completed'] and summary['protected']
    assert not summary['guard_hits'] and not summary['failures'] and not summary['new_threads']
    assert summary['snapshots'][-1]['label'] == 'inline_trivial_entry'
    baseline = summary['baseline']
    assert baseline['label'] == 'before_first_why3_module'
    stats = ('stat_minor_collections', 'stat_major_collections', 'stat_compactions',
             'stat_forced_major_collections')
    assert all(s['state'][k] == baseline['state'][k]
               for s in summary['snapshots'][1:] for k in stats)
    assert all(not s['state'][k] for s in summary['snapshots'][1:]
               for k in ('requested_major_slice', 'requested_minor_gc'))
    # Reuse the accepted raw-structure decoder only. No replay()/compose().
    decoder_path = EVIDENCE / 'retained-why-inline-identifier-state-20261018/compose.py'
    decode = pure_functions(decoder_path, ['auxiliary_observations'], {'struct': struct})
    auxiliary = decode['auxiliary_observations'](aux, decoded)
    for state in auxiliary.values():
        state.pop('continuing_capacity_established')
        if 'retained_variants' in state:
            state['retained_variants'] = [list(v) for v in state['retained_variants']]
    hstate = {k: hs[k] for k in ('next_tag', 'outer_length', 'allocated_key_slots',
                               'nonempty_key_slots', 'limit', 'oversize', 'rover')}
    hstate['maximum_bucket_length'] = max(len(b['payload']) - 2 for b in hs['buckets'])
    return dict(pid=97103, installed_elf_identity=summary['mapped_files'][process['executable']],
                cut='first CVC5 inline entry, after CE; upper envelope only',
                Ident=ident['counter']['decoded'], Hsdecl=hstate,
                auxiliary_observations=auxiliary,
                protected_since=baseline['label'], protected_guard_hits=[],
                minor_collections_at_protected_entry=baseline['state']['stat_minor_collections'],
                major_collections_at_protected_entry=baseline['state']['stat_major_collections'],
                endpoint_minor_words=summary['snapshots'][-1]['minor_allocated_words'],
                collector_phase=summary['snapshots'][-1]['caml_gc_phase'],
                native_replay=False)


def attachment():
    historical = {}
    for name in ('other-cases-result.json', 'is-message-result.json'):
        for row in read(EVIDENCE / 'retained-why-fixed-registration-state-20261020' / name)['cases']:
            historical[row['case'].replace('_', '-')] = dict(
                pid=row['pid'], cut=row['phase'], Ident=row['private_identifier_counter'],
                Hsdecl=row['Hsdecl'], auxiliary_observations=row['auxiliary_observations'])
    historical['input-is-valid'] = input_projection()
    targets = read(EVIDENCE / 'retained-parallel-logging-prefix-20261020/cut-projection.json')
    fresh = dict(zip(CASES, (17310, 17514, 17631, 17704, 17869)))
    out = []
    for case in CASES:
        old = historical[case]
        owners = {'Ident': dict(counter=old['Ident']),
                  'Decl.Hsdecl': dict(old['Hsdecl'])}
        owners['Decl.Hsdecl']['counter'] = owners['Decl.Hsdecl'].pop('next_tag')
        for name, state in old['auxiliary_observations'].items():
            owners['Task.Stdecl.Hcpt' if name == 'Task.Stdecl' else name] = dict(state)
        for state in owners.values():
            state.pop('continuing_capacity_established', None)
        out.append(dict(case=case, historical_pid=old['pid'], historical_cut=old['cut'],
                        fresh_save_pid=fresh[case],
                        retained_j12_pid=targets[case.replace('-', '_')]['captured_pid'],
                        prospective_route='combined quiet/timeless/J12/logging',
                        target_cut='registration before preparation',
                        attachment_kind=('upper_envelope_from_later_cut' if case == 'input-is-valid'
                                         else 'exact_under_constructor_trace_relation'),
                        observed_in_prospective_process=False, owners=owners,
                        prefix_charged_again=False, unmeasured_delta_subtracted=False))
    return out


# Full source identities plus exact lines; no duplicate source archive.
SLICES = {
 'ocaml/stdlib/weak.ml': [(18, 30), (98, 137), (178, 295)],
 'ocaml/stdlib/ephemeron.ml': [(111, 221), (241, 268), (315, 334), (445, 540)],
 'why3/src/util/hashcons.ml': [(22, 60)],
 'why3/src/util/hcpt.ml': [(130, 158), (180, 260)],
 'why3/src/util/weakhtbl.ml': [(15, 115)],
 'why3/src/core/ident.ml': [(175, 200)],
 'why3/src/core/ty.ml': [(90, 128), (234, 254)],
 'why3/src/core/decl.ml': [(340, 419), (635, 661), (743, 752), (810, 835)],
 'why3/src/core/theory.ml': [(209, 284), (999, 1016)],
 'why3/src/core/task.ml': [(17, 61), (88, 106), (148, 200)],
 'why3/src/core/trans.ml': [(46, 55), (75, 137)],
 'why3/src/driver/driver.ml': [(330, 389)],
 'why3/src/transform/inlining.ml': [(54, 101)],
 'why3/src/transform/introduction.ml': [(513, 537)],
 'why3/src/transform/libencoding.ml': [(263, 276)],
}


def source_witnesses():
    result = []
    with tarfile.open(SOURCES) as archive:
        for name, ranges in SLICES.items():
            raw = archive.extractfile(name).read()
            lines = raw.decode().splitlines()
            result.append(dict(archive=str(SOURCES.relative_to(REPO)), member=name,
                               identity=identity(raw), excerpts=[dict(first=lo, last=hi,
                               text='\n'.join(lines[lo-1:hi])) for lo, hi in ranges]))
    runtime = EVIDENCE / 'retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
    prefix = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/'
    with tarfile.open(runtime) as archive:
        for name, lo, hi in [('runtime/caml/mlvalues.h', 150, 160),
                             ('runtime/caml/weak.h', 148, 161),
                             ('runtime/sys.c', 640, 643),
                             ('stdlib/obj.ml', 129, 139), ('stdlib/sys.ml.in', 37, 47)]:
            raw = archive.extractfile(prefix + name).read()
            result.append(dict(archive=str(runtime.relative_to(REPO)), member=prefix+name,
                               identity=identity(raw), excerpts=[dict(first=lo, last=hi,
                               text='\n'.join(raw.decode().splitlines()[lo-1:hi]))]))
    # Bind the capture guard's protected interval, rather than infer it from totals.
    with tarfile.open(CAPTURE) as archive:
        raw = archive.extractfile('probe.py').read()
        lines = raw.decode().splitlines()
        selected = [i for i, line in enumerate(lines) if 'protected' in line]
        result.append(dict(archive=str(CAPTURE.relative_to(REPO)), member='probe.py',
                           identity=identity(raw), excerpts=[dict(first=max(1,i-3), last=i+5,
                           text='\n'.join(lines[max(0,i-4):i+5])) for i in selected]))
    return result


if __name__ == '__main__':
    for name, value in [('input-state.json', input_projection()),
                        ('attachment.json', attachment()), ('source-witnesses.json', source_witnesses())]:
        (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')

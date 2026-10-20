#!/usr/bin/env python3
"""Offline serializer input inventory; consumes retained archives, never a target.

The candidate is conditional. In particular, missing restored-path bindings
cannot be converted into a whole-continuation fallback guarantee.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
E = HERE.parent
CAPTURE = E / 'retained-why-save-state-capture-20261020'
JOIN = E / 'retained-why-save-state-join-20261020'
CASES = ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']
SOURCE_RANGES = {
    'why3/src/session/session_itp.ml': [(34, 82), (1939, 1939), (2019, 2209)],
    'why3/src/gnat/gnat_config.ml': [(12, 19), (269, 409)],
    'why3/src/gnat/gnat_util.ml': [(41, 46), (101, 108)],
    'why3/src/driver/whyconf.ml': [(39, 59), (327, 395), (521, 550), (778, 840), (1008, 1013)],
    'why3/src/core/theory.ml': [(472, 492), (919, 938)],
    'why3/src/core/ident.ml': [(158, 173)],
    'why3/src/util/sysutil.ml': [(131, 135)],
}


def ident(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def get(path):
    return json.loads(path.read_bytes())


def check_identity(raw, expected, label):
    assert ident(raw) == expected, ('input identity mismatch', label)


class CaptureArchive:
    def __init__(self):
        self.manifest = get(CAPTURE / 'capture-manifest.json')
        self.members = {}
        self.opened = {}
        self.consumed = {}
        for archive in self.manifest['archives']:
            for row in archive['members']:
                assert row['path'] not in self.members
                self.members[row['path']] = (archive['path'],
                    {k: row[k] for k in ('bytes', 'sha256')})

    def read(self, member):
        archive, expected = self.members[member]
        if archive not in self.opened:
            self.opened[archive] = tarfile.open(CAPTURE / archive)
        raw = self.opened[archive].extractfile(member).read()
        check_identity(raw, expected, member)
        self.consumed[member] = {'archive': archive, **expected}
        return raw

    def close(self):
        for archive in self.opened.values():
            archive.close()


def string(row):
    assert row is not None, 'unknown string'
    raw = bytes.fromhex(row['hex'])
    check_identity(raw, {k: row[k] for k in ('bytes', 'sha256')}, 'decoded string')
    return {'bytes': len(raw), 'hex': raw.hex(), 'sha256': row['sha256'],
            'text_utf8': raw.decode('utf-8')}


def path(row):
    assert row is not None, 'unknown path'
    parts = [string(x) for x in row['components']]
    n = len(parts)
    total = sum(x['bytes'] for x in parts)
    assert (n, total, total + max(0, n - 1)) == (
        row['component_count'], row['total_bytes'], row['joined_dot_bytes'])
    return {'components': parts, 'component_count': n, 'total_bytes': total,
            'joined_dot_bytes': total + max(0, n - 1)}


def prover(row):
    parts = {k: string(row[k]) for k in ('name', 'version', 'alternative')}
    return {**parts, 'raw_bytes_sum': sum(x['bytes'] for x in parts.values())}


def prover_key(row):
    return tuple(row[k]['hex'] for k in ('name', 'version', 'alternative'))


def selected_provers(raw):
    """Decode these simple retained RC sections, not a general Whyconf parser.

    Whyconf.load_prover_id gives absent alternative its source-defined empty
    default. No missing captured field receives this default.
    """
    rows = []
    text = raw.decode('utf-8')
    for match in re.finditer(r'(?ms)^\[prover\]\n(.*?)(?=^\[|\Z)', text):
        fields = {}
        for line in match[1].splitlines():
            key, value = line.split('=', 1)
            assert key.strip() not in fields
            fields[key.strip()] = value.strip()
        shortcut = json.loads(fields['shortcut'])
        if shortcut not in ('cvc5', 'z3', 'altergo'):
            continue
        assert fields.get('interactive', 'false') == 'false'
        parts = {}
        for key, field in [('name', 'name'), ('version', 'version'),
                           ('alternative', 'alternative')]:
            value = json.loads(fields[field]) if field in fields else ''
            assert field in fields or field == 'alternative'
            data = value.encode('utf-8')
            parts[key] = {'text_utf8': value, 'hex': data.hex(), **ident(data)}
        rows.append({'shortcut': shortcut, 'config_first_line':
            text[:match.start()].count('\n') + 1, **parts,
            'alternative_from_Whyconf_default': 'alternative' not in fields,
            'raw_bytes_sum': sum(x['bytes'] for x in parts.values())})
    assert {r['shortcut'] for r in rows} == {'cvc5', 'z3', 'altergo'}
    assert len(rows) == 3
    return sorted(rows, key=lambda r: r['shortcut'])


def forest_inventory(ser, restore):
    goals = {g['goal']: g for g in ser['goals']}
    trans = {t['id']: t for t in ser['transformations']}
    assert len(goals) == len(ser['goals']) and len(trans) == len(ser['transformations'])
    required = {r['ident']['pointer']: r for r in restore['required_identifiers']}
    assert len(required) == len(restore['required_identifiers'])
    counts = {k: Counter() for k in ('identifier', 'goal', 'transformation')}
    files, theories = [], []

    def visit_ident(name):
        assert name == required[name['pointer']]['ident'], 'identifier cross-projection mismatch'
        counts['identifier'][name['pointer']] += 1

    def visit_goal(gid, ancestors):
        assert ('g', gid) not in ancestors, 'cyclic serializer forest'
        g = goals[gid]
        counts['goal'][gid] += 1
        visit_ident(g['name'])
        for tid in g['transformations']:
            assert ('t', tid) not in ancestors, 'cyclic serializer forest'
            t = trans[tid]
            counts['transformation'][tid] += 1
            for child in t['subtasks']:
                visit_goal(child, ancestors | {('g', gid), ('t', tid)})

    for f in ser['files']:
        files.append({'id': f['id'], 'format': string(f['format']), 'path': path(f['path'])})
        for t in f['theories']:
            emitted = bool(t['goals'])
            theories.append({'identifier_pointer': t['name']['pointer'],
                'identifier_tag': t['name']['id_tag'], 'serialized': emitted})
            if emitted:
                visit_ident(t['name'])
                for gid in t['goals']:
                    visit_goal(gid, set())
    id_rows = []
    for pointer, row in required.items():
        fallback = string(row['ident']['id_string'])
        restored = row['restore_path']
        qualified = None if restored is None else path(restored['qualified_path'])
        # An absent table binding is an observed absence, never a future empty path.
        assert (row['binding'] is None) == (restored is None)
        selected_fallback = qualified is None or qualified['component_count'] == 0
        chosen = fallback['bytes'] if selected_fallback else qualified['joined_dot_bytes']
        assert row['fallback'] == selected_fallback
        assert row['serializer_name_bytes'] == chosen
        id_rows.append({'pointer': pointer, 'id_tag': row['ident']['id_tag'],
            'serializer_visits': counts['identifier'][pointer], 'fallback': fallback,
            'captured_binding_present': row['binding'] is not None,
            'captured_qualified_path': qualified, 'captured_selected_bytes': chosen,
            'fallback_or_captured_qualified_bytes_upper': max(fallback['bytes'],
                chosen if qualified is None else qualified['joined_dot_bytes']),
            'whole_interval_name_bound_established': False})
    assert set(counts['identifier']) <= set(required)
    goal_rows = [{'id': gid, 'visits': counts['goal'][gid],
        'identifier_pointer': g['name']['pointer'], 'explanation': string(g['explanation'])}
        for gid, g in goals.items()]
    trans_rows = [{'id': tid, 'visits': counts['transformation'][tid],
        'name': string(t['name']), 'arguments': path(t['arguments'])}
        for tid, t in trans.items()]
    totals = {
        'file_path_component_bytes': sum(f['path']['total_bytes'] for f in files),
        'file_format_bytes': sum(f['format']['bytes'] for f in files),
        'identifier_captured_selected_bytes': sum(r['serializer_visits'] * r['captured_selected_bytes'] for r in id_rows),
        'identifier_fallback_or_captured_qualified_bytes_upper': sum(r['serializer_visits'] * r['fallback_or_captured_qualified_bytes_upper'] for r in id_rows),
        'goal_explanation_bytes': sum(r['visits'] * r['explanation']['bytes'] for r in goal_rows),
        'transformation_name_bytes': sum(r['visits'] * r['name']['bytes'] for r in trans_rows),
        'transformation_argument_bytes': sum(r['visits'] * r['arguments']['total_bytes'] for r in trans_rows),
    }
    captured = sum(v for k, v in totals.items() if k != 'identifier_fallback_or_captured_qualified_bytes_upper')
    candidate = captured - totals['identifier_captured_selected_bytes'] + totals['identifier_fallback_or_captured_qualified_bytes_upper']
    return {'files': files, 'theories': theories, 'identifiers': id_rows,
        'goals': goal_rows, 'transformations': trans_rows, 'field_totals': totals,
        'captured_forest_string_bytes': captured,
        'candidate_forest_string_bytes': candidate,
        'visits': {'files': len(files), 'theories_examined': len(theories),
            'theories_serialized': sum(t['serialized'] for t in theories),
            'goals': sum(counts['goal'].values()),
            'transformations': sum(counts['transformation'].values())},
        'missing_binding_serialized_identifier_tags': [r['id_tag'] for r in id_rows
            if r['serializer_visits'] and not r['captured_binding_present']]}


def sources():
    directory = E / 'retained-why-session-helper-source-20261019'
    manifest = get(directory / 'source-identities.json')
    out = []
    with tarfile.open(directory / 'sources.tar.gz') as archive:
        for member, ranges in SOURCE_RANGES.items():
            raw = archive.extractfile(member).read()
            check_identity(raw, manifest['members'][member]['identity'], member)
            lines = raw.decode().splitlines()
            out.append({'archive': str(directory.relative_to(E)) + '/sources.tar.gz',
                'member': member, 'identity': ident(raw), 'ranges': [
                    {'first': a, 'last': b, 'text': '\n'.join(lines[a-1:b])}
                    for a, b in ranges]})
    return out


def extract():
    archive = CaptureArchive()
    joined = get(JOIN / 'result.json')
    by_case = {r['case']: r for r in joined['cases']}
    growth_path = E / 'retained-why-save-attempt-growth-20261020/applications.json'
    growth = {r['case']: r for r in get(growth_path)}
    check_identity(growth_path.read_bytes(), joined['imported_growth_applications_identity'], 'growth applications')
    inputs, results = [], []
    for case in CASES:
        slug = case.replace('_', '-')
        group = 'inline' if case == 'input_is_valid' else 'registration'
        prefix = f'{group}/{case}'
        comparison = get(JOIN / (slug + '-correspondence.json'))
        replay = get(JOIN / (slug + '-replay.json'))
        assert comparison['matched'] and replay['complete']
        combined = dict(comparison['new_inputs'])
        for name, expected in replay['input_identities'].items():
            assert name not in combined or combined[name] == expected, ('overlapping raw identity mismatch', name)
            combined[name] = expected
        for name, expected in combined.items():
            assert archive.members[f'{prefix}/capture/{name}'][1] == expected
        raw = archive.read(f'{prefix}/capture/save-missing-state.json')
        assert ident(raw) == by_case[case]['projection_identity'] == combined['save-missing-state.json']
        projection = json.loads(raw)
        assert projection['complete'] and not projection['failures']
        assert all(v['known'] for v in projection['sections'].values())
        ser = projection['sections']['serializer']['value']
        inv = forest_inventory(ser, projection['sections']['restore_paths']['value'])
        plan = json.loads(archive.read(f'{group}/plan.json'))
        config = archive.read(f'{prefix}/why3.conf')
        selected = selected_provers(config)
        overlay = archive.read(f'{group}/overlay/why3.conf')
        assert overlay == b'[main]\nmagic = 14\n'
        invocation, = [i for i in plan['inputs'] if i['name'] == case]
        argv = invocation['argv']
        assert argv[argv.index('--prover')+1] == 'cvc5,z3,altergo'
        assert argv[argv.index('--proof')+1] == 'per_check'
        assert argv[argv.index('--counterexample')+1] == 'off'
        assert invocation['input']['sha256'] == growth[case]['input_sha256']
        config_path = str(Path(invocation['cwd']) / 'why3.conf')
        overlay_path = argv[argv.index('--why3-conf')+1]
        assert ident(config) == plan['file_identities'][config_path]
        assert ident(overlay) == plan['file_identities'][overlay_path]
        assert not any(x.startswith('--debug') or x in ('--replay', '--proof-dir', '--prepare-shared') for x in argv)
        initial = [prover(p) for p in ser['provers']]
        domain = {prover_key(p): p for p in initial + selected}
        assert all(a['script'] is None for a in ser['attempts'])
        assert all(prover_key(prover(a['prover'])) in domain for a in ser['attempts'])
        assert all(prover_key(prover(r['key'])) in domain
                   for g in ser['goals'] for r in g['attempts']['entries'])
        app = growth[case]
        gr = app['conditional_transfer']
        assert gr == by_case[case]['conditional_growth']
        assert inv['visits']['goals'] == app['inputs']['G']
        assert inv['visits']['transformations'] == app['inputs']['T']
        assert len(domain) <= gr['conditional_prover_key_domain_upper']
        ax = gr['conditional_A_xml_upper']
        status_max = 17
        prover_sum = sum(p['raw_bytes_sum'] for p in domain.values())
        candidate = inv['candidate_forest_string_bytes'] + prover_sum + status_max * ax
        results.append({'case': case, 'pid': comparison['new_pid'],
            'phase': projection['phase'], 'inventory': inv,
            'selected_provers': selected, 'captured_provers': initial,
            'whole_interval_prover_domain': list(domain.values()),
            'prover_string_bytes_upper': prover_sum,
            'attempt_xml_visits_upper': ax, 'status_label_bytes_per_attempt_upper': status_max,
            'status_label_bytes_upper': status_max * ax,
            'remaining_save_entries_upper': gr['remaining_all_save_entries_upper'],
            'candidate_raw_string_bytes_sum_per_save': candidate,
            'candidate_raw_string_bytes_sum_all_remaining_saves': candidate * gr['remaining_all_save_entries_upper'],
            'raw_string_bytes_sum': None,
            'restored_path_continuation_bound_established': False,
            'candidate_additional_premise': 'Every save_ident occurrence uses either the captured fallback id_string or a qualified path whose joined-dot length does not exceed max(captured fallback bytes, captured qualified joined-dot bytes). In particular, bound any later registration for the listed currently unbound serialized identifiers.',
            'scalar_format_bytes_max': None, 'formatter_storage_bound': None,
            'native_allocation_bound': None, 'complete_save_capacity_established': False})
        inputs.append({'case': case, 'projection_identity': ident(raw),
            'comparison_identity': ident((JOIN / (slug + '-correspondence.json')).read_bytes()),
            'replay_identity': ident((JOIN / (slug + '-replay.json')).read_bytes()),
            'raw_evidence_identities_joined_to_archive_manifest': combined,
            'plan_identity': ident(archive.read(f'{group}/plan.json')),
            'argv': argv, 'cwd': invocation['cwd'], 'configuration_identity': ident(config),
            'extra_configuration_identity': ident(overlay)})
    archive.close()
    labels = ['valid', 'failure', 'unknown', 'highfailure', 'timeout', 'outofmemory', 'steplimitexceeded', 'invalid']
    assert max(map(len, labels)) == 17
    return {'scope': 'Retained raw serializer input extraction; U remains unknown without the restored-path continuation premise',
        'input_identities': {'capture_manifest': ident((CAPTURE / 'capture-manifest.json').read_bytes()),
            'accepted_state_join': ident((JOIN / 'result.json').read_bytes()),
            'growth_applications': ident(growth_path.read_bytes())},
        'consumed_archive_members': archive.consumed, 'fresh_input_lineage': inputs,
        'source_witnesses': sources(), 'result_status_labels': labels, 'cases': results,
        'native_runs': 0, 'new_captures': 0, 'collector_replays': 0,
        'binder_recomputations': 0, 'alpha_replays': 0, 'source_fetches': 0}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='write first result only')
    args = parser.parse_args()
    result = extract()
    target = HERE / 'result.json'
    if args.write:
        assert not target.exists(), 'refusing to overwrite retained result'
        target.write_text(json.dumps(result, indent=2) + '\n')
    else:
        assert result == get(target), 'retained result differs'
    print(json.dumps({'cases': [{k: r[k] for k in ('case', 'candidate_raw_string_bytes_sum_per_save', 'raw_string_bytes_sum')} for r in result['cases']], 'retained_result_equal': True}))

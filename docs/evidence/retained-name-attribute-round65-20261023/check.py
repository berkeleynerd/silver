"""Attach accepted R65 freezes without replaying their programs."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def check():
    manifest = read(HERE / 'inputs.json')
    frozen = {}
    for component in manifest['components'].values():
        for path in component['paths']:
            data = (ROOT / path).read_bytes()
            assert data == subprocess.check_output(
                ['git', 'show', component['freeze'] + ':' + path], cwd=ROOT), path
            frozen[path] = identity(data)
    review = read(EV / 'retained-name-attribute-bounds-review-20261023/audit-result.json')
    for path, expected in {**review['exact_inputs'], **review['providers']}.items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    reviewed = {(t['commit'], p) for t in review['targets']['targets'] for p in t['paths']}
    for name in ('hsattr', 'raw_names', 'mapping'):
        component = manifest['components'][name]
        for path in component['paths']:
            assert (component['freeze'], path) in reviewed, (name, path)
    assert review['seven_owner_join']['named_owners'] == 7
    assert review['author_predecessor_native_solver_proof_capture_replays'] == 0

    mapping = read(HERE / 'composition-result.json')
    historical = read(HERE / 'candidate-composition-result.json')
    assert mapping['cases'] == historical['cases']
    for path, expected in mapping['inputs'].items():
        assert identity((EV / path).read_bytes()) == expected, path
    attrs = read(EV / 'retained-why-hsattr-demand-20261023/result.json')
    names = read(EV / 'retained-why-raw-name-length-20261023/result.json')
    nrows = {r['case']: r for r in names['cases']}
    arows = {r['case']: r for r in attrs['cases']}
    rows = []
    assert len(mapping['cases']) == len(nrows) == len(arows) == 5
    for joined in mapping['cases']:
        case = joined['case']
        name, attr = nrows[case], arows[case]
        assert name['name_string_operand_guard']
        assert all(name['integer_and_table_guards'].values())
        assert name['L_pr_hyp_name_input'] == attr['hyp_name_value_bytes_upper']
        assert joined['all_seven_named_owner_operands_fit']
        assert joined['source_join_pending_independent_review']  # Historical mapping status.
        assert not joined['actual_whole_process_headroom']
        rows.append({'case': case, 'seven_named_owner_operands_fit': True,
                     'raw_name_bytes_upper': name['raw_name_L_at_printer_entry'],
                     'unique_name_bytes_upper': name['candidate_or_printed_unique_name_bytes_upper'],
                     'raw_proposition_name_bytes_upper': name['raw_proposition_name_L_pr']})
    assert not mapping['whole_capacity_rule_complete']
    assert not mapping['second_episode_multiplier']
    assert not names['whole_119_capacity']
    assert names['L_pr_uses_separate_hyp_name_provider'] == manifest['components']['hsattr']['freeze']

    pins = read(EV / 'retained-literal-native-completion-20261019/inputs.json')
    for row in pins['repository']:
        assert identity((ROOT / row['path']).read_bytes()) == {
            key: row[key] for key in ('bytes', 'sha256')}
    binary = read(EV / 'retained-printer-entry-collision-review-20261020/native-byte-join.json')
    assert identity(Path(binary['installed_binary']).read_bytes()) == binary['installed_identity']
    # Verbatim source artifacts retain their original relative-link context.
    # Verify both the declared origin and exact copy before using that context.
    copied_sources = {}
    raw_packet = EV / 'retained-why-raw-name-length-20261023'
    for provider in read(raw_packet / 'inputs.json')['hyp_name_provider']:
        copy = raw_packet / provider['retained_copy']
        data = copy.read_bytes()
        assert identity(data) == provider['identity']
        assert data == subprocess.check_output(
            ['git', 'show', provider['commit'] + ':' + provider['path']], cwd=ROOT)
        if copy.suffix == '.md':
            copied_sources[copy] = (ROOT / provider['path']).parent
    links = 0
    paths = set(frozen) | {str(p.relative_to(ROOT)) for p in HERE.iterdir() if p.is_file()}
    for path in paths:
        p = ROOT / path
        if p.suffix == '.py':
            ast.parse(p.read_text(), filename=path)
        if p.suffix == '.md':
            for target in re.findall(r'\]\(([^)]+)\)', p.read_text()):
                if '://' not in target and not target.startswith('#'):
                    destination = (copied_sources.get(p, p.parent) / target.split('#')[0]).resolve()
                    if destination == HERE / 'integration-result.json':
                        continue  # This invocation writes this one output after success.
                    assert destination.exists(), (path, target)
                    links += 1
    return {'status': 'pass', 'frozen_files': frozen, 'cases': rows,
            'new_source_contracts_and_seven_owner_join_independently_accepted': True,
            'raw_name_origin_attachment_established': True,
            'native_source_pins_unchanged': len(pins['repository']),
            'installed_why_unchanged': True, 'local_links': links,
            'verbatim_source_copy_link_contexts_verified': len(copied_sources),
            'whole_process_headroom': False, 'whole_capacity_rule_complete': False,
            'component_checker_replays': 0, 'native_runs': 0}


if __name__ == '__main__':
    started = time.perf_counter()
    result = check()
    result['elapsed_seconds'] = time.perf_counter() - started
    (HERE / 'integration-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k != 'frozen_files'}))

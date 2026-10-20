#!/usr/bin/env python3
"""New initial-count attachment; no target, debugger or predecessor replay."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CAPTURE = 'docs/evidence/retained-why-save-state-capture-20261020/'
CASES = ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid')


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads(path.read_text())


def derive(inputs):
    for name, expected in inputs['files'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in inputs['local_files'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    manifest = read(ROOT / (CAPTURE + 'capture-manifest.json'))
    records, raw_members = {}, {}
    for archive in manifest['archives']:
        path = CAPTURE + archive['path']
        expected = {m['member']: m['identity'] for m in inputs['members']
                    if m['archive'] == path}
        retained = {m['path']: {k: m[k] for k in ('bytes', 'sha256')}
                    for m in archive['members']}
        assert all(retained[n] == h for n, h in expected.items())
        with tarfile.open(ROOT / path, 'r|gz') as stream:
            for member in stream:
                if member.name not in expected:
                    continue
                raw = stream.extractfile(member).read()
                assert identity(raw) == expected[member.name], member.name
                raw_members[member.name] = raw
                if member.name.endswith('.json'):
                    records[member.name] = json.loads(raw)
        assert set(expected) <= set(raw_members)
    query = read(HERE / 'debugger-signal-defaults.json')
    assert query['returncode'] == 0
    # Clean captured environment has no HOME/XDG cache location. Retain the
    # exact harmless warning rather than misreporting an empty stderr.
    assert query['stderr'] == (query['command'][0] +
        ": warning: Couldn't determine a path for the index cache directory.\n")
    assert not query['target_loaded'] and not query['target_executed']
    for signal in ('SIGINT', 'SIGSEGV', 'SIGBUS'):
        assert re.search(r'^' + signal + r'\s+Yes\s+Yes\s+', query['stdout'], re.M)
    assert query['command'][1:4] == ['-nx', '-q', '-batch']
    for group in ('registration', 'inline'):
        plan = records[group + '/plan.json']
        assert plan['file_identities'][query['command'][0]] == query['binary']
        assert plan['protected_start'] == 'camlWhy3__Exn_printer__entry'
        launcher = raw_members[group + '/run.py'].decode()
        assert "'-nx','-q','-batch'" in launcher.replace(' ', '')
        assert 'set auto-load off' in launcher
    cases = []
    for case in CASES:
        group = 'inline' if case == 'input_is_valid' else 'registration'
        base = group + '/' + case + '/capture/'
        summary, counter, process = (records[base + n] for n in
                                    ('summary.json', 'identifier-state.json', 'process.json'))
        script = raw_members[base + 'probe.gdb'].decode()
        lines = [line.strip() for line in script.splitlines()]
        assert lines.count('starti') == lines.count('continue') == 1
        assert lines.index('starti') < lines.index('continue') < lines.index('finish_capture()')
        assert 'set auto-load off' in lines
        assert not any(re.match(r'(?:handle|signal|run|step|next|finish)\b', line)
                       for line in lines)
        log = raw_members[base + 'debugger.log'].decode()
        assert not re.search(r'(?:Program|Thread .*?) received signal', log)
        assert summary['completed'] and not summary['failures'] and not summary['guard_hits']
        assert not summary['new_threads'] and process['initial_threads'] == 1
        assert identity(raw_members[base + 'identifier-state.json']) == summary['identifier_state']['identity']
        value = counter['counter']['decoded']
        assert value == summary['identifier_state']['counter']
        raw = counter['counter']['fields'][0]
        assert raw == 2*value + 1 and 0 <= value < 2**62
        endpoint = 'inline_trivial_entry' if group == 'inline' else 'end_of_registration'
        rows = [r for r in summary['snapshots'] if r['label'] == endpoint]
        assert len(rows) == 1
        row = rows[0]
        assert row['native_r14'] == row['state_address']
        words = row['minor_allocated_words']
        assert words == (row['state']['young_alloc_end'] - row['effective_young_ptr']) // 8
        assert row['state']['minor_heap_wsz'] == 2**28
        assert 5*value <= words < 2**28 < 5*2**62
        cases.append({'case': case, 'pid': process['pid'], 'endpoint': endpoint,
                      'minor_allocated_words': words, 'initial_registration_count': value,
                      'initial_type_symbol_count_upper': value,
                      'initial_tuple_registry_entries_upper': value,
                      'initial_two_arity_family_union_upper': 2*value})
    witnesses = read(HERE / 'source-witnesses.json')
    with tarfile.open(ROOT / witnesses[0]['archive']) as archive:
        cache = {}
        for witness in witnesses:
            member = witness['member']
            if member not in cache:
                cache[member] = archive.extractfile(member).read()
            raw = cache[member]
            assert identity(raw) == witness['member_identity']
            text = ''.join(raw.decode().splitlines(keepends=True)[witness['first_line']-1:witness['last_line']])
            assert text == witness['text']
    return {'scope': 'Actual retained debugger-controlled prefixes under documented source/runtime relation',
            'cases': cases, 'initial_no_wrap_established_under_named_relation': True,
            'later_no_wrap_established': False, 'complete_writer_capacity_established': False,
            'native_target_runs': 0, 'predecessor_checker_replays': 0}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    inputs = read(HERE / 'inputs.json')
    result = derive(inputs)
    raw = (json.dumps(result, indent=2) + '\n').encode()
    if args.write:
        (HERE / 'result.json').write_bytes(raw)
    else:
        assert (HERE / 'result.json').read_bytes() == raw
    print(json.dumps({'status': 'pass', 'retained_cases': len(result['cases']),
                      'selected_members': len(inputs['members']),
                      'source_excerpts': len(read(HERE / 'source-witnesses.json')),
                      'elapsed_seconds': time.monotonic()-start,
                      'native_target_runs': 0, 'debugger_queries_in_this_check': 0,
                      'predecessor_checker_replays': 0}, indent=2))


if __name__ == '__main__':
    main()

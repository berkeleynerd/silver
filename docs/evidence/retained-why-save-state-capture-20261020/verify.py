#!/usr/bin/env python3
"""Stream archive/member hashes and saved facts; optionally extract a new tree.

No native target, observer, session replay, binder interpreter or solver runs.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import tarfile
import time

HERE = Path(__file__).resolve().parent
CASES = ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid')
ARCHIVES = ('capture-common.tar.gz',) + tuple(
    'capture-' + name.replace('_', '-') + '.tar.gz' for name in CASES)
METADATA_SUFFIXES = ('/plan.json', '/result.json', '/process.json', '/summary.json',
    '/server.json', '/session-root.json', '/events.jsonl', '/native.log',
    '/extension-preflight.json', '-plan-before-extension.json')
CHUNK = 1024 * 1024
MEMBER_BUFFER = 4 * CHUNK
TOTAL_BUFFER = 16 * CHUNK


def require(condition, message):
    if not condition:
        raise ValueError(message)


def hash_stream(stream, sink=None, buffer=None):
    digest, size = hashlib.sha256(), 0
    for chunk in iter(lambda: stream.read(CHUNK), b''):
        digest.update(chunk)
        size += len(chunk)
        if sink is not None:
            sink.write(chunk)
        if buffer is not None:
            buffer.write(chunk)
    return dict(bytes=size, sha256=digest.hexdigest())


def identity(path):
    with path.open('rb') as stream:
        return hash_stream(stream)


def expected_identity(row):
    return {key: row[key] for key in ('bytes', 'sha256')}


def safe_name(value):
    name = PurePosixPath(value)
    require(bool(value) and bool(name.parts) and not name.is_absolute() and str(name) == value and
        all(part not in ('..', '.') and ':' not in part for part in name.parts) and
        '\\' not in value and '\0' not in value, 'unsafe member name: ' + repr(value))
    return name


def stream_archives(manifest, extraction=None, collect=True):
    cache, index, records = {}, {}, []
    for archive in manifest['archives']:
        path = HERE / archive['path']
        require(path.stat().st_size < 100_000_000, 'oversized archive')
        require(identity(path) == expected_identity(archive), 'archive hash differs: ' + path.name)
        expected = {row['path']: row for row in archive['members']}
        require(len(expected) == len(archive['members']), 'duplicate manifest member')
        for member_name, row in expected.items():
            safe_name(member_name)
            require(member_name not in index, 'duplicate member across archives')
            index[member_name] = row
        found, expanded = [], 0
        with tarfile.open(path, mode='r|gz') as stream:
            for member in stream:
                name = safe_name(member.name)
                require(member.isfile() and not member.issym() and not member.islnk(),
                    'only regular files are allowed')
                require(member.name in expected and member.name not in found, 'unexpected/duplicate member')
                row = expected[member.name]
                require(member.size == row['bytes'], 'member size differs')
                wanted = collect and member.name.endswith(METADATA_SUFFIXES)
                if wanted:
                    require(member.size <= MEMBER_BUFFER, 'metadata exceeds member buffer')
                    require(sum(map(len, cache.values())) + member.size <= TOTAL_BUFFER,
                        'metadata exceeds total buffer')
                buffer = io.BytesIO() if wanted else None
                source = stream.extractfile(member)
                if extraction is None:
                    actual = hash_stream(source, buffer=buffer)
                else:
                    destination = extraction.joinpath(*name.parts)
                    destination.parent.mkdir(parents=True, exist_ok=True)
                    with destination.open('xb') as sink:
                        actual = hash_stream(source, sink=sink, buffer=buffer)
                require(actual == expected_identity(row), 'member hash differs: ' + member.name)
                if buffer is not None:
                    cache[member.name] = buffer.getvalue()
                found.append(member.name)
                expanded += member.size
        require(found == list(expected), 'archive membership/order differs')
        records.append(dict(path=path.name, compressed_bytes=archive['bytes'],
            members=len(found), expanded_bytes=expanded, all_hashes_match=True))
    return cache, index, records


def saved_facts(manifest, cache, index):
    def load(member):
        return json.loads(cache[member])

    require(manifest['schema'] == 1 and manifest['native_process_cases'] == 5, 'unexpected packet scope')
    require(tuple(group['prefix'] for group in manifest['groups']) == ('registration', 'inline'),
        'unexpected groups')
    preflight = load('preparation/extension-preflight.json')
    facts = []
    for group in manifest['groups']:
        prefix, run_id = group['prefix'], group['managed_run']
        plan = load(prefix + '/plan.json')
        require(expected_identity(index[prefix + '/plan.json']) == group['plan_identity'],
            'plan identity differs')
        require(load(prefix + '/result.json') == group['capture_result'], 'aggregate result differs')
        names = CASES[:4] if prefix == 'registration' else CASES[4:]
        require(tuple(case['name'] for case in plan['inputs']) == names and
            tuple(case['name'] for case in group['cases']) == names and
            tuple(case['name'] for case in group['capture_result']['cases']) == names,
            'selected cases differ')
        require(len(plan['file_identities']) == group['historical_pre_post_identity_count'],
            'historical identity count differs')
        for row in group['local_plan_inputs_rehashed']:
            require(plan['file_identities'][row['original']] == expected_identity(row) ==
                expected_identity(index[row['member']]), 'local plan input identity differs')
        extension, = [row for row in preflight if row['root'] == group['original_root']]
        require(extension['new_plan'] == group['plan_identity'] and
            extension['collector_commit'] == manifest['collector_commit'] and
            extension['file_identities_checked'] == len(plan['file_identities']),
            'extension preflight differs')
        before = 'preparation/' + Path(group['original_root']).name + '-plan-before-extension.json'
        require(extension['prior_plan'] == expected_identity(index[before]), 'prior plan identity differs')
        events = [json.loads(line) for line in cache['managed/' + run_id + '/events.jsonl'].splitlines()]
        start, = [row for row in events if row['event'] == 'started']
        end, = [row for row in events if row['event'] == 'finished']
        require(start['run_id'] == end['run_id'] == run_id and start['workers'] == group['workers'] == 1,
            'managed identity/allocation differs')
        require(end['outcome'] == 'success' and not end['failure_keys'] and
            end['duration_seconds'] == group['managed_seconds'], 'managed outcome differs')
        require(start['host'] == group['native_platform'] == 'linux-x86_64' and
            start['machine'] == group['machine'], 'native host differs')
        require(plan['endpoint'] == group['recorded_plan_endpoint'], 'recorded plan endpoint differs')
        if prefix == 'registration':
            require(b'All five registration segments completed;' in
                cache['managed/' + run_id + '/native.log'], 'historical wording missing')
            require(group['actual_stopped_endpoint']['symbol'] == plan['endpoint']['symbol'],
                'registration endpoint differs')
        else:
            require(group['actual_stopped_endpoint']['symbol'] == plan['entry_observers']['apply']['symbol'],
                'inline endpoint differs')
        for case, saved, result in zip(plan['inputs'], group['cases'], group['capture_result']['cases']):
            member = prefix + '/' + case['name']
            summary = load(member + '/capture/summary.json')
            process = load(member + '/capture/process.json')
            require(summary['completed'] and not summary['failures'] and not summary['guard_hits'],
                'unsuccessful capture summary')
            require(all(row['hits'] == 0 for row in summary['forbidden_calls'].values()),
                'forbidden call observed')
            require(result['completed'] and result['returncode'] == 0 and not result['timed_out']
                and not result['failures'] and not result['guard_hits'], 'unsuccessful case result')
            require(load(member + '/capture/result.json') == result, 'case/aggregate result differs')
            require(process['argv'] == case['argv'] and process['environment'] == case['environment']
                and process['pid'] == saved['pid'], 'process identity differs')
            require(saved['member_prefix'] == member and saved['debugger_seconds'] == result['duration_seconds'],
                'case manifest differs')
            require(expected_identity(index[member + '/' + Path(case['argv'][-1]).name]) == case['input'],
                'selected input differs')
            for suffix in ('save-missing-state.json', 'save-state-memory-reads.jsonl', 'session-root.json'):
                require(member + '/capture/' + suffix in index, 'missing retained collector member')
            if prefix == 'inline':
                require(summary['inline_entry'] is not None and
                    summary['driver_preparation'][0]['visited_directives'] ==
                    ['counterexamples_dependent_intros', 'inline_trivial'], 'inline stop differs')
            facts.append(dict(case=case['name'], pid=process['pid'], completed=True,
                protected_guard_hits=0, forbidden_call_hits=0, managed_run=run_id,
                member_prefix=member, actual_phase=group['actual_stopped_endpoint']['kind']))
    return facts


def verify(extraction=None):
    timer = time.perf_counter()
    if extraction is not None:
        require(not extraction.exists() and not extraction.is_symlink(), 'extraction root must be new')
    manifest_path = HERE / 'capture-manifest.json'
    require(manifest_path.stat().st_size <= MEMBER_BUFFER, 'manifest exceeds buffer')
    manifest = json.loads(manifest_path.read_bytes())
    require(tuple(row['path'] for row in manifest['archives']) == ARCHIVES, 'unexpected archive set')
    cache, index, records = stream_archives(manifest)
    facts = saved_facts(manifest, cache, index)
    if extraction is not None:
        extraction.mkdir(parents=True, exist_ok=False)
        # Validate the whole packet before writing. Recheck archive/member bytes
        # during extraction; never use extractall or follow archive links.
        stream_archives(manifest, extraction=extraction, collect=False)
    return dict(status='passed', recorded_UTC=datetime.now(timezone.utc).isoformat(),
        manifest_identity=identity(manifest_path), native_platform='linux-x86_64',
        archives=records, archives_verified=len(records), members_verified=len(index),
        expanded_bytes_streamed=sum(row['expanded_bytes'] for row in records),
        all_archives_below_100000000_bytes=True, maximum_read_chunk_bytes=CHUNK,
        metadata_member_limit_bytes=MEMBER_BUFFER, total_metadata_cache_limit_bytes=TOTAL_BUFFER,
        recorded_capture_facts=facts, historical_managed_runs=[dict(
            run_id=group['managed_run'], duration_seconds=group['managed_seconds'], workers=group['workers'],
            pre_post_input_identity_count=group['historical_pre_post_identity_count'])
            for group in manifest['groups']],
        installed_dependencies_rehashed=False, observed_state_replayed=False,
        extraction_passes=1 if extraction is not None else 0,
        extracted_to=str(extraction) if extraction is not None else None,
        native_processes_started=0, observer_replays=0, binder_or_alpha_analyses=0,
        solver_requests=0, proof_runs=0, elapsed_seconds=time.perf_counter() - timer)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--extract', type=Path, help='Optional new directory; verify first, then write exact regular-file members')
    args = parser.parse_args()
    result = verify(args.extract)
    if args.output is not None:
        args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: result[key] for key in (
        'status', 'archives_verified', 'members_verified', 'expanded_bytes_streamed', 'elapsed_seconds')}))

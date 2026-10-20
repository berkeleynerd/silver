#!/usr/bin/env python3
"""Stream-check named capture archives; optionally extract only verified members.

No native process, analyzer replay, binder interpretation or solver is invoked.
Extraction is restricted to the manifest's named regular files in a new root.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import importlib.util
import io
import json
from pathlib import Path, PurePosixPath
import tarfile
import tempfile
import time

HERE = Path(__file__).resolve().parent
CASES = ('put_line', 'put', 'first_or_default', 'is_message')
ARCHIVES = ('capture-common.tar.gz',) + tuple('capture-'+name.replace('_','-')+'.tar.gz' for name in CASES)


def hash_stream(stream, sink=None):
    digest, size = hashlib.sha256(), 0
    for chunk in iter(lambda: stream.read(1024*1024), b''):
        digest.update(chunk)
        size += len(chunk)
        if sink is not None:
            sink.write(chunk)
    return dict(bytes=size, sha256=digest.hexdigest())


def identity(path):
    with path.open('rb') as stream:
        return hash_stream(stream)


def load_json(path):
    return json.loads(path.read_bytes())


def verify(extraction=None):
    timer = time.perf_counter()
    manifest = load_json(HERE/'capture-manifest.json')
    assert tuple(row['path'] for row in manifest['archives']) == ARCHIVES
    if extraction is not None:
        # A new directory has no existing symlinks/files that could redirect
        # these explicitly checked regular-file destinations.
        assert not extraction.exists(), 'extraction root must be new'
        extraction.mkdir(parents=True)
    cache, archives = {}, []
    for archive in manifest['archives']:
        path = HERE/archive['path']
        assert path.stat().st_size < 100_000_000
        assert identity(path) == {k: archive[k] for k in ('bytes','sha256')}
        expected = {row['path']: row for row in archive['members']}
        assert len(expected) == len(archive['members'])
        found, expanded = [], 0
        with tarfile.open(path, mode='r|gz') as stream:
            for member in stream:
                name = PurePosixPath(member.name)
                assert member.isfile() and not member.issym() and not member.islnk()
                assert not name.is_absolute() and '..' not in name.parts
                assert str(name) == member.name and member.name in expected and member.name not in found
                row = expected[member.name]
                assert member.size == row['bytes']
                wanted = (archive['path'] == 'capture-common.tar.gz' or
                    member.name.endswith(('/process.json','/summary.json','/result.json','.gnat-json')))
                if wanted:
                    assert member.size <= 4*1024*1024, 'selected metadata exceeds bounded buffer'
                buffer = io.BytesIO() if wanted else None
                destination = extraction.joinpath(*name.parts) if extraction is not None else None
                if destination is not None:
                    destination.parent.mkdir(parents=True, exist_ok=True)
                    with destination.open('xb') as target:
                        # Keep only small selected metadata in memory. Full
                        # raw logs are always streamed in bounded chunks.
                        source = stream.extractfile(member)
                        digest = hashlib.sha256()
                        size = 0
                        for chunk in iter(lambda: source.read(1024*1024), b''):
                            digest.update(chunk); size += len(chunk); target.write(chunk)
                            if buffer is not None: buffer.write(chunk)
                        actual = dict(bytes=size, sha256=digest.hexdigest())
                else:
                    actual = hash_stream(stream.extractfile(member), buffer)
                assert actual == {k: row[k] for k in ('bytes','sha256')}, member.name
                if buffer is not None:
                    cache[member.name] = buffer.getvalue()
                    assert sum(len(value) for value in cache.values()) <= 16*1024*1024
                found.append(member.name)
                expanded += member.size
        assert found == list(expected), 'archive membership/order differs'
        archives.append(dict(path=archive['path'], compressed_bytes=archive['bytes'],
            members=len(found), expanded_bytes=expanded, all_hashes_match=True))
    plan = json.loads(cache['plan.json'])
    assert len(plan['file_identities']) == 201
    assert tuple(case['name'] for case in plan['inputs']) == CASES
    assert manifest['native_process_cases'] == 4 and manifest['workers'] == 1
    assert json.loads(cache['result.json']) == manifest['capture_result']
    events = [json.loads(line) for line in cache['managed/events.jsonl'].splitlines()]
    end, = [row for row in events if row['event'] == 'finished']
    assert end['outcome'] == 'success' and end['duration_seconds'] == 247.745976497
    assert b'All five registration segments completed;' in cache['managed/native.log']
    for case in plan['inputs']:
        name = case['name']
        summary = json.loads(cache[name+'/capture/summary.json'])
        process = json.loads(cache[name+'/capture/process.json'])
        result = json.loads(cache[name+'/capture/result.json'])
        assert summary['completed'] and not summary['failures'] and not summary['guard_hits']
        assert all(row['hits'] == 0 for row in summary['forbidden_calls'].values())
        assert result['completed'] and result['returncode'] == 0 and not result['timed_out']
        assert process['argv'] == case['argv'] and process['environment'] == case['environment']
        analysis = load_json(HERE/(name.replace('_','-')+'-analysis.json'))
        assert analysis['pid'] == process['pid'] and analysis['case'] == name
        assert analysis['source_inputs']['plan'] == hash_stream(io.BytesIO(cache['plan.json']))
        assert analysis['source_inputs']['process'] == hash_stream(io.BytesIO(cache[name+'/capture/process.json']))
        assert analysis['native_executions_by_analyzer'] == 0
    # A selected identity-only relocation test exercises the changed helper,
    # without replaying any session reads or repeating binder computations.
    spec = importlib.util.spec_from_file_location('relocated_identity_test', HERE/'analyze.py')
    analyzer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(analyzer)
    case = plan['inputs'][0]
    with tempfile.TemporaryDirectory(prefix='fixed-session-identity-') as directory:
        relocated = Path(directory)/'captured'/case['name']/'capture'
        relocated.mkdir(parents=True)
        (relocated.parent/case['argv'][-1]).write_bytes(cache[case['name']+'/'+case['argv'][-1]])
        (relocated.parent.parent/'session_observer.py').write_bytes(cache['session_observer.py'])
        assert str(relocated.parent) != case['cwd']
        actual = analyzer.verify_input_identities(relocated, plan, case)
        assert actual == (relocated.parent/case['argv'][-1], relocated.parent.parent/'session_observer.py')
    return dict(status='passed', native_platform='linux-x86_64',
        recorded_UTC=datetime.now(timezone.utc).isoformat(), archives=archives,
        archives_verified=len(archives), members_verified=sum(row['members'] for row in archives),
        expanded_bytes_streamed=sum(row['expanded_bytes'] for row in archives),
        all_archives_below_100000000_bytes=True, maximum_read_chunk_bytes=1024*1024,
        metadata_member_limit_bytes=4*1024*1024, total_metadata_cache_limit_bytes=16*1024*1024,
        selected_identity_relocation_test=dict(case=case['name'], files=2,
            recorded_keys='case.cwd / input basename; case.cwd parent / session_observer.py',
            analyzer_replayed=False, binder_analysis_repeated=False),
        prior_runner_contract=dict(recorded_pre_post_input_identities=201,
            current_201_installed_files_rehashed=False, completed_native_cases=4,
            managed_duration_seconds=end['duration_seconds'], workers=1,
            original_runner_All_five_wording_preserved=True),
        extracted_to=str(extraction) if extraction is not None else None,
        native_processes_started=0, analyzer_replays=0, binder_analyses=0,
        elapsed_seconds=time.perf_counter()-timer)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--extract', type=Path,
        help='Optional new extraction root; only checked manifest regular files are written')
    args = parser.parse_args()
    result = verify(args.extract)
    if args.output:
        args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ('status','archives_verified','members_verified','expanded_bytes_streamed','elapsed_seconds')}))

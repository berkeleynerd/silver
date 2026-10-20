#!/usr/bin/env python3
"""Retain completed, stopped captures; never start a target or replay an observer."""
import argparse
from datetime import datetime, timezone
import gzip
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
REPOSITORY = Path('/home/canto/src/github.com/berkeleynerd/silver')
COLLECTOR = 'f3baf9cdfa068496a4034c16f77e9fbcd756420a'
RUNS = ('20261020T091152-10d928ebc9aa', '20261020T091635-344f0aadb4bb')
CASES = (('put_line', 'put', 'first_or_default', 'is_message'), ('input_is_valid',))
PREPARATION = ('prepare_roots.py', 'relocation.json', 'extension-preflight.json',
    'wse-20261020-extension.diff', 'wse-20261020-plan-before-extension.json',
    'why-session-save-capture-ready-20261020-extension.diff',
    'why-session-save-capture-ready-20261020-plan-before-extension.json')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def identity(path):
    digest, size = hashlib.sha256(), 0
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
            size += len(chunk)
    return dict(bytes=size, sha256=digest.hexdigest())


def load(path):
    return json.loads(path.read_bytes())


def regular_files(root):
    files = []
    for path in root.rglob('*'):
        require(not path.is_symlink(), 'unexpected symlink: ' + str(path))
        if path.is_file() and '__pycache__' not in path.parts:
            files.append(path)
    return sorted(files)


def pack(out, name, files):
    destination = out / name
    require(not destination.exists(), 'refuse to overwrite archive: ' + str(destination))
    members = []
    require(len({name for name, _ in files}) == len(files), 'duplicate archive member')
    with destination.open('xb') as raw, gzip.GzipFile(filename='', mode='wb',
            fileobj=raw, mtime=0, compresslevel=6) as compressed, \
            tarfile.open(fileobj=compressed, mode='w') as archive:
        for member, source in sorted(files):
            before = source.stat()
            row = identity(source)
            info = tarfile.TarInfo(member)
            info.size, info.mode, info.mtime = row['bytes'], 0o644, 0
            with source.open('rb') as stream:
                archive.addfile(info, stream)
            after = source.stat()
            require((before.st_ino, before.st_size, before.st_mtime_ns) ==
                (after.st_ino, after.st_size, after.st_mtime_ns), 'input changed: ' + str(source))
            members.append(dict(path=member, **row))
    record = dict(path=name, **identity(destination), members=members)
    require(record['bytes'] < 100_000_000, name + ' exceeds archive size ceiling')
    print(json.dumps(dict(path=name, bytes=record['bytes'], members=len(members))), flush=True)
    return record


def main(args):
    timer = time.perf_counter()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    require(not (out / 'capture-manifest.json').exists(), 'manifest already exists')
    common, captures, groups = [], [], []
    for prefix, root, run_id, cases in zip(('registration', 'inline'),
            (args.registration_root, args.inline_root), RUNS, CASES):
        plan, aggregate = load(root / 'plan.json'), load(root / 'result.json')
        require(tuple(case['name'] for case in plan['inputs']) == cases, 'unexpected selected cases')
        require(tuple(case['name'] for case in aggregate['cases']) == cases, 'incomplete aggregate result')
        run = args.managed_directory / run_id
        events = [json.loads(line) for line in (run / 'events.jsonl').read_bytes().splitlines()]
        starts = [row for row in events if row['event'] == 'started']
        ends = [row for row in events if row['event'] == 'finished']
        require(len(starts) == len(ends) == 1, 'managed run is not durably completed')
        start, end = starts[0], ends[0]
        require(end['outcome'] == 'success' and not end['failure_keys'], 'managed capture failed')
        require(start['run_id'] == end['run_id'] == run_id and start['workers'] == 1,
            'unexpected managed run identity/allocation')
        included = [(prefix + '/' + path.name, path) for path in root.iterdir() if path.is_file()]
        included += [(prefix + '/overlay/' + path.name, path)
            for path in (root / 'overlay').iterdir() if path.is_file()]
        common += included
        common += [('managed/' + run_id + '/' + name, run / name)
            for name in ('events.jsonl', 'native.log')]
        # Rehash retained local inputs only. Installed tool/source identities
        # remain the original runner's pre/post contract, not a new audit.
        local_identities = []
        for original, expected in plan['file_identities'].items():
            source = Path(original)
            if source.is_relative_to(root):
                require(identity(source) == expected, 'changed local plan input: ' + original)
                local_identities.append(dict(original=original,
                    member=prefix + '/' + source.relative_to(root).as_posix(), **expected))
        records = []
        for case, result in zip(plan['inputs'], aggregate['cases']):
            name = case['name']
            capture = root / name / 'capture'
            summary, process = load(capture / 'summary.json'), load(capture / 'process.json')
            require(result['completed'] and result['returncode'] == 0 and not result['timed_out']
                and not result['failures'] and not result['guard_hits'], 'case failed: ' + name)
            require(summary['completed'] and not summary['failures'] and not summary['guard_hits'],
                'incomplete summary: ' + name)
            require(all(row['hits'] == 0 for row in summary['forbidden_calls'].values()),
                'forbidden call: ' + name)
            require(process['argv'] == case['argv'] and process['environment'] == case['environment'],
                'process identity differs: ' + name)
            require(load(capture / 'result.json') == result, 'aggregate/case result differs')
            require((capture / 'save-missing-state.json').is_file() and
                (capture / 'save-state-memory-reads.jsonl').is_file(), 'missing collector output')
            if prefix == 'inline':
                require(summary['inline_entry'] is not None, 'actual inline entry was not reached')
            archive = 'capture-' + name.replace('_', '-') + '.tar.gz'
            captures.append((archive, [(prefix + '/' + path.relative_to(root).as_posix(), path)
                for path in regular_files(root / name)]))
            records.append(dict(name=name, pid=process['pid'], archive=archive,
                member_prefix=prefix + '/' + name, debugger_seconds=result['duration_seconds'],
                completed=True, no_failures=True, no_protected_guard_hits=True,
                forbidden_call_hits=0))
        actual_endpoint = (dict(kind='registration', symbol=plan['endpoint']['symbol'])
            if prefix == 'registration' else dict(kind='first Input_Is_Valid/cvc5 inline_trivial entry',
                symbol=plan['entry_observers']['apply']['symbol'],
                condition="visited_directives == ['counterexamples_dependent_intros', 'inline_trivial']"))
        groups.append(dict(prefix=prefix, original_root=str(root), managed_run=run_id,
            managed_seconds=end['duration_seconds'], workers=start['workers'],
            native_platform=start['host'], machine=start['machine'],
            historical_pre_post_identity_count=len(plan['file_identities']),
            plan_identity=identity(root / 'plan.json'), local_plan_inputs_rehashed=local_identities,
            recorded_plan_endpoint=plan['endpoint'], actual_stopped_endpoint=actual_endpoint,
            capture_result=aggregate, cases=records))
    common += [('preparation/' + name, args.preparation / name) for name in PREPARATION]
    archives = [pack(out, 'capture-common.tar.gz', common)]
    archives += [pack(out, name, files) for name, files in captures]
    manifest = dict(schema=1, recorded_UTC=datetime.now(timezone.utc).isoformat(),
        authorization='Active owner-requested #119/#153 Round28; bounded stopped-capture retention',
        base_commit='22c5d9274ac7fe6ab7797aef378a3bcb4b4afafe', collector_commit=COLLECTOR,
        scope='Five fresh stopped native captures; archive/hash and recorded metadata checks only',
        native_process_cases=5, groups=groups, archives=archives,
        exclusions=['directories and runtime socket files', '__pycache__ bytecode',
            'preparation-directory replay/comparator outputs owned by the numeric packet'],
        limitations=[
            'Registration runner original stdout/docstring says five; its plan/results contain four cases.',
            'Inline plan endpoint remains inherited registration metadata; probe/inline-entry summary identify the actual first cvc5 inline stop.',
            'Startup guard observations precede protected_start; no protected-interval guard hit is recorded.',
            'No observer/session replay, binder/alpha computation, solver request or proof execution is performed by this packager.',
            'The packet retains observations; capacity, per-process numeric attachment, complete R and #153 completion remain separate.',
            'Diagnostic limits are not language admission thresholds; Oracle, tools, pins and admitted production source are unchanged.'],
        packaging_seconds=time.perf_counter() - timer)
    (out / 'capture-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(dict(status='packaged', archives=len(archives),
        packaging_seconds=manifest['packaging_seconds'])))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--registration-root', type=Path, default=REPOSITORY / 'tmp/wse-20261020')
    parser.add_argument('--inline-root', type=Path,
        default=REPOSITORY / 'tmp/why-session-save-capture-ready-20261020')
    parser.add_argument('--managed-directory', type=Path, default=REPOSITORY /
        '.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs')
    parser.add_argument('--preparation', type=Path, default=REPOSITORY /
        'tmp/retained-tool-capacity/tmp/save-state-capture-20261020')
    parser.add_argument('--output', type=Path, default=HERE)
    main(parser.parse_args())

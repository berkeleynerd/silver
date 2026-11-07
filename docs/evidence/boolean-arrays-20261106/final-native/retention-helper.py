"""Retain completed native evidence; never run a proof, build, test or Git mutation."""
from pathlib import Path
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import shutil
import subprocess
import sys
import tarfile


NATIVE = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/empty-loop-repair')
FEATURE = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/boolean-arrays')
SCRATCH = NATIVE / 'tmp/boolean-array-producer'
REGISTRY = Path('/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs')
AUDIT_ID = None  # Set only from an actual successful repaired audit run.
DESTINATION = FEATURE / 'docs/evidence/boolean-arrays-20261106/final-native'


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + '\n')


def git(root, *args):
    return subprocess.check_output(['git', *args], cwd=root, text=True).strip()


def completed(run_id):
    events = [json.loads(line) for line in (REGISTRY / run_id / 'events.jsonl').read_text().splitlines()]
    assert events[-1]['event'] == 'finished', (run_id, events[-1]['event'])
    assert events[-1]['outcome'] == 'success', (run_id, events[-1])
    return events


def add_archive(output, members):
    entries = []
    with tarfile.open(output, 'w:gz') as archive:
        for original, name in members:
            assert original.is_file(), original
            archive.add(original, arcname=name, recursive=False)
            entries.append({'path': name, 'original': str(original), 'bytes': original.stat().st_size,
                            'sha256': sha(original)})
    # Verify actual retained bytes, rather than only the sources supplied to tar.
    with tarfile.open(output, 'r:gz') as archive:
        assert archive.getnames() == [entry['path'] for entry in entries]
        for entry in entries:
            with archive.extractfile(entry['path']) as stream:
                assert hashlib.file_digest(stream, 'sha256').hexdigest() == entry['sha256']
    return entries


def main():
    global AUDIT_ID
    parser = argparse.ArgumentParser()
    parser.add_argument('--audit-run', required=True)
    parser.add_argument('--build-run', required=True)
    args = parser.parse_args()
    assert args.audit_run != '20261106T232644-673fc5a9c06b', 'Original failed audit cannot be reused as successful evidence'
    AUDIT_ID = args.audit_run
    audit_events = completed(AUDIT_ID)
    build_events = completed(args.build_run)
    assert not DESTINATION.exists(), DESTINATION
    stage = SCRATCH / 'repaired-final-native-delivery'
    assert not stage.exists(), stage
    stage.mkdir()
    status_before = git(FEATURE, 'status', '--short')
    reports = NATIVE / '.silver/linux-x86_64/compiler/obj/review-final/gnatprove'
    retained = REGISTRY / AUDIT_ID / 'proof-evidence'
    manifest = json.loads((reports / 'proof-provenance.json').read_text())
    assert manifest['complete'] is True and manifest['mode'] == 'full'
    sys.path.insert(0, str(NATIVE))
    from scripts.platforms import native_layout
    from scripts.proof_provenance import input_hashes
    assert input_hashes(native_layout(NATIVE)) == manifest['inputs_sha256']
    for name, expected in manifest['reports_sha256'].items():
        assert sha(reports / name) == expected, name
        assert sha(retained / name) == expected, name
    assert (retained / 'proof-provenance.json').read_bytes() == (reports / 'proof-provenance.json').read_bytes()
    snap = json.loads((SCRATCH / 'validation-repaired-final-inputs.json').read_text())
    assert manifest['inputs_sha256'] == snap['all_preflight_inputs']
    prepared_comparison = SCRATCH / 'repaired-managed-preflight-comparison.json'
    comparison_record = json.loads(prepared_comparison.read_text())
    assert comparison_record['run_id'] == AUDIT_ID
    assert comparison_record['all_prepared_inputs_match_verified_snapshot'] is True
    shutil.copy2(prepared_comparison, stage / 'managed-preflight-comparison.json')
    comparison = []
    for relative, expected in snap['inputs'].items():
        current = sha(NATIVE / relative)
        feature = sha(FEATURE / relative)
        assert current == feature == expected, relative
        comparison.append({'path': relative, 'recorded_sha256': expected,
                           'native_sha256': current, 'feature_sha256': feature})
    expected_inventory = {name for name in snap['inputs'] if name.startswith(('src/', 'scripts/'))}
    inventory_comparison = {}
    for label, root in (('native', NATIVE), ('feature', FEATURE)):
        actual = {str(path.relative_to(root))
                  for directory, suffixes in (('src', {'.adb', '.ads'}), ('scripts', {'.py'}))
                  for path in (root / directory).rglob('*')
                  if path.is_file() and path.suffix in suffixes}
        extra, missing = sorted(actual - expected_inventory), sorted(expected_inventory - actual)
        assert not extra and not missing, (label, extra, missing)
        inventory_comparison[label] = {'count': len(actual), 'extra': extra, 'missing': missing}
    write(stage / 'input-comparison.json', {
        'target_commit': snap['target_commit'], 'native_head': git(NATIVE, 'rev-parse', 'HEAD'),
        'feature_head_observed': git(FEATURE, 'rev-parse', 'HEAD'),
        'selected_inputs': comparison, 'selected_input_count': len(comparison), 'mismatches': [],
        'all_proof_input_count': len(manifest['inputs_sha256']),
        'all_proof_inputs_match_after_build': True,
        'source_script_inventories': inventory_comparison,
        'original_snapshot': snap,
    })
    shutil.copy2(reports / 'proof-provenance.json', stage / 'proof-provenance.json')
    report_members = [(p, 'reports/' + p.name) for p in sorted(retained.iterdir()) if p.is_file()]
    report_inventory = add_archive(stage / 'complete-native-reports.tar.gz', report_members)
    write(stage / 'complete-native-reports.inventory.json', report_inventory)
    counts = Counter()
    severities = {'proof': Counter(), 'flow': Counter()}
    original_assertion = []
    repaired_assertions = []
    for path in reports.glob('*.spark'):
        data = json.loads(path.read_text())
        counts['units'] += 1
        counts['entities'] += len(data.get('entities', {}))
        for kind in ('proof', 'flow'):
            records = data.get(kind, [])
            counts[kind + '_records'] += len(records)
            severities[kind].update(item.get('severity', '<absent>') for item in records)
            assert all(item.get('severity') == 'info' for item in records), path
            original_assertion.extend(item for item in records
                                      if item.get('rule') == 'VC_ASSERT'
                                      and item.get('line') == 2179
                                      and item.get('file') == 'silver_output_profile.adb')
    assert original_assertion and all(item['severity'] == 'info' for item in original_assertion)
    for path in reports.glob('*.spark'):
        data = json.loads(path.read_text())
        repaired_assertions.extend(item for item in data.get('proof', []) if item.get('file') == 'silver_output_profile.adb' and item.get('rule') == 'VC_ASSERT' and item.get('line') in {3661, 3934, 3948})
    assert {item['line'] for item in repaired_assertions} == {3661, 3934, 3948}
    assert all(item['severity'] == 'info' for item in repaired_assertions)
    binary_records = {}
    for name in ('silver', 'silver_image_adapter'):
        path = NATIVE / '.silver/linux-x86_64/compiler/bin' / name
        binary_records[name] = {'path': str(path), 'resolved_path': str(path.resolve()),
                                'bytes': path.stat().st_size, 'sha256': sha(path)}
    build_record = {
        'run_id': args.build_run, 'started': build_events[0], 'finished': build_events[-1],
        'command': next(event['command'] for event in build_events if event['event'] == 'command'),
        'binaries': binary_records, 'native_head': git(NATIVE, 'rev-parse', 'HEAD'),
        'native_tracked_status': git(NATIVE, 'status', '--short', '--untracked-files=no'),
        'native_full_status': git(NATIVE, 'status', '--short'),
        'proof_inputs_unchanged_after_build': True,
    }
    assert build_record['native_tracked_status'] == ''
    write(stage / 'build-result.json', build_record)
    # Observe only ordinary-build products. Never request an instrumented rebuild.
    build_start_ns = int(datetime.fromisoformat(build_events[0]['utc']).timestamp() * 1_000_000_000)
    earlier_layout = json.loads((SCRATCH / 'layout-current.json').read_text())
    obj = NATIVE / '.silver/linux-x86_64/compiler/obj/silver_output_profile.o'
    su = obj.with_suffix('.su')
    layout = {'scope': 'Read-only observation of products from the ordinary final build; no additional compilation.',
              'source_sha256': sha(NATIVE / 'src/silver_output_profile.adb'),
              'earlier_source_sha256': earlier_layout['identities']['src/silver_output_profile.adb']['sha256'],
              'object': {'path': str(obj), 'sha256': sha(obj), 'mtime_ns': obj.stat().st_mtime_ns,
                         'fresh_for_build': obj.stat().st_mtime_ns >= build_start_ns},
              'stack_usage_file': {'path': str(su), 'exists': su.is_file()}, 'record_sizes': {}}
    layout_members = []
    if layout['object']['fresh_for_build']:
        readelf = Path(manifest['tools']['gcc']['path']).parent / 'readelf'
        dwarf = subprocess.check_output([str(readelf), '--debug-dump=info', str(obj)], text=True)
        import re
        excerpts = []
        for name, old in earlier_layout['records'].items():
            match = re.search(r'^.*DW_AT_name.*' + re.escape(name) + r'\s*$', dwarf, re.M)
            assert match, name
            tail = dwarf[match.end():]
            size = re.match(r'\n\s*<[^>]+>\s+DW_AT_byte_size\s*:\s*(\d+)', tail)
            assert size, name
            value = int(size.group(1))
            layout['record_sizes'][name] = {'earlier_bytes': old['byte_size'], 'final_bytes': value,
                                             'delta_bytes': value - old['byte_size']}
            excerpts.extend(dwarf[match.start():match.end() + 400].splitlines()[:7])
        layout['readelf'] = {'path': str(readelf), 'sha256': sha(readelf),
                             'version': subprocess.check_output([str(readelf), '--version'], text=True)}
        (stage / 'ordinary-build-layout-excerpts.txt').write_text('\n'.join(excerpts) + '\n')
        layout_members.append((obj, 'silver_output_profile.o'))
        for relative in ('src/silver_array_bindings.ads', 'src/silver_output_profile.adb'):
            layout_members.append((NATIVE / relative, relative))
    if su.is_file():
        fresh = su.stat().st_mtime_ns >= build_start_ns
        layout['stack_usage_file'].update({'sha256': sha(su), 'mtime_ns': su.stat().st_mtime_ns,
                                           'fresh_for_build': fresh})
        if fresh:
            frames = [line for line in su.read_text().splitlines() if ':Loop_Body\t' in line]
            old_frames = [line for line in earlier_layout['frames'] if ':Loop_Body\t' in line]
            layout['loop_body_frames'] = {'earlier': old_frames, 'final': frames,
                                          'limitation': 'Dynamic .su entries report fixed frame portions, not total stack bounds.'}
            layout_members.append((su, 'silver_output_profile.su'))
        else:
            layout['loop_body_frames'] = {'final_observation': 'unavailable',
                                          'reason': 'Ordinary build did not regenerate the existing .su file; retained earlier d82 observation is historical.'}
    else:
        layout['loop_body_frames'] = {'final_observation': 'unavailable',
                                      'reason': 'Ordinary build did not produce a .su file.'}
    write(stage / 'ordinary-build-layout.json', layout)
    if layout_members:
        layout_inventory = add_archive(stage / 'ordinary-build-layout.tar.gz', layout_members)
        write(stage / 'ordinary-build-layout.inventory.json', layout_inventory)
    plan = json.loads((SCRATCH / 'final-observation-retention-plan.json').read_text())
    members = []
    for item in plan['files']:
        path = Path(item['source'])
        assert sha(path) == item['sha256'] and path.stat().st_size == item['bytes'], path
        members.append((path, item['archive_path']))
    observation_dir = stage / 'observations'
    observation_dir.mkdir()
    obs_inventory = add_archive(observation_dir / 'retained-observations.tar.gz', members)
    write(observation_dir / 'retained-observations.inventory.json', obs_inventory)
    for name in ('application-window-result.json', 'layout-comparison.json'):
        shutil.copy2(SCRATCH / name, observation_dir / name)
    write(observation_dir / 'scope.json', {
        'scope': plan['scope'], 'input_source_sha256': 'd82f6880924196f6fccc2077ed86b71c6a31683d72b8e2a935d494b7d62296f4',
        'compiler_sha256': '1cf857171f9af64e20bfdb2fb2a32e411ceefc67a26168acf5e1fa83961d0796',
        'scope_limit': 'These application and concrete 8 MiB stack observations used the earlier compiler. They do not represent fresh final compiler tests or universal stack bounds. Root regression stream owns final applications; independent review owns applicability.',
        'layout_comparison': 'Pre-Boolean baseline 430d20668407a621945456743818172d02c8db6c versus earlier Boolean-array native equivalent 25e6fe06a3; fixed portions only for dynamic stack entries.',
        'managed_runs': plan['managed_runs'], 'file_count': len(obs_inventory),
    })
    run_members = []
    for run_id in [AUDIT_ID, args.build_run, *plan['managed_runs']]:
        for name in ('events.jsonl', 'native.log'):
            path = REGISTRY / run_id / name
            if path.is_file():
                run_members.append((path, run_id + '/' + name))
    run_inventory = add_archive(stage / 'managed-runs.tar.gz', run_members)
    write(stage / 'managed-runs.inventory.json', run_inventory)
    transfer = SCRATCH / 'repaired-cache-transfer-evidence/transfer.json'
    if transfer.is_file():
        transfer_members = [(path, str(path.relative_to(transfer.parent)))
                            for path in sorted(transfer.parent.rglob('*')) if path.is_file()]
        transfer_inventory = add_archive(stage / 'ordinary-cache-transfer.tar.gz', transfer_members)
        write(stage / 'ordinary-cache-transfer.inventory.json', transfer_inventory)
    record = {
        'recorded_utc': datetime.now(timezone.utc).isoformat(), 'platform': 'linux-x86_64',
        'selected_model_effort': 'GPT-6.1 Sol / Extra High per original bounded assignment; runtime confirmation and token/cost evidence unavailable',
        'audit_run_id': AUDIT_ID, 'audit_started': audit_events[0], 'audit_finished': audit_events[-1],
        'audit_command': manifest['command'], 'raw_spark_counts': dict(counts),
        'record_severities': {kind: dict(values) for kind, values in severities.items()},
        'original_required_assertion': original_assertion,
        'repaired_primary_and_relation_assertions': repaired_assertions,
        'proof_provenance_sha256': sha(stage / 'proof-provenance.json'),
        'source_sha256': sha(NATIVE / 'src/silver_output_profile.adb'),
        'build_run_id': args.build_run, 'binary_identities': binary_records,
        'cache_scope': 'Complete forced-analysis audit with ordinary native sessions/cache reuse; not a cold proof measurement. The separately retained repaired-cache transfer record identifies missing-key-only additions from the idle experiment cache, without overwrites/key rewrites; ordinary GNATprove matching remains authoritative. Earlier cache transfers remain dated history in their original packets.',
        'timing_scope': 'Managed elapsed wall time on a shared Linux host; exact phases/settings are recorded in the captured managed events. This successful native run used stable captured source/options. Earlier failed/interrupted runs remain separate historical outcomes.',
        'assurance_scope': 'Complete native compiler/runtime audit and ordinary final build on the repaired captured inputs, following separate retained original failure and focused/whole-helper experiments. Complete Lean/source-correspondence and full regressions are separate root-owned evidence.',
        'native_status': build_record['native_full_status'], 'feature_status_before_retention': status_before,
        'retention': 'Success provenance and all complete .spark/SARIF/summary/input reports; exact managed logs/events compressed; selected source/input comparison and binary identities; earlier observations explicitly scoped.',
    }
    write(stage / 'record.json', record)
    shutil.copy2(Path(__file__), stage / 'retention-helper.py')
    files = [{'path': str(path.relative_to(stage)), 'bytes': path.stat().st_size, 'sha256': sha(path)}
             for path in sorted(stage.rglob('*')) if path.is_file()]
    write(stage / 'artifact-inventory.json', files)
    assert not DESTINATION.exists(), DESTINATION
    shutil.copytree(stage, DESTINATION)
    for entry in files:
        assert sha(DESTINATION / entry['path']) == entry['sha256'], entry['path']
    print(json.dumps({'destination': str(DESTINATION), 'audit': AUDIT_ID, 'build': args.build_run,
                      'raw_spark_counts': dict(counts), 'binaries': binary_records,
                      'retained_files': len(files) + 1,
                      'retained_bytes': sum(path.stat().st_size for path in DESTINATION.rglob('*') if path.is_file())}, indent=2))


if __name__ == '__main__':
    main()

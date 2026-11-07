"""Retain one completed isolated experiment; run no proof, build or test."""
from pathlib import Path
from datetime import datetime, timezone
import argparse
import gzip
import hashlib
import json
import shutil
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
FEATURE = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/boolean-arrays')
REGISTRY = Path('/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs')
REPORTS = ROOT / '.silver/linux-x86_64/compiler/obj/explore/primary-branch-cut/gnatprove'
EXPECTED_SOURCE = 'c1ce845a597605c152119bedc6b07f1aa3bccece5d2870addb86cd18077fffaa'


def sha(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def archive(output, members):
    rows = []
    with tarfile.open(output, 'w:gz') as out:
        for path, name in members:
            assert path.is_file(), path
            out.add(path, arcname=name, recursive=False)
            rows.append({'path': name, 'original': str(path), 'bytes': path.stat().st_size,
                         'sha256': sha(path)})
    with tarfile.open(output, 'r:gz') as retained:
        assert retained.getnames() == [row['path'] for row in rows]
        for row in rows:
            with retained.extractfile(row['path']) as stream:
                assert hashlib.file_digest(stream, 'sha256').hexdigest() == row['sha256'], row['path']
    return rows


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--run', required=True)
    parser.add_argument('--label', required=True)
    parser.add_argument('--line', type=int, required=True)
    parser.add_argument('--rule', required=True)
    args = parser.parse_args()
    run = REGISTRY / args.run
    events = [json.loads(line) for line in (run / 'events.jsonl').read_text().splitlines()]
    assert events[-1]['event'] == 'finished' and events[-1]['outcome'] == 'success', events[-1]
    prepared = next(event for event in events if event['event'] == 'prepared')['inputs']
    command = next(event['command'] for event in events if event['event'] == 'command')
    for flag in ('--level=2', '--timeout=30', '--memlimit=1000', '--prover=cvc5,z3,altergo',
                 '--debug-save-vcs', '--limit-subp=silver_output_profile.adb:3562',
                 f'--limit-line=silver_output_profile.adb:{args.line}', '-j2'):
        assert flag in command, flag
    assert events[0]['workers'] == 2
    source = ROOT / 'src/silver_output_profile.adb'
    assert sha(source) == EXPECTED_SOURCE == prepared['inputs_sha256']['src/silver_output_profile.adb']
    data = json.loads((REPORTS / 'silver_output_profile.spark').read_text())
    selected = [record for record in data['proof']
                if record.get('file') == 'silver_output_profile.adb'
                and record.get('line') == args.line and record.get('rule') == args.rule]
    assert selected and all(record.get('severity') == 'info' for record in selected), selected
    assert all(record.get('severity') == 'info'
               for kind in ('proof', 'flow') for record in data.get(kind, []))
    before = json.loads((ROOT / 'tmp/primary-branch-cut/pre-edit.json').read_text())
    assert sha(ROOT / '.silver/linux-x86_64/compiler/bin/silver') == before['binary_sha256']
    stage = ROOT / 'tmp/primary-branch-cut' / ('retained-' + args.label)
    destination = FEATURE / 'docs/evidence/boolean-arrays-20261106/native-primary-failure' / args.label
    assert not stage.exists() and not destination.exists()
    stage.mkdir()
    suffixes = {'.spark', '.out', '.sarif', '.gnat-json', '.conf', '.smt2', '.psmt2', '.why', '.mlw'}
    members = [(path, str(path.relative_to(REPORTS))) for path in sorted(REPORTS.rglob('*'))
               if path.is_file() and (path.suffix in suffixes or path.name.startswith('why3session')
                                      or path.name.startswith('why3shapes'))]
    inventory = archive(stage / 'reports-and-solver-inputs.tar.gz', members)
    write(stage / 'reports-and-solver-inputs.inventory.json', inventory)
    run_inventory = archive(stage / 'managed-run.tar.gz',
                            [(run / name, name) for name in ('events.jsonl', 'native.log')])
    write(stage / 'managed-run.inventory.json', run_inventory)
    with gzip.open(stage / 'source.adb.gz', 'wb') as out:
        out.write(source.read_bytes())
    with gzip.open(stage / 'native-inputs-and-tools.json.gz', 'wt') as out:
        json.dump(prepared, out, indent=2)
    shutil.copy2(ROOT / 'tmp/primary-branch-cut/pre-edit.json', stage / 'pre-edit.json')
    shutil.copy2(FEATURE / 'tmp/primary-diagnosis/primary-branch-cut.patch', stage / 'candidate.patch')
    shutil.copy2(Path(__file__), stage / 'retention-helper.py')
    solver_files = [row for row in inventory if Path(row['path']).suffix in {'.smt2', '.psmt2'}]
    assert solver_files, 'No saved solver input retained'
    record = {'recorded_utc': datetime.now(timezone.utc).isoformat(), 'platform': 'linux-x86_64',
              'run_id': args.run, 'started': events[0], 'finished': events[-1], 'command': command,
              'source_sha256': EXPECTED_SOURCE, 'target_line': args.line, 'target_rule': args.rule,
              'actual_selected_records': selected, 'proof_record_count': len(data.get('proof', [])),
              'flow_record_count': len(data.get('flow', [])), 'saved_solver_input_count': len(solver_files),
              'selected_input_count': len(prepared['inputs_sha256']),
              'original_binary_unchanged': True, 'original_binary_sha256': before['binary_sha256'],
              'branch': subprocess.check_output(['git', 'branch', '--show-current'], cwd=ROOT, text=True).strip(),
              'head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
              'tracked_status': subprocess.check_output(['git', 'status', '--short', '--untracked-files=no'],
                                                        cwd=ROOT, text=True),
              'selected_model_effort': 'GPT-6.1 Sol / Extra High per original assignment; runtime confirmation and token/cost unavailable',
              'scope': 'Isolated assertion or postcondition experiment only; not whole-helper or complete native assurance. Original canonical232644 remains failed and untouched. No source integration, rebuild, application execution, commit or publication.'}
    write(stage / 'record.json', record)
    files = [{'path': str(path.relative_to(stage)), 'bytes': path.stat().st_size, 'sha256': sha(path)}
             for path in sorted(stage.iterdir()) if path.is_file()]
    write(stage / 'artifact-inventory.json', files)
    shutil.copytree(stage, destination)
    for row in files:
        assert sha(destination / row['path']) == row['sha256'], row['path']
    print(json.dumps({'destination': str(destination), 'run_id': args.run,
                      'selected_records': len(selected), 'saved_solver_inputs': len(solver_files),
                      'duration_seconds': events[-1].get('duration_seconds')}, indent=2))


if __name__ == '__main__':
    main()

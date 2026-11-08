"""Focused application validation using the delivered compiler and unchanged auditors."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys
import tarfile
import time

parser = argparse.ArgumentParser()
parser.add_argument('--installation', type=Path, required=True)
parser.add_argument('--source-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
installation = args.installation.resolve()
root = args.source_root.resolve()
output = args.output.resolve()
output.mkdir(parents=True, exist_ok=True)
sys.path.insert(0, str(installation))
from scripts.check_evidence import audit_reports
from tests.test_samples import SupportedSampleTests

compiler = installation / '.silver/linux-x86_64/compiler/bin/silver'
manifest = json.loads((root / 'samples/manifest.json').read_text())
selected = {
    'rosetta_factorial.adb', 'rosetta_fibonacci_sequence.adb',
    'rosetta_signum.adb', 'rosetta_sum_multiples_of_3_and_5.adb',
}
entries = [entry for entry in manifest['samples'] if entry['source'] in selected]
assert len(entries) == len(selected)
all_sources = [entry['source'] for entry in manifest['samples']]
assert len(all_sources) == len(set(all_sources))
assert set(all_sources) == {str(p.relative_to(root / 'samples')) for p in (root / 'samples').rglob('*.adb')}
capabilities = {entry['id'] for entry in json.loads((root / 'catalogue/silver.json').read_text())['constructs']}
checker = SupportedSampleTests()
summary = {
    'compiler': str(compiler), 'compiler_sha256': hashlib.sha256(compiler.read_bytes()).hexdigest(),
    'source_root': str(root), 'manifest_sha256': hashlib.sha256((root / 'samples/manifest.json').read_bytes()).hexdigest(),
    'mode': 'four focused sample admission/proof/build/audit/execution checks; unchanged production options',
    'results': [],
}
for entry in entries:
    source = root / 'samples' / entry['source']
    data = source.read_bytes()
    assert len(data) <= 4096
    assert set(entry['capabilities']) <= capabilities
    assert entry['application_functions']
    sample_output = output / source.stem
    sample_output.mkdir(exist_ok=True)
    result = {'source': entry['source'], 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data), 'application_functions': entry['application_functions']}
    start = time.monotonic()
    for action in ['check', 'compile']:
        command = [str(compiler), action, str(source)]
        completed = subprocess.run(command, cwd=installation, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (sample_output / (action + '.log')).write_bytes(completed.stdout)
        result[action + '_exit'] = completed.returncode
        assert completed.returncode == 0, (command, completed.stdout.decode(errors='replace'))
        if action == 'compile':
            text = completed.stdout.decode()
            match = re.search(r'^Executable: (.+)$', text, re.MULTILINE)
            assert match, text
            executable = Path(match.group(1))
            if not executable.is_absolute(): executable = installation / executable
    workspace = executable.parent.parent
    assert workspace.parent == installation / '.silver/linux-x86_64'
    snapshots = [p for p in workspace.rglob('*.adb') if p.read_bytes() == data]
    assert len(snapshots) == 1
    reports = list(workspace.rglob('gnatprove.sarif'))
    assert len(reports) == 1
    checker.assert_application_proof_policy(reports[0], output=True, functions=True)
    units = {snapshots[0].stem, 'silver_io', 'silver_output_libc', 'silver_arguments', 'silver_runtime'}
    statistics = audit_reports(reports[0].parent, units, {'silver_output_libc', 'silver_runtime'}, application_kind='assigned', indexed_main=True, application_functions=tuple(entry['application_functions']))
    assert statistics['units'] == len(units)
    assert statistics['proof_checks'] > 0
    cases = [{'arguments': [], 'expected': entry['expected']}, *entry.get('argument_cases', [])]
    for index, case in enumerate(cases):
        executed = subprocess.run([str(executable), *case['arguments']], stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=10)
        (sample_output / f'execution-{index}.stdout').write_bytes(executed.stdout)
        (sample_output / f'execution-{index}.stderr').write_bytes(executed.stderr)
        expected = case['expected']
        assert executed.returncode == expected['exit_status'], (source, executed.returncode)
        assert executed.stdout == expected['stdout'].encode(), (source, executed.stdout, expected['stdout'])
        assert executed.stderr == expected['stderr'].encode(), (source, executed.stderr)
    assert source.read_bytes() == data
    archive = sample_output / 'application-evidence.tar.gz'
    with tarfile.open(archive, 'w:gz') as tar:
        for path in sorted(workspace.rglob('*')):
            if path.is_file() and (path.suffix in ('.ads', '.adb', '.gpr', '.spark', '.sarif') or path.name in ('gnatprove.out', 'why3session.xml')):
                tar.add(path, arcname=str(path.relative_to(workspace)), recursive=False)
    result.update(workspace=str(workspace), executable=str(executable), statistics=statistics, cases=len(cases), elapsed_seconds=time.monotonic()-start, archive_sha256=hashlib.sha256(archive.read_bytes()).hexdigest(), outcome='passed')
    summary['results'].append(result)
    (output / 'summary.json').write_text(json.dumps(summary, indent=2)+'\n')
    print(json.dumps(result), flush=True)
summary['outcome'] = 'passed'
(output / 'summary.json').write_text(json.dumps(summary, indent=2)+'\n')
print('All four sample admission/proof/build/audit/execution checks passed.', flush=True)

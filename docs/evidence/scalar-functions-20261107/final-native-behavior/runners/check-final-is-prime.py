"""Run the existing Is_Prime manifest case and retain its native artifacts."""
from pathlib import Path
import gzip
import hashlib
import json
import os
import re
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root))
from scripts.check_evidence import audit_reports
from scripts.platforms import native_layout
from tests.test_samples import SupportedSampleTests

host = native_layout(root)
out = root / 'tmp/final-native-sample'
out.mkdir(exist_ok=True)
source = root / 'samples/rosetta_primality_by_trial_division.adb'
data = source.read_bytes()
manifest = json.loads((root / 'samples/manifest.json').read_text())
entry = next(item for item in manifest['samples'] if item['source'] == source.name)
compiler = host.compiler / 'bin/silver'
summary = {
    'source': str(source), 'source_sha256': hashlib.sha256(data).hexdigest(),
    'compiler': str(compiler), 'compiler_sha256': hashlib.sha256(compiler.read_bytes()).hexdigest(),
    'cpu_affinity': sorted(os.sched_getaffinity(0)), 'completed': False,
}

def save():
    (out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')

save()
for mode in ['check', 'compile']:
    command = [str(compiler), mode, str(source)]
    result = subprocess.run(command, cwd=root, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT)
    (out / (mode + '.log')).write_text(result.stdout)
    print(result.stdout, flush=True)
    summary[mode] = {'command': command, 'returncode': result.returncode}
    save()
    assert result.returncode == 0, (mode, result.stdout)

match = re.search(r'^Executable: (.+)$', result.stdout, re.MULTILINE)
assert match, result.stdout
executable = Path(match.group(1))
if not executable.is_absolute():
    executable = root / executable
workspace = executable.parent.parent
assert workspace.parent == host.artifacts
snapshots = [path for path in workspace.rglob('*.adb') if path.read_bytes() == data]
assert len(snapshots) == 1, snapshots
reports = list(workspace.rglob('gnatprove.sarif'))
assert len(reports) == 1, reports
SupportedSampleTests().assert_application_proof_policy(reports[0], output=True, functions=True)
statistics = audit_reports(
    reports[0].parent, {'main', 'silver_io', 'silver_output_libc', 'silver_arguments', 'silver_runtime'},
    {'silver_output_libc', 'silver_runtime'}, application_kind='assigned',
    indexed_main=True, application_functions=tuple(entry['application_functions']))
assert statistics['units'] == 5 and statistics['proof_checks'] > 0, statistics
summary.update(workspace=str(workspace), executable=str(executable),
               executable_sha256=hashlib.sha256(executable.read_bytes()).hexdigest(),
               statistics=statistics, application_functions=entry['application_functions'])
save()

execution = subprocess.run([str(executable)], capture_output=True, timeout=10)
(out / 'stdout').write_bytes(execution.stdout)
(out / 'stderr').write_bytes(execution.stderr)
expected = entry['expected']
assert execution.returncode == expected['exit_status'], execution.returncode
assert execution.stdout == expected['stdout'].encode('utf-8'), execution.stdout
assert execution.stderr == expected['stderr'].encode('utf-8'), execution.stderr
assert source.read_bytes() == data and snapshots[0].read_bytes() == data
summary.update(completed=True, execution_returncode=execution.returncode,
               stdout=execution.stdout.decode(), stderr=execution.stderr.decode())
summary['retained_reports'] = []
for path in [*reports[0].parent.glob('*.spark'), reports[0], reports[0].parent / 'gnatprove.out',
             workspace / 'main.adb', workspace / 'program.gpr']:
    payload = path.read_bytes()
    target = out / (path.name + '.gz')
    target.write_bytes(gzip.compress(payload, mtime=0))
    summary['retained_reports'].append({'file': target.name, 'sha256': hashlib.sha256(payload).hexdigest()})
save()
print(json.dumps(summary, indent=2), flush=True)

"""Resolve collect2's actual child; GCC -v did not forward verbosity."""
import ast
import hashlib
import json
from pathlib import Path
import subprocess
import time

root = Path(__file__).resolve().parent
capture = root / 'ld-resolution'
capture.mkdir()
prior = json.loads((root / 'capture/result.json').read_text())
display = (root / 'capture/driver-only.stderr').read_text()
parser = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/retained-tool-capacity/docs/evidence/retained-link-inputs-20261018/inventory.py')
tree = ast.parse(parser.read_text())
node = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'decode_gcc_command')
scope = {}
exec(compile(ast.Module(body=[node], type_ignores=[]), str(parser), 'exec'), scope)
line = next(l for l in display.split('\n') if '/collect2 ' in l)
argv = scope['decode_gcc_command'](line)
assert len(argv) == 45 and argv[1] == '-fno-lto'
assert not any(a.startswith('-plugin') for a in argv)
argv.insert(1, '-v')
argv[argv.index('-o') + 1] = str(capture / 'null-resolved-ld')
env = dict(prior['environment'])
for key in ('COLLECT_GCC', 'COMPILER_PATH', 'LIBRARY_PATH', 'COLLECT_GCC_OPTIONS'):
    values = {l.partition('=')[2] for l in display.split('\n') if l.startswith(key + '=')}
    assert len(values) == 1
    env[key] = values.pop()
started = time.monotonic()
result = subprocess.run(argv, cwd=prior['commands'][0]['cwd'], env=env, capture_output=True)
elapsed = time.monotonic() - started
(capture / 'stdout').write_bytes(result.stdout)
(capture / 'stderr').write_bytes(result.stderr)
result.check_returncode()
lines = result.stderr.decode().split('\n')
ld_lines = [l for l in lines if l.strip().startswith('/') and Path(l.strip().split()[0]).name == 'ld']
assert len(ld_lines) == 1, lines
ld = Path(ld_lines[0].strip().split()[0])
expected = Path(prior['commands'][0]['argv'][0]).with_name('ld')
digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
assert digest(ld) == digest(expected)
record = {'reason': 'Prior GCC -v link succeeded but did not forward -v to collect2; repeat only the retained-object link with collect2 verbosity to resolve actual ld',
          'argv': argv, 'cwd': prior['commands'][0]['cwd'], 'environment': env,
          'returncode': result.returncode, 'seconds': elapsed,
          'selected_linker': str(ld), 'resolved_linker': str(ld.resolve()),
          'selected_linker_sha256': digest(ld), 'expected_linker': str(expected),
          'expected_linker_sha256': digest(expected),
          'compiler_frontend_assembler_prover_or_program_executed': False}
(capture / 'result.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps({k: record[k] for k in ('seconds', 'selected_linker', 'resolved_linker', 'selected_linker_sha256')}, indent=2))

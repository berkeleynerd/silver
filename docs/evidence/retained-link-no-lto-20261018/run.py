"""Check an explicit no-LTO link descriptor using retained null objects."""
import hashlib
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parent
SOURCE = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/retained-tool-capacity/docs/evidence/retained-link-inputs-20261018/capture/result.json')
record = json.loads(SOURCE.read_text())
capture = ROOT / 'capture'
capture.mkdir()
(capture / 'temp').mkdir()
base = record['source_link_argv']
env = dict(record['environment'])
env['TMPDIR'] = str(capture / 'temp')
cwd = record['commands'][0]['cwd']
objects = []
for name in ('main.o', 'b__main.o'):
    path = Path(cwd) / name
    data = path.read_bytes()
    objects.append({'path': str(path), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
output = str(capture / 'null-explicit-no-lto')
args = list(base[1:])
args[args.index('-o') + 1] = output
flags = ['-fno-lto', '-fno-use-linker-plugin']
commands = []
started = time.monotonic()
for name, command in [('driver-only', [base[0], '-###', *flags, *args]),
                      ('link', [base[0], '-v', *flags, *args])]:
    tick = time.monotonic()
    result = subprocess.run(command, cwd=cwd, env=env, capture_output=True)
    (capture / (name + '.stdout')).write_bytes(result.stdout)
    (capture / (name + '.stderr')).write_bytes(result.stderr)
    commands.append({'name': name, 'argv': command, 'cwd': cwd,
                     'returncode': result.returncode, 'seconds': time.monotonic() - tick})
    result.check_returncode()
binary = Path(output).read_bytes()
result = {'method': 'One driver-only query and one link of retained null objects; no frontend, assembler, prover or program execution',
          'source_capture': str(SOURCE), 'source_capture_sha256': hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
          'objects': objects, 'environment': env, 'commands': commands,
          'output': {'path': output, 'bytes': len(binary), 'sha256': hashlib.sha256(binary).hexdigest()},
          'seconds': time.monotonic() - started}
(capture / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))

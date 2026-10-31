"""Retain 4096-byte Boolean admission probes under the ordinary 8 MiB stack."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

binary, destination = map(Path, sys.argv[1:])
destination.mkdir(parents=True, exist_ok=True)
prefix = b'with Silver_IO;procedure Main is pragma SPARK_Mode(On);'
suffix = b'begin null;end Main;'
cases = {}
for name, declarations, opening, atom, closing in (
    ('grouped_initializer', b'Flag:Boolean:=', b'(', b'True', b')'),
    ('negated_initializer', b'Flag:Boolean:=', b'(not ', b'True', b')'),
    ('metadata_and_groups', b''.join(b'B' + str(i).encode() + b':Boolean:=True;' for i in range(150)) + b'Flag:Boolean:=', b'(', b'B149', b')'),
    ('scalar_flow_and_groups', b'subtype S is Integer range 0..1;' + b''.join(b'N' + str(i).encode() + b':S:=0;' for i in range(100)) + b'Flag:Boolean:=', b'(', b'True', b')'),
):
    count = (4096 - len(prefix + declarations + atom + b';' + suffix)) // (len(opening) + len(closing))
    source = prefix + declarations + opening * count + atom + closing * count + b';' + suffix
    source += b' ' * (4096 - len(source))
    cases[name] = source
record = {'binary': str(binary), 'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
          'stack_kib': 8192, 'cases': []}
for name, source in cases.items():
    path = destination / (name + '.adb'); path.write_bytes(source)
    command = ['bash', '-c', 'ulimit -s 8192 || exit; exec "$@"', 'boolean-stack', str(binary), 'check', str(path)]
    started = time.monotonic()
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
    (destination / (name + '.log')).write_bytes(result.stdout)
    item = {'name': name, 'bytes': len(source), 'source_sha256': hashlib.sha256(source).hexdigest(),
            'returncode': result.returncode, 'elapsed_seconds': time.monotonic() - started,
            'command': command}
    record['cases'].append(item); print(json.dumps(item), flush=True)
(destination / 'observations.json').write_text(json.dumps(record, indent=2) + '\n')
raise SystemExit(any(item['returncode'] != 0 for item in record['cases']))

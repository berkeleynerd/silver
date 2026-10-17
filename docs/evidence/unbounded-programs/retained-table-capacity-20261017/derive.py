#!/usr/bin/env python3
"""Reproduce allocator arithmetic/inventory; not a Silver membership checker."""
import argparse
import hashlib
import json
from pathlib import Path
import re

p = argparse.ArgumentParser()
p.add_argument('ada_source', type=Path, help='complete pinned GCC gcc/ada directory')
p.add_argument('output', type=Path)
a = p.parse_args()
files = ['table.ads', 'table.adb', 'types.ads', 'alloc.ads', 'atree.ads',
         'atree.adb', 'nlists.adb', 'namet.ads', 'namet.adb', 'sinput.adb',
         'stringt.adb', 'uintp.adb', 'exp_dbug.adb']
pin = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
repository = Path(__file__).resolve().parents[4]
manifest_path = repository / 'docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json'
manifest = json.loads(manifest_path.read_text())
if manifest['commit'] != pin:
    raise SystemExit('Pinned manifest commit mismatch')
expected = {entry['path']: entry for entry in manifest['files']}
verified = {}

def verify_source(path):
    raw = path.read_bytes()
    sha256 = hashlib.sha256(raw).hexdigest()
    blob = hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest()
    entry = expected.get(path.name)
    if entry is None or sha256 != entry['sha256'] or blob != entry['git_blob_sha1']:
        raise SystemExit(f'Pinned source mismatch: {path.name}')
    verified[path.name] = sha256
    return raw

for name in files:
    verify_source(a.ada_source / name)
I = 2**31 - 1

def growth(initial, increment):
    length = initial
    history = [length]
    while True:
        candidate = length * (100 + increment) // 100
        if candidate > I or length + 10 > I:
            return {'initial': initial, 'increment_percent': increment,
                    'representable_length_sequence': history,
                    'next_formula_result': candidate,
                    'scope': 'Min=0; no release/reset; length arithmetic only'}
        length = max(candidate, length + 10)
        history.append(length)

instances = []
inventory_paths = sorted(path for path in a.ada_source.iterdir()
                         if path.suffix in ('.ads', '.adb') and path.is_file())
expected_names = {name for name in expected
                  if '/' not in name and Path(name).suffix in ('.ads', '.adb')}
if {path.name for path in inventory_paths} != expected_names:
    raise SystemExit('Pinned top-level Ada source inventory mismatch')
for path in inventory_paths:
    source = verify_source(path).decode()
    # Lexical inventory only: comments, reachability, alternate allocators and
    # generated sources require separate source review, not inference here.
    for m in re.finditer(r'package\s+(\w+)\s+is\s+new\s+Table\.Table\s*\((.*?)\);', source, re.S | re.I):
        instances.append({'file': path.name,
                          'line_lf': source.count('\n', 0, m.start()) + 1,
                          'package': m[1], 'actual_parameters': m[2].strip()})
line_sequence = [500]
while line_sequence[-1] * 2 * 32 <= I:
    line_sequence.append(line_sequence[-1] * 2)
result = {
    'source_commit': pin,
    'source_relation': 'every inspected/inventoried file verified against retained pinned-tree manifest',
    'source_files_verified': len(verified),
    'source_hash_mismatches': 0,
    'source_sha256': {f: verified[f] for f in files},
    'string_growth': growth(2500, 150),
    'line_capacity_sequence': line_sequence,
    'next_line_capacity': line_sequence[-1] * 2,
    'next_line_intermediate_bits': line_sequence[-1] * 2 * 32,
    'lexical_table_instance_count': len(instances),
    'lexical_table_instances': instances,
    'limitations': ['no compiler run', 'no complete allocation-route closure',
                    'no whole-program upper bound', 'no safe language threshold',
                    'growth sequence excludes Release/Save/Restore and nonzero low bounds'],
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['lexical_table_instance_count', 'next_line_capacity',
                                     'next_line_intermediate_bits']}, indent=2))

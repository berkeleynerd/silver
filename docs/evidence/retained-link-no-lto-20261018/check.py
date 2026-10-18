#!/usr/bin/env python3
"""Reconcile the explicit no-LTO descriptor without executing native tools."""
import argparse
import ast
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
parser.add_argument('--installed', action='store_true',
                    help='also hash the retained objects and both linker paths')
args = parser.parse_args()
root = Path(__file__).resolve().parent
prior = root.parent / 'retained-link-inputs-20261018'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
manifest = json.loads((root / 'manifest.json').read_text())
for row in manifest['files']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']

# Reuse the inverse of GCC's display quoting without executing the inventory's
# top-level filesystem scan or interpreting shell expansions.
source = prior / 'inventory.py'
tree = ast.parse(source.read_text())
node = next(n for n in tree.body if isinstance(n, ast.FunctionDef)
            and n.name == 'decode_gcc_command')
scope = {}
exec(compile(ast.Module(body=[node], type_ignores=[]), str(source), 'exec'), scope)
decode = scope['decode_gcc_command']
record = json.loads((root / 'capture/result.json').read_text())
assert record['source_capture_sha256'] == sha((prior / 'capture/result.json').read_bytes())
base = json.loads((prior / 'capture/result.json').read_text())
inventory = json.loads((prior / 'inventory.json').read_text())
display = (root / 'capture/driver-only.stderr').read_text()
command = decode(next(line for line in display.split('\n') if '/collect2 ' in line))
assert len(command) == 45 and command[1] == '-fno-lto'
assert not any(s.startswith(('-plugin', '@')) for s in command)
assert record['commands'][0]['argv'][1:4] == ['-###', '-fno-lto', '-fno-use-linker-plugin']
assert record['commands'][1]['argv'][1:4] == ['-v', '-fno-lto', '-fno-use-linker-plugin']
assert all(row['returncode'] == 0 for row in record['commands'])
assert len(record['environment']) == 7
assert {k: v for k, v in record['environment'].items() if k != 'TMPDIR'} == {
    k: v for k, v in base['environment'].items() if k != 'TMPDIR'}


def normalize_output(argv):
    result = list(argv)
    result[result.index('-o') + 1] = '<output>'
    return result


old = inventory['collect2_argv']
assert old[1] == '-plugin'
assert all(s.startswith('-plugin-opt=') for s in old[3:11])
# Exactly ten old plugin fields disappear and one no-LTO field is added.
assert normalize_output([command[0], *command[2:]]) == normalize_output([old[0], *old[11:]])
assert [s[2:] for s in command if s.startswith('-L')] == inventory['search_directories']
assert len(inventory['search_directories']) == 14
for row in record['objects']:
    retained = next(r for r in inventory['files'] if r['path'] == row['path'])
    assert retained['role'] == 'generated-input'
    assert (row['bytes'], row['sha256']) == (retained['bytes'], retained['sha256'])
    if args.installed:
        raw = Path(row['path']).read_bytes()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']

resolved = json.loads((root / 'ld-resolution/result.json').read_text())
assert resolved['returncode'] == 0
assert resolved['selected_linker_sha256'] == resolved['expected_linker_sha256']
if args.installed:
    for key in ('selected_linker', 'expected_linker'):
        assert sha(Path(resolved[key]).read_bytes()) == resolved[key + '_sha256']
assert resolved['argv'][1:3] == ['-v', '-fno-lto']
assert normalize_output([resolved['argv'][0], *resolved['argv'][2:]]) == normalize_output(command)
ld_line = next(line for line in (root / 'ld-resolution/stderr').read_text().split('\n')
               if line.startswith(resolved['selected_linker'] + ' '))
# collect2 prints these args without quoting. This capture's paths/args have no
# whitespace, so literal splitting is unambiguous and does not evaluate $ORIGIN.
assert not any(any(c.isspace() for c in s) for s in resolved['argv'])
ld_argv = ld_line.split()
assert ld_argv == [resolved['selected_linker'], '-v', *resolved['argv'][3:]]
assert len(ld_argv) - 1 == 44  # remove the diagnostic-only -v

values = {}
for key in ('COMPILER_PATH', 'COLLECT_GCC_OPTIONS'):
    found = {line.partition('=')[2] for line in display.split('\n')
             if line.startswith(key + '=')}
    assert len(found) == 1
    values[key] = found.pop()
options = re.findall(r"'([^']*)'", values['COLLECT_GCC_OPTIONS'])
assert ' '.join("'" + s + "'" for s in options) == values['COLLECT_GCC_OPTIONS']
assert len(options) == 12
copied = [s for s in options if s.startswith(('-m', '-f'))]
assert copied == ['-fno-lto', '-fno-use-linker-plugin', '-mtune=generic', '-march=x86-64']
assert len(values['COMPILER_PATH'].split(':')) == len(record['environment']['PATH'].split(':')) == 3

texts = {}
for bundle, names, old_schema in [
    (prior, ['gcc/gcc/collect2.cc', 'gcc/gcc/gcc.cc'], True),
]:
    rows = json.loads((bundle / 'sources.json').read_text())
    if not old_schema:
        rows = rows['files']
    with tarfile.open(bundle / 'sources.tar.gz') as archive:
        for name in names:
            row = next(r for r in rows if r.get('archive_path', r.get('path')) == name)
            raw = archive.extractfile(name).read()
            assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
            texts[name] = raw.decode()
gcc = texts['gcc/gcc/gcc.cc']
collect = texts['gcc/gcc/collect2.cc']
for fragment in ('#define PLUGIN_COND "!fno-use-linker-plugin:%{!fno-lto"',
                 'if (!switch_matches (fno_use_linker_plugin,', '%{fno-lto}'):
    assert fragment in gcc, fragment
for fragment in ('else if (startswith (argv[i], "-fno-lto"))',
                 'else if (startswith (q, "-fno-lto"))',
                 'else if (startswith (arg, "-fno-lto"))',
                 'rflag || (! DO_COLLECT_EXPORT_LIST && ! do_collecting)',
                 'if (lto_mode != LTO_MODE_NONE)',
                 'ld1_argv = XCNEWVEC (char *, argc + 4);',
                 'ld2_argv = XCNEWVEC (char *, argc + 11);',
                 'object_lst = XCNEWVEC (char *, argc);'):
    assert fragment in collect

n = len(command)
slots = {'ld1': n + 4, 'ld2': n + 11, 'objects': n,
         'unused_C_command': n + 9 + 8 + len(copied)}
assert list(slots.values()) == [49, 56, 45, 66]
result = {
    'scope': 'Selected explicit no-LTO link descriptor; not whole linker capacity',
    'collect2_argv_positions': n,
    'ld_argv_positions_without_diagnostic_v': 44,
    'array_pointer_slots': slots,
    'array_bytes_LP64': {k: 8*v for k, v in slots.items()},
    'unused_C_command_write_slots_including_NUL': 20,
    'quoted_environment_fields': len(options),
    'copied_f_or_m_fields': len(copied),
    'prefix_nodes': 6,
    'fixed_target_inputs_and_order_unchanged': True,
    'plugin_arguments_or_LTO_worker_launches': 0,
    'linker_launches_per_invocation': 1,
    'driver_query_seconds': record['commands'][0]['seconds'],
    'first_link_seconds': record['commands'][1]['seconds'],
    'diagnostic_link_seconds': resolved['seconds'],
    'installed_hashes_rechecked': args.installed,
    'whole_linker_capacity_established': False,
}
args.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))

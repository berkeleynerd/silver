#!/usr/bin/env python3
"""Offline checks for the handwritten selected-driver container argument."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc', type=Path)
args = parser.parse_args()
here = Path(__file__).resolve().parent
evidence = here.parent


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def archive_sources(bundle):
    manifest = json.loads((bundle / 'sources.json').read_text())
    raw = (bundle / 'sources.tar.gz').read_bytes()
    if 'archive_sha256' in manifest:
        assert sha(raw) == manifest['archive_sha256']
    result = {}
    with tarfile.open(bundle / 'sources.tar.gz') as archive:
        assert set(archive.getnames()) == {r['path'] for r in manifest['files']}
        for row in manifest['files']:
            data = archive.extractfile(row['path']).read()
            assert len(data) == row['bytes'] and sha(data) == row['sha256']
            result[row['path']] = data.decode()
    return result


sources = archive_sources(here)
sources.update(archive_sources(evidence / 'retained-native-environment-20261018'))
gcc = sources['gcc/gcc.cc']
opts = sources['gcc/opts.h']
dec = sources['gcc/opts-common.cc']
vec = sources['gcc/vec.cc']
config = json.loads((here / 'installed-configuration.json').read_text())
configured = config['configuration_arguments'].encode()
assert len(configured) == config['configuration_bytes']
assert sha(configured) == config['configuration_sha256']
assert b'--build=x86_64-pc-linux-gnu' in configured
assert not any(s in configured for s in (b'--with-specs', b'--with-cpu',
    b'--with-arch', b'--with-tune', b'--with-tls'))
assert '[CONFIGURE_SPECS=]' in sources['gcc/configure.ac']
if args.gcc:
    binary = args.gcc.read_bytes()
    assert sha(binary) == config['binary_sha256']
    offset = config['configuration_file_offset']
    assert binary[offset:offset + len(configured) + 1] == configured + b'\0'

for fragment in ('int opt_array_len = argc;',
                 'opt_array = XNEWVEC (struct cl_decoded_option, opt_array_len);',
                 '"diagnostics-plain-output"',
                 'prune_options (decoded_options, decoded_options_count);'):
    assert fragment in dec
for fragment in ('const char *canonical_option[4];', 'HOST_WIDE_INT value;',
                 'HOST_WIDE_INT mask;', 'unsigned int live_cond;'):
    assert fragment in opts
for fragment in ('n_infiles_alloc = 16;', 'n_switches_alloc = 16;',
                 'argbuf.create (10);', 'at_file_argbuf.create (10);',
                 'argbuf.safe_push (0);', 'save_growing_size = obstack_object_size (&obstack);',
                 'if (argc == 1)\n    return NULL;',
                 'obstack_grow (&collect_obstack, "\'-", 2);'):
    assert fragment in gcc
assert 'alloc = alloc * 2;' in vec and 'alloc = (alloc * 3 / 2);' in vec
assert 'int lang_specific_extra_outfiles = 0;' in sources['gcc/c/gccspec.cc']
assert 'with_cpu=$cpu' in sources['gcc/config.gcc']
assert 'arch=x86-64\n\tcpu=generic' in sources['gcc/config.gcc']
assert 'with_arch=$arch' in sources['gcc/config.gcc']

witness = evidence / 'unbounded-programs/retained-native-expansion-20261017/fixed-gcc-prefix-witness'
manifest = json.loads((witness / 'manifest.json').read_text())
needed = {'invocation.json', 'frontend-exec.json', 'dumpspecs.stdout.gz'}
for row in manifest['files']:
    if row['path'] in needed:
        raw = (witness / row['path']).read_bytes()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        needed.remove(row['path'])
assert not needed
invocation = json.loads((witness / 'invocation.json').read_text())['argv']
actual = json.loads((witness / 'frontend-exec.json').read_text())['argv']
assert len(invocation) == 13 and invocation[1:10] == [
    '-c', '-x', 'ada', '-gnatA', '-gnat2022', '-gnata', '-gnato', '-gnatx',
    '-Wno-free-nonheap-object']
assert invocation[10].startswith('-gnatec=/')
assert invocation[11].startswith('-gnatem=/')
assert invocation[12].startswith('/') and invocation[12].endswith('/main.adb')
assert not any(s.startswith('@') for s in invocation)
expected = [actual[0], '-quiet', '-Wno-free-nonheap-object',
            '-dumpbase', 'main.adb', '-dumpbase-ext', '.adb',
            *invocation[4:9], *invocation[10:12], '-mtune=generic',
            '-march=x86-64', invocation[12], '-o', actual[-1]]
assert actual == expected and len(actual) == 19
assert actual[-1].startswith('/') and actual[-1].endswith('.s')

dump = gzip.decompress((witness / 'dumpspecs.stdout.gz').read_bytes()).decode()
blocks = re.findall(r'^\*([^:\n]+):\n(.*?)(?=^\*|\Z)', dump, re.M | re.S)
specs = {name: value.removesuffix('\n\n') for name, value in blocks}
assert len(specs) == len(blocks) == 47
assert max(map(len, specs.values())) == 2901
for name in ('self_spec', 'startfile_prefix_spec', 'sysroot_suffix_spec',
             'sysroot_hdrs_suffix_spec'):
    assert specs[name] == ''
assert specs['link_command'].startswith('%{!fsyntax-only:%{!c:')
assert '%:debug-level-gt(0)' in specs['asm_debug_option']
assert '%:local_cpu_detect' in specs['cc1_cpu']
ada = sources['gcc/ada/gcc-interface/lang-specs.h']
ada_selected = ada.split('{"@ada",', 1)[1].split('{"@adawhy",', 1)[0]
assert len(ada_selected) + len(' %<dumpdir %<dumpbase %<dumpbase-ext %{d*} %:dumps()') < 2901
assert '%{g*&m*&f*}' in ada_selected
assert '%{!gnatc*:%{!gnats*:%(invoke_as)}}' in ada_selected

# LP64 field layouts and explicit request arithmetic; no compiler execution.
pointer = 8
decoded_size = 12 * pointer  # 11 eight-byte fields plus int/padding
switch_size = 2 * pointer + 4 + 3 + 1
infile_size = 3 * pointer + 3 + 5
assert (decoded_size, switch_size, infile_size) == (96, 24, 32)
retained_switches = 9 + 2
assert retained_switches + 1 <= 16 and 1 + 1 <= 16
arg_capacity = 10
max_demand = 19 + 1
while arg_capacity < max_demand:
    arg_capacity = arg_capacity * 2 if arg_capacity < 16 else arg_capacity * 3 // 2
assert arg_capacity == 20
P = 222
local_strings = max(2902, P + 9, 6 * P + 37)
assert local_strings <= 2**31 - 1
result = {
    'scope': 'Selected standalone native Main driver; not GPR/binder/link/producer',
    'source_files_checked': len(sources),
    'configured_named_specs': len(specs),
    'initial_argv_positions': 13,
    'retained_switches': retained_switches,
    'input_files': 1,
    'initial_decoded_option_request_bytes': 13 * decoded_size,
    'per_default_decoded_option_request_bytes': 2 * decoded_size,
    'per_default_temporary_argv_bytes': 2 * pointer,
    'switch_array_request_bytes': 16 * switch_size,
    'infile_array_request_bytes': 16 * infile_size,
    'output_array_request_bytes': pointer,
    'explicit_link_file_array_request_bytes': 1,
    'frontend_argv_positions': 19,
    'assembler_argv_positions': 5,
    'argbuf_capacity': arg_capacity,
    'argbuf_object_bytes': 8 + arg_capacity * pointer,
    'function_context_vector_object_bytes': 8 + 10 * pointer,
    'execute_command_object_bytes': 2 * pointer,
    'successful_execution_counter_increments': 2,
    'spec_function_calls': 3,
    'selected_P_example': P,
    'local_spec_string_object_bound': local_strings,
    'aggregate_memory_or_address_span_gate': False,
    'source_argument_required': True,
    'compiler_or_prover_executed': False,
    'whole_driver_or_program_capacity_established': False,
}
result_file = here / 'checks.json'
if result_file.exists():
    assert result == json.loads(result_file.read_text())
print(json.dumps(result, indent=2))

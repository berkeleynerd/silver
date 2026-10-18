#!/usr/bin/env python3
"""Check retained source/layout inputs for real startup; execute no compiler."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import struct
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', required=True, type=Path)
parser.add_argument('--gnat1', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
digest = lambda raw: hashlib.sha256(raw).hexdigest()
identity = json.loads((root / 'real-function-start-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], row['path']
    sources[row['path']] = raw.decode()

row = identity['reused_identity']
raw = (root / row['path']).read_bytes()
assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
retained = json.loads(raw)
row = retained['headers_archive']
raw = (root / row['path']).read_bytes()
assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
headers = {}
with tarfile.open(fileobj=io.BytesIO(raw), mode='r:gz') as archive:
    for row in retained['selected_headers']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
        headers[row['path']] = raw.decode()

binary = args.gnat1.read_bytes()
assert digest(binary) == retained['binary']['sha256']
assert binary[:6] == b'\x7fELF\x02\x01'
offset = struct.unpack_from('<Q', binary, 32)[0]
entry_size, count = struct.unpack_from('<HH', binary, 54)
segments = [struct.unpack_from('<IIQQQQQQ', binary, offset + i * entry_size)
            for i in range(count)]


def at(address, length):
    for kind, flags, pos, start, physical, size, memory, alignment in segments:
        if kind == 1 and start <= address and address + length <= start + size:
            return binary[pos + address - start:pos + address - start + length]
    raise AssertionError(hex(address))


for row in retained['allocation_immediates']:
    code = bytes.fromhex(row['hex'])
    assert at(int(row['address'], 16), len(code)) == code
sizes = {row['object']: row['request'] for row in retained['allocation_immediates']}
assert sizes['function'] == 208 and sizes['eh_status'] == 48
assert sizes['machine_function'] == 320
assert sizes['rtx_constant_pool'] == 32
assert sizes['constant_pool_hash_wrapper'] == 48

# These guards bind the arithmetic to the inspected source routes. The report
# supplies the path proof; matching these strings is not semantic certification.
fn = sources['gcc/function.cc']
trans = sources['gcc/ada/gcc-interface/trans.cc']
assert 'allocate_struct_function (gnu_subprog, false);' in trans
assert 'allocate_struct_function (gnu_elab_proc_decl, false);' in trans
assert 'crtl->abi = &fndecl_abi (cfun->decl).base_abi ();' in fn
assert 'if (!in_dummy_function)' in fn
assert 'if (opts != optimization_default_node)' in fn
assert 'static GTY(()) hash_table<temp_address_hasher> *temp_slot_address_table;' in fn
assert 'if (VOID_TYPE_P (type))\n    return false;' in fn
assert 'void empty () { if (elements ()) empty_slow (); }' in sources['gcc/hash-table.h']
assert 'default_rtl_profile (void)\n{\n  crtl->maybe_hot_insn_p = true;' in sources['gcc/predict.cc']
assert 'OPT_LEVELS_2_PLUS, OPT_fipa_ra' in sources['gcc/opts.cc']
target = sources['gcc/config/i386/i386-options.cc']
assert 'target_option_default_node = target_option_current_node' in target
assert 'TYPE_DEFAULT_CALL_SAVED_REGISTERS = 0' in sources['gcc/config/i386/i386.h']
assert 'if (old_tree != new_tree || fp_flag_change)' in target
for macro in ('INIT_EXPANDERS', 'TARGET_FNTYPE_ABI', 'TARGET_OPTION_RELAYOUT_FUNCTION'):
    assert not any(re.search(r'^\s*#\s*define\s+' + macro + r'\b', s, re.M)
                   for s in headers.values())
    assert not re.search(r'^\s*#\s*define\s+' + macro + r'\b',
                         sources['gcc/config/i386/i386.cc'], re.M)

function_count = 2
direct_per_function = 1 + 1 + 2 + 1
reg_slots = 92 + 6 + 100
assert reg_slots == 198
result = {
    'scope': identity['scope'],
    'source_files_verified': len(sources),
    'retained_installed_headers_verified': len(headers),
    'retained_allocation_immediates_verified': len(retained['allocation_immediates']),
    'selected_path_premises': {
        'emitted_functions': ['Main'],
        'additional_unfinalized_function': 'empty elaboration procedure',
        'optimization': 'O0 with no override',
        'ABI': 'Linux x86-64 SysV with default target options',
        'function_specific_target_or_optimization_attributes': False,
        'stack_usage_or_callgraph_info': False,
        'debug_profile_instrumentation_or_alignment_overrides': False,
        'first_RTL_setup_and_no_temp_slot_cost_probes_reused': True,
        'whole_translation_constructor_graph_included': False,
    },
    'gigi_struct_function_constructors': {
        'calls': function_count,
        'GGC_events_each': direct_per_function,
        'GGC_events_total': function_count * direct_per_function,
        'individual_raw_requests_each': [208, 48, 40, 40, 320],
        'funcdef_no_increment': function_count,
        'result_and_parameter_relayout_GGC_events': 0,
        'default_ABI_and_option_hooks_GGC_events': 0,
        'language_function_and_tree_objects_included': False,
    },
    'Main_real_RTL_prepare': {
        'struct_function_reallocated': False,
        'GGC_events_total': 4,
        'individual_raw_requests': [reg_slots * 8, 32, 48, 31 * 8],
        'ordinary_reg_alignment_bytes': reg_slots,
        'new_virtual_REG_objects': 0,
        'temp_hash_new_GGC_events': 0,
        'temp_hash_is_rooted_empty_table_from_dummy_setup': True,
        'temp_hash_backbone_raw_bytes_already_charged': 61 * 8,
        'section_selection_GGC_events': 0,
        'first_RTL_target_setup_already_charged_separately': True,
    },
    'additional_disjoint_GGC_events': function_count * direct_per_function + 4,
    'whole_native_capacity_established': False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'source_files': len(sources), 'headers': len(headers),
                  'additional_GGC_events': result['additional_disjoint_GGC_events'],
                  'whole_native_capacity_established': False}))

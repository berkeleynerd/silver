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
         'stringt.adb', 'uintp.adb', 'exp_dbug.adb', 'scng.adb', 'hostparm.ads',
         'tbuild.adb', 'lib.adb', 'sem_ch3.adb', 'par-ch4.adb', 'par.adb',
         'par-ch5.adb', 'par-ch6.adb', 'par-util.adb', 'par-endh.adb',
         'par-labl.adb', 'elists.adb', 'sem_ch5.adb']
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

def demand_envelope(demand, initial, factor, increment):
    """Bound backing length from bounded logical demand, including Release.

    Requires nonnegative instance parameters, valid caller operations and saved
    states from this same invariant. Does not bound the number of source events.
    """
    assert min(demand, initial, factor, increment) >= 0
    before_growth = max(demand, initial)
    return max(initial * factor,
               demand + demand // 1000,
               before_growth * (100 + increment) // 100,
               before_growth + 10)

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
paren_count_sites = []
parser_auxiliary_sites = []
inventory_paths = sorted(path for path in a.ada_source.iterdir()
                         if path.suffix in ('.ads', '.adb') and path.is_file())
expected_names = {name for name in expected
                  if '/' not in name and Path(name).suffix in ('.ads', '.adb')}
if {path.name for path in inventory_paths} != expected_names:
    raise SystemExit('Pinned top-level Ada source inventory mismatch')
for path in inventory_paths:
    source = verify_source(path).decode()
    lines = source.split('\n')
    for match in re.finditer(r'\bSet_Paren_Count\s*\(', source, re.I):
        number = source.count('\n', 0, match.start()) + 1
        paren_count_sites.append({'file': path.name, 'line_lf': number,
                                  'source': lines[number - 1].strip()})
    if path.name.startswith('par'):
        for number, line in enumerate(lines, 1):
            if re.search(r'\b(?:Push_Scope_Stack|Loop_Block_Count|'
                         r'Set_Loop_Block_Name|Goto_List|Label_List)\b|'
                         r'\b(?:Scope|Suspicious_Labels)\s*\.', line, re.I):
                parser_auxiliary_sites.append({'file': path.name,
                                               'line_lf': number,
                                               'source': line.strip()})
    # Lexical inventory only: comments, reachability, alternate allocators and
    # generated sources require separate source review, not inference here.
    for m in re.finditer(r'package\s+(\w+)\s+is\s+new\s+Table\.Table\s*\((.*?)\);', source, re.S | re.I):
        instances.append({'file': path.name,
                          'line_lf': source.count('\n', 0, m.start()) + 1,
                          'package': m[1], 'actual_parameters': m[2].strip()})
line_sequence = [500]
while line_sequence[-1] * 2 * 32 <= I:
    line_sequence.append(line_sequence[-1] * 2)

def final_column(line):
    """Exact selected ASCII recurrence in Scng.Check_End_Of_Line."""
    column = 1
    for byte in line:
        assert byte == 9 or 32 <= byte <= 126
        column = (column - 1 + 8) // 8 * 8 + 1 if byte == 9 else column + 1
    return column

column_cases = []
for label, line in [('32765 ASCII bytes', b'x' * 32765),
                    ('32766 ASCII bytes', b'x' * 32766),
                    ('4095 tabs', b'\t' * 4095),
                    ('4096 tabs', b'\t' * 4096),
                    ('4095 tabs and five bytes', b'\t' * 4095 + b'xxxxx'),
                    ('4095 tabs and six bytes', b'\t' * 4095 + b'xxxxxx')]:
    column = final_column(line)
    column_cases.append({'case': label, 'physical_bytes': len(line),
                         'final_column': column,
                         'passes_selected_line_checks':
                         len(line) <= 32766 and (len(line) < 4096 or column <= 32766),
                         'passes_sufficient_column_rule': column <= 32766})
assert [case['passes_sufficient_column_rule'] for case in column_cases] == [True, False, True, False, True, False]

def qualification(lengths, homonyms):
    assert lengths and min(lengths) > 0
    assert all(1 <= value <= I for value in homonyms)
    h = sum(len(str(value)) for value in homonyms) + max(len(homonyms)-1, 0)
    q = sum(lengths) + 2*(len(lengths)-1) + (2+h if homonyms else 0)
    return {'component_lengths': lengths, 'homonyms': homonyms,
            'homonym_temporary_length': h, 'qualified_length_bound': q,
            'homonym_buffer_fits': h <= 256}

qualification_cases = [qualification([4, 12], []),
                       qualification([4, 12, 12, 12, 12], []),
                       qualification([4] + [12]*129, [1]*129),
                       qualification([4] + [12]*23, [I]*23),
                       qualification([4] + [12]*24, [I]*24)]
assert [case['qualified_length_bound'] for case in qualification_cases[:2]] == [18, 60]
assert [case['homonym_temporary_length'] for case in qualification_cases[2:]] == [257, 252, 263]
result = {
    'source_commit': pin,
    'source_relation': 'every inspected/inventoried file verified against retained pinned-tree manifest',
    'source_files_verified': len(verified),
    'source_hash_mismatches': 0,
    'source_sha256': {f: verified[f] for f in files},
    'demand_envelope': {
        'kind': 'sufficient backing-length bound; no whole-source demand established',
        'string_example_demand': 858993458,
        'string_example_backing_length_bound': demand_envelope(858993458, 2500, 1, 150),
        'next_demand_backing_length_bound': demand_envelope(858993459, 2500, 1, 150),
        'sentinel_length_requirement': 'backing_length_bound + 1 <= Int_Last',
        'scope': 'nonnegative parameters, well-formed caller operations and saved states; separate index/byte/nominal-ID checks required',
    },
    'string_growth': growth(2500, 150),
    'line_capacity_sequence': line_sequence,
    'next_line_capacity': line_sequence[-1] * 2,
    'next_line_intermediate_bits': line_sequence[-1] * 2 * 32,
    'ascii_line_column_cases': column_cases,
    'line_rule_scope': 'ASCII/HT between CR, LF, CRLF or EOF; selected no-style-check scan; final column <=32766 is a sufficient local rule, not whole-source admission',
    'name_components': {
        'nominal_usable_ids': -300000000 - (-399999997) + 1,
        'initialized_entries': 256,
        'initialized_characters': 512,
        'entry_bytes': 16,
        'source_word_entry_charge': 'W',
        'source_word_character_charge': 'sum(source_word_lengths) + W',
        'maximum_stored_name_length': 32767,
        'global_name_buffer_characters': 4 * 32766,
        'default_local_name_buffer_characters': 4096,
        'internal_name_maximum_unqualified_length': 2 + len(str(I)),
        'internal_name_maximum_character_charge': 3 + len(str(I)),
        'qualification_cases': qualification_cases,
        'integer_discrete_encoding_extra_characters': 5 + 3 + 2*11 + 2,
        'scope': 'local calls/source word interning; not generated-name caller counts or qualification/consumer closure',
    },
    'lexical_table_instance_count': len(instances),
    'main_parser_auxiliaries': {
        'scope_peak_entry_count': '2 + maximum nested if/for statement depth',
        'scope_initial': 50,
        'scope_increment_percent': 100,
        'suspicious_label_appends': 'Q <= F; bare Reject followed by for',
        'suspicious_label_entry_bytes': 12,
        'suspicious_label_initial': 50,
        'suspicious_label_increment_percent': 100,
        'loop_counter_delta': 'F; incoming counter plus F must fit Nat',
        'loop_name_entry_charge': 'F',
        'loop_name_character_charge': 'F * 13 including NUL',
        'element_list_headers': 3,
        'element_list_elements': '2 * F',
        'element_list_entry_bytes': 8,
        'loop_auxiliary_ordinary_nodes': '2 * F',
        'loop_auxiliary_entities': 'F; same loop scopes as entity component',
        'implicit_declaration_list_links': 'F',
        'extra_ordinary_lists': 0,
        'lexical_sites': parser_auxiliary_sites,
        'scope': 'one successful Main parse and Par.Labl, current grammar; '
                 'not ordinary parser nodes/scanner multiplicities or dependency parsing',
    },
    'parenthesis_counts': {
        'lexical_setter_sites': paren_count_sites,
        'auxiliary_entry_bytes': 8,
        'entry_demand_bound': 'one per ordinary node allocation/copy event',
        'count_value_bound': 'max(1, maximum parser nesting over selected files)',
        'table_initial': 10,
        'table_increment_percent': 200,
        'source_nesting_from_file_bytes': 'floor(B/2)',
        'scope': 'manual caller classification; lexical inventory is not a reachability proof',
    },
    'lexical_table_instances': instances,
    'limitations': ['no compiler run', 'no complete allocation-route closure',
                    'no whole-program upper bound', 'no safe language threshold',
                    'growth sequence excludes Release/Save/Restore and nonzero low bounds'],
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: result[k] for k in ['lexical_table_instance_count', 'next_line_capacity',
                                     'next_line_intermediate_bits']}, indent=2))

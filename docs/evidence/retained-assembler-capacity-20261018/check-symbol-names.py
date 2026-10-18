#!/usr/bin/env python3
"""Reconcile the selected GAS/BFD no-at-sign symbol-name transfer offline."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
manifest = json.loads((root / 'source-manifest.json').read_text())
sources = {}
with tarfile.open(root / 'sources.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files'])
    for row in manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes']
        assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
        sources[row['path']] = raw.decode()

anchors = {
    'gas/write.h': ['#define FAKE_LABEL_NAME "L0\\001"'],
    'gas/symbols.c': [
        "#define LOCAL_LABEL_CHAR\t'\\002'",
        'ret = notes_strdup (name);', 'symbolP->bsym->name = name;',
        'bsymnew->name = bsymorg->name;',
        'return symbol_new (FAKE_LABEL_NAME, seg, frag, ofs);',
        'return symbol_make (FAKE_LABEL_NAME);',
        'sprintf (p, "L%u%c%u",', 'dot_symbol.bsym->name = ".";',
    ],
    'gas/expr.c': ['symbolP = symbol_create (FAKE_LABEL_NAME,'],
    'gas/config/obj-elf.h': ["#define LOCAL_LABEL_PREFIX '.'"],
    'gas/config/obj-elf.c': [
        'symbolS *sym = symbol_new (s, absolute_section, &zero_address_frag, 0);',
        'sy_obj->versioned_name = NULL;',
        'versioned_name = sy_obj->versioned_name;\n  if (versioned_name)',
        'S_SET_NAME (symp, versioned_name->name);',
    ],
    'gas/subsegs.c': ['s = symbol_create (sec->symbol->name, sec, &zero_address_frag, 0);',
                       's = symbol_new (sec->symbol->name, sec, &zero_address_frag, 0);'],
    'bfd/section.c': ['newsect->symbol->name = newsect->name;'],
    'bfd/elf.c': ['sym.st_name = 0;',
                 'size_t stridx = _bfd_elf_strtab_add (stt, syms[idx]->name, false);'],
    'gas/config/te-linux.h': ['#define TE_LINUX', '#define LOCAL_LABELS_FB 1'],
}
for path, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[path], (path, fragment)
headers = ['gas/as.h', 'gas/obj.h', 'gas/tc.h', 'gas/config/te-linux.h',
           'gas/config/tc-i386.h', 'gas/config/obj-elf.h']
for path in headers:
    for macro in ['FAKE_LABEL_NAME', 'tc_canonicalize_symbol_name']:
        assert not re.search(r'^\s*#\s*define\s+'+macro+r'\b', sources[path], re.M)

# Inputs are the selected compiler stream, not arbitrary user assembly. Labels
# receive decimal counters; this alphabet-level property does not depend on
# their count. Property-note numeric labels use only digits 0 through 4.
compiler_names = ['_ada_main', 'main.adb', '.L', '.LCFI', '.LFB', '.LFE',
                  '0', '1', '2', '3', '4']
section_names = ['.text', '.data', '.bss', '.eh_frame', '.sframe', '.comment',
                 '.note.GNU-stack', '.note.gnu.property', '.symtab', '.strtab',
                 '.shstrtab', '.rela.eh_frame', '.rela.sframe', '*ABS*',
                 '*UND*', '*COM*', '*EXPR*', '*REG*']
constructor_alphabets = {
    'temporary_and_expression': 'L0\x01',
    'forward_backward_numeric': '.L0123456789\x02',
    'dot': '.',
    'predefinition_version': 'GAS(version)',
    'predefinition_date': 'GAS(date)',
}
assert all('@' not in s for s in compiler_names + section_names)
assert all('@' not in s for s in constructor_alphabets.values())
obj = json.loads((root / 'object-check-results.json').read_text())
assert obj['outgoing_symbol_entries_including_null'] == 98
lifecycle = json.loads((root / 'lifecycle-check-results.json').read_text())
assert lifecycle['predefined_output_chain_objects_selected'] == 0

result = {
    'scope': 'Selected null Main GAS/BFD symbol-name transfer',
    'binutils_commit': manifest['commit'],
    'complete_sources_verified': len(sources),
    'selected_headers_checked': headers,
    'compiler_name_classes': compiler_names,
    'section_name_union': section_names,
    'GAS_constructor_alphabets': constructor_alphabets,
    'selected_final_ELF_symbol_names_have_no_literal_at': True,
    'input_requirements': [
        'Established selected null compiler stream and fixed main.adb file spelling',
        'No user assembly, symver, arbitrary section/group/visibility or GOT operand',
        'Selected x86 ELF target and invocation; no symbol canonicalization override',
    ],
    'transfer': [
        'GAS creates names from input, fixed sections or the listed constructor alphabets',
        'Copies, local/full conversion and clones preserve those names',
        'Absent symver leaves the version-name rename branch disabled',
        'BFD section symbols reuse section names; ELF serialization copies or empties names',
    ],
    'compiler_directive_at_tokens_are_symbol_names': False,
    'complete_inner_parser_and_writer_call_inventory': False,
    'complete_capacity_result': False,
    'native_execution': False,
    'reachability_basis': 'Handwritten selected-stream/source argument; anchors are not C semantic verification',
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))

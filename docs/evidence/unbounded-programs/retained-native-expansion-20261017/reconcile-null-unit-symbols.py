#!/usr/bin/env python3
"""Reconcile null Main symbol constructors and direct unit-output guards offline."""
import argparse
import hashlib
import json
import re
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'null-unit-symbols-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row['path']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
for row in identity['reused_results']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']

anchors = {
    'gcc/cgraph.cc': ['return new (ggc_alloc<cgraph_node> ()) cgraph_node ();',
                      'node->register_symbol ();', 'maybe_record_nested_function (node);'],
    'gcc/varpool.cc': ['return new (ggc_alloc<varpool_node> ()) varpool_node ();',
                       'if (DECL_HARD_REGISTER (decl))\n    return false;'],
    'gcc/cgraph.h': ['nodes->m_uid = cgraph_max_uid++;',
                     'if (node->order == -1)\n    node->order = order++;',
                     'section_hash (NULL), assembler_name_hash (NULL), init_priority_hash (NULL)'],
    'gcc/symtab.cc': ['if (is_a <varpool_node *> (node) && DECL_HARD_REGISTER (node->decl))\n    return;',
                      'assembler_name_hash = hash_table<asmname_hasher>::create_ggc (10);',
                      'ref_list.clear ();'],
    'gcc/ipa-ref.h': ['referring.create (0);', 'references.create (0);'],
    'gcc/vec.h': ['if (nelems > 0)\n    reserve_exact (nelems PASS_MEM_STAT);'],
    'gcc/tree-nested.cc': ['&& TREE_CODE (DECL_CONTEXT (node->decl)) == FUNCTION_DECL)'],
    'gcc/ada/gcc-interface/utils.cc': [
        'ASM_FORMAT_PRIVATE_NAME (label, first_global_object_name, ULONG_MAX);',
        'DECL_HARD_REGISTER (dummy_global) = 1;',
        'node = varpool_node::get_create (dummy_global);'],
    'gcc/ada/gcc-interface/decl.cc': ['Get_External_Name (gnat_entity, has_suffix, sp);'],
    'gcc/ada/gcc-interface/trans.cc': ['t = create_concat_name (Defining_Entity (Unit (gnat_root)), NULL);'],
    'gcc/defaults.h': ['#  define ASM_PN_FORMAT "%s.%lu"',
                       '(char *) alloca (strlen (name_) + 32);'],
    'gcc/function.cc': ['if (debug_info_level > DINFO_LEVEL_NONE)',
                        'vec_safe_push (types_used_by_cur_var_decl, t);'],
    'gcc/hash-table.h': ['hash_table *table = ggc_alloc<hash_table> ();',
                         'm_size * 3 <= m_n_elements * 4'],
    'gcc/omp-offload.cc': ['if (num_funcs == 0 && num_vars == 0 && num_ind_funcs == 0)\n    return;'],
    'gcc/emit-rtl.cc': ['prologue_location = epilogue_location = 0;',
                       'curr_location = UNKNOWN_LOCATION;'],
    'gcc/varasm.cc': ['pool->first = NULL;',
                      'v.create (object_block_htab->elements ());',
                      'if (tm_clone_hash == NULL)\n    return;',
                      'for (t = weakref_targets; t; t = TREE_CHAIN (t))',
                      'for (t = weak_decls; t; t = TREE_CHAIN (t))',
                      'for (list = pending_assemble_externals; list; list = TREE_CHAIN (list))',
                      'for (rtx list = pending_libcall_symbols; list; list = XEXP (list, 1))'],
    'gcc/dwarf2asm.cc': ['if (!indirect_pool)\n    return;'],
    'gcc/dwarf2out.cc': ['#define FUNC_BEGIN_LABEL\t"LFB"',
                        '#define FUNC_END_LABEL\t\t"LFE"'],
    'gcc/dwarf2cfi.cc': ['ASM_GENERATE_INTERNAL_LABEL (label, "LCFI", num);'],
    'gcc/config/i386/gnu-property.cc': ['fprintf (asm_out_file, "0:\\n");',
                                       'fprintf (asm_out_file, "4:\\n");'],
    'gcc/config/i386/i386.cc': ['static bool indirect_thunk_needed = false;',
                               'static bool indirect_return_needed = false;',
                               'static int pic_labels_used;'],
    'gcc/toplev.cc': ['output_shared_constant_pool ();', 'output_object_blocks ();',
                     'finish_tm_clone_pairs ();', 'weak_finish ();',
                     'process_pending_assemble_externals ();'],
}
for path, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[path], (path, fragment)

target = json.loads((root / 'null-symbols-source-identity.json').read_text())
by_path = {row['path']: row for row in target['files']}
for path in target['selected_target_headers']:
    raw = (args.gcc_root / path).read_bytes()
    assert hashlib.sha256(raw).hexdigest() == by_path[path]['sha256']
    for override in ['ASM_PN_FORMAT', 'ASM_FORMAT_PRIVATE_NAME', 'NO_DOT_IN_LABEL',
                     'FUNC_BEGIN_LABEL', 'FUNC_END_LABEL']:
        assert not re.search(r'^\s*#\s*define\s+'+override+r'\b', raw.decode(), re.M)

graph = json.loads((root / 'native-null-symbols.json').read_text())['incoming_IPA_join']
assert graph['function_nodes'] == graph['variable_nodes'] == 1
assert all(graph[k] == 0 for k in ['call_edges', 'symbol_references', 'aliases',
                                  'thunks', 'nested_functions', 'variable_initializers'])
meta = json.loads((root / 'native-null-gigi-metadata.json').read_text())
assert meta['updated_selected_known_GGC_subtotal'] == 40024

# Give every named bitfield its own four-byte storage unit. Fixed source
# identities bind the LF-numbered regions; no compiler sizeof probe is used.
def bitfields(lo, hi):
    chunk = '\n'.join(sources['gcc/cgraph.h'].split('\n')[lo-1:hi])
    chunk = re.sub(r'/\*.*?\*/', '', chunk, flags=re.S)
    return len(re.findall(r'\b(?:unsigned|ENUM_BITFIELD\s*\([^)]*\))\s+\w+\s*:\s*\d+\s*;', chunk))

assert (bitfields(532, 651), bitfields(1505, 1576), bitfields(2352, 2364)) == (28, 28, 4)
def align8(n):
    return (n+7)//8*8
top = 3*8 + 4 + 4
symtab = align8(top + 28*4 + 8*8 + 2*8 + 4)
cgraph = align8(symtab + 14*8 + 16 + 4*4 + 28*4 + 4)
varpool = align8(symtab + 4*4)
assert (top, symtab, cgraph, varpool) == (32, 232, 496, 248)
assert cgraph <= 512 and varpool <= 256
global_name = '_ada_main'
dummy_name = global_name + '.' + str(2**64-1)
assert len(global_name)+32 == 41
assert len(dummy_name)+1 == 31 <= 41
compiler_spellings = ['_ada_main', 'main.adb', '.L', '.LCFI', '.LFB', '.LFE',
                      '.text', '.data', '.bss', '.note.GNU-stack',
                      '.note.gnu.property', '0', '1', '2', '3', '4']
assert all('@' not in name for name in compiler_spellings)
prime_region = sources['gcc/hash-table.cc'].split('struct prime_ent const prime_tab[] = {', 1)[1].split('};', 1)[0]
primes = [int(x) for x in re.findall(r'\{\s+(\d+),', prime_region)]
assert next(x for x in primes if x >= 10) == 13
assert 1*4 < 13*3
identifier_insertions = meta['ordinary_identifier_hash']['live_plus_deleted_insertions_upper']+1
assert identifier_insertions*4 < 65536*3
rows = [
    dict(object='Main cgraph node', requests=1, raw_bytes_upper=512),
    dict(object='forced dummy varpool node', requests=1, raw_bytes_upper=256),
    dict(object='forced dummy void VAR_DECL', requests=1, raw_bytes_upper=312),
    dict(object='forced dummy identifier', requests=1, raw_bytes_upper=40),
    dict(object='forced dummy identifier characters', requests=1, raw_bytes_upper=31),
    dict(object='optional assembler-name hash control', requests=1, raw_bytes_upper=128),
    dict(object='optional assembler-name hash entry backing', requests=1, raw_bytes_upper=13*8),
]
events = sum(r['requests'] for r in rows)
assert events == 7
result = dict(
    scope='Selected null Main symbol constructors and direct end-of-unit output guards',
    gcc_commit=identity['gcc_commit'], checked_source_identities=len(sources),
    selected_target_headers_checked=len(target['selected_target_headers']),
    objects=rows, additional_GGC_events=events,
    existing_selected_known_GGC_subtotal=40024,
    updated_selected_known_GGC_subtotal=40024+events,
    dummy_private_identifier=dummy_name, dummy_stack_format_buffer_bytes=41,
    cgraph_layout_ceiling=cgraph, varpool_layout_ceiling=varpool,
    assembler_name_hash=dict(live_entries_upper=1, historical_inserts_upper=1,
                             slots_upper=13, backing_raw_bytes_upper=104),
    shared_identifier_hash=dict(historical_inserts_upper=identifier_insertions,
                                slots_upper=65536, backing_raw_bytes_upper=524288),
    nested_function_summary_requests=0, debug_used_type_requests=0,
    direct_unit_output_guarded_additional_GGC_events=0,
    known_prior_emission_and_ordering_costs_reused=True,
    compiler_emitted_symbol_spellings_have_no_literal_at=True,
    compiler_name_classes=compiler_spellings,
    dummy_emitted_symbol_count=0,
    final_ELF_symbol_name_transfer_requires_GAS_BFD_join=True,
    reachability_basis='Handwritten source argument under the prior null graph, full schedule and effective options; anchors do not prove C semantics',
    required_remaining_inputs=[
        'Variable source/path/line-map and Ada callback metadata',
        'Initial GIMPLE/CFG/SSA, warnings/rangers, cgraph analysis/IPA summaries and manager lifetimes',
        'Whole-schedule GGC pages/finalizers and remaining shared ordinary pools',
        'Driver/process teardown and selected host-library formatting/stdio representations'],
    aggregate_RAM_admission_gate=False, native_execution=False,
    complete_capacity_result=False)
args.output.write_text(json.dumps(result, indent=2, sort_keys=True)+'\n')
print(json.dumps(dict(identities=len(sources), added_GGC_events=events,
                     known_subtotal=40024+events, complete_capacity_result=False)))

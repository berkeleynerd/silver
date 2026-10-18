"""Replay retained literal-output RTL identities and arithmetic; no native tools."""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
sha = lambda b: hashlib.sha256(b).hexdigest()
inputs = {}
for row in json.loads((root / 'inputs.json').read_bytes()):
    raw = (root / row['file']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['file']
    inputs[row['file']] = json.loads(raw)

m = json.loads((root / 'manifest.json').read_bytes())
assert m['source_commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
a = m['archive']
raw = (root / a['file']).read_bytes()
assert len(raw) == a['bytes'] and sha(raw) == a['sha256']
sources = {}
with tarfile.open(root / a['file']) as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in m['files'])
    for row in m['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
        sources[row['path']] = raw

overlap = 0
for row in inputs['native-source-inputs.json']['files']:
    if row['path'] in sources:
        raw = sources[row['path']]
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256']
        overlap += 1

# These checks preserve selected source landmarks, not a translation of GCC.
# The companion argument supplies the path and semantic interpretation.
anchors = {
    'common.opt': ['Common Var(flag_split_wide_types) Optimization',
                   'Common Var(flag_split_wide_types_early) Optimization'],
    'lower-subreg.cc': ['mode_move_cost >= word_move_cost * factor',
                       'regno_reg_rtx[regno] = NULL_RTX;',
                       'v = rtvec_alloc (words);',
                       'gen_reg_rtx_offset (reg, word_mode, i * UNITS_PER_WORD)',
                       'PUT_CODE (reg, CONCATN);',
                       'bool gate (function *) final override { return flag_split_wide_types != 0; }',
                       'return flag_split_wide_types && flag_split_wide_types_early;'],
    'simplify-rtx.cc': ['if (outermode == innermode && known_eq (byte, 0U))\n    return op;'],
    'emit-rtl.cc': ['int new_size = old_size * 2;',
                    'regno_reg_rtx[reg_rtx_no++] = val;'],
    'ira.cc': ['ira_conflicts_p = optimize > 0;',
               'hard_regno = reg_alloc_order[i];'],
    'ira-costs.cc': ['else if (!optimize && !targetm.class_likely_spilled_p (best))',
                     'if (optimize && ALLOCNO_CLASS (a) != pref[i])'],
    'ira-color.cc': ['if (costs == NULL)', 'best_hard_regno = hard_regno;',
                     'fast_allocation ();'],
    'config/i386/i386.cc': ['if (GENERAL_REGNO_P (i) && call_used_or_fixed_reg_p (i))',
                            'case DIREG:', 'case SIREG:',
                            'return COSTS_N_INSNS (CEIL (GET_MODE_SIZE (mode), units));',
                            'xasm = "%!call\\t%P0";'],
    'lra.cc': ['lra_pmode_pseudo = gen_reg_rtx (Pmode);',
               'if (! reloads_p && lra_constraint_iter > 1)',
               'if (! lra_need_for_spills_p ())'],
    'lra-spills.cc': ['if (lra_reg_info[i].nrefs != 0 && lra_get_regno_hard_regno (i) < 0'],
    'lra-constraints.cc': ['&& targetm.register_move_cost (GET_MODE (src), sclass, dclass) == 2);'],
    'dwarf2cfi.cc': ['if (note == NULL)\n    return;',
                     'eh_landing_pad lp = get_eh_landing_pad_from_rtx (insn);'],
}
for name, snippets in anchors.items():
    source = sources['gcc/' + name].decode()
    for snippet in snippets:
        assert snippet in source, (name, snippet)

INT_MAX = 2**31 - 1


def shape(c, n):
    assert c >= 0 and n >= 0 and c+n >= 1
    entry = 7*c+3*n+12
    layout_edges = n+4
    ira = entry+2*layout_edges
    reload = ira+1
    late_merges = 2*n+7
    frame = reload+4+2+1+late_merges
    final = frame+5+5
    nop = n+3+layout_edges+late_merges
    k = 99+5*c
    # This is the existing 198-entry, signed doubling scheme. Check the
    # actual first-unused index, not just the live pseudo count.
    capacity = 198
    while capacity <= k-1:
        capacity *= 2
    text = 2*c*7+4*c*3+c*5+nop+8
    return {
        'calls': c, 'nulls': n,
        'pass_expand_chain': entry,
        'split_added_REG_requests': 2*c,
        'split_added_two_element_rtvec_requests': c,
        'split_added_reg_attrs_requests_upper': 2*c,
        'split_referenced_pseudos_upper': 4*c,
        'lifetime_dynamic_pseudo_requests_upper': 5*c+1,
        'first_unused_pseudo_number_upper': k,
        'register_array_capacity_upper': capacity,
        'IRA_entry_chain': ira, 'postreload_chain': reload,
        'postframe_chain': frame, 'final_chain': final,
        'first_unused_UID_upper': final+1,
        'ordinary_blocks_upper': 2*n+8,
        'edges_upper': 2*n+9,
        'block_slots_upper': 2*n+10,
        'nops_upper': nop,
        'CFI_traces_upper': n+5,
        'CFI_rows_upper': 2*n+10,
        'CFI_objects_upper': 12,
        'FDE_objects': 1,
        'instruction_text_lines_upper': 7*c+nop+4,
        'shortening_text_bytes_upper': text,
        'local_symbol_instruction_references_upper': 2*c,
        'external_call_instruction_references_upper': c,
        'local_representation_checks': {
            'first_unused_UID_signed_int': final+1 <= INT_MAX,
            'pseudo_number_signed_int': k <= INT_MAX,
            'register_array_signed_doubling': capacity <= INT_MAX,
            'block_index_signed_int': 2*n+10 <= INT_MAX,
            'shortening_address_signed_int': text <= INT_MAX,
        },
    }


native = inputs['native-entry.json']
c = native['source_counts']['output_calls']
n = native['source_counts']['null_statements']
entry = native['components']['conditional_native_pass_expand']
base = shape(c, n)
assert entry['descriptor_subreg_byte_offsets'] == [0, 8]
assert entry['descriptor_subreg_mode'] == 'DI'
assert entry['fresh_dynamic_pseudos_upper'] == 3*c
assert entry['instruction_chain_lifetime_requests_upper'] == base['pass_expand_chain']
assert entry['initial_local_stack_payload_bytes'] == entry['outgoing_argument_stack_bytes'] == 0
assert entry['descriptor_cross_call_liveness_excluded'] is False
assert entry['allocation_or_frame_bound_established'] is False

# Recompute the selected total-def liveness. Artificial SP/FP uses remain
# outside this pseudo-only model and are excluded from the nine-GPR count.
ops = [({'d0'}, set()), ({'d1'}, set()), ({'x'}, {'d0'}),
       ({'y'}, {'d1'}), ({'RDI'}, {'x'}), ({'RSI'}, {'y'}),
       ({'RDI', 'RSI'}, {'RDI', 'RSI'})]
live = set()
boundaries = [set()]
for defs, uses in reversed(ops):
    live = (live-defs) | uses
    boundaries.append(live)
assert not live
assert all(not (s & {'d0','d1','x','y'}) for s in [boundaries[0],boundaries[1],boundaries[-1]])
maximum_live_pseudos = max(len(s & {'d0','d1','x','y'}) for s in boundaries)

# The proof deliberately uses the stronger clique+two-hard-register bound:
# it remains valid for every allocator order and every possible hard-arg
# conflict subset, without depending on coalescing or exact live-point IDs.
caller_regs = [0, 1, 2, 4, 5, 36, 37, 38, 39]
allocation_cases = 0
for order in itertools.permutations(range(4)):
    for mask in range(4):
        blocked = {r for j, r in enumerate([4, 5]) if mask & (1 << j)}
        assigned = []
        for pseudo in order:
            available = [r for r in caller_regs if r not in blocked and r not in assigned]
            assert len(available) >= 4
            assigned.append(available[0])
        assert len(set(assigned)) == 4
        allocation_cases += 1

assert shape(0, 1)['final_chain'] == 52
assert shape(0, 1)['shortening_text_bytes_upper'] == 26
assert shape(1, 0)['IRA_entry_chain'] == 27
assert shape(1, 0)['final_chain'] == 52
assert shape(1, 0)['shortening_text_bytes_upper'] == 53
for c, n in [(1,0),(2,3),(5000,7),(0,5000)]:
    s = shape(c, n)
    assert s['final_chain'] == 7*c+7*n+45
    assert s['shortening_text_bytes_upper'] == 31*c+4*n+22
    assert s['nops_upper'] == 4*n+14
    assert all(s['local_representation_checks'].values())

text_c_boundary = (INT_MAX-22)//31
assert shape(text_c_boundary,0)['local_representation_checks']['shortening_address_signed_int']
assert not shape(text_c_boundary+1,0)['local_representation_checks']['shortening_address_signed_int']
uid_n_boundary = (INT_MAX-46)//7
assert shape(0,uid_n_boundary)['local_representation_checks']['first_unused_UID_signed_int']
assert not shape(0,uid_n_boundary+1)['local_representation_checks']['first_unused_UID_signed_int']

result = {
    'scope': 'Conditional split-wide literal-output native RTL through final text',
    'selected_added_option': '-fsplit-wide-types',
    'complete_source_files_verified': len(sources),
    'source_files_hash_equal_predecessor': overlap,
    'predecessor': inputs['native-entry.json']['scope'],
    'literal_predecessor_arithmetic': base,
    'source_selected_split_profitability': {'TI_cost':8,'DI_cost':4,'TI_words':2},
    'call_group_liveness_arithmetic': {'maximum_live_pseudos':maximum_live_pseudos,
                                      'pseudo_live_at_call_or_group_boundary':False},
    'allocator_availability_arithmetic': {'SysV_caller_GPRs':9,'other_pseudos_upper':3,
                                         'explicit_argument_hard_regs_upper':2,
                                         'free_caller_GPRs_lower':4,
                                         'order_and_conflict_cases':allocation_cases},
    'source_selected_LRA_passes': {'constraints':2,'live_range_construction':1,
                                  'assignment':1,'inheritance_upper':1,'undo_upper':1},
    'frame': {'saved_RBP_bytes':8,'compiler_local_or_spill_bytes':0,'outgoing_argument_bytes':0},
    'focused_arithmetic_checks': ['predecessor interface','whole-DI local liveness',
                                  'all four-pseudo orders and hard-arg subsets',
                                  'null-interface consistency','5000-call/null composition',
                                  'signed text and UID boundaries'],
    'native_tool_executions':0,
    'requires_companion_manual_source_argument':True,
    'all_lifetime_RTX_GGC_and_helper_storage_accounted':False,
    'updated_parent_and_child_option_storage_joined':False,
    'exact_selected_option_native_witness_run':False,
    'assembled_object_and_relocation_capacity_established':False,
    'whole_native_pipeline_capacity_established':False,
    'GNATprove_producer_capacity_established':False,
    'production_admission_changed':False,
}
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'source_files':len(sources),'predecessor_source_overlap':overlap,
                  'allocator_cases':allocation_cases,'output':str(args.output)}))

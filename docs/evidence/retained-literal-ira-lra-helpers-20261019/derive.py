#!/usr/bin/env python3
"""Named outer IRA and selected LRA helper storage; pure offline arithmetic.

This is not an actual-source adapter. The handwritten companion argument and
accepted source/configuration/owner premises remain necessary.
"""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32, U32, PTRDIFF_MAX = 2**31 - 1, 2**32 - 1, 2**63 - 1
UPSTREAM = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
ADAPTER = 'docs/evidence/retained-literal-ordinary-attachment-20261019/result.json'
OLD = 'docs/evidence/unbounded-programs/retained-native-expansion-20261017/'


def require(value, message):
    if not value:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def verify_inputs(gcc_source, manifest=None):
    manifest = read(HERE / 'inputs.json') if manifest is None else manifest
    require(manifest['GCC_revision'] == UPSTREAM, 'GCC revision')
    roots = dict(gcc=Path(gcc_source), repository=REPO)
    for row in manifest['files']:
        require(identity((roots[row['root']] / row['path']).read_bytes()) ==
                {k: row[k] for k in ('bytes', 'sha256')},
                'changed helper input ' + row['path'])
    for row in manifest['excerpts']:
        # LF coordinates only: splitlines() also splits GCC form feeds.
        lines = (roots[row['root']] / row['path']).read_text().split('\n')
        actual = '\n'.join(lines[row['first_LF_line'] - 1:row['last_LF_line']])
        require(actual == row['text'], 'helper excerpt coordinates ' + row['name'])
        require(identity(actual.encode()) == row['identity'],
                'helper excerpt identity ' + row['name'])
        require(all(fragment in actual for fragment in row['operative_fragments']),
                'helper excerpt operative coverage ' + row['name'])
    old = read(REPO / OLD / 'df-backing-source-identity.json')
    require(old['upstream_commit'] == UPSTREAM, 'retained layout source revision')
    with tarfile.open(REPO / OLD / 'df-backing-selected-headers.tar.gz') as archive:
        header = archive.extractfile('insn-modes.h').read()
    expected = next(r for r in old['selected_headers'] if r['path'] == 'insn-modes.h')
    require(identity(header) == {k: expected[k] for k in ('bytes', 'sha256')},
            'selected generated mode header')
    require(b'#define NUM_POLY_INT_COEFFS 1' in header, 'one poly coefficient')
    target_files = [row for row in manifest['files']
                    if row['root'] == 'gcc' and row['path'].startswith('gcc/config/i386/')]
    require(target_files and all('TARGET_ALLOCATE_INITIAL_VALUE' not in
            (roots['gcc'] / row['path']).read_text() for row in target_files),
            'selected i386 initial-value hook has no override')
    return dict(GCC_files=sum(r['root'] == 'gcc' for r in manifest['files']),
                repository_files=sum(r['root'] == 'repository' for r in manifest['files']),
                literal_LF_operative_excerpts=len(manifest['excerpts']),
                retained_generated_headers=1,
                selected_target_files_without_initial_value_override=len(target_files))


def arithmetic(c, n):
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0,
            'selected literal C/N domain')
    k, b, m, u = 99 + 5*c, 2*n + 10, 7*c + 5*n + 20, 7*c + 5*n + 22
    p, r = 2*m + b, 3*k//2 + 1
    # Accepted DF creation owner, not a fresh DF lifetime proof or charge.
    df_creations = 17690*c + 368*n + 19076
    # Two creator opportunities per pseudo, not the global 10C pool bound.
    live_length_sum = 2*(p + 1)
    rows = []

    def row(name, instances, elements, element_bytes, header=0, owner='named helper'):
        rows.append(dict(name=name, simultaneous_instances_upper=instances,
                         elements_upper=elements, element_bytes=element_bytes,
                         each_request_bytes_upper=header + elements*element_bytes,
                         accounting_owner=owner))

    row('IRA equivalence array', 1, r, 40)
    row('temporary IRA equivalence array', 1, k, 32)
    row('common register renumber array', 1, r, 2)
    row('common register preference array', 1, r, 3)
    row('regstat set-reference array', 1, k, 8)
    row('regstat information array', 1, k, 16)
    row('empty IRA scratch pointer reserve', 1, u, 8, 8)
    row('LRA register-info array', 1, r, 144,
        owner='retained core selected_native_backing; same allocation')
    row('LRA block gen-kill records', 1, b, 72)
    row('LRA reverse-postorder array', 1, b, 4)
    row('optional LRA inheritance usage array', 1, k, 24)
    row('LRA assignment integer arrays', 6, k, 4)
    row('LRA assignment thread array', 1, k, 12)
    row('LRA assignment start-point array', 1, p, 8)
    row('persistent LRA elimination table', 1, 4, 48,
        owner='retained target helper; one cold control, no repeated charge')
    row('empty LRA pointer-equivalence hash wrapper', 1, 1, 48)
    row('empty LRA pointer-equivalence hash slots', 1, 13, 8)
    row('LRA constraint pointer reserve', 1, u, 8, 8,
        owner='retained core selected_native_backing; same allocation')
    guards = dict(
        register_growth_signed_tripling=3*k <= I32,
        register_array_length_and_value_counter_signed=r <= I32,
        register_indices_signed=k <= I32,
        block_indices_and_inheritance_epoch_signed=b <= I32,
        UID_narrowing_and_negation_signed=u <= I32,
        empty_scratch_vector_31_bit_capacity=u <= I32,
        point_endpoint_and_loop_successor_signed=p + 1 <= I32,
        regstat_DF_count_narrowing_and_use_plus_set=df_creations <= I32,
        regstat_note_death_increments=600*c <= I32,
        regstat_and_inheritance_call_counters=c <= I32,
        regstat_pre_saturation_frequency=2000 <= I32,
        assignment_live_length_sum_signed=live_length_sum <= I32,
        stored_class_char_and_hard_reg_short=33 <= 127 and 91 <= 32767)
    for item in rows:
        guards['request_PTRDIFF_MAX:' + item['name']] = (
            item['each_request_bytes_upper'] <= PTRDIFF_MAX)
    return dict(
        scope='conditional named outer IRA and selected LRA helper storage',
        counts=dict(C=c, N=n),
        extents=dict(A=4*c, K=k, B=b, M=m, U=u, P=p, R=r),
        individual_requests=rows,
        counters=dict(accepted_DF_reference_creations_upper=df_creations,
                      regstat_sets_and_refs_each_upper=df_creations,
                      regstat_deaths_each_upper=600*c,
                      calls_crossed_each_upper=c,
                      pseudo_calls_crossed=0,
                      frequency_before_saturation_upper=2000,
                      frequency_stored_upper=1000,
                      inheritance_passes_upper=1,
                      inheritance_EBB_epochs_upper=b,
                      inheritance_reload_counter=0,
                      inheritance_call_counter_upper=c,
                      LRA_initial_value_counter_upper=r,
                      LRA_live_ranges_per_pseudo_upper=2,
                      assignment_live_length_sum_upper=live_length_sum),
        selected_schedule=dict(regstat_initializations=1, regstat_recomputations=0,
                               IRA_scratch_records=0, initial_value_hook_invocations=0,
                               LRA_register_array_requests=1,
                               LRA_register_growth_requests=0,
                               LRA_live_range_builds=1, LRA_assignments=1,
                               LRA_inheritance_passes_upper=1,
                               LRA_exception_receiver_worklist_requests=0),
        local_representation_checks=guards,
        conditional_named_helper_storage_capacity=all(guards.values()),
        failed_predicates=[key for key, value in guards.items() if not value],
        new_GGC_events=0, new_scalar_registrations=0, new_array_registrations=0,
        shared_bitmap_or_ET_blocks_recharged=0,
        retained_LRA_register_and_constraint_owners_recharged=False,
        aggregate_ordinary_bytes=None, lifetime_ordinary_request_total=None,
        aggregate_RAM_gate=False,
        all_outer_IRA_interfaces_closed=False,
        all_LRA_ordinary_helpers_closed=False,
        all_LRA_numeric_arithmetic_closed=False,
        complete_all_ordinary_native_capacity=False, complete_native_capacity=False,
        whole_literal_pipeline_capacity_established=False,
        production_admission_changed=False, actual_source_adapter_created=False,
        numeric_packet_consumed=False, independent_review_status='pending',
        source_reachability_argument_is_handwritten=True,
        native_tool_executions=0, predecessor_evaluator_or_checker_executions=0,
        aggregate_or_corpus_replays=0)


def retained_interface_check(adapter=None, pool=None):
    """Fixed Hello reconciliation only. Never executes a predecessor module."""
    adapter = read(REPO / ADAPTER) if adapter is None else adapter
    pool = read(REPO / 'docs/evidence/retained-literal-shared-bitmap-pools-20261019/result.json') if pool is None else pool
    raw = (REPO / 'samples/hello_world.adb').read_bytes()
    require(identity(raw) == adapter['source'] == pool['source'], 'retained source identity')
    require(adapter['source_counts'] == pool['source_counts'], 'retained complete counts')
    c, n = adapter['source_counts']['output_calls'], adapter['source_counts']['null_statements']
    r = arithmetic(c, n)
    x = r['extents']
    shape = adapter['core_result']['RTL_shape']
    require(shape['split_referenced_pseudos_upper'] == x['A'] and
            shape['first_unused_pseudo_number_upper'] == x['K'] and
            shape['block_slots_upper'] == x['B'] and shape['IRA_entry_chain'] == x['M'],
            'retained RTL shape')
    require(all(pool['extents'][key] == x[key] for key in ('K', 'B', 'M', 'U', 'P')),
            'retained shared extents')
    backing = adapter['core_result']['selected_native_backing']
    lra = backing['LRA_register_and_recognition_backing']
    require(lra['register_record_entries_upper'] == x['R'] and
            lra['register_record_request_bytes_upper'] == 144*x['R'] and
            lra['register_record_array_requests'] == 1 and
            lra['last_reg_value_upper'] == x['R'] and
            lra['referenced_pseudo_nrefs_upper'] == 2 and
            lra['constraint_stack_request_bytes_upper'] == 8+8*x['U'] and
            lra['constraint_stack_growth_requests_after_initialization'] == 0,
            'retained LRA ordinary owners')
    df = backing['DF_selected_reference_and_solver_transfer']
    require(df['ref_order_final_upper'] == r['counters']['accepted_DF_reference_creations_upper'] and
            df['selected_REG_DEAD_UNUSED_note_requests_upper'] == 600*c,
            'retained DF reference and note owners')
    require(pool['reg_bitmap_families']['LRA_per_register_instruction_heads_upper'] == x['R'] and
            pool['program_points']['each_assignment_header_array_bytes_upper'] == 32*x['P'] and
            pool['LRA_additional_pools']['live_ranges']['live_objects_upper'] == 10*c and
            pool['LRA_additional_pools']['live_range_copies'] == 0 and
            pool['LRA_additional_pools']['copy_pool_objects'] == 0,
            'retained bitmap and LRA live-pool owners')
    ira = adapter['selected_native_IRA_ordinary_storage']
    require(all(ira['extents'][key] == x[key] for key in ('A', 'K', 'B', 'M', 'U', 'P')),
            'retained accepted IRA owner')
    require(len(adapter['conditions']) == len(adapter['conditional_conditions']) == 305 and
            all(v is True for v in adapter['conditions'].values()) and
            all(v is True for v in adapter['conditional_conditions'].values()),
            'frozen Hello accepted 305 prerequisites')
    ggc = adapter['selected_native_GGC_ledger']
    require(ggc['source'] == adapter['source'] and ggc['source_counts'] == adapter['source_counts'],
            'retained GGC source')
    rows = ggc['owner_rows']
    require(len(rows) == len({item['owner'] for item in rows}) == 50 and
            sum(item['positive_GGC_requests_upper'] for item in rows) ==
            ggc['total_positive_GGC_events_upper'] == adapter['selected_positive_GGC_events_upper'] == 47054,
            'retained fixed Hello GGC partition')
    growth = ggc['new_transfer']['reload_equivalence']
    require(growth['record_bytes'] == 56 and growth['first_capacity_upper'] == 146 and
            growth['second_capacity_upper'] == 292,
            'retained GGC reload-equivalence reserves')
    schedule = read(REPO / OLD / 'literal-rtl-backing-predecessor.json')['source_selected_LRA_passes']
    require(schedule == dict(constraints=2, live_range_construction=1, assignment=1,
                             inheritance_upper=1, undo_upper=1), 'retained LRA schedule')
    return dict(source=adapter['source'], source_counts=adapter['source_counts'],
                accepted_adapter_result_identity=identity((REPO / ADAPTER).read_bytes()),
                accepted_predicates_preserved=305, accepted_GGC_owners_preserved=50,
                fixed_Hello_positive_GGC_events_preserved=47054,
                reload_equivalence_owner=growth,
                LRA_register_record_owner=lra,
                DF_count_owner=dict(ref_order_final_upper=df['ref_order_final_upper'],
                                   selected_note_requests_upper=df['selected_REG_DEAD_UNUSED_note_requests_upper']),
                selected_LRA_schedule=schedule,
                existing_owner_rows_replaced=0, new_GGC_owner_rows=0,
                no_actual_source_adapter_created=True,
                numeric_packet_consumed=False)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--gcc-source', required=True)
    args = parser.parse_args()
    verification = verify_inputs(args.gcc_source)
    result = arithmetic(1, 0)
    result['input_verification'] = verification
    result['retained_interface'] = retained_interface_check()
    print(json.dumps(result, indent=2))

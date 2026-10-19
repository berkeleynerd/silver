#!/usr/bin/env python3
"""Pure selected LRA arithmetic; no native tools or predecessor execution.

Source premises are obligations for an actual-source caller.  The successful
Hello check is a frozen fixture and is not such a caller.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1
GCC = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
ADAPTER = 'docs/evidence/retained-literal-ira-lra-helper-attachment-20261019/result.json'
RECOGNITION = 'docs/evidence/retained-literal-lra-recognition-20261019/result.json'
HEADERS = 'docs/evidence/unbounded-programs/retained-native-expansion-20261017/df-backing-selected-headers.tar.gz'
PREMISES = (
    'accepted_selected_source_configuration_and_schedule',
    'accepted_complete_367_guard_and_owner_join',
    'accepted_recognition_lifetime_and_rounded_counters',
    'accepted_IRA_numeric_DI_primitives_and_assignment',
    'accepted_fixed_generated_target_semantics',
    'selected_default_parameters_without_override',
)
PARAMETERS = dict(inheritance_probability_cutoff=40,
                  considered_reload_pseudos=500, preference_log2=30,
                  operands=30, hard_registers=92, register_classes=34,
                  alternative_bits=64, poly_coefficients=1,
                  register_filters=0, loser_factor=6, maximum_reject=600)


def require(p, message):
    if not p:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def arithmetic(c, n):
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0,
            'selected C>=1 N>=0 integer domain')
    k, b, m = 99+5*c, 2*n+10, 7*c+5*n+20
    u, p, r = m+2, 2*m+b, 3*k//2+1
    imported = dict(register_tripling=3*k <= I32,
                    signed_UID_and_negation=u <= I32,
                    signed_block_and_inheritance_epoch=b <= I32,
                    live_lengths_and_point_successors=2*(p+1) <= I32,
                    note_counter=600*c <= I32,
                    hard_register_usage=10000*c <= I32)
    bounds = dict(frame_offset=16, frame_rounding_pre_mask=31,
                  elimination_offset_values=[0, 16],
                  initial_elimination_difference_values=[1, 17],
                  subsequent_elimination_difference=0,
                  stack_pointer_delta=0, pseudo_value_offset=0,
                  LRA_preference_profit=0, assignment_cost_writer_calls=0,
                  constraint_static_reject=12, constraint_reject_lower=-6,
                  constraint_reject_upper=2060, constraint_losers=6,
                  constraint_scaled_losers=36,
                  constraint_pre_penalty_absolute_score=2108,
                  constraint_post_penalty_absolute_score=3308,
                  constraint_reload_sum=0, constraint_each_nregs_sum=2,
                  constraint_starvation_sum_with_successor=5,
                  alternative_table_index=69, alternative_shift=34,
                  selected_alternative_epoch_increments=7*c,
                  selected_small_class_epoch_consumers=0,
                  inheritance_cutoff_product=400000,
                  inheritance_cutoff=4000,
                  preference_shift=1 << 30,
                  preference_denominator_upper=p+1,
                  selected_new_pseudo_interval=0,
                  fixed_automatic_object_bytes=900,
                  dynamic_automatic_request_bytes=16,
                  recursive_pattern_nodes=3,
                  constrain_operands_invocations_nested=2)
    local = dict(
        signed_elimination_initial_difference=17 <= I64,
        signed_frame_rounding_before_mask=31 <= I64,
        signed_constraint_reject=-I32 <= -6 <= 2060 <= I32,
        signed_constraint_product_before_comparison=36 <= I32,
        signed_constraint_score_before_comparison=3308 <= I32,
        signed_constraint_width_sums=5 <= I32,
        signed_frequency_comparator=2000 <= I32,
        signed_pseudo_ID_comparator=k-1 <= I32,
        signed_iteration_counters=2 <= I32,
        signed_alternative_flat_index=69 <= I32,
        alternative_mask_shift=0 <= 34 < 64,
        alternative_signed_char=35 <= 127,
        operand_array_indices=2 <= PARAMETERS['operands'],
        argument_array_indices=3 <= PARAMETERS['hard_registers'],
        fixed_automatic_object_PTRDIFF=900 <= I64,
        dynamic_automatic_product_PTRDIFF=2*8 <= I64,
        inheritance_cutoff_product_before_division=400000 <= I32,
        preference_shift_width=0 <= 30 < 32,
        preference_denominator_positive_signed=1 <= p+1 <= I32,
        no_selected_register_filter_shift=PARAMETERS['register_filters'] == 0,
        unsigned_epoch_wrap_has_no_selected_consumer=True,
    )
    return dict(counts=dict(C=c, N=n), extents=dict(K=k,B=b,M=m,U=u,P=p,R=r),
                bounds=bounds, imported_checks=imported, local_checks=local,
                failed_predicates=[name for group in (imported, local)
                                   for name, value in group.items() if not value],
                conditional_arithmetic_pass=all(imported.values()) and all(local.values()),
                new_count_restrictions=0, new_allocation_owners=0,
                new_GGC_events=0, new_finalizer_registrations=0,
                pool_and_bitmap_recharges=0,
                lifetime_ordinary_allocations=None, aggregate_RAM_gate=False,
                all_LRA_capacity=False, complete_native_capacity=False,
                whole_pipeline_capacity=False, actual_source_adapter=False,
                physical_stack_capacity_established=False,
                generated_source_binary_correspondence_established=False)


def apply(c, n, premises):
    require(type(premises) is dict and set(premises) == set(PREMISES),
            'exact named source premises required')
    require(all(v is True or v is False or v is None for v in premises.values()),
            'premises must be true, false or unknown')
    a = arithmetic(c, n)
    missing = [k for k, v in premises.items() if v is not True]
    computed = not missing and a['conditional_arithmetic_pass']
    return dict(counts=a['counts'], source_premises=copy.deepcopy(premises),
                representation_checks=dict(**a['imported_checks'], **a['local_checks']),
                missing_source_premises=missing, failed_predicates=a['failed_predicates'],
                computed=computed, derived=a['bounds'] if computed else None,
                selected_LRA_named_arithmetic_and_automatic_storage=computed,
                all_LRA_capacity=False, complete_native_capacity=False,
                whole_pipeline_capacity=False, actual_source_adapter=False)


def verify_inputs(gcc_source, manifest=None):
    m = read(HERE/'inputs.json') if manifest is None else manifest
    require(m['GCC_revision'] == GCC, 'GCC revision')
    roots = dict(gcc=Path(gcc_source), repository=REPO)
    for row in m['files']:
        raw = (roots[row['root']]/row['path']).read_bytes()
        require(identity(raw) == row['identity'], 'input pin: '+row['path'])
    for row in m['excerpts']:
        raw = (roots[row['root']]/row['path']).read_bytes()
        lines = raw.decode().split('\n')
        excerpt = '\n'.join(lines[row['first_LF_line']-1:row['last_LF_line']])
        require(excerpt == row['text'], 'literal LF excerpt: '+row['name'])
        require(identity(excerpt.encode()) == row['identity'], 'excerpt hash: '+row['name'])
        require(all(t in excerpt for t in row['operative_fragments']),
                'operative fragments: '+row['name'])
    with tarfile.open(REPO/HEADERS) as archive:
        for row in m['generated_headers']:
            raw = archive.extractfile(row['path']).read()
            require(identity(raw) == row['identity'], 'generated header '+row['path'])
            require(all(t.encode() in raw for t in row['operative_fragments']),
                    'generated constants '+row['path'])
    require(m['fixed_parameters'] == PARAMETERS, 'fixed parameter record')
    # Concrete generic source scope, not generated compiler output.
    for name in ('lra.cc','lra-constraints.cc','lra-eliminations.cc',
                 'lra-lives.cc','lra-assigns.cc'):
        source = (roots['gcc']/'gcc'/name).read_text()
        require('XALLOCAVEC (' not in source and 'alloca (' not in source,
                'no dynamic LRA automatic request: '+name)
    return dict(GCC_files=sum(r['root']=='gcc' for r in m['files']),
                repository_files=sum(r['root']=='repository' for r in m['files']),
                literal_LF_excerpts=len(m['excerpts']),
                retained_generated_headers=len(m['generated_headers']))


def fixed_hello(adapter=None, recognition=None):
    a = read(REPO/ADAPTER) if adapter is None else adapter
    r = read(REPO/RECOGNITION) if recognition is None else recognition
    f = r['accepted_fixture']
    require(a['source'] == f['source'] == identity((REPO/'samples/hello_world.adb').read_bytes()),
            'complete fixed source identity')
    require(a['source_counts'] == f['source_counts'], 'complete fixed source counts')
    require(a['source_counts']['output_calls'] == 1 and
            a['source_counts']['null_statements'] == 0, 'fixed Hello counts')
    owner = a['core_result']['selected_native_backing']['LRA_register_and_recognition_backing']
    require(owner == f['complete_owner'], 'complete existing recognition owner')
    for key in ('conditions', 'conditional_conditions'):
        require(len(a[key]) == 367 and all(v is True for v in a[key].values()),
                'complete successful 367-key fixture map: '+key)
    require(r['complete_dynamic_recognition_lifetime_conditional'] is True and
            r['arithmetic']['computed'] is True, 'accepted recognition result')
    require(a['launch']['native_options'] ==
            ['-gnatx','-Wno-free-nonheap-object','-fsplit-wide-types'],
            'complete selected native options')
    require(a['selected_named_IRA_numeric_arithmetic_established'] is True and
            a['selected_named_IRA_LRA_helper_storage_established'] is True,
            'accepted arithmetic and helper prerequisites')
    return dict(source=copy.deepcopy(a['source']), source_counts=copy.deepcopy(a['source_counts']),
                complete_existing_owner=copy.deepcopy(owner), unchanged_guard_count=367,
                applied=apply(1,0,dict.fromkeys(PREMISES, True)),
                fixed_fixture_only=True, general_actual_source_join=False)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--gcc-source', required=True)
    args = parser.parse_args()
    out = dict(scope='Conditional named selected LRA arithmetic/automatic-storage residual',
               arithmetic=arithmetic(1,0), accepted_fixture=fixed_hello(),
               input_verification=verify_inputs(args.gcc_source),
               independent_review_status='pending', new_allocation_owners=0,
               whole_pipeline_capacity=False, complete_native_capacity=False)
    (HERE/'result.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps(out['input_verification']))


if __name__ == '__main__':
    main()

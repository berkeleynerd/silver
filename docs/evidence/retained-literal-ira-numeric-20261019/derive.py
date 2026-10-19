#!/usr/bin/env python3
"""Selected literal IRA numeric bounds. No native or predecessor execution."""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
I32,I64=2**31-1,2**63-1
FREQ=1000
HARD_REGS,CLASSES,GROUP_INSNS,GROUP_PSEUDOS=92,34,7,4
MOVE_MAX,MEM_MAX,INIT_COST=65535,100,1000000


def require(value,message):
    if not value:raise ValueError(message)


def read(path):return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


def verify_inputs(gcc_root,pins=None):
    pins=read(HERE/'inputs.json') if pins is None else pins
    roots=dict(gcc=Path(gcc_root),repository=REPO)
    for r in pins['files']:
        raw=(roots[r['root']]/r['path']).read_bytes()
        require(identity(raw)=={k:r[k] for k in ('bytes','sha256')},
                'changed IRA numeric input '+r['path'])
    for r in pins['excerpts']:
        # Literal LF coordinates, deliberately not str.splitlines(): GCC
        # sources include form feeds which must not shift source line numbers.
        lines=(roots[r['root']]/r['path']).read_text().split('\n')
        actual='\n'.join(lines[r['first_line']-1:r['last_line']])+'\n'
        require(actual==r['text'],'changed IRA numeric LF excerpt '+r['name'])
        require(all(s in actual for s in r['operative_fragments']),
                'missing IRA numeric operative fragment '+r['name'])
    return dict(GCC_files=sum(r['root']=='gcc' for r in pins['files']),
        repository_files=sum(r['root']=='repository' for r in pins['files']),
        LF_coordinate_and_operative_excerpt_checks=len(pins['excerpts']))


def arithmetic(c,n):
    require(type(c) is int and c>=1 and type(n) is int and n>=0,'literal C/N domain')
    a,k,b,m=4*c,99+5*c,2*n+10,7*c+5*n+20
    p=2*m+b
    # Only the two-input/output movdi pattern reaches pseudo cost recording.
    # No tied, commutative or OP_INOUT operand; one SYMBOL_REF other operand
    # can need copy_cost <= MEM_MAX and each of two constraints adds <= 2.
    penalty=4
    alternative=MEM_MAX+penalty
    op_add=alternative*FREQ
    class_candidate=MOVE_MAX*FREQ+op_add
    memory_candidate=MEM_MAX*FREQ+op_add
    ref_cost_upper=max(INIT_COST,MOVE_MAX*FREQ)
    class_low,class_high=-2*FREQ,2*ref_cost_upper
    memory_high=2*max(INIT_COST,MEM_MAX*FREQ)
    pref_diff=class_high-class_low
    diff_low,diff_high=-class_high,memory_high-class_low
    priority_low,priority_high=2*diff_low,2*diff_high
    # Each hard-death pass clears a bit before another reference can cause
    # another decrement.  Include both ordinary definitions and MUST_CLOBBER
    # scans, then all four group-pseudo deaths and one direct own-range update.
    decrements_per_insn=2*HARD_REGS+GROUP_PSEUDOS
    update_calls=GROUP_INSNS*(decrements_per_insn+1)
    local_points=2*GROUP_INSNS+1
    excess=update_calls*CLASSES*local_points
    aggregate_abs=a*max(-class_low,class_high)
    inherited=dict(allocno_ID_count_signed=a<=I32,
                   point_endpoint_successor_signed=p+1<=I32)
    guards=dict(
        frequency_rescale_product_signed=10000*FREQ<=I32,
        per_allocno_reference_count_signed=2<=I32,
        per_allocno_frequency_signed=2*FREQ<=I32,
        DI_memory_table_signed_short=0<MEM_MAX<=2**15-1,
        DI_register_table_unsigned_short=0<MOVE_MAX<=2**16-1,
        DI_non_sentinel_target_matrix_arithmetic=4*MEM_MAX<=2**16-1,
        selected_alternative_reject_sum_signed=24<=I32,
        selected_alternative_bit_index=28<=64,
        nonpseudo_copy_and_penalty_signed=alternative<=I32,
        alternative_frequency_product_signed=op_add<=I32,
        class_candidate_before_MIN_signed=class_candidate<=I32,
        memory_candidate_before_MIN_signed=memory_candidate<=I32,
        direct_hard_move_product_signed=MOVE_MAX*FREQ<=I32,
        two_reference_class_sum_signed=-I32<=class_low<=class_high<=I32,
        two_reference_memory_sum_signed=memory_high<=I32,
        preferred_difference_before_division_signed=pref_diff<=I32,
        preference_denominator_strictly_positive=2>0,
        preference_stored_frequency_signed=pref_diff//2<=I32,
        pressure_live_count_signed=HARD_REGS+GROUP_PSEUDOS<=I32,
        pressure_single_summand_signed=local_points<=I32,
        excess_pressure_accumulation_signed=excess<=I32,
        priority_difference_before_checked_multiply_signed=
            -I32<=diff_low<=diff_high<=I32,
        priority_first_product_without_saturation_signed=
            -I32<=priority_low<=priority_high<=I32,
        priority_normalization_product_signed=True,
        priority_sort_boolean_difference_signed=True,
        priority_sort_allocno_ID_difference_signed=a-1<=I32,
        aggregate_cost_sums_signed64=aggregate_abs<=I64)
    # The True normalization facts are algebraic claims, not observations:
    # |q|<=Q and mult=floor(INT_MAX/Q), or all q=0 and mult=1.
    combined={**inherited,**guards}
    return dict(scope='Selected IRA numeric cost/frequency/equivalence/preference, pressure and fast-priority arithmetic; outer helper capacity and LRA arithmetic remain separate',
        source_counts=dict(output_calls=c,null_statements=n),
        extents=dict(A=a,K=k,B=b,M=m,P=p),
        constants=dict(IRA_frequency_upper=FREQ,LRA_frequency_unit_separate=10000,
            group_instructions_upper=GROUP_INSNS,group_pseudos_upper=GROUP_PSEUDOS,
            hard_registers=HARD_REGS,register_classes=CLASSES,DI_memory_move_upper=MEM_MAX,
            DI_register_move_upper=MOVE_MAX,initial_operand_cost=INIT_COST),
        cost_bounds=dict(references_per_allocno_upper=2,frequency_sum_upper=2*FREQ,
            raw_alternative_cost_upper=alternative,alternative_frequency_product_upper=op_add,
            generic_class_candidate_before_MIN_upper=class_candidate,
            generic_memory_candidate_before_MIN_upper=memory_candidate,
            generic_stored_operand_cost_interval=[0,INIT_COST],
            direct_hard_move_class_interval=[-FREQ,MOVE_MAX*FREQ],
            accumulated_class_interval=[class_low,class_high],
            accumulated_memory_interval=[0,memory_high],
            equivalence_gains=0,call_frequency_and_crossings=0,
            preference_difference_absolute_upper=pref_diff,
            preference_divisor_lower=2,preference_frequency_upper=pref_diff//2,
            preference_updates_of_existing_record=0),
        pressure=dict(live_count_per_class_upper=HARD_REGS+GROUP_PSEUDOS,
            hard_death_scans_per_instruction_upper=2,
            decrements_per_instruction_upper=decrements_per_insn,
            update_calls_per_allocno_upper=update_calls,
            classes_per_update_upper=CLASSES,summand_upper=local_points,
            excess_pressure_per_allocno_upper=excess,
            high_pressure_may_predate_group=True,
            cross_class_repeated_overlaps_included=True,
            zero_excess_pressure_claim=False),
        priority=dict(reference_log_multiplier_upper=2,DI_nregs=1,
            difference_interval=[diff_low,diff_high],
            first_product_interval=[priority_low,priority_high],
            first_product_overflow_branch_needed=False,
            final_normalization_absolute_upper=I32,
            normalization_rule='Q=max(abs(q)); t=1 if Q=0 else INT_MAX//Q; abs(q*t)<=INT_MAX',
            length_divisor_interval=[1,max(1,excess)],
            signed_INT_MIN_never_negated=True,comparison_uses_SORTGT=True,
            ID_difference_absolute_upper=max(0,a-1)),
        aggregate=dict(cost_terms_upper=a,each_cost_absolute_upper=max(-class_low,class_high),
            signed64_sum_absolute_upper=aggregate_abs,memory_cost_total=0,
            load_store_shuffle_costs=0,move_loops_and_additional_jumps=0),
        inherited_representation_checks=inherited,local_numeric_checks=guards,
        conditional_selected_IRA_numeric_arithmetic=all(combined.values()),
        failed_predicates=[name for name,value in combined.items() if not value],
        separate_LRA_signed_usage_guard=10000*c<=I32,
        previous_storage_owners_modified=False,new_GGC_events=0,
        new_scalar_registrations=0,new_array_registrations=0,
        new_shared_bitmap_or_ET_blocks=0,aggregate_RAM_gate=False,
        outer_IRA_helper_capacity_closed=False,remaining_LRA_arithmetic_closed=False,
        all_ordinary_native_capacity=False,complete_native_capacity=False,
        whole_literal_pipeline_capacity_established=False,production_admission_changed=False,
        source_reachability_argument_is_handwritten=True,actual_source_adapter_created=False,
        independent_review_status='pending',native_tool_executions=0,
        predecessor_evaluator_or_checker_executions=0,aggregate_or_corpus_replays=0)


def retained_interface():
    base=REPO/'docs/evidence'
    old=read(base/'retained-literal-ira-lra-ordinary-20261019/result.json')
    ledger=read(base/'retained-literal-native-ggc-ledger-20261019/result.json')
    raw=(REPO/'samples/hello_world.adb').read_bytes()
    require(identity(raw)==old['retained_interface']['source']==ledger['source'],
            'retained IRA numeric source identity')
    counts=old['retained_interface']['source_counts']
    require(counts==ledger['source_counts'],'retained IRA numeric complete counts')
    r=arithmetic(counts['output_calls'],counts['null_statements'])
    require(all(r['extents'][k]==old['extents'][k] for k in r['extents']),
            'retained IRA storage extents')
    require(old['conditional_named_IRA_allocation_capacity'] is True,
            'accepted fixed-Hello local storage prerequisites')
    require(r['separate_LRA_signed_usage_guard']==ledger['local_representation_checks']
            ['LRA_signed_hard_register_frequency'],'separate retained LRA signed usage')
    return dict(source=identity(raw),source_counts=counts,
        frozen_GGC_total_preserved=ledger['total_positive_GGC_events_upper'],
        older_storage_result_preserved=True,predecessor_modules_executed=False)


if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--gcc-source',required=True)
    args=ap.parse_args();r=arithmetic(1,0)
    r['input_verification']=verify_inputs(args.gcc_source)
    r['retained_interface']=retained_interface()
    print(json.dumps(r,indent=2))

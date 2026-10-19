#!/usr/bin/env python3
"""Focused arithmetic, operand-source, LF coordinate and retained-owner checks."""
import argparse
from datetime import datetime,timezone
import importlib.util
import json
from pathlib import Path
import platform
import re
import time

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('ira_numeric',HERE/'derive.py')
d=importlib.util.module_from_spec(spec);spec.loader.exec_module(d)


def truncdiv(n,den):return (abs(n)//den)*(1 if n>=0 else -1)


def main():
    ap=argparse.ArgumentParser();ap.add_argument('--gcc-source',required=True)
    args=ap.parse_args();start=datetime.now(timezone.utc).isoformat();tick=time.perf_counter()
    checks=[]
    def check(name,value):
        if not value:raise AssertionError(name)
        checks.append(name)
    def rejects(name,call,reason):
        try:call()
        except ValueError as ex:check(name,reason in str(ex))
        else:raise AssertionError('did not reject '+name)

    verification=d.verify_inputs(args.gcc_source)
    result=d.arithmetic(1,0);result['input_verification']=verification
    result['retained_interface']=d.retained_interface()
    check('Hello local and inherited numeric guards',result['conditional_selected_IRA_numeric_arithmetic'])
    check('Hello frozen GGC owner',result['retained_interface']['frozen_GGC_total_preserved']==47054)
    check('IRA and LRA frequency units distinct',result['constants']['IRA_frequency_upper']==1000 and
          result['constants']['LRA_frequency_unit_separate']==10000)
    check('class interval',result['cost_bounds']['accumulated_class_interval']==[-2000,131070000])
    check('memory interval',result['cost_bounds']['accumulated_memory_interval']==[0,2000000])
    check('raw candidate computed before MIN',result['cost_bounds']
          ['generic_class_candidate_before_MIN_upper']==65639000)
    check('preference numerator',result['cost_bounds']['preference_difference_absolute_upper']==131072000)
    check('pressure update envelope',result['pressure']['excess_pressure_per_allocno_upper']==674730)
    check('first priority product',result['priority']['first_product_interval']==[-262140000,4004000])
    check('Hello aggregate cost envelope',result['aggregate']['signed64_sum_absolute_upper']==524280000)
    for key in ('previous_storage_owners_modified','aggregate_RAM_gate',
                'outer_IRA_helper_capacity_closed','remaining_LRA_arithmetic_closed',
                'all_ordinary_native_capacity','complete_native_capacity',
                'whole_literal_pipeline_capacity_established','production_admission_changed',
                'actual_source_adapter_created'):
        check('scope remains bounded '+key,result[key] is False)
    check('no zero-pressure assumption',result['pressure']['zero_excess_pressure_claim'] is False)
    for key in ('new_GGC_events','new_scalar_registrations','new_array_registrations',
                'new_shared_bitmap_or_ET_blocks'):
        check('no recharged owner '+key,result[key]==0)

    # Extract the actual two constraint strings, including ignored/disabled
    # alternatives. This checks the fixed syntax budget, not target reachability.
    md=(Path(args.gcc_source)/'gcc/config/i386/i386.md').read_text()
    block=md[md.index('(define_insn "*movdi_internal"'):]
    constraints=re.findall(r'\(match_operand:DI ([01]) "[^"]+"\s*"([^"]+)"',block[:650])
    check('two movdi operand constraints extracted',len(constraints)==2 and [x[0] for x in constraints]==['0','1'])
    alternatives=[s.split(',') for _,s in constraints]
    check('28 fixed alternatives',all(len(x)==28 for x in alternatives))
    check('no tied commutative inout or extra penalty syntax',
          all(not any(c in s for c in '0123456789%+&!^') for _,s in constraints))
    check('two question marks per alternative at most',
          max(sum(s[i].count('?') for s in alternatives) for i in range(28))<=2)
    check('IRA setup alternatives reject upper 24',
          max(6*sum(s[i].count('?') for s in alternatives)+2*6 for i in range(28))<=24)

    # Full legal IRA frequency range, source field endpoints, and evaluation
    # before the MIN operation.  No saturating accumulator is assumed to fix
    # an overflowing candidate product.
    candidate_cases=0
    for f in range(1,1001):
        for move in (0,2,65535):
            for alt in (0,4,100,104):
                raw=move*f+alt*f
                if not 0<=raw<=65639000<=d.I32:raise AssertionError('raw class candidate')
                if not 0<=min(1000000,raw)<=1000000:raise AssertionError('MIN stored bound')
                candidate_cases+=1
        for memory in (6,100):
            for allowed in (0,1):
                for alt in (0,104):
                    raw=(memory-allowed)*f+alt*f
                    if not 0<=raw<=204000:raise AssertionError('raw memory candidate')
                    candidate_cases+=1
        if not -1000<=-f<=65535*f<=65535000:raise AssertionError('hard move cost range')
    check('all 1000 frequencies and candidate corners',True)
    # Every two-reference combination in the conservative reference interval.
    for x in (-1000,0,1000000,65535000):
        for y in (-1000,0,1000000,65535000):
            check('two-reference addition '+str((x,y)),-2000<=x+y<=131070000 and -d.I32<=x+y<=d.I32)
    for x in (-2000,0,131070000):
        for y in (-2000,0,131070000):
            z=x-y
            check('preference subtraction before division '+str((x,y)),abs(z)<=131072000<d.I32)
            check('positive preference division '+str((x,y)),0<=max(0,truncdiv(z,2))<=65536000)

    # Duplicate hard-register references cannot repeat a decrement within one
    # scan: the first visit clears the live bit. Refill for MUST_CLOBBER scan.
    hard_deaths=0
    for stage in range(2):
        live=set(range(92))
        for reg in list(range(92))*3:
            if reg in live:
                hard_deaths+=1;live.remove(reg)
    check('both hard-death scans count every register',hard_deaths==184)
    calls=7*(hard_deaths+4+1)
    check('all group update opportunities',calls==1323)
    pressure_samples=[]
    for group_start in (0,1000,d.I32-16):
        for high_start in (0,group_start,group_start+7):
            current=group_start+14;total=0
            for update in range(calls):
                for cl in range(34):
                    # Repeat overlapping intervals deliberately; no reset or
                    # disjointness assumption enters this upper-bound test.
                    total+=current-max(high_start,group_start)+1
                    if not 0<=total<=674730:raise AssertionError('pressure accumulator')
            pressure_samples.append(dict(group_start=group_start,high_start=high_start,total=total))
    check('pressure local clipping near signed endpoint',True)
    check('live pressure each class at most 96',92+4==96<d.I32)

    # Validate normalization with C++-style truncation on negative quotients.
    normalization_cases=0
    for maximum in list(range(4097))+[4004000,262140000,d.I32-1,d.I32]:
        mult=1 if maximum==0 else d.I32//maximum
        for q in sorted(set([-maximum,-maximum+1 if maximum else 0,0,
                             maximum-1 if maximum else 0,maximum])):
            for length in (1,2,674730):
                product=q*mult
                if not -d.I32<=product<=d.I32:raise AssertionError('priority normalization product')
                value=truncdiv(product,length)
                if not -d.I32<=value<=d.I32:raise AssertionError('priority divisor')
                normalization_cases+=1
    check('normalization product checked before division',True)
    for memory in (0,2000000):
        for cost in (-2000,131070000):
            difference=memory-cost
            check('priority initial product '+str((memory,cost)),
                  -131070000<=difference<=2002000 and
                  -262140000<=2*difference<=4004000)

    aggregate_c=d.I64//524280000
    point_n=(d.I32-65)//12
    id_c=d.I32//4
    cases=[(1,0),(1,1),(7,64),(1000,1000),(d.I32//10000,0),
           (d.I32//10000+1,0),(id_c,0),(id_c+1,0),
           (1,point_n),(1,point_n+1),(aggregate_c,0),(aggregate_c+1,0),(d.I64,d.I64)]
    case_rows=[]
    for c,n in cases:
        r=d.arithmetic(c,n);all_checks={**r['inherited_representation_checks'],**r['local_numeric_checks']}
        check('numeric conjunction '+str((c,n)),
              r['conditional_selected_IRA_numeric_arithmetic']==all(all_checks.values()) and
              r['failed_predicates']==[key for key,v in all_checks.items() if not v])
        check('per-allocno bound independent of C/N '+str((c,n)),
              r['cost_bounds']==result['cost_bounds'] and r['pressure']==result['pressure'])
        case_rows.append(dict(C=c,N=n,numeric_fits=r['conditional_selected_IRA_numeric_arithmetic'],
                              failed=r['failed_predicates'],LRA_guard=r['separate_LRA_signed_usage_guard']))
    for c,expected in ((aggregate_c,True),(aggregate_c+1,False)):
        check('signed64 aggregate exact boundary '+str(c),d.arithmetic(c,0)['local_numeric_checks']
              ['aggregate_cost_sums_signed64']==expected)
    check('LRA next-boundary failure distinct from new numeric guard',
          d.arithmetic(d.I32//10000+1,0)['conditional_selected_IRA_numeric_arithmetic'] and
          not d.arithmetic(d.I32//10000+1,0)['separate_LRA_signed_usage_guard'])
    check('ID subtraction endpoint',abs(0-(d.I32-1))<=d.I32)
    for c,n in ((0,0),(True,0),(1,-1),(1,False),(1.0,0)):
        rejects('invalid counts '+str((c,n)),lambda c=c,n=n:d.arithmetic(c,n),'literal C/N domain')
    pins=d.read(HERE/'inputs.json');pins['files'][0]['sha256']='0'*64
    rejects('source byte mutation',lambda:d.verify_inputs(args.gcc_source,pins),'changed IRA numeric input')
    pins=d.read(HERE/'inputs.json');pins['excerpts'][0]['first_line']+=1
    rejects('LF coordinate mutation',lambda:d.verify_inputs(args.gcc_source,pins),'changed IRA numeric LF excerpt')
    pins=d.read(HERE/'inputs.json');pins['excerpts'][0]['operative_fragments']=['not an operative fragment']
    rejects('operative fragment mutation',lambda:d.verify_inputs(args.gcc_source,pins),'missing IRA numeric operative fragment')
    summary=dict(scope='Focused new IRA numeric bounds and source-interface checks',
        checks_passed=len(checks),check_names=checks,frequency_values_checked=1000,
        candidate_corner_cases=candidate_cases,priority_normalization_cases=normalization_cases,
        pressure_adversarial_samples=pressure_samples,count_cases=case_rows,
        extracted_movdi_constraints=constraints,input_verification=verification,
        started_UTC=start,finished_UTC=datetime.now(timezone.utc).isoformat(),
        checker_wall_seconds=time.perf_counter()-tick,
        host=dict(system=platform.system(),release=platform.release(),machine=platform.machine()),
        native_tool_executions=0,predecessor_evaluator_or_checker_executions=0,
        aggregate_or_corpus_replays=0,source_reachability_argument_is_handwritten=True,
        independent_review_status='pending')
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    (HERE/'check-results.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({key:summary[key] for key in ('checks_passed','checker_wall_seconds','input_verification','host')}))


if __name__=='__main__':main()

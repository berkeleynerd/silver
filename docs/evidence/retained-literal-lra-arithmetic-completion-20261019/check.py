#!/usr/bin/env python3
"""Focused arithmetic/source-interface checks, not a C++ proof or tool run."""
import argparse
import copy
import json
import platform
import re
import time
from pathlib import Path
import derive as d


def main():
    parser=argparse.ArgumentParser(); parser.add_argument('--gcc-source',required=True)
    source=Path(parser.parse_args().gcc_source)
    start=time.monotonic(); checks=[]
    def check(name, value):
        if not value: raise AssertionError(name)
        checks.append(name)
    def rejects(name, call):
        try: call()
        except (ValueError, KeyError): checks.append(name)
        else: raise AssertionError('did not reject '+name)

    verification=d.verify_inputs(source)
    check('input pins and literal LF text/operative correspondence', bool(verification))
    fixture=d.fixed_hello()
    check('complete frozen owner and 367-key maps', fixture['unchanged_guard_count']==367)
    check('Hello is a fixture, never a general source join',
          fixture['fixed_fixture_only'] and not fixture['general_actual_source_join'])
    for c,n in [(1,0),(1,1),(5000,0),(5000,5000),(214748,0),
                (214749,0),(143165556,0),(143165557,0),(1,89478479),
                (1,89478480),(1,2**31),(2**100,2**100)]:
        a=d.arithmetic(c,n)
        check(f'exact natural extents {c}/{n}', a['extents']['P']==14*c+12*n+50)
        check(f'local score independent of counts {c}/{n}',
              a['bounds']['constraint_post_penalty_absolute_score']==3308)
        check(f'no allocation or full-capacity assertion {c}/{n}',
              a['new_allocation_owners']==a['new_GGC_events']==a['pool_and_bitmap_recharges']==0
              and not a['all_LRA_capacity'] and not a['complete_native_capacity']
              and not a['physical_stack_capacity_established'])
    check('5000-call inherited/local arithmetic passes',d.arithmetic(5000,0)['conditional_arithmetic_pass'])
    check('hard usage boundary passes',d.arithmetic(214748,0)['imported_checks']['hard_register_usage'])
    check('hard usage first failure retained',not d.arithmetic(214749,0)['imported_checks']['hard_register_usage'])
    check('register-tripling boundary passes',d.arithmetic(143165556,0)['imported_checks']['register_tripling'])
    check('register-tripling first failure retained',not d.arithmetic(143165557,0)['imported_checks']['register_tripling'])
    nlast=((2**31-1)-130)//24
    check('point exact last-safe boundary',d.arithmetic(1,nlast)['imported_checks']['live_lengths_and_point_successors'])
    check('point exact first-failure boundary',not d.arithmetic(1,nlast+1)['imported_checks']['live_lengths_and_point_successors'])
    for c,n in [(True,0),(1,False),(0,0),(1,-1),(1.0,0),('1',0),(1,None)]:
        rejects(f'invalid count domain {c!r}/{n!r}', lambda c=c,n=n:d.arithmetic(c,n))

    premises=dict.fromkeys(d.PREMISES,True)
    check('all explicit source premises permit conditional result',d.apply(1,0,premises)['computed'])
    for name in d.PREMISES:
        for missing in (False,None):
            p={**premises,name:missing};r=d.apply(1,0,p)
            check(f'preserve {name}={missing}',not r['computed'] and r['derived'] is None
                  and r['source_premises'][name] is missing)
    for value in (1,'true',[],{}):
        rejects('no truthiness coercion '+repr(value),
                lambda value=value:d.apply(1,0,{**premises,d.PREMISES[0]:value}))
    rejects('missing source key',lambda:d.apply(1,0,{}))
    check('failed inherited arithmetic leaves null result',d.apply(214749,0,premises)['derived'] is None)

    # Sentinel subtraction, including the first update that differs from steady state.
    offsets=[16,16,0,0]; previous=[-1]*4
    first=[x-y for x,y in zip(offsets,previous)]
    check('all first offset differences include sentinel',first==[17,17,1,1])
    check('stable frame second update differences zero',all(x-y==0 for x,y in zip(offsets,offsets)))
    check('round-up addition evaluated before mask',((16+16-1)&-16)==16 and 16+16-1==31)
    for entry in (0,1,2**61-1):
        for values in ([0,0,0],[0,0,1],[entry,entry]):
            total=0
            for count in values:
                total+=count
                if total>0: break
            check(f'zero-threshold profile sum stops {entry}/{values}',total<=max(values))

    # Rejection site sum deliberately includes mutually exclusive branches.
    positive_sites=[3,1,1,1,2,2,1,1,3,600,2,3,3,2,3,1,6,1]
    check('source per-operand rejection sum below 1024',sum(positive_sites)<1024)
    score_cases=0
    for losers in range(7):
        for reject in (-6,0,2060):
            for static in (0,12):
                for cycle in (0,600):
                    for starvation in (0,600):
                        subtotal=losers*6+reject-static
                        final=subtotal+cycle+starvation
                        assert abs(subtotal)<=2108 and abs(final)<=3308
                        score_cases+=1
    check('all independent score corners fit before comparison',score_cases==168)

    md=(source/'gcc/config/i386/i386.md').read_text().split('\n')
    dest=re.search(r'"([^"]+)"','\n'.join(md[2595:2596])).group(1).split(',')
    inp=re.search(r'"([^"]+)"','\n'.join(md[2597:2598])).group(1).split(',')
    check('28 complete movdi alternatives',len(dest)==len(inp)==28)
    check('no matching early-clobber commutative dollar/caret syntax',
          not any(c in ''.join(dest+inp) for c in '0123456789&%+$^!'))
    check('each static rejection at most one question mark',max(s.count('?') for s in dest+inp)==1)
    check('candidate alternative constraints 2/3/4',
          [s.strip() for s in dest[2:5]]==['r','r','r'] and
          [s.strip() for s in inp[2:5]]==['Z','rem','i'])
    check('32-bit first alternatives explicitly disabled for 64-bit',
          '(eq_attr "alternative" "0,1,17,18")\n\t      (const_string "nox64")' in '\n'.join(md))
    check('call has LP64 r constraint substitution','(define_mode_attr c [(SI "l") (DI "r")])' in '\n'.join(md))
    # The selected consumer is false for NO_REGS and GENERAL_REGS, including
    # an arbitrary incoming marker.  The route proof, not this model, supplies it.
    for old in (0,1,d.U32-1,d.U32):
        marker=old
        cache={0:[123,99],1:[old,2]}
        saved=copy.deepcopy(cache)
        for small,size in [(False,9),(False,0),(False,9)]:
            marker=(marker+1)&d.U32
            if size and small: raise AssertionError('selected consumer unexpectedly active')
        check(f'unsigned marker boundary has no selected cache effect {old}',cache==saved)
    for point in (0,1,(1<<30)-1,1<<30,(1<<31)-2):
        denom=point+1; quotient=(1<<30)//denom
        check(f'preference division positive including zero quotient {point}',
              denom>0 and (0>=quotient)==(quotient==0))
    objects=[900,31,31]+[30*s for s in (4,4,16,16,1,1,1,4,4,8,8,4,4,1)]+[92*4,16,30*8,30*4,30*4,30*8]
    check('every actual automatic object within 900 bytes',max(objects)==900)
    check('largest actual flat alternative slot',max(a*2+o for a in range(35) for o in range(2))==69)
    check('matching matrix initial writes in bounds',all(0<=i<30 for i in (0,1)) and 0<30)

    manifest=d.read(d.HERE/'inputs.json')
    for field in d.PARAMETERS:
        m=copy.deepcopy(manifest);m['fixed_parameters'][field]+=1
        rejects('fixed parameter/source mutation '+field,lambda m=m:d.verify_inputs(source,m))
    for mutation in ('hash','LF','operative','generated'):
        m=copy.deepcopy(manifest)
        if mutation=='hash':m['files'][0]['identity']['sha256']='0'*64
        elif mutation=='LF':m['excerpts'][0]['first_LF_line']+=1
        elif mutation=='operative':m['excerpts'][0]['operative_fragments'].append('MISSING_OPERATIVE_TERM')
        else:m['generated_headers'][0]['operative_fragments'].append('#define MAX_RECOG_OPERANDS 31')
        rejects('reject '+mutation+' source mismatch',lambda m=m:d.verify_inputs(source,m))
    a=d.read(d.REPO/d.ADAPTER); r=d.read(d.REPO/d.RECOGNITION)
    for key in ('conditions','conditional_conditions'):
        for value in (False,None):
            bad=copy.deepcopy(a);bad[key][next(iter(bad[key]))]=value
            rejects(f'fixed prerequisite mutation {key}/{value}',lambda bad=bad:d.fixed_hello(bad,r))
    bad=copy.deepcopy(a);bad['launch']['native_options'].append('--param=lra-inheritance-ebb-probability-cutoff=100')
    rejects('extra invocation parameter rejected',lambda:d.fixed_hello(bad,r))
    bad=copy.deepcopy(r);bad['accepted_fixture']['complete_owner']['each_recognition_record_bytes']+=1
    rejects('complete owner mutation rejected',lambda:d.fixed_hello(a,bad))
    bad=copy.deepcopy(r);bad['accepted_fixture']['source_counts']['Put']+=1
    rejects('complete source count mutation rejected',lambda:d.fixed_hello(a,bad))
    output=dict(checks=len(checks),passed=checks,elapsed_seconds=time.monotonic()-start,
                host=platform.platform(),input_verification=verification,
                independent_score_corners=score_cases,
                native_tool_executions=0,predecessor_module_executions=0,
                solver_or_prover_executions=0,aggregate_or_corpus_replays=0,
                handwritten_source_theorem_mechanically_proved=False)
    (d.HERE/'check-results.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps({k:v for k,v in output.items() if k!='passed'}))


if __name__=='__main__':main()

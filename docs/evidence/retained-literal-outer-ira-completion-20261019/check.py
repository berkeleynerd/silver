#!/usr/bin/env python3
"""Focused outer-IRA arithmetic and source/owner checks. No native tool runs."""
import argparse
import copy
import json
import platform
import re
import runpy
import subprocess
import tarfile
import time
from pathlib import Path
from derive import HERE, REPO, I32, I64, arithmetic, identity, require, validate_inputs, retained_reconciliation


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--gcc-root',type=Path,required=True)
    args=p.parse_args();start=time.perf_counter();checks=[]
    def check(name,value):
        require(value,name);checks.append(name)
    def rejects(name,fn,fragment):
        try:fn()
        except ValueError as e:check(name,fragment in str(e))
        else:raise AssertionError(name+' did not reject')
    pins=validate_inputs(args.gcc_root)
    manifest=json.loads((HERE/'inputs.json').read_bytes())
    for row in manifest['files']:
        if row['root']=='repository':
            raw=subprocess.check_output(['git','show',manifest['base_revision']+':'+row['path']],cwd=REPO)
            check('base Git input '+row['path'], identity(raw)==row['identity'])
    for c,n in [(1,0),(2,0),(16,0),(17,0),(10,10),(5000,0),(1,1000000),(10**20,10**20)]:
        r=arithmetic(c,n);a,k,b=4*c,99+5*c,2*n+10
        req=r['individual_ordinary_requests_upper'];g=r['local_representation_checks']
        check(f'count and extent transfer C{c}/N{n}',r['extents']==dict(A=a,K=k,B=b,M=7*c+5*n+20,U=7*c+5*n+22,P=14*c+12*n+50,D=17690*c+368*n+19076))
        check(f'exact scratch C{c}/N{n}',req['DF_last_visit_age']==8+4*b and req['DF_last_change_age']==12+4*b and req['DF_each_postorder']==4*b)
        check(f'guard result C{c}/N{n}',r['failed_predicates']==[q for q,v in g.items() if not v] and r['conditional_remaining_outer_IRA_interface_arithmetic']==all(g.values()))
        check(f'correction and scope C{c}/N{n}',r['GGC_correction']['positive_GGC_requests_upper']==4 and not r['corrected_collector_capacity_established'] and not r['actual_source_attachment_implemented'] and not r['complete_native_capacity'])
    check('C16 sort inline',arithmetic(16,0)['individual_ordinary_requests_upper']['IRA_sort_scratch']==0)
    check('C17 sort heap',arithmetic(17,0)['individual_ordinary_requests_upper']['IRA_sort_scratch']==272)
    check('DF sort may exceed inline scratch',arithmetic(1,0)['individual_ordinary_requests_upper']['DF_sort_scratch']==8*47==376)
    boundaries=[]
    for key in arithmetic(1,0)['local_representation_checks']:
        use_n=key.startswith('CFG_') or key.startswith('DF_') and not key.startswith('DF_reference')
        def evaluate(x):return arithmetic(1,x) if use_n else arithmetic(x,0)
        lo=0 if use_n else 1;hi=2**70
        require(evaluate(lo)['local_representation_checks'][key] and not evaluate(hi)['local_representation_checks'][key],'boundary bracket '+key)
        while lo+1<hi:
            mid=(lo+hi)//2
            if evaluate(mid)['local_representation_checks'][key]:lo=mid
            else:hi=mid
        check('guard last-safe/first-failing '+key,evaluate(lo)['local_representation_checks'][key] and not evaluate(hi)['local_representation_checks'][key])
        boundaries.append(dict(predicate=key,variable='N' if use_n else 'C',last_safe=lo,first_failing=hi))
    for c,n in [(0,0),(-1,0),(1,-1),(True,0),(1,False),(1.0,0),(1,None)]:
        rejects('invalid count '+repr((c,n)),lambda:arithmetic(c,n),'literal C/N')
    # Independent interval decomposition: every child span is a subspan,
    # each leaf has 2..5 elements, every left scratch need fits floor(root/2).
    for count in list(range(2,257))+[511,512,513,1023,1024,1025,4096]:
        stack=[(0,count,1)];maxdepth=0
        while stack:
            base,n,depth=stack.pop();maxdepth=max(maxdepth,depth)
            require(0<=base<base+n<=count,'sort source span')
            if n<=5:require(2<=n<=5,'sort network domain')
            else:
                left=n//2;right=n-left
                require(left<=count//2 and 8*left<=8*(count//2),'sort scratch span')
                stack.extend([(base,left,depth+1),(base+left,right,depth+1)])
        check('sort interval/depth '+str(count),maxdepth<=(count-1).bit_length()+1)
    for bits in [1,12,63,64,65,127,128,129,104,I32]:
        words=(bits+63)//64
        check('dense independent rounding '+str(bits),64*(words-1)<bits<=64*words and 8+8*words<2**32)
    inv=runpy.run_path(str(HERE/'inspect-md.py'))['inventory'](args.gcc_root)
    check('retained target inventory exact',inv==json.loads((HERE/'target-patterns.json').read_bytes()))
    check('target direct leaf cases',len(inv['direct_SET_leaf_templates'])==37)
    check('target wildcard roots all parallel',len(inv['root_wildcard_templates'])==7 and all(x['pattern'][0]=='match_parallel' for x in inv['root_wildcard_templates']))
    check('target include closure',all((args.gcc_root/'gcc/config/i386'/x['include']).is_file() for x in inv['includes']))
    # REG-rejecting push/pop/ternlog/memory patterns need not constrain.
    attrs={x['name'].strip('"'):x['values'] for x in inv['constraint_mode_attributes']}
    check('constraint mode attributes exact set',set(attrs)=={'hfbfconstf','sseconstm1'})
    for name,values in attrs.items():
        check('constraint attribute terminal values '+name,all(x[1].strip('"') in ('','F','BC','BF') for x in values))
    survivors=[]
    for row in inv['direct_SET_leaf_templates']:
        pat=row['pattern'];preds=[x[2].strip('"') for x in pat[1:] if len(x)>=3 and x[0].startswith('match_operand')]
        if any(x in ('push_operand','pop_operand','memory_operand','ternlog_operand') for x in preds):continue
        survivors.append(row)
        for operand in pat[1:]:
            if len(operand)>3:
                raw_constraint=operand[3].strip('"')
                require(all(name in attrs for name in re.findall(r'<([^>]*)>',raw_constraint)), 'known constraint attribute')
                constraint=re.sub(r'<[^>]*>', '', raw_constraint)
                check('no matching/earlyclobber probe constraint '+row['file']+'/'+row['name']+'/'+operand[1],not any(ch in constraint for ch in '0123456789&+<>'))
    with tarfile.open(REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017/df-backing-selected-headers.tar.gz') as t:
        mode=t.extractfile('insn-modes.h').read().decode()
        check('retained 124 modes',len(re.findall(r'^  E_\w+mode,',mode,re.M))==124 and '#define NUM_POLY_INT_COEFFS 1' in mode)
    with tarfile.open(REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017/rtl-selected-headers.tar.gz') as t:
        conf=t.extractfile('insn-config.h').read().decode()
        check('retained 30 operands and zero filters','#define MAX_RECOG_OPERANDS 30' in conf and '#define NUM_REGISTER_FILTERS 0' in conf)
    for kind in ['hash','text','fragment','coordinate']:
        mutant=copy.deepcopy(manifest)
        if kind=='hash':mutant['files'][0]['identity']['sha256']='0'*64
        elif kind=='text':mutant['excerpts'][0]['text']+='\n'
        elif kind=='fragment':mutant['excerpts'][0]['operative_fragments'].append('UNREACHABLE_FAKE_FRAGMENT')
        else:mutant['excerpts'][0]['first_LF_line']+=1
        rejects('manifest rejects '+kind,lambda:validate_inputs(args.gcc_root,mutant),'input identity' if kind=='hash' else 'operative fragment' if kind=='fragment' else 'LF excerpt')
    retained=retained_reconciliation()
    check('historical50 correction51',retained['inherited_events']==47054 and retained['corrected_event_envelope']==47058 and retained['corrected_owner_count']==51)
    check('367 prerequisite map retained',retained['accepted_367_guard_schema']==367)
    corr=arithmetic(1,0)['GGC_correction']
    check('constructor byte arithmetic',sum(x['count']*x['each_raw_bytes_upper'] for x in corr['constructor_requests'])==144 and 3*32+128==corr['aggregate_rounded_bytes_upper']==224)
    result=dict(scope='Pure outer-IRA source-interface count transfer; actual-source correction pending',hello=arithmetic(1,0),
                C10_N10=arithmetic(10,10),C5000_N0=arithmetic(5000,0),boundaries=boundaries,retained_reconciliation=retained,
                verified_inputs=pins,native_tool_executions=0,predecessor_evaluator_executions=0)
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    elapsed=time.perf_counter()-start
    report=dict(passed=True,checks=len(checks),check_names=checks,elapsed_seconds=elapsed,
                host=dict(system=platform.system(),release=platform.release(),machine=platform.machine()),
                verified_inputs=pins,source_argument_is_handwritten=True,
                checked_artifacts={p:identity((HERE/p).read_bytes()) for p in ['derive.py','inspect-md.py','check.py','inputs.json','target-patterns.json','result.json']})
    (HERE/'check-results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:report[k] for k in ['passed','checks','elapsed_seconds','verified_inputs']}))

if __name__=='__main__':main()

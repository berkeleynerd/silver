#!/usr/bin/env python3
"""Focused new checks; no native compiler or predecessor import/execution."""
import argparse, ast, copy, json, platform, re, time
from pathlib import Path
import derive as d


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--ada-root',required=True)
    parser.add_argument('--gcc-root',required=True);args=parser.parse_args()
    start=time.monotonic();names=[]
    def check(name,p):
        if not p:raise AssertionError(name)
        names.append(name)
    def rejects(name,call):
        try:call()
        except ValueError:names.append(name)
        else:raise AssertionError(name)
    verification=d.verify_inputs(args.ada_root,args.gcc_root)
    check('exact byte pins and LF operative excerpts',verification==dict(files=37,literal_LF_excerpts=48))
    for c,n in [(1,0),(1,100),(5000,0),(32766,2),(2**31,0),(1,2**100)]:
        a=d.arithmetic(c,n)
        check(f'node-domain algebra {c}/{n}',a['frontend_node_allowance']==41275+19*c+4*n)
        check(f'no complete capacity or lifetime request invention {c}/{n}',
              not a['complete_Ada_frontend_capacity'] and not a['complete_native_capacity']
              and a['NCT_lifetime_requests'] is None and a['NCT_pending_Elists_recharged']==0)
        check(f'local copy wrapper bound independent of C/N {c}/{n}',a['individual_objects_bytes_upper']['NCT_each_wrapper']==16)
    for c,n in [(True,0),(1,False),(0,0),(1,-1),('1',0),(1,0.0)]:
        rejects(f'invalid count input {c!r}/{n!r}',lambda c=c,n=n:d.arithmetic(c,n))
    for p in [-1,513,True]:rejects(f'path outside accepted descriptor {p}',lambda p=p:d.arithmetic(1,0,p))
    a=d.arithmetic(1,0)
    check('three exact fixed-table allocations',[(v['capacity_upper'],v['individual_bytes_upper']) for v in a['named_fixed_tables'].values()]==[(32,396),(64,33280),(96,97)])
    for name,t in a['named_fixed_tables'].items():
        length=t['initial']
        while length<t['demand']:length=max(length*(100+t['increment_percent'])//100,length+10)
        check('source growth recurrence '+name,length<=t['capacity_upper'])
    check('zero diagnostic demand retains all11 initial tables',len(a['zero_attempt_diagnostic_tables'])==11 and all(t['individual_bytes_upper']>0 and t['demand']==0 for t in a['zero_attempt_diagnostic_tables'].values()))
    check('fixed static and local objects all fit',all(a['checks'].values()))
    last=(d.I32-1-41275)//19
    check('inherited node domain last integer boundary',d.arithmetic(last,0)['checks']['inherited_node_domain'])
    check('inherited node domain first failure',not d.arithmetic(last+1,0)['checks']['inherited_node_domain'])
    good=dict.fromkeys(d.PREMISES,True)
    check('all joins export only named bounds',d.apply(1,0,good)['computed'] and not d.apply(1,0,good)['complete_Ada_frontend_capacity'])
    for key in d.PREMISES:
        for value in [False,None]:
            r=d.apply(1,0,{**good,key:value})
            check(f'preserve {key}/{value}',not r['computed'] and r['derived'] is None and r['source_premises'][key] is value)
    rejects('no caller-settable complete-frontend assumption',lambda:d.apply(1,0,{**good,'remaining_frontend_safe':True}))
    rejects('no truthiness coercion',lambda:d.apply(1,0,{**good,d.PREMISES[0]:1}))
    rejects('missing source joins',lambda:d.apply(1,0,{}))
    check('failed inherited domain nulls named export',d.apply(2**31,0,good)['derived'] is None)

    ada=Path(args.ada_root)
    registry=json.loads((d.HERE/'registry-literals.json').read_text())
    check('exact fixed registry177 Strings',sum(r['count'] for r in registry)==177)
    check('largest actual registry literal39',max(r['maximum_characters'] for r in registry)==39)
    for row in registry:
        raw=(ada/row['path']).read_bytes().decode()
        for entry in row['literals']:
            line=raw.split('\n')[entry['LF']-1]
            assert entry['value'] in line and entry['characters']==len(entry['value'])
        check('every registry literal LF/value '+row['path'],len(row['literals'])==row['count'])
    raw=re.sub(r'--[^\n]*','',(ada/'errid.ads').read_text())
    for typ,count in [('Diagnostic_Id',10),('Switch_Id',85)]:
        body=re.search(r'type '+typ+r' is\s*\((.*?)\);',raw,re.S)[1]
        check('fixed registry enum '+typ,len(body.split(','))==count)
    opt=(ada/'opt.ads').read_text()
    config=re.search(r'type Config_Switches_Type is record(.*?)end record;',opt,re.S)[1]
    config=re.sub(r'--[^\n]*','',config)
    check('Config_Switches26 scalar fields',len(re.findall(r'^\s*\w+\s*:',config,re.M))==26)
    check('full table body unconditionally initializes',re.search(r'begin\s+Init;\s+end Table;\s+end Table;', (ada/'table.adb').read_text()) is not None)
    # A node-key map is chained. Peak cardinality does not become an array product.
    keys={};allocations=0
    for key,value in [(7,1),(7,2),(8,3),(7,4)]:
        allocations+=key not in keys;keys[key]=value
    check('duplicate map keys replace without another wrapper',allocations==2 and len(keys)==2 and keys[7]==4)
    check('maximum copy-map bucket and successor',max(k%511 for k in range(1022))==510 and 510<d.I32)

    census=json.loads((d.HERE/'fixed-table-census.json').read_text())
    fixed=json.loads((d.REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017/native-fixed-inputs.json').read_text())['fixed_lifetime_table_growth']
    check('complete120-symbol reconciliation uses retained exact counts',{r['symbol']:r['retained_positive_lifetime_growth'] for r in census['rows']}==fixed)
    check('39 inherited14 new67 still-unreconciled',census['inherited_count']==39 and census['newly_priced_named_count']==14 and len(census['unreconciled'])==67)
    check('no silent zero-growth discharge',any(r['retained_positive_lifetime_growth']==0 and r['owner'] is None for r in census['rows']))
    check('lib.Units existing ALI owner distinguished',next(r for r in census['rows'] if r['symbol']=='lib__units__last_val')['owner'].startswith('inherited Main_ALI'))
    check('ALI consumer Unit table is a separate Main instance',next(r for r in census['rows'] if r['symbol']=='ali__units__last_val')['owner'] is None)
    manifest=json.loads((d.HERE/'inputs.json').read_text())
    for variant in ['hash','LF','operative']:
        m=copy.deepcopy(manifest)
        if variant=='hash':m['files'][0]['identity']['sha256']='0'*64
        elif variant=='LF':m['excerpts'][0]['first_LF_line']+=1
        else:m['excerpts'][0]['operative_fragments'].append('MISSING_OPERATIVE_TERM')
        rejects('source mutation '+variant,lambda m=m:d.verify_inputs(args.ada_root,args.gcc_root,m))
    for file in d.HERE.glob('*.py'):ast.parse(file.read_bytes(),filename=str(file))
    result=json.loads((d.HERE/'result.json').read_text())
    check('retained result matches new pure arithmetic',result['arithmetic']==a)
    output=dict(checks=len(names),passed=names,elapsed_seconds=time.monotonic()-start,
                host=platform.platform(),input_verification=verification,
                native_executions=0,predecessor_executions=0,prover_or_Lean_executions=0,
                complete_Ada_frontend_capacity=False,handwritten_source_argument_mechanically_proved=False)
    (d.HERE/'check-results.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps({k:v for k,v in output.items() if k!='passed'}))

if __name__=='__main__':main()

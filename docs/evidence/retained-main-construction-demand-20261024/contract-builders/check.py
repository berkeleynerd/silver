#!/usr/bin/env python3
"""One focused new contract-builder check; no native or predecessor main."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import platform
import sys
import tarfile
import time
sys.dont_write_bytecode=True
from builders import *
from sites import collect, ROOT

HERE=Path(__file__).resolve().parent
checks=Counter()

def check(ok,name):
    if not ok:raise AssertionError(name)
    checks[name]+=1


def identities():
    x=json.loads((HERE/'identity.json').read_text())
    sha=lambda s:hashlib.sha256(s).hexdigest()
    for p in x['providers']:check(sha((ROOT/p['path']).read_bytes())==p['sha256'],'provider identity')
    for a in x['archives']:
        check(sha((ROOT/a['path']).read_bytes())==a['sha256'],'archive identity')
        with tarfile.open(ROOT/a['path']) as t:
            for f in a['files']:
                data=t.extractfile(f['path']).read()
                check(sha(data)==f['sha256'],'complete source identity')
                ls=data.decode().splitlines()
                for s in f['spans']:
                    code='\n'.join(ls[s['first']-1:s['last']])+'\n'
                    check(sha(code.encode())==s['sha256'],'source span identity')
                    for anchor in s['anchors']:check(anchor in code,'native branch anchor')


def diagrams():
    INT,BOOL=Ty('int'),Ty('bool')
    formal=PV(k.Var(1,INT));actual=PV(k.Var(2,INT))
    fields=[Field(200+i,INT) for i in range(11)]
    regs=[Region(100+i,Ty('ref'+str(i)),(fields[i],),i<7) for i in range(11)]
    globals_=tuple(PV(k.Var(1000+i,r.ty),r) for i,r in enumerate(regs))
    registry={v.var:v for v in globals_+(formal,actual)}
    fixture=k.Ledger(2000)
    terms=[k.node('app',k.var(globals_[i].var),k.var(formal.var),symbol='P') for i in range(7,11)]
    f=terms[0]
    for t in terms[1:]:f=k.node('and',f,t)
    post=k.close('eps',(k.Var(50,UNIT),),f,fixture)
    pre=(k.node('true'),)
    eff=Effect(frozenset(globals_[:7]),{r:frozenset({fd}) for r,fd in zip(regs,fields)},covers=frozenset(regs))
    d=Demand(10000,20000,30000)
    c=create_cty((formal,),pre,(post,),eff,UNIT,registry,d,defensive=True)
    check(c.effect.reads==frozenset(globals_),'post reads retain complete eleven-key state family')
    check(set(c.effect.writes)==set(regs) and c.effect.covers==frozenset(regs),'existing external writes and covers are preserved')
    check(not c.effect.taints and len(c.freeze)==11,'flat taints and exact external region freeze')
    check(d.owner_requests==Counter(Hsty=1) and d.kernel.ident_increments==0,'create_cty projects result without fresh binders')
    original_map_bytes=d.kernel.map_bytes_upper
    for _ in range(20):
        out=c_app(c,(actual,),UNIT,d)
        check(out.effect.reads==frozenset(globals_+(actual,)),'actual read union preserves external state')
        check(out.effect.writes==c.effect.writes and out.freeze==c.freeze,'application retains effects and frozen source identities')
        fv=k.t_vars(out.post[0],k.Ledger(0))
        check(formal.var not in fv and fv[actual.var]==4,'stored contract renaming retains repeated actual occurrences')
    check(d.owner_requests==Counter(Hsty=1) and d.kernel.ident_increments==0,'repeated API application has no hidden owner reset or increment')
    check(d.records['actual_tvar']==20 and d.calls['cty_spec_root']==40,'every supplied map and specification root is charged')
    check(d.kernel.map_bytes_upper>original_map_bytes,'repeated application accumulates map requests')

    empty=Demand(10000,20000,30000)
    composite=Ty('arrow',(INT,BOOL))
    create_cty((),(),(),Effect(),composite,{},empty)
    check(empty.owner_requests['Hsty']==3,'empty post list still projects entire result type')
    check(empty.records['effect']>=6,'intermediate empty effect records are retained')

    # Result references are a create_cty row even though their applications
    # need the separate region-instantiation partition.
    constructor=Demand(10000,20000,30000)
    r=regs[0]
    cc=create_cty((),(),(),Effect(),r.ty,{},constructor,defensive=True,result_region=r)
    check(cc.effect.resets==frozenset({r}) and not cc.freeze,'defensive reference result adds its escape reset')
    check(constructor.owner_requests==Counter(Hsty=1),'flat constructor does not invent type instantiation')

    saved=Demand(10000,20000,30000)
    image=k.node('app',ty=composite,symbol='f')
    bb=k.Binding((k.Var(70,UNIT),),k.node('true'),(),{}, {k.Var(71,composite):image})
    q=k.Term('eps',binding=bb,ty=UNIT)
    create_cty((),(),(q,),Effect(),UNIT,{},saved)
    check(saved.calls['t_gen_fold']==3 and saved.calls['ty_v_fold']==4,'type closure visits dead saved image rather than opened result alone')

    cases=Demand(10000,20000,30000)
    case=b.Case(k.node('const',ty=INT),((b.Pattern('wild',INT),k.Binding((),k.node('true'),(),{},{})),))
    qcase=k.Term('eps',binding=k.Binding((k.Var(72,UNIT),),case,(),{},{}),ty=UNIT)
    create_cty((),(),(qcase,),Effect(),UNIT,{},cases)
    check(cases.calls['pat_gen_fold']==1 and cases.calls['t_gen_fold']==4,'context cases stay in create_cty type traversal')
    check(cases.owner_requests==Counter(Hsty=1) and not cases.kernel.ident_increments,'context inspection neither opens nor freshens a branch')

    alias=Demand(10000,20000,30000)
    u=PV(k.Var(80,INT));v=PV(k.Var(81,INT));z=PV(k.Var(82,INT))
    aq=k.close('eps',(k.Var(83,UNIT),),k.node('app',k.var(u.var),k.var(v.var),symbol='R'),fixture)
    ac=Contract((u,v),(),(aq,),Effect(),UNIT)
    ar=c_app(ac,(z,z),UNIT,alias)
    check(k.t_vars(ar.post[0],k.Ledger(0))=={z.var:2},'noninjective actual map adds cache coefficients')
    check(alias.records['actual_tvar']==2,'aliasing does not erase map-entry construction')

    unit=Demand(10000,20000,30000)
    uc=Contract((),(),(q,),Effect(),UNIT)
    ur1=c_app(uc,(),UNIT,unit,unit=True);ur2=c_app(uc,(),UNIT,unit,unit=True)
    check(unit.calls['cty_apply_return_original']==2 and unit.calls['prior_contract_discarded']==2,'Unit counts application before replacement')
    check(unit.calls['cty_spec_root']==0,'nullary early return does not instantiate discarded contract')
    check(unit.owner_requests==Counter(Hsty=4,Hsity=2) and unit.kernel.ident_increments==2,'Unit replacement counts both Hsty requests and one Hsity and Ident per entry')
    check(ur1.post[0].binding.variables[0].tag==10001 and ur2.post[0].binding.variables[0].tag==10002,'Unit result uses one transported Ident history')
    check(unit.records['discarded_rho_preid']==2 and unit.records['apply_result_tuple']==2,
          'Unit retains discarded preid and application-prefix tuples')
    record=Demand(10000,20000,30000)
    c_app(Contract((formal,),(),(),Effect(),INT),(actual,),INT,record,constructor_one=True)
    check(record.memo_reads['fs_tuple_ids.mem']==1 and not record.calls['cty_tuple_unit'],
          'ordinary record constructor still probes tuple table')

    failure=Demand(10000,20000,30000)
    stale_q=k.close('eps',(k.Var(90,UNIT),),k.node('app',k.var(globals_[0].var),symbol='S'),fixture)
    try:create_cty((),(),(stale_q,),Effect(resets=frozenset({regs[0]})),UNIT,registry,failure)
    except SourceFailure as exc:check(str(exc)=='StaleVariable','stale diagnostic fails at actual effect check')
    else:raise AssertionError('stale read must fail')
    check(failure.owner_requests['Hsty']==1 and failure.kernel.map_bytes_upper>0 and not failure.records['cty'],'failed create_cty keeps projection and map prefix')
    mismatch=Demand(10000,20000,30000)
    try:c_app(c,(actual,),BOOL,mismatch)
    except SourceFailure:check(mismatch.records['actual_tvar']==1 and not mismatch.records['cty'],'result mismatch retains previously constructed actual map')
    else:raise AssertionError('result mismatch must fail')
    try:c_app(Contract((globals_[0],),(),(),Effect(),UNIT),(globals_[0],),UNIT,Demand())
    except ValueError:check(True,'reference application remains explicit residual')
    else:raise AssertionError('reference partition must not be priced as same pure types')
    return {name:x.export() for name,x in [('api20',d),('empty_post',empty),('reference_constructor',constructor),('saved_image',saved),('context_case',cases),('aliased_actuals',alias),('unit2',unit),('record_call',record),('failed_stale',failure),('failed_result',mismatch)]}


def main():
    start=time.monotonic();identities();sites=collect()
    check(len(sites['main_clone_ancestor_inventory'])==11,'source-attached Main clone closure')
    check(len(sites['other_fixed_clone_origins_remaining'])==58,'finite other-origin residual inventory')
    output=diagrams()
    (HERE/'sites.json').write_text(json.dumps(sites,indent=2)+'\n')
    (HERE/'exports.json').write_text(json.dumps(output,indent=2)+'\n')
    r={'status':'pass','assertions':sum(checks.values()),'families':dict(checks),
       'elapsed_seconds':time.monotonic()-start,'host':platform.platform(),
       'main_clone_ancestors':11,'remaining_fixed_origins':58,'exports':list(output),
       'native_runs':0,'predecessor_checker_main_runs':0,
       'complete_native_bytes':False,'complete_main_builder_classification':False,
       'whole_source_to_initial_vc_storage':False}
    (HERE/'result.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))

if __name__=='__main__':main()

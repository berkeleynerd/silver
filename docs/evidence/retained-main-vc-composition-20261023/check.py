#!/usr/bin/env python3
"""Check new composition seams against immutable inputs; replay no providers."""
import argparse
from collections import Counter
from dataclasses import replace
import gzip
import hashlib
import json
from pathlib import Path
import platform
import random
import re
import tarfile
import time

from model import (Term, Symbol, Logic, Axiom, Use, task_prefixes, TRUE, FALSE, BTRUE, BFALSE,
    var, app, node, free, lexical, affine, pretty, marked_map, alias_map,
    clone_records, application_cost, alias_cost, matcher, k, ksize, attached,
    term_of_kode, reflow, wp_core, range_definition)

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
COUNT=Counter()


def check(ok, family):
    if not ok:
        raise AssertionError(family)
    COUNT[family]+=1


def rejects(fn, family):
    try:
        fn()
    except ValueError:
        check(True,family)
    else:
        raise AssertionError('did not reject: '+family)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_inputs():
    manifest=json.loads((HERE/'identity.json').read_text())
    sources={}
    for item in manifest['archives']:
        path=ROOT/item['path']
        check(sha(path)==item['sha256'],'archive identity')
        with tarfile.open(path) as tar:
            for row in item['selected_files']:
                data=tar.extractfile(row['path']).read()
                check(len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256'],
                      'complete selected source identity')
                sources[(item['path'],row['path'])]=data.decode()
    for row in manifest['providers']:
        check(sha(ROOT/row['path'])==row['sha256'],'accepted provider identity')
    for row in manifest['spans']:
        text=sources[(row['archive'],row['path'])]
        fragment='\n'.join(text.splitlines()[row['first']-1:row['last']])+'\n'
        check(hashlib.sha256(fragment.encode()).hexdigest()==row['sha256'],'source seam span')
        for needle in row['contains']:
            check(needle in fragment,'source seam guard')
    library_files=[]
    for (archive,name),text in sources.items():
        if 'retained-producer-import-context' in archive and name.startswith('installed/') and name.endswith(('.mlw','.why')):
            check('GP_Inline' not in text and 'GP_Pretty_Ada' not in text,'fixed libraries have no native marks')
            library_files.append(name)
    check(len(library_files)==21,'complete fixed library byte frontier')
    raw=manifest['spark_inventory']
    archive=ROOT/raw['path']
    check(sha(archive)==raw['sha256'],'complete SPARK archive identity')
    with tarfile.open(archive) as tar:
        members=[m for m in tar.getmembers() if m.isfile() and
                 m.name.startswith('spark-source/src/') and m.name.endswith(('.ads','.adb'))]
        check(len(members)==279,'complete SPARK source inventory')
        goal_sites=[]
        for member in members:
            text=tar.extractfile(member).read().decode()
            check(not any(t in text for t in ('vc:wp','vc:sp','vc:white_box')),
                  'SPARK has no literal VC mode or white-box label')
            check(not re.search(r'\bNew_Goal\b',text,re.I),'no explicit native Goal emitter')
            if re.search(r'\bW_Goal\b',text):
                goal_sites.append(member.name)
        check(sorted(goal_sites)==['spark-source/src/why/why-sinfo.ads',
                                   'spark-source/src/why/xgen/xtree_sinfo.adb'],
              'native Goal mentions confined to schema and node-kind declaration')
    return manifest,library_files


def accepted_interfaces():
    # Read accepted data; do not import/rerun source.py or its provider checker.
    profiles=json.load(gzip.open(ROOT/'docs/evidence/retained-main-callers-profile-20261023/profiles.json.gz','rt'))
    rows=Counter()
    allowed={'variable','constant','binding','application','assignment','sequence',
             'if','raise','try','while','unit-cfun','assert','check','assume','any'}
    def visit(t,keys):
        rows[t['op']]+=1
        check(t['op'] in allowed,'typed constructor coverage')
        check(set(t['effects'])=={'reads','writes','raises'},'effects retained')
        if t['op']=='sequence':
            check(t['key'] in keys and t['lowering']['constructor']=='LDvar',
                  'sequence binding retained')
        if t['op']=='application':
            c=t['contract']
            check(len(c['actuals'])==len(t['args']) and c['local']['h']==c['local']['o']==0,
                  'per-call actual and contract attachment')
            check(all(x in c for x in ['pre','opened_post','definition','residual','reads','writes','result']),
                  'per-call complete terms')
        if t['op']=='unit-cfun':
            check(not t['effects']['raises'],'local check empty escaping set')
        for a in t['args']:
            visit(a,keys)
    for d in profiles['diagrams'].values():
        p=d['profile']; visit(p['tree'],set(p['initial_key_superset']))
        check(p['accounting']['nh']==p['accounting']['Delta'],'one process outcome increment vector')
    check(len(profiles['diagrams'])==60,'accepted diagram count')
    return dict(rows)


def context_and_costs():
    static=range_definition('r');dynamic=range_definition('d',dynamic=True)
    check(affine(static.body)==(5,Counter({'r:x':2})),'range affine source row')
    check(affine(dynamic.body)==(3,Counter({'d:first':1,'d:last':1,'d:x':2})),'range affine source row')
    symbols={
        'r':Symbol('r',('int',),'prop',('GP_Inline',)),
        'd':Symbol('d',('int','int','int'),'prop',('GP_Inline',)),
        'a':Symbol('a',('ref',),'int'),
        'b':Symbol('b',('ref',),'int',('GP_Inline',)),
        'field':Symbol('field',('ref',),'int',projection=True),
        'scalar':Symbol('scalar',('int',),'int'),
        'boolfun':Symbol('boolfun',('bool',),'bool'),
        'unitfun':Symbol('unitfun',('unit',),'int'),
        'poly':Symbol('poly',('typevar:a',),'typevar:a'),
    }
    x=var('x','ref')
    known={
        'a':Logic('a',('x',),app('b',x,ty='int')),
        'b':Logic('b',('x',),app('field',x,ty='int',attrs=('GP_Pretty_Ada:field',))),
        'field':Logic('field',('x',),var('x','ref')),
        'scalar':Logic('scalar',('x',),var('x')),
        'boolfun':Logic('boolfun',('x',),var('x','bool')),
        'unitfun':Logic('unitfun',('u',),Term('const',key='42',ty='int')),
        'poly':Logic('poly',('u',),var('u','typevar:a')),
    }
    aliases,reached=alias_map({'a','scalar','boolfun','unitfun','poly'},symbols,known,{'ref','unit'})
    check(set(aliases)=={'a','b','unitfun'} and 'field' in reached,'actual alias eligibility and closure')
    check('field' not in aliases,'named projection stops alias search')
    check('poly' not in aliases,'declared Tyvar stays ineligible despite possible Unit occurrence')
    D=marked_map([static,dynamic,*known.values()],symbols)
    check(set(D)=={'r','d','b'},'actual marked map')
    check(application_cost('r',[11],D)==27,'actual static range cost')
    check(application_cost('d',[7,13,11],D)==45,'actual dynamic range cost')
    check(application_cost('missing',[11],D)==12,'unmarked constructor arm')
    # The original marked definition survives if a trigger is skipped, while
    # another unmarked symbol can reach a marked target. Both maxima matter.
    marked={'b':(('x',),app('combine-five',x,x,x,x,x,ty='int'))}
    check(alias_cost('a',7,marked,aliases)==36,'unmarked alias reaches marked target')
    marked['a']=(('x',),app('combine-nine',*(x for _ in range(9)),ty='int'))
    check(alias_cost('a',7,marked,aliases)==64,'skipped original marked alias retained')
    # Exact extraction guards and ordered overwrite, not a max of all records.
    rhs=static.body
    eq_axiom=Axiom(node('forall',app('=',app('r',var('r:x')),rhs),key='r:x'))
    bool_axiom=Axiom(node('forall',node('iff',app('=',app('r',var('r:x')),BTRUE),rhs),key='r:x'))
    E=marked_map([bool_axiom,static],symbols)
    check(lexical(E['r'][1])==lexical(rhs)+3,'Boolean axiom adds three nodes')
    annotated=Axiom(node('forall',node('iff',app('=',app('r',var('r:x')),
        replace(BTRUE,attrs=('source-location',))),rhs),key='r:x'))
    check(lexical(marked_map([annotated],symbols)['r'][1])==lexical(rhs)+3,
          'Boolean True recognition ignores attributes')
    check(marked_map([static,bool_axiom],symbols)['r'][1]==rhs,'earliest source declaration wins native backward fold')
    check(marked_map([eq_axiom],symbols)['r'][1]==rhs,'oriented quantified equation extraction')
    imported=[replace(eq_axiom,kind='lemma'),Axiom(app('imported-goal'),kind='goal')]
    goals,prefix,used=task_prefixes([Use('fixed'),Use('fixed'),Axiom(app('Main-vc'),kind='goal'),
        static,Axiom(app('later-vc'),kind='goal')],{'fixed':imported})
    check(len(goals)==2 and used=={'fixed'} and len(goals[0][0])==1,
          'task use deduplication drops imported goals')
    check(goals[0][0][0].kind=='axiom' and marked_map(goals[0][0],symbols)['r'][1]==rhs,
          'imported lemma becomes marked-map axiom')
    check(static not in goals[0][0] and static in goals[1][0],
          'goal prefix snapshots exclude later original pdecl')
    hidden=app('opaque',app('<=',var('r:x'),var('r:x'),attrs=('GP_Pretty_Ada:hidden',)))
    check(not pretty(hidden),'pretty traversal does not enter actuals')
    trigger_only=node('forall',app('opaque',var('z')),app('trigger',var('z'),
        attrs=('GP_Pretty_Ada:trigger',)),key='z')
    check(not pretty(trigger_only),'pretty traversal does not enter quantifier triggers')
    bad=[
        replace(static,group_size=2),replace(static,body=hidden),replace(static,body=trigger_only),
        Axiom(app('=',app('r',var('r:x')),rhs)),
        Axiom(node('forall',app('=',rhs,app('r',var('r:x'))),key='r:x')),
        Axiom(node('forall',node('implies',app('r',var('r:x')),rhs),key='r:x')),
        Axiom(node('forall',app('=',app('r',Term('const',key='0',ty='int')),rhs),key='r:x')),
        replace(eq_axiom,kind='lemma'),
    ]
    for d in bad:
        check(not marked_map([d],symbols),'marked extraction rejection guard')
    # Clone identities/formals/types are separate; a substituted symbol's own
    # definition disappears and the replacement keeps its existing attributes.
    cs,cd,sm=clone_records(symbols,[static,known['a'],known['b']], 'clone:',
                          {'b':'replacement'}, {'ref':'concrete-ref'})
    check('clone:b' not in cs and len(cd)==2,'substituted definition omitted')
    check(cd[1].body.key=='replacement' and cd[1].formals!=known['a'].formals,
          'clone symbol and binder identities')
    check(cs['clone:a'].argtypes==('concrete-ref',),'clone concrete argument type')
    check(cs['clone:r'].attrs==symbols['r'].attrs,'clone source attributes')
    cycle=known | {'b':Logic('b',('x',),app('a',x,ty='int'))}
    rejects(lambda:alias_map({'a'},symbols,cycle,{'ref'}),'cyclic fixture diagnoses broken constructor premise')
    # Formula projection: lexical reuse, actual contexts, and outer quantifier.
    value=app('+',var('input'),Term('const',key='1',ty='int'),ty='int')
    core=k('seq',k('let',key='v',terms=(value,TRUE)),
           k('stop',terms=(app('r',var('v')),)),key=0)
    g=wp_core(core,{})
    f=node('forall',g,key='input',ty='int')
    check(free(f)==set(),'initial VC outer free-variable closure')
    m0=matcher(f);m1=matcher(f,D)
    check(m1>=m0 and m0>lexical(value),'per-formula lexical weighted join')
    weighted=6*m0*m0*m1
    unit=node('forall',app('=',var('u','unit'),var('u','unit')),key='u',ty='unit')
    check(matcher(unit,destructible={'unit':('unit.Tuple0',0)})>matcher(unit),
          'outer Unit quantifier destructor charged')
    # Duplicate actual variables use last ordered formal write just like fold_left2.
    repeated={'repeat':(('x','x'),app('combine-two',var('x'),var('x'),ty='int'))}
    check(application_cost('repeat',[3,17],repeated)==35,'repeated formal binding order')
    return {'formula_fixture':{'M0':m0,'M1':m1,'terminal_goal_upper':weighted},
            'range_profiles':{'static':[5,2],'dynamic':[3,1,1,2]},
            'D_keys':sorted(D),'I_keys':sorted(aliases),'reachable_symbols':sorted(reached)}


def extraction_and_reflow():
    a=app('+',var('a'),var('b'),ty='int')
    t=app('pred',var('v'),ty='bool')
    p=app('=',var('v'),var('external'))
    code=k('seq',k('let',key='v',terms=(a,TRUE)),
             k('par',k('stop',terms=(app('side-check',var('v')),)),
               k('let',key='result',terms=(t,p))),key=0)
    value,predicate,residual=term_of_kode(code,'result')
    check(value.op==predicate.op=='let' and value.args[0]==predicate.args[0]==a,
          'both extracted outputs unwind their own definition')
    check(attached(residual)[a]==1 and attached(residual)[app('side-check',var('v'))]==1,
          'extraction preserves residual checks and saved definitions')
    check('v' not in free(value)|free(predicate),'extraction binder closure')
    unknown=k('seq',k('val',key=('v',),terms=(TRUE,)),
                k('let',key='result',terms=(BTRUE,app('p',var('v')))),key=0)
    rejects(lambda:term_of_kode(unknown,'result'),'unknown value used only in predicate still fails')
    unitcode=k('seq',k('val',key=('v',),terms=(TRUE,)),
        k('let',key='result',terms=(BTRUE,app('p-unit',var('v','unit')))),key=0)
    unitvalue,unitpred,_=term_of_kode(unitcode,'result',frozenset({'v'}))
    check('v' not in free(unitvalue)|free(unitpred),'Unit saved value has definition')
    throws=k('seq',k('cont',key=3),k('let',key='result',terms=(BTRUE,TRUE)),key=0)
    rejects(lambda:term_of_kode(throws,'result'),'exceptional extraction fails')
    nonlinear=k('if',k('let',key='result',terms=(BTRUE,TRUE)),
                        k('let',key='result',terms=(BFALSE,TRUE)),key='condition')
    rejects(lambda:term_of_kode(nonlinear,'result'),'nonlinear extraction fails')
    # A separate internal k_fun obligation is a Par child, not another j.
    local=k('seq',k('val',key=(),terms=(TRUE,)),k('stop',terms=(app('local-check'),)),key=0)
    whole=k('par',local,k('stop',terms=(app('main-check'),)))
    formula=wp_core(whole,{})
    check(formula.op=='and' and len(formula.args)==2,'local function check stays in enclosing formula')
    # Source-generated nullary RKfunc/RKpred constants have a separate F
    # candidate even though their Cany result is normally only assumed.
    for definition in (None,app('source-initializer',var('logical-input'),ty='int')):
        result=(k('val',key=('wrapper-result',),terms=(TRUE,)) if definition is None
                else k('let',key='wrapper-result',terms=(definition,TRUE)))
        for trace in (False,True):
            result_trace=(k('seq',result,k('let',key='trace',
                terms=(var('wrapper-result'),TRUE)),key=0) if trace else result)
            wrapper=k('seq',k('val',key=(),terms=(TRUE,)),
                k('seq',result_trace,k('stop',terms=(TRUE,)),key=0),key=0)
            check(ksize(wrapper)<=7 and ksize(reflow(wrapper,False))<=23,
                  'source-dependent wrapper has own constructor export')
            if definition is not None:
                check(attached(wrapper)[definition]==1,'wrapper retains its complete initializer term')
    # Actual outcome consumption routes handler terms without resetting labels.
    exceptional=k('seq',k('par',k('cont',key=7),k('cont',key=9)),
                    k('stop',terms=(app('handler-seven'),)),key=7)
    r=reflow(exceptional)
    check(attached(r)[app('handler-seven')]==1,'exception continuation inserted once')
    rejects(lambda:reflow(k('tag',k('tag',k('cont',key=0),key=('wp',)),key=('sp',))),
            'open SP-to-WP switch rejects invalid fixture')
    # Finite stress over structures exercises the already-proved singleton-exit
    # invariant, including dead continuations and open exceptional handlers.
    rng=random.Random(185)
    bases=[k('cont',key=i) for i in range(3)]+[
        k('stop',terms=(app('stop'),)),k('cut',terms=(app('cut'),)),
        k('let',key='v',terms=(a,p)),k('val',key=('u',),terms=(TRUE,)),k('havoc')]
    def generate(depth):
        if not depth or rng.randrange(4)==0:
            return rng.choice(bases)
        choice=rng.randrange(5)
        if choice<3:
            return k(('seq','par','if')[choice],generate(depth-1),generate(depth-1),
                     key=rng.randrange(3) if choice==0 else 'c' if choice==2 else None)
        return k('axiom' if choice==3 else 'tag',generate(depth-1),
                 key=None if choice==3 else ('off','fixture'))
    largest=0
    for _ in range(1200):
        code=generate(5)
        for vc_wp in (False,True):
            r=reflow(code,vc_wp)
            check(ksize(r)<=3*ksize(code)+2,'reflow retained node envelope')
            check(not (attached(r)-attached(code)),'reflow attached-term submultiset')
            largest=max(largest,ksize(code))
    return {'random_reflow_inputs':1200,'modes_per_input':2,'largest_input_kode_nodes':largest,
            'two_output_extraction_costs':[lexical(value),lexical(predicate)]}


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--write',action='store_true')
    args=parser.parse_args()
    start=time.perf_counter()
    manifest,libs=source_inputs()
    rows=accepted_interfaces()
    join=context_and_costs()
    structure=extraction_and_reflow()
    result={
        'checks':sum(COUNT.values()),'checks_by_family':dict(COUNT),
        'elapsed_seconds':time.perf_counter()-start,
        'platform':platform.platform(),'machine':platform.machine(),
        'selected_model':'GPT-6 Astra','selected_effort':'Extra High',
        'runtime_model_effort_confirmation':None,'tokens':None,'cost':None,
        'reason':'Check only new #185 composition seams; reuse accepted provider bytes and results without replay.',
        'input_sha256':{row['path']:row['sha256'] for row in manifest['providers']},
        'checker_sha256':sha(Path(__file__)), 'model_sha256':sha(HERE/'model.py'),
        'identity_sha256':sha(HERE/'identity.json'),
        'library_files':libs,'accepted_typed_occurrences':rows,**join,**structure,
        'native_executions':0,'predecessor_checker_executions':0,
        'scope':'Source identities/guards and focused finite models; universal result is the research-note construction induction, pending exact-freeze independent review.'}
    if args.write:
        (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__=='__main__':
    main()

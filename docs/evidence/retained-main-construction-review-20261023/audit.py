#!/usr/bin/env python3
"""Independent frozen construction audit. No author/provider code imports."""
import gzip
import hashlib
import io
import itertools
import json
import platform
import subprocess
import tarfile
import time
from collections import Counter
from functools import lru_cache
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = '767007bf43ad1a7ef82b8d629ab460b6186f694e'
PACKET = 'docs/evidence/retained-main-construction-profile-20261023/'
CHECKS = 0
TERM_RECORDS = 0
NATIVE_OCCURRENCES = 0


def check(value, message):
    global CHECKS
    if not value:
        raise AssertionError(message)
    CHECKS += 1


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


@lru_cache(None)
def blob(path):
    return subprocess.check_output(['git', 'show', AUTHOR + ':' + path], cwd=ROOT)


def read(path):
    return json.loads(blob(path))


@lru_cache(None)
def archive(path):
    with tarfile.open(fileobj=io.BytesIO(blob(path))) as tf:
        return {m.name: tf.extractfile(m).read() for m in tf if m.isfile()}


def t(op, ty='prop', key='', args=()):
    return dict(op=op, key=key, type=ty, args=list(args))


def v(key, ty='int'):
    return t('var', ty, key)


def a(key, *args, ty='prop'):
    return t('app', ty, key, args)


BT, BF, TRUE = t('atom', 'bool', 'True'), t('atom', 'bool', 'False'), t('atom', 'prop', 'true')


def evaluate(tree, weights):
    if tree['op'] == 'var':
        return weights[tree['key']]
    children = tree['args']
    if tree['op'] == 'let':
        definition = evaluate(children[0], weights)
        return 1 + definition + evaluate(children[1], dict(weights, **{tree['key']: definition}))
    return 1 + sum(evaluate(c, weights) for c in children)


def free(tree, bound=frozenset()):
    if tree['op'] == 'var':
        return set() if tree['key'] in bound else {tree['key']}
    if tree['op'] == 'let':
        return free(tree['args'][0], bound) | free(tree['args'][1], bound | {tree['key']})
    return set().union(*(free(c, bound) for c in tree['args']))


def term_record(record, expected_tree=None):
    global TERM_RECORDS
    TERM_RECORDS += 1
    tree = record['tree']
    if expected_tree is not None:
        check(tree == expected_tree, 'complete term tree correspondence')
    keys = sorted(free(tree))
    unit = dict.fromkeys(keys, 1)
    value = evaluate(tree, unit)
    coeff = {}
    for key in keys:
        coeff[key] = evaluate(tree, unit | {key: 2}) - value
    constant = value - sum(coeff.values())
    check(record['coefficients'] == coeff and record['constant'] == constant, 'independent affine recovery')
    check(record['unit_weight'] == value, 'unit lexical weight')
    check(constant >= 0 and all(n > 0 for n in coeff.values()), 'positive-weight monotonicity coefficients')
    for scale in [7, 10**85]:
        weights = {key: scale*(i+1)+3 for i, key in enumerate(keys)}
        check(evaluate(tree, weights) == constant + sum(coeff[k]*weights[k] for k in keys), 'mixed lexical weights and binder use')
        check(evaluate(tree, {k: w+scale for k,w in weights.items()}) >= evaluate(tree, weights), 'fixed-shape monotonicity')
    return constant, coeff


def term_scope(tree, bound):
    if tree['op'] == 'var' and tree['key'].startswith('tmp:'):
        check(tree['key'] in bound, 'logical temporary is in caller/local scope')
    for i,child in enumerate(tree['args']):
        scope = bound | {tree['key']} if tree['op'] == 'let' and i == 1 else bound
        term_scope(child, scope)


def expected_contracts():
    result = {}

    def generic(name, args, ty, route='RKfunc', reset=False):
        xs = [v('a'+str(i), x) for i,x in enumerate(args)]
        rhs = a(name, *xs, ty=ty)
        r = v('result', 'bool' if ty == 'prop' else ty)
        if ty == 'prop':
            post = t('iff', args=[a('=', r, BT), rhs])
            definition = t('if', 'bool', args=[rhs, BT, BF])
        else:
            post, definition = a('=', r, rhs), rhs
        result[name] = (args, ty, route, reset, [], post, definition, TRUE)

    for name, count in [('Int.+',2),('Int.-',2),('Int.*',2),('Int.neg',1)]:
        generic(name, ['int']*count, 'int')
    for name in ['Int.<','Int.<=','Int.>','Int.>=']:
        generic(name, ['int','int'], 'prop', 'RKpred')
    for name, args, ty in [
            ('Array.get',['map','int'],'character'),
            ('Array.slide',['map','int','int'],'map'),
            ('Array.slice',['map','int','int'],'map'),
            ('Array.concat',['map','int','int','map','int','int','int'],'map'),
            ('String.to_array',['string'],'map'), ('String.of_array',['map','int','int'],'string')]:
        generic(name,args,ty)
    for bound in ['first','last','length']:
        generic('String.'+bound,['string'],'int','RKnone explicit equality')
    for module in ['Standard.Integer','Standard.Positive']:
        for bound in ['first','last']:
            generic(module+'.'+bound,[],'int','RKfunc nullary declaration')
    for ty in ['int','bool','map']:
        generic(ty+'__content',[ty+'__ref'],ty,'projection')
        generic(ty+'__mkref',[ty],ty+'__ref','constructor',True)
    result['='] = (['any','any'],'prop','logic-only',False,[],None,None,None)
    result['String.dynamic_property'] = (['int']*4,'prop','logic-only',False,[],None,None,None)

    def explicit(name,args,ty,pre,post,definition=None,residual=None):
        result[name] = (args,ty,'RKnone',False,pre,post,definition,residual)

    for family in ['Static','Dynamic','Boolean']:
        xs = [v('a'+str(i)) for i in range(3 if family=='Dynamic' else 1)]
        value, r = xs[-1], v('result')
        range_p = a(family+'.dynamic_property',*xs) if family=='Dynamic' else a(family+'.in_range',value)
        tests = {'range_check':range_p}
        for i,bound in enumerate(['first','last']):
            b = xs[i] if family=='Dynamic' else t('atom','int',family+'.'+bound)
            tests['check_not_'+bound] = t('not',args=[a('=',value,b)])
        for suffix,p in tests.items():
            post = a('=',r,value)
            residual = TRUE
            if family!='Boolean':
                post = t('and',args=[post,p])
                residual = t('and',args=[TRUE,p])
            explicit(family+'.'+suffix,['int']*len(xs),'int',[p],post,value,residual)
    r,x,y = v('result','bool'),v('a0','bool'),v('a1','bool')
    for suffix,yes,no in [('bool_eq',BT,BF),('bool_ne',BF,BT)]:
        definition = t('if','bool',args=[a('=',x,y),yes,no])
        explicit('Boolean.'+suffix,['bool','bool'],'bool',[],a('=',r,definition),definition,TRUE)
    explicit('Discrete.bool_eq',['rep','rep'],'bool',[],
             t('if',args=[a('=',v('a0','rep'),v('a1','rep')),a('=',r,BT),t('not',args=[a('=',r,BT)])]))
    explicit('Rep_Proj_Base.to_rep',['abstract'],'int',[],
             a('=',a('Rep_Proj_Base.to_rep',v('a0','abstract'),ty='int'),v('result')))
    explicit('Rep_Proj_Base.of_rep',['int'],'abstract',[],
             a('=',a('Rep_Proj_Base.to_rep',v('result','abstract'),ty='int'),v('a0')))
    return result


def graph(record):
    nodes = {n['id']:n for n in record['nodes']}
    check(len(nodes)==len(record['nodes']), 'distinct native identities')
    visited = set()
    def walk(uid, active=frozenset()):
        global NATIVE_OCCURRENCES
        check(uid in nodes and uid not in active, 'closed acyclic native child graph')
        NATIVE_OCCURRENCES += 1
        visited.add(uid)
        for c in nodes[uid]['children']:
            walk(c,active|{uid})
    walk(record['root'])
    check(visited==set(nodes), 'native graph has no unattached nodes')
    return nodes


def native(nodes,uid):
    n=nodes[uid]
    return (n['op'],n['key'],n['type'],n['domain'],n['symbol_identifier'],
            tuple(native(nodes,c) for c in n['children']))


def N(op,ty,*children,key='',domain='term',symbol=False):
    return (op,key,ty,domain,symbol,tuple(children))


def projection(n, signatures, want='value'):
    op,key,ty,domain,symbol,children=n
    if op=='label':
        return projection(children[0],signatures,want)
    if op=='identifier' and not symbol:
        out=v(key,ty)
    elif op=='constant':
        out=t('atom',ty,key)
    elif op in ['call','deref'] or (op=='identifier' and symbol):
        sig=signatures[key]
        args=[projection(c,signatures) for c in children]
        check(len(args)==len(sig['arg_types']), 'logical saturation')
        for c,expected in zip(args,sig['arg_types']):
            check(expected=='any' or c['type']==expected, 'logical actual type')
        out=a(key,*args,ty=sig['result_type'])
    elif op=='binding':
        out=t('let','prop' if want=='prop' else ty,key,
              [projection(children[0],signatures),projection(children[1],signatures,want)])
    elif op=='and':
        out=t('and',args=[projection(c,signatures,'prop') for c in children])
    elif op=='if':
        out=t('if','prop' if want=='prop' else ty,args=[projection(children[0],signatures,'prop')]+
              [projection(c,signatures,want) for c in children[1:]])
    else:
        raise AssertionError('unexpected logical constructor '+op)
    if want=='prop' and out['type']!='prop':
        check(out['type']=='bool','Boolean-to-proposition source type')
        return a('=',out,BT)
    if want=='value' and out['type']=='prop':
        return t('if','bool',args=[out,BT,BF])
    return out


def inspect_program(n,p,signatures,bound=frozenset(),hole=None):
    op,key,ty,domain,symbol,children=n
    if op=='label':
        return inspect_program(children[0],p,signatures,bound,hole)
    if op=='unexpanded-source-concat':
        check(p['op']=='input' and p['type']==ty and p['key']=='P_source_child', 'whole-child handle')
        check(p['input_scope']=='source-binding-environment' and p['imports']==
              'complete child profile: body, contracts, terms, effects, free and bound identities',
              'whole-child scope/obligations retained')
        return 0,Counter({p['key']:1}),Counter(input=1)
    iscall=op in ['call','deref'] or (op=='identifier' and symbol)
    expected_op='application' if iscall else op
    check(p['op']==expected_op, 'program constructor correspondence')
    check(p['key']==key, 'program binding/symbol identity')
    if op=='assert':
        check(not p['args'] and p['type']=='unit','assertion program shell')
        term_record(p['attached_term'],projection(children[0],signatures,'prop'))
        term_scope(p['attached_term']['tree'],bound)
        return 1,Counter(),Counter({'assert':1,'attached_terms':1})
    check(len(children)==len(p['args']),'all program child occurrences retained')
    inv=Counter({expected_op:1}); coeff=Counter()
    if iscall:
        sig=signatures[key]
        check(sig['route']!='logic-only','resolved program binding exists')
        check(len(children)==len(sig['arg_types']),'program saturation')
        check(p['type']==('bool' if sig['result_type']=='prop' else sig['result_type']),'program result from declaration')
        check(p['formal_contract']==key and p['proxy_actual_slots']==len(children),'formal contract/proxy slots retained')
        for child,expected in zip(p['args'],sig['arg_types']):
            check(expected=='any' or child['type']==expected,'program actual type')
        count=2+2*len(children);inv['call:'+key]+=1;inv['proxy_actual_slots']+=len(children)
    else:
        check(p['type']==ty,'direct program type')
        count=2 if op in ['and','or'] else 3 if op=='not' else 1
    if op=='identifier' and key.startswith('tmp:'):
        check(key in bound,'temporary use is in caller/local binding scope')
    if op=='binding':
        check(key.startswith('tmp:') and key not in bound,'fresh generated binding key')
    for i,(cn,cp) in enumerate(zip(children,p['args'])):
        scope=bound|{key} if op=='binding' and i==1 else bound
        c,cs,iv=inspect_program(cn,cp,signatures,scope,hole)
        count+=c;coeff.update(cs);inv.update(iv)
    return count,coeff,inv


def inspect_conversion(d,signatures):
    case=d['parameters']; nodes=graph(d['native']); root=d['native']['root']
    child_nodes=graph(d['source_child']); eid=d['source_child']['root']
    child=native(child_nodes,eid)
    all_nodes={}
    records=[d['native'],d['source_child']]+list(d['pending_before'].values())+list(d['pending_after'].values())
    for who in ['source','target']:
        records += [d[who+'_shape'][which] for which in ['first','last']]
    for record in records:
        for uid,node in graph(record).items():
            check(uid not in all_nodes or all_nodes[uid]==node,'same native identity has same full record across views')
            all_nodes[uid]=node
    bounds={}
    for who in ['source','target']:
        shape=d[who+'_shape']
        check(shape['static']==case['static_'+who], 'shape/control agreement')
        for which in ['first','last']:
            bn=graph(shape[which]);bounds[who,which]=native(bn,shape[which]['root'])
    ss,st=case['static_source'],case['static_target'];mode=case['mode']
    check(d['source_shape']['identity']!=d['target_shape']['identity'],'retained diagrams use differing type identities')
    new_source_binding=case['input'] in ['complex','pending']
    outer=nodes[root]
    if new_source_binding:
        check(outer['op']=='binding' and outer['children'][0]==eid,'complex/pending source evaluated once')
        av=N('identifier','map' if ss else 'string',key=outer['key'])
        split=nodes[outer['children'][1]]
    else:
        av=child;split=outer
    check(split['op']=='binding','mandatory split binding')
    bv=N('identifier','map',key=split['key'])
    attr=lambda which: bounds['source',which] if ss else N('call','int',av,key='String.'+which)
    mapped=av if ss else N('call','map',av,key='String.to_array',domain=mode)
    if case['sliding']:
        check(st,'ordinary sliding target is static')
        mapped=N('call','map',mapped,attr('first'),bounds['target','first'],key='Array.slide',domain=mode)
    value=bv if st else N('call','string',bv,attr('first'),attr('last'),key='String.of_array',domain=mode)
    if case['need_check'] and mode=='prog':
        if st:
            lf,ll,rf,rl=attr('first'),attr('last'),bounds['target','first'],bounds['target','last']
            check_tree=N('if','bool',N('call','bool',lf,ll,key='Int.<='),
                N('and','bool',N('call','bool',rf,rl,key='Int.<='),
                  N('call','bool',N('call','int',ll,lf,key='Int.-'),N('call','int',rl,rf,key='Int.-'),key='=',domain='pred'),domain='pred'),
                N('call','int',rl,rf,key='Int.<'),domain='pred')
        else:
            check_tree=N('call','bool',bounds['target','first'],bounds['target','last'],attr('first'),attr('last'),key='String.dynamic_property',domain='pred')
        value=N('sequence','map' if st else 'string',N('assert','unit',check_tree,domain='prog'),value,domain='prog')
    expected=N('binding','map' if st else 'string',N('label','map',mapped,domain=mode),value,key=split['key'],domain=mode)
    if new_source_binding:
        expected=N('binding','map' if st else 'string',child,expected,key=outer['key'],domain=mode)
    check(native(nodes,root)==expected,'complete independent source constructor row')
    check(d['pending_before']==d['pending_after'],'caller pending entries preserved')
    pending={};created={}
    for event in d['construction_events']:
        action,uid,*rest=event
        if action=='create':
            check(uid not in created,'fresh pending entry')
            check(all_nodes[uid]['op']=='identifier' and all_nodes[uid]['key']=='tmp:'+str(uid),
                  'temporary native identity/key agrees with map')
            check(rest[0] in all_nodes,'pending definition is retained')
            pending[uid]=rest[0];created[uid]=rest[0]
        elif action=='consume':
            check(pending.pop(uid,None)==rest[0],'exact pending entry consumed')
        elif action=='reuse':
            check(uid not in pending and nodes[uid]['op'] in ['identifier','deref'],'cheap nonpending node reused')
        elif action=='no-binding':
            check(uid not in pending,'no fictitious binding')
        else:raise AssertionError('unrecognized event')
    check(pending=={int(k):x['root'] for k,x in d['pending_after'].items()},'full pending event replay')
    def occurrences(uid):return int(uid==eid)+sum(occurrences(c) for c in nodes[uid]['children'])
    multiplicity=occurrences(root)
    check(multiplicity==case['child_occurrences'],'source occurrence count')
    check(multiplicity==(1 if new_source_binding or ss else 1+int(case['sliding'])+2*int(not st)+
                        ((4 if st else 2) if case['need_check'] and mode=='prog' else 0)),'independent repeated-use count')
    check(case['source_bindings']==1+int(new_source_binding),'binding count')
    incoming=frozenset('tmp:'+k for k in d['pending_before'])
    if mode=='prog':
        c,coeff,inv=inspect_program(expected,d['program'],signatures,incoming)
        check(not coeff and c==case['typed_expression_nodes_upper'],'resolved expression-node envelope')
        check(dict(inv)==case['program_inventory'],'program occurrence inventory')
    else:
        term_record(d['logical_profile'],projection(expected,signatures))
        term_scope(d['logical_profile']['tree'],incoming)
        check({k:v for k,v in d['logical_profile'].items() if k!='tree'}==case['logical_profile'],'case lexical summary')


def main():
    started=time.perf_counter()
    retained=json.loads((HERE/'inputs.json').read_text())
    check(retained['author_commit']==AUTHOR,'exact author target')
    expected_files={PACKET+x for x in ['README.md','algebra.py','check.py','identity.json','profiles.json.gz','result.json','round.json','sources.tar.gz']}
    expected_files.add('docs/research/retained-main-construction-profile.md')
    check(set(retained['author_files'])==expected_files,'all nine author files pinned')
    for path,ident in retained['author_files'].items():
        check(identity(blob(path))==ident,'author file identity')
        check((ROOT/path).read_bytes()==blob(path),'imported author file identity')
    meta=read(PACKET+'identity.json')
    for row in meta['providers']:
        check(hashlib.sha256(blob(row['path'])).hexdigest()==row['sha256'],'provider identity')
    copied=archive(PACKET+'sources.tar.gz')
    check(hashlib.sha256(blob(PACKET+'sources.tar.gz')).hexdigest()==meta['sources_sha256'],'copied archive identity')
    check(set(copied)=={r['path'] for r in meta['sources']},'complete copied source inventory')
    for row in meta['sources']:
        data=copied[row['path']]
        check(identity(data)=={k:row[k] for k in ['bytes','sha256']},'complete copied source member')
        check(data==archive(row['provider'])[row['provider_member']],'source reattachment to original provider')
    for row in retained['source_spans']:
        data=archive(row['archive'])[row['member']]
        check(identity(data)==row['source_identity'],'supplementary source identity')
        lines=data.splitlines(keepends=True)
        for part in row['spans']:
            lo,hi=part['first'],part['last']
            check(1<=lo<=hi<=len(lines),'strict reviewed span endpoints')
            check(identity(b''.join(lines[lo-1:hi]))==part['identity'],'reviewed source span')
    for path,ident in retained['accepted_fixed_files'].items():
        check(identity(blob(path))==ident,'fixed tranche unchanged by continuation')

    profile=json.loads(gzip.decompress(blob(PACKET+'profiles.json.gz')))
    signatures=profile['primitive_catalogue'];recipes=expected_contracts()
    check(set(signatures)==set(recipes) and len(recipes)==43,'source-attached primitive inventory')
    for name,(args,ty,route,reset,pre,post,definition,residual) in recipes.items():
        s=signatures[name]
        check((s['symbol'],s['arg_types'],s['result_type'],s['route'],s['reset'])==(name,args,ty,route,reset),'primitive signature and effect route')
        check(len(s['pre'])==len(pre),'explicit precondition list')
        for actual,want in zip(s['pre'],pre):term_record(actual,want)
        check(s['closed_post_epsilon']==int(post is not None),'closed-post epsilon charge')
        for field,want in [('opened_post',post),('extracted_definition',definition),('residual_upper',residual)]:
            if want is None:check(s[field] is None,'no unsupported extraction '+name+'/'+field)
            else:term_record(s[field],want)
        if name=='Discrete.bool_eq':check('not classified' in s['extraction_basis'],'raw conditional scope retained')
    expected_cases=set()
    for ss,st,sliding,need,mode in itertools.product([False,True],[False,True],[False,True],[False,True],['prog','term']):
        if sliding and not st:continue
        for kind in ['identifier','complex','pending']+(['deref'] if ss else []):
            expected_cases.add((ss,st,sliding,need,mode,kind))
    seen=set()
    check(len(profile['diagrams'])==len(profile['cases'])==84,'complete retained control partition')
    for case,d in zip(profile['cases'],profile['diagrams']):
        check(case==d['parameters'],'diagram/input case agreement')
        key=tuple(case[k] for k in ['static_source','static_target','sliding','need_check','mode','input'])
        check(key not in seen,'unique branch case');seen.add(key)
        inspect_conversion(d,signatures)
    check(seen==expected_cases,'all declared branch configurations accounted')
    supplied=profile['supplied_child_interface'];ns=graph(supplied['native'])
    c,coeff,_=inspect_program(native(ns,supplied['native']['root']),supplied['program'],signatures)
    check(c==supplied['expression_nodes']['constant']==24,'supplied-child wrapper expression cost')
    check(dict(coeff)==supplied['expression_nodes']['coefficients']=={'P_source_child':1},'whole child imported once')
    check('complete independent derivation' in supplied['obligation'],'child obligation stays open')
    report=dict(status='pass',author_commit=AUTHOR,checks=CHECKS,author_files=len(retained['author_files']),
                providers=len(meta['providers']),complete_copied_sources=len(copied),
                reviewed_source_members=len(retained['source_spans']),
                accepted_fixed_files=len(retained['accepted_fixed_files']),
                reviewed_source_spans=sum(len(r['spans']) for r in retained['source_spans']),
                signatures=len(signatures),conversion_cases=len(seen),term_records=TERM_RECORDS,
                native_occurrences_checked=NATIVE_OCCURRENCES,supplied_child_examples=1,
                elapsed_seconds=time.perf_counter()-started,platform=platform.platform(),
                author_or_predecessor_module_imports=0,native_runs=0,Main_U_H_complete=False,issue178_complete=False)
    (HERE/'audit-result.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))


if __name__=='__main__':main()

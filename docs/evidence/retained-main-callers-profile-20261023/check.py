#!/usr/bin/env python3
"""Focused offline evidence: source identities, caller diagrams and U/H join.

No compiler/prover/target/Lean execution; no replay of accepted predecessors.
"""
import argparse
from dataclasses import asdict
import gzip,hashlib,itertools,json,platform,tarfile,time
from pathlib import Path
import body,callers,source as s,terms,typed
base=callers.base
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
COUNT=0


def check(test,message):
    global COUNT
    if not test: raise AssertionError(message)
    COUNT+=1


def fails(fn,message):
    try: fn()
    except (ValueError,KeyError): check(True,message);return
    raise AssertionError('accepted invalid case: '+message)


def digest(data): return hashlib.sha256(data).hexdigest()


def identities():
    manifest=json.loads((HERE/'identity.json').read_text())
    for p in manifest['providers']:
        check(digest((ROOT/p['path']).read_bytes())==p['sha256'],'provider '+p['path'])
    with tarfile.open(HERE/'sources.tar.gz') as archive:
        check(set(archive.getnames())=={p['path'] for p in manifest['sources']},'complete member set')
        for p in manifest['sources']:
            data=archive.extractfile(p['path']).read()
            check(len(data)==p['bytes'] and digest(data)==p['sha256'],'complete source '+p['path'])
            with tarfile.open(ROOT/p['provider']) as upstream:
                check(data==upstream.extractfile(p['provider_member']).read(),'source corresponds '+p['path'])
        for span in manifest['spans']:
            data=archive.extractfile(span['path']).read().splitlines(keepends=True)
            text=b''.join(data[span['first']-1:span['last']])
            check(digest(text)==span['sha256'],'review span '+span['claim'])
    return dict(source_files=len(manifest['sources']),providers=len(manifest['providers']),spans=len(manifest['spans']))


def walk(t):
    yield t
    for a in t.args: yield from walk(a)


def native_record(root):
    nodes={n.uid:n for n in walk(root)}
    return dict(root=root.uid,nodes=[dict(id=n.uid,op=n.op,type=n.ty,key=n.key,domain=n.domain,
                symbol_identifier=n.symbol_identifier,children=[a.uid for a in n.args]) for n in nodes.values()])


def lexical(t,w):
    if t.op=='var': return w[t.key]
    if t.op=='let':
        d=lexical(t.args[0],w)
        return 1+d+lexical(t.args[1],w|{t.key:d})
    if t.op in {'forall','exists','epsilon'}:
        return 1+sum(lexical(a,w|{t.key:1}) for a in t.args)
    return 1+sum(lexical(a,w) for a in t.args)


def check_term(t):
    c,vs=terms.affine(t)
    check(c>=0 and all(x>0 for x in vs.values()),'positive affine terms')
    for scale in (1,3,10**30):
        w={key:scale*(i+1) for i,key in enumerate(sorted(vs))}
        check(lexical(t,w)==c+sum(v*w[key] for key,v in vs.items()),'lexical binder expansion')


def fixed_contracts():
    accepted=json.loads((HERE.parent/'retained-main-typed-profile-20261023/selected-contracts.json').read_text())
    profiles=terms.api_profiles()
    for symbol,d in profiles.items():
        old=accepted[symbol[4:]];sig=d['signature'];mapping={name:f'a{i}' for i,(name,_) in enumerate(old['formals'])}
        c,vs=terms.affine(sig.post)
        check(c==old['post_lexical']['constant'],'immutable API constant')
        check(dict(vs)=={mapping.get(k,k):v for k,v in old['post_lexical']['coefficients'].items()},'immutable API coefficients')
        check_term(sig.post)
        for t in sig.pre: check_term(t)
        if d['definition'] is not None:
            check_term(d['definition']);check_term(d['residual'])
        check(len(d['reads'])==({'put':11,'put_line':11,'reject':7}.get(symbol[4:],0)),'typed API read closure')
        check(len(d['writes'])==({'put':11,'put_line':11,'reject':7}.get(symbol[4:],0)),'typed API writes')
    return profiles


def litshape(name,length):
    return s.Shape(name,True,s.Bound('constant','1'),s.Bound('constant',str(length)),length)


def value_lit(name,length,expected=None):
    return s.Value('literal',key=name,shape=litshape(name,length),expected=expected)


def intval(n): return s.Value('integer',key=str(n))


def name(n,expected=None): return s.Value('name',key=n,expected=expected)


def fixtures():
    for count in (1,2,7):
        yield 'null-'+str(count),[],[s.Statement('null') for _ in range(count)]
    for mutable,policy in itertools.product((False,True),('named','well-formed')):
        sh=litshape('literal:static',2)
        d=s.Declaration(s.Object('S','string',mutable,sh,policy),value_lit('literal:static',2),not mutable)
        statements=[s.Statement('call',key='put_line',values=(name('S',s.STANDARD_STRING),))]
        if mutable: statements.insert(0,s.Statement('assign',key='S',values=(value_lit('literal:static',2),)))
        yield f'static-{mutable}-{policy}',[d],statements
    for guarded,split in itertools.product((False,True),(False,True)):
        d=s.Declaration(s.Object('D','string',False,s.STANDARD_STRING),
            s.Value('query',(value_lit('literal:default',2,s.STANDARD_STRING),),key='first_or_default',guarded=guarded),True)
        decls=[d]
        target='D'
        if split:
            obj=s.Object('M','string',True,s.STANDARD_STRING,bounds=(s.Bound('to_rep','M:first'),s.Bound('to_rep','M:last')))
            decls.append(s.Declaration(obj,name('D')));target='M'
        length=s.Value('scalar_compare',(s.Value('length',key=target),intval(2)),key='=')
        valid=s.Value('query',key='input_is_valid')
        condition=s.Value('and',(valid,length),warn=True)
        output=s.Statement('call',key='put',values=(name(target),))
        no=s.Statement('call',key='reject')
        statements=[s.Statement('if',values=(condition,),bodies=((output,),(no,)),warn=(True,True))]
        if split: statements.append(s.Statement('assign',key='M',values=(name('D'),),check_lengths=True))
        yield f'input-{guarded}-{split}',decls,statements
    for op in ('+','-','*','neg','pos'):
        args=(name('N'),intval(2)) if op in {'+','-','*'} else (name('N'),)
        v=s.Value(op,args,range_symbol='Standard.Integer.range_check')
        obj=s.Object('N','int',True)
        conds=tuple(s.Value('scalar_compare',(v,intval(1)),key=cmp) for cmp in ('=','/=','<','<=','>','>='))
        arms=tuple((s.Statement('assign',key='N',values=(v,)),) for _ in conds)+((s.Statement('null'),),)
        yield 'scalar-'+op,[s.Declaration(obj,intval(3))],[s.Statement('if',values=conds,bodies=arms)]
    for empty,dynamic,complex_right in itertools.product((False,True),(False,True),(False,True)):
        if empty and dynamic: continue
        ds=[s.Declaration(s.Object('N','int',True),intval(3))]
        if dynamic:
            ds.append(s.Declaration(s.Object('D','string',False,s.STANDARD_STRING),
                s.Value('query',(value_lit('literal:def',1,s.STANDARD_STRING),),key='first_or_default')))
            left=name('D')
        else: left=value_lit('literal:left',0 if empty else 2)
        right=(s.Value('image',(name('N'),),key='11') if complex_right else value_lit('literal:right',1))
        concat=s.Value('concat',(left,right),expected=s.STANDARD_STRING)
        compare=s.Value('string_compare',(concat,name('D') if dynamic else value_lit('literal:cmp',2)),key='/=')
        yield f'concat-{empty}-{dynamic}-{complex_right}',ds,[s.Statement('if',values=(compare,),
            bodies=((s.Statement('call',key='put',values=(concat,)),),(s.Statement('null'),)))]
    for depth,captures,reverse,warn in itertools.product((1,2,3),(0,1,2),(False,True),(False,True)):
        obj=s.Object('N','int',True)
        leaf=s.Statement('assign',key='N',values=(intval(1),))
        current=(leaf,)
        for level in reversed(range(depth)):
            low=s.Value('+',(name('N'),intval(level)),range_symbol='Standard.Integer.range_check')
            high=intval(level+5)
            caps=tuple(s.Declaration(s.Object(f'capture:{level}:{i}','int',False),v,True)
                       for i,v in enumerate((low,high)[:captures]))
            current=(s.Statement('loop',values=(low,high),bodies=(current,),key='index:'+str(level),
                    captures=caps,reverse=reverse,warn=(warn,warn),roots=(('N','entire'),)),)
        yield f'loop-{depth}-{captures}-{reverse}-{warn}',[s.Declaration(obj,intval(1))],list(current)
    out=s.Statement('call',key='put_line',values=(value_lit('literal:out',1,s.STANDARD_STRING),))
    roots=tuple((k,'entire') for k in ('Silver_io__written_bytes.written_bytes',
        'Silver_io__written_count.written_count','Silver_io__flushed.flushed','Silver_io__succeeded.succeeded'))
    yield 'loop-output',[],[s.Statement('loop',values=(intval(1),intval(2)),bodies=((out,),),key='I',roots=roots)]


def diagram_checks():
    records={};nulls={}
    for label,ds,ss in fixtures():
        f=s.Fold();native,program=f.main(ds,ss)
        derivation=typed.Derivation(f.signatures,f.apis).main(program,f.loop_count)
        a=derivation['accounting']
        check(a['nh']==1+2*f.loop_count,'one Main and two loop handlers')
        check(a['Delta']==a['nh'] and a['xf']==a['lost']==a['lemma']==a['rlpv']==0,'exception/key family join')
        check(a['U_upper']==a['U0_upper']+a['nv_upper']+a['nf_upper']+a['tr_upper']+a['unit_h'],'U join')
        check(not any(k.startswith('tmp:') for k in derivation['initial_key_superset']),'all emitted temp references scoped')
        check(len(derivation['initial_key_superset'])==len(set(derivation['initial_key_superset'])),'key union not spelling count')
        for contract in derivation['contracts']:
            check(contract['local']['h']==contract['local']['o']==0,'complete local effect/oldie frontier')
            check(len(contract['actuals'])==len(f.signatures[contract['symbol']].arg_types),'complete actual/formal saturation')
        check(derivation['reflow_upper']==3*derivation['kode_upper']+2,'accepted linear reflow transfer')
        for signature in f.signatures.values():
            for term in signature.pre+((signature.post,) if signature.post else ()): check_term(term)
        records[label]=dict(source=dict(declarations=[asdict(d) for d in ds],statements=[asdict(x) for x in ss]),
            native=native_record(native),pending={str(k):v.uid for k,v in f.b.pending.items()},
            context=f.context,profile=derivation)
        if label.startswith('null-'): nulls[int(label[5:])]=derivation['typed_expression_upper']
    check(nulls[1]<nulls[2]<nulls[7],'located null entries retain their unit expressions')
    return records


def seams():
    # Logical Prog Andb inside an Assume: each proposition -> bool adds 3,
    # the outer bool -> proposition adds 2. This is not a logical conjunction.
    f=s.Fold();b=f.b
    for key in ('P','Q'):
        f.signatures[key]=base.Signature(key,('int',),'prop','logic-only',(),None,'seam test')
    p=b.call('P','bool',b.identifier('p','int'),domain='pred')
    q=b.call('Q','bool',b.identifier('q','int'),domain='pred')
    t=body.term(body.and_expression(b,p,q,'prog'),f.signatures,'prop')
    c,vs=terms.affine(t)
    check(c==11 and vs=={'p':1,'q':1},'Andb E0 = 9 + P + Q')
    check_term(t)
    check(body.term(b.node('label','bool',b.node('not','bool',p)),f.signatures,'prop').op=='not','extended label recursion')
    # Optional range checks retain Cany and ignored nontrivial scalar values.
    n=b.call('Int.+','int',callers.constant(b,1),callers.constant(b,2),domain='prog')
    checknode=body.scalar_range_check(b,callers.constant(b,1),callers.constant(b,2),
        callers.constant(b,-9),callers.constant(b,9),low_prog=n,high_prog=n)
    main=body.main_wrapper(b,b.node('unit','unit'),checknode,[])
    p=body.project(main,f.signatures);r=typed.Derivation(f.signatures,f.apis).main(p,0)
    check(r['counts']['any']==1 and r['counts']['internal_k_fun']==2,'range Cany plus two real ignored bodies')
    check(r['accounting']['Delta']==1,'ignored scalar evaluations add no outcomes')
    fails(lambda:body.project(b.node('unsupported','int'),f.signatures),'fail closed native constructor')
    fails(lambda:body.expression_nodes(body.Expr('unsupported','int')),'fail closed typed constructor')
    bad_assignment=body.assign(b,b.identifier('bad-ref','int__ref'),callers.constant(b,'True','bool'))
    fails(lambda:body.project(bad_assignment,f.signatures),'fail closed assignment type mismatch')
    fails(lambda:f.shape(s.Shape('nonstatic-constrained',False,s.Bound('constant','1'),s.Bound('constant','8'))),'String shape premise')
    # A repeated native binding is alpha-renamed per occurrence, not shared by
    # printed tmp spelling. An escaping ignored raise is rejected.
    temp=body.fresh(b,'int');binding=body.let(b,temp,callers.constant(b,7),temp)
    pair=b.node('sequence','int',binding,binding,domain='prog')
    dr=typed.Derivation(f.signatures,f.apis);tree,*_=dr.walk(body.project(pair,f.signatures))
    check(tree['args'][0]['key']!=tree['args'][1]['key'],'per-occurrence alpha renaming')
    bad=body.Expr('unit-cfun','unit',(body.Expr('raise','unit',key='escape'),),terms=(base.TRUE,))
    fails(lambda:typed.Derivation(f.signatures,f.apis).walk(bad),'Cfun escaping raises cannot be erased')
    ff=s.Fold()
    ff.declaration(s.Declaration(s.Object('N','int',True),intval(1)))
    invalid_loop=s.Statement('loop',values=(intval(1),intval(2)),
        bodies=((s.Statement('assign',key='N',values=(intval(1),)),),),key='I',roots=(('N','not-written'),))
    fails(lambda:ff.statement(invalid_loop),'ordinary whole write cannot select preservation-only frame')
    return dict(range_check_profile=r,andb=terms.record(t))


def main():
    parser=argparse.ArgumentParser();parser.add_argument('--write',action='store_true');args=parser.parse_args()
    started=time.monotonic();identity=identities();fixed_contracts();records=diagram_checks();extra=seams()
    payload=json.dumps(dict(diagrams=records,seams=extra),sort_keys=True,default=lambda x:asdict(x)).encode()
    if args.write:
        (HERE/'profiles.json.gz').write_bytes(gzip.compress(payload,mtime=0))
    else:
        check(gzip.decompress((HERE/'profiles.json.gz').read_bytes())==payload,'retained complete diagrams')
    result=dict(status='pass',checks=COUNT,diagrams=len(records),**identity,
        platform=platform.platform(),elapsed_seconds=time.monotonic()-started,
        executions='offline Python only; no native compiler/prover/target/Lean; no predecessor checker replay')
    if args.write: (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))


if __name__=='__main__':main()

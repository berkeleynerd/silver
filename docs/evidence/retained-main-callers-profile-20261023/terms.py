"""Lexical terms and immutable selected-API contract imports.

Quantifier/epsilon binders are logical variables. They are not program-variable
keys; let definitions retain their lexical weight at every use.
"""
from collections import Counter
from pathlib import Path
import json
import callers
base = callers.base


def affine(t):
    if t.op == 'var':
        return 0, Counter({t.key:1})
    if t.op == 'let':
        ac,av = affine(t.args[0]); bc,bv = affine(t.args[1])
        bv = bv.copy(); uses = 1+bv.pop(t.key,0)
        return 1+uses*ac+bc, bv+Counter({k:uses*v for k,v in av.items()})
    c,vs = 1,Counter()
    for a in t.args:
        ac,av = affine(a); c += ac; vs.update(av)
    if t.op in {'forall','exists','epsilon'}:
        c += vs.pop(t.key,0)
    return c,vs


def record(t):
    c,vs = affine(t)
    return dict(tree=base.tree_record(t),constant=c,coefficients=dict(sorted(vs.items())),
                unit_weight=c+sum(vs.values()))


def rename(t, mapping):
    if t.op == 'var':
        return base.var(mapping.get(t.key,t.key),t.ty)
    if t.op in {'let','forall','exists','epsilon'} and t.key in mapping:
        raise ValueError('substitution would capture a logical binder')
    return base.Term(t.op,tuple(rename(a,mapping) for a in t.args),t.key,t.ty)


def fixed_term(t, formal_map):
    op = t['op']; args = tuple(fixed_term(a,formal_map) for a in t['args'])
    if op == 'var':
        return base.var(formal_map.get(t['key'],t['key']),t.get('type','any'))
    if op in {'integer','truth','constant'}:
        key = (str(t['value']) if op=='integer' else
               (('true' if t['value']==0 else 'false') if t.get('domain')==3 else
                ('True' if t['value']==0 else 'False')) if op=='truth' else t['symbol'])
        return base.atom(key,'prop' if op=='truth' and t.get('domain')==3 else t.get('type','any'))
    if op in {'application','projection'}:
        return base.app(t['symbol'],*args,ty=t.get('type') or 'any')
    if op == 'connection':
        # Why's EW_And/EW_Or/EW_Equivalent/EW_Imply/EW_And_Then/EW_Or_Else.
        name = {1:'and',2:'or',3:'iff',4:'implies',5:'and',6:'or'}[t['connector']]
        out = args[-1]
        for a in reversed(args[:-1]):
            out = base.connective(name,a,out)
        return out
    if op in {'not','if'}:
        return base.connective(op,*args)
    if op == 'let':
        return base.Term('let',args,t['binder'],args[1].ty)
    if op == 'forall':
        out = args[0]
        # The selected template has exactly one quantified variable. Keeping
        # each binder separate also covers the general source representation.
        for key in reversed(t['binders']):
            out = base.Term('forall',(out,),key,'prop')
        return out
    raise ValueError('uncovered immutable fixed term '+op)


def api_profiles():
    path = Path(__file__).resolve().parents[1]/'retained-main-typed-profile-20261023/selected-contracts.json'
    raw = json.loads(path.read_text())
    out = {}
    for name,d in raw.items():
        formal_map = {key:f'a{i}' for i,(key,_) in enumerate(d['formals'])}
        pre,post = fixed_term(d['pre'],formal_map),fixed_term(d['post'],formal_map)
        result = {'input_is_valid':'bool','first_or_default':'string'}.get(name,'unit')
        args = ('unit',) if name in {'input_is_valid','reject'} else ('string',)
        signature = base.Signature('API.'+name,args,result,'selected API explicit contract',
                                   (pre,),post,'immutable author 3040c6736d')
        # create_cty adds the free post/pre variables to reads. In the selected
        # procedures all four concrete output keys occur in their post.
        free = set(affine(pre)[1]) | set(affine(post)[1])
        free -= {'result'} | set(formal_map.values())
        reads = set(d['reads']) | free
        extraction = d['normal_post_extraction']
        out[signature.symbol] = dict(signature=signature,reads=reads,writes=set(d['writes']),
            oldies=(),raises=(),definition=None if extraction is None else
            fixed_term(extraction['definition'],formal_map),residual=None if extraction is None else
            fixed_term(extraction['residual'],formal_map))
    return out

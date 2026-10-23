"""Scoped typed interface and source-derived key/outcome accounting.

This constructs an auditable envelope from resolved source rows; it does not
execute Why3 typing. Application children remain separate definitions and
every contract use has its actual/formal substitution and result slot.
"""
from collections import Counter
import body, terms
base=body.base


def scoped_term(t, free, prefix, bound=None):
    bound={} if bound is None else bound
    if t.op=='var':
        return base.var(bound.get(t.key,free.get(t.key,t.key)),t.ty)
    if t.op=='let':
        key=prefix+':logic:'+t.key
        return base.Term('let',(scoped_term(t.args[0],free,prefix+'.0',bound),
                    scoped_term(t.args[1],free,prefix+'.1',bound|{t.key:key})),key,t.ty)
    if t.op in {'forall','exists','epsilon'}:
        key=prefix+':logic:'+t.key
        return base.Term(t.op,tuple(scoped_term(a,free,prefix+'.'+str(i),bound|{t.key:key})
                                    for i,a in enumerate(t.args)),key,t.ty)
    return base.Term(t.op,tuple(scoped_term(a,free,prefix+'.'+str(i),bound)
                               for i,a in enumerate(t.args)),t.key,t.ty)


def lower_booleans(p):
    args=tuple(lower_booleans(a) for a in p.args)
    true=body.Expr('application','bool',key='bool.True')
    false=body.Expr('application','bool',key='bool.False')
    if p.op=='and': return body.Expr('if','bool',(args[0],args[1],false))
    if p.op=='or': return body.Expr('if','bool',(args[0],true,args[1]))
    if p.op=='not': return body.Expr('if','bool',(args[0],false,true))
    return body.Expr(p.op,p.ty,args,p.key,p.terms,p.detail)


class Derivation:
    def __init__(self,signatures,apis):
        self.signatures=signatures; self.apis=apis
        self.keys=set(['Main:unit-formal']); self.fields=set()
        self.counts=Counter(); self.term_uses=[]; self.contract_uses=[]

    def term(self,t,scope,path):
        result=scoped_term(t,scope,path)
        free=set(terms.affine(result)[1])
        self.keys.update(free)
        self.term_uses.append(dict(site=path,term=terms.record(result)))
        return result

    def contract(self,symbol,actuals,path):
        s=self.signatures[symbol]
        mapping={f'a{i}':v for i,v in enumerate(actuals)}
        mapping['result']=path+':result'
        # Result is an opened logical post binder. Its eventual program pv is
        # supplied by k_expr or the counted k_fun/trace creation families.
        pres=[scoped_term(t,mapping,path) for t in s.pre]
        post=scoped_term(s.post,mapping,path) if s.post is not None else None
        api=self.apis.get(symbol)
        if api:
            definition=api['definition']; residual=api['residual']
            reads=set(api['reads']); writes=set(api['writes'])
        else:
            split=base.split_post(s.post) if s.post is not None else None
            definition,residual=split if split else (None,None)
            reads=set(); writes=set()
        reads.update(actuals)
        self.keys.update(reads|writes)
        # Typed effects store their named mutable fields as pvsymbols too.
        # Per-root tokens intentionally overcount shared reference field
        # symbols. Projections/constructors retain their own source field.
        self.fields.update('effect-field:'+key for key in writes)
        if symbol.endswith('__content') or symbol.endswith('__mkref'):
            self.fields.add('field:'+symbol.replace('__mkref','__content'))
        # Also retain original signature formal keys. Instantiation replaces
        # these in the applied cty; retaining them here is a safe union bound
        # for a consumer that traverses the referenced rsymbol's contract.
        for i in range(len(actuals)): self.keys.add('formal:'+symbol+':'+str(i))
        local=dict(h=0,o=0,p=int(bool(pres)),v=int(bool(writes) or s.reset))
        record=dict(site=path,symbol=symbol,actuals=actuals,result=mapping['result'],
            pre=[terms.record(t) for t in pres],opened_post=terms.record(post) if post else None,
            closed_post_epsilon=int(post is not None),reads=sorted(reads),writes=sorted(writes),
            reset=s.reset,local=local,
            definition=terms.record(scoped_term(definition,mapping,path)) if definition else None,
            residual=terms.record(scoped_term(residual,mapping,path)) if residual else None)
        self.contract_uses.append(record)
        return record,reads,writes

    def walk(self,p,path='Main',scope=None):
        scope={} if scope is None else scope
        op=p.op; self.counts[op]+=1
        out=dict(op=op,type=p.ty,site=path,key=p.key,args=[])
        reads=set(); writes=set(); raises=set(); e=1; k=1
        if op=='variable':
            key=scope.get(p.key,p.key); self.keys.add(key); reads.add(key); out['key']=key
            if p.ty.endswith('__ref'):
                self.fields.add('root-field:'+key)
        elif op=='constant': pass
        elif op=='binding':
            if len(p.args)!=2: raise ValueError('binding arity')
            key=path+':bound'; self.keys.add(key); out['key']=key
            self.counts['program_binding_slots']+=1
            a,ar,aw,ax,ae,ak=self.walk(p.args[0],path+'.def',scope)
            z,zr,zw,zx,ze,zk=self.walk(p.args[1],path+'.body',scope|{p.key:key})
            out['args']=[a,z]; reads=ar|(zr-{key}); writes=aw|zw; raises=ax|zx
            e=1+ae+ze; k=1+ak+zk
        else:
            child_data=[self.walk(a,path+'.'+str(i),scope) for i,a in enumerate(p.args)]
            out['args']=[x[0] for x in child_data]
            for _,r,w,x,_,_ in child_data:
                reads.update(r);writes.update(w);raises.update(x)
            ce=sum(x[4] for x in child_data); ck=sum(x[5] for x in child_data)
            if op=='application':
                base.validate_call(p.key,p.args,self.signatures)
                actuals=[path+':actual:'+str(i) for i in range(len(p.args))]
                self.keys.update(actuals); self.counts['argument_proxy_slots']+=len(actuals)
                contract,r,w=self.contract(p.key,actuals,path)
                out['contract']=contract; reads.update(r);writes.update(w)
                out['evaluation']='right-to-left; each actual once; optional proxy at each slot'
                e=2+2*len(actuals)+ce
                k=len(actuals)+ck+3+2*contract['local']['p']+2*contract['local']['v']
                self.counts['trace_slots']+=1
            elif op=='assignment':
                if len(p.args)!=2 or p.args[0].op!='variable':
                    raise ValueError('whole-object assignment source row required')
                key=scope.get(p.args[0].key,p.args[0].key); writes.add(key)
                actuals=[path+':assignment:'+str(i) for i in range(2)]
                self.keys.update(actuals);self.fields.add('field:'+p.key)
                self.counts['assignment_proxy_slots']+=2
                out['actuals']=actuals;out['evaluation']='value before reference'
                e=3+ce;k=2+ck+3
            elif op in {'sequence','if','raise','try','while','unit-cfun'}:
                if op=='sequence':
                    if len(p.args)!=2 or p.args[0].ty!='unit' or p.ty!=p.args[1].ty:
                        raise ValueError('sequence first child must have Unit type')
                    # typing:1126-1130 -> DElet (_, RKnone, e1, e2), then
                    # dexpr:1719-1730 -> expr:721-724 creates a fresh Unit pv.
                    # This anonymous LDvar never becomes visible in e2's
                    # source scope, but k_expr uses it as e1's result key.
                    key=path+':sequence-bound';self.keys.add(key);out['key']=key
                    out['lowering']=dict(constructor='LDvar',type='unit',
                        definition=out['args'][0]['site'],context=out['args'][1]['site'])
                    self.counts['program_binding_slots']+=1
                    self.counts['sequence_binding_slots']+=1
                    e=1+ce;k=1+ck
                elif op=='if':
                    if len(p.args)!=3 or p.args[0].ty!='bool' or p.args[1].ty!=p.args[2].ty:
                        raise ValueError('typed conditional shape')
                    self.counts['condition_proxy_slots']+=1;e=1+ce;k=5+ck
                elif op=='raise': raises.add(p.key);e=1+ce;k=2+ck
                elif op=='try':
                    if len(p.args)!=2: raise ValueError('singleton unit handler required')
                    # Only the first child is protected; handler exceptions
                    # would still escape. The current handlers are unit.
                    raises=(child_data[0][3]-{p.key})|child_data[1][3]
                    self.counts['handler_slots']+=1;e=1+ce;k=1+ck
                elif op=='while':
                    if p.args[0].op!='application' or p.args[0].key!='bool.True':
                        raise ValueError('ordinary lowering requires literal True test')
                    self.counts['loop_havoc_slots']+=int(bool(writes))
                    e=1+ce;k=6+2*int(bool(writes))+child_data[1][5]
                    # k_expr does not visit the syntactic True test. Its
                    # contract/key envelope above remains a safe overcount.
                else:
                    if p.ty!='unit' or raises:
                        raise ValueError('ordinary ignored child must return unit and have no escaping raises')
                    self.counts['internal_k_fun']+=1;self.counts['trace_slots']+=1
                    out['contract']=dict(pre=[],post=[terms.record(base.TRUE)],h=0,o=0,p=0,
                                         v=int(bool(writes)),oldies=[],raises=[])
                    e=2+ce;k=8+2*int(bool(writes))+ck
            elif op in {'assert','check','assume'}:
                if len(p.terms)!=1: raise ValueError('assertion term arity')
                t=self.term(p.terms[0],scope,path+'.predicate')
                reads.update(terms.affine(t)[1]);out['terms']=[terms.record(t)]
                e=1;k=1 if op=='assume' else 3
            elif op=='any':
                if p.ty!='unit' or len(p.terms)!=2: raise ValueError('ordinary range any contract')
                ts=[self.term(t,scope,path+'.contract'+str(i)) for i,t in enumerate(p.terms)]
                for t in ts: reads.update(terms.affine(t)[1])
                out['contract']=dict(pre=[terms.record(ts[0])],post=[terms.record(ts[1])],
                    h=0,o=0,p=1,v=0,oldies=[],raises=[])
                self.counts['trace_slots']+=1;e=2;k=5
            else: raise ValueError('uncovered typed source interface '+op)
        out['effects']=dict(reads=sorted(reads),writes=sorted(writes),raises=sorted(raises))
        out['typed_expression_upper']=e;out['kode_without_optional_tags_upper']=k
        return out,reads,writes,raises,e,k

    def main(self,p,source_loops):
        tree,reads,writes,raises,e,k=self.walk(lower_booleans(p))
        if raises: raise ValueError('Main has escaping exception '+str(raises))
        nh=self.counts['handler_slots']
        if nh!=1+2*source_loops: raise ValueError('source handler correspondence')
        self.keys.update(self.fields)
        U0=len(self.keys);nv=self.counts['condition_proxy_slots']
        nf=1+self.counts['internal_k_fun'];tr=self.counts['trace_slots']
        # These zeros follow the source frontier, unit-Cfun check above and
        # saturated zero-argument lambdas/any -> LDvar typing branch.
        accounting=dict(U0_upper=U0,nv_upper=nv,nf_upper=nf,tr_upper=tr,
                        xf=0,lost=0,unit_h=nh,lemma=0,rlpv=0,nh=nh,
                        U_upper=U0+nv+nf+tr+nh,Delta=nh,
                        Cfinal='C0 + '+str(nh),H='H0 + '+str(1+nh))
        # Each typed expression may carry one WP/SP tag; each k_fun may carry
        # its additional outer tag. Main's pre/post contributes four nodes.
        kode=k+4+e+nf
        return dict(tree=tree,initial_key_superset=sorted(self.keys),counts=dict(self.counts),
            typed_expression_upper=e,kode_upper=kode,reflow_upper=3*kode+2,
            accounting=accounting,terms=self.term_uses,contracts=self.contract_uses,
            main_contract=dict(unit_formal='Main:unit-formal',pre=[terms.record(base.TRUE)],
                               post=[],effects=dict(reads=sorted(reads),writes=sorted(writes),raises=[]),
                               h=0,o=0,p=1))

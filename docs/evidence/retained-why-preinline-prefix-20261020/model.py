"""Finite source model for the case-free CE formula route; no target execution.

Terms and binders retain object identity, delayed maps, and source closing
shortcuts. Raw logical definitions are decoded separately and are unchanged.
"""
from collections import Counter
from dataclasses import dataclass
from functools import lru_cache
import json
import struct

@dataclass(eq=False)
class Term:
    kind: str
    args: tuple
    ty: object = None
    attrs: frozenset = frozenset()
    loc: object = None
    raw: object = None

@dataclass(eq=False)
class Bind:
    variables: tuple
    free: Counter
    saved: dict
    body: Term
    triggers: tuple = ()
    raw: object = None

class Raw:
    def __init__(self, data):
        self.blocks = {}
        for line in data.splitlines():
            r = json.loads(line); p = r['address']
            assert p not in self.blocks
            self.blocks[p] = r
        self.variables, self.symbols, self.patterns, self.binds = {}, {}, {}, {}
        self.reads = set()

    def fields(self, p, size=None, tag=0):
        r = self.blocks[p]; self.reads.add(p)
        assert r['header'] == int.from_bytes(bytes.fromhex(r['header_hex']), 'little')
        assert r['tag'] == r['header'] & 255 and r['words'] == r['header'] >> 10
        assert r['tag'] == tag and (size is None or r['words'] == size)
        data = bytes.fromhex(r['payload_hex']); assert len(data) == 8*r['words']
        return struct.unpack('<'+'Q'*r['words'], data)

    @lru_cache(None)
    def seq(self, p):
        result, seen = [], set()
        while p != 1:
            assert p not in seen; seen.add(p)
            value,p = self.fields(p,2); result.append(value)
        return tuple(result)

    def mapping(self, p, seen=frozenset()):
        if p == 1: return ()
        assert p not in seen
        l,k,v,r,h = self.fields(p,5); assert h & 1
        rows = self.mapping(l,seen|{p})+((k,v),)+self.mapping(r,seen|{p})
        assert len({k for k,v in rows}) == len(rows)
        return rows

    def string(self,p):
        r=self.blocks[p]; assert r['tag']==252
        data=bytes.fromhex(r['payload_hex'])
        assert data[len(data)-data[-1]-1]==0
        return data[:len(data)-data[-1]-1].decode('utf-8')

    @lru_cache(None)
    def attrs(self,p):
        out=[]
        for a,v in self.mapping(p):
            assert v==1
            s,tag=self.fields(a,2); assert tag&1
            out.append(self.string(s))
        assert len(set(out))==len(out)
        return frozenset(out)

    def ident(self,p):
        s,a,loc,tag=self.fields(p,4); assert tag&1
        return self.string(s),self.attrs(a)

    def variable(self,p):
        if p not in self.variables:
            ident,ty=self.fields(p,2)
            self.variables[p]=(ty,)+self.ident(ident)
        return p

    def symbol(self,p):
        if p not in self.symbols:
            ident,args,value,constr,proj=self.fields(p,5)
            name,attrs=self.ident(ident)
            self.symbols[p]=dict(name=name,attrs=attrs,arity=len(self.seq(args)),
                                 arg_types=self.seq(args),value_type=None if value==1 else self.fields(value,1)[0],
                                 constr=constr>>1,projection=proj>>1,identifier=ident)
        return p

    @lru_cache(None)
    def typevars(self,p):
        n,_=self.fields(p,2); tag=self.blocks[n]['tag']
        if tag==0: return frozenset(self.fields(n,1))
        _,args=self.fields(n,2,1)
        return frozenset().union(*(self.typevars(x) for x in self.seq(args)))

    def integer(self,p):
        if p&1:
            return (p-(1<<64) if p>>63 else p)>>1
        row=self.blocks[p]; assert row['tag']==255
        b=bytes.fromhex(row['payload_hex']); w=struct.unpack('<'+'Q'*(len(b)//8),b)
        count=w[1]&((1<<63)-1); assert 0<count<=len(w)-2
        return (-1 if w[1]>>63 else 1)*sum(x<<(64*i) for i,x in enumerate(w[2:2+count]))

    def constant(self,p):
        q,=self.fields(p,1,0); kind,value=self.fields(q,2)
        assert kind in (1,3,5,7,9)
        return (kind>>1,self.integer(value))

    def binding(self,variables,info,body,triggers=(),token=None):
        if token in self.binds:return self.binds[token]
        free,saved=self.fields(info,2)
        f=Counter({self.variable(v):self.integer(n) for v,n in self.mapping(free)})
        assert all(n>0 for n in f.values())
        sub={self.variable(v):self.term(t) for v,t in self.mapping(saved)}
        result=Bind(tuple(self.variable(v) for v in variables),f,sub,self.term(body),
                    tuple(tuple(self.term(t) for t in group) for group in triggers),token)
        self.binds[token]=result
        return result

    def pattern(self,p):
        if p in self.patterns: return self.patterns[p]
        n,vars,ty=self.fields(p,3)
        variables=tuple(self.variable(v) for v,u in self.mapping(vars))
        if n&1:
            assert n==1; result=('wild',(),variables,1)
        else:
            tag=self.blocks[n]['tag']
            if tag==0:
                v,=self.fields(n,1); result=('var',(self.variable(v),),variables,1)
            elif tag==1:
                s,args=self.fields(n,2,1); args=tuple(self.pattern(x) for x in self.seq(args))
                result=('app',(self.symbol(s),args),variables,1+sum(x[3] for x in args))
            else: raise AssertionError(('unhandled raw pattern',tag))
        self.patterns[p]=result; return result

    @lru_cache(None)
    def term(self,p):
        n,ty,attrs,loc=self.fields(p,4)
        ty=None if ty==1 else self.fields(ty,1)[0]
        attrs=self.attrs(attrs); loc=None if loc==1 else loc
        if n&1:
            assert n in (1,3); kind='true' if n==1 else 'false'; args=()
        else:
            tag=self.blocks[n]['tag']
            sizes=(1,1,2,3,2,2,1,2,3,1); f=self.fields(n,sizes[tag],tag)
            if tag==0:kind,args='var',(self.variable(f[0]),)
            elif tag==1:kind,args='const',self.constant(f[0])
            elif tag==2:kind,args='app',(self.symbol(f[0]),tuple(self.term(t) for t in self.seq(f[1])))
            elif tag==3:kind,args='if',tuple(self.term(t) for t in f)
            elif tag in (4,6):
                v,info,body=self.fields(f[1] if tag==4 else f[0],3)
                b=self.binding((v,),info,body,token=f[1] if tag==4 else f[0])
                kind,args=('let',(self.term(f[0]),b)) if tag==4 else ('eps',(b,))
            elif tag==5:
                branches=[]
                for branch in self.seq(f[1]):
                    ptn,info,body=self.fields(branch,3);pat=self.pattern(ptn)
                    branches.append((pat,self.binding(pat[2],info,body,token=branch)))
                kind,args='case',(self.term(f[0]),tuple(branches))
            elif tag==7:
                vl,info,tr,body=self.fields(f[1],4)
                kind,args='quant',(f[0]>>1,self.binding(self.seq(vl),info,body,tuple(self.seq(g) for g in self.seq(tr)),token=f[1]))
            elif tag==8:kind,args='bin',(f[0]>>1,self.term(f[1]),self.term(f[2]))
            elif tag==9:kind,args='not',(self.term(f[0]),)
        return Term(kind,args,ty,attrs,loc,p)


def children(t,hidden=False):
    k,a=t.kind,t.args
    if k=='app':return a[1]
    if k=='if':return a
    if k=='bin':return a[1:]
    if k=='not':return a
    base=[]
    if k=='let':base=[a[0]];binds=[a[1]]
    elif k=='eps':binds=[a[0]]
    elif k=='quant':binds=[a[1]]
    elif k=='case':base=[a[0]];binds=[b for p,b in a[1]]
    else:return ()
    for b in binds:
        base.append(b.body);base.extend(t for g in b.triggers for t in g)
        if hidden:base.extend(b.saved.values())
    return tuple(base)

@lru_cache(None)
def freevars(t):
    k,a=t.kind,t.args
    if k=='var':return Counter({a[0]:1})
    if k=='let':return freevars(a[0])+a[1].free
    if k=='eps':return a[0].free
    if k=='quant':return a[1].free
    if k=='case':return sum((b.free for p,b in a[1]),freevars(a[0]))
    return sum((freevars(ch) for ch in children(t)),Counter())


def canonical(t,frames=(),depth=0,triggers=False,stats=False):
    """Opened alpha tree; substitution values see remaining outer frames."""
    k,a=t.kind,t.args
    if k=='var':
        v=a[0]
        for i,(bound,saved) in enumerate(frames):
            if v in bound:return ('var',t.ty,('bound',bound[v]))
            if v in saved:return canonical(saved[v],frames[i+1:],depth,triggers,stats)
        return ('var',t.ty,('free',v))
    recur=lambda c:canonical(c,frames,depth,triggers,stats)
    if k=='const':return (k,t.ty,a if stats else (a[1],))
    if k=='app':return (k,t.ty,a[0],tuple(map(recur,a[1])))
    if k in ('if','not'):return (k,t.ty,tuple(map(recur,a)))
    if k=='bin':return (k,t.ty,a[0],tuple(map(recur,a[1:])))
    if k in ('true','false'):return (k,t.ty)
    def opened(b):
        bound={v:depth+i for i,v in enumerate(b.variables)}
        fr=((bound,b.saved),)+frames; d=depth+len(bound)
        body=canonical(b.body,fr,d,triggers,stats)
        trs=tuple(tuple(canonical(x,fr,d,triggers,stats) for x in g) for g in b.triggers) if triggers else ()
        return len(bound),trs,body
    if k=='let':return (k,t.ty,recur(a[0]),opened(a[1]))
    if k=='eps':return (k,t.ty,opened(a[0]))
    if k=='quant':return (k,t.ty,a[0],opened(a[1]))
    if k=='case':return (k,t.ty,recur(a[0]),tuple((p,opened(b)) for p,b in a[1]))
    raise AssertionError(k)

class CE:
    def __init__(self,raw,equality_symbol):
        self.raw=raw;self.variables=dict(raw.variables);self.next_var=-1
        self.equality_symbol=equality_symbol
        self.events=Counter();self.true=Term('true',());self.false=Term('false',())
        self.branch_events=Counter()

    def new(self,k,a,ty=None):return Term(k,tuple(a),ty)
    def fresh(self,v,unused=False):
        ty,name,attrs=self.variables[v]
        if unused and 'id:unused' in attrs:return v
        out=self.next_var;self.next_var-=1
        self.events['unused_copy' if unused else 'binder_open']+=1
        if unused:
            if not any(a.startswith('model_trace:') for a in attrs):attrs=attrs|{'model_trace:'+name}
            attrs=attrs|{'id:unused'};name+="'unused"
        self.variables[out]=(ty,name,attrs)
        return out
    def var(self,v):return self.new('var',(v,),self.variables[v][0])
    def similar(self,s,t):
        if s.kind!=t.kind or s.ty!=t.ty:return False
        k,a,b=s.kind,s.args,t.args
        if k in ('var','const','true','false'):return a==b
        if k=='app':return a[0]==b[0] and len(a[1])==len(b[1]) and all(x is y for x,y in zip(a[1],b[1]))
        if k in ('bin','quant'):return a[0]==b[0] and all(x is y for x,y in zip(a[1:],b[1:]))
        return len(a)==len(b) and all(x is y for x,y in zip(a,b))
    def copy(self,s,t):
        if s is t:return s
        if self.similar(s,t) and not t.attrs and t.loc is None:return s
        return Term(t.kind,t.args,t.ty,s.attrs|t.attrs,s.loc if t.loc is None else t.loc)
    def equal(self,s,t):return canonical(s)==canonical(t)
    def attr_remove(self,t,a):return Term(t.kind,t.args,t.ty,t.attrs-{a},t.loc)
    def attr_add(self,t,a):return Term(t.kind,t.args,t.ty,t.attrs|{a},t.loc)
    def close(self,vs,body,triggers=()):
        free=sum((freevars(t) for g in triggers for t in g),freevars(body).copy())
        for v in vs:free.pop(v,None)
        return Bind(tuple(vs),free,{},body,tuple(triggers))
    def open(self,b):
        vs=tuple(self.fresh(v) for v in b.variables)
        mapping=dict(b.saved);mapping.update((v,self.var(w)) for v,w in zip(b.variables,vs))
        trs=tuple(tuple(self.subst(mapping,t) for t in g) for g in b.triggers)
        body=self.subst(mapping,b.body)
        def close(vs1,trs1,body1):
            if vs1==vs and body1 is body and len(trs1)==len(trs) and all(len(g)==len(h) and all(x is y for x,y in zip(g,h)) for g,h in zip(trs1,trs)):
                return b
            return self.close(vs1,body1,trs1)
        return vs,trs,body,close
    def subst_bind(self,m,b):
        m={v:t for v,t in m.items() if v in b.free}
        if not m:return b
        free=Counter({v:n for v,n in b.free.items() if v not in m})
        for v,t in m.items():
            for x,n in freevars(t).items():free[x]+=n*b.free[v]
        saved={v:self.subst(m,t) for v,t in b.saved.items()}
        saved={**m,**saved} # Extmap.set_union keeps the first map's values.
        return Bind(b.variables,free,saved,b.body,b.triggers)
    def subst(self,m,t):
        if not m:return t
        self.events['substitution_term_entries']+=1
        k,a=t.kind,t.args
        if k=='var':return self.copy(t,m.get(a[0],t))
        if k=='let':out=self.new(k,(self.subst(m,a[0]),self.subst_bind(m,a[1])),t.ty)
        elif k=='eps':out=self.new(k,(self.subst_bind(m,a[0]),),t.ty)
        elif k=='quant':out=self.new(k,(a[0],self.subst_bind(m,a[1])))
        elif k=='case':raise AssertionError('case in CE substitution')
        else:return self.map_plain(lambda x:self.subst(m,x),t)
        return self.copy(t,out)
    def map_plain(self,fn,t):
        k,a=t.kind,t.args
        if k=='app':out=self.new(k,(a[0],tuple(map(fn,a[1]))),t.ty)
        elif k=='if':out=self.new(k,tuple(map(fn,a)),t.ty)
        elif k=='bin':out=self.new(k,(a[0],fn(a[1]),fn(a[2])))
        elif k=='not':out=self.new(k,(fn(a[0]),))
        elif k in ('var','const','true','false'):out=t
        else:raise AssertionError(k)
        return self.copy(t,out)
    def neg(self,t):
        if t.kind=='true':return self.copy(t,self.false)
        if t.kind=='false':return self.copy(t,self.true)
        if t.kind=='not':return self.copy(t,t.args[0])
        return self.new('not',(t,))
    def binary(self,op,a,b,asym=False):
        ka,kb=a.kind,b.kind
        if op==0:
            if ka=='true':return b
            if kb=='true' or ka=='false':return self.attr_remove(a,'asym_split')
            if kb=='false':return b
        elif op==1:
            if ka=='true' or kb=='false':return self.attr_remove(a,'asym_split')
            if kb=='true' or ka=='false':return b
        elif op==2:
            if ka=='true' or kb=='true':return b
            if ka=='false':return self.copy(a,self.true)
            if kb=='false':return self.neg(a)
        elif op==3:
            if ka=='true':return b
            if kb=='true':return a
            if ka=='false':return self.neg(b)
            if kb=='false':return self.neg(a)
        if self.equal(a,b):return self.copy(a,self.true) if op in (2,3) else a
        return self.new('bin',(op,self.attr_add(a,'asym_split') if asym else a,b))
    def iff(self,a,b):return self.binary(3,a,b)
    def conditional(self,c,a,b):
        if c.kind=='true':return a
        if c.kind=='false':return b
        if a.kind=='true':return self.binary(2,self.neg(c),b)
        if a.kind=='false':return self.binary(0,self.neg(c),b,True)
        if b.kind=='true':return self.binary(2,c,a)
        if b.kind=='false':return self.binary(0,c,a,True)
        if self.equal(a,b):return a
        return self.new('if',(c,a,b),a.ty)
    def let_simp(self,e,b,keep):
        v,=b.variables;n=freevars(b.body).get(v,0)
        if n==0 or n==1 or e.kind in ('var','const'):
            self.branch_events['kept_let' if keep else 'eliminated_let']+=1
            if n:self.branch_events['let_substitution']+=1
            sub=dict(b.saved)
            if n:sub[v]=e
            body=self.subst(sub,b.body)
            if keep:
                v=self.fresh(v,True)
                return self.new('let',(e,self.close((v,),body)),body.ty)
            return body
        return self.new('let',(e,b),b.body.ty)
    def quant_simp(self,q,b):
        free=freevars(b.body)
        if all(v in free for v in b.variables):return self.new('quant',(q,b))
        vs,trs,body,_=self.open(b)
        free=freevars(body);vs=tuple(v for v in vs if v in free)
        if not vs:return body
        # check is membership in body free variables, not retained bound list.
        trs=tuple(g for g in trs if all(all(v in free for v in freevars(t)) for t in g))
        return self.new('quant',(q,self.close(vs,body,trs)))
    def map_simp(self,fn,t):
        k,a=t.kind,t.args
        if k=='app' and a[0]==self.equality_symbol and len(a[1])==2:
            x,y=map(fn,a[1]);out=self.true if self.equal(x,y) else self.new('app',(a[0],(x,y)),t.ty)
            if out is self.true:self.branch_events['reflexive_equality']+=1
        elif k=='if':out=self.conditional(*(fn(x) for x in a))
        elif k=='let':
            vs,trs,body,close=self.open(a[1]);out=self.let_simp(fn(a[0]),close(vs,(),fn(body)),False)
        elif k=='quant':
            vs,trs,body,close=self.open(a[1]);mapped=tuple(tuple(fn(x) for x in g) for g in trs)
            out=self.quant_simp(a[0],close(vs,mapped,fn(body)))
        elif k=='bin':out=self.binary(a[0],fn(a[1]),fn(a[2]))
        elif k=='not':out=self.neg(fn(a[0]))
        elif k=='eps':
            vs,trs,body,_=self.open(a[0]);res=fn(body)
            out=t if res is body else self.new('eps',(self.close(vs,res),),t.ty)
        elif k=='case':raise AssertionError('case in CE mapper')
        else:out=self.map_plain(fn,t)
        return self.copy(t,out)
    def remove(self,pol,t):
        self.events['remove_entries']+=1
        k,a=t.kind,t.args; fn=lambda x:self.remove(pol,x)
        if k=='bin' and a[0]==2:out=self.binary(2,self.remove(not pol,a[1]),fn(a[2]))
        elif k=='bin' and a[0]==3:
            ap,an=fn(a[1]),self.remove(not pol,a[1]);bp,bn=fn(a[2]),self.remove(not pol,a[2])
            if self.equal(ap,an) and self.equal(bp,bn):out=self.iff(ap,bp)
            elif pol:
                self.branch_events['iff_expanded']+=1
                out=self.binary(0,self.binary(2,an,bp),self.binary(2,bn,ap))
            else:
                self.branch_events['iff_expanded']+=1
                out=self.binary(2,self.binary(1,an,bn),self.binary(0,ap,bp))
        elif k=='not':out=self.neg(self.remove(not pol,a[0]))
        elif k=='let':
            vs,trs,body,close=self.open(a[1]);body1=self.map_simp(fn,body)
            if 'id:unused' in self.variables[vs[0]][2]:out=body1
            else:out=self.let_simp(a[0],close(vs,(),body1),True)
        elif k=='app' and a[0]==self.equality_symbol and len(a[1])==2 and self.unused_arg(a[1][0]):
            self.branch_events['unused_equality']+=1;out=self.false if pol else self.true
        elif k=='if' and t.ty is None:
            cp,cn=fn(a[0]),self.remove(not pol,a[0]);x,y=fn(a[1]),fn(a[2])
            if self.equal(cp,cn):out=self.conditional(cp,x,y)
            elif pol:
                self.branch_events['if_expanded']+=1
                out=self.binary(0,self.binary(2,cn,x),self.binary(2,self.neg(cp),y))
            else:
                self.branch_events['if_expanded']+=1
                out=self.binary(1,self.binary(0,cp,x),self.binary(0,self.neg(cn),y))
        elif k in ('if','eps'):out=t
        else:out=self.map_simp(fn,t)
        return self.copy(t,out)
    def unused_arg(self,t):
        if t.kind=='var':return 'id:unused' in self.variables[t.args[0]][2]
        if t.kind=='app' and not t.args[1]:return 'id:unused' in self.raw.symbols[t.args[0]]['attrs']
        return False

"""Independent finite splitter interface probe; source proof remains required.

Models exact Unit/Zero/Comb cardinalities and constructor masses, plus the
right-only/no_csp selection. It deliberately overcharges every iff/if fallback
as drop_byso. Saved-map internals and term semantics are outside this probe.
"""
from dataclasses import dataclass
from functools import cached_property
import hashlib
import itertools
import json
from pathlib import Path
import subprocess
import time

ROOT = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/why-right-split-20261023')
FREEZE = 'd551c0c33ea767057fa732904faf2e1325dfe07c'
HERE = Path(__file__).resolve().parent
U = ('U', ())

def base(x): return ('C', (x,))
def zero(x): return ('Z', (x,))
def count(x): return len(x[1])
def degree(x): return min(2, count(x))
def plus(a,b):
    if b[0] == 'U' or a[0] == 'Z': return a
    if a[0] == 'U' or b[0] == 'Z': return b
    return ('C', a[1]+b[1])
def mmap(f0,f,a):
    if a[0] == 'U': return U
    if a[0] == 'Z': return f0(a[1][0])
    return ('C',tuple(map(f,a[1])))
def bimap(f00,f0,f1,f,a,b):
    if 'U' in (a[0],b[0]): return U
    if a[0] == b[0] == 'Z': return f00(a[1][0],b[1][0])
    fn = f0 if a[0] == 'Z' else f1 if b[0] == 'Z' else f
    return ('C',tuple(fn(x,y) for x in a[1] for y in b[1]))

@dataclass(frozen=True)
class F:
    op: str
    cs: tuple = ()
    case: bool = False
    stop: bool = False
    slots: int = 0
    @cached_property
    def shape(self):
        return ((3 if self.op in ('by','so') else 1)+sum(c.shape[0] for c in self.cs),
                self.slots+sum(c.shape[1] for c in self.cs))

@dataclass
class S:
    pos: tuple
    neg: tuple
    bwd: tuple
    fwd: tuple
    cp: bool = False
    cn: bool = False

class Run:
    def __init__(self,ro=True):
        self.ro=ro; self.entries=0;self.maximum=0;self.maxslots=0;self.regs=0;self.drops=0
    def keep(self,x):
        self.maximum=max(self.maximum,x[0]);self.maxslots=max(self.maxslots,x[1]);return x
    def neg(self,x):return self.keep((1+x[0],x[1]))
    def binary(self,x,y):return self.keep((1+x[0]+y[0],x[1]+y[1]))
    def nc(self,a):return mmap(lambda x:zero((1,0)),self.neg,a)
    def ic(self,a,b):return bimap(lambda x,y:zero(y),lambda x,y:y,lambda x,y:self.neg(x),self.binary,a,b)
    def ac(self,a,b):return bimap(lambda x,y:zero(y),lambda x,y:y,lambda x,y:x,self.binary,a,b)
    def select(self,s,pos,others):
        flag=s.cp if pos else s.cn
        return (s.pos if pos else s.neg) if not self.ro or flag and sum(map(degree,others))<=1 else base(s.bwd if pos else s.fwd)
    def drop(self,f):
        self.drops+=1;self.regs+=f.shape[1];return self.keep(f.shape)
    def split(self,f,cp=True,cn=True,intro=False):
        self.entries+=1;x=self.keep(f.shape);op=f.op
        if f.stop or intro and op in ('iff','if','forall','exists'):
            d=self.drop(f);s=S(base(x),base(d),x,d)
        elif op in ('a','true','false'):
            s=S(U if op=='true' else zero(x) if op=='false' else base(x),
                U if op=='false' else zero(x) if op=='true' else base(x),x,x)
        elif op in ('by','so'):
            s=self.split(f.cs[0],cp,cn,intro)
        elif op=='not':
            a=self.split(f.cs[0],cn,cp,intro)
            pos=mmap(lambda _:base((1,0)),self.neg,a.neg)
            neg=mmap(lambda _:base((1,0)),self.neg,a.pos)
            s=S(pos,neg,self.neg(a.fwd),self.neg(a.bwd),a.cn,a.cp)
        elif op in ('let','forall','exists'):
            body=f.cs[-1];self.regs+=f.slots
            a=self.split(body,cp,cn,intro)
            overhead=(x[0]-body.shape[0],x[1]-body.shape[1])
            close=lambda z:self.keep((z[0]+overhead[0],z[1]+overhead[1]))
            pos=mmap(zero,close,a.pos);neg=mmap(zero,close,a.neg)
            bw=close(a.bwd);fw=close(a.fwd)
            s=S(pos,neg,bw,fw,a.cp,a.cn)
            if op=='forall':s.neg=base(fw);s.cn=False
            if op=='exists':s.pos=base(bw);s.cp=False
        elif op in ('and','or','imp'):
            ca,cb=(False,cn) if op=='and' else (cp,False)
            aa,ab=(cb,ca) if op=='imp' else (ca,cb)
            a=self.split(f.cs[0],aa,ab,intro);b=self.split(f.cs[1],ca,cb,intro)
            bw=self.binary(a.fwd if op=='imp' else a.bwd,b.bwd)
            fw=self.binary(a.bwd if op=='imp' else a.fwd,b.fwd)
            if op=='and':
                bb=self.select(b,False,[]);aa=self.select(a,False,[bb])
                s=S(plus(a.pos,b.pos),self.ac(aa,bb),bw,fw,False,cn)
            elif op=='or':
                bb=self.select(b,True,[]);aa=self.select(a,True,[b.pos])
                s=S(self.ac(aa,bb),plus(a.neg,b.neg),bw,fw,cp,False)
            else:
                aa=self.select(a,False,[b.pos])
                s=S(self.ic(aa,b.pos),plus(self.nc(a.pos),b.neg),bw,fw,cp,False)
        elif op=='iff':
            a,b=(self.split(c,False,False,intro) for c in f.cs);d=self.drop(f)
            assert not(a.cp or a.cn or b.cp or b.cn)
            n1=self.select(a,False,[b.pos]);n2=self.select(b,False,[a.pos])
            pos=plus(self.ic(n1,b.pos),self.ic(n2,a.pos))
            n2=self.select(b,False,[]);p2=self.select(b,True,[])
            n1=self.select(a,False,[n2]);p1=self.select(a,True,[p2])
            neg=plus(self.ac(n1,n2),self.ac(self.nc(p1),self.nc(p2)))
            s=S(pos,neg,d,d)
        elif op=='if':
            a,b,c=(self.split(ch,False,False,intro) for ch in f.cs);di=self.drop(f.cs[0])
            assert not(a.cp or a.cn or b.cp or b.cn or c.cp or c.cn)
            bw=self.keep((1+di[0]+b.bwd[0]+c.bwd[0],di[1]+b.bwd[1]+c.bwd[1]))
            fw=self.keep((1+di[0]+b.fwd[0]+c.fwd[0],di[1]+b.fwd[1]+c.fwd[1]))
            pos=plus(self.ic(self.select(a,False,[b.pos]),b.pos),self.ic(self.nc(self.select(a,True,[c.pos])),c.pos))
            neg=plus(self.ac(self.select(a,False,[b.neg]),b.neg),self.ac(self.nc(self.select(a,True,[c.neg])),c.neg))
            self.nc(self.select(a,True,[c.neg,c.pos])) # evaluated for empty side
            s=S(pos,neg,bw,fw)
        else:raise AssertionError(op)
        if f.case:s.cp,s.cn=cp,cn
        for family in [s.pos,s.neg]:
            for v in family[1]:self.keep(v)
        return s

def main():
    start=time.perf_counter()
    paths=['docs/research/retained-why-right-split.md']
    paths+=subprocess.check_output(['git','ls-tree','-r','--name-only',FREEZE,'docs/evidence/retained-why-right-split-20261023'],cwd=ROOT,text=True).splitlines()
    identities={}
    for p in paths:
        b=subprocess.check_output(['git','show',f'{FREEZE}:{p}'],cwd=ROOT)
        assert b==(ROOT/p).read_bytes(),p
        identities[p]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
    seeds=[F(op,case=c,stop=s) for op,c,s in itertools.product(['a','true','false'],[False,True],[False,True])]
    seeds+=[F('and',(F('a'),F('a')),case=True),F('or',(F('a'),F('a')),case=True)]
    cases=list(seeds)
    for a,b in itertools.product(seeds,repeat=2):
        for op in ['and','or','imp','iff','by','so']:
            for flag in [False,True]:cases.append(F(op,(a,b),case=flag))
        cases.append(F('if',(a,b,F('not',(a,))),case=True))
        cases.append(F('let',(a,b),slots=1))
    for a in list(cases[::11]):
        for op in ['forall','exists','not']:
            cases.append(F(op,(a,),case=True,slots=3 if op!='not' else 0))
    checked=0
    for f,intro in itertools.product(cases,[False,True]):
        run=Run();s=run.split(f,intro=intro);m,p=f.shape
        assert count(s.pos)<=m and count(s.neg)<=m,(f,s)
        assert run.maximum<=3*m and run.maxslots<=p,(f,run.__dict__)
        assert s.bwd[0]<=m and s.fwd[0]<=m
        assert run.entries<=m and run.drops<=m and run.regs<=(m+1)*p
        checked+=1
    def family(n):
        f=F('a')
        for _ in range(n-1):f=F('and',(f,F('a')),case=True)
        return f
    f=F('or',(family(20),family(20)),case=True)
    guarded=Run().split(f);unguarded=Run(False).split(f)
    assert count(guarded.pos)<=f.shape[0]<count(unguarded.pos)
    result={'status':'pass','freeze':FREEZE,'exact_inputs':identities,'interface_cases':checked,
            'unguarded_positive_count':count(unguarded.pos),'counterexample_input_mass':f.shape[0],
            'elapsed_seconds':time.perf_counter()-start,'native_runs':0,'predecessor_replays':0,
            'limits':'Finite source-shaped abstraction; no substitution/lineage proof or universal soundness from probes.'}
    (HERE/'split-probe-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='exact_inputs'},indent=2))
if __name__=='__main__':main()

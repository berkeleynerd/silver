"""Offline source-correspondence fixtures and fixed-graph exclusion checks."""
from pathlib import Path
import copy,json,random,subprocess,sys,time
import compose
HERE=Path(__file__).resolve().parent
start=time.monotonic();summary,detailed,model=compose.compose()
assert summary==json.loads((HERE/'result.json').read_text())
assert json.loads(json.dumps(detailed))==json.loads((HERE/'details.json').read_text())
graph,_,_,_=compose.verified_graph();bound=[x['output_coordinates_upper'] for x in detailed['root_results']]
keys=tuple(model.environment)
# These finite executions exercise the abstract inclusion invariant. They are
# not a substitute for the source induction over all 2^45 exclusion sets.
masks=[set(),set(keys)]+[{k} for k in keys]+[set(keys)-{k} for k in keys]
rng=random.Random(119)
masks += [{k for k in keys if rng.getrandbits(1)} for _ in range(64)]
for excluded in masks:
 r=compose.Refiner(graph,excluded=excluded).run()
 assert len(r['root_results'])==len(bound)
 assert all(all(a<=b for a,b in zip(x['output_coordinates_upper'],upper)) for x,upper in zip(r['root_results'],bound))
 assert r['optional_hit_count']<=summary['kernel_events']['environment_hits_upper']

# Directly check multiplicities greater than those in this graph: duplicate a
# formal twice, including once in a trigger, and substitute a three-node tree.
R=compose.Refiner({'blocks':{},'roots':[]});ty=('v',1)
R.variables[1]=(ty,{'name':'x'});R.variables[2]=(ty,{'name':'y'});R.nextvar=2
x=R.make('var',1,ty,());y=R.make('var',2,ty,())
a=R.make('const',0,ty,());arg=R.make('app',101,ty,(),[a,a])
body=R.make('app',102,ty,(),[x,x]);base,coef=R.linear(body,(1,))
assert base==(1,0,0,1) and coef==(2,)
out=R.substitute(body,{1:arg},{})
assert R.dimensions(out)==(7,0,0,3)
# Quantifier body and trigger both contribute; the bound variable is renamed.
q=R.make('quant',(0,(1,)),None,(),[body,x],[(2,)])
base,coef=R.linear(q,(1,));assert base==(2,1,0,1) and coef==(3,)
out=R.substitute(q,{1:arg},{})
assert R.dimensions(out)==(11,1,0,4)
assert R.nodes[out][5][0][0]!=2
# A type instance changes types uniformly and preserves tree dimensions.
newty=('a',202,());newa=R.make('const',0,newty,());newarg=R.make('app',101,newty,(),[newa,newa])
out2=R.substitute(body,{1:newarg},{1:newty});assert R.dimensions(out2)==(7,0,0,3)
assert R.nodes[out2][2]==newty
# Capture avoidance: a replacement's free y remains free under a freshly
# renamed body binder that originally used the same alpha identity.
xy=R.make('app',102,ty,(),[x,y]);qy=R.make('quant',(0,()),None,(),[xy],[(2,)])
renamed=R.substitute(qy,{1:y},{})
assert dict(R.free(renamed))=={2:1}
# Actual source triviality rules: duplicate variable args reject, closed args
# may repeat, epsilon rejects even when closed, and inline:trivial overrides.
assert R.eligible(body)==(False,False)
closed_body=R.make('app',102,ty,(),[a,a]);assert R.eligible(closed_body)==(True,True)
eps=R.make('eps',None,ty,(),[a],[(2,)])
assert R.eligible(R.make('app',102,ty,(),[eps]))==(False,False)
assert R.eligible(R.with_attrs(body,frozenset(['inline:trivial'])))==(True,True)
# A mixed optional shape is reported as ambiguous, not silently admitted.
mixed=R.make('app',102,ty,(),[R.choice([x,a]),x])
assert R.eligible(mixed)==(True,False)
# Type mismatch and malformed source views must fail closed.
try:R.match_type(('a',3,()),('a',4,()),{})
except AssertionError:pass
else:raise AssertionError('type mismatch accepted')
g=copy.deepcopy(graph);g['blocks'].pop(str(g['roots'][0]))
try:compose.Refiner(g).run()
except (AssertionError,KeyError):pass
else:raise AssertionError('missing declaration accepted')
cli=subprocess.run([sys.executable,'-B',str(HERE/'compose.py')],capture_output=True,text=True,check=True)
assert json.loads(cli.stdout)==summary
print(json.dumps({'result':'PASS','concrete_exclusion_scenarios':len(masks),'elapsed_seconds':time.monotonic()-start,
 'claims':'finite regression checks; all-exclusion claim uses inspected source induction; no native target'}))

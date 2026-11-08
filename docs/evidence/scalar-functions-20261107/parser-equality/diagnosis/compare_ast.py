from pathlib import Path
import json, collections, hashlib
here = Path(__file__).parent
src = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-parser-repairs-298/tmp/parser-proof-repair/saved-after-helpers/silver_output_profile__array_declaration_at.gnat-json')
raw = src.read_bytes()
assert hashlib.sha256(raw).hexdigest() == '6b2c8f3ea1ed20c2b0811f754e633a21d3ef89daf6e756b436293331f2237742'
d = json.loads(raw)

def walk(x):
 if isinstance(x,list):
  if x and isinstance(x[0],str) and x[0].startswith('W_'):yield x
  for y in x:yield from walk(y)

def ident(x):
 if x[0]=='W_IDENTIFIER':return ident(x[3])
 if x[0]=='W_NAME':return (x[5][4]+'.' if x[5] else '')+x[3]
 raise ValueError(x[:3])

counts=collections.Counter()
def norm(x,env=None):
 env={} if env is None else env
 if x is None:return None
 if not isinstance(x,list):return x
 if not x:return ()
 k=x[0]
 if k in ('W_LABEL','W_LOC_LABEL'):return norm(x[4],env)
 if k=='W_IDENTIFIER':
  n=ident(x)
  if n in env:return env[n]
  if n in ('param__text','param__state','param__arguments'):return n[7:]
  for z in ('text','state','arguments'):
   if n=='Silver_output_profile__array_declaration_at__'+z+'.'+z:return z
  return n
 if k=='W_BINDING':
  return norm(x[5],dict(env,**{ident(x[3]):norm(x[4],env)}))
 if k=='W_EPSILON':
  eq=x[5]
  assert eq[0]=='W_CONNECTION' and eq[4]==5 and not eq[6]
  lhs,guard=eq[3],eq[5]
  assert lhs[0]=='W_CALL' and ident(lhs[3])=='=' and ident(lhs[4][0])==ident(x[3])
  assert guard[0]=='W_CALL' and ident(guard[3]).endswith('__function_guard')
  counts['epsilon_guard_erased']+=1
  return norm(lhs[4][1],env)
 if k=='W_CALL':
  fn=ident(x[3]);args=tuple(norm(y,env) for y in x[4])
  if '___program_fun.' in fn:
   counts['program_call_to_logic']+=1;fn=fn.replace('___program_fun.','.')
  if fn.endswith('.range_check_'):
   counts['range_check_identity']+=1;assert len(args)==1;return args[0]
  for z in ('array_values','boolean_array_values'):
   if fn=='Silver_output_profile__'+z+'_at.'+z+'_at':
    counts['reader_refinement']+=1;fn=fn.replace(z+'_at',z+'_model')
  fn={'Boolean.andb':'and','Boolean.orb':'or','Integer.bool_eq':'=','Integer.bool_ne':'<>','Int.+':'+','Int.-':'-'}.get(fn,fn)
  if fn=='=' and len(args)==2 and args[1] is True:return args[0]
  return (fn,*args)
 if k=='W_LITERAL':
  if x[3] in (0,1):return x[3]==0
  return ('literal',*x[3:])
 if k in ('W_INTEGER_CONSTANT','W_RANGE_CONSTANT'):return int(x[3])
 if k=='W_CONNECTION':
  op={0:'or',1:'and',4:'or',5:'and',2:'implies'}[x[4]]
  return (op,*(norm(y,env) for y in [x[3],x[5]]+(x[6] or [])))
 if k=='W_NOT':return ('not',norm(x[3],env))
 if k=='W_CONDITIONAL':
  assert not x[5];return ('if',norm(x[3],env),norm(x[4],env),norm(x[6],env))
 if k=='W_RECORD_ACCESS':return ('field',norm(x[3],env),ident(x[4]))
 if k=='W_RECORD_AGGREGATE':return ('record',*(norm(y,env) for y in x[3]))
 if k=='W_FIELD_ASSOCIATION':return (ident(x[3]),norm(x[4],env))
 if k=='W_IDENTIFIER':return ident(x)
 raise ValueError(k)

tmodel=next(t for t in d['theory_declarations'] if t[4]=='Silver_output_profile__array_declaration_model___def__axiom')
tprog=next(t for t in d['theory_declarations'] if t[4]=='Silver_output_profile__array_declaration_at__subprogram_def')
model=tmodel[3][0][4][6][4][1]
prog=next(n[4] for n in walk(tprog) if n[0]=='W_BINDING' and ident(n[3])=='silver_output_profile__array_declaration_at__result__assume')
m=norm(model);p=norm(prog)

# The trees expand common local bindings. Report unique leaf differences only.
diffs=[]
def compare(a,b,path=()):
 if a==b:return
 if isinstance(a,tuple) and isinstance(b,tuple) and len(a)==len(b):
  for i,(aa,bb) in enumerate(zip(a,b)):compare(aa,bb,path+(i,))
 else:diffs.append({'path':path,'model':a,'program':b})
compare(m,p)
summary={'input_sha256':hashlib.sha256(raw).hexdigest(),'normalization_counts':counts,'difference_count':len(diffs),'unique_differences':list({json.dumps([v['model'],v['program']]):{'model':v['model'],'program':v['program']} for v in diffs}.values()),'first_paths':diffs[:5]}
(here/'normalized-comparison.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))

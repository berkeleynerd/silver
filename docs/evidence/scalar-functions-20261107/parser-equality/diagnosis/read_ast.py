from pathlib import Path
import json, hashlib
here = Path(__file__).parent
src = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-parser-repairs-298/tmp/parser-proof-repair/saved-after-helpers/silver_output_profile__array_declaration_at.gnat-json')
raw = src.read_bytes()
assert hashlib.sha256(raw).hexdigest() == '6b2c8f3ea1ed20c2b0811f754e633a21d3ef89daf6e756b436293331f2237742'
d = json.loads(raw)
def fmt(x,dep=0):
 if x is None:return '_'
 if not isinstance(x,list):return str(x)
 if not x:return '[]'
 if not isinstance(x[0],str) or not x[0].startswith('W_'):return '['+', '.join(fmt(v,dep) for v in x)+']'
 k=x[0];args=x[3:]
 if k in ('W_IDENTIFIER','W_TYPE','W_BINDER'):return fmt(x[3] if k!='W_TYPE' else x[4],dep)
 if k=='W_NAME':return (x[5][4]+'.' if x[5] else '')+str(x[3])
 if k in ('W_LABEL','W_LOC_LABEL'):return fmt(x[4],dep)
 if k=='W_CALL':return fmt(x[3],dep)+'('+', '.join(fmt(v,dep) for v in x[4])+')'
 if k in ('W_INTEGER_CONSTANT','W_RANGE_CONSTANT'):return str(x[3])
 if k=='W_LITERAL':return 'literal'+str(x[3])
 if k=='W_BINDING':return '(let '+fmt(x[3])+' = '+fmt(x[4],dep+1)+' in\n'+'  '*dep+fmt(x[5],dep)+')'
 if k=='W_EPSILON':return '(epsilon '+fmt(x[3])+'. '+fmt(x[5],dep)+')'
 if k=='W_CONNECTION':return '('+(' '+str(x[4])+' ').join(fmt(v,dep) for v in [x[3],x[5]]+(x[6] or []))+')'
 if k=='W_CONDITIONAL':return '(if '+fmt(x[3],dep)+' then\n'+'  '*(dep+1)+fmt(x[4],dep+1)+' else\n'+'  '*(dep+1)+fmt(x[6],dep+1)+')'
 if k=='W_NOT':return '(not '+fmt(x[3],dep)+')'
 if k=='W_RECORD_ACCESS':return fmt(x[3],dep)+'.'+fmt(x[4])
 if k=='W_RECORD_AGGREGATE':return '{'+', '.join(fmt(v,dep) for v in x[3])+'}'
 if k=='W_FIELD_ASSOCIATION':return fmt(x[3])+' := '+fmt(x[4],dep)
 if k=='W_UNIVERSAL_QUANTIF':return '(forall '+', '.join(fmt(v) for v in x[3])+'. '+fmt(x[6],dep)+')'
 if k in ('W_AXIOM',):return x[3]+' :\n'+fmt(x[4],dep)
 if k=='W_STATEMENT_SEQUENCE':return '\n'.join(fmt(v,dep) for v in x[3])
 if k=='W_ASSERT':return 'assert'+str(x[4])+' '+fmt(x[3],dep)
 if k=='W_COMMENT':return '# '+x[3]
 if k=='W_DEREF':return '!'+fmt(x[3])
 if k=='W_FUNCTION_DECL':return 'function '+fmt(x[3])+' pre '+fmt(x[6])+'\npost '+fmt(x[7])+'\nbody\n'+fmt(x[9])
 if k=='W_ASSIGNMENT':return fmt(x[3])+' := '+fmt(x[4],dep)
 if k=='W_ABSTRACT_EXPR':return '(abstract '+fmt(x[3],dep)+' ensures '+fmt(x[4],dep)+')'
 if k=='W_TRY_BLOCK':return '(try '+fmt(x[3],dep)+' handler '+fmt(x[4],dep)+')'
 return k+'('+', '.join(fmt(v,dep) for v in args if not (isinstance(v,list) and v and v[0]=='W_TYPE'))+')'
selected = ('Silver_output_profile__array_declaration_model___def__axiom', 'Silver_output_profile__array_declaration_at__subprogram_def', 'Silver_output_profile__array_values_at___post__axiom', 'Silver_output_profile__boolean_array_values_at___post__axiom')
for t in d['theory_declarations']:
 if t[4] in selected or t[4] in tuple('Temp___String_Literal_' + str(i) for i in (9365,9369,9373,842,846,850)):
  dest=here / (t[4] + '.txt')
  dest.write_text('\n'.join(fmt(v) for v in t[3]))
  print(t[4], 'AST node', t[1], 'text bytes', dest.stat().st_size)

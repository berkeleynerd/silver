"""Read-only extraction for the two fixed ASCII Ada prototypes; not a Lean proof."""
from pathlib import Path
import hashlib,json,re,subprocess
ROOT=Path(__file__).resolve().parents[4]
OUT=Path(__file__).parent
TARGET='8102cd38980ef112bbeed69d8e082d9626f96bc9'
NAME='proof/Silver/ComposeBooleanArraySource.lean'
def git(rev,path):
    return subprocess.check_output(['git','show',f'{rev}:{path}'],cwd=ROOT,text=True)
def read_rhs(text,name):
    start=text.index(':=',text.index(f'def {name} : List String'))+2
    tail=text[start:].lstrip()
    if tail.startswith('expectedTokens'):
        tail=tail[len('expectedTokens'):].lstrip()
    return json.JSONDecoder().raw_decode(tail)[0]
def tokens(text):
    assert all(c in '\t\r\n' or 32 <= ord(c) <= 126 for c in text)
    assert '"' not in text and '%' not in text
    parts=re.findall(r'\s+|--[^\r\n]*|[A-Za-z0-9_]+|:=|=>|<=|>=|/=|\.\.|[^\s]',text)
    assert ''.join(parts)==text
    return [p.lower() for p in parts if not p.isspace() and not p.startswith('--')]
def native_header(text,name):
    start=re.search(r'\bfunction\s+'+name+r'\b',text,re.I).end()
    depth=0
    for finish in range(start,len(text)):
        char=text[finish]
        if char=='(':depth+=1
        elif char==')':depth-=1
        elif char==';' and depth==0:return text[start:finish]
    raise ValueError(name)
old=git('d3aafa4baf',NAME)
new=git(TARGET,NAME)
native=git(TARGET,'src/silver_output_profile.adb')
results=[]
for definition,ada in [('modelSpec','Boolean_Array_Values_Model'),('executableSpec','Boolean_Array_Values_At')]:
    previous=read_rhs(old,definition)
    literal=read_rhs(new,definition)
    actual=native_header(native,ada)
    previous_tokens=tokens(previous)
    actual_tokens=tokens(actual)
    assert literal==previous_tokens==actual_tokens
    results.append({'definition':definition,'token_count':len(literal),'matches_previous_expectedTokens_string':True,'matches_complete_native_spec_header':True,'tokens':literal,'previous_string':previous,'native_header':actual})
assert old[old.index('structure Checked'):]==new[new.index('structure Checked'):]
record={'target':TARGET,'comparison':'d3aafa4baf','method':'Independent tokenization of the exact unquoted ASCII header subset after inspecting SourceLexer.lean; balanced-parenthesis extraction through the first top-level native declaration semicolon. Complements retained kernel source checks.','all_six_checked_fields_unchanged':True,'results':results}
(OUT/'helper-memory-header-equality.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({'headers':[{k:v for k,v in r.items() if k not in ('tokens','previous_string','native_header')} for r in results],'all_six_checked_fields_unchanged':True}))

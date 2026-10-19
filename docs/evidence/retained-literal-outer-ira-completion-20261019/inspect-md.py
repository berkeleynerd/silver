#!/usr/bin/env python3
"""Read-only MD source-case inventory; does not execute GCC generators."""
from pathlib import Path
import re,json

def tokens(s):
 i=0
 while i<len(s):
  c=s[i]
  if c.isspace():i+=1;continue
  if c==';': i=s.find('\n',i) if '\n' in s[i:] else len(s);continue
  if s.startswith('/*',i):i=s.index('*/',i)+2;continue
  if c=='"':
   j=i+1
   while j<len(s):
    if s[j]=='\\':j+=2
    elif s[j]=='"':break
    else:j+=1
   yield s[i:j+1];i=j+1
  elif c=='{':
   j=i+1;depth=1
   while depth:
    if s.startswith('/*',j):j=s.index('*/',j)+2;continue
    if s.startswith('//',j):j=s.index('\n',j);continue
    if s[j] in ('"',"'"):
     q=s[j];j+=1
     while s[j]!=q:
      j+=2 if s[j]=='\\' else 1
    elif s[j]=='{':depth+=1
    elif s[j]=='}':depth-=1
    j+=1
   yield s[i:j];i=j
  elif c in '()[]': yield c;i+=1
  else:
   j=i+1
   while j<len(s) and not s[j].isspace() and s[j] not in '()[]{}";':j+=1
   yield s[i:j];i=j

def parse(s):
 ts=iter(tokens(s))
 def seq(end=None):
  out=[]
  for t in ts:
   if t==end:return out
   if t=='(':out.append(seq(')'))
   elif t=='[':out.append(seq(']'))
   else:out.append(t)
  return out
 return seq()

def inventory(gcc_root):
 root=Path(gcc_root)/'gcc/config/i386'
 rows=[];wild=[];files=[];includes=[];attrs=[]
 for f in sorted(root.glob('*.md')):
  files.append(str(f.relative_to(Path(gcc_root))))
  for x in parse(f.read_text()):
   if not isinstance(x,list) or not x:continue
   if x[0]=='define_mode_attr' and x[1].strip('"') in ('hfbfconstf','sseconstm1'):attrs.append(dict(file=f.name,name=x[1],values=x[2]))
   if x[0]=='include':includes.append(dict(file=f.name,include=x[1].strip('"')))
   if x[0] not in ('define_insn','define_insn_and_split'):continue
   body=x[2]
   if len(body)!=1 or not isinstance(body[0],list):continue
   if body[0][0].split(':')[0] in ('match_operand','match_operator','match_parallel','match_dup'):
    wild.append(dict(file=f.name,name=x[1],pattern=body[0],condition=x[3]))
   if body[0][0]!='set':continue
   pat=body[0]
   if len(pat)!=3 or not all(isinstance(a,list) and a[0].split(':')[0] in ('match_operand','match_dup','reg') for a in pat[1:]):continue
   rows.append(dict(file=f.name,name=x[1],pattern=pat,condition=x[3]))
 return dict(scope='Unexpanded direct SET/leaf templates and root wildcards; handwritten source argument classifies them',
             files=files,includes=includes,constraint_mode_attributes=attrs,direct_SET_leaf_templates=rows,root_wildcard_templates=wild,
             does_not_execute_recognizer_or_generators=True)

if __name__=='__main__':
 import argparse
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--gcc-root',required=True)
 a=p.parse_args()
 print(json.dumps(inventory(a.gcc_root),indent=2))

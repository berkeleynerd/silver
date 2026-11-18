from pathlib import Path
from datetime import datetime,timezone
import json,collections,xml.etree.ElementTree as E
p=Path('.silver/linux-aarch64/compiler/obj/gnatprove');a=collections.Counter();b=collections.Counter();files=0;fail=[]
for x in p.rglob('why3session.xml'):
 try:t=E.parse(x)
 except E.ParseError:fail.append(str(x));continue
 files+=1
 for g in t.iter('goal'):a['goals']+=1;a['goals_proved_true']+=g.get('proved')=='true'
 for r in t.iter('result'):b[r.get('status','missing')]+=1
procs=[]
for proc in Path('/proc').iterdir():
 if not proc.name.isdigit():continue
 try:
  args=[x.decode(errors='replace') for x in proc.joinpath('cmdline').read_bytes().split(b'\0') if x]
  if args and Path(args[0]).name in {'gnat2why','gnatwhy3','cvc5','z3','alt-ergo'} and any('named-native-392' in x for x in args):
   procs.append({'pid':proc.name,'tool':Path(args[0]).name,'inputs':[x for x in args if x.endswith(('.adb','.ads','.gnat-json'))]})
 except OSError:pass
x={'utc':datetime.now(timezone.utc).isoformat(),'partial_only':True,'sessions_parsed':files,'parse_incomplete':fail,'goals':dict(a),'attempt_statuses':dict(b),'active_native':procs,'cache_hits':'not observed'}
with Path('tmp/final-native-392/progress.jsonl').open('a') as f:f.write(json.dumps(x)+'\n')
print(json.dumps(x))

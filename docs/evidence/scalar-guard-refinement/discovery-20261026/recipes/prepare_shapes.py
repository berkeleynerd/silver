"""Author exact-limit recognizer inputs; no compiler invocation."""
from pathlib import Path
import json
BASE=Path(__file__).resolve().parent
OUT=BASE/'recognizer-shapes'
OUT.mkdir(exist_ok=True)
records=[]

def save(name, source, **metadata):
    # Padding changes neither executable syntax nor proof work.
    padded=source+' '*(4096-len(source.encode()))
    if len(source.encode())>4096:
        raise ValueError(name)
    (OUT/(name+'.adb')).write_text(padded)
    (OUT/(name+'-4097.adb')).write_text(padded+' ')
    records.append(dict(name=name,source_bytes=4096,negative_neighbor_bytes=4097,
                        expectation='current grammar: 4096 accepted; 4097 source-limit rejection',**metadata))

for count in [1,32,128,224]:
    declarations='X:Integer range 0..9:=0;'+''.join(f'X{i}:Integer:=0;' for i in range(1,count))
    header='with Silver_IO;procedure Main is pragma SPARK_Mode(On);'+declarations+'begin if '
    tail=' then null;end if;end Main;\n'
    depth=(4096-len((header+'X=0'+tail).encode()))//2
    save(f'parentheses-{count}',header+'('*depth+'X=0'+')'*depth+tail,
         form='parentheses',active_scalars=count,depth=depth)

header='with Silver_IO;procedure Main is pragma SPARK_Mode(On);X:Integer range 0..9:=0;begin '
tail='end Main;\n'
for name,left,right in [('not','if ',' then null;end if;'),
                         ('and_then','if ',' then null;end if;'),
                         ('or_else','if ',' then null;end if;')]:
    if name=='not':
        unit='not ('
        depth=(4096-len((header+left+'X=0'+right+tail).encode()))//(len(unit)+1)
        expr=unit*depth+'X=0'+')'*depth
    else:
        unit=' and then X=0' if name=='and_then' else ' or else X=0'
        depth=(4096-len((header+left+'X=0'+right+tail).encode()))//len(unit)
        expr='X=0'+unit*depth
    save(name,header+left+expr+right+tail,form=name,depth=depth,active_scalars=1)

for name,left,right in [('nested_if','if X=0 then ','end if;'),
                         ('nested_loop','for I in 1..1 loop ','end loop;'),
                         ('mixed','for I in 1..1 loop if (X=0) then ','end if;end loop;')]:
    depth=(4096-len((header+'null;'+tail).encode()))//(len(left)+len(right))
    save(name,header+left*depth+'null;'+right*depth+tail,form=name,depth=depth,
         active_scalars=(1+depth if name in ('nested_loop','mixed') else 1))
(OUT/'shapes.json').write_text(json.dumps(records,indent=2)+'\n')
print(json.dumps(records,indent=2))

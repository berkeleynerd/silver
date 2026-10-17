#!/usr/bin/env python3
"""Copy compact raw research evidence; preserve all original scratch artifacts."""
from pathlib import Path
import hashlib
import json
import shutil
import sys

base=Path(__file__).resolve().parent
dest=Path(sys.argv[1]).resolve()
dest.mkdir(parents=True,exist_ok=True)
copied=[]
omitted=[]
for src in sorted(base.rglob('*')):
    if not src.is_file(): continue
    rel=src.relative_to(base)
    if src.suffix in ('.py','.json','.txt','.c','.adb','.ads') or src.name=='README.md':
        target=dest/rel;target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(src,target)
        copied.append(str(rel))
    else:
        omitted.append({'path':str(rel),'bytes':src.stat().st_size,
                        'sha256':hashlib.sha256(src.read_bytes()).hexdigest(),
                        'retained_at':str(src)})
        if src.suffix=='.s':
            lines=src.read_text().splitlines()
            # Show instructions/directives without copying repeated literal payload.
            text='\n'.join(f'{i}: {s}' for i,s in enumerate(lines,1)
                           if not s.split() or s.split()[0] not in ('.ascii','.string'))+'\n'
            target=dest/(str(rel)+'.nonliteral-excerpt.txt')
            target.parent.mkdir(parents=True,exist_ok=True);target.write_text(text)
source_ranges={
    'darwin-aarch64.cc':[(20740,20783),(22764,22794)],
    'gcc16-aarch64.cc':[(20210,20246)],
    'sdk-macho-loader.h':[(393,412),(473,485),(913,919)],
    'gnat-fsf-gcc.anod':[(12,29),(295,306)],
}
for name,ranges in source_ranges.items():
    f=base/'sources'/name
    if not f.exists():continue
    lines=f.read_text().splitlines()
    text='\n'.join(f'{i}: {lines[i-1]}' for lo,hi in ranges for i in range(lo,min(hi,len(lines))+1))+'\n'
    target=dest/'sources'/(name+'.excerpt.txt');target.parent.mkdir(parents=True,exist_ok=True);target.write_text(text)
(dest/'retained-large-artifacts.json').write_text(json.dumps(omitted,indent=2)+'\n')
entries=[]
for f in sorted(dest.rglob('*')):
    if f.is_file() and f.name!='MANIFEST.json':
        entries.append({'path':str(f.relative_to(dest)),'bytes':f.stat().st_size,
                        'sha256':hashlib.sha256(f.read_bytes()).hexdigest()})
(dest/'MANIFEST.json').write_text(json.dumps(entries,indent=2)+'\n')
print(json.dumps({'copied':len(copied),'retained_omitted':len(omitted),'bundle_bytes':sum(e['bytes'] for e in entries)},indent=2))

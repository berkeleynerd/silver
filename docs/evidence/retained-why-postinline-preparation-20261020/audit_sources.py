"""Exact source identities/excerpts for the post-inline interface; no execution."""
import json,tarfile
from inventory import HERE,REPO,identity
ARCHIVE='docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
RANGES={
 'core/decl.ml':[(29,98),(175,283),(344,748),(750,836)],
 'core/term.ml':[(132,180),(262,427),(430,541),(590,630),(739,858),(1174,1210),(1284,1297),(1423,1440)],
 'core/ty.ml':[(130,172),(208,255),(306,316)],
 'core/theory.ml':[(88,165),(214,272),(968,1018)],
 'core/task.ml':[(73,174)],
 'core/trans.ml':[(48,140),(234,312)],
 'core/pattern.ml':[(20,157)],
 'core/printer.ml':[(447,499)],
 'driver/driver.ml':[(75,96),(101,265),(329,390)],
 'driver/driver_lexer.mll':[(68,125)],
 'util/lexlib.mll':[(82,127)],
 'util/debug.ml':[(65,85)],
 'transform/eliminate_definition.ml':[(17,43)],
 'transform/remove_unused.ml':[(17,310)],
 'transform/detect_polymorphism.ml':[(17,131)],
 'transform/libencoding.ml':[(17,26)],
 'transform/eliminate_algebraic.ml':[(17,33)]}

def audit():
    with tarfile.open(REPO/ARCHIVE) as arc:
        source={m.name:arc.extractfile(m).read() for m in arc.getmembers() if m.isfile() and m.name.endswith(('.ml','.mll'))}
    prefix,=[p[:-len('core/term.ml')] for p in source if p.endswith('/core/term.ml')]
    files={}
    for name,ranges in RANGES.items():
        p=prefix+name;data=source[p];lines=data.decode().splitlines(keepends=True)
        excerpts=[]
        for first,last in ranges:
            last=min(last,len(lines));assert first<=last
            excerpts.append(dict(first=first,last=last,text=''.join(lines[first-1:last])))
        files[p]=dict(**identity(data),excerpts=excerpts)
    return dict(archive=ARCHIVE,files=files,source_arguments_machine_checked=False)

if __name__=='__main__':
    (HERE/'source-witnesses.json').write_text(json.dumps(audit(),sort_keys=True,indent=2)+'\n')

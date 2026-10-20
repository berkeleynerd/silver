"""Retain exact source slices for the R57 transfer proof; no source execution."""
import json,tarfile
from context_model import HERE, REPO, identity
ARCHIVE='docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
RANGES={
 'driver/driver_lexer.mll':[(68,125)],
 'util/lexlib.mll':[(82,127)],
 'core/term.ml':[(262,402),(404,427),(535,543),(590,665),(739,858),(1073,1209),(1247,1340),(1423,1462),(1664,1818)],
 'core/decl.ml':[(29,98),(130,283),(344,419),(439,450),(518,671),(688,748),(830,836)],
 'core/pattern.ml':[(20,157)],
 'core/task.ml':[(135,174)],
 'core/trans.ml':[(48,109),(133,202),(234,243)],
 'driver/driver.ml':[(101,265),(319,390)],
 'transform/inlining.ml':[(17,145)],
 'transform/eliminate_definition.ml':[(17,43),(81,140),(211,234)],
 'transform/remove_unused.ml':[(17,45),(145,269)],
 'transform/detect_polymorphism.ml':[(17,131)],
 'transform/eliminate_inductive.ml':[(17,190)],
 'transform/eliminate_epsilon.ml':[(17,228)],
 'transform/eliminate_gnatprove_guard_epsilon.ml':[(1,122)],
 'transform/eliminate_literal.ml':[(17,193)],
 'transform/eliminate_algebraic.ml':[(22,198),(365,494),(589,677)],
 'transform/simplify_formula.ml':[(13,38)],
 'transform/split_goal.ml':[(180,443),(493,568)],
 'transform/discriminate.ml':[(462,478)],
 'transform/encoding.ml':[(125,140)],
 'transform/introduction.ml':[(17,280),(513,529)]}

def audit():
    with tarfile.open(REPO/ARCHIVE) as arc:
        source={m.name:arc.extractfile(m).read() for m in arc.getmembers() if m.isfile() and m.name.endswith(('.ml','.mll'))}
    prefix,=[p[:-len('core/term.ml')] for p in source if p.endswith('/core/term.ml')]
    files={}
    for name,ranges in RANGES.items():
        p=prefix+name;data=source[p];lines=data.decode().splitlines(keepends=True)
        slices=[]
        for first,last in ranges:
            last=min(last,len(lines));assert first<=last,(name,first,len(lines))
            slices.append(dict(first=first,last=last,text=''.join(lines[first-1:last])))
        files[p]=dict(**identity(data),excerpts=slices)
    return dict(archive=ARCHIVE,files=files,source_theorem_machine_checked=False)

if __name__=='__main__':
    (HERE/'source-witnesses.json').write_text(json.dumps(audit(),sort_keys=True,indent=2)+'\n')

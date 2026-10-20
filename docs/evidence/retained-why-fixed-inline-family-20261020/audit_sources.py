"""Exact source witnesses and attribute-producer census for human review.

The census is supporting evidence, not a proof from absence of a string.
"""
from project import HERE, REPO, identity
import json, re, tarfile

ARCHIVE='docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
RANGES={
 'core/term.ml':[(262,402),(515,542),(646,695),(739,858),(913,931),(1073,1174),(1247,1296)],
 'core/decl.ml':[(41,75),(130,340),(344,419),(518,649),(741,748),(780,826)],
 'core/ty.ml':[(244,327)],
 'core/trans.ml':[(48,109),(234,243),(291,301)],
 'core/task.ml':[(135,170)],
 'core/ident.ml':[(187,215)],
 'core/pattern.ml':[(20,141)],
 'driver/driver.ml':[(344,389)],
 'util/number.ml':[(402,417)],
 'transform/inlining.ml':[(17,145)],
 'transform/eliminate_definition.ml':[(17,43),(81,140),(211,234)],
 'transform/eliminate_algebraic.ml':[(22,198),(298,315),(365,470),(589,671)],
 'transform/split_goal.ml':[(468,568)],
 'transform/discriminate.ml':[(186,291)],
 'transform/encoding.ml':[(109,160)],
 'transform/libencoding.ml':[(43,75),(107,252),(260,302)],
 'transform/encoding_guards.ml':[(39,163)],
 'transform/encoding_tags.ml':[(39,164)],
 'transform/encoding_guards_full.ml':[(1,10000)],
 'transform/encoding_tags_full.ml':[(1,10000)],
 'transform/encoding_sort.ml':[(48,132)],
 'transform/encoding_twin.ml':[(58,139)],
 'transform/encoding_select.ml':[(1,10000)],
}
CENSUS=[
 'transform/counterexamples.ml','transform/eliminate_builtin.ml',
 'transform/eliminate_definition.ml','transform/remove_unused.ml','transform/detect_polymorphism.ml',
 'transform/eliminate_inductive.ml','transform/eliminate_algebraic.ml','transform/eliminate_literal.ml',
 'transform/eliminate_epsilon.ml','transform/introduction.ml','transform/simplify_formula.ml',
 'transform/split_goal.ml','transform/discriminate.ml','transform/encoding.ml','transform/libencoding.ml',
 'transform/encoding_sort.ml','transform/encoding_twin.ml','transform/encoding_guards.ml','transform/encoding_tags.ml',
 'transform/encoding_guards_full.ml','transform/encoding_tags_full.ml','transform/encoding_select.ml']

def audit():
    with tarfile.open(REPO/ARCHIVE) as arc:
        source={m.name:arc.extractfile(m).read() for m in arc.getmembers() if m.isfile() and m.name.endswith('.ml')}
    prefixes=[p for p in source if p.endswith('/transform/inlining.ml')];assert len(prefixes)==1
    prefix=prefixes[0][:-len('transform/inlining.ml')]
    # Discover the CE/guard module by its actual definitions; do not assume
    # an illustrative filename is the selected implementation.
    names=set(RANGES)
    names.update(n for n in CENSUS if prefix+n in source)
    definitions=('let counterexamples_dependent_intros','let eliminate_gnatprove_guard_epsilon')
    for p,data in source.items():
        if any(s.encode() in data for s in definitions):names.add(p[len(prefix):])
    out={};census={}
    for name in sorted(names):
        p=prefix+name;data=source[p];lines=data.decode().splitlines(keepends=True)
        slices=[]
        for first,last in RANGES.get(name,[]):
            last=min(last,len(lines));assert first<=last
            slices.append(dict(first=first,last=last,text=''.join(lines[first-1:last])))
        out[p]=dict(**identity(data),excerpts=slices)
        census[p]=[dict(line=i,text=line.rstrip('\n')) for i,line in enumerate(lines,1)
            if re.search(r'create_attribute|t_attr_(?:add|set|copy)|~attrs|id_(?:clone|derive|fresh)',line)]
    literal=[]
    for p,data in source.items():
        for i,line in enumerate(data.decode().splitlines(),1):
            if 'inline:trivial' in line:literal.append(dict(file=p,line=i,text=line))
    assert literal and all(x['file']==prefix+'transform/inlining.ml' for x in literal)
    return dict(archive=ARCHIVE,files=out,attribute_producer_sites=census,
                force_attribute_literal_sites=literal,absence_scan_is_not_source_theorem=True)

if __name__=='__main__':
    (HERE/'source-witnesses.json').write_text(json.dumps(audit(),sort_keys=True,indent=2)+'\n')

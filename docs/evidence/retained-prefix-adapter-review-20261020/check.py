#!/usr/bin/env python3
"""Independent finite input/source audit for R51; no native tool execution."""
import argparse
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import struct
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
SOURCES = {
    'src/core/term.ml': [(266,281),(404,418),(550,555),(608,659),
                         (739,860),(1177,1209),(1247,1280),(1657,1809),(1850,1888)],
    'src/transform/introduction.ml': [(513,524)],
    'src/transform/prepare_for_counterexmp.ml': [(15,34)],
    'src/transform/libencoding.ml': [(263,276)],
    'src/core/trans.ml': [(46,53),(75,99),(114,136)],
    'src/core/decl.ml': [(409,419),(601,606)],
    'src/util/weakhtbl.ml': [(66,101)],
    'src/driver/call_provers.ml': [(205,226),(233,402)],
    'src/driver/driver.ml': [(119,148),(264,271)],
    'src/server/server-unix.c': [(346,398),(462,499),(517,544)],
    'src/gnat/gnat_report.ml': [(34,46),(211,219)],
    'src/gnat/gnat_checks.ml': [(469,482),(714,724),(1049,1084)],
    'src/gnat/gnat_main.ml': [(75,116)],
    'src/session/controller_itp.ml': [(517,536),(592,618)],
}


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def encoded(value):
    return json.dumps(value, indent=2, sort_keys=True) + '\n'


def proposition_audit(case):
    family = 'inline' if case == 'input_is_valid' else 'registration'
    prefix = f'{family}/{case}/capture/'
    archive = ROOT / ('docs/evidence/retained-why-save-state-capture-20261020/'
                      'capture-' + case.replace('_','-') + '.tar.gz')
    with tarfile.open(archive) as stream:
        blocks = {}
        for line in stream.extractfile(prefix + 'session-blocks.jsonl'):
            row = json.loads(line)
            raw = bytes.fromhex(row['payload_hex'])
            assert row['tag'] == row['header'] & 255
            assert row['words'] == row['header'] >> 10
            assert len(raw) == 8 * row['words']
            row['fields'] = struct.unpack('<'+'Q'*row['words'], raw)
            assert row['address'] not in blocks
            blocks[row['address']] = row
        chains = json.load(stream.extractfile(prefix + 'session-task-chains.json'))

    def fields(p, size=None):
        out = blocks[p]['fields']
        assert size is None or len(out) == size
        return out

    def seq(p):
        result, seen = [], set()
        while p != 1:
            assert p not in seen
            seen.add(p)
            x,p = fields(p,2)
            result.append(x)
        return result

    def mapping(p):
        if p == 1:
            return []
        l,k,v,r,h = fields(p,5)
        return mapping(l)+[(k,v)]+mapping(r)

    @lru_cache(None)
    def tv(ty):
        node,_ = fields(ty,2)
        tag = blocks[node]['tag']
        if tag == 0:
            return frozenset(fields(node,1))
        assert tag == 1
        _,args = fields(node,2)
        return frozenset().union(*(tv(t) for t in seq(args)))

    visited, binders, types, saved_images = set(), set(), set(), set()

    def check_type(ty):
        types.add(ty)
        assert not tv(ty), ('free type variable', case, ty)

    def variable(v):
        _,ty = fields(v,2)
        check_type(ty)

    def binding(p, quant=False):
        if p in binders:
            return
        binders.add(p)
        if quant:
            vl,info,tr,body = fields(p,4)
            for v in seq(vl): variable(v)
            for group in seq(tr):
                for term in seq(group): walk(term)
        else:
            v,info,body = fields(p,3)
            variable(v)
        free,saved = fields(info,2)
        for v,_ in mapping(free): variable(v)
        for v,t in mapping(saved):
            variable(v)
            saved_images.add(t)
            walk(t)
        walk(body)

    def walk(t):
        if t in visited:
            return
        visited.add(t)
        node,ty,_,_ = fields(t,4)
        if ty != 1: check_type(fields(ty,1)[0])
        if node & 1:
            assert node in (1,3)
            return
        tag = blocks[node]['tag']
        a = fields(node)
        if tag == 0: variable(a[0])
        elif tag == 1: pass
        elif tag == 2:
            for child in seq(a[1]): walk(child)
        elif tag == 3:
            for child in a: walk(child)
        elif tag == 4:
            walk(a[0]); binding(a[1])
        elif tag == 5:
            raise AssertionError(('Tcase in proposition',case,t))
        elif tag == 6: binding(a[0])
        elif tag == 7: binding(a[1],True)
        elif tag == 8:
            walk(a[1]); walk(a[2])
        elif tag == 9: walk(a[0])
        else: raise AssertionError(tag)

    declarations = {}
    for chain in chains.values():
        for row in chain:
            node,_ = fields(row['tdecl'],2)
            if blocks[node]['tag'] != 0: continue
            d, = fields(node,1)
            dn,_,_ = fields(d,3)
            if blocks[dn]['tag'] != 5: continue
            payload, = fields(dn,1)
            kind,pr,t = fields(payload,3)
            declarations[d] = {'kind':kind>>1,'formula':t,'symbol':pr}
    for d in declarations.values(): walk(d['formula'])
    return {'case':case,'propositions':len(declarations),
            'stored_terms':len(visited),'stored_binders':len(binders),
            'type_roots':len(types),'saved_image_roots':len(saved_images),
            'free_type_variables':0,'case_nodes':0,
            'scope':'all raw task propositions including hidden maps and binder variable types'}


def literal_overlap_audit():
    """All relative offsets, including whole-pattern containment cases."""
    packet = ROOT/'docs/evidence/retained-solver-response-adapter-20261020'
    loaded = json.loads((packet/'loaded-response-directives.json').read_text())
    families = {
        'cvc5': {
            'long': [('(error "','out of memory")')],
            'simple': ['cvc5 suffered a segfault',
                       'cvc5::internal::Minisat::OutOfMemoryException',
                       'CVC4 suffered a segfault','CVC4::BVMinisat::OutOfMemoryException',
                       'std::bad_alloc','Cannot allocate memory',
                       'interrupted by timeout','unknown (RESOURCEOUT)']},
        'z3': {
            'long': [('(error "','out of memory")'),
                     ('Maximal allocation counts ',' have been exceeded'),
                     ('(error "','number of configured allocations exceeded")')],
            'simple': ['Cannot allocate memory','interrupted by timeout']}}
    results = {}
    for driver,parts in families.items():
        text = '\n'.join(e['args'][0] for e in loaded[driver+'_gnatprove.drv'])
        checked = 0
        for literal in parts['simple']:
            assert all(literal not in other for other in parts['simple'] if other != literal)
        for prefix,suffix in parts['long']:
            assert prefix in text and suffix in text
            for literal in parts['simple']:
                assert literal in text
                for distance in range(1,len(literal)):
                    # Simple begins at -distance and crosses long-start 0.
                    width = min(len(prefix),len(literal)-distance)
                    assert literal[distance:distance+width] != prefix[:width]
                    # Long ends at 0; simple begins at -distance and crosses 0.
                    width = min(distance,len(suffix))
                    assert suffix[-width:] != literal[distance-width:distance]
                    checked += 2
        results[driver] = {'relative_offsets_checked':checked,'compatible_crossings':0,
                           'simple_delimiters_mutually_noncontained':True}
    return results


def composition_audit():
    result = json.loads((ROOT/'docs/evidence/retained-why-preinline-prefix-20261020/result.json').read_text())
    rows = []
    for row in result['cases']:
        full = (2*row['selected_ce_direct_Ident_sum'] + row['selected_ce_goal_binder_sum']
                + 2*row['selected_altergo_prefix_Ident_max'])
        stated = row['under_named_episode_and_seed_premises']
        assert full == stated['full_prefix_Ident_upper']
        removed = stated['already_completed_cvc5_prefix_allowance']
        assert removed == (row['selected_ce_direct_Ident_sum'] if row['case']=='input_is_valid' else 0)
        assert full-removed == stated['post_cut_prefix_Ident_upper']
        assert stated['global_escape_budget'] == 2
        rows.append({'case':row['case'],'full':full,'post_cut':full-removed,'removed_allowance':removed})
    total = result['under_named_source_cache_episode_and_seed_premises']
    assert sum(r['full'] for r in rows)==total['full_five_process_prefix_Ident_upper']
    assert sum(r['post_cut'] for r in rows)==total['post_five_cut_prefix_Ident_upper']
    assert not result['includes_R50_update_charge']
    assert not result['includes_pending_callback_charge']
    assert not result['includes_transform_lookup_initialization']
    assert not result['complete_inline_capacity'] and not result['complete_Ident_no_wrap']
    assert result['intended_parallel_seed_closure'] is False
    return {'cases':rows,'full_sum':sum(r['full'] for r in rows),
            'post_cut_sum':sum(r['post_cut'] for r in rows),
            'scope':'retained serial per-process direct Ident charges; one shared e<=2 budget per process'}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--write',action='store_true')
    args = ap.parse_args()
    inputs = json.loads((HERE/'inputs.json').read_text())
    for path,expected in inputs['files'].items():
        assert identity((ROOT/path).read_bytes()) == expected, path
    sources = []
    with tarfile.open(ROOT/WHY) as archive:
        for member,ranges in SOURCES.items():
            raw = archive.extractfile('why3/'+member).read()
            lines = raw.decode().splitlines(keepends=True)
            sources.append({'archive':WHY,'member':'why3/'+member,'identity':identity(raw),
                            'ranges':[{'first':a,'last':b,'text':''.join(lines[a-1:b])}
                                      for a,b in ranges]})
    with tarfile.open(ROOT/OCAML) as archive:
        member = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/weak.ml'
        raw = archive.extractfile(member).read()
        lines = raw.decode().splitlines(keepends=True)
        sources.append({'archive':OCAML,'member':member,'identity':identity(raw),
                        'ranges':[{'first':272,'last':294,'text':''.join(lines[271:294])}]})
    result = {'propositions':[proposition_audit(c) for c in
              ('put_line','put','first_or_default','is_message','input_is_valid')],
              'literal_overlaps':literal_overlap_audit(),
              'prefix_composition':composition_audit(),
              'frozen_files':len(inputs['files']),'source_members':len(sources)}
    for name,value in [('source-review.json',sources),('result.json',result)]:
        data = encoded(value)
        if args.write: (HERE/name).write_text(data)
        else: assert (HERE/name).read_text() == data, name
    print(json.dumps(result,sort_keys=True))


if __name__ == '__main__': main()

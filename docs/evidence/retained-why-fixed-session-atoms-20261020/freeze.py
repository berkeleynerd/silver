#!/usr/bin/env python3
"""Freeze existing projections and exact retained source/input identities.

This packages already-produced atom projections; it does not extract them or
run any native, logical-opening, binder/alpha, solver or source-fetch operation.
"""
import gzip
import json
from pathlib import Path
import runpy
import tarfile

HERE = Path(__file__).resolve().parent
M = runpy.run_path(str(HERE/'extract.py'))
REPO, identity = M['REPO'], M['identity']
E = HERE.parent
WHY = E/'retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = E/'retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
Z = E/'retained-why-interval-native-effects-20261019'
ORDER = ['put-line','put','first-or-default','is-message','input-is-valid']


def write(path,value):
    path.write_text(json.dumps(value,indent=2,sort_keys=True)+'\n')


def freeze():
    excerpts = []
    why = {
        'why3/src/core/ident.ml':[(16,27),(158,164)],
        'why3/src/core/term.ml':[(93,108),(222,254),(654,659)],
        'why3/src/core/decl.ml':[(285,287)],
        'why3/src/util/wstdlib.ml':[(79,84)],
        'why3/src/util/extset.ml':[(56,67)],
        'why3/src/util/extmap.ml':[(101,104)],
        'why3/src/util/number.ml':[(19,47)],
        'why3/src/util/constant.ml':[(16,20),(48,73)],
        'why3/src/util/bigInt.ml':[(13,18),(64,70)],
        'why3/src/session/termcode.ml':[(20,98),(340,430)],
    }
    def retain(path,member,ranges):
        if member:
            with tarfile.open(path) as archive:
                raw=archive.extractfile(member).read()
        else:
            raw=path.read_bytes()
        lines=raw.decode().splitlines()
        for first,last in ranges:
            assert 1 <= first <= last <= len(lines)
            excerpts.append(dict(path=str(path.relative_to(REPO)),member=member,
                file_identity=identity(raw),first=first,last=last,text='\n'.join(lines[first-1:last])))
    for member,ranges in why.items():
        retain(WHY,member,ranges)
    retain(OCAML,'ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/caml/mlvalues.h',[(142,161),(361,367)])
    retain(Z/'caml_z.c',None,[(116,175),(319,338),(381,399),(989,1086)])
    retain(Z/'z.ml',None,[(309,311)])
    retain(Z/'big_int_Z.ml',None,[(97,100)])
    write(HERE/'source-excerpts.json',excerpts)
    cases=[]
    packets=[]
    for stem in ORDER:
        path=HERE/(stem+'-atoms.json.gz')
        value=json.loads(gzip.decompress(path.read_bytes()))
        cert=value['saved_occurrence_certificate']
        row={k:value[k] for k in ['case','typed_graph_complete','numeric_components_complete',
            'term_constructor_counts','pattern_constructor_counts','original_name_bytes_min','original_name_bytes_max',
            'numeric_summary','constant_kinds','max_case_pattern_occurrences','term_attribute_summary',
            'goal_identifier_attribute_summary','proposition_and_explanation_requests_per_save','elapsed_seconds']}
        row.update(B_binders=value['imported_B_binders'],APn_visits=value['imported_APn_visits'],
            detached_visits=sum(v['detached'] for v in cert['visits']),
            stored_tasks=len(cert['tasks']),formula_roots=len(cert['formulas']),
            stored_terms=len(value['covered_term_pointers']),stored_patterns=len(value['pattern_pointers']),
            identifiers=len(value['identifiers']),constants=len(value['constants']),attributes=len(value['attributes']),
            shape_attribute_union={k:value['shape_attribute_union'][k] for k in ['count','sum_bytes']},
            max_numeric_native_buffer_bytes=5+64*value['numeric_summary']['used_limbs_max'],
            max_numeric_native_limb_copy_bytes=8*value['numeric_summary']['used_limbs_max'],
            unsupported_numeric_components=len(value['unsupported_numeric_components']),coverage_failures=value['coverage_failures'])
        cases.append(row)
        packets.append(dict(path=path.name,identity=identity(path.read_bytes())))
    write(HERE/'summary.json',dict(cases=cases,
        APn_visits=sum(r['APn_visits'] for r in cases),
        J_one_save_per_forest=sum(r['proposition_and_explanation_requests_per_save'] for r in cases),
        extraction_seconds=sum(r['elapsed_seconds'] for r in cases),
        explanation_prefixes_actual=None,explanation_prefixes_source_defaults=['expl:','infer:'],
        source_contract_scope='Retained source-family contracts; not historical installed-source identity.',
        scope='One save per retained logical forest. Input_Is_Valid is prior first cvc5 inline entry; four others are registration cuts. APn domain differs from scheduler task envelope153.'))
    files=[HERE/n for n in ['extract.py','check.py','freeze.py','summary.json','source-excerpts.json']]
    files += [M['OUTCOMES']/'check.py',M['OUTCOMES']/'atom-certificate.json',
        M['STATE']/'binder-certificate.json',M['STATE']/'capture.tar.gz',M['DOMAIN']/'capture-manifest.json',
        WHY,OCAML,Z/'caml_z.c',Z/'z.ml',Z/'big_int_Z.ml',Z/'zarith-retrieval.json',
        E/'retained-why-native-effect-completeness-20261019/source-family.json']
    for stem in ORDER[:-1]:
        files += [M['DOMAIN']/('capture-'+stem+'.tar.gz'),M['DOMAIN']/(stem+'-analysis.json')]
    write(HERE/'inputs.json',dict(schema=1,base_commit='b1c0d89f7b652a1c12e957caa986887be890786e',
        files=[dict(path=str(p.relative_to(REPO)),identity=identity(p.read_bytes())) for p in files],packets=packets,
        source_revisions=dict(why3='9390baf120ef260547dfa14f08e11c890b203d9c',
            ocaml='8eb41f72ded84df884c3671734c947f612091f84',zarith='667d742948914aa1f80d5ad5abb98bc412335e51')))


if __name__ == '__main__':
    freeze()

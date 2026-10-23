"""Identity, complete info-field inventory, strict spans and new arithmetic only."""
import json
import re
import tarfile
import time
from derive import derive, HERE, ROOT
from freeze import identity, WHY

def main():
    start=time.monotonic()
    manifest=json.loads((HERE/'inputs.json').read_bytes())
    for group in ('files','archives'):
        for p,expected in manifest[group].items():
            assert identity((ROOT/p).read_bytes())==expected,p
    witnesses=json.loads((HERE/'source-witnesses.json').read_bytes())
    spans=0
    by_archive={}
    for w in witnesses: by_archive.setdefault(w['archive'],[]).append(w)
    sources={}
    for archive,ws in by_archive.items():
        with tarfile.open(ROOT/archive) as tf:
            for w in ws:
                blob=tf.extractfile(w['member']).read()
                assert identity(blob)==w['identity']
                sources[w['member']]=blob.decode()
                lines=blob.decode().splitlines(keepends=True)
                for s in w['sections']:
                    a,z=s['first'],s['last']
                    assert type(a) is int and type(z) is int and 1<=a<=z<=len(lines)
                    assert ''.join(lines[a-1:z])==s['text']
                    spans+=1
    src=sources['why3/src/printer/smtv2.ml']
    record=src.split('type info = {',1)[1].split('}',1)[0]
    fields=re.findall(r'^\s*(?:mutable\s+)?(\w+)\s*:',record,re.M)
    field_roles={
        'info_syn':'info_syn (including sm0)', 'info_rliteral':'info_rliteral',
        'info_model':'info_model','info_in_goal':'vc_info/scalar info fields',
        'info_vc_term':'vc_info/scalar info fields','info_printer':'accepted R64/R65',
        'type_coercions':'type_coercions','type_fields':'type_fields','type_sorts':'type_sorts',
        'ty_tysymbol':'ty_tysymbol','info_version':'vc_info/scalar info fields',
        'meta_model_projection':'meta_model_projection','meta_record_def':'meta_record_def',
        'record_fields':'record_fields','constr_proj_id':'constr_proj_id','constructors':'constructors',
        'info_cntexample_need_push':'vc_info/scalar info fields','info_cntexample':'vc_info/scalar info fields',
        'info_incremental':'vc_info/scalar info fields','info_set_incremental':'vc_info/scalar info fields',
        'info_supports_reason_unknown':'vc_info/scalar info fields','info_supports_minimize':'vc_info/scalar info fields',
        'info_labels':'info_labels','incr_list_axioms':'incr_list_axioms','incr_list_ldecls':'incr_list_ldecls',
    }
    assert len(fields)==len(set(fields)) and set(fields)==set(field_roles)
    expected=json.loads((HERE/'result.json').read_bytes())
    actual=derive()
    assert actual==expected
    owner_names={r['owner'] for r in actual['cases'][0]['owners']}
    assert all(r in owner_names or r=='accepted R64/R65' for r in field_roles.values())
    for case in actual['cases']:
        assert {r['owner'] for r in case['owners']}==owner_names
        assert case['all_guards_pass'] and all(case['native_operand_guards'].values())
    census={'complete_info_fields':field_roles,
        'SMTv2_container_calls_lexical_inventory':sorted(set(re.findall(r'\b(?:Mstr|Mts|Mty|Mls|Mvs|Mid|Sid|Sattr|Sls|Stv|S)\.\w+',src))),
        'source_inventory_is_reachability_proof':False,
        'field_count':len(fields),'owner_family_rows':len(owner_names)}
    (HERE/'census.json').write_text(json.dumps(census,indent=2)+'\n')
    report={'status':'pass','elapsed_seconds':time.monotonic()-start,'provider_files':len(manifest['files']),
        'source_archives':len(manifest['archives']),'complete_source_members':len(witnesses),
        'strict_source_spans':spans,'complete_info_fields':len(fields),'owner_family_rows':len(owner_names),
        'cases':len(actual['cases']),'prior_checkers_models_native_solver_proof_capture_runs':0,
        'scope':'current packet source identity, field census and arithmetic; source induction pending review'}
    (HERE/'check-result.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))

if __name__=='__main__':
    main()

#!/usr/bin/env python3
"""Narrow independent source/identity checks for R52; no target execution."""
import argparse
from functools import lru_cache
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
SOURCES = {
    'src/gnat/gnat_expl.ml': [(75,168),(188,269),(417,573)],
    'src/gnat/gnat_main.ml': [(48,116)],
    'src/gnat/gnat_checks.ml': [(174,235),(598,661),(1022,1084)],
    'src/gnat/gnat_config.ml': [(24,42),(110,129),(567,575),(629,655)],
    'src/core/term.ml': [(266,281),(536,555),(626,675),(739,781),(799,831),(1282,1294)],
    'src/core/decl.ml': [(340,393),(409,419)],
    'src/transform/introduction.ml': [(23,52),(170,228)],
    'src/session/controller_itp.ml': [(340,392),(517,540),(592,651)],
    'src/driver/call_provers.ml': [(55,55),(280,307),(342,402),(448,458),(507,532)],
    'src/driver/driver.ml': [(101,148),(260,274)],
    'src/util/loc.ml': [(42,64)],
}


def identity(raw):
    return {'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}


def load(path):
    return json.loads(path.read_bytes())


def warning_audit(texts):
    """Check the finite kind-closure premise, not the OCaml control-flow proof."""
    text = texts['src/gnat/gnat_expl.ml']
    partition = text[text.index('let is_warning_kind r ='):text.index('type subp_entity')]
    ordinary, warning = partition.split('-> false')
    assert warning.count('-> true') == 1
    constructors = lambda s:set(re.findall(r'^\s*\|\s*(VC_\w+)\s*$',s,re.M))
    nonwarning = constructors(ordinary)
    warning = constructors(warning)
    assert len(warning)==5 and not warning & nonwarning
    parser = text[text.index('let check_kind_from_string s ='):text.index('let check_kind_to_ada')]
    mapping = dict(re.findall(r'\|\s*"([^"\n]+)"\s*->\s*(VC_\w+)',parser))
    assert set(mapping.values()) == nonwarning | warning
    assignments = re.findall(r'\bcheck_kind\s*<-\s*Some\s+(\w+)',text)
    assert assignments == ['kind','VC_Loop_Invariant_Init','VC_Loop_Invariant_Preserv']
    assert set(assignments[1:]) <= nonwarning
    check_record = text[text.index('type check ='):text.index('type extra_info =')]
    assert 'mutable' not in check_record
    defaults = [line.strip() for line in text.splitlines() if 'default_expl' in line and '(*' not in line]
    assert defaults == ['let default_expl =',
                        'let b = search_attrs read_vc_labels ({default_expl with check_id = None}) t in']
    cert = load(ROOT/'docs/evidence/retained-why-warning-exclusion-20261020/certificate.json')
    rows, observed = [],set()
    for case in cert['cases']:
        for item in case['check_labels']:
            label = bytes.fromhex(item['hex']).decode('ascii')
            assert label == item['label']
            tag,_,token,*_ = label.split(':')
            assert tag=='GP_Check'
            kind = mapping[token]
            assert kind in nonwarning and kind==item['kind'] and item['is_warning'] is False
            observed.add(token)
        assert len(case['check_labels'])==case['distinct_GP_Check_attributes']
        rows.append({'case':case['case'],'distinct_labels':len(case['check_labels']),
                     'forest_visits':case['raw_forest_visits'],
                     'registered_goal_upper':case['registered_goal_upper']})
    assert sum(r['forest_visits'] for r in rows)==161
    assert sum(r['registered_goal_upper'] for r in rows)==153
    return {'cases':rows,'observed_tokens':sorted(observed),
            'source_warning_kinds':sorted(warning),
            'extraction_assignments':assignments,'stored_check_kind_mutable':False,
            'warning_kind_constructor_closure':True,
            'scope':'Finite source kind closure plus accepted author raw-label binding; source control flow reviewed separately',
            'diagnostic_Loc_warning_excluded':False,
            'actual_queued_limits_proved_by_this_audit':False}


def parallel_subset_audit():
    """Independent map-free normalization of the claimed protected pairs.

    This intentionally handles no saved maps. The frozen positive subset has
    none, so no author strict comparator or generic delayed-frame claim is used.
    """
    packet=ROOT/'docs/evidence/retained-why-parallel-first-fill-20261020'
    summary=load(packet/'result.json')
    old=load(ROOT/'docs/evidence/retained-why-preinline-prefix-20261020/result.json')
    rows=[]
    for case,previous in zip(summary['cases'],old['cases']):
        slug=case['case'].replace('_','-')
        cert=load(packet/(slug+'-certificate.json'))
        graph=json.loads(gzip.decompress((ROOT/cert['graph_input']).read_bytes()))
        terms,bindings=graph['terms'],graph['bindings']

        @lru_cache(None)
        def canonical(index,scope=()):
            t=terms[index]
            kind,a=t['kind'],t['args']
            meta=(t['type'],tuple(t['attrs']),t['location'])

            def sub(i):return canonical(i,scope)

            def binder(i):
                b=bindings[i]
                assert not b['saved']
                inner=scope+tuple(b['variables'])
                tr=tuple(tuple(canonical(x,inner) for x in group) for group in b['triggers'])
                return (len(b['variables']),tr,canonical(b['body'],inner))

            if kind=='var':
                v,=a
                payload=('bound',scope[::-1].index(v)) if v in scope else ('free',v)
            elif kind in ('const','true','false'):payload=tuple(a)
            elif kind=='app':payload=(a[0],tuple(sub(x) for x in a[1]))
            elif kind in ('if','not'):payload=tuple(sub(x) for x in a)
            elif kind=='bin':payload=(a[0],sub(a[1]),sub(a[2]))
            elif kind=='let':payload=(sub(a[0]),binder(a[1]))
            elif kind=='quant':payload=(a[0],binder(a[1]))
            elif kind=='eps':payload=binder(a[0])
            else:raise AssertionError(kind)
            return (meta,kind,payload)

        for item in cert['live_raw_protected']:
            raw,candidate=item['raw_root_index'],item['candidate_root_index']
            assert canonical(raw)==canonical(candidate)
            initial=item['initial_same_key_objects']
            assert len(initial)==1 and initial[0]['declaration']==item['declaration']
            assert initial[0]['raw_declaration'] and initial[0]['compatible']
        for item in cert['true_shape_protected']:
            t=terms[item['candidate_root_index']]
            assert t['kind']=='true' and t['args']==[] and t['type'] is None
        direct=2*previous['selected_ce_direct_Ident_sum']+previous['selected_ce_goal_binder_sum']
        assert direct==case['prospective_fixed_input_prefix_Ident_upper']
        rows.append({'case':case['case'],'map_free_positive_pairs':len(cert['live_raw_protected']),
                     'true_roots':len(cert['true_shape_protected']),
                     'unresolved_keys':len(cert['unresolved']),
                     'conditional_prospective_direct_Ident':direct})
    assert sum(r['map_free_positive_pairs'] for r in rows)==660
    assert sum(r['true_roots'] for r in rows)==2
    assert sum(r['unresolved_keys'] for r in rows)==13
    assert sum(r['conditional_prospective_direct_Ident'] for r in rows)==309197
    assert summary['intended_parallel_stored_family_closed'] is False
    assert summary['intended_parallel_fixed_raw_input_and_initial_state_attachment_established'] is False
    assert summary['global_signal_escape_budget_per_process']==2
    assert summary['added_signal_escape_allowance']==0
    return {'cases':rows,'method':'Independent map-free structural normalization; no author comparator import',
            'generic_saved_map_comparison_tested':False,
            'parallel_stored_family_closed':False}


def config_credit_audit():
    packet=ROOT/'docs/evidence/retained-response-timing-config-20261020'
    result=load(packet/'result.json')
    recipe=load(packet/'recipe.json')
    assert result['configured_limits']==result['queued_limits']==[0.0,0,0]
    assert result['server_limits']==[0,0]
    assert result['parallel_transfer_claimed'] is False
    assert len(recipe['changed_lines'])==2
    for line in recipe['changed_lines']:
        original=bytes.fromhex(line['original_hex'])
        replacement=bytes.fromhex(line['replacement_hex'])
        assert original==b'time "why3cpulimit time : %s s"\n'
        assert replacement==b'(* time measurement removed  *)\n'
        assert len(original)==len(replacement)==line['bytes']==32
    count=result['file_names_upper']
    assert count==945214
    # Hash table capacities start at 16; resize when size > twice capacity.
    capacities=[16]
    while 2*capacities[-1]+1<=count:
        capacities.append(2*capacities[-1])
    array_words=4*sum(capacities)  # two tables, overcount initial tail arrays
    minor_array_words=4*sum(n for n in capacities if n<=256)
    header_closure_words=2*len(capacities)*128
    lexer_words=128*(2*6+5)
    assert array_words<=8*count
    assert minor_array_words+header_closure_words+lexer_words<16384
    moved_entries=sum(2*n+1 for n in capacities[:-1])
    assert moved_entries<=2*count+20
    assert 8*count+6*moved_entries+header_closure_words+lexer_words <=20*count+16384
    assert result['minor_credit_words']==result['major_credit_words']==8*count+16384==7578096
    assert result['reference_credit_entries']==20*count+16384==18920664
    rows=[]
    resources={r['case']:r for r in load(packet/'capture-resources.json')}
    for row in result['rows']:
        end=resources[row['case']]['end']
        prior=end['state']['stat_major_words']
        assert prior==row['prior_major_words'] and prior>=0
        minor=row['minor']+7578096
        major=row['major']+7578096
        all_major=major+prior
        refs=row['tables']['ref_table']+18920664
        assert minor==row['candidate_minor_upper']<2**28
        assert major==row['candidate_major_upper']<2**28
        assert all_major==row['candidate_arena_allocation_upper']<2**24
        assert refs==row['candidate_reference_upper']<2**25
        rows.append({'case':row['case'],'minor_upper':minor,'current_major_upper':major,
                     'all_major_upper':all_major,'reference_upper':refs})
    assert max(r['all_major_upper'] for r in rows)==8526220
    return {'rows':rows,'file_names_upper':count,'capacities':capacities,
            'two_table_array_payload_words':array_words,
            'small_array_header_closure_lexer_words':minor_array_words+header_closure_words+lexer_words,
            'per_table_moved_entries':moved_entries,
            'scope':'Independent geometric/arithmetic audit; source projection and allocator history reviewed separately',
            'parallel_transfer_claimed':False}


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--write',action='store_true')
    args=ap.parse_args()
    inputs=load(HERE/'inputs.json')
    for path,expected in inputs['files'].items():
        assert identity((ROOT/path).read_bytes())==expected,path
    excerpts,texts=[],{}
    with tarfile.open(ROOT/WHY) as archive:
        for member,ranges in SOURCES.items():
            raw=archive.extractfile('why3/'+member).read()
            texts[member]=raw.decode()
            lines=texts[member].splitlines(keepends=True)
            excerpts.append({'archive':WHY,'member':'why3/'+member,'identity':identity(raw),
                             'ranges':[{'first':a,'last':b,'text':''.join(lines[a-1:b])}
                                       for a,b in ranges]})
    result={'frozen_input_files':len(inputs['files']),
            'source_members':len(excerpts),'warning_closure':warning_audit(texts),
            'parallel_protected_subset':parallel_subset_audit(),
            'config_credit_arithmetic':config_credit_audit()}
    for name,value in [('source-review.json',excerpts),('result.json',result)]:
        data=json.dumps(value,indent=2,sort_keys=True)+'\n'
        if args.write:(HERE/name).write_text(data)
        else:assert (HERE/name).read_text()==data,name
    print(json.dumps(result,sort_keys=True))


if __name__=='__main__':
    main()

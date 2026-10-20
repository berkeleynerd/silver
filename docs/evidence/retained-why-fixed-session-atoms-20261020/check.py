#!/usr/bin/env python3
"""Check pins, direct atom-byte correspondence and imported count metadata.

No native execution, logical opening, binder/alpha replay or solver runs. The
extractor's typed closure traversal is reviewed separately; this check verifies
its frozen projection against raw blocks without traversing term edges again.
"""
import gzip
import json
from pathlib import Path
import runpy
import tarfile
import time

HERE = Path(__file__).resolve().parent
M = runpy.run_path(str(HERE/'extract.py'))
REPO, identity, load_case = M['REPO'], M['identity'], M['load_case']
BASE = M['BASE']


def read(path):
    return json.loads(path.read_bytes())


def check():
    start = time.perf_counter()
    inputs = read(HERE/'inputs.json')
    for row in inputs['files']:
        assert identity((REPO/row['path']).read_bytes()) == row['identity'], row['path']
    for row in read(HERE/'source-excerpts.json'):
        path = REPO/row['path']
        if row.get('member'):
            with tarfile.open(path) as archive:
                raw = archive.extractfile(row['member']).read()
        else:
            raw = path.read_bytes()
        assert identity(raw) == row['file_identity']
        assert '\n'.join(raw.decode().splitlines()[row['first']-1:row['last']]) == row['text']
    results = []
    summary = read(HERE/'summary.json')
    for index, packet in enumerate(inputs['packets']):
        path = HERE/packet['path']
        assert identity(path.read_bytes()) == packet['identity']
        value = json.loads(gzip.decompress(path.read_bytes()))
        cert, blocks, provenance, _ = load_case(value['case'])
        assert value['provenance'] == provenance
        assert value['saved_occurrence_certificate'] == cert
        assert value['imported_B_binders'] == cert['B_binders']
        assert value['imported_APn_visits'] == len(cert['visits'])
        assert value['typed_graph_complete'] and value['numeric_components_complete']
        assert not value['coverage_failures'] and not value['unsupported_numeric_components']
        raw = BASE(blocks)
        for pointer in value['read_pointers']:
            raw.row(pointer)
        assert set(value['formula_roots']) <= set(value['covered_term_pointers'])
        assert sum(value['term_constructor_counts'].values()) == len(value['covered_term_pointers'])
        assert sum(value['pattern_constructor_counts'].values()) == len(value['pattern_pointers'])
        for pointer, atom in value['identifiers'].items():
            name, attrs, _, _ = raw.fields(int(pointer),4)
            assert atom == dict(string_pointer=name,name_hex=raw.string(name).hex(),length=len(raw.string(name)))
            assert value['identifier_attributes'][pointer] == [k for k,_ in raw.mapping(attrs)]
        for pointer, attrs in value['term_attributes'].items():
            assert attrs == [k for k,_ in raw.mapping(raw.fields(int(pointer),4)[2])]
        for pointer, atom in value['attributes'].items():
            string, tag = raw.fields(int(pointer),2)
            assert atom == dict(string_pointer=string,hex=raw.string(string).hex(),bytes=len(raw.string(string)),
                attr_tag=tag >> 1,attr_tag_word=tag)
        for pointer, atom in value['constants'].items():
            kind = raw.row(int(pointer))[0]['tag']
            enclosed, = raw.fields(int(pointer),1,kind)
            assert atom['kind'] == ('int','real','string')[kind]
            if kind == 2:
                assert atom['hex'] == raw.string(enclosed).hex()
                continue
            if kind == 0:
                literal, word = raw.fields(enclosed,2)
                assert atom['literal_kind'] == literal >> 1
                words = [word]
            else:
                _, real = raw.fields(enclosed,2)
                words = raw.fields(real,3)
            assert len(words) == len(atom['parts'])
            for word, part in zip(words,atom['parts']):
                if word & 1:
                    number = raw.integer(word)
                    assert part['representation'] == 'immediate_OCaml_int'
                    assert part['raw_word'] == word
                else:
                    row, data = raw.row(word)
                    assert row['tag'] == 255 and part['payload_hex'] == data.hex()
                    header = int.from_bytes(data[8:16],'little')
                    used = header & ((1 << 63)-1)
                    assert part['used_limbs'] == used and 1 <= used <= row['words']-2
                    magnitude = int.from_bytes(data[16:16+8*used],'little')
                    number = -magnitude if header >> 63 else magnitude
                    assert part['bit_length_upper'] == 64*used
                    assert part['decimal_bytes_upper'] == 64*used+1
                    assert part['representation'] == 'heap_Zarith_custom'
                assert part['value'] == str(number)
                assert part['decimal_bytes'] == len(str(number))
                assert part['absolute_decimal_digits'] == len(str(abs(number)))
                assert part['bit_length'] == abs(number).bit_length()
        proposition_ids = set()
        for task_id, task in cert['tasks'].items():
            assert task['propositions'][0]['formula'] == task['goal_formula']
            assert task['propositions'][0]['kind'] == 2
            identifier, = raw.fields(task['propositions'][0]['symbol'],1)
            assert value['goal_identifier_by_task'][task_id] == identifier
            proposition_ids.update(raw.fields(p['symbol'],1)[0] for p in task['propositions'])
        assert value['proposition_identifier_pointers'] == sorted(proposition_ids)
        term_attrs = set().union(*map(set,value['term_attributes'].values()))
        prop_attrs = set().union(*(set(value['identifier_attributes'][str(p)]) for p in proposition_ids))
        assert value['term_attribute_union'] == sorted(term_attrs)
        assert value['proposition_identifier_attribute_union'] == sorted(prop_attrs)
        union = term_attrs | prop_attrs
        assert value['shape_attribute_union'] == dict(pointers=sorted(union),count=len(union),
            sum_bytes=sum(value['attributes'][str(a)]['bytes'] for a in union))
        J = sum(len(cert['tasks'][str(v['task'])]['propositions'])+1 for v in cert['visits'] if not v['detached'])
        assert value['proposition_and_explanation_requests_per_save'] == J
        assert value['imported_shape_term_visits_per_task'] == {
            task:sum(cert['formulas'][str(p['formula'])]['opened_term_occurrences'] for p in row['propositions'])
            for task,row in cert['tasks'].items()}
        assert value['explanation_prefixes']['values'] is None
        summarized = summary['cases'][index]
        for key in ['case','typed_graph_complete','numeric_components_complete','term_constructor_counts',
                    'pattern_constructor_counts','original_name_bytes_min','original_name_bytes_max',
                    'numeric_summary','constant_kinds','max_case_pattern_occurrences','term_attribute_summary',
                    'goal_identifier_attribute_summary','proposition_and_explanation_requests_per_save','elapsed_seconds']:
            assert summarized[key] == value[key]
        for key, expected in dict(B_binders=cert['B_binders'],APn_visits=len(cert['visits']),
            detached_visits=sum(v['detached'] for v in cert['visits']),stored_tasks=len(cert['tasks']),
            formula_roots=len(cert['formulas']),stored_terms=len(value['covered_term_pointers']),
            stored_patterns=len(value['pattern_pointers']),identifiers=len(value['identifiers']),
            constants=len(value['constants']),attributes=len(value['attributes'])).items():
            assert summarized[key] == expected
        assert summarized['shape_attribute_union'] == {k:value['shape_attribute_union'][k] for k in ['count','sum_bytes']}
        assert summarized['max_numeric_native_buffer_bytes'] == 5+64*value['numeric_summary']['used_limbs_max']
        assert summarized['max_numeric_native_limb_copy_bytes'] == 8*value['numeric_summary']['used_limbs_max']
        results.append(dict(case=value['case'],J=J,read_blocks=len(value['read_pointers']),
            terms=len(value['covered_term_pointers']),identifiers=len(value['identifiers']),
            constants=len(value['constants']),attributes=len(value['attributes'])))
    assert [r['case'] for r in results] == [r['case'] for r in summary['cases']]
    assert summary['APn_visits'] == sum(r['APn_visits'] for r in summary['cases'])
    assert summary['J_one_save_per_forest'] == sum(r['J'] for r in results)
    return dict(passed=True,cases=results,elapsed_seconds=time.perf_counter()-start,
        platform='Linux x86_64',native_executions=0,session_replays=0,binder_recomputations=0,
        alpha_replays=0,source_fetches=0,solver_runs=0)


if __name__ == '__main__':
    print(json.dumps(check(),indent=2,sort_keys=True))

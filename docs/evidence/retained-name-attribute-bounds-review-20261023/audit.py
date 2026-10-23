"""Independent final-freeze audit; imports no author or predecessor code.

Reviewed source reasoning lives in the report. Identity/finite arithmetic
checks here are not a source semantics or native refinement proof.
"""
import gzip
import hashlib
import json
from pathlib import Path
import platform
import re
import struct
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = ROOT / 'docs/evidence'
HS = EV / 'retained-why-hsattr-demand-20261023'
RAW = EV / 'retained-why-raw-name-length-20261023'
MAX_INT, MAX_ARRAY = 2**62-1, 2**54-1
B = 2**28


def ident(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def read(path):
    return json.loads(path.read_text())


def weak(q):
    a, b = max(5003, 3*5003//2+3, 3*q+3), 3*q//2+3
    return dict(live_entries_upper=q, individual_outer_array_length_upper=a,
                individual_bucket_length_upper=b, outer_growth_multiply_upper=3*a,
                bucket_growth_multiply_upper=3*b,
                shrink_multiply_plus_two_absolute_upper=2*b+6,
                oversize_and_rover_upper=a, find_or_equality_calls_per_request_upper=b)


def source_check(packet, archives):
    checked = []
    for witness in packet:
        raw = archives[witness['archive']][witness['member']]
        assert ident(raw) == witness['identity']
        lines = raw.decode().splitlines(keepends=True)
        assert len(lines) == witness['lines']
        spans = []
        for excerpt in witness['excerpts']:
            first, last = excerpt['first'], excerpt['last']
            assert type(first) is int and type(last) is int
            assert 1 <= first <= last <= len(lines), (witness['member'], first, last, len(lines))
            text = ''.join(lines[first-1:last])
            assert text == excerpt['text'] and ident(text.encode()) == excerpt['identity']
            spans.append([first, last])
        checked.append(dict(member=witness['member'], identity=ident(raw), actual_lines=len(lines), ranges=spans))
    return checked


def attribute_origins():
    origins = read(HS / 'origins.json')
    counts = []
    for row in origins['cases']:
        case = row['case']
        graph_file = EV / 'retained-why-preinline-prefix-20261020' / (case+'-graph.json.gz')
        types_file = EV / 'retained-why-fixed-inline-family-20261020' / (case+'-types.json')
        graph, types = json.loads(gzip.decompress(graph_file.read_bytes())), read(types_file)
        assert ident(graph_file.read_bytes()) == row['graph_identity']
        assert ident(types_file.read_bytes()) == row['signature_projection_identity']
        groups = {
            'all_stored_and_candidate_terms': graph['terms'],
            'all_graph_variables': list(graph['variables'].values()),
            'all_graph_symbols': list(graph['symbols'].values()),
            'declaration_type_and_signature_identifiers': list(types['identifiers'].values()),
        }
        for name, objects in groups.items():
            attrs = [x['attrs'] for x in objects]
            union = sorted(set(a for aa in attrs for a in aa))
            expected = row['groups'][name]
            assert len(objects) == expected['records']
            assert union == expected['distinct_strings']
            assert not any(a.startswith('at:') for a in union)
            assert expected['at_prefix_strings'] == []
            assert max(map(len, attrs), default=0) == expected['maximum_cardinality']
        names = sorted(set(a[9:] for t in graph['terms'] for a in t['attrs'] if a.startswith('hyp_name:')))
        assert names == row['hyp_name_values']
        assert max(map(len, names), default=0) == row['hyp_name_value_bytes_max'] <= 13
        assert all(str(i) in types['identifiers'] for d in types['declarations'].values() for i in d['news'])
        assert all(str(s['identifier']) in types['identifiers'] for s in types['signatures'].values())
        counts.append({'case': case, 'records': {name: len(objects) for name, objects in groups.items()},
                       'hyp_name_values': names})
    assert origins['continuing_hyp_name_value_bytes_upper'] == 13
    return origins, counts


def attribute_arithmetic():
    result = read(HS / 'result.json')
    combined = read(EV / 'retained-combined-parallel-startup-20261020/projection.json')
    logging = read(EV / 'retained-parallel-logging-prefix-20261020/cut-projection.json')
    library = read(EV / 'retained-why-library-publication-bound-20261020/bound.json')
    assert library['direct_root_bounds']['real']['expanded_source_bytes'] == 807447
    assert combined['credits']['minor_words'] == 7582192
    checked = []
    for row in result['cases']:
        case = row['case']
        family = read(EV / 'retained-why-fixed-inline-family-20261020' / (case+'-family.json'))
        certificate = read(EV / 'retained-why-preinline-prefix-20261020' / (case+'-certificate.json'))
        roots = [r['goal'] for r in family['stages']['raw']['roots']]
        selected = {r['goal']: r for r in certificate['selected']}
        assert len(roots) == len(set(roots)) == family['registered_roots'] == row['registered_roots']
        demand = [selected[g]['ce_direct_Ident_upper'] for g in roots]
        episodes = 3*len(roots)+2
        ce, parser = 2*sum(demand)+2*max(demand), 8*episodes*807447
        q = B+ce+parser
        domain = case.replace('-', '_')
        minor = combined['domains'][domain]['bounds']['minor_words']
        assert minor == logging[domain]['prospective_end_credits']['minor_words']+7582192
        assert row['prefix_minor_words_upper'] == minor < B
        assert row['retained_j12_pid'] == logging[domain]['captured_pid']
        assert row['prefix_requests_upper'] == row['prefix_next_tag_upper'] == B
        assert row['episodes_upper'] == episodes
        assert row['expanded_parser_source_slots'] == 2*episodes*807447
        assert row['suffix_requests'] == dict(library_parser=parser, CE_unused_copy=ce,
                                             other_preparation=0, solver_request_printer=0,
                                             saves=0, other_callbacks_and_shutdown=0)
        assert row['suffix_requests_upper'] == ce+parser
        assert row['lifetime_requests_and_increments_upper'] == q
        assert row['counter'] == dict(initial=0, increments_upper=q, final_upper=q, signed_ocaml_int_fits=True)
        for key, count in [('prefix_backing_envelope', B), ('backing', q)]:
            for field, value in weak(count).items():
                assert row[key][field] == value
        backing = weak(q)
        a, b = backing['individual_outer_array_length_upper'], backing['individual_bucket_length_upper']
        assert q <= MAX_INT and 3*max(a,b)+6 <= MAX_INT
        assert a <= MAX_ARRAY and b+2 <= MAX_ARRAY-2
        assert row['native_owner_operands_fit'] and not row['actual_whole_process_headroom']
        checked.append(dict(case=case, combined_minor_words=minor, library_requests=parser,
                            CE_requests=ce, lifetime_requests=q, outer_array=a))
    assert result['budgets'] == dict(escape=2, save_entering_callbacks=2, saves=3,
                                    renewed_at_stage_or_owner_boundary=False)
    assert not result['all_seven_owner_composition_claimed']
    return result, checked


def joined_owners(attrs):
    folder = EV / 'retained-name-attribute-round65-20261023'
    joined = read(folder / 'composition-result.json')
    historical = read(folder / 'candidate-composition-result.json')
    six = read(EV / 'retained-six-owner-round63-20261023/candidate-composition-result.json')
    accepted = read(EV / 'retained-six-owner-round63-20261023/integration-result.json')
    assert accepted['new_source_contracts_independently_accepted']
    for path, expected in joined['inputs'].items():
        assert ident((EV / path).read_bytes()) == expected
    assert joined['cases'] == historical['cases']
    assert joined['inputs']['retained-why-hsattr-demand-20261023/result.json'] != historical['inputs']['retained-why-hsattr-demand-20261023/result.json']
    assert joined['budgets'] == six['budgets'] == dict(per_process_escape=2,
        save_entering_callbacks_upper=2, saves_upper=3, allowance_renewed_at_stage_boundary=False)
    assert six['native_limits']['max_array_length'] == MAX_ARRAY
    assert six['native_limits']['max_ephemeron_keys'] == MAX_ARRAY-2
    six_rows = {r['case']: r for r in six['cases']}
    attr_rows = {r['case']: r for r in attrs['cases']}
    assert len(joined['cases']) == len(six_rows) == len(attr_rows) == 5
    for row in joined['cases']:
        s, a = six_rows[row['case']], attr_rows[row['case']]
        assert s['attachment']['prospective_route'] == 'combined quiet/timeless/J12/logging'
        assert s['attachment']['target_cut'] == 'registration before preparation'
        assert a['target_cut'] == 'prospective combined quiet/timeless/J12/logging registration'
        assert row['retained_j12_pid'] == a['retained_j12_pid'] == s['attachment']['retained_j12_pid']
        assert row['registered_roots'] == a['registered_roots'] == s['demand']['registered_roots']
        assert row['episodes_upper'] == a['episodes_upper'] == s['demand']['preparation_episodes_upper']
        assert row['conditional_transfers'] == {
            **s['conditional_transfers'],
            'Ident.Hsattr': dict(counter=a['counter'], backing=a['backing'], native_operands_fit=True)}
        assert len(row['conditional_transfers']) == 7
        assert row['Hsattr_lifetime_from_empty_attached_once']
        assert not row['actual_whole_process_headroom']
    assert not joined['second_episode_multiplier']
    assert not joined['whole_capacity_rule_complete'] and not joined['all_mutable_owners_closed']
    assert not joined['aggregate_RAM_gate']
    return dict(cases=5, named_owners=7, original_six_owner_transfers_unchanged=True,
                Hsattr_lifetime_attached_once=True, repaired_input_digest_checked=True,
                original_candidate_preserved=True, first_violation_join_is_conditional=True)


def raw_capture(row):
    case, capture = row['case'], row['capture']
    with tarfile.open(ROOT / capture['archive']) as archive:
        payload = archive.extractfile(capture['member']).read()
        assert ident(payload) == capture['identity']
        records = [json.loads(line) for line in payload.splitlines()]
        blocks = {r['address']: r for r in records}
        assert len(blocks) == len(records)
        if capture['additional_member']:
            extra = archive.extractfile(capture['additional_member']).read()
            assert ident(extra) == capture['additional_member_identity']
            for address, block in json.loads(extra)['blocks'].items():
                p = int(address)
                blob = bytes.fromhex(block['payload_hex']) if 'payload_hex' in block else struct.pack('<'+'Q'*len(block['fields']), *block['fields'])
                if p in blocks:
                    assert (blocks[p]['header'], bytes.fromhex(blocks[p]['payload_hex'])) == (block['header'], blob)
                else:
                    blocks[p] = {**block, 'payload_hex': blob.hex()}

    def block(p):
        r = blocks[p]
        data = bytes.fromhex(r['payload_hex'])
        assert r['tag'] == r['header'] & 255
        assert r['words'] == r['header'] >> 10 and len(data) == r['words']*8
        return r, data

    def fields(p, count, tag=0):
        r, data = block(p)
        assert (r['words'], r['tag']) == (count, tag), (p, count, tag, r)
        return struct.unpack('<'+'Q'*count, data)

    def string(p):
        r, data = block(p)
        assert r['tag'] == 252 and data and data[-1] < 8
        length = len(data)-data[-1]-1
        assert length >= 0 and data[length] == 0
        return data[:length]

    def sequence(p):
        result, seen = [], set()
        while p != 1:
            assert p not in seen
            seen.add(p)
            value, p = fields(p, 2)
            result.append(value)
        return result

    def mapping(p):
        stack, seen, result = [p], set(), []
        while stack:
            p = stack.pop()
            if p == 1:
                continue
            assert p not in seen
            seen.add(p)
            left, key, value, right, height = fields(p, 5)
            assert height & 1
            result.append((key, value))
            stack.extend([left, right])
        return result

    graph_path = EV / 'retained-why-preinline-prefix-20261020' / (case+'-graph.json.gz')
    type_path = EV / 'retained-why-fixed-inline-family-20261020' / (case+'-types.json')
    graph, types = json.loads(gzip.decompress(graph_path.read_bytes())), read(type_path)
    assert ident(graph_path.read_bytes()) == row['accepted_graph_identity']
    assert ident(type_path.read_bytes()) == row['accepted_types_identity']
    metadata_path = EV / 'retained-why-parallel-symbol-exclusion-20261020' / (case+'-metadata.json')
    metadata = read(metadata_path)
    assert ident(metadata_path.read_bytes()) == row['accepted_metadata_inventory_identity']
    map_path = ROOT / row['address_map_file']
    assert ident(map_path.read_bytes()) == row['address_map_identity']
    address_map = json.loads(gzip.decompress(map_path.read_bytes()))
    reverse = {v: int(k) for k,v in address_map.items()}
    assert len(reverse) == len(address_map)
    work, seen, ids = [], set(), set()
    range_rows = []
    for event in metadata['update_events']:
        assert event['meta'] not in ('introduced_lsymbol', 'introduced_prsymbol', 'float_type')
        if event['meta'] == 'range_type':
            assert event['origin'] == 'raw'
            (kt, nt), (kl, nl) = event['arguments']
            assert (kt,kl) == (1,2)
            ot, ol = reverse[nt], reverse[nl]
            work.extend([('ts',ot), ('ls',ol)])
            range_rows.append(dict(new_type_symbol=nt, old_type_symbol=ot, new_logic_symbol=nl, old_logic_symbol=ol))
    assert range_rows == row['range_metadata_origin_rows']
    work += [('decl', d['declaration']) for d in graph['declarations']]
    work += [('ls', int(p)) for p in graph['symbols']]
    work += [('vs', int(p)) for p in graph['variables'] if int(p)>0]
    work += [('ty', v['type']) for v in graph['variables'].values()]
    work += [('ty', t['type']) for t in graph['terms'] if t['type'] is not None]
    work += [('id', int(p)) for p in types['identifiers']]
    # Independent breadth-first field closure, rather than importing project.py.
    while work:
        role, p = work.pop()
        if (role,p) in seen:
            continue
        seen.add((role,p))
        if role == 'id':
            ids.add(p)
        elif role in ('tv','pr'):
            work.append(('id',fields(p,1)[0]))
        elif role == 'vs':
            name, typ = fields(p,2)
            work.extend([('id',name), ('ty',typ)])
        elif role == 'ls':
            name,args,result,_,_ = fields(p,5)
            work.append(('id',name))
            work += [('ty',a) for a in sequence(args)]
            if result != 1:
                work.append(('ty',fields(result,1)[0]))
        elif role == 'ty':
            node,_ = fields(p,2)
            if block(node)[0]['tag'] == 0:
                work.append(('tv',fields(node,1)[0]))
            else:
                head,args = fields(node,2,1)
                work.append(('ts',head))
                work += [('ty',a) for a in sequence(args)]
        elif role == 'ts':
            name,params,definition = fields(p,3)
            work.append(('id',name))
            work += [('tv',v) for v in sequence(params)]
            if definition != 1:
                kind = block(definition)[0]['tag']
                assert kind in (0,1,2)
                if kind == 0:
                    work.append(('ty',fields(definition,1)[0]))
        else:
            assert role == 'decl'
            node,news,_ = fields(p,3)
            work += [('id',key) for key,_ in mapping(news)]
            kind = block(node)[0]['tag']
            value = fields(node,1,kind)[0]
            if kind == 0:
                work.append(('ts',value))
            elif kind == 1:
                for data in sequence(value):
                    head,constructors = fields(data,2)
                    work.append(('ts',head))
                    for c in sequence(constructors):
                        symbol,projections = fields(c,2)
                        work.append(('ls',symbol))
                        work += [('ls',fields(v,1)[0]) for v in sequence(projections) if v != 1]
            elif kind == 2:
                work.append(('ls',value))
            elif kind == 3:
                for definition in sequence(value):
                    symbol,body = fields(definition,2)
                    assert fields(body,3)[0] == symbol
                    work.append(('ls',symbol))
            elif kind == 4:
                _,entries = fields(value,2)
                for entry in sequence(entries):
                    symbol,clauses = fields(entry,2)
                    work.append(('ls',symbol))
                    work += [('pr',fields(c,2)[0]) for c in sequence(clauses)]
            else:
                assert kind == 5
                work.append(('pr',fields(value,3)[1]))
    assert ids == set(map(int,row['identifiers']))
    lengths = []
    for p in ids:
        name,attrs,_,tag = fields(p,4)
        assert tag & 1
        raw_name = string(name)
        stored = row['identifiers'][str(p)]
        assert stored['string_pointer'] == name
        assert raw_name.decode('ascii') == stored['name'] and len(raw_name) == stored['bytes']
        values = []
        for a,unit in mapping(attrs):
            assert unit == 1
            text,atag = fields(a,2)
            assert atag & 1
            values.append(string(text).decode('ascii'))
        assert sorted(values) == stored['attrs']
        lengths.append(len(raw_name))
    positive = {v['name'] for p,v in graph['variables'].items() if int(p)>0}
    allowed = positive | {v+"'unused" for v in positive}
    assert all(v['name'] in allowed for p,v in graph['variables'].items() if int(p)<0)
    assert max(lengths) == row['initial_all_identifier_bytes_max']['bytes']
    return dict(case=case, identifier_records=len(ids), original_name_max=max(lengths), range_metadata_joins=len(range_rows))


def raw_names(archives):
    manifest, result = read(RAW / 'inputs.json'), read(RAW / 'result.json')
    providers = {}
    for path, expected in manifest['files'].items():
        actual = ident((ROOT / path).read_bytes())
        assert actual == expected, path
        providers[path] = actual
    for item in manifest['hyp_name_provider']:
        data = (RAW / item['retained_copy']).read_bytes()
        assert ident(data) == item['identity']
        assert data == (ROOT / item['path']).read_bytes()
        assert data == subprocess.check_output(['git','show',item['commit']+':'+item['path']], cwd=ROOT)
    checked_sources = []
    for w in read(RAW / 'source-witnesses.json'):
        raw = archives[w['archive']][w['member']]
        assert ident(raw) == w['identity']
        lines = raw.decode().splitlines(keepends=True)
        ranges = []
        for s in w['sections']:
            first,last = s['first'],s['last']
            assert type(first) is int and type(last) is int and 1 <= first <= last <= len(lines)
            assert ''.join(lines[first-1:last]) == s['text']
            ranges.append([first,last])
        checked_sources.append(dict(member=w['member'], identity=ident(raw), actual_lines=len(lines), ranges=ranges))
    drivers = EV / 'retained-solver-request-bytes-20261020'
    driver_names = read(drivers / 'driver-inputs.json')
    for name in driver_names:
        text = (drivers / 'drivers' / name).read_text()
        assert not any(t in text for t in ('introduced_lsymbol','introduced_prsymbol','range_type','float_type'))
    prior = {r['case']:r for r in read(EV / 'retained-why-printer-name-tables-20261023/result.json')['cases']}
    cases = []
    for row in result['cases']:
        names = read(RAW / (row['case']+'-names.json'))
        measured = raw_capture(names)
        m, n = measured['original_name_max'], prior[row['case']]['candidate']['all_cached_suffixes_and_reached_suffix_operands_upper']
        L, prop = max(m+7,8), max(m+11,14,13)
        base = max(22,5,2*(L+5))
        candidate = base+len(str(n))
        assert row['raw_name_L_at_printer_entry'] == names['L_interface'] == L
        assert row['raw_proposition_name_L_pr'] == prop and row['L_pr_hyp_name_input'] == 13
        assert row['raw_printer_created_projection_name_bytes_upper'] == L+5
        assert row['sanitized_or_blacklist_base_bytes_upper'] == base
        assert row['candidate_or_printed_unique_name_bytes_upper'] == candidate
        assert row['suffix_operand_upper'] == n
        assert row['integer_and_table_guards'] == prior[row['case']]['integer_and_table_guards']
        assert all(row['integer_and_table_guards'].values()) and row['name_string_operand_guard']
        assert L+5 <= 2**57-9 and candidate <= 2**57-9
        assert measured['identifier_records'] == row['captured_identifiers']
        cases.append({**measured, 'L':L, 'L_pr':prop, 'printed_name_bytes':candidate})
    assert result['one_process_global_escaping_exception_budget'] == 2
    assert result['save_entering_callbacks'] == 2 and result['saves_upper'] == 3
    assert not any(result[k] for k in ('budget_renewed','full_printer_capacity','whole_119_capacity',
                                      'name_uniqueness_semantics_claimed','aggregate_RAM_gate'))
    return providers, checked_sources, cases


def main():
    started = time.monotonic()
    config = read(HERE / 'targets.json')
    identities = {}
    for target in config['targets']:
        for path in target['paths']:
            data = (ROOT / path).read_bytes()
            committed = subprocess.check_output(['git', 'show', target['commit']+':'+path], cwd=ROOT)
            assert data == committed, (target['commit'], path)
            identities[path] = ident(data)
    providers = {}
    for path, expected in read(HS / 'inputs.json')['files'].items():
        actual = ident((ROOT / path).read_bytes())
        assert actual == expected, path
        providers[path] = actual
    packet = read(HS / 'source-witnesses.json')
    archive_names = {w['archive'] for w in packet['witnesses']}
    archive_names.add('docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz')
    archives = {}
    for path in archive_names:
        with tarfile.open(ROOT / path) as archive:
            archives[path] = {m.name: archive.extractfile(m).read() for m in archive.getmembers() if m.isfile()}
    source = archives['docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz']
    inventory = {name: ident(raw) for name, raw in source.items()
                 if name.startswith('why3/') and name.endswith(('.ml', '.mli', '.mll', '.mly'))}
    assert inventory == {m['member']: m['identity'] for m in packet['source_members']}
    pattern = re.compile(r'\b(?:create_attribute|attribute_of_sexp|create_model_trace_attr|create_written_attr|create_call_result_attr|create_eid_attr|transform_model_trace_attr|append_to_model_element_name|append_to_model_trace_attr|compute_model_trace_field|suffix_attr_name|Hsattr)\b')
    references = [dict(member=name, line=n, text=line) for name in inventory
                  for n, line in enumerate(source[name].decode().splitlines(), 1) if pattern.search(line)]
    assert references == packet['reference_census']
    witnesses = source_check(packet['witnesses'], archives)
    origins, origin_counts = attribute_origins()
    for library in origins['libraries']:
        raw = archives['docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz'][library['member']]
        assert ident(raw) == library['identity']
        text = raw.decode()
        assert '[@' not in text and not re.search(r'\b(old|at)\b', text)
        matches = list(re.finditer(r'\b(requires|ensures|assert|assume|check|invariant|variant)\b', text))
        assert [m.group() for m in matches] == library['annotation_keywords']
        assert all(text[m.end():].lstrip().startswith('{') for m in matches)
    attrs, attr_rows = attribute_arithmetic()
    join = joined_owners(attrs)
    raw_providers, raw_sources, raw_rows = raw_names(archives)
    for path, identity in raw_providers.items():
        assert path not in providers or providers[path] == identity
        providers[path] = identity
    result = dict(targets=config, exact_inputs=identities, providers=providers,
                  Hsattr_source_members=len(inventory), Hsattr_reference_rows=len(references),
                  Hsattr_witnesses=witnesses, attribute_origins=origin_counts,
                  Hsattr_arithmetic=attr_rows, seven_owner_join=join,
                  raw_name_sources=raw_sources, raw_name_arithmetic=raw_rows, host=platform.platform(),
                  source_argument_machine_checked=False,
                  author_predecessor_native_solver_proof_capture_replays=0,
                  elapsed_seconds=time.monotonic()-started)
    (HERE / 'audit-result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: v for k, v in result.items() if k not in
                     ('targets','exact_inputs','providers','Hsattr_witnesses','attribute_origins','raw_name_sources')}, indent=2))


if __name__ == '__main__':
    main()

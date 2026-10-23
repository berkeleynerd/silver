"""One independent finite/source-identity audit of the two reviewed interfaces.

Read Git blobs and retained archives only. Never import an author/predecessor
program or execute Why3. The source argument is separately reviewed reasoning.
"""
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile
import time

ROOT = Path(sys.argv[1]).resolve()
LIBRARY, CALLBACK, COMBINED = sys.argv[2:5]
HERE = Path(__file__).resolve().parent
EV = 'docs/evidence/'
LP = EV + 'retained-why-library-constructors-20261023/'
CP = EV + 'retained-why-callback-demand-20261023/'
RP = EV + 'retained-six-owner-round63-20261023/'
OWNERS = ('Ident', 'Decl.Hsdecl', 'Ty.Hsty', 'Theory.Hstdecl',
          'Task.Hstask', 'Task.Stdecl.Hcpt')
CASES = {'put-line': 51, 'put': 42, 'first-or-default': 22,
         'is-message': 2, 'input-is-valid': 1}
inputs, archives, members, blobs = {}, {}, {}, {}


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def blob(revision, path):
    key = revision + ':' + path
    if key in blobs:
        return blobs[key]
    data = subprocess.check_output(['git', 'show', revision + ':' + path], cwd=ROOT)
    inputs[key] = identity(data)
    blobs[key] = data
    return data


def read(revision, path):
    return json.loads(blob(revision, path))


def pin_tree(revision, directory):
    paths = subprocess.check_output(
        ['git', 'ls-tree', '-r', '--name-only', revision, '--', directory],
        cwd=ROOT, text=True).splitlines()
    assert paths
    for path in paths:
        blob(revision, path)
    return paths


def member(revision, archive, name):
    data = blob(revision, archive)
    digest = identity(data)['sha256']
    if digest not in archives:
        with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as arc:
            archives[digest] = {m.name: arc.extractfile(m).read()
                                for m in arc.getmembers() if m.isfile()}
    data = archives[digest][name]
    members[digest + ':' + name] = identity(data)
    return data


def verify_packet(revision, prefix, note):
    pin_tree(revision, prefix)
    blob(revision, note)
    manifest = read(revision, prefix + 'inputs.json')
    for path, expected in manifest['files'].items():
        assert identity(blob(revision, path)) == expected, path
    witnesses = read(revision, prefix + 'source-witnesses.json')
    for w in witnesses:
        data = member(revision, w['archive'], w['member'])
        assert identity(data) == w['member_identity'], w['member']
        lines = data.decode().splitlines(keepends=True)
        assert 1 <= w['first_line'] <= w['last_line'] <= len(lines)
        excerpt = ''.join(lines[w['first_line'] - 1:w['last_line']])
        assert excerpt == w.get('text', w.get('excerpt'))
        assert identity(excerpt.encode()) == w['excerpt_identity']
    return len(witnesses)


def vector(ident, decl, ty, td):
    return {owner: {'increments': n, 'requests': 0 if owner == 'Ident' else n}
            for owner, n in zip(OWNERS, (ident, decl, ty, td, 0, 0))}


def tuple_tree(arity):
    def add(*pairs):
        return tuple(sum(v[i] for v in pairs) for i in range(2))
    ts = (arity + 1, 0)
    fs = add((1, arity + 1), ts)
    its = add((arity, arity), ts, ts)
    rs = add((arity + 1, 2 * arity + 1), its, fs)
    pd = add(its, rs)
    theory = add(ts, fs)
    assert its == (3 * arity + 2, arity)
    assert rs == (5 * arity + 5, 4 * arity + 2)
    assert pd == (8 * arity + 7, 5 * arity + 2)
    assert add(theory, pd) == (10 * arity + 10, 6 * arity + 3)
    return {'arity': arity, 'its': its, 'rs': rs, 'pd_lower': pd,
            'both_publication_lower_children': add(theory, pd)}


def main():
    started = time.perf_counter()
    witness_counts = {
        'library': verify_packet(LIBRARY, LP, 'docs/research/retained-why-library-constructors.md'),
        'callbacks': verify_packet(CALLBACK, CP, 'docs/research/retained-why-callback-demand.md')}
    library = read(LIBRARY, LP + 'result.json')
    callbacks = read(CALLBACK, CP + 'result.json')
    publication = read(LIBRARY, EV + 'retained-why-library-publication-bound-20261020/bound.json')
    attachment = read(LIBRARY, EV + 'retained-why-shared-demand-20261020/attachment.json')
    by_state = {r['case']: r for r in attachment}
    by_library = {r['case']: r for r in library['cases']}
    by_callback = {r['case']: r for r in callbacks['cases']}
    assert set(by_state) == set(by_library) == set(by_callback) == set(CASES)
    assert publication['source_bytes_all_files'] == 38678
    assert publication['direct_root_bounds']['int']['expanded_source_bytes'] == 147480
    assert publication['direct_root_bounds']['real']['expanded_source_bytes'] == 807447
    assert publication['direct_root_bounds']['real']['swallowed_clone_marker_upper_count'] == 4698
    assert publication['implicit_tuple']['lexical_arity_domain_size'] == 38679
    assert publication['implicit_tuple']['resize_assignments_both_tables_global_upper'] == 128
    assert library['shape_interface']['original_callable_contract_stored_slots'] == 1024
    assert library['shape_interface']['generated_cloned_any_contract_stored_slots'] == 32768
    assert library['shape_interface']['general_diagnostic_term_stored_slots'] is None
    shapes = read(LIBRARY, LP + 'family-shapes.json')
    for info in shapes['files'].values():
        raw = member(LIBRARY, shapes['archive'], info['member'])
        assert identity(raw) == {k: info[k] for k in ('bytes', 'sha256')}
    declarations = shapes['declarations']
    assert len(declarations) == 499
    assert max(d['units'] for d in declarations) == 128
    assert shapes['explicit_program_declarations_in_cloned_targets'] == []
    program = [d for d in declarations if re.match(r'(let|val)\b', d['source'])]
    # Stronger than normal-path call lookup: every identifier in each whole
    # program declaration is disjoint from every generated proposition base.
    # Thus a spurious failed lookup cannot find its tick_lemma alternative.
    # The source projection and namespace-preservation argument are reviewed
    # separately; this finite set check does not establish them by itself.
    proposition_names = {m.group(1) for d in declarations
                         if (m := re.match(r'(?:axiom|lemma|goal)\s+([A-Za-z_][A-Za-z0-9_\']*)', d['source']))}
    program_identifiers = set().union(*(set(re.findall(r"[A-Za-z_][A-Za-z0-9_']*", d['source'])) for d in program))
    assert not (proposition_names & program_identifiers)
    binder_records = max(len(re.findall(r'\b(?:forall|exists|ensures)\b', d['source'])) for d in program)
    assert binder_records <= 4
    contracts = read(LIBRARY, LP + 'callable-contracts.json')
    by_program = {d['module'] + ':' + str(d['line']): d for d in program}
    assert len(program) == contracts['explicit_program_declarations'] == 59
    assert len(contracts['executable_bodies']) == contracts['executable_outer_let_declarations'] == 38
    assert set(contracts['lexical_proposition_head_names']) == proposition_names
    assert contracts['maximum_source_quantifier_and_post_boundaries'] == binder_records
    for row in contracts['program_declarations']:
        assert identity(by_program[row['key']]['source'].encode()) == row['declaration_identity']
    for row in contracts['executable_bodies']:
        assert by_program[row['key']]['source'].endswith(row['body'])
        assert identity(row['body'].encode()) == row['body_identity']
        assert sorted(set(re.findall(r"[A-Za-z_][A-Za-z0-9_']*", row['body']))) == row['all_body_identifier_runs']
        assert not (set(row['all_body_identifier_runs']) & proposition_names)
    assert contracts['implicit_RKnone_post_origins'] == ['real.RealInfix:76']
    assert 512 + 64 + 32 + 8 + 16 + 8 * 16 == 760 < 1024
    assert 512 * (1 + 16 + 2 * 16) < 32768
    assert 32 * 2**18 + 2**20 + 2**18 + 2**18 + 2**20 < 2**24
    computed, trees = [], [tuple_tree(n) for n in (0, 2)]
    for case, n in CASES.items():
        path = EV + 'retained-why-fixed-inline-family-20261020/' + case + '-family.json'
        data = blob(LIBRARY, path)
        assert data == blob(CALLBACK, path) == blob(COMBINED, path)
        family = json.loads(data)
        assert family['registered_roots'] == len(family['stages']['raw']['roots']) == n
        initial = by_state[case]['owners']['Ident']['counter']
        arity, keys = max(initial, 38678), 2 * initial + 38679
        trees.append(tuple_tree(arity))
        for escape in range(3):
            episodes = 3 * n + escape
            base = 2 * episodes * (keys + 4698 + 1)
            resize, signal = 128 * keys, escape * (keys + 1)
            entries = base + resize + signal
            slots = 2 * episodes * 807447
            expected = vector(2**24 * slots + (10 * arity + 12) * entries,
                              4 * slots + entries,
                              2**24 * slots + (7 * arity + 4) * entries,
                              2**21 * slots + 2 * entries)
            zero = vector(0, 0, 0, 0)
            if escape == 2:
                row, cb = by_library[case], by_callback[case]
                assert row['lookup_vector'] == expected
                assert row['episodes_upper'] == cb['same_process_preparation_episode_upper'] == episodes
                assert row['whole_process_publication_memo_callbacks'] == dict(
                    base=base, resize=resize, signal=signal, each_table_total=entries)
                assert row['expanded_source_slots_whole_process'] == slots
                assert row['lookup_vector_complete'] and row['incomplete_owners'] == []
                assert cb['process_vector'] == zero
                assert callbacks['residuals'][case]['other_callbacks_and_shutdown'] == zero
            computed.append(dict(case=case, escape=escape, episodes=episodes,
                                 publication_entries=entries, library=expected, callbacks=zero))
    pin_tree(COMBINED, RP)
    root = read(COMBINED, RP + 'candidate-composition-result.json')
    source = blob(COMBINED, RP + 'compose.py').decode()
    assert "residuals[row['case']]['lookup_library_constructors'] = row['lookup_vector']" in source
    assert "residuals[row['case']]['other_callbacks_and_shutdown'] = row['process_vector']" in source
    assert "shared.compose(residuals, escape=2)" in source
    for prefix, revision, note in (
            (LP, LIBRARY, 'docs/research/retained-why-library-constructors.md'),
            (CP, CALLBACK, 'docs/research/retained-why-callback-demand.md')):
        for path in pin_tree(revision, prefix) + [note]:
            assert blob(COMBINED, path) == blob(revision, path)
    for row in root['cases']:
        case = row['case']
        supplied = row['caller_supplied_residuals']
        assert supplied['lookup_library_constructors'] == by_library[case]['lookup_vector']
        assert supplied['other_callbacks_and_shutdown'] == by_callback[case]['process_vector']
        assert set(supplied) == {'lookup_library_constructors', 'other_callbacks_and_shutdown',
                                 'later_preparation', 'solver_request_printers'}
        for owner in OWNERS:
            for field in ('increments', 'requests'):
                total = row['known_demand'][owner][field] + sum(v[owner][field] for v in supplied.values())
                assert row['joined_known_and_supplied_demand'][owner][field] == total
            tr = row['conditional_transfers'][owner]
            endpoint = row['attachment']['owners'][owner]['counter'] + row['joined_known_and_supplied_demand'][owner]['increments']
            assert tr['counter']['final_upper'] == endpoint <= 2**62 - 1
            if owner != 'Ident':
                backing = tr['backing']
                if owner == 'Task.Stdecl.Hcpt':
                    assert 2 * backing['individual_array_length_upper'] <= 2**54 - 1
                else:
                    a, b = backing['individual_outer_array_length_upper'], backing['individual_bucket_length_upper']
                    assert 3 * max(a, b) + 6 <= 2**62 - 1
                    assert a <= 2**54 - 1 and b + 2 <= 2**54 - 3
            assert tr['native_operands_fit']
        assert row['missing_residual_contracts'] == []
        assert row['complete_six_owner_numeric_input']
        assert not row['actual_whole_process_headroom']
    assert not root['whole_pipeline_capacity']
    assert not root['new_source_contracts_independently_accepted']
    assert not root['second_episode_multiplier']
    assert library['global_escape_upper'] == callbacks['budgets']['process_global_escape'] == root['budgets']['per_process_escape'] == 2
    assert callbacks['save_binders_imported_by_shared_demand_not_recharged']
    assert not library['whole_process_headroom'] and not callbacks['whole_process_headroom']
    result = dict(passed=True, library_freeze=LIBRARY, callback_freeze=CALLBACK,
                  combined_freeze=COMBINED, witness_counts=witness_counts,
                  frozen_revision_path_inputs=len(inputs), source_archives=len(archives),
                  source_members=len(members), process_escape_vectors=len(computed),
                  lexical_callable_census=dict(program_declarations=len(program),
                      proposition_bases=len(proposition_names),
                      source_quantifier_or_ensures_records_upper=binder_records,
                      program_identifier_proposition_name_intersection=[]),
                  tuple_trees=trees, vectors=computed, combined_cases=len(root['cases']),
                  second_episode_multiplier=False, source_argument_machine_checked=False,
                  native_runs=0, proof_runs=0, captures=0, author_or_predecessor_programs_run=0,
                  elapsed_seconds=time.perf_counter() - started)
    (HERE / 'inputs.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')
    (HERE / 'source-identities.json').write_text(json.dumps(members, indent=2, sort_keys=True) + '\n')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('vectors', 'tuple_trees')}))


if __name__ == '__main__':
    main()

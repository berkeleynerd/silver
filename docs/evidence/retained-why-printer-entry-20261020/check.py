"""Focused transcription, source-correspondence and arithmetic check.

Does not prove the mathematical source simulation and runs no predecessor.
"""
from pathlib import Path
import hashlib
import importlib.util
import json
import platform
import re
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EV = HERE.parent

def read(path):
    return json.loads(path.read_text())

def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def strip_comments(text):
    result, i, depth, quoted = [], 0, 0, False
    while i < len(text):
        if not depth and text[i] == '"':
            quoted = not quoted; result.append(text[i]); i += 1
        elif quoted and text[i] == '\\':
            result.append(text[i:i+2]); i += 2
        elif not depth and not quoted and text[i:i+3] == '(*)':
            result.append('(*)'); i += 3
        elif not quoted and text[i:i+2] == '(*':
            depth += 1; i += 2
        elif not quoted and text[i:i+2] == '*)':
            assert depth > 0
            depth -= 1; i += 2
        else:
            if not depth: result.append(text[i])
            i += 1
    assert depth == 0
    return ''.join(result)

def main():
    started = time.monotonic()
    inputs = read(HERE / 'inputs.json')
    for path, expected in read(HERE / 'packet-inputs.json').items():
        assert identity((REPO / path).read_bytes()) == expected, path
    for path, expected in inputs['retained_inputs'].items():
        assert identity((REPO / path).read_bytes()) == expected, path
    for path, expected in inputs['external_frozen_inputs'].items():
        data = subprocess.check_output(['git', 'show', path], cwd=REPO)
        assert identity(data) == expected, path
    witnesses = read(HERE / 'source-witnesses.json')
    archive = REPO / witnesses['archive']
    assert identity(archive.read_bytes()) == witnesses['archive_identity']
    source = {}
    with tarfile.open(archive) as tf:
        for path, witness in witnesses['sources'].items():
            data = tf.extractfile(witness['member']).read()
            assert identity(data) == {k: witness[k] for k in ('bytes', 'sha256')}, path
            source[path] = data.decode()
            lines = source[path].splitlines(keepends=True)
            for section in witness['sections']:
                assert ''.join(lines[section['first']-1:section['last']]) == section['text'], path
    # Assertions bind the named branch owners, not a lexical proof of reachability.
    assert 'Trans.compose_l\n      Split_goal.split_goal_right' in source['transform/gnat_split_conj.ml']
    assert 'Introduction.' not in source['transform/gnat_split_conj.ml']
    assert 'Introduction.' not in source['transform/gnat_rewrite.ml']
    assert 'Trans.singleton Introduction.simplify_intros' in source['transform/gnat_trivial.ml']
    assert '| Gnat_config.Per_Check ->\n        ["split_goal_wp_conj"]' in source['gnat/gnat_checks.ml']
    assert 'Introduction.remove_unused_from_context' in source['transform/prepare_for_counterexmp.ml']
    assert 'let o = Hsdecl.hashcons d' in source['transform/introduction.ml']
    assert 'let vs = create_vsymbol (id_fresh "v") ty' in source['transform/eliminate_algebraic.ml']
    assert 'if n = 1 || small e then' in source['core/term.ml']
    assert 'TermTF.t_map t_fmla_simpl fmla_simpl t' in source['transform/simplify_formula.ml']
    expected = {
        'z3_gnatprove.drv': ['inline_trivial','eliminate_builtin','remove_unused','detect_polymorphism','eliminate_inductive','eliminate_algebraic_if_poly','eliminate_literal','eliminate_gnatprove_guard_epsilon','eliminate_epsilon','introduce_premises','simplify_formula','discriminate_if_poly','encoding_smt_if_poly'],
        'cvc5_gnatprove.drv': ['counterexamples_dependent_intros','inline_trivial','eliminate_builtin','remove_unused','detect_polymorphism','eliminate_definition_conditionally','eliminate_inductive','eliminate_gnatprove_guard_epsilon','eliminate_epsilon','eliminate_literal','simplify_formula','eliminate_projections_sums','discriminate_if_poly','eliminate_algebraic_if_poly','encoding_smt_if_poly'],
        'alt_ergo_gnatprove_smt2.drv': ['counterexamples_dependent_intros','monomorphise_goal','inline_trivial','eliminate_builtin','remove_unused','eliminate_recursion','eliminate_inductive','eliminate_epsilon','eliminate_algebraic','eliminate_literal','split_premise_right','simplify_formula'],
    }
    drivers = EV / 'retained-solver-request-bytes-20261020/drivers'
    for name, route in expected.items():
        actual = re.findall(r'^\s*transformation\s+"([^"]+)"', strip_comments((drivers/name).read_text()), re.M)
        assert actual == route, (name, actual)
    assert 'meta "algebraic:kept" type bool' in strip_comments((drivers/'smt-libv2.gen').read_text())
    for c in read(HERE / 'metadata-attachment.json')['cases']:
        metadata = read(EV / 'retained-why-parallel-symbol-exclusion-20261020' / (c['case'] + '-metadata.json'))
        assert all(not metadata['updated_metadata'].get(key) for key in c['absent_in_complete_updated_metadata'])
        assert c['maximum_dependency_heads_per_axiom'] <= 2
    projection = read(HERE / 'continuation-projection.json')
    expected_special = {'put-line': {62}, 'put': {52}, 'first-or-default': set(), 'is-message': set(), 'input-is-valid': set()}
    for c in projection['cases']:
        inv = read(HERE / (c['case'] + '-inventory.json'))
        for route, rows in c['routes'].items():
            original = {r['goal']: r for r in inv['routes'][route]}
            assert set(original) == {r['goal'] for r in rows}
            assert {r['goal'] for r in rows if r['binding_bearing_value_body_bound_slots']} == expected_special[c['case']]
            for r in rows:
                assert r['optional_inline_partial_let_potential_upper'] == 5 * r['partial_let_potential_before_inline']
                assert r['epsilon_occurrences'] == len(original[r['goal']]['eps']) == len(r['epsilon_parents'])
                assert all(x == 0 for x in r['binding_bearing_value_body_bound_slots'])
    spec = importlib.util.spec_from_file_location('printer_entry_compose', HERE / 'compose.py')
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    result = module.calculate()
    assert result == read(HERE / 'result.json')
    assert result['new_stage_escape_allowance'] is False
    assert result['aggregate_RAM_gate'] is False
    assert any(c['process_demands']['term_and_opening_entries'] > 2**62 for c in result['cases'])
    assert all(c['process_demands']['type_hashcons_requests'] < 2**62 for c in result['cases'])
    assert all(c['dimensions']['P'] <= 2*c['dimensions']['M'] for c in result['cases'])
    for c in result['cases']:
        components = c['direct_Ident_components']
        clones = components['introduction_type_map_variable_clones']
        assert clones['one_episode'] == 3*c['dimensions']['unique_goal_pre_introduction_R']
        assert clones['process_demand'] == c['episodes_upper']*clones['one_episode']
        assert sum(x['one_episode'] for x in components.values()) == c['one_episode']['direct_Ident_registrations']
        assert sum(x['process_demand'] for x in components.values()) == c['process_demands']['direct_Ident_registrations']
    # Local links in the owned research note must resolve; external frozen
    # companion files are separately identified through Git above.
    note = REPO / 'docs/research/retained-why-printer-entry.md'
    for target in re.findall(r'\]\(([^)]+)\)', note.read_text()):
        if '://' not in target and not target.startswith('#'):
            assert (note.parent / target.split('#')[0]).exists(), target
    answer = {'status': 'pass', 'platform': platform.system(), 'machine': platform.machine(),
              'elapsed_seconds': time.monotonic() - started,
              'source_members': len(source), 'retained_input_identities': len(inputs['retained_inputs']),
              'external_frozen_input_identities': len(inputs['external_frozen_inputs']),
              'registered_root_route_rows': sum(len(rows) for c in projection['cases'] for rows in c['routes'].values()),
              'new_projection_replayed_by_checker': False,
              'predecessor_checkers_replayed': 0, 'native_target_runs': 0,
              'source_argument_machine_checked': False, 'independent_review_accepted': False,
              'whole_quiet_capacity_complete': False}
    (HERE / 'check-result.json').write_text(json.dumps(answer, sort_keys=True, indent=2) + '\n')
    print(json.dumps(answer, sort_keys=True))

if __name__ == '__main__':
    main()

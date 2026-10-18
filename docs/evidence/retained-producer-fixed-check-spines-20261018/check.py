#!/usr/bin/env python3
"""Reconcile pinned fixed inputs with a source argument, without running Why3."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[2]


def nodes(value):
    if isinstance(value, list):
        if value and isinstance(value[0], str) and value[0].startswith('W_'):
            yield value
        for child in value:
            yield from nodes(child)


def symbol(node):
    if node[0] == 'W_IDENTIFIER':
        node = node[3]
    assert node[0] == 'W_NAME'
    return node[3]


def true_literal(node):
    return node is not None and node[0] == 'W_LITERAL' and node[3] == 0


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    archive = HERE / 'sources.tar.gz'
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity['source_archive_sha256']
    with tarfile.open(archive) as tar:
        source = {}
        for row in identity['source_files']:
            data = tar.extractfile(row['path']).read()
            assert len(data) == row['bytes']
            assert hashlib.sha256(data).hexdigest() == row['sha256']
            source[row['path']] = data.decode()
    for row in identity['local_sources']:
        assert hashlib.sha256((PROJECT / row['path']).read_bytes()).hexdigest() == row['sha256']
    vc = source['src/mlw/vc.ml']
    assert 'let wp_of_post expl loc ity ql =' in vc
    assert '| _, _, Ttrue  when can_simp wp2 -> sp_implies c wp1' in vc
    assert 'wp_if test wp1 wp2, sp, Spv.add v (Spv.union rd1 rd2)' in vc
    assert '| Kstop f ->\n      f' in vc
    converter = source['plugins/gnat_json/gnat_ast_to_ptree.ml']
    assert 'if is_true post && no_vcs_no_side_effects expr then' in converter
    assert '| Eidapp _ | Eapply _ | Einfix _ | Einnfix _ ->\n      false' in converter
    assert 'spec.sp_pre = [] (* existence *)' in converter
    assert 'let attr = mk_str "vc:divergent" in' in converter
    splitter = source['src/transform/gnat_split_conj.ml']
    assert 't_attr_copy f (t_implies f1 (unfold_right n env f2))' in splitter

    fixed = HERE.parent / 'retained-producer-bodies-20261018/inputs-and-outputs.tar.gz'
    assert hashlib.sha256(fixed.read_bytes()).hexdigest() == identity['fixed_archive_sha256']
    results = []
    with tarfile.open(fixed) as tar:
        for row in identity['fixed_inputs']:
            data = tar.extractfile(row['path']).read()
            assert len(data) == row['bytes']
            assert hashlib.sha256(data).hexdigest() == row['sha256']
            tree = json.loads(data)
            theories = tree['theory_declarations']
            assert theories[-1][4].endswith(row['name'] + '__subprogram_def')
            body = list(nodes(theories[-1][3]))
            counts = Counter(n[0] for n in body)
            context_bodies = [n for th in theories[:-1] for n in nodes(th[3])
                              if n[0] == 'W_FUNCTION_DECL' and n[2] == 4 and n[9] is not None]
            assert not context_bodies
            program_decls = [n for n in body if n[0] == 'W_FUNCTION_DECL']
            assert len(program_decls) == 1
            assert program_decls[0][7] is None  # No checked outer postcondition.
            abstract = [n for n in body if n[0] == 'W_ABSTRACT_EXPR']
            assert all(true_literal(n[4]) for n in abstract)
            empty_contract = [n for n in abstract if n[3][0] == 'W_BINDING'
                              and symbol(n[3][3]) == '_'
                              and true_literal(n[3][4])]
            assert len(empty_contract) == 2
            labels = sorted(set(re.findall(r'GP_Check:[^"\\]*', data.decode())))
            assert len(labels) == 1
            assert not any(n[0] in ('W_LOOP', 'W_ABSURD') for n in body)

            if row['name'] == 'input_is_valid':
                assert labels[0].endswith('VC_PRECONDITION:silver_arguments.adb:14:43')
                assert counts['W_CONDITIONAL'] == 2
                assert counts['W_ASSIGNMENT'] == 5
                assert counts['W_ASSERT'] == 0
                assert counts['W_ANY_EXPR'] == 0
                assert len(abstract) == 2
                tasks = 1
            else:
                assert row['name'] == 'is_message'
                assert labels[0].endswith('VC_RANGE_CHECK:silver_arguments.adb:6:11')
                assert counts['W_CONDITIONAL'] == 1
                assert counts['W_ASSIGNMENT'] == 1
                assertions = [n for n in body if n[0] == 'W_ASSERT']
                assert len(assertions) == 1 and assertions[0][4] == 2  # Assume.
                anys = [n for n in body if n[0] == 'W_ANY_EXPR']
                assert len(anys) == 2 and all(n[4] is None for n in anys)
                assert len(abstract) == 3
                integer = next(th for th in theories if th[4] == 'Standard__integer')
                in_range = next(n for n in nodes(integer[3])
                                if n[0] == 'W_FUNCTION_DECL' and symbol(n[3]) == 'in_range')
                assert in_range[10] == ['GP_Inline']
                comparisons = [n for n in nodes(in_range[9])
                               if n[0] == 'W_CALL' and symbol(n[3]) == '<=']
                assert len(comparisons) == 2
                assert len([n for n in nodes(in_range[9]) if n[0] == 'W_CONNECTION']) == 1
                tasks = 2 + 1
            results.append(dict(entity=row['name'], native_input_sha256=row['sha256'],
                native_check_labels=labels, program_body_kind_counts=dict(sorted(counts.items())),
                additional_context_program_bodies=0, empty_contract_helpers=2,
                other_true_helpers=len(abstract)-2,
                source_derived_terminal_task_bound=tasks,
                response_record_bound=1))
    result = dict(why3_revision=identity['why3_revision'], native_or_proof_executions=0,
        fixed_inputs=results,
        scope='Source derivation reconciled with complete fixed producer inputs; no mechanical SP/WP verification, no bound for the other three fixed library files or whole-tool representations')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()

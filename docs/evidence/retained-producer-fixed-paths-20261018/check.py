#!/usr/bin/env python3
"""Check the fixed-tree path calculation; never execute compiler or proof tools."""
import collections
import hashlib
import json
import re
import tarfile
from pathlib import Path

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


def outcome(node):
    assert node[0] == 'W_NAME'
    return ((node[5][4] + '.') if node[5] else '') + node[3]


CALLS = collections.Counter()
NORMAL = 'normal'


def out(paths=None, checks=0):
    if paths is None:
        paths = {NORMAL: 1}
    return collections.Counter(paths), checks


def seq(a, b, which=NORMAL):
    paths, checks = a
    next_paths, next_checks = b
    combined = paths.copy()
    multiplicity = combined.pop(which, 0)
    combined.update({key: multiplicity * value for key, value in next_paths.items()})
    return combined, checks + multiplicity * next_checks


def par(a, b):
    paths, checks = a
    other_paths, other_checks = b
    return paths + other_paths, checks + other_checks


def stop(checks):
    return out({}, checks)


def sequence(fragments):
    result = out()
    for fragment in fragments:
        result = seq(result, fragment)
    return result


def leaf(node):
    """Right-split leaf weight for the reviewed fixed predicate frontier."""
    if node is None:
        return 0
    kind = node[0]
    if kind in ('W_LABEL', 'W_LOC_LABEL'):
        return leaf(node[4])
    if kind == 'W_BINDING':
        return leaf(node[5])
    if kind == 'W_CONNECTION':
        assert not node[6]
        if node[4] in (1, 3, 5):  # And_then, Iff, And.
            return leaf(node[3]) + leaf(node[5])
        if node[4] == 2:  # Implication.
            return leaf(node[5])
        assert node[4] in (0, 4)  # Or_else, Or remain one positive leaf.
        return 1
    if kind == 'W_CONDITIONAL':
        assert not node[5] and node[6] is not None
        return leaf(node[4]) + leaf(node[6])
    if kind == 'W_UNIVERSAL_QUANTIF':
        return leaf(node[6])
    if kind == 'W_CALL':
        return 2 if symbol(node[3]) == 'in_range' else 1
    if kind in ('W_LITERAL', 'W_NOT'):
        return 1
    raise ValueError(('unsupported predicate', node[:3]))


def exp(node):
    """Finite verification-path account, not execution of native/Why3 code."""
    if node is None:
        return out()
    kind = node[0]
    if kind in ('W_LABEL', 'W_LOC_LABEL'):
        return exp(node[4])
    if kind in ('W_IDENTIFIER', 'W_LITERAL', 'W_INTEGER_CONSTANT',
                'W_MODULAR_CONSTANT', 'W_DEREF', 'W_COMMENT'):
        assert kind != 'W_IDENTIFIER' or symbol(node) != 'absurd'
        return out()
    if kind in ('W_BINDING', 'W_BINDING_REF'):
        return seq(exp(node[4]), exp(node[5]))
    if kind == 'W_STATEMENT_SEQUENCE':
        return sequence(exp(child) for child in node[3])
    if kind == 'W_CONDITIONAL':
        assert not node[5]
        return seq(exp(node[3]), par(exp(node[4]), exp(node[6])))
    if kind == 'W_CONNECTION':
        assert not node[6] and node[4] in (0, 1)
        return seq(exp(node[3]), par(exp(node[5]), out()))
    if kind == 'W_NOT':
        return exp(node[3])
    if kind == 'W_CALL':
        CALLS[outcome(node[3][3])] += 1
        args = [exp(child) for child in node[4]]
        assert all(paths == {NORMAL: 1} for paths, _ in args), (
            'branching argument', node[:3])
        return seq(sequence(args), out(checks=2))
    if kind == 'W_ASSIGNMENT':
        return exp(node[4])
    if kind == 'W_ASSERT':
        assert node[4] in (0, 1, 2)
        return out(checks=0 if node[4] == 2 else leaf(node[3]))
    if kind == 'W_ANY_EXPR':
        assert node[3] is None
        return out(checks=leaf(node[4]))
    if kind == 'W_RECORD_ACCESS':
        return exp(node[3])
    if kind == 'W_ABSTRACT_EXPR':
        paths, checks = exp(node[3])
        assert set(paths) <= {NORMAL}
        return out(checks=checks + paths[NORMAL] * leaf(node[4]))
    if kind == 'W_RAISE':
        return seq(exp(node[4]), out({outcome(node[3]): 1}))
    if kind == 'W_TRY_BLOCK':
        paths, checks = exp(node[3])
        combined = paths.copy()
        catches = []
        # All handlers catch body outcomes. A handler cannot catch its own raise.
        for handler in node[4]:
            key = outcome(handler[3])
            multiplicity = paths[key]
            combined.pop(key, None)
            handler_paths, handler_checks = exp(handler[5])
            catches.append((handler_paths, multiplicity))
            checks += multiplicity * handler_checks
        for handler_paths, multiplicity in catches:
            combined.update({key: multiplicity * value
                             for key, value in handler_paths.items()})
        return combined, checks
    if kind == 'W_LOOP':
        assert not node[5]
        invariant_leaves = sum(leaf(child) for child in node[4] or [])
        before = exp(node[3])
        body = seq(exp(node[6]), before)
        verification = par(stop(invariant_leaves), seq(body, stop(invariant_leaves)))
        return seq(before, verification)
    raise ValueError(('unsupported program', node[:3]))



def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    sources = {}
    for archive in identity['source_archives']:
        path = PROJECT / archive['path']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == archive['sha256']
        with tarfile.open(path) as tar:
            for row in archive['files']:
                data = tar.extractfile(row['path']).read()
                assert len(data) == row['bytes']
                assert hashlib.sha256(data).hexdigest() == row['sha256']
                sources[row['path']] = data.decode()
    for row in identity['local_sources']:
        assert hashlib.sha256((PROJECT / row['path']).read_bytes()).hexdigest() == row['sha256']
    assert 'Kpar (j, k_havoc loc attrs eff k)' in sources['src/mlw/vc.ml']
    assert 'wp_and wp1 wp2, sp_combine_map sp1 sp2, rd1' in sources['src/mlw/vc.ml']
    assert 'E.mk_seq code_before loop)' in sources['plugins/gnat_json/gnat_ast_to_ptree.ml']
    assert 'requires { in_range n }' in sources['installed/share/spark/theories/ada__model.mlw']
    assert 'val function get map I1.t : component_type' in sources['installed/share/spark/theories/_gnatprove_standard.mlw']
    archive = PROJECT / identity['fixed_archive']['path']
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity['fixed_archive']['sha256']
    expected = [(6, 1173, 5, 1203, 9, 0), (6, 593, 6, 629, 14, 2),
                (8, 1089, 7, 1145, 18, 2)]
    rows = []
    with tarfile.open(archive) as tar:
        for row, expect in zip(identity['fixed_inputs'], expected, strict=True):
            data = tar.extractfile(row['path']).read()
            assert len(data) == row['bytes']
            assert hashlib.sha256(data).hexdigest() == row['sha256']
            assert b'case_split' not in data
            tree = json.loads(data)
            theories = tree['theory_declarations']
            body = list(nodes(theories[-1][3]))
            functions = [n for n in body if n[0] == 'W_FUNCTION_DECL']
            assert len(functions) == 1
            fun = functions[0]
            assert not [n for th in theories[:-1] for n in nodes(th[3])
                        if n[0] == 'W_FUNCTION_DECL' and n[2] == 4 and n[9] is not None]
            assert all(not n[5] for n in nodes(theories) if n[0] == 'W_EFFECTS')
            for n in body:
                if n[0] == 'W_ABSTRACT_EXPR':
                    assert n[4][0] == 'W_LITERAL' and n[4][3] == 0
            marked = []
            for th in theories:
                for n in nodes(th[3]):
                    if n[0] == 'W_FUNCTION_DECL' and symbol(n[3]) == 'bool_eq':
                        assert 'GP_Inline' not in n[10]
                    if n[0] == 'W_FUNCTION_DECL' and 'GP_Inline' in n[10]:
                        name = symbol(n[3])
                        if name == 'in_range':
                            assert leaf(n[9]) == 2
                        else:
                            assert name == 'is_message'
                        marked.append(th[4] + '.' + name)
            labels = sorted(set(re.findall(r'GP_Check:[^"\\]*', data.decode())))
            loop_labels = [s for s in labels if ':VC_LOOP_INVARIANT:' in s]
            CALLS.clear()
            paths, checks = exp(fun[9])
            calls = dict(sorted(CALLS.items()))
            post = leaf(fun[7])
            terminal_paths, total = seq((paths, checks), stop(post))
            assert not terminal_paths
            assert (paths[NORMAL], checks, post, total, len(labels), len(loop_labels)) == expect
            assert set(paths) == {NORMAL}
            loops = []
            for loop in [n for n in body if n[0] == 'W_LOOP']:
                before, qb = exp(loop[3])
                after, qa = exp(loop[6])
                leaves = [leaf(n) for n in loop[4] or []]
                lp, lq = exp(loop)
                assert before == {NORMAL: 1} and qb == 43
                assert len(after) == 3 and all(v == 1 for v in after.values()) and qa == 38
                assert leaves == [1, 1]
                assert NORMAL not in lp and len(lp) == 2 and lq == 128
                loops.append({'native_occurrence_id': loop[1], 'before_paths': dict(before),
                              'before_checks': qb, 'after_paths': dict(after), 'after_checks': qa,
                              'invariant_leaves': leaves, 'loop_paths': dict(lp), 'loop_checks': lq})
            rows.append({'entity': row['entity'], 'native_input_sha256': row['sha256'],
                         'body_paths': dict(paths), 'body_check_budget': checks,
                         'postcondition_leaf_budget': post, 'terminal_task_bound': total,
                         'response_record_bound': len(labels) + 2*len(loop_labels),
                         'native_check_labels': labels, 'call_symbols_visited_by_accounting_walk': sorted(calls),
                         'marked_context_definitions': marked, 'loops': loops})
    total_g = sum(row['terminal_task_bound'] for row in rows) + 1 + 3
    total_r = sum(row['response_record_bound'] for row in rows) + 1 + 1
    result = {'why3_revision': identity['why3_revision'], 'native_or_proof_executions': 0,
              'call_leaf_allowance': 2, 'fixed_inputs': rows,
              'all_five_fixed_files': {'terminal_task_bound': total_g, 'response_record_bound': total_r,
                  'raw_response_constant_bytes_excluding_warning_and_argument_terms': 5*15245+3732*total_r+2145*total_g,
                  'projected_response_constant_bytes_excluding_warning_terms': 5*212+3732*total_r+2601*total_g},
              'scope': 'Source-derived fixed-tree path calculation, not execution or mechanical verification of Why3 transformations; other representation and solver domains remain separate'}
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: result[key] for key in ('native_or_proof_executions', 'all_five_fixed_files')}))


if __name__ == '__main__':
    main()

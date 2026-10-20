#!/usr/bin/env python3
"""Bounded offline import-closure and counter-interface check, not a WhyML proof."""
import argparse
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
INPUTS = 'docs/evidence/retained-solver-task-language-20261020/input-census.json'
DRIVERS = 'docs/evidence/retained-solver-task-language-20261020/driver-census.json'
INITIAL = 'docs/evidence/retained-why-initial-registration-bound-20261020/result.json'
LEXER = 'docs/evidence/retained-why-path-input-inventory-20261020/extract.py'
MAX_INT = 2**62 - 1
RANGES = {
    'why3/plugins/gnat_json/gnat_ast_to_ptree.ml': [(95, 117), (160, 174), (678, 701), (1226, 1280), (1285, 1333)],
    'why3/src/parser/typing.ml': [(1584, 1591)],
    'why3/src/mlw/pmodule.ml': [(384, 410), (463, 486), (1697, 1702)],
    'why3/src/mlw/vc.ml': [(169, 175)],
    'why3/src/core/theory.ml': [(214, 240), (268, 284), (651, 660), (861, 878), (999, 1075)],
    'why3/src/core/task.ml': [(19, 29), (45, 61), (76, 113), (148, 200)],
    'why3/src/core/trans.ml': [(46, 57), (75, 99)],
    'why3/src/driver/driver.ml': [(155, 205), (233, 236), (330, 389), (490, 494)],
    'why3/src/session/controller_itp.ml': [(409, 438)],
    'why3/src/session/session_itp.ml': [(310, 311), (677, 690)],
    'why3/src/core/printer.ml': [(447, 472), (518, 561)],
    'why3/src/transform/discriminate.ml': [(489, 504)],
    'why3/src/transform/encoding_sort.ml': [(225, 247)],
    'why3/src/core/ident.ml': [(158, 192)],
    'why3/src/core/ident.mli': [(66, 72)],
    'why3/src/core/term.ml': [(36, 39), (73, 85)],
    'why3/src/core/term.mli': [(38, 45)],
    'why3/src/core/ty.ml': [(84, 88), (120, 128), (159, 170), (203, 217), (234, 236)],
    'why3/src/core/ty.mli': [(41, 47)],
    'why3/src/core/decl.ml': [(285, 303), (697, 707), (743, 752), (830, 835)],
    'why3/src/core/decl.mli': [(69, 78)],
    'why3/src/util/wstdlib.ml': [(61, 67), (93, 100)],
    'why3/src/util/weakhtbl.ml': [(50, 58)],
    'why3/src/util/hashcons.ml': [(33, 50)],
    'why3/src/util/hcpt.ml': [(121, 158), (509, 518)],
}


def ident(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def canonical(value):
    return json.dumps(value, indent=2, sort_keys=True) + '\n'


def nodes(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from nodes(child)
    elif isinstance(value, list):
        if value and isinstance(value[0], str) and value[0].startswith('W_'):
            yield value
        for child in value:
            yield from nodes(child)


def run(write):
    manifest = json.loads((HERE / 'inputs.json').read_text())
    for path, expected in manifest['files'].items():
        assert ident((ROOT / path).read_bytes()) == expected, path
    spec = importlib.util.spec_from_file_location('retained_lexical_helper', ROOT / LEXER)
    lexer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(lexer)
    archives = {}
    members = {}

    def member(archive, name, expected=None):
        if archive not in archives:
            assert archive in manifest['files'], archive
            archives[archive] = tarfile.open(ROOT / archive)
        raw = archives[archive].extractfile(name).read()
        identity = ident(raw)
        if expected is not None:
            assert identity == expected, (archive, name)
        members[archive + ':' + name] = identity
        return raw

    fixed = json.loads((ROOT / INPUTS).read_text())['fixed_inputs']
    cases = []
    root_union = set()
    for item in fixed:
        if item['kind'] != 'native_input':
            continue
        ns = list(nodes(json.loads(member(item['archive'], item['member'], item['identity']))))
        kinds = Counter(n[0] for n in ns)
        assert not any('FLOAT' in k or k == 'W_REAL_CONSTANT' for k in kinds)
        mods = Counter()
        for n in ns:
            if n[0] == 'W_MODULE':
                assert len(n) == 5 and isinstance(n[3], str) and isinstance(n[4], str), n
                if n[3]:
                    mods[n[3] + '.' + n[4]] += 1
        assert mods
        root_union.update(mods)
        cases.append({'case': item['member'].split('/')[0],
                      'external_module_occurrences': dict(sorted(mods.items())),
                      'node_kinds': dict(sorted(kinds.items()))})

    graph = {}
    all_edges = []
    coverage = []
    for item in fixed:
        if item['kind'] != 'prefix_library':
            continue
        source = member(item['archive'], item['member'], item['identity']).decode('ascii')
        masked, _, strings = lexer.mask_comments_strings(source)
        # Restore quoted module-path tokens only while parsing dependency heads.
        restored = list(masked)
        for s in strings:
            restored[s['first_byte']:s['past_last_byte']] = s['source_literal']
        restored = ''.join(restored)
        lib = Path(item['member']).stem
        current = None
        stack = []
        heads = deps = 0
        for line_no, (line, plain) in enumerate(zip(restored.splitlines(), masked.splitlines()), 1):
            h = re.match(r'^\s*(module|theory)\s+([A-Za-z_][A-Za-z_0-9\']*)\s*$', plain)
            if h:
                assert not stack, (lib, line_no, stack)
                current = lib + '.' + h[2]
                assert current not in graph
                graph[current] = {'member': item['member'], 'line': line_no, 'edges': []}
                stack.append('module')
                heads += 1
            keywords = re.findall(r'\b(module|theory|use|clone)\b', plain)
            if keywords:
                assert len(keywords) == 1 and re.match(r'^\s*' + keywords[0] + r'\b', plain), (lib, line_no)
                if keywords[0] in ('module', 'theory'):
                    assert h, (lib, line_no, line)
            d = re.match(r'^\s*(use|clone)\s+(?:(export|import)\s+)?((?:"[^"\\]*"|[A-Za-z_][A-Za-z_0-9\']*)(?:\.[A-Za-z_][A-Za-z_0-9\']*)*)(?=\s|$)', line)
            if keywords and keywords[0] in ('use', 'clone'):
                assert d and current is not None and stack, (lib, line_no, line)
                q = d[3].replace('"', '')
                target = q if '.' in q else lib + '.' + q
                edge = {'from': current, 'to': target, 'kind': d[1], 'line': line_no,
                        'source_head': line.strip()}
                graph[current]['edges'].append(edge)
                all_edges.append(edge)
                deps += 1
            for token in re.findall(r'\b(match|begin|scope|end)\b', plain):
                if token != 'end':
                    stack.append(token)
                else:
                    assert stack, (lib, line_no)
                    stack.pop()
                    if not stack:
                        current = None
        assert not stack, (lib, stack)
        coverage.append({'member': item['member'], 'module_heads': heads, 'dependency_heads': deps})
    assert sum(r['module_heads'] for r in coverage) == 252
    assert sum(r['dependency_heads'] for r in coverage) == 478

    closure = set()
    todo = list(root_union)
    while todo:
        key = todo.pop()
        if key in closure:
            continue
        closure.add(key)
        todo.extend(e['to'] for e in graph.get(key, {}).get('edges', []))
    assert closure - graph.keys() == {'why3.WellFounded.WellFounded'}
    assert len(closure) == 47 and len(root_union) == 10
    assert not any('Float' in key or key.startswith('ieee_float.') for key in closure)
    selected = {k: v for k, v in sorted(graph.items()) if k in closure}
    edges = [e for e in all_edges if e['from'] in closure]
    assert len(edges) == 66

    drivers = json.loads((ROOT / DRIVERS).read_text())
    for name, item in drivers['identities'].items():
        s = member(item['archive'], item['member'], item['identity']).decode('ascii')
        plain, _, _ = lexer.mask_comments_strings(s)
        assert not re.search(r'\buse\b', plain), name
    malformed = []
    for driver, data in drivers['roots'].items():
        for template in data['templates']:
            assert template['value'] != ''
            if template['final_parenthesis_depth']:
                assert template['scope'] == 'ieee_float.Float80'
                assert template['scope'] not in closure
                malformed.append({'driver': driver, **template})
    assert len(malformed) == 4  # two source sites, in both CVC5 and Z3 closures

    initial = json.loads((ROOT / INITIAL).read_text())
    arithmetic = []
    for row in initial['cases']:
        i = row['initial_registration_count']
        b = row['minor_allocated_words']
        assert 5*i <= b < 2**28
        arithmetic.append({'case': row['case'], 'pid': row['pid'], 'I': i,
                           'minor_words': b, 'maximum_additional_registrations_for_no_wrap': MAX_INT-i})
    # The attached local call count is an existing result, not five-case scaling.
    local = 235 + 6*123 + 4 + 168
    assert local == 1145 and 60496 + local == 61641 < MAX_INT

    witnesses = []
    for name, ranges in RANGES.items():
        raw = member(WHY, name)
        lines = raw.decode().splitlines()
        witnesses.append({'archive': WHY, 'member': name, **ident(raw),
                          'excerpts': [{'first': lo, 'last': hi,
                                        'text': '\n'.join(lines[lo-1:hi])+'\n'}
                                       for lo, hi in ranges]})
    # This one specific conversion API could otherwise seed Task.Stdecl from
    # the separate Theory.Stdecl pool. Record all references, not a call graph.
    mk_tds_refs = []
    for entry in archives[WHY].getmembers():
        if not entry.name.endswith(('.ml', '.mli')):
            continue
        source = archives[WHY].extractfile(entry).read().decode()
        for line_no, line in enumerate(source.splitlines(), 1):
            if re.search(r'\bmk_tds\b', line):
                mk_tds_refs.append({'member': entry.name, 'line': line_no, 'text': line})
    assert [(r['member'], r['line']) for r in mk_tds_refs] == [
        ('why3/src/core/task.ml', 33), ('why3/src/core/task.mli', 30)]
    result = {
        'scope': 'Five retained fixed-library process domains under the named source/runtime relation',
        'structured_input_cases': cases, 'external_roots': sorted(root_union),
        'complete_library_head_coverage': coverage,
        'reachable_modules': selected, 'external_builtin': 'why3.WellFounded.WellFounded',
        'reachable_module_count': len(closure), 'reachable_dependency_edges': len(edges),
        'driver_use_directives': 0, 'malformed_templates_excluded_by_theory_origin': malformed,
        'mk_tds_references': mk_tds_refs,
        'direct_driver_metadata_loop_identifier_registrations': 0,
        'update_goal_reattachment_registration_charge': None,
        'initial_identifier_arithmetic': arithmetic,
        'earlier_input_is_valid_first_cvc5_inline_accounted_registrations': local,
        'earlier_inline_charge_reattached_to_fresh_prepared_graph_here': False,
        'float80_template_origin_excluded_under_named_relation': True,
        'continuing_identifier_inequality_instantiated': False,
        'complete_nonaliasing_task_mapping': False,
        'actual_ordinary_attempt_classification': None, 'complete_q': None,
        'global_suffix_budget': {'save_entering_callbacks': 2, 'save_attempts': 3, 'e_upper': 2},
        'native_solver_proof_capture_runs': 0,
        'note_identity': ident((ROOT / 'docs/research/retained-cvc5-task-acceptance.md').read_bytes()),
        'checked_member_identities': members,
        'checker_scope': 'Exact finite bytes, structured module roots, lexical dependency-head coverage, transitive graph, and displayed arithmetic. Semantic preservation is the accompanying source argument, not proved by this script.',
    }
    for name, value in [('result.json', result), ('source-witnesses.json', witnesses)]:
        output = canonical(value)
        if write:
            (HERE / name).write_text(output)
        else:
            assert (HERE / name).read_text() == output, name
    for archive in archives.values():
        archive.close()
    print(f'checked {len(manifest["files"])} pinned inputs, {len(members)} archive members; '
          f'{len(root_union)} roots, {len(closure)} reachable modules, {len(edges)} edges; whole q remains null')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    run(parser.parse_args().write)

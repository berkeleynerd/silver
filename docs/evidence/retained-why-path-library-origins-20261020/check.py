#!/usr/bin/env python3
"""Bind the new source-origin/effect argument to retained inputs.

This is an identity/census check, not a semantic proof or a predecessor replay.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
TAIL = 'docs/evidence/retained-producer-fixed-tail-20261018/observations.tar.gz'
DIM = 'docs/evidence/retained-producer-prefix-gc-20261018/dimensions-sources.tar.gz'
LIB = 'docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz'
INPUTS = [WHY,
    TAIL, DIM, LIB,
    'docs/evidence/retained-producer-prefix-gc-20261018/dimensions-inputs.json',
    'docs/reviews/review-save-capacity-round31-20261020.md',
    'docs/research/retained-why-path-payload-bound.md',
    'docs/evidence/retained-why-path-payload-bound-20261020/result.json',
    'docs/evidence/retained-why-path-payload-bound-20261020/source-witnesses.json',
    'docs/evidence/retained-why-path-input-inventory-20261020/library-inventory.json',
    'docs/evidence/retained-producer-fixed-context-20261018/result.json',
    'docs/evidence/retained-producer-driver-envelope-20261018/result.json',
    'docs/research/retained-producer-driver-envelope.md',
    'docs/evidence/retained-why-native-effect-completeness-20261019/configuration.json',
    'docs/evidence/retained-why-native-effect-completeness-20261019/companion-effect-ledger.json',
    'docs/evidence/retained-why-native-effect-completeness-20261019/result.json']

# Entire selected implementation bodies, including indirect helper definitions.
FULL = [
    'src/core/env.ml', 'src/core/trans.ml', 'src/core/task.ml',
    'src/core/printer.ml', 'src/core/pretty.ml',
    'src/transform/prepare_for_counterexmp.ml', 'src/transform/inlining.ml',
    'src/transform/eliminate_definition.ml', 'src/transform/remove_unused.ml',
    'src/transform/detect_polymorphism.ml', 'src/transform/eliminate_inductive.ml',
    'src/transform/eliminate_gnatprove_guard_epsilon.ml',
    'src/transform/eliminate_epsilon.ml', 'src/transform/eliminate_literal.ml',
    'src/transform/simplify_formula.ml', 'src/transform/eliminate_algebraic.ml',
    'src/transform/discriminate.ml', 'src/transform/encoding_select.ml',
    'src/transform/introduction.ml', 'src/transform/split_goal.ml',
    'src/printer/smtv2.ml', 'src/util/exthtbl.ml', 'src/util/weakhtbl.ml',
    'src/util/exn_printer.ml', 'src/gnat/gnat_report.ml',
    'src/gnat/gnat_util.ml', 'src/gnat/gnat_scheduler.ml']
SPECS = [
    ('src/core/theory.ml', 127, 158),
    ('src/core/theory.ml', 215, 240),
    ('src/core/decl.ml', 82, 104),
    ('src/core/decl.ml', 340, 370),
    ('src/mlw/pmodule.ml', 221, 312),
    ('src/mlw/pmodule.ml', 345, 386),
    ('src/mlw/pmodule.ml', 481, 568),
    ('src/mlw/pmodule.ml', 575, 1150),
    ('src/mlw/pmodule.ml', 1150, 1396),
    ('src/mlw/pmodule.ml', 1445, 1702),
    ('src/mlw/pdecl.ml', 20, 143),
    ('src/mlw/ity.ml', 125, 171),
    ('src/mlw/ity.ml', 543, 616),
    ('src/mlw/ity.ml', 751, 757),
    ('src/mlw/expr.ml', 20, 58),
    ('src/mlw/expr.ml', 112, 217),
    ('src/mlw/expr.ml', 721, 733),
    ('src/mlw/expr.ml', 1189, 1307),
    ('src/mlw/dexpr.ml', 674, 690),
    ('src/mlw/dexpr.ml', 965, 990),
    ('src/mlw/dexpr.ml', 1497, 1545),
    ('src/mlw/dexpr.ml', 1640, 1680),
    ('src/mlw/dexpr.ml', 1720, 1788),
    ('src/parser/typing.ml', 188, 199),
    ('src/parser/typing.ml', 290, 328),
    ('src/parser/typing.ml', 1063, 1073),
    ('src/parser/typing.ml', 1206, 1218),
    ('src/parser/typing.ml', 1315, 1474),
    ('src/parser/typing.ml', 1583, 1770),
    ('src/parser/typing.ml', 1781, 1842),
    ('src/parser/typing.ml', 1894, 1967),
    ('src/parser/lexer.mll', 207, 280),
    ('src/parser/parser.mly', 61, 134),
    ('src/gnat/gnat_config.ml', 343, 409),
    ('src/gnat/gnat_main.ml', 78, 120),
    ('src/gnat/gnat_main.ml', 166, 267),
    ('src/gnat/gnat_main.ml', 268, None),
    ('src/gnat/gnat_checks.ml', 365, 448),
    ('src/session/controller_itp.ml', 114, 138),
    ('src/session/controller_itp.ml', 246, 261),
    ('src/session/controller_itp.ml', 409, 438),
    ('src/session/controller_itp.ml', 450, 536),
    ('src/driver/driver.ml', 24, 32),
    ('src/driver/driver.ml', 330, 408),
    ('src/driver/driver.ml', 456, 499),
    ('src/driver/call_provers.ml', 233, 402),
    ('src/driver/call_provers.ml', 462, 520),
    ('src/driver/smtv2_model_parser.ml', 788, 920),
    ('src/driver/smtv2_model_parser.ml', 1605, None),
    ('src/driver/whyconf.ml', 1188, 1207),
    ('plugins/ada_terms/ada_main.ml', 190, None),
    ('plugins/gnat_json/gnat_ast_to_ptree.ml', 1410, None)]

TRANSFORM_FILES = {
    'counterexamples_dependent_intros': 'prepare_for_counterexmp',
    'inline_trivial': 'inlining', 'eliminate_builtin': 'eliminate_definition',
    'remove_unused': 'remove_unused', 'detect_polymorphism': 'detect_polymorphism',
    'eliminate_definition_conditionally': 'eliminate_definition',
    'eliminate_inductive': 'eliminate_inductive',
    'eliminate_gnatprove_guard_epsilon': 'eliminate_gnatprove_guard_epsilon',
    'eliminate_epsilon': 'eliminate_epsilon', 'eliminate_literal': 'eliminate_literal',
    'simplify_formula': 'simplify_formula',
    'eliminate_projections_sums': 'eliminate_algebraic',
    'discriminate_if_poly': 'discriminate',
    'eliminate_algebraic_if_poly': 'eliminate_algebraic',
    'encoding_smt_if_poly': 'encoding', 'monomorphise_goal': 'libencoding',
    'eliminate_recursion': 'eliminate_definition',
    'eliminate_algebraic': 'eliminate_algebraic',
    'split_premise_right': 'split_goal', 'introduce_premises': 'introduction'}
FLAGS = ['ft_select_inst', 'ft_select_lskept', 'ft_select_lsinst', 'ft_select_alginst']


def ident(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads((ROOT / path).read_text())


def uncomment(text):
    """Retained driver lexer rules; same scanner as fixed-tail evidence."""
    out, i, depth, quoted = [], 0, 0, False
    while i < len(text):
        c = text[i]
        if depth:
            if text.startswith('(*', i):
                depth += 1; out += '  '; i += 2
            elif text.startswith('*)', i):
                depth -= 1; out += '  '; i += 2
            else:
                out.append('\n' if c == '\n' else ' '); i += 1
        elif quoted:
            out.append(c); i += 1
            if c == '\\':
                assert i < len(text)
                out.append(text[i]); i += 1
            elif c == '"':
                quoted = False
        elif text.startswith('(*)', i):
            out += '(*)'; i += 3
        elif text.startswith('(*', i):
            depth = 1; out += '  '; i += 2
        else:
            out.append(c); i += 1
            if c == '"':
                quoted = True
    assert depth == 0 and not quoted
    return ''.join(out)


def compute():
    with tarfile.open(ROOT / WHY) as t:
        sources = {m.name: t.extractfile(m).read() for m in t.getmembers()
                   if m.isfile() and m.name.endswith(('.ml', '.mli', '.mll', '.mly'))}
    witnesses = []
    for name, first, last in [(p, 1, None) for p in FULL] + SPECS:
        member = 'why3/' + name
        raw = sources[member]
        lines = raw.decode().splitlines(keepends=True)
        last = len(lines) if last is None else last
        assert 1 <= first <= last <= len(lines), member
        excerpt = ''.join(lines[first-1:last])
        witnesses.append({'member': member, 'member_identity': ident(raw),
                          'first': first, 'last': last, 'text': excerpt,
                          'excerpt_identity': ident(excerpt.encode())})
    census = {'environment_construction': [], 'discrimination_flags': [],
              'meta_registration': [], 'counterexample_meta_references': [],
              'program_restore_clients': [], 'exception_registrations': []}
    exceptions = []
    for member, raw in sorted(sources.items()):
        lines = raw.decode().splitlines(keepends=True)
        for i, line in enumerate(lines):
            row = {'member': member, 'line': i+1, 'text': line.rstrip('\n')}
            if 'Env.create_env' in line:
                census['environment_construction'].append(row)
            if re.search(r'\b(register_meta|register_meta_excl)\b', line):
                census['meta_registration'].append(row)
            if 'get_counterexmp' in line:
                census['counterexample_meta_references'].append(row)
            if re.search(r'\b(' + '|'.join(FLAGS) + r')\b', line):
                census['discrimination_flags'].append(row)
            if re.search(r'\b(restore_its|restore_rs|restore_pv)\b', line):
                census['program_restore_clients'].append(row)
            if 'Exn_printer.register' in line:
                census['exception_registrations'].append(row)
                if member.startswith(('why3/src/', 'why3/plugins/ada_terms/',
                                      'why3/plugins/gnat_json/')):
                    # A containing suffix, not a claim to parse an OCaml body.
                    exceptions.append({'member': member, 'member_identity': ident(raw),
                        'first': i+1, 'last': len(lines), 'text': ''.join(lines[i:])})
    dispatch = read('docs/evidence/retained-producer-driver-envelope-20261018/result.json')['selected_driver_dispatch']
    selected = {r['name'] for d in dispatch.values() for r in d['transformations']}
    assert selected == set(TRANSFORM_FILES)
    registrations = []
    for name, stem in sorted(TRANSFORM_FILES.items()):
        member = 'why3/src/transform/' + stem + '.ml'
        raw = sources[member]
        pattern = r'\bregister_(?:env_)?transform\s+"' + re.escape(name) + '"'
        matches = list(re.finditer(pattern, raw.decode()))
        assert len(matches) == 1, name
        registrations.append({'name': name, 'member': member,
            'line': raw[:matches[0].start()].count(b'\n')+1,
            'member_identity': ident(raw)})
    lib = read('docs/evidence/retained-why-path-input-inventory-20261020/library-inventory.json')
    old = read('docs/evidence/retained-why-path-payload-bound-20261020/result.json')
    assert lib['total_source_bytes'] == 38678
    assert lib['source_dependency_graph_acyclic']
    assert lib['same_file_dependencies_reference_prior_module_heads']
    assert lib['all_module_heads_are_plain_unqualified_names']
    assert lib['clone_val_exception_substitution_candidate_count'] == 0
    assert old['library_origin_lemma_payload_upper'] == 116162
    assert not old['all_selectable_payloads_bounded']
    flag_members = sorted({r['member'] for r in census['discrimination_flags']})
    assert flag_members == ['why3/src/transform/discriminate.ml',
                            'why3/src/transform/discriminate.mli',
                            'why3/src/transform/encoding_select.ml']
    # New, narrow CE-meta input check. No retained capture/proof checker runs.
    dimensions = read('docs/evidence/retained-producer-prefix-gc-20261018/dimensions-inputs.json')
    with tarfile.open(ROOT / TAIL) as t:
        retained = {m.name: t.extractfile(m).read() for m in t.getmembers() if m.isfile()}
    resolution = json.loads(retained['driver-resolution.json'])
    with tarfile.open(ROOT / DIM) as t:
        texts = {p: t.extractfile(v['member']).read()
                 for p, v in dimensions['installed_text'].items()}
    overlay_root = '/tmp/silver-producer-fixed-tail-20261018/'
    texts.update({overlay_root+n: b for n,b in retained.items() if n.startswith('overlay/')})
    ce_inputs = []
    for path, row in sorted(resolution.items()):
        data = texts[path]
        assert ident(data) == row['identity'], path
        code = uncomment(data.decode())
        assert 'get_counterexmp' not in code, path
        ce_inputs.append({'kind': 'resolved_driver', 'path': path, **ident(data),
                          'raw_comment_mentions': data.count(b'get_counterexmp')})
    for name, data in sorted(retained.items()):
        if name.endswith('.gnat-json'):
            assert b'get_counterexmp' not in data, name
            ce_inputs.append({'kind': 'native_input', 'member': name, **ident(data)})
    with tarfile.open(ROOT / LIB) as t:
        for m in t.getmembers():
            if m.isfile() and m.name.startswith('installed/') and m.name.endswith(('.mlw','.why')):
                data = t.extractfile(m).read()
                assert b'get_counterexmp' not in data, m.name
                ce_inputs.append({'kind': 'prefix_library', 'member': m.name, **ident(data)})
    assert sum(r['kind']=='resolved_driver' for r in ce_inputs) == 14
    assert sum(r['kind']=='native_input' for r in ce_inputs) == 5
    assert sum(r['kind']=='prefix_library' for r in ce_inputs) == 11
    return {
        'inputs.json': {p: ident((ROOT/p).read_bytes()) for p in INPUTS},
        'source-witnesses.json': witnesses,
        'reference-census.json': census,
        'exception-printer-suffixes.json': exceptions,
        'selected-dispatch.json': {'drivers': dispatch, 'registrations': registrations,
            'discrimination_flags': FLAGS, 'choices_per_flag': ['none','goal','local','all'],
            'flag_reference_members': flag_members},
        'counterexample-meta-inputs.json': {'inputs': ce_inputs,
            'forbidden_meta': 'get_counterexmp', 'occurrences_outside_driver_comments': 0,
            'note': 'Input absence is combined with the source meta-preservation argument; this census alone is not the theorem'},
        'result.json': {
            'scope': 'Selected later Theory path writers and named library/declaration origins',
            'source_argument_machine_checked': False,
            'environment_constructions_in_selected_lifetime': 2,
            'environment_tags': [0, 1],
            'named_file_and_module_keys_are_structural_strings': True,
            'global_program_restore_caches_proved_collision_free': False,
            'all_expression_body_symbols_proved_library_local': False,
            'replacement_invariant': 'Named module DAG, bounded declared heads/type-definition graphs/namespace units; expression bodies may contain foreign restored symbols',
            'later_successfully_constructed_path_payload_bytes_upper': 116162,
            'later_payload_bytes_upper_under_named_relation': 116162,
            'complete_selected_later_path_writer_coverage_under_named_relation': True,
            'named_relation': 'Five retained Linux x86_64 processes; fixed inputs/source/runtime relation, selected loading/configuration/root family, valid table operations, and normal numeric/allocation services',
            'writer_coverage_is_reviewable_source_argument': True,
            'normal_numeric_and_allocation_services_required': True,
            'failed_numeric_service_payload_bound': None,
            'selected_transform_names': len(selected),
            'driver_printers': sorted({d['printer'] for d in dispatch.values()}),
            'additional_discrimination_flag_choices': 16,
            'source_witness_count': len(witnesses),
            'exception_registration_census_count': len(census['exception_registrations']),
            'retained_exception_printer_suffix_count': len(exceptions),
            'actual_initial_selectable_payload_bound': None,
            'actual_whole_process_R': None,
            'actual_whole_process_U': None,
            'initial_old_array_exclusion_in_this_packet': False,
            'path_native_construction_in_this_packet': False,
            'complete_save_capacity_established': False,
            'whole_pipeline_capacity_established': False,
            'native_runs': 0, 'new_captures': 0, 'proof_runs': 0,
            'source_fetches': 0, 'predecessor_checker_replays': 0}}


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--write', action='store_true')
    args = p.parse_args()
    results = compute()
    for name, value in results.items():
        path = HERE / name
        if args.write:
            path.write_text(json.dumps(value, indent=2) + '\n')
        else:
            assert json.loads(path.read_text()) == value, name
    print(json.dumps({'status': 'pass', 'json_comparisons': len(results),
        'source_witnesses': results['result.json']['source_witness_count'],
        'selected_transforms': results['result.json']['selected_transform_names'],
        'later_payload_bound': 116162, 'actual_whole_process_R': None}))


if __name__ == '__main__':
    main()

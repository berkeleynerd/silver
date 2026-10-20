#!/usr/bin/env python3
"""Retained-source identities and conditional path-payload arithmetic.

Source effect arguments are reviewed prose, not proved by this census.
This checker performs no source fetch, capture, native run, or proof run.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
E = HERE.parent
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
LIBRARY = 'docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz'
LIB_PREFIX = 'installed/libexec/spark/share/why3/theories/'
OPREFIX = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/'
INPUTS = [WHY, OCAML, LIBRARY,
    'docs/evidence/retained-why-save-serializer-inputs-20261020/result.json',
    'docs/evidence/retained-why-save-formatter-core-20261020/result.json',
    'docs/evidence/retained-why-restored-path-continuation-20261020/result.json',
    'docs/evidence/retained-why-path-input-inventory-20261020/library-inventory.json',
    'docs/evidence/retained-why-path-input-inventory-20261020/capture-inventory.json',
    'docs/evidence/retained-why-path-input-inventory-20261020/cut-evidence.json',
    'docs/evidence/retained-why-path-input-inventory-20261020/result.json',
    'docs/evidence/retained-why-session-helper-source-20261019/runtime-version.json']

# Full encoding callback bodies are retained, not just their registration lines.
SPECS = [
    ('why3/src/core/theory.ml', 307, 349),
    ('why3/src/core/theory.ml', 472, 516),
    ('why3/src/core/theory.ml', 549, 591),
    ('why3/src/core/theory.ml', 1047, 1055),
    ('why3/src/core/ty.ml', 65, 89),
    ('why3/src/core/ty.ml', 278, 286),
    ('why3/src/core/term.ml', 53, 84),
    ('why3/src/core/term.ml', 1037, 1048),
    ('why3/src/core/decl.ml', 340, 370),
    ('why3/src/core/ident.ml', 158, 213),
    ('why3/src/core/ident.ml', 76, 90),
    ('why3/src/core/task.ml', 148, 200),
    ('why3/src/core/trans.ml', 12, 138),
    ('why3/src/core/trans.ml', 199, 226),
    ('why3/src/core/trans.ml', 234, 320),
    ('why3/src/core/trans.ml', 521, 545),
    ('why3/src/core/printer.ml', 595, 609),
    ('why3/src/core/env.ml', 191, 222),
    ('why3/src/session/session_itp.ml', 2099, 2107),
    ('why3/src/transform/eliminate_algebraic.ml', 32, 56),
    ('why3/src/transform/eliminate_algebraic.ml', 470, 487),
    ('why3/src/transform/eliminate_literal.ml', 193, 228),
    ('why3/src/transform/encoding.ml', 12, None),
    ('why3/src/transform/encoding_select.ml', 12, 74),
    ('why3/src/transform/encoding_twin.ml', 12, None),
    ('why3/src/transform/encoding_guards.ml', 12, None),
    ('why3/src/transform/encoding_tags.ml', 12, None),
    ('why3/src/transform/encoding_guards_full.ml', 12, None),
    ('why3/src/transform/encoding_tags_full.ml', 12, None),
    ('why3/src/transform/libencoding.ml', 12, None),
    ('why3/src/parser/typing.ml', 1675, 1754),
    ('why3/src/parser/typing.ml', 185, 198),
    ('why3/src/parser/typing.ml', 1469, 1473),
    ('why3/src/parser/typing.ml', 1566, 1581),
    ('why3/src/parser/typing.ml', 1593, 1654),
    ('why3/src/parser/typing.ml', 1808, 1827),
    ('why3/src/parser/parser.mly', 61, 134),
    ('why3/src/parser/parser_common.mly', 403, 418),
    ('why3/src/parser/lexer.mll', 259, 280),
    ('why3/src/mlw/pmodule.ml', 373, 379),
    ('why3/src/mlw/pmodule.ml', 410, 486),
    ('why3/src/mlw/pmodule.ml', 527, 555),
    ('why3/src/mlw/pmodule.ml', 730, 834),
    ('why3/src/mlw/pmodule.ml', 1051, 1082),
    ('why3/src/mlw/pmodule.ml', 1348, 1396),
    ('why3/src/mlw/pmodule.ml', 1445, 1467),
    ('why3/src/mlw/pmodule.ml', 1591, 1635),
    ('why3/src/mlw/pdecl.ml', 378, 507),
    ('why3/src/mlw/pdecl.ml', 530, 610),
    ('why3/src/mlw/pdecl.ml', 611, 649),
    ('why3/src/mlw/vc.ml', 1740, None),
    ('why3/src/mlw/expr.ml', 115, 153),
    ('why3/src/mlw/expr.ml', 726, 733),
]
OSPECS = [('stdlib/stdlib.ml', 267, 268), ('runtime/ints.c', 119, 185),
          ('stdlib/string.ml', 49, 77), ('stdlib/ephemeron.ml', 195, 211),
          ('stdlib/ephemeron.ml', 540, 560)]


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def source_packet():
    witnesses, census = [], []
    for archive, specs in [(WHY, SPECS),
                           (OCAML, [(OPREFIX + p, a, b) for p, a, b in OSPECS]),
                           (LIBRARY, [(LIB_PREFIX + p + '.mlw', 1, None)
                                      for p in ['int', 'real', 'algebra', 'relations']])]:
        with tarfile.open(ROOT / archive) as t:
            for member, first, last in specs:
                raw = t.extractfile(member).read()
                lines = raw.decode().splitlines(keepends=True)
                last = len(lines) if last is None else last
                assert 1 <= first <= last <= len(lines), member
                excerpt = ''.join(lines[first - 1:last])
                witnesses.append({'archive': archive, 'member': member,
                    'member_identity': identity(raw), 'first': first, 'last': last,
                    'text': excerpt, 'excerpt_identity': identity(excerpt.encode())})
            if archive == WHY:
                for m in t.getmembers():
                    if not m.isfile() or not m.name.endswith(('.ml', '.mli')):
                        continue
                    for line, text in enumerate(t.extractfile(m).read().decode().splitlines(), 1):
                        if re.search(r'\b(ft_select_kept|ft_enco_kept|ft_enco_poly)\b', text):
                            census.append({'member': m.name, 'line': line, 'text': text})
    return witnesses, census


def candidate(c, fmt, payload_upper):
    names = [x for x in c['inventory']['identifiers'] if x['serializer_visits']]
    n = sum(x['serializer_visits'] for x in names)
    captured = sum(x['serializer_visits'] * x['fallback_or_captured_qualified_bytes_upper']
                   for x in names)
    fixed_strings = c['candidate_raw_string_bytes_sum_per_save'] - captured
    fallback = max(x['fallback']['bytes'] for x in names)
    q, d = fmt['Q'], fmt['candidate_d']
    fixed_format = 1152 * q + 32 * q * d + 79
    if payload_upper is None:
        return None, None
    if type(payload_upper) is not int or payload_upper < 0:
        raise ValueError('payload bound must be a nonnegative mathematical integer')
    u = fixed_strings + n * max(fallback, payload_upper)
    return u, fixed_format + 7 * u


def compute():
    source, census = source_packet()
    library_bytes = sum(w['member_identity']['bytes'] for w in source if w['archive'] == LIBRARY)
    assert library_bytes == 38678
    inv = read(E / 'retained-why-path-input-inventory-20261020/library-inventory.json')
    assert inv['total_source_bytes'] == library_bytes
    assert inv['module_count'] == 69 and inv['dependency_declaration_count'] == 102
    assert inv['source_dependency_graph_acyclic']
    assert inv['same_file_dependencies_reference_prior_module_heads']
    assert inv['module_head_interface_colon_count'] == 0
    assert inv['all_module_heads_are_plain_unqualified_names']
    assert inv['explicit_scope_head_count'] == inv['nested_module_head_count'] == 0
    assert inv['clone_val_exception_substitution_candidate_count'] == 0
    assert all(v == 0 for v in inv['typed_source_excluded_keyword_counts'].values())
    assert inv['external_targets'] == ['why3.WellFounded.WellFounded']
    with tarfile.open(ROOT / LIBRARY) as t:
        for f in inv['files']:
            assert identity(t.extractfile(f['member']).read()) == f['identity']
    library_payload_bound = 3 * library_bytes + 128
    serializer = read(E / 'retained-why-save-serializer-inputs-20261020/result.json')
    formatter = read(E / 'retained-why-save-formatter-core-20261020/result.json')
    old = read(E / 'retained-why-restored-path-continuation-20261020/result.json')
    by_case = {c['case']: c for c in formatter['cases']}
    old_by_case = {c['case']: c for c in old['cases']}
    rows = []
    for c in serializer['cases']:
        f, prior = by_case[c['case']], old_by_case[c['case']]
        names = [x for x in c['inventory']['identifiers'] if x['serializer_visits']]
        n = sum(x['serializer_visits'] for x in names)
        fallback = max(x['fallback']['bytes'] for x in names)
        fixed_strings = prior['nonidentifier_byte_sum_upper']
        assert n == prior['identifier_occurrence_count']
        q, d = f['Q'], f['candidate_d']
        fixed_format = 1152 * q + 32 * q * d + 79
        ceiling = (1000000010 - fixed_format - 7 * fixed_strings) // (7 * n)
        assert ceiling >= fallback
        _, good = candidate(c, f, ceiling)
        _, bad = candidate(c, f, ceiling + 1)
        assert good <= 1000000010 < bad
        u25, l25 = candidate(c, f, 25)
        ulib, llib = candidate(c, f, library_payload_bound)
        assert l25 <= 1000000010
        assert llib <= 1000000010
        assert candidate(c, f, None) == (None, None)
        for invalid in (-1, True):
            try:
                candidate(c, f, invalid)
            except ValueError:
                pass
            else:
                raise AssertionError('invalid payload bound accepted')
        rows.append({'case': c['case'], 'pid': c['pid'], 'identifier_occurrences': n,
            'nonidentifier_raw_bytes': fixed_strings, 'fallback_max_bytes': fallback,
            'Q': q, 'candidate_d': d,
            'largest_uniform_payload_bound_passing_sentinel_guard': ceiling,
            'sentinel_expression_at_ceiling': good,
            'sentinel_expression_at_ceiling_plus_one': bad,
            'hypothetical_all_payloads_le25_U': u25,
            'hypothetical_all_payloads_le25_L_plus79': l25,
            'conditional_uniform_library_bound_U': ulib,
            'conditional_uniform_library_bound_L_plus79': llib,
            'actual_all_selectable_payload_bound': None,
            'actual_U': None, 'complete_save_capacity_established': False})
    # The signed minimum has 19 digits and one sign. Positive ints have <=19.
    assert len(str(-(1 << 62))) == 20 and len(str((1 << 62) - 1)) == 19
    assert 10 ** 18 <= 1 << 62 < 10 ** 19
    return {
        'inputs.json': {p: identity((ROOT / p).read_bytes()) for p in INPUTS},
        'source-witnesses.json': source,
        'encoding-registry-census.json': census,
        'result.json': {'scope': 'Source-local tuple and encoding results; conditional uniform path-payload guard',
            'tuple_name_bytes_upper': 25, 'tuple_path_components_upper': 1,
            'fixed_library_source_bytes': library_bytes,
            'library_origin_lemma_payload_upper': library_payload_bound,
            'library_origin_lemma_is_whole_process_payload_bound': False,
            'library_inventory_author_commit': 'd35f7809e5366bbdb4012315de00d7089130233b',
            'encoding_registry_reference_count': len(census),
            'source_witness_count': len(source), 'cases': rows,
            'all_five_common_payload_ceiling': min(r['largest_uniform_payload_bound_passing_sentinel_guard'] for r in rows),
            'all_selectable_payloads_bounded': False, 'whole_save_capacity_established': False,
            'whole_pipeline_capacity_established': False,
            'native_runs': 0, 'captures': 0, 'proof_runs': 0, 'source_fetches': 0,
            'checks': ['exact source bytes and complete retained registry-reference census',
                       'native signed decimal endpoint inequality',
                       'five exact sentinel boundaries and first rejecting successors',
                       'unknown payload remains unknown; negative and bool bounds rejected']}}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--write', action='store_true')
    args = ap.parse_args()
    outputs = compute()
    for name, result in outputs.items():
        path = HERE / name
        if args.write:
            path.write_text(json.dumps(result, indent=2) + '\n')
        else:
            assert read(path) == result, name
    print(json.dumps({'checked': list(outputs), 'cases': 5,
                     'source_witnesses': len(outputs['source-witnesses.json']),
                     'actual_payload_bound_established': False, 'native_runs': 0}))


if __name__ == '__main__':
    main()

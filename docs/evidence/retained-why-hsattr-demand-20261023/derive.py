"""Hsattr source/retained-input projection. No native or predecessor execution."""
import ast
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent
CASES = ('put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid')
SOURCE = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
LIBRARY = 'docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz'
NATIVE = 'docs/evidence/retained-producer-prefix-gc-20261018/observations.tar.gz'
TRANSFER = 'docs/evidence/retained-why-inline-operations-20261018/compose.py'
INT_MAX = 2**62 - 1
ARRAY_MAX = 2**54 - 1
B = 2**28


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def write(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def transfers():
    # Extract only these already accepted pure definitions. Do not import its
    # model, graph replay or any predecessor checker.
    tree = ast.parse((ROOT / TRANSFER).read_text())
    names = ('natural', 'counter_transfer', 'weak_transfer')
    nodes = [n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in names]
    assert {n.name for n in nodes} == set(names)
    env = {'INT_MAX': INT_MAX}
    exec(compile(ast.Module(body=nodes, type_ignores=[]), TRANSFER, 'exec'), env)
    return env


def no_at(strings):
    assert all(isinstance(s, str) and not s.startswith('at:') for s in strings)


def origin_projection():
    rows = []
    for case in CASES:
        gp = EV / 'retained-why-preinline-prefix-20261020' / (case + '-graph.json.gz')
        tp = EV / 'retained-why-fixed-inline-family-20261020' / (case + '-types.json')
        g = json.loads(gzip.decompress(gp.read_bytes()))
        t = read(tp)
        groups = {
            'all_stored_and_candidate_terms': [x['attrs'] for x in g['terms']],
            'all_graph_variables': [x['attrs'] for x in g['variables'].values()],
            'all_graph_symbols': [x['attrs'] for x in g['symbols'].values()],
            'declaration_type_and_signature_identifiers': [x['attrs'] for x in t['identifiers'].values()],
        }
        projected = {}
        for name, sets in groups.items():
            strings = sorted({a for aa in sets for a in aa})
            no_at(strings)
            projected[name] = dict(records=len(sets), distinct_strings=strings,
                                   at_prefix_strings=[], maximum_cardinality=max(map(len, sets), default=0))
        term_strings = projected['all_stored_and_candidate_terms']['distinct_strings']
        hyp = sorted(a[len('hyp_name:'):] for a in term_strings if a.startswith('hyp_name:'))
        assert max(map(len, hyp), default=0) <= 13
        # Relevant original heads are in either stored term symbols or d_news;
        # types.json's separate projection attaches the latter and data fields.
        all_news = {str(i) for d in t['declarations'].values() for i in d['news']}
        assert all_news <= set(t['identifiers'])
        assert all(str(s['identifier']) in t['identifiers'] for s in t['signatures'].values())
        rows.append(dict(case=case, groups=projected, hyp_name_values=hyp,
                         hyp_name_value_bytes_max=max(map(len, hyp), default=0),
                         source_capture=t['input'], graph_identity=identity(gp.read_bytes()),
                         signature_projection_identity=identity(tp.read_bytes()),
                         all_declaration_news_identifiers_covered=True))
    library = []
    with tarfile.open(ROOT / LIBRARY) as archive:
        for stem in ('algebra', 'int', 'real', 'relations'):
            member = 'installed/libexec/spark/share/why3/theories/' + stem + '.mlw'
            raw = archive.extractfile(member).read()
            s = raw.decode()
            assert '[@' not in s and re.search(r'\b(?:old|at)\b', s) is None
            annotations = list(re.finditer(r'\b(requires|ensures|assert|assume|check|invariant|variant)\b', s))
            # Every selected source annotation omits its optional explicit name.
            assert all(s[m.end():].lstrip().startswith('{') for m in annotations)
            library.append(dict(member=member, identity=identity(raw),
                                attributes_old_and_at_tokens_absent=True,
                                annotation_keywords=[m.group() for m in annotations],
                                all_optional_annotation_names_absent=True))
    return dict(cases=rows, libraries=library, library_hyp_name_values=['Ensures', 'Requires', 'Variant'],
                continuing_hyp_name_value_bytes_upper=13,
                source_induction_machine_checked=False)


RANGES = {
    'why3/src/core/ident.ml': [(16, 59), (173, 216), (355, 421), (443, 462), (488, 496), (535, 557)],
    'why3/src/util/hashcons.ml': [(23, 56)],
    'why3/src/core/term.ml': [(640, 660), (1675, 1714), (1850, 1888)],
    'why3/src/parser/parser_common.mly': [(95, 134), (175, 179), (1166, 1176), (1286, 1300), (1333, 1345), (1607, 1613)],
    'why3/src/parser/typing.ml': [(329, 362), (1668, 1680)],
    'why3/src/mlw/pdecl.ml': [(341, 355), (379, 506)],
    'why3/src/mlw/pmodule.ml': [(547, 556), (1349, 1357)],
    'why3/src/mlw/expr.ml': [(856, 879)],
    'why3/src/mlw/vc.ml': [(1672, 1690)],
    'why3/src/transform/prepare_for_counterexmp.ml': [(15, 34)],
    'why3/src/transform/introduction.ml': [(148, 224), (509, 528)],
    'why3/src/printer/cntexmp_printer.ml': [(104, 129)],
    'why3/src/printer/smtv2.ml': [(405, 430), (726, 765), (1003, 1075)],
    'why3/src/session/session_itp.ml': [(1063, 1083)],
}


def source_projection():
    out = []
    with tarfile.open(ROOT / SOURCE) as archive:
        for member, ranges in RANGES.items():
            raw = archive.extractfile(member).read()
            lines = raw.decode().splitlines(keepends=True)
            excerpts = []
            for lo, hi in ranges:
                assert 1 <= lo <= hi <= len(lines), (member, lo, hi, len(lines))
                text = ''.join(lines[lo-1:hi])
                excerpts.append(dict(first=lo, last=hi, text=text, identity=identity(text.encode())))
            out.append(dict(archive=SOURCE, member=member, identity=identity(raw), lines=len(lines), excerpts=excerpts))
        pattern = re.compile(r'\b(?:create_attribute|attribute_of_sexp|create_model_trace_attr|create_written_attr|create_call_result_attr|create_eid_attr|transform_model_trace_attr|append_to_model_element_name|append_to_model_trace_attr|compute_model_trace_field|suffix_attr_name|Hsattr)\b')
        census = []
        members = []
        for member in archive.getmembers():
            if not member.isfile() or not member.name.startswith('why3/') or not member.name.endswith(('.ml', '.mli', '.mll', '.mly')):
                continue
            raw = archive.extractfile(member).read()
            members.append(dict(member=member.name, identity=identity(raw)))
            for line, text in enumerate(raw.decode().splitlines(), 1):
                if pattern.search(text):
                    census.append(dict(member=member.name, line=line, text=text))
    with tarfile.open(ROOT / NATIVE) as archive:
        for member, marker in [('success/attribute-static.txt', 'Dump of assembler code'),
                               ('success/installed-constructors.txt', 'Dump of assembler code for function camlWhy3__Hashcons__hashcons_412:')]:
            raw = archive.extractfile(member).read()
            lines = raw.decode().splitlines(keepends=True)
            lo = next(i+1 for i, s in enumerate(lines) if s.startswith(marker))
            hi = next(i+1 for i in range(lo, len(lines)) if lines[i].startswith('End of assembler dump.'))
            text = ''.join(lines[lo-1:hi])
            if 'attribute' in member:
                assert 'sub    $0x18,%r15' in text and 'camlWhy3__Ident__tag_1336' in text
            else:
                assert text.index('caml_apply2') < text.index('camlStdlib__Weak__merge_795') < text.index('addq   $0x2')
            out.append(dict(archive=NATIVE, member=member, identity=identity(raw), lines=len(lines),
                            excerpts=[dict(first=lo, last=hi, text=text, identity=identity(text.encode()))]))
    return dict(witnesses=out, reference_census=census, source_members=members,
                census_is_reachability_proof=False, comments_and_interfaces_retained=True)


def calculate(escape=2):
    if type(escape) is not int or not 0 <= escape <= 2:
        raise ValueError('one process-global integer e in [0,2]')
    trans = transfers()
    shared = read(EV / 'retained-six-owner-round63-20261023/candidate-composition-result.json')
    prefix = read(EV / 'retained-parallel-logging-prefix-20261020/cut-projection.json')
    lib = read(EV / 'retained-why-library-publication-bound-20261020/bound.json')
    real = lib['direct_root_bounds']['real']['expanded_source_bytes']
    assert real == 807447
    assert shared['native_limits']['max_array_length'] == ARRAY_MAX
    assert shared['native_limits']['max_ephemeron_keys'] == ARRAY_MAX - 2
    rows = []
    for case in CASES:
        prior = next(r for r in shared['cases'] if r['case'] == case)
        family = read(EV / 'retained-why-fixed-inline-family-20261020' / (case + '-family.json'))
        cert = read(EV / 'retained-why-preinline-prefix-20261020' / (case + '-certificate.json'))
        roots = [r['goal'] for r in family['stages']['raw']['roots']]
        selected = {r['goal']: r for r in cert['selected']}
        assert len(set(roots)) == len(roots) == family['registered_roots']
        assert set(roots) <= selected.keys()
        # One direct source-family bound for each possible CE call; surplus
        # mono/validation registrations do not become claimed attribute calls.
        per_root = [selected[r]['ce_direct_Ident_upper'] for r in roots]
        ce = 2 * sum(per_root) + escape * max(per_root)
        assert ce <= prior['demand']['components']['CE_and_monomorphise']['Ident']['increments']
        episodes = 3 * len(roots) + escape
        expanded_parse_slots = 2 * episodes * real
        parser = 4 * expanded_parse_slots
        p = prefix[case.replace('-', '_')]
        initial_words = p['prospective_end_credits']['minor_words']
        assert initial_words < B
        initial = trans['weak_transfer'](5003, 0, 0, B)
        total = B + parser + ce
        backing = trans['weak_transfer'](5003, 0, 0, total)
        counter = trans['counter_transfer'](0, total)
        a = backing['individual_outer_array_length_upper']
        b = backing['individual_bucket_length_upper']
        fits = counter['signed_ocaml_int_fits'] and 3*max(a,b)+6 <= INT_MAX and a <= ARRAY_MAX and b+2 <= ARRAY_MAX-2
        assert fits
        rows.append(dict(case=case, retained_j12_pid=p['captured_pid'],
                         target_cut='prospective combined quiet/timeless/J12/logging registration',
                         prefix_minor_words_upper=initial_words,
                         prefix_requests_upper=B, prefix_next_tag_upper=B,
                         prefix_backing_envelope=initial,
                         initial_state_kind='source initialization plus bounded complete request history; not a captured Hsattr state',
                         registered_roots=len(roots), episodes_upper=episodes,
                         expanded_parser_source_slots=expanded_parse_slots,
                         suffix_requests=dict(library_parser=parser, CE_unused_copy=ce,
                                              other_preparation=0, solver_request_printer=0,
                                              saves=0, other_callbacks_and_shutdown=0),
                         suffix_requests_upper=parser+ce,
                         lifetime_requests_and_increments_upper=total,
                         counter=counter, backing=backing, native_owner_operands_fit=fits,
                         hyp_name_value_bytes_upper=13,
                         actual_whole_process_headroom=False))
    return dict(cases=rows, budgets=dict(escape=escape, save_entering_callbacks=2, saves=3,
                renewed_at_stage_or_owner_boundary=False), source_contracts_pending_independent_review=True,
                seventh_owner_conditional_arithmetic_fits=True, all_seven_owner_composition_claimed=False,
                source_argument_machine_checked=False, attribute_bytes_and_locations_closed=False,
                aggregate_RAM_gate=False, actual_whole_process_headroom=False,
                native_runs=0, predecessor_checker_replays=0)


def dependencies():
    files = [SOURCE, LIBRARY, NATIVE, TRANSFER,
             'docs/evidence/retained-six-owner-round63-20261023/candidate-composition-result.json',
             'docs/evidence/retained-six-owner-round63-20261023/integration-result.json',
             'docs/evidence/retained-printer-names-round64-20261023/README.md',
             'docs/evidence/retained-parallel-logging-prefix-20261020/cut-projection.json',
             'docs/evidence/retained-why-library-publication-bound-20261020/bound.json',
             'docs/evidence/retained-why-fixed-inline-family-20261020/project.py',
             'docs/evidence/retained-why-library-constructors-20261023/family-shapes.json',
             'docs/evidence/retained-why-initial-registration-bound-20261020/result.json']
    notes = ['retained-producer-prefix-gc', 'retained-combined-parallel-startup',
             'retained-parallel-logging-prefix', 'retained-why-shared-demand',
             'retained-why-initial-registration-bound', 'retained-why-preinline-prefix',
             'retained-why-fixed-inline-family', 'retained-why-inline-representative-state',
             'retained-why-library-constructors', 'retained-why-printer-entry',
             'retained-why-printer-demand', 'retained-why-callback-demand',
             'retained-why-model-meta-control', 'retained-why-save-shape-builder-allocation']
    files += ['docs/research/' + n + '.md' for n in notes]
    for case in CASES:
        for folder, suffix in [('retained-why-preinline-prefix-20261020', '-graph.json.gz'),
                               ('retained-why-preinline-prefix-20261020', '-certificate.json'),
                               ('retained-why-fixed-inline-family-20261020', '-family.json'),
                               ('retained-why-fixed-inline-family-20261020', '-types.json')]:
            files.append('docs/evidence/' + folder + '/' + case + suffix)
    return {name: identity((ROOT / name).read_bytes()) for name in files}


if __name__ == '__main__':
    write('inputs.json', dict(base='8b651049e46c8800df92e9efed4832ddfcbad8ab', files=dependencies()))
    write('source-witnesses.json', source_projection())
    write('origins.json', origin_projection())
    write('result.json', calculate())

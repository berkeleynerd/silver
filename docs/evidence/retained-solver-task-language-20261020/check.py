#!/usr/bin/env python3
"""Offline identity/lexical support for the reviewed source argument, not a prover."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
TAIL = 'docs/evidence/retained-producer-fixed-tail-20261018/observations.tar.gz'
LIB = 'docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz'
DRIVERS = 'docs/evidence/retained-solver-identity-20261020/drivers.json'
META = 'docs/evidence/retained-why-path-library-origins-20261020/counterexample-meta-inputs.json'
FILES = [WHY, TAIL, LIB, DRIVERS, META,
    'docs/evidence/retained-producer-prefix-per-check-20261018/observations.tar.gz',
    'docs/evidence/retained-producer-response-20261018/sources.tar.gz',
    'docs/evidence/retained-why-session-helper-source-20261019/source-identities.json',
    'docs/evidence/retained-why-model-meta-control-20261020/attachment.json',
    'docs/evidence/retained-why-model-meta-control-20261020/result.json',
    'docs/evidence/retained-why-path-initial-state-20261020/prefix-attachment.json',
    'docs/evidence/retained-why-path-library-origins-20261020/selected-dispatch.json',
    'docs/research/retained-why-model-meta-control.md',
    'docs/research/retained-why-path-library-origins.md',
    'docs/research/retained-producer-prefix-per-check.md',
    'docs/research/retained-solver-identity.md',
    'docs/reviews/review-save-capacity-round32-20261020.md',
    'docs/research/retained-cvc5-output-capacity.md',
    'docs/research/retained-z3-output-capacity.md',
    'docs/research/retained-altergo-output-capacity.md']
FORBIDDEN = {'get_counterexmp', 'meta_incremental', 'supports_smtlib_minimize'}
SYNTAX = {'syntax_type', 'syntax_logic', 'syntax_literal'}
SPECS = {
    'src/printer/smtv2.ml': [(1, 1082)],
    'src/core/printer.ml': [(130, 429), (447, 561)],
    'src/core/ident.ml': [(225, 351), (373, 404)],
    'src/core/theory.ml': [(85, 158), (215, 240), (848, 883), (965, 1017)],
    'src/core/task.ml': [(51, 181)],
    'src/core/trans.ml': [(44, 151)],
    'src/transform/discriminate.ml': [(480, 504)],
    'src/transform/encoding_sort.ml': [(215, 247)],
    'src/util/constant.ml': [(53, 80)],
    'src/util/loc.ml': [(16, 130), (254, 297)],
    'src/util/lexlib.mll': [(25, 40), (88, 143), (152, 180)],
    'src/driver/driver.ml': [(98, 139), (170, 265), (329, 408), (456, 477)],
    'src/driver/driver_lexer.mll': [(65, 145)],
    'src/driver/call_provers.ml': [(507, 552), (604, 618)],
    'src/parser/lexer.mll': [(53, 74), (257, 279)],
    'src/parser/typing.ml': [(253, 261), (1745, 1770)],
    'src/parser/mlw_printer.ml': [(17, 29), (76, 83)],
    'src/gnat/gnat_util.ml': [(125, 152)],
    'src/gnat/gnat_config.ml': [(210, 240)],
    'src/util/debug.ml': [(14, 55)],
    'plugins/gnat_json/gnat_ast_to_ptree.ml': [(53, 64), (229, 257), (1223, 1241), (1283, 1300)],
    'plugins/gnat_json/ptree_constructors.ml': [(1, 24)],
}


def identity(b):
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}


def read_json(p):
    return json.loads((ROOT / p).read_text())


def archive(p):
    with tarfile.open(ROOT / p) as t:
        return {m.name: t.extractfile(m).read() for m in t if m.isfile()}


def lex(text):
    """Tokenize fixed driver/library fragments; nested comments and Lexlib strings.

    This is not a Why3 parser. Only directives whose complete fixed forms are
    retained below are interpreted. Unsupported string escapes fail closed.
    """
    out = []
    i = 0
    while i < len(text):
        if text.startswith('(*)', i):
            out.append(('word', '(*)', text.count('\n', 0, i) + 1)); i += 3
        elif text.startswith('(*', i):
            depth = 1; i += 2
            while depth:
                assert i < len(text), 'unterminated comment'
                if text.startswith('(*)', i): i += 3
                elif text.startswith('(*', i): depth += 1; i += 2
                elif text.startswith('*)', i): depth -= 1; i += 2
                else: i += 1
        elif text[i].isspace():
            i += 1
        elif text[i] == '"':
            line = text.count('\n', 0, i) + 1
            i += 1; s = ''
            while i < len(text) and text[i] != '"':
                if text[i] != '\\':
                    assert ord(text[i]) >= 32, 'literal control byte in string'
                    s += text[i]; i += 1; continue
                i += 1
                if text[i] in '\r\n':
                    m = re.match(r'\r*\n[ \t]*', text[i:]); assert m
                    i += len(m[0]); continue
                escaped = {'n': '\n', 'r': '\r', 't': '\t', 'b': '\b', '\\': '\\', '"': '"', "'": "'"}
                if text[i] in escaped: s += escaped[text[i]]; i += 1
                elif text[i:i+3].isdigit():
                    v = int(text[i:i+3]); assert 0 <= v <= 255
                    s += chr(v); i += 3
                elif text[i] == 'x': s += chr(int(text[i+1:i+3], 16)); i += 3
                elif text[i] == 'o': s += chr(int(text[i+1:i+4], 8)); i += 4
                else: raise AssertionError('unsupported escape: ' + text[i:i+10])
            assert i < len(text)
            out.append(('string', s, line)); i += 1
        else:
            # Names/operators are only delimiters for this fixed census.
            m = re.match(r"[^\s\"()]+|[()]", text[i:]); assert m
            out.append(('word', m[0], text.count('\n', 0, i) + 1)); i += len(m[0])
    return out


def forms(s):
    """Read SMT S-expression structure (including comments/quoted symbols).

    Used only for fixed prelude strings and symbolic template instantiation.
    No solver parsing, typing, evaluation, or term-size claim is made.
    """
    tokens = re.findall(r';[^\n]*|\|[^|]*\||"(?:""|[^"])*"|[()]|[^\s();]+', s)
    tokens = [t for t in tokens if not t.startswith(';')]
    stack = [[]]
    for t in tokens:
        if t == '(':
            child = []; stack[-1].append(child); stack.append(child)
        elif t == ')':
            assert len(stack) > 1, ('negative nesting', s)
            stack.pop()
        else: stack[-1].append(t)
    assert len(stack) == 1, ('unclosed form', s)
    return stack[0]


def driver_records(name, data):
    ts = lex(data.decode())
    rows = []; scope = None
    for i, (kind, val, line) in enumerate(ts):
        if kind != 'word': continue
        if val == 'theory': scope = ts[i + 1][1]
        elif val == 'end': scope = None
        elif val in {'prelude', 'printer', 'filename', 'meta', 'import'}:
            assert ts[i + 1][0] == 'string'
            rows.append({'file': name, 'line': line, 'scope': scope, 'kind': val, 'value': ts[i+1][1]})
        elif val == 'syntax':
            j = i + 2
            while ts[j][0] != 'string': j += 1
            rows.append({'file': name, 'line': line, 'scope': scope,
                         'kind': 'syntax_' + ts[i+1][1], 'value': ts[j][1]})
    return rows


def all_strings(obj):
    if isinstance(obj, str): yield obj
    elif isinstance(obj, list):
        for v in obj: yield from all_strings(v)
    elif isinstance(obj, dict):
        for k, v in obj.items(): yield k; yield from all_strings(v)


def produce():
    sources = archive(WHY)
    source_ids = read_json('docs/evidence/retained-why-session-helper-source-20261019/source-identities.json')['members']
    witnesses = {}
    for path, spans in SPECS.items():
        name = 'why3/' + path; b = sources[name]
        assert identity(b) == source_ids[name]['identity']
        lines = b.decode().splitlines()
        witnesses[path] = {'identity': identity(b), 'excerpts': [
            {'first': a, 'last': z, 'text': '\n'.join(f'{i}: {lines[i-1]}' for i in range(a, z+1))}
            for a, z in spans]}

    # Source census supplements, rather than substitutes for, the accepted
    # selected transform/helper effect argument.
    location_census = []
    sensitive_census = []
    for name, b in sorted(sources.items()):
        if not name.startswith('why3/') or not name.endswith(('.ml', '.mll', '.mly')): continue
        assert identity(b) == source_ids[name]['identity']
        for line, text in enumerate(b.decode().splitlines(), 1):
            if re.search(r'Loc\.(?:user_position|set_file)|get_file_tag', text):
                location_census.append({'file': name, 'line': line, 'text': text})
            if any(s in text for s in FORBIDDEN | SYNTAX | {'meta_syntax', 'syntax_logic ', 'syntax_type ', 'syntax_literal '}):
                sensitive_census.append({'file': name, 'line': line, 'text': text})

    dm = read_json(DRIVERS)
    blobs = {WHY: sources}
    records = {}; driver_ids = {}
    for name, d in sorted(dm['corrected_private'].items()):
        if d['archive'] not in blobs: blobs[d['archive']] = archive(d['archive'])
        b = blobs[d['archive']][d['member']]
        assert identity(b) == d['identity']
        rows = driver_records(name, b)
        assert [r['value'] for r in rows if r['kind'] == 'import'] == d['imports']
        records[name] = rows; driver_ids[name] = d
    assert len(records) == 14
    attached = read_json('docs/evidence/retained-why-model-meta-control-20261020/attachment.json')
    for name, d in driver_ids.items():
        assert attached['accepted_driver_resolution'][name]['identity'] == d['identity']
        assert [x['target'] for x in attached['accepted_driver_resolution'][name]['imports']] == d['imports']
    roots = {}
    for root in dm['roots']:
        ordered = []
        def expand(name):
            for r in records[name]:
                if r['kind'] == 'import': expand(r['value'])
                else: ordered.append(r)
        expand(root)
        preludes = []
        templates = []
        for r in ordered:
            if r['kind'] == 'prelude':
                fs = forms(r['value'])
                assert all(isinstance(f, list) and f[0] in {'set-logic', 'set-info', 'define-fun'} for f in fs)
                preludes.append(dict(r, forms=fs))
            if r['kind'].startswith('syntax_'):
                s = r['value']
                assert not any(c in s for c in ';"|\r\n'), ('raw delimiter', r)
                if r['kind'] == 'syntax_literal':
                    pattern = r'%[sem]?[0-9]*[boxd]'
                    rep = '0'
                else:
                    pattern = r'%[tv]?[0-9]+'
                    rep = 'HOLE'
                holes = re.findall(pattern, s)
                shaped = re.sub(pattern, rep, s)
                assert '%' not in shaped, ('unhandled syntax', r)
                depth = 0; minimum = 0
                for c in shaped:
                    if c == '(': depth += 1
                    elif c == ')': depth -= 1
                    minimum = min(minimum, depth)
                assert minimum == 0 and depth >= 0, ('escaping template', r)
                # Two fixed Float80 templates have a +1 nesting surplus.
                # Do not repair them or claim SMT semantic well-formedness.
                templates.append(dict(r, holes=holes,
                    minimum_parenthesis_depth=minimum,
                    final_parenthesis_depth=depth,
                    symbolic_text=shaped))
        metas = sorted({r['value'] for r in ordered if r['kind'] == 'meta'})
        assert not (set(metas) & FORBIDDEN)
        global_counts = Counter(f[0] for r in preludes if r['scope'] is None for f in r['forms'])
        theory_counts = Counter(f[0] for r in preludes if r['scope'] is not None for f in r['forms'])
        roots[root] = {'printer': [r['value'] for r in ordered if r['kind'] == 'printer'],
                       'metas': metas, 'preludes': preludes, 'templates': templates,
                       'template_directives': len(templates),
                       'global_prelude_commands': dict(global_counts),
                       'theory_prelude_command_upper_bounds': dict(theory_counts)}

    # Every JSON string is inspected, so the check is independent of assumptions
    # about which field is a filename, symbol, meta name or location marker.
    fixed = []; known = read_json(META)['inputs']
    for path in (TAIL, LIB):
        if path not in blobs: blobs[path] = archive(path)
    for d in known:
        if d['kind'] not in {'native_input', 'prefix_library'}: continue
        path = TAIL if d['kind'] == 'native_input' else LIB
        b = blobs[path][d['member']]
        assert identity(b) == {k: d[k] for k in ('bytes', 'sha256')}
        if d['kind'] == 'native_input':
            ss = list(all_strings(json.loads(b)))
            assert not any('\r' in s or '\n' in s for s in ss)
            assert not any(s in FORBIDDEN | SYNTAX | {'supports_smt_get_info_unknown_reason'} for s in ss)
            row = {'decoded_string_occurrences': len(ss), 'CR_LF_string_occurrences': 0,
                   'maximum_string_bytes': max(len(s.encode()) for s in ss)}
        else:
            ts = lex(b.decode()); metas = [ts[i+1][1] for i,t in enumerate(ts) if t[0] == 'word' and t[1] == 'meta']
            assert not set(metas) & (FORBIDDEN | SYNTAX | {'supports_smt_get_info_unknown_reason'})
            # The selected library context has no explicit location directive.
            assert not re.search(r'\[##?', b.decode())
            row = {'meta_names': sorted(set(metas)), 'explicit_location_directives': 0}
        assert '\r' not in d['member'] and '\n' not in d['member']
        fixed.append({'archive': path, 'member': d['member'], 'kind': d['kind'], 'identity': identity(b), **row})

    launches = read_json('docs/evidence/retained-why-path-initial-state-20261020/prefix-attachment.json')
    for case in attached['cases']:
        matched = next(d for d in fixed if d['kind'] == 'native_input' and d['member'].startswith(case['case'] + '/'))
        assert matched['identity'] == case['input_identity']
        launch = next(x for x in launches if x['case'] == case['case'])
        assert launch['pid'] == case['pid']
        assert '--debug-why3' not in launch['argv']
        assert 'WHY3DEBUG' not in launch['environment']
        assert all('\r' not in s and '\n' not in s for s in launch['argv'])
        assert all('\r' not in s and '\n' not in s for s in launch['environment'].values())
    for group in attached['groups']:
        for entry in group['library_joins']:
            assert '\r' not in entry['plan_path'] and '\n' not in entry['plan_path']
            assert next(d for d in fixed if d['member'] == entry['accepted_member'])['identity'] == {
                k: entry[k] for k in ('bytes', 'sha256')}
    prefix_plan = json.loads(blobs['docs/evidence/retained-producer-prefix-per-check-20261018/observations.tar.gz']['plan.json'])
    prefix_paths = sorted(prefix_plan['file_identities'])
    assert all('\r' not in p and '\n' not in p for p in prefix_paths)

    # These values are exports of the accompanying semantic argument. The
    # checker verifies its finite supports; it does not prove the induction.
    result = {
        'scope': 'selected five fixed inputs / corrected three-driver family / accepted source-runtime relation',
        'why3_revision': '9390baf120ef260547dfa14f08e11c890b203d9c',
        'per_submitted_file_command_upper_bounds': {
            'check-sat': 1, 'get-info :reason-unknown': 1, 'set-option': 0,
            'get-model': 0, 'echo': 0, 'get-info :all-statistics': 0,
            'get-option': 0, 'get-proof': 0, 'get-value': 0,
            'find-synth': 0, 'find-synth-next': 0,
            'push': 0, 'pop': 0, 'reset': 0, 'reset-assertions': 0, 'minimize': 0},
        'set_info_keys': [':smt-lib-version', ':source', ':category', ':status'],
        'set_info_filename': 0,
        'reason_query_per_solver_sharpening': None,
        'counterexample_meta_absent': True, 'incremental_meta_absent': True,
        'minimize_meta_absent': True, 'force_incremental_debug_flag': False,
        'explicit_task_set_option_commands_excluded': True,
        'partial_generation_submitted': False,
        'total_declaration_command_count': None,
        'solver_automatic_option_changes_excluded': None,
        'solver_semantic_acceptance': None,
        'universal_current_silver_grammar_attachment': None,
        'q_cvc5': None, 'q_z3': None, 'q_altergo': None, 'O': None,
        'global_suffix_budget': {'save_entering_callbacks': 2, 'save_attempts': 3, 'e_upper_bound': 2},
        'native_solver_proof_runs': 0,
    }
    return {'driver-census.json': {'identities': driver_ids, 'roots': roots},
            'input-census.json': {'fixed_inputs': fixed,
                                 'attached_cases': [{'case': c['case'], 'pid': c['pid']} for c in attached['cases']],
                                 'accepted_prefix_file_identity_paths': prefix_paths,
                                 'joined_launch_argv_environment_and_library_paths_CR_LF_free': True},
            'source-witnesses.json': {'sources': witnesses, 'location_constructor_census': location_census,
                                      'sensitive_meta_syntax_reference_census': sensitive_census},
            'result.json': result}


def main():
    start = time.monotonic()
    p = argparse.ArgumentParser(); p.add_argument('--write', action='store_true'); args = p.parse_args()
    expected = {'base': '8d9cee6f09ff1e00010c9189314b230a870f52c1', 'files': {f: identity((ROOT/f).read_bytes()) for f in FILES}}
    products = produce()
    products['inputs.json'] = expected
    for name, content in products.items():
        path = HERE / name
        if args.write: path.write_text(json.dumps(content, indent=2, sort_keys=True) + '\n')
        else: assert json.loads(path.read_text()) == content, name + ' differs'
    # Focused lexer/structure negative controls: raw injection must not be
    # mistaken for one nested expression or a commented-out directive.
    assert lex('(* prelude "(echo bad)" (* nested *) *) prelude "(set-logic ALL)"')[0][1] == 'prelude'
    assert lex('prelude "abc\\\n  def"')[1][1] == 'abcdef'
    assert lex('prelude "a\\nb\\rc"')[1][1] == 'a\nb\rc'
    for bad in [') (echo bad) (', '(x)) (echo bad) (x']:
        try: forms(bad)
        except AssertionError: pass
        else: raise AssertionError('failed negative control')
    assert len(forms('(x) (echo bad)')) == 2
    print(json.dumps({'status': 'pass', 'products': len(products),
                      'elapsed_seconds': round(time.monotonic()-start, 6),
                      'native_solver_proof_runs': 0}))


if __name__ == '__main__': main()

#!/usr/bin/env python3
"""Offline identities, source census and arithmetic; never executes Z3.

The source reasoning and its remaining premises are in the research note.
This is a lexical census, not a C++ type checker or a binary-refinement proof.
"""
import argparse
import ast
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
REV = "745087e237e669d709ae35694728a0c479e572b3"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_sources():
    identity = json.loads((HERE / "identity.json").read_text())
    archive = HERE / "sources.tar.gz"
    assert digest(archive.read_bytes()) == identity["sha256"]
    assert archive.stat().st_size == identity["bytes"]
    assert identity["revision"] == REV
    assert identity["url"].endswith("/" + REV)
    prefix = "z3-" + REV + "/"
    with tarfile.open(archive) as tf:
        source = {m.name[len(prefix):]: tf.extractfile(m).read()
                  for m in tf.getmembers() if m.isfile() and m.name.startswith(prefix)}
    imported = {}
    for item in identity["imports"]:
        archive = ROOT / item["archive"]
        assert digest(archive.read_bytes()) == item["archive_sha256"]
        with tarfile.open(archive) as tf:
            data = tf.extractfile(item["member"]).read()
        assert digest(data) == item["sha256"] and len(data) == item["bytes"]
        imported[item["member"]] = data
        if item["member"].startswith("solvers/Z3Prover-z3/"):
            assert data == source[item["member"].removeprefix("solvers/Z3Prover-z3/")]
    return source, imported


# Keep string and character literals intact while blanking comments, preserving
# offsets and line numbers. The exact source has no raw-string member-update
# spellings; this scanner does not claim to preprocess arbitrary future C++.
COMMENTS = re.compile(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', re.S)
UPDATE = re.compile(r'(?:\.|->)\s*update\s*\(')


def mask_comments(text):
    def replace(match):
        value = match.group()
        return re.sub(r'[^\n]', ' ', value) if value.startswith('/') else value
    return COMMENTS.sub(replace, text)


def first_argument(text, start):
    depth = 0
    quote = None
    i = start
    while i < len(text):
        c = text[i]
        if quote:
            if c == '\\':
                i += 2
                continue
            if c == quote:
                quote = None
        elif c in "\"'":
            quote = c
        elif c in '([{':
            depth += 1
        elif c in ')]}':
            if depth == 0:
                return text[start:i].strip()
            depth -= 1
        elif c == ',' and depth == 0:
            return text[start:i].strip()
        i += 1
    raise AssertionError("unterminated member update")


def census(source):
    rows = []
    files = []
    for path, data in sorted(source.items()):
        if not path.startswith('src/') or Path(path).suffix not in {'.cpp', '.h'}:
            continue
        # API files are included. Tests are inventoried too, then separated.
        files.append({'path': path, 'bytes': len(data), 'sha256': digest(data)})
        raw = data.decode()
        masked = mask_comments(raw)
        for match in UPDATE.finditer(masked):
            line = raw.count('\n', 0, match.start()) + 1
            arg = first_argument(masked, match.end())
            literal = ast.literal_eval(arg) if re.fullmatch(r'"(?:\\.|[^"\\])*"', arg) else None
            kind = 'literal-key-candidate' if literal is not None else 'other-update'
            if path == 'src/util/statistics.cpp' and arg == 'name':
                kind = 'uint64-statistics-forwarder'
            if path == 'src/ast/euf/euf_ac_plugin.cpp' and arg in {
                    'm_superposition_stats.bare_str()', 'm_eqs_stats.bare_str()'}:
                kind = 'constructed-ac-statistics-key'
            if kind == 'other-update' and not path.startswith('src/test/'):
                # Dispositions of the exact nonliteral candidates, based on
                # their receiver declarations; not inference from argument type.
                if path.startswith('src/ast/simplifiers/') or path == 'src/qe/lite/qe_lite_tactic.cpp':
                    kind = 'nonstatistics-dependent-expression-state'
                elif path.startswith('src/tactic/') or path in {
                        'src/qe/qe_tactic.cpp', 'src/smt/tactic/unit_subsumption_tactic.cpp'}:
                    kind = 'nonstatistics-goal'
                elif path in {'src/ast/sls/sat_ddfw.h', 'src/sat/sat_local_search.cpp',
                              'src/sat/sat_solver.cpp'}:
                    kind = 'nonstatistics-moving-average'
                elif path in {'src/ast/sls/bvsls_opt_engine.cpp', 'src/ast/sls/sls_bv_engine.cpp'}:
                    kind = 'nonstatistics-bitvector-evaluator'
                elif path == 'src/smt/theory_seq.cpp':
                    kind = 'nonstatistics-sequence-solution-or-exclusion-map'
                else:
                    kind = {
                        'src/math/lp/lar_solver.cpp': 'nonstatistics-random-updater',
                        'src/math/simplex/network_flow_def.h': 'nonstatistics-network-tree',
                        'src/muz/rel/dl_compiler.cpp': 'nonstatistics-variable-occurrence-counter',
                        'src/muz/rel/dl_sparse_table.cpp': 'nonstatistics-table-indexer',
                    }[path]
            rows.append({'path': path, 'line': line, 'first_argument': arg,
                         'literal': literal, 'classification': kind,
                         'test_source': path.startswith('src/test/')})
    production = [r for r in rows if not r['test_source']]
    literal_keys = {r['literal'] for r in production if r['literal'] is not None}
    forwarding = {'num allocs', 'rlimit count'}
    ac_names = {'add', 'mul', 'ac-op'}
    constructed = {'ac ' + n + suffix for n in ac_names
                   for suffix in [' superpositions', ' equations']}
    keys = sorted(literal_keys | forwarding | constructed)
    assert all(k.isascii() for k in keys)
    assert len(literal_keys) == 509
    assert len(keys) == 517 and max(map(len, keys)) == 38
    assert Counter(r['classification'] for r in production)[
        'uint64-statistics-forwarder'] == 2
    assert Counter(r['classification'] for r in production)[
        'constructed-ac-statistics-key'] == 2
    return {'scanned_files': files, 'member_update_calls': rows,
            'production_classification_counts': dict(sorted(Counter(
                r['classification'] for r in production).items())),
            'literal_keys': sorted(literal_keys), 'forwarded_keys': sorted(forwarding),
            'ac_keys': sorted(constructed), 'key_universe': keys}


def source_checks(source, imported):
    required = {
        'src/util/statistics.cpp': ['mk_map(m_stats, m_u)', 'mk_map(m_d_stats, m_d)',
            'get_keys(m_u, keys)', 'get_keys(m_d, keys)', 'std::fixed << std::setprecision(2)',
            'str_hash_proc, str_eq_proc', 'get_uint64_stats(st, "num allocs"',
            'get_uint64_stats(st, "rlimit count"'],
        'src/ast/euf/euf_ac_plugin.cpp': ['m_name = f->get_name()',
            'std::string("ac ") + name + " superpositions"',
            'std::string("ac ") + name + " equations"'],
        'src/ast/euf/euf_arith_plugin.cpp': ['m_add(g, "add"', 'm_mul(g, "mul"'],
        'src/ast/euf/euf_specrel_plugin.cpp': ['if (!sp.is_ac(f))', 'alloc(ac_plugin, g, f)'],
        'src/ast/special_relations_decl_plugin.cpp': ['m_ac("ac-op")', 'name = m_ac;'],
        'src/shell/main.cpp': ['g_display_statistics = true', 'gparams::set("stats", "true")'],
        'src/shell/smtlib_frontend.cpp': ['signal (SIGINT, SIG_DFL)',
            'g_cmd_context->set_regular_stream("stdout")', 'raise(SIGINT)'],
        'src/smt/theory_lra.cpp': ['IF_VERBOSE(0, verbose_stream() << "repeated term\\n";)'],
        'src/util/util.h': ['get_verbosity_level() >= LVL'],
        'src/util/warning.cpp': ['g_warning_msgs   = true', '"WARNING: "'],
        'src/params/pattern_inference_params_helper.pyg': ["('warnings', BOOL, False"],
        'src/params/smt_params.h': ['m_progress_sampling_freq = 0'],
        'src/util/scoped_timer.cpp': ['if (ms == 0 || ms == UINT_MAX)'],
        'src/parsers/smt2/smt2parser.cpp': ['while (num_errors < 100)',
            'if (!sync_after_error())', 'warning_msg("%s", msg.c_str())'],
    }
    for path, snippets in required.items():
        text = source[path].decode()
        for snippet in snippets:
            assert snippet in text, (path, snippet)
    conf = json.loads(imported['installed/share/spark/config/gnatprove.conf'])
    z3 = [p for p in conf['provers'] if p['shortcut'] == 'z3']
    assert len(z3) == 1
    assert z3[0]['executable'] == 'z3'
    assert z3[0]['args'] == ['-smt2', '-st', 'smt.arith.solver=6', '%f']
    assert z3[0]['args_time'] == [] and z3[0]['args_steps'] == ['rlimit=%S']
    printer = imported['src/printer/smtv2.ml'].decode()
    assert 'if info.info_incremental then\n        print_incremental_axiom info fmt' in printer
    assert 'if info.info_cntexample then\n    fprintf fmt "@[(get-model)' in printer


def arithmetic(inventory):
    # Largest finite binary64 is exactly this integer, without float rounding.
    maximum = (2**53 - 1) * 2**971
    assert len(str(maximum)) == 309
    scalar = 1 + len(str(maximum)) + 1 + 2  # sign, integer, point, fraction
    assert scalar == 313 and len(str(2**32 - 1)) == 10
    keys = inventory['key_universe']
    rows = 2 * len(keys)  # each raw name can occur in both maps
    width = max(map(len, keys))
    bound = 3 + rows * (width + scalar + 4)
    assert bound == 367073
    # Synthetic renderer witnesses: raw-map duplication and sanitizer collisions
    # must not be mistaken for post-sanitization deduplication.
    def shape(us, ds):
        names = sorted(set(us)) + sorted(set(ds))
        max_len = max((len(n.removeprefix(':')) for n in names), default=0)
        result = '(' + '\n '.join(
            ':' + re.sub(r'[^a-zA-Z0-9_-]', '-', k.removeprefix(':'))
            + ' ' * max(0, max_len-len(k)) + ' '
            + (us[k] if k in us else ds[k]) for k in sorted(names)) + ')\n'
        assert len(result) <= 3 + len(names) * (max_len + 313 + 4)
        return len(names), len(result)
    assert shape({'a b': '1'}, {'a b': '2.00'})[0] == 2
    assert shape({'a b': '1', 'a-b': '2'}, {})[0] == 2
    assert shape({}, {}) == (0, 3)
    shape({}, {k: '-' + str(maximum) + '.00' for k in keys})
    # Outer families use source-level literals and worst-case decimal domains.
    error_constant = sum(map(len, ['(error "', 'line ', ' column ', ': ', '")\n'])) + 20
    assert error_constant == 46
    return {'literal_key_count': len(inventory['literal_keys']),
            'key_universe_count': len(keys), 'maximum_raw_key_bytes': width,
            'maximum_rows_per_render': rows,
            'binary64_fixed2_maximum_bytes': scalar,
            'statistics_render_bound_bytes': bound,
            'normal_answer_maximum_bytes': len('unknown\n'),
            'success_answer_bytes': len('success\n'),
            'positioned_error_constant_without_filename': error_constant,
            'positioned_error_envelope': '48 + filename_bytes + 2*message_bytes',
            'warning_envelope': '10 + formatted_message_bytes',
            'repeated_term_bytes_per_visit': len('repeated term\n'),
            'candidate_source_name_closure': True,
            'installed_source_correspondence_proved': False,
            'complete_output_file_q': None, 'weighted_output_O': None,
            'solver_or_target_executed': False,
            'remaining': ['input-command/meta/syntax preservation and counts',
                          'warning and direct-diagnostic occurrence/payload bounds',
                          'exception/fatal/build-option residuals',
                          'selected executable/source/configuration join']}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    source, imported = read_sources()
    source_checks(source, imported)
    inventory = census(source)
    result = arithmetic(inventory)
    for name, value in [('inventory.json', inventory), ('result.json', result)]:
        path = HERE / name
        if args.write:
            path.write_text(json.dumps(value, indent=2) + '\n')
        else:
            assert json.loads(path.read_text()) == value, name
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()

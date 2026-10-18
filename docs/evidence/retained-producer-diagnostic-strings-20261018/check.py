#!/usr/bin/env python3
"""Offline diagnostic frontier and affine arithmetic; no tool execution."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[2]


def uncomment(source):
    """Why3 nested comments, quoted strings and the special (*) token."""
    clean = []
    i = depth = 0
    quoted = False
    while i < len(source):
        if depth:
            if source[i:i+3] == '(*)':
                i += 3
            elif source[i:i+2] == '(*':
                depth += 1
                i += 2
            elif source[i:i+2] == '*)':
                depth -= 1
                i += 2
            else:
                clean.append('\n' if source[i] == '\n' else ' ')
                i += 1
        elif quoted:
            clean.append(source[i])
            if source[i] == '\\':
                clean.append(source[i+1])
                i += 2
                continue
            if source[i] == '"':
                quoted = False
            i += 1
        elif source[i:i+3] == '(*)':
            clean.append('(*)')
            i += 3
        elif source[i:i+2] == '(*':
            depth = 1
            i += 2
        else:
            quoted = source[i] == '"'
            clean.append(source[i])
            i += 1
    assert depth == 0 and not quoted
    return ''.join(clean)


def raw(r, g, a, n, o, wo, lo):
    return 15245 + 3732*r + 2145*g + 384*a + 3075*n + 3111*o + 3*wo + 6*lo


def projected(r, g, a, n, o, wo, lo):
    return 212 + 3732*r + 2601*g + 3075*n + 3087*o + 3*wo + 6*lo


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
    for row in identity['local_inputs']:
        assert hashlib.sha256((PROJECT / row['path']).read_bytes()).hexdigest() == row['sha256']

    def has(path, text):
        assert ' '.join(text.split()) in ' '.join(sources['why3/' + path].split()), path

    has('src/driver/call_provers.ml', 'let result_list = Re.Str.full_split re out in')
    has('src/driver/call_provers.ml', 'Unknown (Re.Str.replace_matched s out)')
    has('src/driver/call_provers.ml', 'Unknown (s1 ^ " + " ^ s2)')
    has('src/driver/call_provers.ml', 'print_prover_answer res1 print_prover_answer res2; analyse saved_models saved_res tl1')
    has('src/gnat/gnat_checks.ml', 'pa.Session_itp.proof_state <> None')
    has('src/gnat/gnat_checks.ml', 'List.iter (fun p -> schedule_goal_with_prover ~callback c g p) provers')
    has('src/gnat/gnat_checks.ml', 'find_best_untried_prover c.Controller_itp.controller_session g')
    has('src/util/loc.ml', 'pp_open_box fmt 0;')
    has('src/gnat/gnat_report.ml', '| None -> s in warning_list := s :: !warning_list')
    has('src/util/debug.ml', 'Sys.getenv "WHY3DEBUG"')
    has('src/gnat/gnat_main.ml', 'Sys.getenv "GNATWHY3LOG"')
    has('src/gnat/gnat_main.ml', 'let s = Buffer.contents escape_buffer in if s <> "" then Gnat_report.add_warning s;')

    closure = json.loads((PROJECT / identity['local_inputs'][0]['path']).read_text())['import_closure']
    tokens_re = re.compile(r'"(?:\\.|[^"\\])*"|[A-Za-z_][A-Za-z_0-9]*|\S', re.S)
    keywords = {'valid', 'invalid', 'unknown', 'fail', 'failure', 'timeout', 'outofmemory', 'steplimitexceeded', 'exitcode'}
    rules = []
    for name in closure:
        source = sources['installed/libexec/spark/share/why3/drivers/' + name]
        tokens = tokens_re.findall(uncomment(source))
        for i, token in enumerate(tokens):
            if token in keywords:
                assert token not in ('fail', 'failure', 'exitcode'), (name, token)
                regexp = json.loads(tokens[i+1])
                # The actual grammar expresses exit codes as (e.g.) valid 0,
                # not with a separate exitcode keyword.
                assert isinstance(regexp, str), (name, token, 'answer-valued exit code')
                replacement = json.loads(tokens[i+2]) if token == 'unknown' else None
                # Translate only the Str grouping/alternation syntax used by
                # these exact patterns; ordinary parentheses are literals.
                python_re = regexp.replace('(', r'\(').replace(')', r'\)')
                python_re = python_re.replace(r'\\(', '(').replace(r'\\)', ')').replace(r'\|', '|')
                assert re.search(python_re, '') is None
                rules.append({'file': name, 'class': token, 'regexp': regexp, 'replacement': replacement})
    unknown = [r for r in rules if r['class'] == 'unknown']
    assert [(r['file'], r['replacement']) for r in unknown] == [
        ('alt_ergo_gnatprove_smt2.drv', ''), ('cvc5.gen', '(not unknown!)'),
        ('smt-libv2.gen', '\\1'), ('smt-libv2.gen', '\\1')]
    assert [r['regexp'] for r in unknown] == [
        '^; File ".*", line [0-9]+, characters [0-9]+-[0-9]+: ?I don\'t know',
        '^(error "Can\'t get-info :reason-unknown when the last result wasn\'t unknown!")$',
        r'^\(unknown\|sat\|Fail\)$', r'^(:reason-unknown \([^)]*\))$']
    # The two capture rules copy one group once; the fixed replacement is
    # shorter than its fixed matched line. Empty replacements copy zero bytes.
    assert len('(not unknown!)') < len('(error "Can\'t get-info :reason-unknown when the last result wasn\'t unknown!")')
    fixed_payloads = ['no match found from given regexps', 'default answer',
                      'unrecognized prover answer', 'signaled', 'interrupted']
    for payload in fixed_payloads:
        assert '"' + payload + '"' in sources['why3/src/driver/call_provers.ml']
        assert len('High failure (' + payload + ')') <= 64
    fixed_warning = ('two consecutive answers returned by the prover, will ignore the first one.\n'
                     'First answer: \nSecond answer: \n')
    # Two class wrappers plus one separator allowance per participating
    # segment. The source argument bounds total payload participation by 2O.
    assert len(fixed_warning) + 2*64 + 2*3 < 512

    # Both sides are affine, so zero and basis vectors determine equality.
    for values in [[0]*7] + [[int(i == j) for i in range(7)] for j in range(7)]:
        r, g, a, n, o, wo, lo = values
        wc, lc, la = o+n, 514*o+512*n, 4*o+64*a
        assert raw(*values) == 15245+3732*r+2145*g+3*(wc+wo)+6*(la+lc+lo)
        assert projected(*values) == 212+3732*r+2601*g+3*(wc+wo)+6*(lc+lo)
    fixed = json.loads((PROJECT / identity['local_inputs'][1]['path']).read_text())['all_five_fixed_files']
    g, r = fixed['terminal_task_bound'], fixed['response_record_bound']
    a, n = 4*g, 3*g
    fixed_raw = raw(r, g, a, n, 0, 0, 0) + 4*15245
    fixed_projected = projected(r, g, a, n, 0, 0, 0) + 4*212
    assert (g, r, a, n, fixed_raw, fixed_projected) == (2981, 51, 11924, 8943, 38739343, 35444698)
    result = {'native_or_proof_executions': 0, 'selected_driver_files': len(closure),
              'answer_rules': rules, 'answer_payload_coefficient': 4,
              'answer_constant_per_entry': 64, 'consecutive_warning_payload_coefficient': 2,
              'consecutive_warning_constant_per_segment': 512,
              'raw_coefficients': {'constant_per_response': 15245, 'R': 3732, 'G': 2145, 'A': 384, 'N': 3075, 'O': 3111, 'W_o': 3, 'L_o': 6},
              'projected_coefficients': {'constant_per_response': 212, 'R': 3732, 'G': 2601, 'N': 3075, 'O': 3087, 'W_o': 3, 'L_o': 6},
              'five_fixed_responses': {'G': g, 'R': r, 'A': a, 'N': n,
                  'raw_constant_bytes': fixed_raw, 'projected_constant_bytes': fixed_projected},
              'scope': 'Source-derived string transfer, not a bound on raw solver output, remaining warnings, or complete producer capacity; no parser/scheduler execution'}
    (HERE / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ('native_or_proof_executions', 'selected_driver_files', 'five_fixed_responses')}))


if __name__ == '__main__':
    main()

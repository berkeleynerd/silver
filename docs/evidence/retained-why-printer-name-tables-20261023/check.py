"""Check frozen inputs, new arithmetic and focused synthetic failure traces."""
import json
from pathlib import Path
import re
import tarfile
import time
from freeze import identity
from transfer import BLACKLIST_CALLS, BLACKLIST_MAX_BYTES, PREMISES, bounds
from small_model import history_checks, structural_checks

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def strip_ocaml_comments(text):
    out, i, depth, quoted = [], 0, 0, False
    while i < len(text):
        pair = text[i:i+2]
        if depth:
            if pair == '(*':
                depth += 1
                i += 2
            elif pair == '*)':
                depth -= 1
                i += 2
            else:
                i += 1
        elif quoted:
            out.append(text[i])
            if text[i] == '\\':
                i += 1
                out.append(text[i])
            elif text[i] == '"':
                quoted = False
            i += 1
        elif pair == '(*':
            depth = 1
            i += 2
        else:
            quoted = text[i] == '"'
            out.append(text[i])
            i += 1
    assert not depth and not quoted
    return ''.join(out)


def checked_section(lines, first, last):
    assert type(first) is int and type(last) is int
    assert 1 <= first <= last <= len(lines)
    return ''.join(lines[first-1:last])


def range_boundary_checks():
    lines = ['first\n', 'last\n']
    assert checked_section(lines, 1, 2) == 'first\nlast\n'
    for first, last in [(0, 1), (2, 1), (1, 3), (True, 1)]:
        try:
            checked_section(lines, first, last)
        except AssertionError:
            pass
        else:
            raise AssertionError('invalid witness range accepted')
    return 4


def main():
    started = time.monotonic()
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for group in ('providers', 'archives'):
        for path, expected in inputs[group].items():
            assert identity((ROOT / path).read_bytes()) == expected, path
    source = {}
    witnesses = json.loads((HERE / 'source-witnesses.json').read_text())
    for witness in witnesses:
        with tarfile.open(ROOT / witness['archive']) as tf:
            blob = tf.extractfile(witness['member']).read()
        assert identity(blob) == witness['identity']
        text = blob.decode()
        source[witness['member']] = text
        lines = text.splitlines(keepends=True)
        for section in witness['sections']:
            assert checked_section(lines, section['start'], section['end']) == section['text']
    smt = source['why3/src/printer/smtv2.ml']
    bltext = strip_ocaml_comments(smt[smt.index('  let bls ='):smt.index('  let san =')])
    words = [json.loads(token) for token in re.findall(r'"(?:[^"\\]|\\.)*"', bltext)]
    assert len(words) == BLACKLIST_CALLS
    assert len(set(words)) == 335
    assert max(map(len, words)) == BLACKLIST_MAX_BYTES
    assert all(word.isascii() and not any(c.isspace() for c in word) for word in words)
    # Exact selected factory/client form: no second sanitizer, duplicate, reset,
    # string_unique or name-printer exposure among this module's calls.
    assert 'create_ident_printer bls ~sanitizer:san' in smt
    assert 'let san = sanitizer char_to_alpha char_to_alnumus' in smt
    assert len(re.findall(r'\bid_unique\b', smt)) == 3
    assert len(re.findall(r'\bforget_id\b', smt)) == 1
    assert not re.search(r'\b(string_unique|forget_all|duplicate_ident_printer)\b', smt)
    rows = json.loads((ROOT / 'docs/evidence/retained-why-printer-demand-20261023/result.json').read_text())
    premises = dict.fromkeys(PREMISES, True)
    cases = []
    for row in rows['cases']:
        dims = {**row['dimensions'], 'E': row['episodes_upper']}
        assert dims['E'] == 3 * row['registered_roots'] + 2
        result = bounds(dims, premises)
        assert result['conditional_integer_and_table_interface'] is not None
        assert result['conditional_name_string_operand_interface'] is None
        assert result['name_string_operand_guard'] is None
        assert bounds(dims)['conditional_integer_and_table_interface'] is None
        assert bounds(dims, {**premises, PREMISES[0]: False})['conditional_integer_and_table_interface'] is None
        assert bounds(dims, premises, L=1 << 57)['name_string_operand_guard'] is False
        assert bounds(dims, premises, L=0)['name_string_operand_guard'] is True
        assert result['candidate']['forget_id_calls_per_fresh_printer_upper'] == row['per_episode_vector']['Ident']['increments']
        cases.append({'case': row['case'], 'dimensions': dims, **result})
    report = {
        'scope': 'fresh selected SMTv2 indices/Hid tables; conditional source argument',
        'cases': cases,
        'blacklist': {'calls': len(words), 'distinct_words': len(set(words)),
                      'maximum_bytes': max(map(len, words)), 'all_space_free_ASCII': True},
        'same_global_escaping_exception_budget': 2,
        'same_global_save_entering_callbacks': 2,
        'same_global_saves_upper': 3,
        'exception_allowance_renewed_per_table': False,
        'source_argument_machine_checked': False,
        'raw_name_origin_attachment_established': False,
        'whole_printer_or_119_capacity_established': False,
    }
    (HERE / 'result.json').write_text(json.dumps(report, indent=2) + '\n')
    checks = {'provider_files': len(inputs['providers']), 'archives': len(inputs['archives']),
              'complete_source_members': len(witnesses), 'cases': len(cases),
              'strict_source_ranges_verified': sum(len(w['sections']) for w in witnesses),
              'source_range_negative_boundaries': range_boundary_checks(),
              'history_small_model': history_checks(), 'structural_small_model': structural_checks(),
              'scope': 'finite arithmetic and model regression; not source-semantic proof',
              'elapsed_seconds': time.monotonic() - started,
              'native_solver_proof_capture_predecessor_runs': 0}
    (HERE / 'check-result.json').write_text(json.dumps(checks, indent=2) + '\n')
    print(json.dumps(checks, indent=2))


if __name__ == '__main__':
    main()

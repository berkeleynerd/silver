"""Independent frozen-source/arithmetic audit; no native or predecessor replay.

The source theorem is reviewed in the companion report. These finite checks
establish identities and numerical correspondence, not an OCaml simulation.
Only files in this reviewer evidence directory are written.
"""
import hashlib
import json
from pathlib import Path
import platform
import re
import subprocess
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = Path('docs/evidence/retained-why-printer-name-tables-20261023')
MAX_INT = 2**62 - 1
MAX_ARRAY = 2**54 - 1
MAX_STRING = 2**57 - 9


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def uncomment(text):
    # OCaml comment delimiters are interpreted only outside string tokens.
    tokens = re.finditer(r'"(?:\\.|[^"\\])*"|\(\*|\*\)|.', text, re.S)
    depth, out = 0, []
    for match in tokens:
        token = match.group()
        if token == '(*':
            depth += 1
        elif token == '*)':
            assert depth > 0
            depth -= 1
        elif depth == 0:
            out.append(token)
    assert depth == 0
    return ''.join(out)


def table(writes, removes):
    # Least power of two at least 2048 with 2*capacity >= writes.
    capacity = 1 << max(11, ((writes + 1) // 2 - 1).bit_length())
    return {
        'insertion_opportunities_upper': writes,
        'remove_opportunities_upper': removes,
        'client_entry_bucket_occurrences_upper': writes,
        'abandoned_resize_published_bucket_occurrences_upper': 2 * writes,
        'scalar_size_lower': -removes,
        'scalar_size_upper': writes,
        'capacity_upper': capacity,
        'largest_bucket_or_tail_array_words': capacity,
        'largest_bucket_or_tail_array_block_bytes': 8 * (capacity + 1),
        'each_lookup_or_remove_cell_visits_upper': writes,
        'each_resize_cell_visits_upper': writes,
        'each_resize_outer_array_iterations_upper': 2 * capacity,
    }


def main():
    start = time.monotonic()
    target = sys.argv[1]
    assert re.fullmatch('[0-9a-f]{40}', target)
    inputs = json.loads((ROOT / PACKET / 'inputs.json').read_text())
    own_inputs = {}
    paths = [str(PACKET / p.name) for p in (ROOT / PACKET).iterdir()
             if p.is_file()]
    paths += ['docs/research/retained-why-printer-name-tables.md']
    paths += list(inputs['providers']) + list(inputs['archives'])
    for name in sorted(set(paths)):
        data = (ROOT / name).read_bytes()
        committed = subprocess.check_output(['git', 'show', f'{target}:{name}'], cwd=ROOT)
        assert data == committed, ('not frozen target bytes', name)
        own_inputs[name] = identity(data)
    for group in ('providers', 'archives'):
        for name, expected in inputs[group].items():
            assert own_inputs[name] == expected, name

    sources, members = {}, []
    for witness in json.loads((ROOT / PACKET / 'source-witnesses.json').read_text()):
        with tarfile.open(ROOT / witness['archive']) as archive:
            data = archive.extractfile(witness['member']).read()
        assert identity(data) == witness['identity']
        lines = data.decode().splitlines(keepends=True)
        checked = []
        for section in witness['sections']:
            first, last = section['start'], section['end']
            assert type(first) is int and type(last) is int
            assert 1 <= first <= last <= len(lines), (witness['member'], first, last, len(lines))
            assert ''.join(lines[first-1:last]) == section['text']
            checked.append([first, last])
        sources[witness['member']] = data.decode()
        members.append({'member': witness['member'], **identity(data),
                        'actual_lines': len(lines), 'checked_ranges': checked})

    smt = sources['why3/src/printer/smtv2.ml']
    ident = sources['why3/src/core/ident.ml']
    ht = sources['ocaml/stdlib/hashtbl.ml']
    blacklist = smt[smt.index('  let bls ='):smt.index('  let san =')]
    words = [json.loads(s) for s in re.findall(r'"(?:\\.|[^"\\])*"', uncomment(blacklist))]
    assert (len(words), len(set(words)), max(map(len, words))) == (343, 335, 22)
    assert all(w.isascii() and not any(c.isspace() for c in w) for w in words)
    assert len(re.findall(r'\bid_unique\b', smt)) == 3
    assert len(re.findall(r'\bforget_id\b', smt)) == 1
    assert not re.search(r'\b(?:duplicate_ident_printer|forget_all|string_unique)\b', smt)
    for text in ['let str_ls = sprintf "%a" (print_ident info) ls.ls_name',
                 'fprintf fmt "@[%a@]" (print_ident info) ls.ls_name',
                 '| V26 | V26Par ->  inspect (Option.get fs.ls_value)',
                 'info_printer = ident_printer ();']:
        assert text in smt
    for text in ['let ind = fetch (succ (Hstr.find indices name)) in',
                 'Hstr.replace indices name ind;\n    specname ind\n  with Not_found -> name in',
                 'Hstr.replace indices name 0;',
                 'let name = find_unique printer.indices name in\n    Hid.replace printer.values id name;',
                 'Hstr.remove printer.indices name;\n    Hid.remove printer.values id']:
        assert text in ident
    assert ht.index('h.size <- h.size - 1;', ht.index('module MakeSeeded')) < ht.index('h.data.(i) <- next', ht.index('module MakeSeeded'))
    assert 'then (slot.key <- key; slot.data <- data; false)' in ht
    assert 'h.data <- ndata;' in ht and 'insert_all_buckets (indexfun h) inplace odata ndata' in ht
    assert 'for i = 0 to nsize - 1 do' in ht and '| Cons tail -> tail.next <- Empty' in ht

    provider = json.loads((ROOT / 'docs/evidence/retained-why-printer-demand-20261023/result.json').read_text())
    rows = json.loads((ROOT / PACKET / 'result.json').read_text())
    assert len(provider['cases']) == len(rows['cases']) == 5
    cases = []
    for row, prior in zip(rows['cases'], provider['cases']):
        assert row['case'] == prior['case']
        d = row['dimensions']
        assert d == {**prior['dimensions'], 'E': prior['episodes_upper']}
        s, p, h, a, t, e = (d[k] for k in ('S', 'P', 'H', 'A', 'T', 'E'))
        assert e == 3 * prior['registered_roots'] + 2
        assert min(s, p, h, a, t, e) >= 1
        body, header = (2*s+p)*(t+1), 2*(a+1)*(t+2)+8
        c, f = h*(body+header), h*(2*p+3*a+2)
        n = 343+c
        assert f == prior['per_episode_vector']['Ident']['increments']
        expected = {
            'body_name_calls_per_declaration_upper': body,
            'header_name_calls_per_declaration_upper': header,
            'id_unique_calls_per_fresh_printer_upper': c,
            'forget_id_calls_per_fresh_printer_upper': f,
            'find_unique_calls_including_blacklist_per_fresh_printer_upper': n,
            'historical_ghost_strings_per_fresh_printer_upper': n,
            'all_cached_suffixes_and_reached_suffix_operands_upper': n,
            'Hstr_replace_calls_upper': 2*n, 'Hstr_find_calls_upper': n,
            'Hstr_mem_calls_upper': n*(n+1), 'specname_calls_upper': n*(n+2),
            'Hid_replace_calls_upper': c, 'Hid_find_calls_upper': c+f,
            'indices': table(n, f), 'values': table(c, f),
            'process_find_unique_calls_upper': e*n,
            'process_id_unique_calls_upper': e*c,
            'process_Hstr_replace_calls_upper': e*2*n,
            'fresh_printer_instances_upper': e, 'new_callback_allowance': 0,
            'raw_name_entry_bytes_upper': None,
            'sanitized_or_blacklist_base_bytes_upper': None,
            'candidate_name_bytes_upper': None,
        }
        assert row['candidate'] == expected
        assert row['conditional_integer_and_table_interface'] == expected
        assert row['conditional_name_string_operand_interface'] is None
        assert row['name_string_operand_guard'] is None
        cap = max(expected[k]['capacity_upper'] for k in ('indices', 'values'))
        assert max(n, f) <= MAX_INT and 2*cap <= MAX_INT and cap <= MAX_ARRAY
        assert len(row['integer_and_table_guards']) == 5 and all(row['integer_and_table_guards'].values())
        assert not any(row[k] for k in ('raw_name_origin_attachment_established',
                                       'source_argument_machine_checked', 'name_uniqueness_semantics_established',
                                       'complete_printer_capacity_established', 'whole_process_capacity_established',
                                       'aggregate_RAM_gate'))
        # Ground nullary terms have two names and no type render. Deferred
        # definition and two-constructor headers fit the existing allowance.
        assert 2 <= t+1
        assert 2+2*a+(2*a+1)*t <= header
        assert 6+2*a*(t+1) <= header
        # The optional string formula admits small L and rejects overlength L.
        def fits(length):
            return length+5 <= MAX_STRING and max(22, 5, 2*(length+5))+len(str(n)) <= MAX_STRING
        assert fits(0) and not fits(2**57)
        cases.append({'case': row['case'], 'C': c, 'F': f, 'N': n, 'E': e,
                      'indices_capacity': expected['indices']['capacity_upper'],
                      'values_capacity': expected['values']['capacity_upper']})

    assert table(4096, 0)['capacity_upper'] == 2048
    assert table(4097, 0)['capacity_upper'] == 4096
    # Independent simple counterexamples. The author exhaustive model is read,
    # not replayed by this script; no finite test substitutes for the induction.
    bindings = {'x': 5}
    assert len(bindings) == 1 and bindings['x']+1 == 6
    partial_roots = [[0, 1, 2], [1, 2]]
    assert sum(map(len, partial_roots)) == 5 > 3
    size, live = 1, 1
    size -= 1
    size -= 1
    assert size == -1 and live == 1 and not size > 4096

    result = {
        'reviewed_commit': target, 'host': platform.platform(),
        'inputs': own_inputs, 'source_members': members, 'cases': cases,
        'provider_files': len(inputs['providers']), 'archives': len(inputs['archives']),
        'complete_source_members': len(members),
        'all_witness_ranges_within_actual_source': True,
        'blacklist': {'calls': len(words), 'distinct': len(set(words)), 'maximum_bytes': max(map(len, words))},
        'numeric_rows_and_integer_array_guards': 'pass',
        'null_L_and_header_checks': 'pass',
        'finite_counterexamples': {'occupancy_one_cache_five': True,
                                  'partial_rehash_three_cells_five_occurrences': True,
                                  'negative_size_after_two_interruptions': True},
        'author_or_predecessor_checkers_run': 0,
        'native_solver_proof_capture_runs': 0,
        'source_argument_machine_checked': False,
        'elapsed_seconds': time.monotonic()-start,
    }
    (HERE / 'audit-result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('inputs', 'source_members')}, indent=2))


if __name__ == '__main__':
    main()

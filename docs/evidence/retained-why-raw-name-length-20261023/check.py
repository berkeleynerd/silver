"""Focused current-packet projection/source/byte-guard check, no prior replay."""
import json
from pathlib import Path
import tarfile
import time
from project import CASES, ROOT, HERE, EV, identity, project


def check():
    start = time.monotonic()
    manifest = json.loads((HERE / 'inputs.json').read_bytes())
    for p, expected in manifest['files'].items():
        assert identity((ROOT / p).read_bytes()) == expected, p
    for item in manifest['hyp_name_provider']:
        assert identity((HERE / item['retained_copy']).read_bytes()) == item['identity']
    witnesses = json.loads((HERE / 'source-witnesses.json').read_bytes())
    ranges = 0
    for w in witnesses:
        with tarfile.open(ROOT / w['archive']) as tf:
            blob = tf.extractfile(w['member']).read()
        assert identity(blob) == w['identity']
        lines = blob.decode().splitlines(keepends=True)
        for s in w['sections']:
            assert type(s['first']) is int and type(s['last']) is int
            assert 1 <= s['first'] <= s['last'] <= len(lines)
            assert ''.join(lines[s['first']-1:s['last']]) == s['text']
            ranges += 1
    driver_path = EV / 'retained-solver-request-bytes-20261020'
    drivers = json.loads((driver_path / 'driver-inputs.json').read_bytes())
    for name in drivers:
        text = (driver_path / 'drivers' / name).read_text()
        assert all(token not in text for token in ('introduced_lsymbol', 'introduced_prsymbol', 'range_type', 'float_type'))
    # Reuse only the accepted R64 callable arithmetic interface. Its checker,
    # freeze script, small model and native evidence are not executed.
    source = EV / 'retained-why-printer-name-tables-20261023/transfer.py'
    api = {}
    exec(compile(source.read_text(), str(source), 'exec'), api)
    old = json.loads((EV / 'retained-why-printer-name-tables-20261023/result.json').read_bytes())
    old = {r['case']: r for r in old['cases']}
    hyp = json.loads((HERE / 'hyp-name-provider-result.json').read_bytes())
    hyp = {r['case']: r['hyp_name_value_bytes_upper'] for r in hyp['cases']}
    cases = []
    for case in CASES:
        frozen = json.loads((HERE / (case + '-names.json')).read_bytes())
        assert project(case) == frozen, case
        m = frozen['initial_all_identifier_bytes_max']['bytes']
        L = max(m + 7, 8)
        assert L == frozen['L_interface']
        # One origin-grown printable symbol/variable, then at most one property
        # suffix: _proj_1/'unused + 'def. Other suffixes are no longer than10.
        assert hyp[case] == 13
        L_pr = max(m + 11, 14, hyp[case])
        row = old[case]
        r = api['bounds'](row['dimensions'], dict.fromkeys(api['PREMISES'], True), L=L)
        assert r['conditional_name_string_operand_interface'] is not None
        cand = r['candidate']
        assert cand['find_unique_calls_including_blacklist_per_fresh_printer_upper'] == row['candidate']['find_unique_calls_including_blacklist_per_fresh_printer_upper']
        assert cand['candidate_name_bytes_upper'] == max(22, 5, 2 * (L + 5)) + len(str(cand['all_cached_suffixes_and_reached_suffix_operands_upper']))
        assert api['bounds'](row['dimensions'], {}, L=L)['conditional_name_string_operand_interface'] is None
        cases.append({'case': case, 'initial_all_identifier_bytes_max': m,
                      'raw_name_L_at_printer_entry': L, 'raw_proposition_name_L_pr': L_pr,
                      'L_pr_hyp_name_input': hyp[case],
                      'raw_printer_created_projection_name_bytes_upper': L + 5,
                      'sanitized_or_blacklist_base_bytes_upper': cand['sanitized_or_blacklist_base_bytes_upper'],
                      'candidate_or_printed_unique_name_bytes_upper': cand['candidate_name_bytes_upper'],
                      'suffix_operand_upper': cand['all_cached_suffixes_and_reached_suffix_operands_upper'],
                      'name_string_operand_guard': r['name_string_operand_guard'],
                      'integer_and_table_guards': r['integer_and_table_guards'],
                      'captured_identifiers': len(frozen['identifiers']),
                      'identifier_at_attribute_count': frozen['identifier_attribute_at_prefix_count']})
    result = {'scope': 'complete selected identifier raw-name origins into R64 per-name string guards; separate proposition raw comments',
              'cases': cases, 'one_process_global_escaping_exception_budget': 2,
              'save_entering_callbacks': 2, 'saves_upper': 3, 'budget_renewed': False,
              'name_origin_argument': 'source induction under stated retained premises, pending independent review',
              'source_argument_machine_checked': False, 'full_printer_capacity': False,
              'whole_119_capacity': False, 'name_uniqueness_semantics_claimed': False,
              'aggregate_RAM_gate': False,
              'L_pr_uses_separate_hyp_name_provider': manifest['hyp_name_provider'][0]['commit']}
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    report = {'status': 'pass', 'elapsed_seconds': time.monotonic() - start,
              'frozen_provider_files': len(manifest['files']), 'complete_source_members': len(witnesses),
              'strict_source_ranges': ranges, 'cases': len(cases),
              'new_direct_name_projections_recomputed': len(cases),
              'accepted_arithmetic_API_used': 'R64 transfer.bounds only',
              'prior_checkers_models_or_native_solver_proof_capture_runs': 0,
              'scope': 'finite source/capture-byte and arithmetic checks, not proof of source induction'}
    (HERE / 'check-result.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    check()

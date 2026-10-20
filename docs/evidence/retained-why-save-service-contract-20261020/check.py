#!/usr/bin/env python3
"""Bind the conditional service/caller join; never execute the service."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
FILES = ROOT / 'docs/evidence/retained-why-save-file-capacity-20261020'
OFFSETS = ROOT / 'docs/evidence/retained-why-save-io-services-20261020'


def read(path):
    return json.loads(path.read_text())


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def derive():
    inputs = read(HERE / 'inputs.json')
    for name, expected in inputs['files'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in inputs['local_files'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    witnesses = read(HERE / 'source-witnesses.json')
    for archive in sorted({r['archive'] for r in witnesses}):
        with tarfile.open(ROOT / archive) as stream:
            cache = {}
            for row in (r for r in witnesses if r['archive'] == archive):
                member = row['member']
                if member not in cache:
                    cache[member] = stream.extractfile(member).read()
                raw = cache[member]
                assert identity(raw) == row['member_identity']
                excerpt = ''.join(raw.decode().splitlines(keepends=True)[row['first_line']-1:row['last_line']])
                assert excerpt == row['text']
    contract = read(HERE / 'contract.json')
    assert contract['status'] == 'explicit_external_service_premise'
    assert not contract['proved_for_installed_os']
    assert not contract['derived_from_POSIX_return_count_excerpt']
    assert contract['request_bytes'] == {'minimum': 1, 'maximum': 65536}
    assert contract['ordinary_success_count'] == '1 <= w <= n'
    assert not contract['complete_delivery_or_termination_guaranteed']
    file_rows = {r['case']: r for r in read(FILES / 'result.json')['cases']}
    prior = read(OFFSETS / 'result.json')
    rows = prior['cases']
    assert len(rows) == len(file_rows) == 5
    cases = []
    for row in rows:
        assert file_rows[row['case']]['pid'] == row['pid']
        assert set(row['descriptors']) == {'xml', 'shape'}
        descriptors = {}
        for name, outcomes in row['descriptors'].items():
            assert {o['initial_cached_offset'] for o in outcomes} == {-1, 0}
            extents = {o['actual_committed_bytes_max'] for o in outcomes}
            assert len(extents) == 1
            extent = extents.pop()
            assert 0 <= extent <= 2**63-1
            for outcome in outcomes:
                bias = outcome['initial_cached_offset']
                assert outcome['guard']
                assert outcome['cached_offset_min'] == bias
                assert outcome['cached_offset_max'] == extent+bias
                assert not outcome['successful_initial_lseek_required']
            descriptors[name] = {
                'offered_bytes_upper': extent,
                'cached_offset_bounds_by_bias': outcomes,
                'syscall_request_min': 1, 'syscall_request_max': 65536,
                'request_fits_retained_int_and_ssize': 65536 <= 2**31-1 < 2**63-1,
                'full_buffer_post_write_pending_max': 65536-1,
                'positive_write_premise_required': True,
            }
        cases.append({'case': row['case'], 'pid': row['pid'], 'descriptors': descriptors})
    countermodel = prior['zero_return_countermodel']
    assert countermodel['returned_write_bytes'] == 0
    assert countermodel['putch_store_index'] == countermodel['buffer_bytes']
    assert not countermodel['store_is_in_buffer']
    return {
        'scope': 'Selected private blocking regular-file XML/shape descriptions only',
        'cases': cases,
        'conditional_service_interface_attached_under_documented_relation': True,
        'positive_write_is_explicit_external_premise': True,
        'positive_write_proved_for_installed_os': False,
        'zero_return_countermodel_to_weaker_interface': countermodel,
        'unconditional_selected_file_bounds': None,
        'complete_file_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
        'native_runs': 0, 'source_fetches': 0, 'predecessor_checker_replays': 0,
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    result = derive()
    raw = (json.dumps(result, indent=2) + '\n').encode()
    if args.write:
        (HERE / 'result.json').write_bytes(raw)
    else:
        assert (HERE / 'result.json').read_bytes() == raw
    print(json.dumps({'status': 'pass', 'processes': len(result['cases']),
                      'descriptions': 10, 'initial_offset_applications': 20,
                      'source_slices': len(read(HERE / 'source-witnesses.json')),
                      'elapsed_seconds': time.monotonic()-start,
                      'external_service_proved': False, 'native_runs': 0,
                      'predecessor_checker_replays': 0}, indent=2))

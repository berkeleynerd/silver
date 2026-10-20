#!/usr/bin/env python3
"""Check the new offset transfer and retained source joins without replay."""
import hashlib
import json
from pathlib import Path
import tarfile
import time

from transfer import IO_BUFFER, MAX_OFFSET, flush_step, offset_bounds, putch_zero_return_countermodel

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def derive():
    prior = json.loads((ROOT / 'docs/evidence/retained-why-save-file-capacity-20261020/result.json').read_text())
    cases = []
    for row in prior['cases']:
        inputs = row['inputs']
        cases.append({'case': row['case'], 'pid': row['pid'], 'descriptors': {
            name: [offset_bounds(inputs[key], bias) for bias in (-1, 0)]
            for name, key in [('xml', 'xml_bytes'), ('shape', 'shape_bytes')]}})
    return {'cases': cases, 'zero_return_countermodel': putch_zero_return_countermodel(),
            'initial_lseek_success_needed_for_offset_representation': False,
            'ordinary_lseek_result_and_private_descriptor_contract_required': True,
            'positive_write_service_attachment_established': False,
            'unconditional_selected_file_bounds': None,
            'complete_save_capacity_established': False,
            'whole_pipeline_capacity_established': False}


def check():
    start = time.monotonic()
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in inputs['files'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    witnesses = json.loads((HERE / 'source-witnesses.json').read_text())
    with tarfile.open(ROOT / witnesses[0]['archive']) as tar:
        raw = tar.extractfile(witnesses[0]['member']).read()
    lines = raw.decode().splitlines(keepends=True)
    for row in witnesses:
        assert identity(raw) == row['member_identity']
        assert ''.join(lines[row['first_line']-1:row['last_line']]) == row['text']
    result = derive()
    assert result == json.loads((HERE / 'result.json').read_text())
    checks = 0
    for bias in (-1, 0):
        for pending in (1, 2, IO_BUFFER-1, IO_BUFFER):
            for committed in (0, 1, MAX_OFFSET-pending):
                for written in {1, pending//2 or 1, pending}:
                    step = flush_step(committed, pending, bias, written)
                    assert step['committed'] + step['pending'] == committed + pending
                    assert step['cached'] == step['committed'] + bias
                    assert -1 <= step['cached'] <= MAX_OFFSET
                    assert 0 <= step['pending'] < IO_BUFFER
                    checks += 1
        assert offset_bounds(MAX_OFFSET, bias)['guard']
        assert not offset_bounds(MAX_OFFSET+1, bias)['guard']
    for bad in (-1, True):
        try:
            offset_bounds(bad, 0)
        except ValueError:
            pass
        else:
            raise AssertionError('invalid extent accepted')
    assert not result['zero_return_countermodel']['store_is_in_buffer']
    assert all(bound['guard'] for row in result['cases']
               for bounds in row['descriptors'].values() for bound in bounds)
    return {'status': 'pass', 'cases': len(result['cases']),
            'descriptor_initial_outcome_checks': 4*len(result['cases']),
            'positive_write_prefix_boundary_checks': checks,
            'source_witnesses': len(witnesses),
            'elapsed_seconds': time.monotonic()-start,
            'native_runs': 0, 'predecessor_checker_replays': 0,
            'positive_write_service_attachment_established': False}


if __name__ == '__main__':
    print(json.dumps(check(), indent=2))

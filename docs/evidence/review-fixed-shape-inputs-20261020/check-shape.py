#!/usr/bin/env python3
"""Independent finite J/L aggregation, source checker and exact Git join.

No captured graph traversal, extraction, logical opening or native work occurs.
The source argument, not this arithmetic comparison, justifies the formulas.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
REL = 'docs/evidence/retained-why-session-shape-transfer-20261020'
BASE = 'b1c0d89f7b652a1c12e957caa986887be890786e'
INITIAL = '79d48aa4dfe243578d09b58ef8c5d65aa571f75f'


def check(shape_root, target):
    start = time.perf_counter()
    packet = shape_root/REL
    paths = subprocess.check_output(['git','diff','--name-only',BASE,target],cwd=ROOT).decode().splitlines()
    for path in paths:
        assert (shape_root/path).read_bytes() == subprocess.check_output(['git','show',f'{target}:{path}'],cwd=ROOT)
    atom_root = ROOT/'docs/evidence/retained-why-fixed-session-atoms-20261020'
    author = json.loads(subprocess.check_output([sys.executable,'-B',str(packet/'check.py'),
        '--atoms-root',str(atom_root)],cwd=shape_root))
    test_start = time.perf_counter()
    tests = subprocess.run([sys.executable,'-B','-m','unittest','discover','-s',str(packet),
        '-p','test_transfer.py','-v'],cwd=shape_root,text=True,capture_output=True,check=True)
    test_result = dict(passed=True,elapsed_seconds=time.perf_counter()-test_start,output=tests.stdout+tests.stderr)
    rows = json.loads((packet/'bounds.json').read_text())
    original_rows = json.loads(subprocess.check_output(['git','show',f'{INITIAL}:{REL}/bounds.json'],cwd=ROOT))
    assert len(rows) == len(original_rows)
    for original, current in zip(original_rows,rows):
        normalized = json.loads(json.dumps(current))
        assert normalized['explanation'].pop('typed_attribute_closure_established') is True
        assert normalized == original
    reports = []
    for row in rows:
        name = row['case'].replace('_','-')+'-atoms.json.gz'
        atoms = json.loads(gzip.decompress((atom_root/name).read_bytes()))
        cert = atoms['saved_occurrence_certificate']
        assert all(v['detached'] is False for v in cert['visits'])
        assert atoms['typed_graph_complete'] and atoms['numeric_components_complete']
        assert not atoms['coverage_failures'] and not atoms['unsupported_numeric_components']
        assert not atoms['pattern_pointers'] and atoms['max_case_pattern_occurrences'] == 0
        assert all(c['kind'] == 'int' for c in atoms['constants'].values())
        max_decimal = max(len(str(int(c['parts'][0]['value']))) for c in atoms['constants'].values())
        max_name = max(len(bytes.fromhex(a['name_hex'])) for a in atoms['identifiers'].values())
        task_values = {}
        for address, task in cert['tasks'].items():
            terms = sum(cert['formulas'][str(p['formula'])]['opened_term_occurrences'] for p in task['propositions'])
            binders = sum(cert['formulas'][str(p['formula'])]['opened_binder_occurrences'] for p in task['propositions'])
            suffix = terms*(terms+1)
            name_bytes = max_name+max(suffix,len(str(suffix)))
            alpha_bytes = len(str(binders))
            atom_bytes = max(name_bytes,alpha_bytes,max_decimal)
            limit = 2**57-9
            expected = dict(T=terms,Q=0,P=terms,A=binders,suffix_index_upper=suffix,
                original_name_bytes_upper=max_name,name_bytes_upper=name_bytes,alpha_bytes_upper=alpha_bytes,
                constant_bytes_upper=max_decimal,atom_bytes_upper=atom_bytes,shape_bytes_upper=terms*(1+atom_bytes),
                guards=dict(alpha_counter=binders <= 2**62-1,suffix_counter_and_successor=suffix+1 <= 2**62-1,
                    individual_name_string=name_bytes <= limit,individual_constant_string=max_decimal <= limit))
            assert expected == row['task_bounds'][address]
            task_values[address] = expected
        assert set(task_values) == set(row['task_bounds'])
        J = sum(1+len(cert['tasks'][str(v['task'])]['propositions']) for v in cert['visits'])
        L = sum(task_values[str(v['task'])]['shape_bytes_upper'] for v in cert['visits'])
        assert (row['B_imported'],row['G'],row['J'],row['L']) == (cert['B_binders'],len(cert['visits']),J,L)
        assert row['numerical_guards'] == dict(J_tagged=J <= 2**62-1,L_string=L <= 2**57-9,
            three_save_shape_buffer=3*L <= 2**57-9,
            all_task_guards=all(all(t['guards'].values()) for t in task_values.values()))
        assert all(row['numerical_guards'].values())
        explanation = row['explanation']
        assert explanation['typed_attribute_closure_established'] is True
        assert explanation['attribute_union_count'] == atoms['shape_attribute_union']['count']
        assert explanation['attribute_union_bytes'] == atoms['shape_attribute_union']['sum_bytes']
        assert all(explanation[k] is None for k in ['prefix_count','per_insertion_bytes_upper','per_save_bytes_upper'])
        assert explanation['included_in_Shape_buffer_L'] is False
        for flag in ['ordinary_signal_source_configuration_join_established','entry_shape_buffer_representation_established',
                     'shape_dictionary_consistency_established','complete_save_capacity_established',
                     'complete_identifier_counter_established','whole_pipeline_capacity_established']:
            assert row[flag] is False
        reports.append(dict(case=row['case'],B=row['B_imported'],G=row['G'],J=J,L=L,
            max_task_T=max(t['T'] for t in task_values.values()),
            max_suffix_index=max(t['suffix_index_upper'] for t in task_values.values()),explanation_prefix_count=None))
    return dict(passed=True,target=target,initial_target=INITIAL,base=BASE,git_exact_paths=paths,
        original_bounds_unchanged_except_attribute_readiness=True,author_checker=author,interface_regressions=test_result,cases=reports,
        elapsed_seconds=time.perf_counter()-start,platform=platform.platform(),
        reviewer_checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        native_runs=0,atom_extractions=0,logical_opening_runs=0,binder_replays=0,alpha_replays=0,solver_runs=0)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--shape-root',type=Path,default=ROOT)
    parser.add_argument('--target',required=True)
    args = parser.parse_args()
    print(json.dumps(check(args.shape_root,args.target),indent=2,sort_keys=True))

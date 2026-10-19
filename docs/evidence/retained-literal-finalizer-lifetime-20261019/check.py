#!/usr/bin/env python3
"""Focused finalizer identity/interface evidence, not a C++ reachability proof."""
import argparse
import hashlib
import json
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]

def read(path):
    return json.loads(path.read_text())

def main():
    start = time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    args = parser.parse_args()
    manifest = read(HERE/'inputs.json')
    checks = []
    def check(name, ok):
        if not ok:
            raise AssertionError(name)
        checks.append(name)
    for row in manifest['files']:
        root = args.gcc_root if row['root'] == 'gcc' else REPO
        raw = (root/row['path']).read_bytes()
        check('identity '+row['root']+':'+row['path'],
              len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'])
    for row in manifest['excerpts']:
        raw = (args.gcc_root/row['path']).read_bytes().split(b'\n')
        excerpt = b'\n'.join(raw[row['first']-1:row['last']]) + b'\n'
        check('excerpt '+row['path']+':'+str(row['first']),
              hashlib.sha256(excerpt).hexdigest() == row['sha256'])
    census = read(REPO/manifest['array_census'])
    actual = {t:[s for s in sites if 'vec_alloc' in s['allocator']]
              for t,sites in census['common_Ada_x86_typed_allocation_types'].items()}
    actual = {t:sites for t,sites in actual.items() if sites}
    check('unchanged retained array-site projection',actual == manifest['array_sites'])
    check('all retained array families classified', set(actual) == {
        'char','ctf_dtdef_ref','ctf_dtdef_t*','ctf_dvdef_ref','ctf_dvdef_t*',
        'gimple_omp_for_iter','ht_identifier_ptr','initial_value_pair','lambda_int',
        'location_t','rtx','tree','unsigned char','value_type','void **'})
    query=read(REPO/'docs/evidence/retained-literal-shared-query-lifetime-20261019/result.json')
    # Exact keys are checked against the accepted result, not a newly executed leaf.
    scalar=query['scalar_finalizers']
    check('accepted scalar history',scalar['historical_registrations_upper'] == 39275)
    check('accepted scalar backing',scalar['allocated_slots_upper'] == 58911)
    f=lambda z:max(4,z,2*min(15,z-1),3*(z-1)//2)
    check('scalar envelope arithmetic', f(39275)==58911)
    check('scalar request arithmetic', 8+16*f(39275)==942584)
    check('outer and depth requests', 8+4*8 == 10*4 == 40)
    check('finite vector arithmetic', 39275 <= 58911 < 2**31 and 58911*3 < 2**32 and 942584 < 2**63)
    result=dict(scope='Selected literal native finalizer vectors and context depth',
        gcc_revision=manifest['gcc_revision'],context_depth=0,depth_entries_used_upper=1,
        depth_backing_bytes=40,outer_vector_lengths=[1,1],outer_vector_capacities=[4,4],
        outer_backing_bytes_each=40,old_context_bitmap_backups=0,
        scalar_history_upper=39275,scalar_capacity_upper=58911,scalar_backing_bytes_upper=942584,
        array_registration_history=0,array_inner_capacity=0,array_inner_backing_requests=0,
        vector_destructor_loop_reachable=False,new_GGC_events=0,
        initialization_and_scalar_owners_recharged=False,
        selected_finalizer_lifetime_source_join_complete=True,independent_review_pending=True,
        total_GGC_events=None,active_page_bound=None,complete_collector_capacity=False,
        full_pipeline_capacity=False,production_admission_changed=False,aggregate_RAM_gate=False,
        checks=checks,checks_passed=len(checks),gcc_files=sum(r['root']=='gcc' for r in manifest['files']),
        repository_files=sum(r['root']=='repo' for r in manifest['files']),
        retained_array_types=len(actual),retained_array_sites=sum(map(len,actual.values())),
        elapsed_seconds=time.perf_counter()-start,native_executions=0,
        predecessor_contexts_executed=0,corpus_scans=0,prior_successful_suites_rerun=False)
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k != 'checks'},indent=2))

if __name__=='__main__':
    main()

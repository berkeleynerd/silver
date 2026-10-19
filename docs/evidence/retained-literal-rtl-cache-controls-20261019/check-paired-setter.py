#!/usr/bin/env python3
"""Focused #141 adjacent reg_attrs setter repair checks; no old suite replay."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import tempfile
import time

from derive import Context,HERE,REPO,identity,read,transfer,evaluate_source


def pair(primes,slots,occupied,deleted,present):
    """Two same-key lookups with no intervening collection or other mutation."""
    expansions=[];insertions=0
    for index in range(2):
        if 3*slots<=4*occupied:
            live=occupied-deleted
            if 2*live>slots or (8*live<slots and slots>32):
                slots=next(p for p in primes if p>=2*live)
            occupied=live;deleted=0;expansions.append(index)
        if not present:
            # Selecting a truly empty slot is the larger occupancy case.
            occupied+=1;insertions+=1;present=True
    return dict(expansions=expansions,insertions=insertions,slots=slots,
                occupied=occupied,deleted=deleted)


def main():
    start=time.monotonic();started=datetime.now(timezone.utc).isoformat()
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output',type=Path,default=HERE/'repair-check-results.json')
    args=parser.parse_args();context=Context(args.gcc_root);cases=[]

    def check(name,value):
        if not value:raise AssertionError(name)
        cases.append(name)

    result=evaluate_source((REPO/'samples/hello_world.adb').read_bytes(),context)
    check('repaired source-associated result matches retained output',result==read(HERE/'result.json'))
    for c in (1,2,40,2**20):
        r=transfer(c,3,context);g=r['reg_attrs']
        check('two descriptor calls plus two split calls at C='+str(c),
              g['original_declaration_calls_upper']==2*c and g['original_declaration_pairs_upper']==c and
              g['split_part_calls_upper']==2*c and g['insertion_capable_lookups_upper']==4*c)
        check('paired miss and backbone ceilings retained at C='+str(c),
              g['paired_declaration_new_entries_upper']==g['paired_declaration_backing_events_upper']==c and
              g['additional_new_entries_upper']==g['new_shared_GGC_backing_events_upper']==3*c and
              g['historical_insertions_upper']==39257+3*c and
              r['new_shared_GGC_backing_request_events_upper']==4*c and
              r['already_owned_direct_reg_attrs_objects_upper']==3*c)
    p=context.primes
    check('second hit expands after first miss crosses old threshold',
          pair(p,61,45,0,False)['expansions']==[1])
    check('first lookup expands and second hit does not',pair(p,61,46,0,False)['expansions']==[0])
    check('same-size compaction prevents second expansion',
          pair(p,61,50,20,False)==dict(expansions=[0],insertions=1,slots=61,occupied=31,deleted=0))
    check('shrink after weak deletions prevents second expansion',
          pair(p,127,96,95,False)==dict(expansions=[0],insertions=1,slots=7,occupied=2,deleted=0))
    states=0
    for slots in (7,13,31,61,127):
        for occupied in range(slots):
            for deleted in range(occupied+1):
                for present in (False,True):
                    if present and occupied==deleted:
                        continue
                    r=pair(p,slots,occupied,deleted,present);states+=1
                    if len(r['expansions'])>1 or r['insertions']>1:
                        raise AssertionError((slots,occupied,deleted,present,r))
    check('all finite paired table states keep at most one expansion and record',states>20000)
    manifest=read(HERE/'inputs.json')
    check('complete setter macro source pinned',any(r['root']=='gcc' and r['path']=='gcc/tree.h'
          for r in manifest['files']) and context.source_files==38)
    with tempfile.TemporaryDirectory(prefix='pair-negative-',dir=HERE) as tmp:
        root=Path(tmp)
        for row in manifest['files']:
            if row['root']=='gcc':
                f=root/row['path'];f.parent.mkdir(parents=True,exist_ok=True)
                f.symlink_to(args.gcc_root/row['path'])
        f=root/'gcc/tree.h';f.unlink()
        f.write_bytes((args.gcc_root/'gcc/tree.h').read_bytes()+b'\n/* changed macro source */\n')
        try:Context(root)
        except ValueError:cases.append('changed complete setter macro source rejected')
        else:raise AssertionError('accepted changed tree.h')
    check('global claims remain open',result['total_GGC_events'] is None and
          not result['whole_literal_pipeline_capacity_established'] and
          not result['complete_scalar_finalizer_lifetime_closed'])
    report=dict(passed=True,checks=len(cases),cases=cases,paired_table_states=states,
        started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.monotonic()-start,source_files=context.source_files,
        repository_inputs=context.repository_files,review_issue=141,original_review_target='8e4a84cfa3',
        callable_identity=identity((HERE/'derive.py').read_bytes()),
        checker_identity=identity((HERE/'check-paired-setter.py').read_bytes()),
        source_argument_identity=identity((REPO/'docs/research/retained-literal-rtl-cache-controls.md').read_bytes()),
        old_packet_suite_rerun=False,native_tool_executions=0,aggregate_executions=0,
        accepted_component_suites_rerun=0,corpus_checkers_rerun=0,
        selected_model='GPT-6 Astra',selected_effort='Extra High',runtime_confirmed_model_effort=None,
        token_cost_evidence=None,independent_review='targeted rereview pending')
    args.output.write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:report[k] for k in ('passed','checks','paired_table_states','elapsed_seconds')}))


if __name__=='__main__':
    main()

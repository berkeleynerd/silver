#!/usr/bin/env python3
"""Focused graph, capacity, ownership and exact-source checks; no native run."""
import argparse
from datetime import datetime,timezone
import itertools
import json
from pathlib import Path
import tempfile
import time

from derive import Context,HERE,REPO,I32,U32,identity,read,transfer,evaluate_source


def simulate_graph(order):
    """Independent finite closure model; source-to-node mapping is handwritten."""
    children={'XUB':(), 'PXUB':(), 'PXUA':(), 'XUP':('PXUA','PXUB'),
              'XUT':('XUB','XUA'), 'XUA':()}
    # The array alias and the original sentinel are already owned.
    ids={'XUA':1};entries={};maps={};next_id=2

    def query(node):
        nonlocal next_id
        if node in ids:
            return ids[node]
        ids[node]=next_id;next_id+=1
        for child in children[node]:
            child_id=query(child)
            entries[node]=True
            maps.setdefault(node,set()).add(child_id)
            maps[node].update(maps.get(child,set()))
        if node.startswith('P'):
            entries[node]=True
        return ids[node]

    for root in order:
        query(root)
    return len(ids)-1,len(entries),len(maps),max(map(len,maps.values()),default=0)


def main():
    start=time.monotonic();started=datetime.now(timezone.utc).isoformat()
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output',type=Path,default=HERE/'check-results.json')
    args=parser.parse_args();context=Context(args.gcc_root);cases=[]

    def check(name,value):
        if not value:raise AssertionError(name)
        cases.append(name)

    def reject(name,call):
        try:call()
        except (ValueError,TypeError):cases.append(name)
        else:raise AssertionError('accepted '+name)

    raw=(REPO/'samples/hello_world.adb').read_bytes();result=evaluate_source(raw,context)
    check('retained exact source result',result==read(HERE/'result.json'))
    check('actual source identity',result['source']==identity(raw) and
          result['source_counts']['source_sha256']==identity(raw)['sha256'])
    check('five fixed graph aliases',sum(r['alias_IDs'] for r in result['alias_graph_rows'])==5)
    check('four entry records and two map controls',
          sum(r['entry_records'] for r in result['alias_graph_rows'])==4 and
          sum(r['child_maps'] for r in result['alias_graph_rows'])==2)
    check('fixed frame is separate and childless',result['new_fixed_frame_alias_IDs_upper']==1 and
          result['new_alias_IDs_upper']==6)
    maps=result['child_maps'];aliases=result['alias_sets'];final=result['scalar_finalizers']
    check('native map layout and first retained prime',maps['allocated_slots']==127 and
          maps['each_backing_caller_bytes']==1016 and maps['each_backing_rounded_bytes']==1024 and
          maps['each_control_caller_bytes']==48 and maps['each_entry_record_caller_bytes']==16)
    check('no history or traversal resize from two children',maps['maximum_keys_per_map']==2 and
          maps['additional_backing_replacements']==maps['additional_traversal_replacements']==0 and
          maps['checks']['no_pre_hit_growth'])
    check('original occupancy and allocated capacity preserved',
          aliases['incoming_occupied_upper']==aliases['incoming_allocated_slots_upper']==414851)
    check('original four plus six new pushes use one transfer',aliases['additional_pushes']==10 and
          aliases['original_pushes_already_owned']==4 and aliases['new_GGC_backing_requests_upper']==6 and
          aliases['new_cold_sentinel_pushes']==0 and result['original_alias_pushes_added_again']==0)
    check('joined alias projection and native rounding',aliases['occupied_upper']==414861 and
          aliases['allocated_slots_upper']==1048575 and aliases['each_caller_bytes_upper']==8388608 and
          result['joined_alias_ID_projection_upper']==414860 and aliases['fits'])
    check('four records two controls two backings six vector requests are disjoint',
          result['selected_graph_direct_GGC_events_upper']==8 and
          result['new_shared_GGC_backing_events_upper']==6 and result['new_disjoint_GGC_events_upper']==14 and
          result['existing_direct_tree_RTL_objects_added_again']==0)
    check('exactly two new scalar allowance and zero array registrations',
          result['new_scalar_finalizer_registrations_upper']==maps['scalar_finalizer_registrations_upper']==2 and
          maps['array_finalizer_registrations']==0 and final['new_ordinary_backing_requests_upper']==2)
    check('separate scalar owners join once',final['joined_occupied_projection_upper']==39275 and
          final['joined_capacity_projection_upper']==58911 and final['each_ordinary_backing_bytes_upper']==942584)
    zeros=('selected_graph_type_UID_increments','selected_graph_type_hash_lookups',
           'selected_graph_integer_cache_lookups','selected_graph_identifier_insertions',
           'selected_graph_DECL_UID_increments','selected_graph_pointer_layout_requests',
           'selected_bounds_address_type_UID_increments','selected_direct_callee_pointer_type_UID_increments',
           'non_LTO_free_lang_data_type_alias_sweep_requests')
    check('local type cache hits add no constructors',all(result[k]==0 for k in zeros))
    check('original type projection unchanged',result['joined_type_UID_projection_upper']==2306)
    open_flags=('complete_alias_lifetime_closed','complete_type_lifetime_closed',
                'complete_scalar_finalizer_lifetime_closed','complete_collector_lifetime_closed',
                'complete_global_counter_lifetime_closed','whole_literal_pipeline_capacity_established',
                'production_admission_changed','aggregate_RAM_gate')
    check('local result never becomes a complete global endpoint',not any(result[k] for k in open_flags) and
          result['total_GGC_events'] is None and result['selected_graph_lifetime_closed'] and
          result['conditional_selected_graph_capacity_established'])

    all_orders=list(itertools.permutations(('XUB','PXUB','PXUA','XUP','XUT')))
    check('all 120 root orders and repeated queries stay within graph ceiling',all(
          simulate_graph(order*7)==(5,4,2,2) for order in all_orders))
    check('graph subsets do not require conservative thin-record root',
          simulate_graph(('XUP','XUB')*30)==(4,3,1,2))
    check('repeated bounds queries never materialize a child map',
          simulate_graph(('XUB',)*100)==(1,0,0,0))
    check('pointer roots are childless even when queried first',simulate_graph(('PXUB','PXUA')*50)==(2,2,0,0))
    for c,n in ((1,0),(2,3),(40,0),(1,50)):
        src=(b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin '+
             b'Silver_IO.Put ("");'*c+b'null;'*n+b'end Main;')
        value=evaluate_source(src,context)
        check('actual source binding '+str((c,n)),value['source']==identity(src) and
              value['new_disjoint_GGC_events_upper']==14 and
              value['source_input']==dict(output_calls=c,null_statements=n,distinct_output_callees=1) and
              value['joined_type_UID_projection_upper']==2295+6*c+5)
    src=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin Silver_IO.Put ("a"); Silver_IO.Put_Line ("b"); end Main;'
    check('two distinct direct callee types retain existing projection',
          evaluate_source(src,context)['joined_type_UID_projection_upper']==2295+12+10)
    check('same counts different bytes remain distinct sources',
          evaluate_source(raw.replace(b'Hello, world!',b'Other, world!'),context)['source']!=result['source'])
    reject('unsupported source rejected',lambda:evaluate_source(raw.replace(b'Put_Line',b'New_Line'),context))
    reject('noncurrent alphabet rejected',lambda:evaluate_source(raw+b'\x00',context))
    for c,n,d in ((0,0,0),(True,0,1),(1,-1,1),(1,False,1),(1,0,2),(2,0,True)):
        reject('invalid source counts '+str((c,n,d)),lambda c=c,n=n,d=d:transfer(c,n,d,context))
    limit=(U32-2295-10)//6
    check('native type projection boundary retains local graph result',
          transfer(limit,0,2,context)['conditional_selected_graph_capacity_established'] and
          not transfer(limit+1,0,2,context)['conditional_selected_graph_capacity_established'] and
          transfer(limit+1,0,2,context)['selected_graph_lifetime_closed'])

    manifest=read(HERE/'inputs.json')
    with tempfile.TemporaryDirectory(prefix='negative-',dir=HERE) as tmp:
        root=Path(tmp)
        for row in manifest['files']:
            if row['root']=='gcc':
                p=root/row['path'];p.parent.mkdir(parents=True,exist_ok=True)
                p.symlink_to(args.gcc_root/row['path'])
        p=root/'gcc/alias.cc';p.unlink()
        p.write_bytes((args.gcc_root/'gcc/alias.cc').read_bytes()+b'\n/* changed */\n')
        reject('changed complete alias source rejected before loading transfers',lambda:Context(root))
    report=dict(passed=True,checks=len(cases),cases=cases,started_utc=started,
        completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.monotonic()-start,
        source_files=context.source_files,repository_inputs=context.repository_files,
        callable_identity=identity((HERE/'derive.py').read_bytes()),checker_identity=identity((HERE/'check.py').read_bytes()),
        source_argument_identity=identity((REPO/'docs/research/retained-literal-type-alias-controls.md').read_bytes()),
        native_tool_executions=0,accepted_component_suites_rerun=0,aggregate_executions=0,
        selected_model='GPT-6 Astra',selected_effort='Extra High',runtime_confirmed_model_effort=None,
        token_cost_evidence=None,independent_review='pending')
    args.output.write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:report[k] for k in ('passed','checks','elapsed_seconds')}))


if __name__=='__main__':
    main()

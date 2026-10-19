#!/usr/bin/env python3
"""Closed completed-String alias graph and fixed-frame alias projection."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
NATIVE = E/'unbounded-programs/retained-native-expansion-20261017'
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_bytes())


class Context:
    def __init__(self,gcc_root):
        manifest=read(HERE/'inputs.json')
        roots=dict(gcc=Path(gcc_root),repository=REPO)
        for row in manifest['files']:
            require(identity((roots[row['root']]/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')},'changed type/alias input '+row['path'])
        self.source_files=sum(r['root']=='gcc' for r in manifest['files'])
        self.repository_files=sum(r['root']=='repository' for r in manifest['files'])
        self.source_counts=runpy.run_path(str(NATIVE/'derive-literal-output.py'))['source_counts']
        # Import accepted pure arithmetic only; no aggregate/component Context.
        self.shared=runpy.run_path(str(E/'retained-literal-original-shared-storage-20261018/compose.py'))
        self.primes=runpy.run_path(str(E/'retained-literal-warning-map-20261018/derive.py'))['PRIMES']
        self.original=read(E/'retained-literal-original-shared-storage-20261018/result.json')
        self.named=read(E/'retained-literal-later-shared-storage-20261018/result.json')
        self.rtl=read(E/'retained-literal-rtl-cache-controls-20261019/result.json')
        a=self.original['alias_sets']
        require(a['incoming_occupied_upper']==a['incoming_allocated_slots_upper']==414851 and
                a['additional_pushes']==4 and a['occupied_upper']==414855 and
                a['allocated_slots_upper']==1048575,'original alias ownership/capacity')
        require(self.original['scalar_finalizers']['additional_pushes']==5 and
                self.named['named_source_demands']['scalar_finalizer_registrations']==6 and
                self.rtl['additional_control_scalar_registrations_upper']==5 and
                self.rtl['new_control_direct_GGC_events']==0,'existing scalar ownership')


def transfer(c,n,d,context):
    require(type(c) is int and c>=1 and type(n) is int and n>=0 and
            type(d) is int and 1<=d<=min(2,c),'literal C N D domain')
    rows=[dict(node='XUB',alias_IDs=1,entry_records=0,child_maps=0,child_keys=0),
          dict(node='pointer to XUB',alias_IDs=1,entry_records=1,child_maps=0,child_keys=0),
          dict(node='pointer to XUA',alias_IDs=1,entry_records=1,child_maps=0,child_keys=0),
          dict(node='XUP',alias_IDs=1,entry_records=1,child_maps=1,child_keys=2),
          dict(node='XUT (conservative existing-root allowance)',alias_IDs=1,
               entry_records=1,child_maps=1,child_keys=2)]
    aliases=context.shared['gc_vector'](414851,4+6)
    aliases.update(original_pushes_already_owned=4,new_graph_pushes_upper=5,
                   new_frame_pushes_upper=1,new_GGC_backing_requests_upper=6,
                   new_cold_sentinel_pushes=0,complete_global_lifetime_closed=False)
    prime=next(p for p in context.primes if p>=64)
    maps=dict(controls_upper=2,entry_records_upper=4,maximum_keys_per_map=2,
              initial_requested_slots=64,allocated_slots=prime,
              each_control_caller_bytes=48,each_control_rounded_bytes=64,
              each_entry_record_caller_bytes=16,each_entry_record_rounded_bytes=16,
              each_backing_caller_bytes=8*prime,each_backing_rounded_bytes=1024,
              additional_backing_replacements=0,additional_traversal_replacements=0,
              scalar_finalizer_registrations_upper=2,array_finalizer_registrations=0,
              selected_graph_lifetime_closed=True,checks=dict(no_pre_hit_growth=4*2<3*prime,
              alias_keys_fit_signed=aliases['occupied_upper']-1<=I32,
              reserved_int_keys_excluded=0<aliases['occupied_upper']-1<=I32,
              backing_request_span=8*prime<=I64))
    z=39257+5+6+5+2
    cap=context.shared['heap_capacity'](z)
    finalizers=dict(incoming_prefix_history_upper=39257,original_registrations_already_owned=5,
        named_registrations_already_owned=6,RTL_control_registrations_already_owned=5,
        new_graph_registrations_upper=2,joined_occupied_projection_upper=z,
        joined_capacity_projection_upper=cap,each_ordinary_backing_bytes_upper=8+16*cap,
        new_ordinary_backing_requests_upper=2,complete_global_lifetime_closed=False,
        checks=dict(length_unsigned=z<=U32,growth_unsigned=3*(z-1)<=U32,
                    capacity_31_bits=cap<=I32,request_span=8+16*cap<=I64))
    return dict(source_input=dict(output_calls=c,null_statements=n,distinct_output_callees=d),
        alias_graph_rows=rows,alias_sets=aliases,child_maps=maps,scalar_finalizers=finalizers,
        new_type_derived_alias_IDs_upper=5,new_fixed_frame_alias_IDs_upper=1,
        new_alias_IDs_upper=6,joined_alias_ID_projection_upper=aliases['occupied_upper']-1,
        selected_graph_direct_GGC_events_upper=4+2+2,new_shared_GGC_backing_events_upper=6,
        new_disjoint_GGC_events_upper=14,new_scalar_finalizer_registrations_upper=2,
        selected_graph_type_UID_increments=0,selected_graph_type_hash_lookups=0,
        selected_graph_integer_cache_lookups=0,selected_graph_identifier_insertions=0,
        selected_graph_DECL_UID_increments=0,selected_graph_pointer_layout_requests=0,
        selected_bounds_address_type_UID_increments=0,selected_direct_callee_pointer_type_UID_increments=0,
        non_LTO_free_lang_data_type_alias_sweep_requests=0,
        joined_type_UID_projection_upper=2295+6*c+5*d,
        original_alias_pushes_added_again=0,existing_direct_tree_RTL_objects_added_again=0,
        selected_graph_lifetime_closed=True,
        conditional_selected_graph_capacity_established=aliases['fits'] and
            all(maps['checks'].values()) and all(finalizers['checks'].values()) and
            2295+6*c+5*d<=U32,
        complete_alias_lifetime_closed=False,complete_type_lifetime_closed=False,
        complete_scalar_finalizer_lifetime_closed=False,complete_collector_lifetime_closed=False,
        complete_global_counter_lifetime_closed=False,whole_literal_pipeline_capacity_established=False,
        total_GGC_events=None,production_admission_changed=False,aggregate_RAM_gate=False,
        remaining='Other later type/cache/identity writers, other direct native alias sources and remaining typed controls; array finalizers and complete collector lifetime.',
        native_tool_executions=0,accepted_component_suites_rerun=0,aggregate_executions=0)


def evaluate_source(raw,context):
    require(isinstance(raw,bytes) and all(32<=b<=126 or b in (9,10,13) for b in raw),
            'current literal alphabet')
    counts=context.source_counts(raw)
    require(counts['maximum_literal_length']<=I32,'signed String bound length')
    result=transfer(counts['output_calls'],counts['null_statements'],
                    int(counts['Put']>0)+int(counts['Put_Line']>0),context)
    result.update(source=identity(raw),source_counts=counts,
        complete_source_files_verified=context.source_files,repository_inputs_verified=context.repository_files,
        source_argument='docs/research/retained-literal-type-alias-controls.md',
        selected_configuration='Retained Linux x86-64 SysV generic O0; completed ordinary String; reviewed wide split; no LTO/offload/debug/instrumentation')
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--source',type=Path,default=REPO/'samples/hello_world.adb')
    parser.add_argument('--output',type=Path,default=HERE/'result.json')
    args=parser.parse_args();context=Context(args.gcc_root)
    result=evaluate_source(args.source.read_bytes(),context)
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps(dict(new_GGC_events=14,new_scalar_registrations=2,
                         selected_graph_fits=result['conditional_selected_graph_capacity_established'])))


if __name__=='__main__':
    main()

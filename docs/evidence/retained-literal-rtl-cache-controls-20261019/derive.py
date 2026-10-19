#!/usr/bin/env python3
"""Source-bound selected CONST_INT/reg_attrs and fixed RTL control lifetimes."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
NATIVE = E/'unbounded-programs/retained-native-expansion-20261017'
U32, I32, I64, U64 = 2**32-1, 2**31-1, 2**63-1, 2**64-1


def require(value, message):
    if not value:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


class Context:
    def __init__(self,gcc_root):
        manifest = read(HERE/'inputs.json')
        roots = dict(gcc=Path(gcc_root),repository=REPO)
        for row in manifest['files']:
            require(identity((roots[row['root']]/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')},'changed cache/control input '+row['path'])
        self.source_counts = runpy.run_path(str(NATIVE/'derive-literal-output.py'))['source_counts']
        self.primes = runpy.run_path(str(E/'retained-literal-warning-map-20261018/derive.py'))['PRIMES']
        self.prefix = read(NATIVE/'native-gcc-prefix-witness.json')
        self.setup = read(NATIVE/'native-rtl-setup.json')
        self.real = read(NATIVE/'native-real-function-start.json')
        self.frame = read(NATIVE/'native-rtl-constructors.json')
        self.source_files = sum(row['root']=='gcc' for row in manifest['files'])
        self.repository_files = sum(row['root']=='repository' for row in manifest['files'])
        prefix = self.prefix['counters']['ggc_bytes']
        require(prefix['initial']==0 and prefix['positive_events']==prefix['events']==39257 and
                prefix['negative_events']==0 and not self.prefix['counter_wrap_or_reset'],
                'fixed process-prefix historical event boundary')
        env = self.setup['source_event_envelope']
        require(env['cold_cost_constants']==120 and env['shared_hash_expansions']==121 and
                env['GGC_events_bound']==437 and env['dummy_GGC_objects']==11,
                'accepted setup cache/direct event ownership')
        require(self.real['Main_real_RTL_prepare']['GGC_events_total']==4 and
                self.real['Main_real_RTL_prepare']['temp_hash_new_GGC_events']==0 and
                self.frame['additional_disjoint_GGC_event_bounds']['frame_hash_wrappers_and_backbones']==4,
                'accepted real startup/frame ownership')


def cache_capacity(history,primes):
    require(type(history) is int and history>=0,'cache historical insertion count')
    # Every prior entry insertion required a positive GGC object event. The
    # constructor requests 37, selecting prime61. Expansion uses >=2*live.
    slots = next((p for p in primes if p>=max(61,2*history)),None)
    raw = None if slots is None else 8*slots
    rounded = None if raw is None else 1 << (raw-1).bit_length()
    checks = dict(historical_region=history<=2**30-1,prime_exists=slots is not None,
        load_products=slots is not None and max(8*history,4*history,3*slots)<=U64,
        unsigned_probe_addition=slots is not None and 2*slots-3<=U32,
        individual_request=raw is not None and raw<=I64,
        allocator_order=rounded is not None and rounded<=2**62)
    return dict(historical_insertions_upper=history,occupied_upper=history,
        allocated_slots_upper=slots,each_backing_caller_bytes_upper=raw,
        each_backing_rounded_bytes_upper=rounded,checks=checks,fits=all(checks.values()))


def transfer(c,n,context):
    require(type(c) is int and c>=1 and type(n) is int and n>=0,'literal C/N domain')
    prefix = 39257
    const = cache_capacity(prefix+120+c,context.primes)
    regs = cache_capacity(prefix+3*c,context.primes)
    const.update(incoming_prefix_history_upper=prefix,fixed_setup_new_entries_upper=120,
        operation_new_entries_upper=c,operation_insertion_capable_lookups_upper=c,
        first_setup_backing_events_already_owned=121,new_shared_GGC_backing_events_upper=c,
        total_post_prefix_backing_events_upper=121+c,
        post_prefix_non_lookup_backing_events=0,new_scalar_finalizer_registrations=0,
        source_lifetime_closed=True,conditional_capacity_established=const['fits'])
    regs.update(incoming_prefix_history_upper=prefix,original_declaration_calls_upper=c,
        split_part_calls_upper=2*c,insertion_capable_lookups_upper=3*c,
        additional_new_entries_upper=3*c,new_shared_GGC_backing_events_upper=3*c,
        post_prefix_non_lookup_backing_events=0,new_scalar_finalizer_registrations=0,
        source_lifetime_closed=True,conditional_capacity_established=regs['fits'])
    controls = [
        dict(owner='dummy RTL constant pool',controls=1,registrations=1,initial_slots=31,
             raw_wrapper_bytes=48,raw_backing_bytes=248,insertions=0,non_lookup_replacements=0,
             prior_direct_owner='11 dummy objects inside first-RTL437'),
        dict(owner='rooted temporary-address table',controls=1,registrations=1,initial_slots=61,
             raw_wrapper_bytes=48,raw_backing_bytes=488,insertions=0,non_lookup_replacements=0,
             prior_direct_owner='11 dummy objects inside first-RTL437'),
        dict(owner='real Main RTL constant pool',controls=1,registrations=1,initial_slots=31,
             raw_wrapper_bytes=48,raw_backing_bytes=248,insertions=0,non_lookup_replacements=0,
             prior_direct_owner='4 real Main RTL preparation objects'),
        dict(owner='prologue/epilogue recording tables',controls=2,registrations=2,initial_slots=31,
             raw_wrapper_bytes=48,raw_backing_bytes=248,insertions=4,non_lookup_replacements=0,
             prior_direct_owner='4 frame wrappers/backbones in existing constructor envelope')]
    return dict(source_input=dict(output_calls=c,null_statements=n),CONST_INT=const,reg_attrs=regs,
        control_rows=controls,additional_control_scalar_registrations_upper=5,
        new_control_direct_GGC_events=0,new_control_hash_replacement_events=0,
        selected_recorded_loop_exit_controls=0,selected_DF_GGC_controls=0,
        selected_fixed_RTL_control_lifetimes_closed=True,
        new_shared_GGC_backing_request_events_upper=4*c,
        additional_scalar_finalizer_ordinary_backing_requests_upper=5,
        already_owned_direct_CONST_INT_objects_upper=120+c,
        already_owned_direct_reg_attrs_objects_upper=3*c,
        already_owned_first_setup_backing_events=121,
        original_five_registrations_added_again=0,named_six_registrations_added_again=0,
        conditional_cache_capacity_established=const['fits'] and regs['fits'],
        complete_scalar_finalizer_lifetime_closed=False,
        complete_type_alias_lifetime_closed=False,complete_global_counter_lifetime_closed=False,
        complete_collector_lifetime_closed=False,whole_literal_pipeline_capacity_established=False,
        total_GGC_events=None,production_admission_changed=False,aggregate_RAM_gate=False,
        exact_next_family='Reachable type/alias construction: canonical pointer/reference builders, alias_sets pushes/entries and alias child hash controls at alias.cc:1219; then finish scalar registration endpoint.',
        native_tool_executions=0,accepted_component_suites_rerun=0,aggregate_executions=0)


def evaluate_source(raw,context):
    require(isinstance(raw,bytes) and all(32<=b<=126 or b in (9,10,13) for b in raw),
            'current literal source alphabet')
    counts = context.source_counts(raw)
    require(counts['maximum_literal_length']<=I32,'signed String bound length')
    result = transfer(counts['output_calls'],counts['null_statements'],context)
    result.update(source=identity(raw),source_counts=counts,
        complete_source_files_verified=context.source_files,repository_inputs_verified=context.repository_files,
        source_argument='docs/research/retained-literal-rtl-cache-controls.md',
        selected_configuration='Retained Linux x86-64 SysV generic O0, fsplit-wide-types as reviewed; no target/function-option changes, debug, instrumentation, plugin, PCH or LTO')
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--source',type=Path,default=REPO/'samples/hello_world.adb')
    parser.add_argument('--output',type=Path,default=HERE/'result.json')
    args=parser.parse_args();context=Context(args.gcc_root)
    result=evaluate_source(args.source.read_bytes(),context)
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps(dict(new_shared_GGC_events=result['new_shared_GGC_backing_request_events_upper'],
        control_registrations=5,cache_capacity_fits=result['conditional_cache_capacity_established'])))


if __name__=='__main__':
    main()

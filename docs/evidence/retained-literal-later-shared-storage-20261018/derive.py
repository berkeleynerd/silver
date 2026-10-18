#!/usr/bin/env python3
"""Named later shared consumers; remaining lifetime inputs are never zeroed."""
import argparse
import ast
import hashlib
import json
from pathlib import Path
import runpy
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1
RESIDUALS = ('identifier_insertions', 'DECL_UID_increments', 'type_UID_increments',
             'scalar_finalizer_registrations')


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(Path(path).read_bytes())


def function_identity(path, name):
    node = next(n for n in ast.parse(Path(path).read_bytes()).body
                if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef)) and n.name == name)
    return identity(ast.dump(node, include_attributes=False).encode())


class Context:
    def __init__(self, gcc_root):
        manifest = read(HERE/'inputs.json')
        roots = dict(gcc=Path(gcc_root), repository=REPO)
        for row in manifest['files']:
            require(identity((roots[row['root']]/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes', 'sha256')}, 'changed later-shared input '+row['path'])
        # Reuse only these accepted pure constructors. Never instantiate the
        # aggregate Context, evaluate an aggregate, or replay a component suite.
        core_path = E/'retained-literal-pipeline-20261018/compose.py'
        core_tree = ast.parse(core_path.read_bytes())
        functions = {node.name:node for node in core_tree.body if isinstance(node,ast.FunctionDef)}
        for name, expected in manifest['accepted_function_ASTs'].items():
            require(function_identity(core_path, name) == expected, 'changed accepted function '+name)
        widths = next(node for node in core_tree.body if isinstance(node,ast.Assign) and
            any(isinstance(target,ast.Tuple) and
                [item.id for item in target.elts if isinstance(item,ast.Name)] == ['I32','I64']
                for target in node.targets))
        require(identity(ast.dump(widths,include_attributes=False).encode()) ==
                manifest['accepted_native_width_assignment_AST'], 'changed accepted native widths')
        selected = ast.Module(body=[widths]+[functions[name] for name in
            manifest['accepted_function_ASTs']],type_ignores=[])
        self.core = {}
        exec(compile(selected,str(core_path),'exec'),self.core)
        require(self.core['I32'] == I32 and self.core['I64'] == I64, 'accepted native widths')
        self.shared_code = runpy.run_path(str(E/'retained-literal-original-shared-storage-20261018/compose.py'))
        self.location = runpy.run_path(str(E/'retained-literal-location-lifetime-20261018/derive.py'))
        self.recognizer = runpy.run_path(str(E/'unbounded-programs/retained-native-expansion-20261017/derive-literal-output.py'))['source_counts']
        self.primes = runpy.run_path(str(E/'retained-literal-warning-map-20261018/derive.py'))['PRIMES']
        self.leaf_context = SimpleNamespace(primes=self.primes, pool_seed=39257,
            cold_string=read(E/'retained-literal-string-layout-20261018/interface.json'))
        self.default_shared = read(E/'retained-literal-original-shared-storage-20261018/result.json')
        self.default_correction = read(E/'retained-literal-location-lifetime-20261018/shared-identifier-correction.json')
        self.source_files = sum(r['root']=='gcc' for r in manifest['files'])
        self.repository_files = sum(r['root']=='repository' for r in manifest['files'])


def identifier_transfer(incoming, additions, code):
    require(type(additions) is int and additions >= 0, 'identifier insertion demand')
    history = incoming['historical_insertions_upper']+additions
    slots = max(incoming['allocated_slots_upper'], code['identifier_slots'](history))
    checks = dict(historical_insertions_unsigned=4*history <= U32,
        slot_threshold_unsigned=3*slots <= U32, doubling_unsigned=slots <= U32,
        individual_request=8*slots <= I64)
    return dict(incoming_historical_insertions_upper=incoming['historical_insertions_upper'],
        incoming_allocated_slots_upper=incoming['allocated_slots_upper'],
        additional_ordinary_backing_requests_upper=additions,
        historical_insertions_upper=history, occupied_upper=history,
        allocated_slots_upper=slots, each_ordinary_backing_bytes_upper=8*slots,
        checks=checks, fits=all(checks.values()))


def finalizer_transfer(incoming, additions, code):
    require(type(additions) is int and additions >= 0, 'scalar finalizer demand')
    history = incoming['occupied_upper']+additions
    slots = max(incoming['allocated_slots_upper'], code['heap_capacity'](history))
    checks = dict(length_unsigned=history <= U32, growth_unsigned=3*max(0,history-1) <= U32,
        capacity_31_bits=slots <= I32, request_span=8+16*slots <= I64)
    return dict(incoming_occupied_upper=incoming['occupied_upper'],
        incoming_allocated_slots_upper=incoming['allocated_slots_upper'],
        additional_ordinary_backing_requests_upper=additions,
        occupied_upper=history, allocated_slots_upper=slots,
        each_ordinary_backing_bytes_upper=8+16*slots, checks=checks, fits=all(checks.values()))


def rtl_hash_transfer(incoming_history, incoming_slots, lookup_calls, new_entries, primes):
    """Conditional lookup-driven C++ weak-cache growth subtotal.

    Pre-hit expansion and post-GC reinsertion are charged by lookup calls.
    This function supplies no source multiplicity or complete incoming seed.
    Constructors, empty(), resizing traverse() and explicit resize sites need
    separate source ownership; this is not a complete cache-lifetime bound.
    """
    for value in (incoming_history, incoming_slots, lookup_calls, new_entries):
        require(type(value) is int and value >= 0, 'RTL hash counters')
    require(incoming_slots >= 1 and new_entries <= lookup_calls, 'RTL hash demand/state')
    history = incoming_history+new_entries
    prime = next((p for p in primes if p >= max(incoming_slots, 2*history)), None)
    checks = dict(occupied_region=history <= 2**30-1, prime_exists=prime is not None,
        load_products=prime is not None and max(8*history,4*history,3*prime) <= 2**64-1,
        probe_unsigned=prime is not None and 2*prime-3 <= U32,
        request_span=prime is not None and 8*prime <= I64,
        allocator_order=prime is not None and (1 << (8*prime-1).bit_length()) <= 2**62)
    return dict(incoming_history_upper=incoming_history, incoming_slots_upper=incoming_slots,
        insertion_capable_lookup_calls_upper=lookup_calls, new_entries_upper=new_entries,
        outgoing_history_upper=history, outgoing_slots_upper=prime,
        additional_GGC_backing_requests_upper=lookup_calls,
        each_backing_caller_bytes_upper=None if prime is None else 8*prime,
        direct_entry_objects_added_again=0, checks=checks, fits=all(checks.values()),
        source_multiplicity_supplied_by_this_transfer=False,
        non_lookup_backing_requests_upper=None,complete_cache_lifetime_closed=False)


def evaluate_source(raw, shared, correction, context, residuals=None):
    require(isinstance(raw, bytes) and all(32 <= b <= 126 or b in (9,10,13) for b in raw),
            'current literal source alphabet')
    counts = context.recognizer(raw)
    require(counts['maximum_literal_length'] <= I32, 'literal length premise')
    source = identity(raw)
    require(shared['source'] == source and shared['source_counts'] == counts,
            'same actual source and recognized original-shared counts required')
    expected_correction = context.location['corrected_shared_identifier_projection'](shared, source, counts)
    require(correction == expected_correction, 'exact source-bound indexed identifier correction required')
    c, n = counts['output_calls'], counts['null_statements']
    d = int(counts['Put']>0)+int(counts['Put_Line']>0)
    old_counters, old_finalizers = shared['counter_endpoints'], shared['scalar_finalizers']
    require(shared['source_bound_demands']['identifier_new_entries'] == c+4*d+31 and
            old_counters['next_DECL_UID_upper'] == 5867+2*c+n+3*d and
            old_counters['next_type_UID_upper'] == 2295+6*c+5*d and
            old_finalizers['incoming_occupied_upper'] == 39257 and
            old_finalizers['additional_pushes'] == 5 and old_finalizers['occupied_upper'] == 39262 and
            old_finalizers['allocated_slots_upper'] == 58891,
            'exact original identity/finalizer ownership boundary')
    core, ac = context.core, context.leaf_context
    ssa = core['native_initial_ssa_lifetime'](c,n,ac)
    cf = core['native_initial_cf_cfg_lifetime'](c,n,ac)
    helpers = core['native_gimplifier_selected_helpers'](c,n)
    pool = core['native_pool_lifetime'](c,ac)
    graph = core['native_graph_lifetime'](c,n,ac)
    require(ssa['additional_DECL_UID_events_upper'] == ssa['additional_identifier_misses_upper'] == 1 and
            ssa['additional_singleton_finalizer_registrations_upper'] == 1 and
            cf['additional_DECL_UID_events_upper'] == 1 and
            cf['direct_gimplifier_interface']['additional_DECL_UID_events_upper'] == c and
            cf['direct_gimplifier_interface']['temporary_identifier_misses'] == 0 and
            cf['additional_singleton_finalizer_registrations_upper'] == 0 and
            helpers['selected_site_additional_DECL_UID_events'] == helpers['selected_site_additional_TYPE_UID_events'] == 0 and
            pool['source_input']['pool_entries_upper'] == 2*c and
            pool['excluded_already_charged_direct_pool_GGC_events'] == 10*c and
            pool['additional_singleton_finalizer_registrations_upper'] == 1 and
            graph['additional_singleton_finalizer_registrations_upper'] == 5,
            'accepted named consumer ownership join')
    demands = dict(identifier_insertions=2*c+1, DECL_UID_increments=3*c+2,
                   type_UID_increments=0, scalar_finalizer_registrations=6)
    # These are projections over the named owners only, not endpoints of an
    # interval in which all unjoined consumers have silently been disabled.
    named_identifiers = identifier_transfer(correction['identifier_hash'], demands['identifier_insertions'], context.shared_code)
    named_finalizers = finalizer_transfer(old_finalizers, demands['scalar_finalizer_registrations'], context.shared_code)
    projected_decl = old_counters['next_DECL_UID_upper']+demands['DECL_UID_increments']
    projected_type = old_counters['next_type_UID_upper']
    residuals = {} if residuals is None else dict(residuals)
    require(set(residuals) <= set(RESIDUALS), 'unknown later residual input')
    for value in residuals.values():
        require(value is None or (type(value) is int and value >= 0), 'nonnegative explicit residual ceiling')
    residuals = {name:residuals.get(name) for name in RESIDUALS}
    full = dict(identifier_hash=None, scalar_finalizers=None, next_DECL_UID_upper=None,
                next_type_UID_upper=None, temporary_name_serial_upper=None, checks={})
    if residuals['identifier_insertions'] is not None:
        full['identifier_hash'] = identifier_transfer(correction['identifier_hash'],
            demands['identifier_insertions']+residuals['identifier_insertions'], context.shared_code)
        full['temporary_name_serial_upper'] = full['identifier_hash']['historical_insertions_upper']
        full['checks']['identifier_hash'] = full['identifier_hash']['fits']
        full['checks']['temporary_name_serial_unsigned'] = full['temporary_name_serial_upper'] <= U32
    if residuals['scalar_finalizer_registrations'] is not None:
        full['scalar_finalizers'] = finalizer_transfer(old_finalizers,
            demands['scalar_finalizer_registrations']+residuals['scalar_finalizer_registrations'], context.shared_code)
        full['checks']['scalar_finalizers'] = full['scalar_finalizers']['fits']
    for key, endpoint, limit in (('DECL_UID_increments','next_DECL_UID_upper',I32),
                                 ('type_UID_increments','next_type_UID_upper',U32)):
        if residuals[key] is not None:
            full[endpoint] = old_counters[endpoint]+demands[key]+residuals[key]
            full['checks'][key] = full[endpoint] <= limit
    unresolved = [k for k,v in residuals.items() if v is None]
    return dict(scope='Disjoint named Main gimplifier/CF/SSA/pool/graph shared demands after finalize_size_functions',
        source=source, source_counts=counts,
        incoming_original_shared_source=shared['source'], incoming_corrected_identifier_state=correction['identifier_hash'],
        incoming_original_counters=old_counters, incoming_scalar_finalizers=old_finalizers,
        named_source_demands=demands,
        consumer_rows=[
            dict(owner='Main direct gimplifier',identifiers=0,DECL_UID=c,type_UID=0,scalar_finalizers=0),
            dict(owner='CF return label',identifiers=0,DECL_UID=1,type_UID=0,scalar_finalizers=0),
            dict(owner='initial SSA .MEM and default-def control',identifiers=1,DECL_UID=1,type_UID=0,scalar_finalizers=1),
            dict(owner='direct String/bounds pool objects',identifiers=2*c,DECL_UID=2*c,type_UID=0,scalar_finalizers=0),
            dict(owner='graph call-site and value-range controls',identifiers=0,DECL_UID=0,type_UID=0,scalar_finalizers=5)],
        named_only_projection=dict(identifier_hash=named_identifiers, scalar_finalizers=named_finalizers,
            next_DECL_UID_upper=projected_decl,next_type_UID_upper=projected_type,
            temporary_name_serial_upper=named_identifiers['historical_insertions_upper'],
            checks=dict(identifier=named_identifiers['fits'],scalar_finalizers=named_finalizers['fits'],
                        DECL_UID=projected_decl <= I32,type_UID=projected_type <= U32),
            valid_as_complete_lifetime_endpoint=False,
            byte_bounds_exclude_interleaved_unjoined_consumers=True),
        explicit_residual_ceilings=residuals, unresolved_endpoint_inputs=unresolved,
        conditional_full_endpoint=full,
        conditional_full_arithmetic_fits=None if unresolved else all(full['checks'].values()),
        supplied_residual_source_bounds_established=False,
        ownership=dict(new_direct_GGC_objects_added=0,new_named_shared_GGC_backing_events=0,
            additional_identifier_ordinary_backing_requests_upper=2*c+1,
            additional_named_scalar_finalizer_ordinary_backing_requests_upper=6,
            original_warning_and_assembler_name_controls_added_again=0,
            original_five_scalar_registrations_added_again=0,
            original_dummy_identifier_and_DECL_UID_added_again=0,
            original_synthetic173_function_structures_added_again=0,
            Main_struct_function_five_direct_requests_added_again=0,
            already_owned_direct_pool_GGC_events=10*c,
            graph_pool_and_SSA_direct_request_subtotals_added_again=0),
        remaining_shared_families=read(HERE/'remaining-families.json'),
        named_consumer_demand_join_closed=True,
        complete_later_shared_storage_closed=False,complete_global_counter_lifetime_closed=False,
        complete_collector_lifetime_closed=False,complete_gimplifier_lifetime_closed=False,
        whole_literal_pipeline_capacity_established=False,total_GGC_events=None,
        production_admission_changed=False,aggregate_RAM_gate=False,native_tool_executions=0,
        accepted_component_suites_rerun=0,aggregate_Context_instantiations=0,
        complete_source_files_verified=context.source_files,repository_inputs_verified=context.repository_files)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--source',type=Path,default=REPO/'samples/hello_world.adb')
    parser.add_argument('--shared-input',type=Path)
    parser.add_argument('--corrected-input',type=Path)
    parser.add_argument('--residuals',type=Path)
    parser.add_argument('--output',type=Path,default=HERE/'result.json')
    args = parser.parse_args()
    context = Context(args.gcc_root)
    result = evaluate_source(args.source.read_bytes(),
        context.default_shared if args.shared_input is None else read(args.shared_input),
        context.default_correction if args.corrected_input is None else read(args.corrected_input),context,
        None if args.residuals is None else read(args.residuals))
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps(dict(named_demands=result['named_source_demands'],
        unresolved_endpoint_inputs=result['unresolved_endpoint_inputs'],native_tool_executions=0)))


if __name__ == '__main__':
    main()

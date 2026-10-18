#!/usr/bin/env python3
"""Selected literal combined-location and dependent warning storage interface."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32, U32, I64, U64 = 2**31-1, 2**32-1, 2**63-1, 2**64-1
REGION = 2**30-1


def require(condition, message):
    if not condition:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def power2(n):
    return 1 << max(0, (n-1).bit_length())


class Context:
    def __init__(self, gcc_root, ada_root):
        manifest = json.loads((HERE/'inputs.json').read_bytes())
        roots = dict(gcc=Path(gcc_root), ada=Path(ada_root), repository=REPO)
        for row in manifest['files']:
            raw = (roots[row['root']]/row['path']).read_bytes()
            require(identity(raw) == {k:row[k] for k in ('bytes', 'sha256')},
                    'changed location input: '+row['path'])
        self.manifest = manifest
        self.roots = roots
        prior = REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017'
        self.recognizer = runpy.run_path(str(prior/'derive-literal-output.py'))['source_counts']
        warning = runpy.run_path(str(REPO/'docs/evidence/retained-literal-warning-map-20261018/derive.py'))
        self.warning = warning['evaluate']
        self.primes = warning['PRIMES']
        self.residual = json.loads((REPO/'docs/evidence/retained-literal-warning-residual-bound-20261018/interface.json').read_bytes())
        self.shared = json.loads((REPO/'docs/evidence/retained-literal-original-shared-storage-20261018/result.json').read_bytes())
        prefix = json.loads((prior/'native-gcc-prefix-witness.json').read_bytes())
        require(prefix['counters']['ggc_bytes']['positive_events'] == 39257 and
                not prefix['counter_wrap_or_reset'], 'changed shared identifier fixed prefix seed')
        indexed = json.loads((prior/'native-indexed-source-buffers.json').read_bytes())
        require(indexed['additional_Source_File_records'] == 1 and
                indexed['additional_nonnull_System_loads_upper_bound'] == 1 and
                indexed['additional_null_System_loads'] == 0 and
                indexed['native_runtime_inventory']['file_count'] == 1575 and
                indexed['prior_generic_one_buffer_per_request_name_premise_repaired_for_this_native_class'],
                'changed indexed System multiplicity correction')
        self.synthetic = json.loads((REPO/'docs/evidence/retained-literal-synthetic-function-storage-20261018/interface.json').read_bytes())
        require(self.residual['R_put_call_ceiling'] == 5 and
                self.residual['helper_initial_warning_map_puts'] == 0 and
                self.residual['selected_generated_FUNCTION_DECL_body_frontier_closed'] and
                self.residual['empty_elaboration']['initial_gimplifications'] == 0 and
                self.residual['cold_string_size_helpers']['ordinary_lowering_executions'] == 0 and
                self.residual['cold_string_size_helpers']['RTL_expansions'] == 0,
                'changed original/helper frontier')
        filename = self.shared['filename_ingress']
        require(filename['source_file_entries_upper'] == 1588 and
                filename['identifier_lookups_upper'] == 1589 and
                filename['direct_identifier_and_character_requests_upper'] == 3178 and
                filename['direct_requests_not_added_to_shared_backing_events'],
                'changed filename ownership')
        require(self.synthetic['function_structure_calls'] == 3 and
                self.synthetic['initial_helper_gimplifications'] == 2,
                'changed synthetic function frontier')
        # The C and C++ hash sequences are different implementations. Check
        # the source sequence rather than assuming their tables agree.
        htab = (roots['gcc']/'libiberty/hashtab.c').read_text()
        values = re.findall(r'^\s*\{\s*(\d+|0x[0-9a-f]+),', htab, re.M)
        require(tuple(int(x, 0) for x in values) == self.primes, 'C htab prime sequence')
        self.source_inputs_verified = sum(r['root'] != 'repository' for r in manifest['files'])
        self.repository_inputs_verified = sum(r['root'] == 'repository' for r in manifest['files'])


def corrected_shared_identifier_projection(shared, expected_source, expected_counts):
    """Project the +1 indexed filename correction onto a source-bound old leaf.

    Callers supply the already recognized source identity/counts. This does
    not evaluate an aggregate or reuse Hello demands for a different source.
    The accepted predecessor remains intact; only dependent fields are exported.
    """
    require(shared['source'] == expected_source and
            shared['source_counts'] == expected_counts and
            expected_counts['source_bytes'] == expected_source['bytes'] and
            expected_counts['source_sha256'] == expected_source['sha256'],
            'exact shared projection source identity/counts required')
    filename, old, counters = (shared[k] for k in
                              ('filename_ingress', 'identifier_hash', 'counter_endpoints'))
    additions = shared['source_bound_demands']['identifier_new_entries']
    require(type(additions) is int and additions >= 0, 'shared identifier additions')
    require(filename['source_file_entries_upper'] == 1588 and
            filename['identifier_lookups_upper'] == 1589 and
            filename['direct_identifier_and_character_requests_upper'] == 3178 and
            filename['direct_requests_not_added_to_shared_backing_events'],
            'exact old filename ingress required')
    slots_for = lambda history: max(16384, power2(4*history//3+1))
    checks_for = lambda history, slots: dict(historical_insertions_unsigned=4*history <= U32,
        slot_threshold_unsigned=3*slots <= U32, doubling_unsigned=slots <= U32,
        individual_request=8*slots <= I64)
    old_incoming, old_history = 39257+1589, 39257+1589+additions
    old_slots = slots_for(old_history)
    expected = dict(incoming_historical_insertions_upper=old_incoming,
        incoming_occupied_upper=old_incoming,
        incoming_allocated_slots_upper=slots_for(old_incoming),
        historical_insertions_upper=old_history, occupied_upper=old_history,
        allocated_slots_upper=old_slots, each_ordinary_backing_bytes_upper=8*old_slots,
        variable_ingress_backing_requests_upper=1589,
        post_prefix_backing_requests_upper=additions,
        checks=checks_for(old_history, old_slots),
        fits=all(checks_for(old_history, old_slots).values()))
    require(old == expected and
            counters['incoming_temporary_name_serial_upper'] == old_incoming and
            counters['next_temporary_name_serial_upper'] == old_history and
            counters['checks']['temporary_name_serial_unsigned'] == (old_history <= U32),
            'exact old shared identifier and serial boundary required')
    incoming, history = old_incoming+1, old_history+1
    slots = slots_for(history)
    checks = checks_for(history, slots)
    corrected = dict(incoming_historical_insertions_upper=incoming,
        incoming_occupied_upper=incoming, incoming_allocated_slots_upper=slots_for(incoming),
        historical_insertions_upper=history, occupied_upper=history,
        allocated_slots_upper=slots, each_ordinary_backing_bytes_upper=8*slots,
        variable_ingress_backing_requests_upper=1590,
        post_prefix_backing_requests_upper=additions, checks=checks, fits=all(checks.values()))
    serial_checks = dict(incoming_temporary_name_serial_unsigned=incoming <= U32,
                         temporary_name_serial_unsigned=history <= U32)
    return dict(scope='Source-bound indexed System filename correction to accepted original shared identifier fields',
        source=expected_source, source_counts=expected_counts,
        predecessor_identifier_hash=old, indexed_Source_File_delta=1,
        filename_lookups_upper=1590, direct_filename_GGC_requests_upper=3180,
        identifier_hash=corrected,
        temporary_name_serial=dict(incoming_upper=incoming, next_upper=history,
                                  checks=serial_checks, fits=all(serial_checks.values())),
        original_shared_GGC_backing_delta_unchanged=shared['additional_shared_GGC_backing_request_events_upper'],
        extra_shared_GGC_backing_events=0, extra_ordinary_identifier_ingress_requests_upper=1,
        original_shared_packet_modified=False, aggregate_attachment_complete=False,
        complete_global_counter_lifetime_closed=False, native_tool_executions=0)


def derive(c, n, predecessor, primes, path_bytes=512):
    """Pure join for already recognized counts and the unchanged warning leaf.

    This bounds a selected process location lifetime; it is not a total-GGC
    or whole-native capacity predicate. Missing physical frontend joins remain
    explicit. Existing prefix and original-warning controls are not charged again.
    """
    for name, value, lower in [('C', c, 1), ('N', n, 0), ('P', path_bytes, 0)]:
        require(type(value) is int and value >= lower, name+' must be an integer in its domain')
    old = predecessor['conditional_map_transfer']
    original, initial = 2*c+n+5, 2*c+1
    require(predecessor['C'] == c and predecessor['N'] == n and
            predecessor['prefix_capacity_ceiling'] == 4093 and
            predecessor['other_original_gigi_put_calls'] == 5 and
            predecessor['selected_initial_gimplifier_warning_put_call_ceiling'] == initial and
            old['original_gigi_put_call_ceiling'] == original and
            old['outgoing_live_or_occupied_ceiling'] == 4093+original+initial and
            old['additive_GGC_event_ceiling'] == 1+original+initial and
            old['additional_singleton_finalizer_registrations_ceiling'] == 1,
            'exact predecessor warning boundary required')
    prime = lambda d: next((p for p in primes if p >= d), None)
    cf, statements, discrim = 4*c+2*n+2, 3*c+n+2, 3*c+2*n+5
    h = c+cf+discrim
    cap = power2(max(128, h))
    backing_events = 1+(cap.bit_length()-8)
    slots = prime(max(127, 2*h))
    raw = 40*cap
    bb_endpoint = c+2*(n+2)
    location_checks = dict(
        selected_ad_hoc_request_region=h <= REGION,
        hash_prime_exists=slots is not None,
        C_hash_probe_unsigned=slots is not None and 2*slots-3 <= U32,
        C_hash_load_products=slots is not None and max(8*h, 4*h, 3*slots) <= U64,
        C_hash_pointer_request=slots is not None and 8*slots <= I64,
        map_capacity_doubling_and_index=max(2*cap, h+1) <= U64,
        map_request_pointer_and_allocator_region=raw <= I64 and power2(raw) <= 2**62,
        location_tag_and_difference=h < 2**62,
        CFG_block_ID_unsigned_endpoint=bb_endpoint <= U32,
        discriminator_unsigned_to_signed_int=bb_endpoint <= I32,
    )
    later = cf+statements+c
    occupied = old['outgoing_live_or_occupied_ceiling']+later
    warning_slots = prime(max(old['outgoing_capacity_ceiling'] or 4093, 2*occupied))
    warning_checks = dict(
        predecessor_fits=old['conditional_map_interface_fits'],
        occupied_sufficient_region=occupied <= REGION,
        hash_prime_exists=warning_slots is not None,
        probe_unsigned=warning_slots is not None and 2*warning_slots-3 <= U32,
        load_products=warning_slots is not None and max(4*occupied, 3*warning_slots) <= U64,
        request_pointer_and_allocator_region=warning_slots is not None and
            16*warning_slots <= I64 and power2(16*warning_slots) <= 2**62,
    )
    filename_checks = dict(spelling_short=path_bytes <= 32767,
        identifier_length_unsigned=path_bytes <= U32, terminal_NUL=path_bytes+1 <= I64,
        source_file_count_signed=1589 <= I32)
    return dict(
        scope='Selected literal Main process: complete combined-location request sources and later dependent warning puts',
        counts=dict(output_calls=c, null_statements=n),
        source_family_location_request_bound_closed=True,
        source_family_later_warning_put_bound_closed=True,
        initial_ad_hoc_state=dict(occupied=0, allocated_entries=0,
            C_hash_slots=127, initial_hash_pointer_bytes=1016,
            initial_hash_control_bytes_upper=128, initial_objects_owned_by_fixed_prefix=True),
        location_requests=dict(initial_call_builder_upper=c,
            CF_block_attachment_upper=cf, CFG_discriminator_upper=discrim,
            original_and_helper_additional_upper=0, later_SSA_RTL_emission_additional_upper=0,
            insertion_capable_lookup_calls_upper=h, fresh_entries_upper=h,
            counts_include_early_return_hit_and_replacement_attempts=True),
        ad_hoc_storage=dict(allocated_entries_upper=cap,
            additional_GGC_backing_requests_upper=backing_events,
            each_caller_bytes_upper=raw, each_rounded_bytes_upper=power2(raw),
            hash_slots_upper=slots, lookup_ordinary_hash_backings_upper=h,
            relocation_traversal_possible_hash_backings_upper=backing_events-1,
            additional_ordinary_hash_backings_upper=h+backing_events-1,
            each_hash_pointer_backing_bytes_upper=None if slots is None else 8*slots,
            initial_ordinary_objects_added_again=0, additional_finalizer_registrations=0,
            relocation_rebases_existing_entries=True, deletion_or_GC_recreation=False),
        discriminators=dict(CFG_block_ID_endpoint_upper=bb_endpoint,
            per_line_discriminator_upper=bb_endpoint, public_interface_signed_bits=32),
        later_warning=dict(incoming=old, CF_put_calls_upper=cf,
            CFG_statement_setter_put_calls_upper=statements,
            CFG_edge_location_put_calls=0, RTL_call_tree_copy_put_calls_upper=c,
            insertion_capable_put_calls_upper=later,
            outgoing_live_or_occupied_upper=occupied,
            outgoing_capacity_upper=warning_slots,
            additional_GGC_backing_requests_upper=later,
            each_caller_bytes_upper=None if warning_slots is None else 16*warning_slots,
            each_rounded_bytes_upper=None if warning_slots is None else power2(16*warning_slots),
            additional_controls=0, additional_finalizer_registrations=0,
            original_and_initial_warning_requests_added_again=0,
            full_post_prefix_warning_GGC_events_diagnostic=old['additive_GGC_event_ceiling']+later,
            same_key_and_failed_source_lookup_calls_not_subtracted=True),
        filename_ingress=dict(scope='Separate metadata ingress with indexed System multiplicity correction',
            predecessor_source_file_entries_upper=1588, predecessor_lookup_calls_upper=1589,
            indexed_additional_Source_File_records_upper=1,
            source_file_entries_upper=1589, lookup_calls_upper=1590,
            identifier_node_requests_upper=1590, each_node_caller_bytes=40,
            each_node_rounded_bytes_upper=64, character_requests_upper=1590,
            each_character_caller_bytes_upper=path_bytes+1,
            each_character_rounded_bytes_upper=power2(path_bytes+1),
            direct_GGC_requests_upper=3180,
            shared_identifier_backing_owned_elsewhere=True,
            corrected_shared_identifier_projection_required=True,
            original_shared_packet_modified=False,
            included_in_new_location_warning_delta=False),
        additional_location_and_later_warning_GGC_events_upper=backing_events+later,
        additional_location_and_later_warning_finalizer_registrations=0,
        conditions=dict(ad_hoc_storage=all(location_checks.values()),
            later_warning_storage=all(warning_checks.values()),
            filename_direct_objects=all(filename_checks.values())),
        local_checks=dict(locations=location_checks, later_warning=warning_checks, filenames=filename_checks),
        ordinary_map_and_frontend_node_association_storage_included=False,
        whole_original_gigi_allocation_events=None, total_GGC_events=None,
        complete_global_counter_lifetime_closed=False, complete_collector_lifetime_closed=False,
        complete_gimplifier_lifetime_closed=False, whole_literal_pipeline_capacity_established=False,
        production_admission_changed=False, aggregate_RAM_gate=False, native_tool_executions=0)


def evaluate(c, n, context, path_bytes=512):
    return derive(c, n, context.warning(c, n, 5), context.primes, path_bytes)


def evaluate_source(raw, context, path_bytes=512):
    require(isinstance(raw, bytes) and all(32 <= b <= 126 or b in (9, 10, 13) for b in raw),
            'current literal source alphabet required')
    counts = context.recognizer(raw)
    require(counts['maximum_literal_length'] <= I32, 'literal length premise')
    result = evaluate(counts['output_calls'], counts['null_statements'], context, path_bytes)
    # Actual Main cannot carry Source_Reference. This checks the existing
    # ordinary-map line premise for Main; fixed/virtual file predicates stay
    # with their own source inventory, not silently inferred from this result.
    lines = len(re.split(rb'\r\n|[\r\n]', raw))
    result.update(source=identity(raw), source_counts=counts,
        Main_physical_line_entries_upper=lines,
        Main_ordinary_map_line_guard=1 <= lines <= 2**24,
        fixed_and_virtual_ordinary_map_line_guards='separate existing source-inventory premises',
        repository_inputs_verified=context.repository_inputs_verified,
        complete_source_files_verified=context.source_inputs_verified)
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--gcc-root', type=Path, default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    p.add_argument('--ada-root', type=Path, default=Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada'))
    p.add_argument('--source', type=Path, default=REPO/'samples/hello_world.adb')
    p.add_argument('--path-bytes', type=int, default=512)
    p.add_argument('--output', type=Path, default=HERE/'result.json')
    p.add_argument('--shared-correction-output', type=Path)
    args = p.parse_args()
    context = Context(args.gcc_root, args.ada_root)
    result = evaluate_source(args.source.read_bytes(), context, args.path_bytes)
    args.output.write_text(json.dumps(result, indent=2, sort_keys=True)+'\n')
    if args.shared_correction_output:
        correction = corrected_shared_identifier_projection(context.shared, result['source'], result['source_counts'])
        args.shared_correction_output.write_text(json.dumps(correction, indent=2, sort_keys=True)+'\n')
    print(json.dumps(dict(conditions=result['conditions'],
        location_requests=result['location_requests']['fresh_entries_upper'],
        new_GGC_events=result['additional_location_and_later_warning_GGC_events_upper'])))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Offline literal-output aggregate with explicit, source-named open joins.

One complete source scan drives the established native and Why formulas.
Passing their arithmetic is not a whole-pipeline capacity verdict.
"""
import argparse
import contextlib
from datetime import datetime, timezone
import hashlib
import io
import json
from pathlib import Path
import re
import runpy
import sys
import tempfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = REPO / 'docs/evidence'
NATIVE = EVIDENCE / 'unbounded-programs/retained-native-expansion-20261017'
I32, I64 = 2**31-1, 2**63-1


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(value, message):
    if not value:
        raise ValueError(message)


def load_checked_script(path, arguments):
    """Run an existing offline checker and retain its callable functions."""
    old = sys.argv
    try:
        sys.argv = [str(path), *map(str, arguments)]
        with contextlib.redirect_stdout(io.StringIO()):
            return runpy.run_path(str(path))
    finally:
        sys.argv = old


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gcc_match=None):
        pins = read(HERE/'inputs.json')
        for row in pins:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {key:row[key] for key in ('bytes','sha256')},
                    'changed aggregate input: '+row['path'])
        self.inputs_verified = len(pins)
        self.ssa_helper_layout = read(NATIVE/'native-rtl-helpers.json')
        roots = dict(gcc=Path(gcc_root), ada=Path(ada_root),
                     plugin=Path(plugin_include), silver=REPO, packet=NATIVE)
        checked = set()
        for manifest in (NATIVE/'literal-output-source-inputs.json',
                         NATIVE/'literal-rtl-backing-inputs.json',HERE/'source-join-inputs.json'):
            for row in read(manifest)['files']:
                path = roots[row['root']]/row['path']
                require(identity(path.read_bytes()) ==
                        {key:row[key] for key in ('bytes','sha256')},
                        'changed literal source: '+str(path))
                checked.add(str(path))
        ingress_packet=EVIDENCE/'retained-native-ingress-bound-20261018'
        ingress_manifest=read(ingress_packet/'source-manifest.json')
        match_path=Path(gcc_match) if gcc_match is not None else Path(
            ingress_manifest['source_root_defaults']['match'])
        for row in ingress_manifest['files']:
            if row['path']=='gcc/match.pd':
                path=match_path
            elif row['source_root']=='ada':
                path=roots['ada']/row['path'].removeprefix('gcc/ada/')
            else:
                path=roots['gcc']/row['path']
            require(identity(path.read_bytes()) ==
                    {key:row[key] for key in ('bytes','sha256')},
                    'changed native ingress source: '+str(path))
            checked.add(str(path))
        self.ingress = runpy.run_path(str(ingress_packet/'derive.py'))
        selected_host = (roots['plugin']/'auto-host.h').read_text()
        require(re.search(r'^#define GATHER_STATISTICS 0$', selected_host, re.M) and
                re.search(r'^#define CHECKING_P 0$', selected_host, re.M),
                'selected unshare set statistics/checking configuration')
        warning_packet=EVIDENCE/'retained-literal-warning-map-20261018'
        warning_manifest=read(warning_packet/'source-manifest.json')
        for row in warning_manifest['files']:
            relative=row['path'].removeprefix('gcc/ada/') if row['root']=='ada' else row['path']
            path=roots[row['root']]/relative
            require(identity(path.read_bytes()) ==
                    {key:row[key] for key in ('bytes','sha256')},
                    'changed native warning-map source: '+str(path))
            checked.add(str(path))
        for row in warning_manifest['retained_inputs']:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {key:row[key] for key in ('bytes','sha256')},
                    'changed native warning-map input: '+row['path'])
        self.warning = runpy.run_path(str(warning_packet/'derive.py'))
        residual_packet=EVIDENCE/'retained-literal-warning-residual-bound-20261018'
        for row in read(residual_packet/'source-manifest.json')['files']:
            path=(roots['ada']/row['path'].removeprefix('gcc/ada/')
                  if row['root']=='ada' else roots['gcc']/row['path'])
            require(identity(path.read_bytes()) ==
                    {key:row[key] for key in ('bytes','sha256')},
                    'changed original-gigi warning source: '+str(path))
            checked.add(str(path))
        self.warning_residual=runpy.run_path(str(residual_packet/'derive.py'))
        self.imported_functions=read(residual_packet/'interface.json')
        cold_packet=EVIDENCE/'retained-literal-string-layout-20261018'
        self.cold_string=read(cold_packet/'interface.json')
        for row in read(cold_packet/'source-manifest.json')['files']:
            path=(roots['ada']/row['path'].removeprefix('gcc/ada/')
                  if row['root']=='ada' else match_path if row['root']=='match'
                  else roots['gcc']/row['path'])
            require(identity(path.read_bytes()) ==
                    {key:row[key] for key in ('bytes','sha256')},
                    'changed cold String source: '+str(path))
            checked.add(str(path))
        self.source_files_verified = len(checked)
        frontend_packet=EVIDENCE/'retained-literal-native-frontend-20261018'
        self.frontend = runpy.run_path(str(frontend_packet/'compose.py'))
        self.frontend_model = self.frontend['load_model'](roots['ada'])
        frontend_identity=read(frontend_packet/'inputs.json')
        # Report nested validation separately: these sets overlap the direct
        # source checks above and are not additive unique-file populations.
        self.frontend_verification = dict(
            repository_inputs=len(frontend_identity['repository_inputs']),
            native_selected_files=len(self.frontend_model['hashes']),
            complete_Ada_macro_inventory_files=self.frontend_model['macro_flag_searched_files'],
            counts_overlap_direct_source_validation=True)
        # These are retained evidence inputs, not a newly observed prefix.
        self.prefix = read(NATIVE/'native-gcc-prefix-witness.json')
        self.pool_seed = self.prefix['counters']['ggc_bytes']['positive_events']
        require(self.pool_seed == 39257 and not self.prefix['counter_wrap_or_reset']
                and not self.prefix['collection_or_new_thread_observed'],
                'retained fixed-prefix event premise')
        prime_source = (roots['gcc']/'gcc/hash-table.cc').read_text()
        self.primes = [int(value) for value in re.findall(r'\{\s+(\d+),', prime_source)]
        require(self.primes[-1] == I32, 'reviewed GCC prime-table range')
        self.literal = runpy.run_path(str(NATIVE/'derive-literal-output.py'))
        self.backing = runpy.run_path(str(NATIVE/'derive-literal-rtl-backing.py'))
        self.physical = runpy.run_path(str(NATIVE/'compose-null-capacity.py'))['physical_source_shape']
        with tempfile.TemporaryDirectory(prefix='silver-literal-rtl-') as temporary:
            self.rtl = load_checked_script(EVIDENCE/'retained-output-rtl-20261018/check.py',
                                          ['--output',Path(temporary)/'rtl.json'])
        self.why = runpy.run_path(str(EVIDENCE/'retained-producer-composition-20261018/check.py'))
        for path, sha in read(EVIDENCE/'retained-producer-composition-20261018/result.json')['input_sha256'].items():
            require(identity((EVIDENCE/path).read_bytes())['sha256'] == sha,
                    'changed Why input: '+path)
        self.fixed_counts, self.fixed_modules = self.why['fixed_envelope']()
        self.schema = read(EVIDENCE/'retained-producer-storage-20261018/serialization.json')['schema']
        self.specialization = runpy.run_path(str(EVIDENCE/
            'retained-literal-producer-specialization-20261018/compose.py'))
        self.specialization_context = self.specialization['Context']()
        self.assembler = runpy.run_path(str(EVIDENCE/'retained-literal-assembler-20261018/compose.py'))
        self.assembler_context = self.assembler['Context']()
        self.assembler_storage = runpy.run_path(str(EVIDENCE/'retained-literal-assembler-20261018/storage.py'))
        self.assembler_storage_context = self.assembler_storage['Context']()
        self.linker = runpy.run_path(str(EVIDENCE/'retained-literal-linker-20261018/compose.py'))
        self.linker_context = self.linker['Context']()
        self.ali = runpy.run_path(str(EVIDENCE/'retained-literal-ali-20261018/compose.py'))
        self.ali_context = self.ali['Context'](ada_root)
        self.ali_consumers = runpy.run_path(str(EVIDENCE/'retained-literal-binder-ali-20261018/compose.py'))
        self.ali_consumers_context = self.ali_consumers['Context'](ada_root)
        self.gpr_parent = runpy.run_path(str(EVIDENCE/'retained-literal-gpr-parent-20261018/compose.py'))
        self.gpr_parent_context = self.gpr_parent['Context'](ada_root)
        self.system = read(NATIVE/'native-indexed-source-buffers.json')['additional_System_input']
        self.configuration = (NATIVE/'null-capacity-fixture.adc').read_bytes()
        checksum = runpy.run_path(str(EVIDENCE/'retained-binder-checksum-closure-20261018/check.py'))
        self.checksum = checksum['evaluate']()


def shared_counts(raw, context):
    """Count words/regions only after the existing complete grammar recognizer."""
    require(all(32 <= byte <= 126 or byte in (9,10,13) for byte in raw),
            'current ASCII source alphabet required')
    native = context.literal['source_counts'](raw)
    words = []
    for match in context.literal['TOKEN'].finditer(raw):
        token = match[0]
        if re.fullmatch(rb'[A-Za-z][A-Za-z_0-9]*',token):
            words.append(token)
    c, n = native['output_calls'], native['null_statements']
    # There is one source literal identity per call, even for equal bytes.
    # No concat, parser flattening or copied declaration exists in this class.
    why = dict(W=len(words), I=max(map(len,words)), S=c, N=0,
               context=1, dots=c, calls_with_actual=c, C_lib=c, output=c,
               X=c, H_chars=native['decoded_literal_bytes'], null=n,
               shape_regions=[dict(dots=1,calls_with_actual=1) for _ in range(c)]
                             +[dict(null=1) for _ in range(n)])
    return native, why


def native_cold_string_interface(context):
    """Join the reviewed fixed helper contribution, preserving open costs."""
    cold=context.cold_string
    require(cold['size_functions_created']==2 and
            cold['initial_helper_gimplifications']==2 and
            cold['additional_live_function_nodes_during_initial_Main_lowering']==2 and
            cold['helper_ordinary_lowering_executions']==0 and
            cold['helper_IPA_body_executions']==0 and
            cold['helper_RTL_expansions']==0 and
            cold['helper_emitted_functions']==0 and
            cold['live_helper_nodes_after_initial_removal']==0 and
            cold['persistent_counter_increments']==dict(symbol_next_uid=2,
                symbol_order=2,function_definition_number=2,private_size_function_fnno=2) and
            cold['R'] is None and cold['helper_allocation_request_events'] is None and
            cold['helper_allocation_bytes'] is None and
            not cold['complete_imported_frontier_closed'] and
            not cold['whole_literal_pipeline_capacity_established'],
            'literal cold String helper interface join')
    return cold


def native_pool_lifetime(c, context):
    """Conditional symbol/pool arithmetic; imported constructors remain open.

    A request group represents individual requests, never a sum-RAM gate.
    The fixed prefix is an incoming population ceiling, not null's lifetime.
    """
    require(type(c) is int and c >= 1, 'positive literal call count')
    helpers=native_cold_string_interface(context)['size_functions_created']
    d_in = context.pool_seed
    tree_live = d_in + 2*c
    # Conservatively include both helpers even if the table is initialized
    # after their removal. The hard-register dummy is still excluded.
    asm_live = c + 3 + helpers

    def prime(request):
        return next((p for p in context.primes if p >= request), None)

    # A failed local bound is returned explicitly; do not round into the
    # unsigned-hash prime range whose probe sum has no no-wrap proof.
    tree_slots = prime(max(1009, 2*tree_live))
    asm_slots = prime(max(10, 2*asm_live))
    incoming_slots = prime(max(1009, 2*d_in))
    ref_capacity = max(4, 2*c)
    requests = [
        dict(object='bounds varpool node', requests_upper=c, raw_bytes_upper=256,
             storage='GGC'),
        dict(object='tree-pool replacement backing', requests_upper=3*c,
             raw_bytes_upper=None if tree_slots is None else 8*tree_slots,
             storage='GGC'),
        dict(object='assembler-name hash control', requests_upper=1,
             raw_bytes_upper=128, storage='GGC'),
        dict(object='assembler-name initial or replacement backing',
             requests_upper=1+asm_live,
             raw_bytes_upper=None if asm_slots is None else 8*asm_slots,
             storage='GGC'),
        dict(object='initializer visited-node backing', requests_upper=c,
             raw_bytes_upper=104, storage='ordinary'),
        # safe_grow and safe_push can each reserve once per reference.
        # Four complete graph scans; equal bounds may share one target.
        dict(object='Main outgoing reference backing', requests_upper=4*c,
             raw_bytes_upper=8+48*ref_capacity, storage='ordinary'),
        dict(object='bounds incoming-reference backing', requests_upper=4*c,
             raw_bytes_upper=8+8*ref_capacity, storage='ordinary')]
    checks = dict(
        tree_pool_live_and_probe=tree_live <= 1073741823,
        assembler_name_live_and_probe=asm_live <= 1073741823,
        symbol_uid_and_order=c+5+helpers <= I32,
        reference_vector_capacity=ref_capacity <= I32,
        reference_vector_growth_intermediate=3*c <= 2**32-1,
        reference_vector_signed_traversal=c <= I32,
        reference_request_size=8+48*ref_capacity <= I64,
        # Prefix descriptor creation is charged conservatively to labels too;
        # no prefix function/static-space/partition label path is selected.
        tree_constant_label_counter=d_in+2*c <= I32)
    return dict(
        source_input=dict(bounds_finalize_calls_upper=c,pool_entries_upper=2*c,
                          insertion_capable_pool_lookups_upper=3*c),
        incoming_tree_pool=dict(live_upper=d_in,occupied_upper=d_in,
                                deleted_upper=d_in,capacity_upper=incoming_slots,
                                initial_request=1009,initial_capacity=1021,
                                basis='retained fixed-prefix positive GGC events; no empty-pool assumption'),
        tree_pool=dict(live_upper=tree_live,occupied_upper=tree_live,
                       capacity_upper=tree_slots,replacement_requests_upper=3*c,
                       pre_hit_expansion_charged=True),
        symbols=dict(fixed_prefix_registered_nodes=0,
                     pre_gimplification_Main_and_dummy=2,
                     external_callee_nodes_upper=2,
                     cold_String_helper_nodes=helpers,
                     bounds_nodes_upper=c,registered_nodes_upper=c+4+helpers,
                     next_uid_upper=c+5+helpers,order_upper=c+4+helpers,
                     assembler_name_live_upper=asm_live,
                     assembler_name_capacity_upper=asm_slots),
        bounds_lifecycle=dict(finalize_calls_upper=c,fresh_nodes_upper=c,
                              initializer_analysis_calls_upper=c,
                              visited_nodes_per_initializer_upper=3,
                              initializer_outgoing_references=0,
                              reference_build_scans_upper=4,
                              incoming_reference_additions_upper=4*c,
                              live_incoming_references_total_upper=c,
                              queue_insertions_upper=2*c,
                              queue_allocation_requests=0,
                              reference_pointer_updates_upper=4*c*c,
                              assembly_definitions_upper=c,
                              release_node_calls_upper=c),
        individual_request_groups=requests,
        additional_GGC_request_events_upper=sum(row['requests_upper'] for row in requests
                                                if row['storage']=='GGC'),
        additional_singleton_finalizer_registrations_upper=1,
        finalizer_dispatch_allocation_requests=0,
        excluded_already_charged_direct_pool_GGC_events=10*c,
        fixed_Main_callee_dummy_node_requests_not_in_delta=4,
        local_representation_checks=checks,
        conditional_arithmetic_fits=all(checks.values()),
        imported_constructor_frontier_established=False,
        required_premise='No other post-prefix imported pool/symbol contribution beyond the two joined String helper nodes, or a separately composed bound (#131). Helper allocation totals remain separate.',
        named_consumer_closed=False,
        whole_native_pipeline_capacity_established=False,
        source_argument='docs/research/retained-literal-pipeline.md#bounds-pool-and-symbol-lifetime-join')


def native_graph_lifetime(c, n, context):
    """Conditional Main graph arithmetic with two discarded helper nodes."""
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0,
            'literal graph counters')
    helpers=native_cold_string_interface(context)['size_functions_created']
    prime = lambda request: next((p for p in context.primes if p >= request),None)
    edge_slots = prime(max(120,2*c))
    symbol_slots = prime(max(13,2*(c+4+helpers)))
    single_user_slots = prime(max(13,2*c))
    comdat_slots = prime(max(251,2*(c+4+helpers)))
    # The initial 13-slot ordinary call-summary vector has no GC rounding.
    summary_capacity = max(13,2*c)
    recycled_capacity = max(4,2*c)
    statements = 3*c+n+2
    work_capacity = max(4,2*statements)
    blocks = n+4
    block_capacity = max(10,2*blocks)
    # Source cap inside account_size_time is 256 entries, not a Silver cap.
    table_capacity = max(4,2*min(256,2+2*statements))
    ggc = [
        dict(object='fresh direct cgraph edge', requests_upper=4*c,raw_bytes_upper=144),
        dict(object='call-site hash control', requests_upper=4,raw_bytes_upper=128),
        dict(object='call-site hash initial/insertion backing',requests_upper=4+4*c,
             raw_bytes_upper=None if edge_slots is None else 8*edge_slots),
        dict(object='call-site hash terminal-empty backing',requests_upper=4,
             raw_bytes_upper=None if edge_slots is None else 8*edge_slots),
        dict(object='fixed Main and imported callee cgraph nodes',requests_upper=3,raw_bytes_upper=512),
        dict(object='cold String helper cgraph nodes',requests_upper=helpers,raw_bytes_upper=512),
        dict(object='fixed dummy varpool node',requests_upper=1,raw_bytes_upper=256),
        dict(object='fixed dummy VAR_DECL',requests_upper=1,raw_bytes_upper=312),
        dict(object='fixed dummy identifier',requests_upper=1,raw_bytes_upper=40),
        dict(object='fixed dummy identifier bytes',requests_upper=1,raw_bytes_upper=31),
        dict(object='function-summary manager',requests_upper=3,raw_bytes_upper=512),
        dict(object='function-summary GGC pointer vector',requests_upper=3,raw_bytes_upper=128),
        dict(object='local Main function-summary record',requests_upper=2,raw_bytes_upper=128),
        dict(object='IPA parameter/edge-argument manager',requests_upper=2,raw_bytes_upper=512),
        dict(object='IPA parameter/edge-argument empty map',requests_upper=2,raw_bytes_upper=208),
        dict(object='IPA value-range hash control',requests_upper=1,raw_bytes_upper=128),
        dict(object='IPA value-range empty backing',requests_upper=1,raw_bytes_upper=488)]
    ordinary = dict(
        call_summary_records_upper=2*c,call_summary_record_bytes_upper=32,
        summary_pool_block_bytes=65536,
        size_summary_record_bytes=16,size_summary_pool_blocks_upper=3,
        fixed_summary_and_growth_cache_vector_bytes=112,
        free_language_data_vector_bytes_each=808,
        empty_pointer_hash_backing_bytes=104,
        ODR_hash_control_bytes_upper=128,ODR_hash_backing_bytes=248,
        call_summary_vector_capacity_upper=summary_capacity,
        call_summary_vector_request_bytes_upper=8+8*summary_capacity,
        recycled_summary_ID_vector_request_bytes_upper=8+4*recycled_capacity,
        necessary_statement_worklist_bytes_upper=8+8*work_capacity,
        necessary_statement_block_cache_bytes_upper=8+block_capacity,
        summary_block_order_bytes_upper=4*blocks,
        summary_CFG_preorder_stack_bytes_upper=8+16*max(20,blocks+1),
        size_time_table_request_bytes_upper=8+96*table_capacity,
        pointer_reachability_hash_per_invocation_bytes_upper=None if symbol_slots is None else 8*symbol_slots,
        single_user_map_bytes_upper=None if single_user_slots is None else 16*single_user_slots,
        COMDAT_map_bytes_each_upper=None if comdat_slots is None else 16*comdat_slots,
        COMDAT_map_live_upper=c+4+helpers,
        inline_order_array_bytes_each=24,reverse_postorder_stack_bytes=72,
        reduced_postorder_stack_bytes=24,reduced_DFS_record_bytes=32,
        reduced_splay_node_bytes=32,splay_control_bytes_upper=64,
        indirect_edge_vector_bytes=72,pending_transform_vector_bytes=40,
        summary_manager_bytes_upper=512,hook_node_bytes=24,
        cold_hook_nodes_upper=3*8+1+6+5+1)
    checks = dict(
        cgraph_edge_UID=1+4*c <= I32,
        call_site_hash_live_and_probe=c <= 1073741823,
        symbol_reachability_hash_live_and_probe=c+4+helpers <= 1073741823,
        call_summary_ID=c <= I32,
        call_summary_vector_capacity=summary_capacity <= I32,
        recycled_summary_vector_capacity=recycled_capacity <= I32,
        vector_growth_intermediate=3*max(c,statements,blocks) <= 2**32-1,
        statement_worklist_capacity=work_capacity <= I32,
        block_cache_capacity=block_capacity <= I32,
        summary_CFG_preorder_capacity=blocks+1 <= I32,
        summary_signed_size_and_rounding=26*c+7 <= I32,
        summary_sreal_exponent=5*c+400 < I32//4,
        summary_worklist_size_product=8+8*work_capacity <= I64,
        summary_record_pool_counts=2*c*65536 <= 2**64-1)
    return dict(source_input=dict(calls=c,nulls=n,graph_scans_upper=4,
                                  post_CFG_statements_upper=statements,block_slots_upper=blocks),
        edge_creation_events_upper=4*c,live_edges_upper=c,edge_uid_endpoint_upper=1+4*c,
        call_site_hash_lifetimes_upper=4,call_site_hash_live_upper=c,
        call_site_hash_slots_upper=edge_slots,call_site_hash_terminal_empty_events_upper=4,
        call_summary_ID_high_water_upper=c,call_summary_creation_events_upper=2*c,
        function_summary_ID_high_water_upper=1,
        parameter_edge_argument_and_value_range_entries=0,
        optimized_or_inlined_body_copies=0,additional_registered_symbols=helpers,
        cold_helper_ordinary_lowering_executions=0,
        cold_helper_summary_ID_assignments=0,
        summary_scaled_size_upper=26*c+6,summary_rounding_numerator_upper=26*c+7,
        summary_positive_time_exponent_upper=5*c+400,
        individual_GGC_request_groups=ggc,ordinary_requests=ordinary,
        additional_GGC_request_events_upper=sum(row['requests_upper'] for row in ggc),
        additional_singleton_finalizer_registrations_upper=5,
        conditional_arithmetic_fits=all(checks.values()),
        imported_constructor_frontier_established=False,
        required_premise='Main is the sole body reaching ordinary lowering/IPA; the two joined String helpers are initially gimplified and discarded without graph analysis. Other imported constructor and helper allocation costs remain separate (#131).',
        conditional_graph_and_summary_lifetime_closed=False,
        local_representation_checks=checks,whole_native_pipeline_capacity_established=False,
        source_argument='docs/research/retained-literal-pipeline.md#direct-call-graph-and-ipa-summary-lifetime')


def native_ssa_helper_backing(c, n, context):
    """Transfer ordinary ranger/out-of-SSA backing to literal extents."""
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0,
            'literal SSA helper counters')
    z, b, r = 3*c+2, n+2, n+5
    coalesce_request = max(40,3*z)
    coalesce_slots = next((p for p in context.primes if p >= coalesce_request),None)
    vec = lambda count,size: 8+max(4,count)*size
    fixed = context.ssa_helper_layout
    vectors = dict(
        statement_list=vec(z,8),block_range_cache=vec(z,8),timestamps=vec(z,4),
        GORI_definition_chain=vec(z,24),GORI_outgoing=vec(r,8),GORI_incoming=vec(r,8),
        infer_exit=vec(r+1,24),infer_nonzero=vec(z+1,8),propagation_update=vec(r+64,4),
        optional_equivalence=vec(r+1,8),optional_self_equivalence=vec(z+1,8),
        optional_partial_equivalence=vec(z+1,24),optional_relations=vec(r+1,24))
    headers = 2*r+8
    checks = dict(
        initial_partition_signed_count=z <= I32,
        SSA_plus_one_vector_31_bit=z+1 <= I32,
        coalesce_initial_request_unsigned=3*z <= 2**32-1,
        coalesce_prime_capacity=coalesce_request <= I32 and coalesce_slots is not None,
        coalesce_empty_iteration_index=coalesce_slots is not None and coalesce_slots <= I32,
        ranger_block_plus_64_signed=r+64 <= I32,
        partition_and_view_byte_products=max(8+16*z,4*z) <= I64,
        ranger_vector_byte_products=max(vectors.values()) <= I64,
        private_bitmap_header_count=headers <= 2**64-1)
    return dict(source_input=dict(calls=c,nulls=n,SSA_slots_upper=z,
                                  ordinary_GIMPLE_blocks_upper=b,ranger_block_slots_upper=r),
        out_of_SSA=dict(
            variable_map_bytes=fixed['out_of_SSA']['variable_map_bytes'],
            initial_partition_bytes_upper=8+16*z,partition_view_requests_upper=2,
            each_partition_view_bytes_upper=4*z,block_pointer_vector_bytes_upper=8+8*b,
            real_partitions=0,tentative_zero_partition_bytes=8,
            zero_xmalloc_or_xcalloc_actual_bytes=1,
            coalesce_record_bytes=120,coalesce_hash_wrapper_bytes=48,
            coalesce_hash_request_slots_upper=coalesce_request,
            coalesce_hash_slots_upper=coalesce_slots,
            coalesce_hash_backing_bytes=None if coalesce_slots is None else 8*coalesce_slots,
            coalesce_hash_live_entries=0,coalesce_hash_probe_calls=0,
            same_variable_hash_backing_bytes=104,
            coalesce_obstack_chunk_bytes=65536,
            elimination_vector_bytes=fixed['out_of_SSA']['elimination_vector_raw_bytes'],
            zero_partition_simple_bitmap_bytes=8,
            shared_default_bitmap_headers_upper=5,shared_default_bitmap_elements=0),
        ranger_per_instance=dict(
            ordinary_vectors_raw_bytes_upper=vectors,
            ordinary_object_bytes_upper=fixed['ranger_per_instance']['ordinary_object_bytes_upper'],
            vrange_allocator_pairs=3,default_obstack_initial_chunks_upper=5,
            default_obstack_chunk_bytes=4064,bitmap_obstack_initial_chunks_upper=5,
            bitmap_obstack_chunk_bytes=65536,bitmap_headers_upper=headers,
            # One new chunk per completed header is conservative; no oversized object.
            bitmap_obstack_all_chunk_requests_upper=5+headers,
            bitmap_elements=0,range_cache_entries=0,range_clones=0,
            constructor_vector_growth_after_initialization=0,
            Boolean_range_heap_growth=False,temporal_time_final=1,
            definition_chain_depth_final=0,temporary_edge_flag_bit=18),
        sequential_ranger_instances_upper=2,
        additional_GGC_request_events_upper=0,
        conditional_SSA_helper_backing_closed=all(checks.values()),
        local_representation_checks=checks,whole_native_pipeline_capacity_established=False,
        source_argument='docs/research/retained-literal-pipeline.md#literal-sized-ranger-and-out-of-ssa-backing')


def native_initial_ssa_lifetime(c, n, context):
    """Initial SSA infrastructure and renaming; excludes CF/CFG/gimplifier construction."""
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0,
            'literal initial SSA counters')
    z, uses, blocks = 3*c+2, 3*c+1, n+4
    stack_pushes = blocks+6*c
    stack_capacity = max(10,2*stack_pushes)
    prime = next((p for p in context.primes if p>=max(7,c)),None)
    vector_requested_slots = max(50,2*z)
    vector_bytes = 1 << (8+8*vector_requested_slots-1).bit_length()
    vector_capacity = (vector_bytes-8)//8
    slab_4K = int(uses>25)
    slab_16K = (max(0,uses-127)+408)//409
    bitmap_elements = (blocks+127)//128
    ggc = [
        dict(object='initial gimple_df',requests_upper=1,raw_bytes_upper=256),
        dict(object='default-def hash control',requests_upper=1,raw_bytes_upper=128),
        dict(object='default-def initial backing',requests_upper=1,raw_bytes_upper=248),
        dict(object='initial SSA-name vector and growth',requests_upper=z,raw_bytes_upper=vector_bytes),
        dict(object='memory VAR_DECL',requests_upper=1,raw_bytes_upper=312),
        dict(object='memory identifier',requests_upper=1,raw_bytes_upper=40),
        dict(object='memory identifier characters',requests_upper=1,raw_bytes_upper=5),
        dict(object='fresh memory SSA_NAME',requests_upper=uses,raw_bytes_upper=88),
        dict(object='detached default definition NOP',requests_upper=1,raw_bytes_upper=64),
        dict(object='operand-use first slab',requests_upper=1,raw_bytes_upper=1024),
        dict(object='operand-use second slab',requests_upper=slab_4K,raw_bytes_upper=4096),
        dict(object='operand-use later slabs',requests_upper=slab_16K,raw_bytes_upper=16384)]
    ordinary = dict(
        var_info_hash_control_bytes_upper=128,
        var_info_hash_backing_bytes_upper=None if prime is None else 8*prime,
        var_info_records_upper=1,var_info_record_bytes=48,var_info_vector_bytes=16,
        interesting_block_bitmap_bytes_upper=8+8*((blocks+63)//64),
        frontier_bitmap_header_array_bytes_upper=32*blocks,frontier_elements=0,
        reaching_definition_stack_capacity_upper=stack_capacity,
        reaching_definition_stack_bytes_upper=8+8*stack_capacity,
        private_SSA_bitmap_headers_upper=3,
        private_SSA_bitmap_elements_upper=2*bitmap_elements,
        private_SSA_bitmap_chunk_requests_upper=4+2*bitmap_elements,
        private_SSA_bitmap_each_chunk_bytes=65536,
        shared_default_bitmap_headers_upper=3,
        shared_kills_bitmap_live_elements_upper=1,
        shared_kills_bitmap_element_requests_upper=blocks,
        shared_PHI_prune_bitmap_elements_upper=bitmap_elements,
        PHI_work_set_bytes_upper=8+4*max(64,blocks),
        PHI_pruning_large_arrays_reached=False,
        dominator_walks=2,walk_int_array_bytes_each_upper=4*blocks,
        walk_int_arrays_per_walk=2,
        walk_pointer_stack_bytes_upper=16*blocks,
        walk_preorder_stack_bytes_upper=8+16*max(20,blocks+1),
        cold_forward_dominance_unsigned_arrays=9,
        cold_forward_dominance_unsigned_arrays_bytes_each_upper=4*blocks,
        cold_forward_dominance_pointer_array_bytes_upper=8*blocks,
        cold_forward_dominance_order_array_bytes_upper=4*(blocks+1),
        cold_forward_dominance_edge_iterator_array_bytes_upper=16*(blocks+1),
        live_ET_nodes_upper=blocks,live_ET_occurrences_upper=2*blocks,
        ET_node_pool_blocks_upper=(blocks+909)//910,
        ET_occurrence_pool_blocks_upper=(2*blocks+1169)//1170,
        each_ET_pool_block_bytes=65536)
    checks = dict(
        phase_SSA_name_versions_and_fresh_count=uses <= I32,
        SSA_vector_growth_unsigned_intermediate=3*z <= 2**32-1,
        SSA_vector_normalized_capacity_31_bit=vector_capacity <= I32,
        SSA_vector_size_product=vector_bytes <= I64,
        var_info_initial_hash_region=prime is not None and prime <= I32,
        initial_CFG_and_dominance_signed_intermediate=4*blocks <= I32,
        definition_stack_growth_unsigned_intermediate=3*stack_pushes <= 2**32-1,
        definition_stack_capacity_31_bit=stack_capacity <= I32,
        bitmap_rounding_unsigned=blocks+127 <= 2**32-1,
        ordinary_size_products=max(32*blocks,8+8*stack_capacity) <= I64)
    return dict(source_input=dict(calls=c,nulls=n,SSA_slots_upper=z,
                                  memory_definitions_upper=3*c,memory_uses_upper=uses,
                                  initial_CFG_block_slots_upper=blocks),
        default_memory_names=1,nondefault_memory_names_upper=3*c,
        initial_SSA_operand_slab_requested_bytes_upper=1024+4096*slab_4K+16384*slab_16K,
        SSA_name_vector_normalized_capacity_upper=vector_capacity,
        default_definition_hash_entries=1,real_SSA_names=0,PHIs=0,
        individual_GGC_request_groups=ggc,ordinary_requests=ordinary,
        additional_GGC_request_events_upper=sum(row['requests_upper'] for row in ggc),
        additional_singleton_finalizer_registrations_upper=1,
        additional_DECL_UID_events_upper=1,additional_identifier_misses_upper=1,
        additional_global_SSA_name_creation_events_upper=uses,
        global_SSA_creation_counter_lifetime_closed=False,
        conditional_initial_SSA_lifetime_closed=all(checks.values()),
        local_representation_checks=checks,whole_native_pipeline_capacity_established=False,
        source_argument='docs/research/retained-literal-pipeline.md#initial-ssa-lifetime')


def native_initial_cf_cfg_lifetime(c, n, context):
    """Initial CF/EH/CFG/root-loop constructors, given the established GIMPLE shape.

    Direct gimplifier sites are exposed separately: their count does not close
    deep unsharing, expression folding, shared type helpers or metadata.
    """
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0,
            'literal initial CF/CFG counters')
    b, blocks, edges, labels = n+2, n+4, n+3, n+1
    post_goto_statements = 3*c+n+2
    discriminator_calls = post_goto_statements+edges
    discriminator_endpoint = c+2*b
    prime = lambda request: next((p for p in context.primes if p>=request),None)
    eh_slots = prime(max(31,2*labels))
    discrim_slots = prime(max(13,2*discriminator_calls))

    def gc_vector(extent, initial):
        requested = max(initial,2*extent)
        raw = 1 << (8+8*requested-1).bit_length()
        return dict(requested_slots_upper=requested,raw_bytes_upper=raw,
                    normalized_capacity_upper=(raw-8)//8)

    vectors = dict(local_declarations=gc_vector(c,4),
                   block_map=gc_vector(blocks,20),label_map=gc_vector(labels,20))
    block_backings = 1+max(0,blocks-20)
    label_backings = 1+max(0,labels-20)
    ggc = [
        dict(object='CF return goto and label tuples',requests_upper=2,raw_bytes_upper=80),
        dict(object='CF return LABEL_DECL',requests_upper=1,raw_bytes_upper=256),
        dict(object='local-declaration vector backing',requests_upper=c,
             raw_bytes_upper=vectors['local_declarations']['raw_bytes_upper']),
        dict(object='initial CFG control',requests_upper=1,raw_bytes_upper=128),
        dict(object='initial CFG blocks including entry and exit',requests_upper=blocks,raw_bytes_upper=128),
        dict(object='initial CFG block-map backing',requests_upper=block_backings,
             raw_bytes_upper=vectors['block_map']['raw_bytes_upper']),
        dict(object='initial CFG label-map backing',requests_upper=label_backings,
             raw_bytes_upper=vectors['label_map']['raw_bytes_upper']),
        dict(object='initial CFG edges',requests_upper=edges,raw_bytes_upper=64),
        dict(object='initial CFG predecessor and successor vectors',requests_upper=2*edges,raw_bytes_upper=64),
        dict(object='initial loops control',requests_upper=1,raw_bytes_upper=32),
        dict(object='initial root loop',requests_upper=1,raw_bytes_upper=1024),
        dict(object='initial root-loop exit sentinel',requests_upper=1,raw_bytes_upper=32),
        dict(object='initial root-loop vector',requests_upper=1,raw_bytes_upper=16)]
    # This list deliberately identifies direct sites, not a whole-gimplifier sum.
    direct = [
        dict(object='initial one-argument call tuple',requests_upper=c,raw_bytes_upper=256),
        dict(object='initial store/goto/label/return tuple',requests_upper=2*c+2*n+1,raw_bytes_upper=128),
        dict(object='outer and possible call-local bind tuples',requests_upper=c+1,raw_bytes_upper=128),
        dict(object='gimplifier descriptor VAR_DECL',requests_upper=c,raw_bytes_upper=312),
        dict(object='descriptor and field INIT_EXPR',requests_upper=3*c,raw_bytes_upper=40),
        dict(object='descriptor field COMPONENT_REF',requests_upper=2*c,raw_bytes_upper=48)]
    ordinary = dict(
        CF_return_record_vector_bytes=136,
        EH_hash_control_bytes_upper=128,EH_hash_live_entries_upper=labels,
        EH_hash_slots_upper=eh_slots,EH_hash_backing_requests_upper=1+labels,
        EH_hash_each_backing_bytes_upper=None if eh_slots is None else 8*eh_slots,
        EH_finally_record_requests_upper=labels,EH_finally_record_bytes=16,
        label_array_requests=2,label_array_bytes_each_upper=16*blocks,
        discriminator_hash_live_entries_upper=discriminator_calls,
        discriminator_hash_slots_upper=discrim_slots,
        discriminator_hash_backing_requests_upper=1+discriminator_calls,
        discriminator_hash_each_backing_bytes_upper=None if discrim_slots is None else 12*discrim_slots,
        cleanup_preorder_stack_bytes_upper=8+16*max(20,blocks+2),
        cleanup_dense_visited_bitmap_bytes_upper=8+8*((blocks+63)//64),
        empty_edge_case_hash_control_bytes_upper=128,empty_edge_case_hash_backing_bytes=208,
        shared_default_bitmap_headers_upper=3,
        shared_altered_bitmap_live_elements_upper=(blocks+127)//128,
        shared_altered_bitmap_fresh_elements_upper=(blocks+127)//128,
        shared_other_bitmap_elements=0,
        root_loop_reverse_order_array_bytes_upper=4*blocks,
        root_loop_preorder_stack_bytes_upper=8+16*max(20,blocks+1),
        root_loop_candidate_vector_bytes=16)
    initial_ssa = native_initial_ssa_lifetime(c,n,context)['ordinary_requests']
    dominance = {k:v for k,v in initial_ssa.items()
                 if k.startswith(('cold_forward_dominance_','live_ET_','ET_','each_ET_'))}
    checks = dict(
        CFG_block_edge_and_dominance_signed=4*blocks <= I32,
        label_UID_signed_endpoint=labels <= I32,
        GC_vector_growth_unsigned=3*max(c,blocks,labels) <= 2**32-1,
        GC_vector_normalized_capacity_31_bit=all(v['normalized_capacity_upper'] <= I32 for v in vectors.values()),
        GC_vector_byte_products=all(v['raw_bytes_upper'] <= I64 for v in vectors.values()),
        EH_hash_prime_and_probe=eh_slots is not None and 2*eh_slots-3 <= 2**32-1,
        discriminator_hash_prime_and_probe=discrim_slots is not None and 2*discrim_slots-3 <= 2**32-1,
        discriminator_block_ID_and_value=discriminator_endpoint <= 2**32-1,
        bitmap_rounding_unsigned=blocks+127 <= 2**32-1,
        ordinary_byte_products=max(16*blocks,8+16*max(20,blocks+2),
            0 if eh_slots is None else 8*eh_slots,
            0 if discrim_slots is None else 12*discrim_slots) <= I64)
    return dict(source_input=dict(calls=c,nulls=n,ordinary_blocks_upper=b,
                                  initial_CFG_block_slots_upper=blocks,initial_edges_upper=edges,
                                  initial_label_UID_requests_upper=labels,
                                  post_goto_statements_upper=post_goto_statements),
        individual_GGC_request_groups=ggc,ordinary_requests=ordinary,
        normalized_GC_vectors=vectors,initial_forward_dominance=dominance,
        additional_GGC_request_events_upper=sum(g['requests_upper'] for g in ggc),
        additional_singleton_finalizer_registrations_upper=0,
        additional_DECL_UID_events_upper=1,
        additional_GIMPLE_tuple_count_upper=2,
        additional_CF_block_location_requests_upper=4*c+2*n+2,
        discriminator_assignment_calls_upper=discriminator_calls,
        discriminator_block_ID_endpoint_upper=discriminator_endpoint,
        additional_discriminator_location_requests_upper=discriminator_calls,
        direct_gimplifier_interface=dict(
            individual_GGC_request_groups=direct,
            direct_site_GGC_request_events_upper=sum(g['requests_upper'] for g in direct),
            additional_DECL_UID_events_upper=c,temporary_identifier_misses=0,
            initial_tuple_requests_upper=4*c+2*n+2,
            retained_source_bind_tuples_upper=c+1,simultaneous_bind_depth_upper=2,
            context_bytes_upper=128,bind_stack_bytes=136,
            bind_stack_allocated_slots_upper=16,bind_stack_backing_requests_upper=2,
            bind_stack_cumulative_requested_bytes_upper=208,
            compound_lvalue_stack_heap_growth=False,
            complete_gimplifier_lifetime_closed=False,
            missing=['Whole-body deep unsharing and declaration/type-field ingress.',
                     'Data-address subtree copies and remaining helper/shared-cache lifetimes; see native_gimplifier_selected_helpers.']),
        conditional_initial_CF_CFG_lifetime_closed=all(checks.values()),
        local_representation_checks=checks,
        shared_metadata_bitmap_ET_pool_and_global_counters_closed=False,
        whole_native_pipeline_capacity_established=False,
        source_argument='docs/research/retained-literal-pipeline.md#initial-cf-eh-cfg-and-root-loop-lifetime')


def native_gimplifier_selected_helpers(c, n):
    """Additional selected sites, not an exhaustive gimplifier allocation bound.

    Reuses the established two-constructor literal ABI and initial GIMPLE
    shape. The data-address subtree and whole-body ingress remain unpriced.
    """
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0,
            'literal gimplifier helper counters')
    requests = [
        dict(object='materialization copied fat and bounds CONSTRUCTOR',
             requests_upper=2*c,raw_bytes_upper=24),
        dict(object='materialization copied constructor element vector',
             requests_upper=2*c,raw_bytes_upper=128,
             logical_elements=2,initial_reserved_elements=4,
             bytes_before_GC_rounding=72),
        dict(object='materialization copied bounds ADDR_EXPR',
             requests_upper=c,raw_bytes_upper=32),
        dict(object='bounds-pool replacement ADDR_EXPR',
             requests_upper=c,raw_bytes_upper=32)]
    return dict(
        source_input=dict(calls=c,nulls=n),
        individual_GGC_request_groups=requests,
        selected_site_GGC_request_events_upper=sum(g['requests_upper'] for g in requests),
        selected_site_additional_DECL_UID_events=0,
        selected_site_additional_TYPE_UID_events=0,
        bounds_address_pointer_type_cache_misses=0,
        bounds_address_fold_convert_replacement_nodes=0,
        selected_GIMPLE_folding=dict(
            call_sites_upper=c,store_sites_upper=2*c,
            generated_matcher_dispatches=0,
            replacement_tree_or_tuple_allocations=0,
            conditional_on_established_initial_GIMPLE_shape=True),
        direct_warning_copy_interface=dict(
            copy_warning_calls_upper=c+1,
            insertion_capable_nowarn_map_calls_upper=c+1,
            incoming_population_and_backing=None,
            backing_requests_priced=False),
        conditional_selected_helper_sites_closed=True,
        whole_body_copy_weight_upper=None,
        data_address_subtree_copy_requests_upper=None,
        complete_gimplifier_GGC_request_events_upper=None,
        complete_gimplifier_lifetime_closed=False,
        obstructions=[
            'post_gigi_declaration_and_type_expression_ingress',
            'retained_data_address_conversion_copy_shape',
            'post_gigi_nowarn_map_population_and_backing',
            'remaining_gimplifier_helper_and_shared_state_exhaustion'],
        source_argument='docs/research/retained-literal-pipeline.md#selected-gimplifier-helpers-and-the-ingress-obstruction')


def native_unshare_protected_set_storage(ingress):
    """Ordinary backing/control lifetime; uses the reviewed C+1 set population."""
    c = ingress['source_input']['calls']
    protected = ingress['protected_set']
    require(protected['distinct_entries_upper']==c+1 and
            protected['backing_requests_upper']==c+2 and
            protected['object_requests_upper']==1 and
            protected['initial_slots']==13 and protected['slot_bytes']==8 and
            protected['deletions']==0,
            'literal unshare protected-set storage interface')
    p = protected['maximum_backing_slots_upper']
    fits = (p is not None and 2*p-3<=2**32-1 and
            max(8*p,4*(c+1),3*p,2*(c+1))<=I64)
    return dict(
        source_input=dict(calls=c,distinct_protected_entries_upper=c+1),
        object_requests_upper=1,object_request_bytes_upper=64,
        backing_requests_upper=c+2,
        maximum_backing_slots_upper=p,
        maximum_backing_request_bytes_upper=None if p is None else 8*p,
        destruction_additional_allocation_requests=0,
        memory_statistics_registration_and_update_requests=0,
        search_collision_counters='unsigned observational; not allocation indexes',
        allocation_domain='ordinary; external allocator internals retain existing trust',
        additional_GGC_request_events_upper=0,
        conditional_protected_set_storage_closed=fits,
        complete_gimplifier_lifetime_closed=False)


def native_main_frontend_attachment(raw, counts, why_counts, context):
    """Attach Main logical/source-visit counts without promoting their scope."""
    frontend=context.frontend['compose'](raw,context.frontend_model)
    projection=context.frontend['source_projection'](raw,context.frontend_model)
    main_counts=projection['Main_counts']
    constructor=context.frontend_model['main_native_construct_vector'](**main_counts)
    gigi=context.frontend_model['native_to_gigi_source_interface'](
        dict(Main_constructor=constructor,
             fixed=dict(node_identities=None,entity_identities=None)),main_counts)
    status=frontend['attachment_status']
    require(set(frontend)=={'scope','selected_source','Main_counts','scanner_pools','lexemes',
                'Main_constructor','gigi_source_interface','local_representation_premises',
                'attachment_status','native_tool_executions'} and
            frontend['selected_source']==counts and
            all(frontend[key]==projection[key] for key in ('Main_counts','scanner_pools','lexemes')) and
            main_counts['word_tokens']==why_counts['W'] and
            main_counts['source_literals']==counts['output_calls'] and
            frontend['Main_constructor']==constructor and
            frontend['gigi_source_interface']==gigi and
            status['Main_constructor_inputs_attached'] is True and
            status['Main_gigi_source_visit_input_attached'] is True and
            status['complete_native_frontend'] is False and
            status['complete_gigi_allocation'] is False and
            status['complete_native_capacity'] is False and
            status['production_admission_changed'] is False and
            frontend['local_representation_premises'][
                'each_literal_length_fits_native_String_Length_and_Integer']==
                    (counts['maximum_literal_length']<=I32) and
            frontend['native_tool_executions']==0,
            'literal native Main frontend interface join')
    return frontend


def evaluate(descriptor_path, context, source_override=None):
    descriptor_path = Path(descriptor_path).resolve()
    descriptor = read(descriptor_path)
    require(set(descriptor) == {'scope','source','shared_inputs','launch','complete_path_bound'},
            'literal descriptor schema')
    require(descriptor['scope'] == 'selected indexed direct literal output research',
            'literal descriptor scope')
    resolve = lambda value:(descriptor_path.parent/value).resolve()
    source_path = Path(source_override).resolve() if source_override else resolve(descriptor['source'])
    raw = source_path.read_bytes()
    counts, why_counts = shared_counts(raw,context)
    frontend=native_main_frontend_attachment(raw,counts,why_counts,context)
    shared = descriptor['shared_inputs']
    expected_roles = {'configuration','System','silver_io.ads','silver_io.adb','silver_output_libc.ads'}
    require(set(shared) == expected_roles, 'shared input roles')
    loaded = {role:resolve(path).read_bytes() for role,path in shared.items()}
    require(loaded['configuration'] == context.configuration, 'indexed naming bytes differ')
    require(identity(loaded['System']) == {k:context.system[k] for k in ('bytes','sha256')},
            'System bytes differ')
    for role in expected_roles-{'configuration','System'}:
        require(loaded[role] == (REPO/'src'/role).read_bytes(), 'Silver library bytes differ: '+role)
    launch = descriptor['launch']
    require(set(launch) == {'native_Main','datarep_Main','phase1_Main','phase2_Main',
                            'native_options','producer_options','library_source_directory'},
            'launch roles')
    main_paths = [launch[phase+'_Main'] for phase in ('native','datarep','phase1','phase2')]
    require(len(set(main_paths)) == 1, 'phases must use one Main launch path')
    require(Path(main_paths[0]).name == 'main.adb', 'indexed Main source basename')
    require(launch['native_options'] == ['-gnatx','-Wno-free-nonheap-object','-fsplit-wide-types'],
            'selected native option delta')
    require(launch['producer_options'] == ['-Wno-free-nonheap-object'],
            'selected producer options')
    paths = [*main_paths,launch['library_source_directory']]
    require(all(isinstance(path,str) and re.fullmatch(r'/[A-Za-z0-9_./~-]+',path)
                and '//' not in path and all(part not in ('.','..') for part in path.split('/'))
                for path in paths), 'absolute normalized launch paths')
    require(all((Path(launch['library_source_directory'])/role).read_bytes() == loaded[role]
                for role in expected_roles-{'configuration','System'}),
            'library launch directory must select the checked source bytes')
    p = descriptor['complete_path_bound']
    require(type(p) is int and p >= 0, 'nonnegative integer path bound')
    native = context.literal['composition'](counts)
    c, n = counts['output_calls'], counts['null_statements']
    rtl = context.rtl['shape'](c,n)
    backing = context.backing['backing'](c,n)
    pools = native_pool_lifetime(c,context)
    graph = native_graph_lifetime(c,n,context)
    ssa_helpers = native_ssa_helper_backing(c,n,context)
    initial_ssa = native_initial_ssa_lifetime(c,n,context)
    initial_cf_cfg = native_initial_cf_cfg_lifetime(c,n,context)
    gimplifier_helpers = native_gimplifier_selected_helpers(c,n)
    ingress = context.ingress['evaluate'](c,n)
    direct = initial_cf_cfg['direct_gimplifier_interface']
    require(ingress['source_input']['calls']==c and ingress['source_input']['nulls']==n and
            ingress['corrected_direct_gimplifier_GGC_events_upper']==direct['direct_site_GGC_request_events_upper'] and
            ingress['corrected_CF_gimple_set_block_calls_upper']==initial_cf_cfg['additional_CF_block_location_requests_upper'] and
            ingress['GENERIC_and_GIMPLE_bind_count_upper']==direct['retained_source_bind_tuples_upper'] and
            ingress['simultaneous_GENERIC_bind_depth_upper']==direct['simultaneous_bind_depth_upper'] and
            ingress['bind_stack']['capacities_upper'][-1]==direct['bind_stack_allocated_slots_upper'] and
            ingress['bind_stack']['maximum_request_bytes_upper']==direct['bind_stack_bytes'] and
            ingress['bind_stack']['requests_upper']==direct['bind_stack_backing_requests_upper'] and
            ingress['bind_stack']['cumulative_request_bytes_upper']==direct['bind_stack_cumulative_requested_bytes_upper'] and
            ingress['CF_local_declarations_vector_elements_upper']==c and
            ingress['direct_copy_warning_calls_upper']==gimplifier_helpers['direct_warning_copy_interface']['copy_warning_calls_upper'] and
            ingress['selected_helper_subtotal_includes_accepted_6C'] and
            ingress['selected_helper_subtotal_GGC_events_upper']==gimplifier_helpers['selected_site_GGC_request_events_upper']+
                ingress['materialization_data_address_delta']['tree_requests_upper'],
            'literal native ingress/direct/helper interface join')
    protected_storage=native_unshare_protected_set_storage(ingress)
    warning=context.warning_residual['evaluate'](c,n)
    warning_transfer=context.warning['evaluate'](c,n,5)['conditional_map_transfer']
    require(warning['C']==c and warning['N']==n and
            warning['direct_warning_copy_calls']==ingress['direct_copy_warning_calls_upper'] and
            warning['additional_call_location_warning_copy_calls']==c and
            warning['selected_initial_gimplifier_warning_put_call_ceiling']==2*c+1 and
            warning['local_gigi_suppression_call_ceiling']==2*c+n and
            warning['other_original_gigi_put_calls']==5 and
            warning['original_gigi_residual_put_call_ceiling']==5 and
            warning['conditional_map_transfer']==warning_transfer and
            warning['original_gigi_source_count_closed'] and
            not warning['complete_gimplifier_lifetime_closed'],
            'literal native warning-map source interface join')
    imported=context.imported_functions
    require(imported['R_put_call_ceiling']==5 and
            imported['R_counts_replacement_puts'] and
            imported['selected_original_gigi_warning_frontier_closed'] and
            imported['helper_initial_warning_map_puts']==0 and
            imported['selected_generated_FUNCTION_DECL_body_frontier_closed'] and
            imported['additional_emitted_functions_from_selected_constructor_frontier']==0 and
            imported['non_Main_function_definition_number_increment']==3 and
            imported['empty_elaboration']['function_structures_allocated']==1 and
            imported['empty_elaboration']['persistent_function_definition_number_increment']==1 and
            imported['empty_elaboration']['symbol_registration_count'] is None and
            imported['empty_elaboration']['allocation_request_events'] is None and
            not imported['complete_imported_frontier_capacity_closed'],
            'literal imported function and warning frontier join')
    require(context.prefix['counters']['ggc_bytes']['largest_increment']==65536 and
            warning['prefix_capacity_ceiling']==4093 and
            max(prime for prime in context.warning['PRIMES'] if 16*prime<=65536)==4093,
            'literal native warning-map prefix capacity join')
    why = context.why['compose'](why_counts,context.schema,context.fixed_counts,context.fixed_modules,p)
    selected_why = context.specialization['evaluate'](raw,context.specialization_context,path_bytes=p)
    require(selected_why['source_counts'] == counts and
            selected_why['Why_source_counts'] == why_counts and
            selected_why['general_core'] == why, 'literal producer specialization join')
    require(why['K'] == c and why['K_literal'] == c, 'literal identity multiplicity join')
    require(native['conditional_native_pass_expand']['first_unused_pseudo_number_upper'] ==
            backing['interface']['pre_split_register_extent'], 'pre-split pseudo join')
    require(rtl['first_unused_pseudo_number_upper'] == backing['interface']['register_extent_upper'],
            'post-split pseudo join')
    require(rtl['first_unused_UID_upper'] == 7*c+7*n+46, 'final instruction UID join')
    require(ssa_helpers['source_input']['SSA_slots_upper'] ==
            native['conditional_O0_out_of_SSA']['SSA_name_vector_length_upper'] and
            ssa_helpers['source_input']['ordinary_GIMPLE_blocks_upper'] ==
            native['conditional_O0_out_of_SSA']['ordinary_blocks_upper'] and
            ssa_helpers['source_input']['ranger_block_slots_upper'] ==
            native['CF_EH_CFG']['block_index_slots_upper']+1 and
            graph['source_input']['post_CFG_statements_upper'] ==
            native['conditional_O0_out_of_SSA']['live_GIMPLE_statements_upper'],
            'literal GIMPLE graph/summary/ranger/out-of-SSA join')
    require(initial_ssa['source_input']['SSA_slots_upper'] ==
            native['initial_SSA']['SSA_name_vector_length_upper'] and
            initial_ssa['initial_SSA_operand_slab_requested_bytes_upper'] ==
            native['initial_SSA']['operand_slab_requested_bytes_upper'], 'literal initial SSA join')
    require(initial_cf_cfg['source_input'] == dict(
        calls=c,nulls=n,ordinary_blocks_upper=native['CF_EH_CFG']['ordinary_blocks_upper'],
        initial_CFG_block_slots_upper=native['CF_EH_CFG']['block_index_slots_upper'],
        initial_edges_upper=native['CF_EH_CFG']['edges_upper'],
        initial_label_UID_requests_upper=native['CF_EH_CFG']['label_UID_requests_upper'],
        post_goto_statements_upper=native['CF_EH_CFG']['live_CFG_statements_upper']),
        'literal initial CF/CFG shape join')
    assembler = context.assembler['evaluate'](raw,context.assembler_context)
    require(assembler['source_identity'] == identity(raw) and
            assembler['counts'] == dict(calls=c,nulls=n,
                decoded_bytes=counts['decoded_literal_bytes'],
                maximum_literal_length=counts['maximum_literal_length']) and
            assembler['final_chain'] == rtl['final_chain'] and
            assembler['text_bytes_upper'] == rtl['shortening_text_bytes_upper'] and
            assembler['GAS']['rodata_bytes_upper'] == native['conditional_native_constant_data'][
                'rodata_payload_including_padding_bytes_upper'], 'literal assembler common-input join')
    # The descriptor bounds path spelling bytes; storage includes the terminal NUL.
    assembler_storage = context.assembler_storage['evaluate'](
        raw,context.assembler_storage_context,path_bytes=p+1)
    require(assembler_storage['interface'] == assembler, 'literal assembler storage interface join')
    linker = context.linker['evaluate'](raw,context.linker_context,path_bytes=p+1)
    require(linker['source_identity'] == identity(raw) and
            linker['counts'] == assembler['counts'] and
            linker['link'] == context.linker['link'](assembler,context.linker_context,4096) and
            linker['assembler_storage_fits'] == assembler_storage['storage']['selected_GAS_BFD_storage_fits'],
            'literal linker common source/text/ELF/storage join')
    # Main ALI takes spelling bytes without NUL, matching the descriptor.
    ali = context.ali['evaluate'](raw,context.ali_context,path_bytes=p)
    physical = context.physical(raw)
    require(ali['source'] == identity(raw) and ali['source_counts'] == counts and
            ali['physical_source'] == physical and ali['path_spelling_bytes_upper'] == p,
            'literal Main ALI common-input join')
    ali_consumers = context.ali_consumers['evaluate'](raw,context.ali_consumers_context,path_bytes=p)
    require(ali_consumers['source'] == identity(raw) and
            ali_consumers['source_counts'] == counts and
            ali_consumers['path_spelling_bytes_upper'] == p and
            ali_consumers['Main_ALI_interface'] == ali, 'literal ALI consumer interface join')
    gpr_parent = context.gpr_parent['evaluate'](raw,context.gpr_parent_context,path_bytes=p)
    require(gpr_parent['source'] == identity(raw) and
            gpr_parent['source_counts'] == counts and
            gpr_parent['path_spelling_bytes_upper'] == p and
            gpr_parent['Main_ALI_interface'] == ali, 'literal GPR parent DW interface join')
    line_capacity = 500
    while line_capacity < physical['physical_line_entries_bound']:
        line_capacity *= 2
    conditions = dict(
        shared_launch_paths=max(map(len,paths)) <= p,
        Main_source_EOF=len(raw)+1 <= I32,
        Main_source_request=len(raw)+17 <= I64,
        Main_line_table=32*line_capacity <= I32,
        Main_expanded_columns=physical['max_expanded_final_column'] <= 32766,
        native_Main_logical_lines=physical['physical_line_entries_bound'] <= 2**24,
        native_Main_frontend_literal_length=frontend['local_representation_premises'][
            'each_literal_length_fits_native_String_Length_and_Integer'],
        native_lowering_and_data=all(native['local_representation_checks'].values()),
        native_RTL_shape=all(rtl['local_representation_checks'].values()),
        native_selected_helper_backing=all(backing['local_representation_checks'].values()),
        native_varpool_and_shared_tree_pool=pools['conditional_arithmetic_fits'],
        native_graph_and_summary_lifetime=graph['conditional_arithmetic_fits'],
        native_SSA_helper_backing=ssa_helpers['conditional_SSA_helper_backing_closed'],
        native_initial_SSA_lifetime=initial_ssa['conditional_initial_SSA_lifetime_closed'],
        native_initial_CF_CFG_lifetime=initial_cf_cfg['conditional_initial_CF_CFG_lifetime_closed'],
        native_whole_body_copy_local_interface=(counts['maximum_literal_length']<=ingress['source_input']['each_literal_length_max'] and
            ingress['conditional_whole_body_ingress_closed'] and
            protected_storage['conditional_protected_set_storage_closed']),
        native_initial_warning_map_lifetime=warning_transfer['conditional_map_interface_fits'],
        Main_assembler_object_interface=assembler['local_interface_fits'],
        Main_GAS_BFD_storage=assembler_storage['storage']['selected_GAS_BFD_storage_fits'],
        literal_output_linker_representation=linker['selected_literal_assembler_and_linker_representation_fits'],
        Main_ALI_interface=ali['selected_Main_ALI_interface_fits'],
        ALI_consumer_local_interfaces=ali_consumers['selected_ALI_consumer_local_interfaces_fit'],
        GPR_parent_DW_local_interface=gpr_parent['selected_parent_DW_reader_local_interface_fits'],
        Why_core=selected_why['literal_Main_core_fits'],
        output_binder_checksum_no_collection=context.checksum[
            'universal_rounded_GGC_bytes_bound_subject_to_reviewed_source_projection']
            < context.checksum['first_collection_threshold'])
    # #131: Main's constant literal extents do not exclude helper construction
    # from imported String's placeholder-based layout. Preserve the arithmetic
    # only as conditional data; None is unknown, not a failed capacity test.
    conditional_conditions=conditions.copy()
    unit_dependent=('native_varpool_and_shared_tree_pool',
        'native_graph_and_summary_lifetime','Main_assembler_object_interface',
        'Main_GAS_BFD_storage','literal_output_linker_representation')
    for key in unit_dependent:
        conditions[key]=None
    frontier=dict(imported_constructor_frontier_established=False,
        Main_is_only_defined_body_established=False,
        Main_is_only_emitted_body_established=True,
        additional_imported_pool_symbol_events_upper=None,
        additional_imported_defined_bodies_upper=None,
        additional_emitted_stream_interface=None,
        cold_String_layout=native_cold_string_interface(context),
        selected_generated_function_frontier=imported,
        affected_predicates=list(unit_dependent),
        missing='The selected generated-body frontier and zero extra emitted functions are established, with two cold String helper graph/symbol increments joined. Complete synthetic-function and original imported allocation totals, empty-elaboration registration and counter-to-emission joins; absent emission does not erase these costs.',
        finding='https://github.com/berkeleynerd/silver/issues/131')
    # These fields deliberately name the actual unclosed consumers. A partial
    # helper count is never substituted for the null family's lifetime total.
    opens = {
        'native_post_prefix_imported_frontier':frontier,
        'native_remaining_lifetime_and_collector': {
            'next_consumer':'original frontend/gigi constructors and remaining gimplifier helper lifetimes, then remaining pass, shared-pool and GGC collector composition.',
            'available':dict(conditional_graph_scan_count_upper=4,conditional_call_edge_creation_events_upper=4*c,
                             Main_frontend_node_identities_upper=frontend['Main_constructor']['total']['node_identities'],
                             Main_frontend_entity_identities_upper=frontend['Main_constructor']['total']['entity_identities'],
                             Main_gigi_source_syntax_visits_upper=frontend['gigi_source_interface']['Main_source_syntax_visit_bound'],
                             conditional_pool_lifecycle_GGC_events_upper=pools['additional_GGC_request_events_upper'],
                             conditional_graph_lifecycle_GGC_events_upper=graph['additional_GGC_request_events_upper'],
                             ranger_and_out_of_SSA_backing_closed=ssa_helpers['conditional_SSA_helper_backing_closed'],
                             initial_SSA_GGC_events_upper=initial_ssa['additional_GGC_request_events_upper'],
                             initial_CF_CFG_GGC_events_upper=initial_cf_cfg['additional_GGC_request_events_upper'],
                             direct_gimplifier_GGC_events_upper=initial_cf_cfg['direct_gimplifier_interface']['direct_site_GGC_request_events_upper'],
                             whole_body_copy_GGC_events_upper=ingress['whole_body_GGC_request_events_upper'],
                             selected_gimplifier_helper_GGC_events_upper=ingress['selected_helper_subtotal_GGC_events_upper'],
                             selected_gimplifier_warning_put_calls_upper=warning['selected_initial_gimplifier_warning_put_call_ceiling'],
                             local_original_gigi_warning_suppressions_upper=warning['local_gigi_suppression_call_ceiling'],
                             remaining_original_gigi_warning_put_calls=5,
                             initial_warning_map_GGC_events_upper=warning_transfer['additive_GGC_event_ceiling']),
            'missing':'Fixed/configuration/frontend physical and late-heap joins, imported gigi type graph and per-kind/helper construction, and remaining helper lifetimes. Original-gigi R<=5 and initial Main warning-map requests are joined; later warning consumers remain separate. Concrete Main constructor and source-syntax visits are not helper/GGC events. Whole-body metadata ingress, data-address copies and possible call binds are joined; no complete gimplifier sum is supplied. Remaining passes, RTL/DF ceilings, identifier/CONST_INT/reg-attribute backing, metadata/Ada callbacks and complete global event/UID/collector bounds remain open. The null 40098 allowance is not reused.'},
        'Main_assembler_and_object': {
            'available':dict(assembly_stream=assembler['assembly'],GAS_interface=assembler['GAS'],
                             ELF_interface=assembler['ELF'],
                             GAS_BFD_storage=assembler_storage['storage'],
                             local_interface_fits=assembler['local_interface_fits']),
            'missing':'Complete production-invocation/materialization and counter-to-emitted-stream joins (#131). No additional imported function is emitted, but surviving counters must still be joined to label spelling and complete stream arithmetic.'},
        'producer_frontends_and_consumers': {
            'missing':'Output-family native/datarep/light frontend and parent ALI/report/flow joins plus required Why/report/server consumers. The null fixed-table and zero-client projections are not assumed for repeated output.'},
        'binder_and_linker_composition': {
            'available':dict(selected_Main_ALI_interface_fits=ali['selected_Main_ALI_interface_fits'],
                Main_ALI_reader_bytes_including_EOF_upper=ali['Main_ALI_reader_bytes_including_EOF_upper'],
                selected_ALI_consumer_local_interfaces_fit=ali_consumers['selected_ALI_consumer_local_interfaces_fit'],
                selected_parent_DW_reader_local_interface_fits=gpr_parent['selected_parent_DW_reader_local_interface_fits'],
                selected_literal_assembler_and_linker_representation_fits=linker['selected_literal_assembler_and_linker_representation_fits'],
                failed_linker_sufficient_checks=linker['link']['failed_sufficient_checks']),
            'missing':'Complete native and GPR shared name-pool backing, invocation/library graph containers, parent source/project/driver routes, fixed-child ALI regeneration correspondence and output launch. Main/fixed ALI local parser tables/buffers, Gprbind A/U-only and native parent GPRbuild D/W local interfaces are attached with explicit additive name contracts; selected ELF/link and checksum interfaces remain joined.'},
        'complete_output_launch_materialization': {
            'missing':'Bind complete output-family project/options/map/search graph and fixed dependency compiler/producer subprocesses. This descriptor binds common bytes and selected roles, not that entire frontier.'}}
    return dict(scope=descriptor['scope'],source=identity(raw),source_path=str(source_path),
        actual_shared_inputs={role:identity(data) for role,data in loaded.items()},
        launch=launch,complete_path_bound=p,
        source_counts=counts,Why_source_counts=why_counts,
        physical_Main=physical,conditions=conditions,
        conditional_conditions=conditional_conditions,
        conditional_arithmetic_pass=all(conditional_conditions.values()),
        failed_conditional_predicates=[key for key,value in conditional_conditions.items() if not value],
        evaluated_predicates_pass=all(value is True for value in conditions.values()),
        failed_predicates=[key for key,value in conditions.items() if value is False],
        unresolved_predicates=[key for key,value in conditions.items() if value is None],
        native_unit_frontier=frontier,
        native_lowering_data=native,RTL_shape=rtl,selected_native_backing=backing,
        native_pool_lifetime=pools,native_graph_lifetime=graph,native_SSA_helper_backing=ssa_helpers,
        native_initial_SSA_lifetime=initial_ssa,
        native_initial_CF_CFG_lifetime=initial_cf_cfg,
        native_gimplifier_selected_helpers=gimplifier_helpers,
        native_gimplifier_ingress=ingress,
        native_unshare_protected_set_storage=protected_storage,
        native_warning_map_demand=warning,
        native_Main_frontend_interface=frontend,
        Main_assembler_object_interface=assembler,
        Main_GAS_BFD_storage=assembler_storage['storage'],
        literal_output_linker=linker,linker_path_bytes_including_NUL_upper=p+1,
        Main_ALI_interface=ali,
        ALI_consumer_interfaces=ali_consumers,
        native_GPR_parent_DW_interface=gpr_parent,
        Why_core=why,selected_Why_core=selected_why,
        accepted_output_binder_checksum=context.checksum,
        open_joins=opens,whole_literal_pipeline_capacity_established=False,
        next_repair='native_remaining_lifetime_and_collector',
        fixed_input_count=context.inputs_verified,external_source_files_verified=context.source_files_verified,
        native_Main_frontend_nested_validation=context.frontend_verification,
        native_tool_executions=0,production_admission_changed=False,aggregate_RAM_gate=False,
        conditional_premises=['Relevant installed behavior matches the reviewed source.',
            'The selected O0, Linux x86-64, no-debug, small-PIC, ordinary PLT descriptor and unchanged Silver library semantics apply.',
            'Native lowering formulas retain their separate whole-unit Main-preservation premise.',
            'Physical resources and ordinary external OS/libc services remain separate.'])


def arguments(parser):
    parser.add_argument('--gcc-root',type=Path,required=True)
    parser.add_argument('--ada-root',type=Path,required=True)
    parser.add_argument('--plugin-include',type=Path,required=True)
    parser.add_argument('--gcc-match',type=Path,
                        help='Pinned match.pd; defaults to the retained ingress manifest path')


def main():
    started=datetime.now(timezone.utc).isoformat()
    timer=time.perf_counter()
    parser=argparse.ArgumentParser(description=__doc__)
    arguments(parser)
    parser.add_argument('--descriptor',type=Path,default=HERE/'fixture.json')
    parser.add_argument('--source',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    result=evaluate(args.descriptor,Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),args.source)
    result['offline_run']=dict(started_utc=started,
        completed_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({key:result[key] for key in ('evaluated_predicates_pass',
        'whole_literal_pipeline_capacity_established','next_repair','native_tool_executions')}))


if __name__=='__main__':
    main()

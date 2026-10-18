#!/usr/bin/env python3
"""Offline literal-output aggregate with explicit, source-named open joins.

One complete source scan drives the established native and Why formulas.
Passing their arithmetic is not a whole-pipeline capacity verdict.
"""
import argparse
import contextlib
import hashlib
import io
import json
from pathlib import Path
import re
import runpy
import sys
import tempfile

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
    def __init__(self, gcc_root, ada_root, plugin_include):
        pins = read(HERE/'inputs.json')
        for row in pins:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {key:row[key] for key in ('bytes','sha256')},
                    'changed aggregate input: '+row['path'])
        self.inputs_verified = len(pins)
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
        self.source_files_verified = len(checked)
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


def native_pool_lifetime(c, context):
    """Source-derived symbol/pool join; excludes the remaining pass/GC join.

    A request group represents individual requests, never a sum-RAM gate.
    The fixed prefix is an incoming population ceiling, not null's lifetime.
    """
    require(type(c) is int and c >= 1, 'positive literal call count')
    d_in = context.pool_seed
    tree_live = d_in + 2*c
    asm_live = c + 3  # Main, at most two imported callees, bounds; no dummy.

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
        symbol_uid_and_order=c+5 <= I32,
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
                     bounds_nodes_upper=c,registered_nodes_upper=c+4,
                     next_uid_upper=c+5,order_upper=c+4,
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
        named_consumer_closed=all(checks.values()),
        whole_native_pipeline_capacity_established=False,
        source_argument='docs/research/retained-literal-pipeline.md#bounds-pool-and-symbol-lifetime-join')


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
    why = context.why['compose'](why_counts,context.schema,context.fixed_counts,context.fixed_modules,p)
    require(why['K'] == c and why['K_literal'] == c, 'literal identity multiplicity join')
    require(native['conditional_native_pass_expand']['first_unused_pseudo_number_upper'] ==
            backing['interface']['pre_split_register_extent'], 'pre-split pseudo join')
    require(rtl['first_unused_pseudo_number_upper'] == backing['interface']['register_extent_upper'],
            'post-split pseudo join')
    require(rtl['first_unused_UID_upper'] == 7*c+7*n+46, 'final instruction UID join')
    physical = context.physical(raw)
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
        native_lowering_and_data=all(native['local_representation_checks'].values()),
        native_RTL_shape=all(rtl['local_representation_checks'].values()),
        native_selected_helper_backing=all(backing['local_representation_checks'].values()),
        native_varpool_and_shared_tree_pool=pools['named_consumer_closed'],
        Why_core=why['producer_core_fits'],
        output_binder_checksum_no_collection=context.checksum[
            'universal_rounded_GGC_bytes_bound_subject_to_reviewed_source_projection']
            < context.checksum['first_collection_threshold'])
    # These fields deliberately name the actual unclosed consumers. A partial
    # helper count is never substituted for the null family's lifetime total.
    opens = {
        'native_remaining_lifetime_and_collector': {
            'next_consumer':'cgraph_node::create_edge -> symbol_table::create_edge (cgraph.cc); up to 4C creations across the selected graph scans, plus live call summaries and IPA hooks.',
            'available':dict(graph_scan_count_upper=4,call_edge_creation_events_upper=4*c,
                             new_pool_lifecycle_GGC_events_upper=pools['additional_GGC_request_events_upper']),
            'missing':'Join call-edge allocation/reuse/UIDs and variable IPA summaries with fixed symbol constructors, existing GIMPLE/RTL/DF ceilings, identifier/CONST_INT/reg-attribute shared backing, Ada callbacks and complete GGC event/UID/collector bounds. The null 40098 allowance is not reused.'},
        'Main_assembler_and_object': {
            'available':dict(instruction_lines=rtl['instruction_text_lines_upper'],
                             text_bytes=rtl['shortening_text_bytes_upper'],
                             rodata_bytes=native['conditional_native_constant_data']['rodata_payload_including_padding_bytes_upper']),
            'missing':'Complete directives/labels/CFI stream, GAS allocation/counter transfer and source-derived ELF symbols/sections/relocations; instruction and data bounds alone are not that interface.'},
        'producer_frontends_and_consumers': {
            'missing':'Output-family native/datarep/light frontend and parent ALI/report/flow joins plus required Why/report/server consumers. The null fixed-table and zero-client projections are not assumed for repeated output.'},
        'binder_and_linker_composition': {
            'missing':'Compose variable Main ALI/invocation graphs, the now-accepted checksum lifetime bounds, output fixed-object delta and variable Main ELF/link interface under one complete output launch descriptor; checksum variation itself is closed.'},
        'complete_output_launch_materialization': {
            'missing':'Bind complete output-family project/options/map/search graph and fixed dependency compiler/producer subprocesses. This descriptor binds common bytes and selected roles, not that entire frontier.'}}
    return dict(scope=descriptor['scope'],source=identity(raw),source_path=str(source_path),
        actual_shared_inputs={role:identity(data) for role,data in loaded.items()},
        launch=launch,complete_path_bound=p,
        source_counts=counts,Why_source_counts=why_counts,
        physical_Main=physical,conditions=conditions,
        evaluated_predicates_pass=all(conditions.values()),
        failed_predicates=[key for key,value in conditions.items() if not value],
        native_lowering_data=native,RTL_shape=rtl,selected_native_backing=backing,
        native_pool_lifetime=pools,Why_core=why,
        accepted_output_binder_checksum=context.checksum,
        open_joins=opens,whole_literal_pipeline_capacity_established=False,
        next_repair='native_remaining_lifetime_and_collector',
        fixed_input_count=context.inputs_verified,external_source_files_verified=context.source_files_verified,
        native_tool_executions=0,production_admission_changed=False,aggregate_RAM_gate=False,
        conditional_premises=['Relevant installed behavior matches the reviewed source.',
            'The selected O0, Linux x86-64, no-debug, small-PIC, ordinary PLT descriptor and unchanged Silver library semantics apply.',
            'Native lowering formulas retain their separate whole-unit Main-preservation premise.',
            'Physical resources and ordinary external OS/libc services remain separate.'])


def arguments(parser):
    parser.add_argument('--gcc-root',type=Path,required=True)
    parser.add_argument('--ada-root',type=Path,required=True)
    parser.add_argument('--plugin-include',type=Path,required=True)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    arguments(parser)
    parser.add_argument('--descriptor',type=Path,default=HERE/'fixture.json')
    parser.add_argument('--source',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    result=evaluate(args.descriptor,Context(args.gcc_root,args.ada_root,args.plugin_include),args.source)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({key:result[key] for key in ('evaluated_predicates_pass',
        'whole_literal_pipeline_capacity_established','next_repair','native_tool_executions')}))


if __name__=='__main__':
    main()

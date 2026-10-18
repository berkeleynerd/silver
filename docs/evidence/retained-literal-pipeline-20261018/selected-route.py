#!/usr/bin/env python3
"""Attach accepted native invocation and Ada numeric leaves to unchanged core.

Offline design research. Fixed path classes, no materialization/native jobs.
All local arithmetic predicates remain conjunctive; total capacity stays open.
"""
import argparse
import copy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import runpy
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
CLOSED = ('Main_assembler_object_interface', 'Main_GAS_BFD_storage',
          'literal_output_linker_representation')


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(value, message):
    if not value:
        raise ValueError(message)


class Context:
    def __init__(self, gcc_root, ada_root, plugin_include, gcc_match=None):
        self.core = runpy.run_path(str(HERE/'compose.py'))
        manifest = read(HERE/'selected-route-inputs.json')
        for row in manifest['files']:
            raw = (REPO/row['path']).read_bytes()
            require(identity(raw) == {k:row[k] for k in ('bytes','sha256')},
                    'selected route current input: '+row['path'])
        for row in manifest['reviews']:
            raw = self.core['read_historical_repository_file'](row['revision'], row['path'])
            require(identity(raw) == {k:row[k] for k in ('bytes','sha256')} and
                    raw == (REPO/row['path']).read_bytes(), 'selected route accepted review: '+row['path'])
        self.core_context = self.core['Context'](gcc_root, ada_root, plugin_include, gcc_match)
        self.invocation = runpy.run_path(str(E/'retained-literal-invocation-join-20261018/compose.py'))
        self.invocation_context = self.invocation['Context']()
        self.numeric = runpy.run_path(str(E/'retained-literal-ada-numeric-20261018/compose.py'))
        self.numeric_context = self.numeric['Context'](ada_root, gcc_root)
        self.validation = dict(current_attachment_input_records=len(manifest['files']),
            historical_acceptance_review_records=len(manifest['reviews']),
            core_current_input_records=self.core_context.inputs_verified,
            core_distinct_current_files=self.core_context.source_files_verified,
            invocation_current_repository_records=self.invocation_context.input_count,
            invocation_complete_retained_sources=len(self.invocation_context.sources),
            invocation_installed_configuration_records=len(self.invocation_context.installed_inputs),
            numeric_identity_records=len(self.numeric_context.identity['files']),
            counts_overlap_and_must_not_be_added=True,
            accepted_reviews=manifest['reviews'])


def join_invocation(raw, core, invocation, context):
    """Correspondence equalities, never require passing arithmetic predicates."""
    counts, p = core['source_counts'], core['complete_path_bound']
    require(core['source'] == invocation['source_identity'] == identity(raw) and
            invocation['source_counts'] == counts, 'invocation source/count join')
    require(invocation['path_bytes'] == p+1 and invocation['host_page_bytes'] == 4096,
            'invocation path spelling/NUL and page join')
    graph = invocation['graph']
    for phase in ('native','datarep','phase1','phase2'):
        require(invocation['common_Main_bindings'][phase] ==
                dict(path=core['launch'][phase+'_Main'], identity=core['source']) and
                core['launch'][phase+'_Main'] == graph['Main'], 'invocation common Main path join')
    files = {row['role']:row for row in invocation['materialization']}
    require(files['Main']['identity'] == core['source'] and files['Main']['path'] == graph['Main'],
            'invocation Main materialization join')
    for role in ('silver_io.ads','silver_io.adb','silver_output_libc.ads'):
        require(files[role]['identity'] == core['actual_shared_inputs'][role] and
                files[role]['path'] == graph['project_root']+'/'+role,
                'invocation fixed source join: '+role)
    require(files['naming']['identity'] == core['actual_shared_inputs']['configuration'] and
            identity(files['naming']['text'].encode()) == core['actual_shared_inputs']['configuration'] and
            files['naming']['path'] == graph['native']['configuration'] and
            invocation['shared_System']['identity'] == core['actual_shared_inputs']['System'],
            'invocation configuration/System join')
    artifacts = context.core_context.linker_context.records['delta_manifest']['artifacts']['members']
    for role in ('silver_io.o','silver_output_libc.o'):
        expected = next(row for row in artifacts if row['path'] == 'indexed/obj/'+role)
        require(files[role]['identity'] == {k:expected[k] for k in ('bytes','sha256')} and
                files[role]['path'] == graph['native']['cwd']+'/'+role,
                'invocation fixed object/linker input join: '+role)
    for role in ('silver_io.ali','silver_output_libc.ali'):
        require(files[role]['identity'] == identity(context.invocation_context.fixed_alis[role]) and
                files[role]['path'] == graph['native']['cwd']+'/'+role,
                'invocation fixed ALI input join: '+role)
    require(invocation['emission_interface'] == core['native_complete_emission_interface'],
            'invocation exact emission join')
    assembly = context.invocation_context.link_context.asm['evaluate'](
        raw, context.invocation_context.link_context.asm_context, path_bytes=p+1)
    require(assembly['interface'] == core['Main_assembler_object_interface'] and
            assembly['storage'] == core['Main_GAS_BFD_storage'],
            'invocation exact assembly/ELF/storage join')
    require(invocation['link_interface'] == core['literal_output_linker_historical_conservative'],
            'invocation conservative linker input join')
    refined, refinement = context.core['attach_relocation_refinement'](
        invocation['link_interface'], context.core_context)
    require(refined == core['literal_output_linker'] and
            refinement == core['literal_output_linker_refinement'] and
            len(refinement['unchanged_other_checks']) == 39,
            'invocation refined linker output join')
    family, checksum = invocation['binder_object_family'], core['accepted_output_binder_checksum']
    bound = context.invocation_context.binder_options['object']
    expected_family = {k:bound['after'][k] for k in ('section_count','symbol_count','relocation_count',
        'maximum_section_alignment','eh_frame_bytes','text_bytes','allocated_bytes')}
    expected_family['file_bytes_upper'] = bound['before']['file']['bytes']
    require(family['interface'] == expected_family and family['identity_is_variable'] and
            not family['equals_captured_fixture'] and family['checksum_domain'] == [0,2**32-1] and
            family['checksum_source'] == graph['native_Main_ALI']+': U main%b version' and
            family['GGC_rounded_bytes_upper'] == checksum[
                'universal_rounded_GGC_bytes_bound_subject_to_reviewed_source_projection'] and
            family['GGC_events_upper'] == checksum['allocation_event_bound'] and
            family['GGC_largest_rounded_request'] == checksum['maximum_rounded_request_bound'],
            'invocation binder family join')
    require(invocation['compile_jobs'] == ['Main','binder'] and
            invocation['fixed_Silver_compile_jobs'] == invocation['GPR_or_Gprbind_jobs'] == 0 and
            not invocation['regenerate_fixed_children_selected'] and
            [row['role'] for row in invocation['processes']] ==
                ['Main_compile','binder_generate','binder_compile','link'] and
            not invocation['production_launcher_adopted'] and
            not invocation['complete_parent_storage_or_fixed_child_regeneration_closed'] and
            not invocation['proof_library_verification_waived'], 'selected native job/scope join')
    return dict(actual_source_and_common_paths=True, configuration_System_and_fixed_sources=True,
        complete_emission_and_exact_assembly_ELF_storage=True,
        conservative_linker_input_and_refined_output=True, binder_checksum_object_family=True,
        selected_fixed_native_bundle_and_four_job_graph=True,
        complete_path_spelling_bytes_upper=p, complete_path_bytes_including_NUL_upper=p+1,
        core_library_source_directory_role='checked input origin; native copied sources use graph project_root',
        complete_materializing_parent_storage_closed=False, producer_proof_graph_closed=False,
        fixed_library_proofs_required=True)


def join_numeric(raw, core, numeric, context):
    counts = core['source_counts']; c, n = counts['output_calls'], counts['null_statements']
    require(numeric['source'] == dict(**identity(raw), output_calls=c, null_statements=n),
            'numeric actual source/count join')
    front = context.numeric_context.front['compose'](raw, context.numeric_context.model)
    require(front == core['native_Main_frontend_interface'], 'numeric exact frontend join')
    original = core['native_original_Main_storage']; d = sum(counts[k] > 0 for k in ('Put','Put_Line'))
    require(context.numeric_context.original['evaluate'](counts['decoded_literal_lengths'], N=n, D=d,
                implicit_with_visits=original['fixed_context_I']) == original['interface'],
            'numeric original Main source projection join')
    demand = original['shared_container_demands']; rows = numeric['demand_rows']
    require(rows['selected_scanner'] == dict(Uints=front['scanner_pools']['Uint_entries'],
                Udigits=front['scanner_pools']['Uint_digits'], Ureals=0, Rep_Table=0) and
            rows['Main_constructor'] == dict(Uints=front['Main_constructor']['total']['uint'],
                Udigits=front['Main_constructor']['total']['retained_digit_words'], Ureals=0, Rep_Table=0) and
            rows['original_Main_constant_size_callbacks'] == dict(Uints=demand['Uint_entries'],
                Udigits=demand['Udigits_words'], Ureals=0, Rep_Table=0) and
            numeric['UI_Ints']['original_Main_wrapper_calls'] == demand['UI_Ints_wrapper_calls'] and
            numeric['demands'] == dict(Uints=28420+9*c, Udigits=107726+71*c, Ureals=67, Rep_Table=504),
            'numeric demand ownership join')
    require(numeric['selected_callback_arguments_joined'] and
            not numeric['complete_native_frontend'] and not numeric['complete_original_gigi'] and
            not numeric['complete_native_capacity'] and not numeric['UI_Ints']['aggregate_heap_gate'],
            'numeric selected interval scope join')
    return dict(frontend_and_original_Main_projections_equal=True,
        scope='fixed all-roots lifetime allowance + selected literal frontend + fixed float and original constant-size callbacks',
        ownership='numeric table/backing interval only; existing GCC partial event ledger unchanged; no byte/event sum across them',
        historical_shared_Ada_unknowns='core_result shared leaf describes its earlier interface; this numeric attachment supplies the selected numeric interval only',
        complete_native_frontend=False, complete_original_gigi=False, complete_native_capacity=False)


def attach(raw, core, invocation, numeric, context):
    route_join = join_invocation(raw, core, invocation, context)
    numeric_join = join_numeric(raw, core, numeric, context)
    conditions, conditional = core['conditions'].copy(), core['conditional_conditions'].copy()
    require(set(core['unresolved_predicates']) == set(CLOSED), 'three core source-family gaps')
    assessments = copy.deepcopy(core['native_unit_frontier']['source_family_condition_assessments'])
    for key in CLOSED:
        require(conditions[key] is None, 'core invocation predicate scope')
        conditions[key] = conditional[key]
        assessments[key] = dict(source_family_premises_closed=True,
            selected_design_invocation_joined=True, production_launcher_adopted=False,
            closed='Same actual source, emission, assembly/ELF/storage and refined linker inputs are bound to the reviewed selected native graph and fixed-input/binder family.',
            residual=None,
            scope='Selected design route under checked configuration and correspondence premises. Its arithmetic guard remains independently conjunctive; complete parent storage and producer/proof jobs remain open.')
    graph_guards = {key:invocation[key] for key in (
        'selected_native_launch_graph_computable','selected_main_emission_to_GAS_object_route_bound',
        'selected_fixed_link_input_materialization_computable')}
    for key,value in graph_guards.items():
        conditions['native_invocation_'+key] = conditional['native_invocation_'+key] = value
    for key,value in numeric['checks'].items():
        conditions['native_Ada_numeric_'+key] = conditional['native_Ada_numeric_'+key] = value
    return dict(scope='selected literal native design route and numeric attachment; incomplete whole pipeline',
        source=core['source'], source_path=core['source_path'], source_counts=core['source_counts'],
        actual_shared_inputs=core['actual_shared_inputs'], launch=core['launch'],
        complete_path_bound=core['complete_path_bound'], conditions=conditions, conditional_conditions=conditional,
        conditional_arithmetic_pass=all(conditional.values()),
        failed_conditional_predicates=[k for k,v in conditional.items() if not v],
        evaluated_predicates_pass=all(v is True for v in conditions.values()),
        failed_predicates=[k for k,v in conditions.items() if v is False],
        unresolved_predicates=[k for k,v in conditions.items() if v is None],
        source_family_condition_assessments=assessments,
        core_result=core,
        core_result_scope='Unmodified core evaluated on the selected descriptor before invocation/numeric attachment. Its predicates, open_joins and nested shared diagnostics are intermediate historical-in-derivation diagnostics, not the selected verdict. All original local capacity guards are retained above.',
        selected_native_invocation=invocation,
        invocation_result_scope='Unmodified accepted leaf; its remaining aggregate-integration item is discharged by invocation_join. Its conservative linker arithmetic remains diagnostic; core_result.literal_output_linker is the joined reviewed refinement.',
        invocation_join=route_join, native_Ada_numeric=numeric, numeric_join=numeric_join,
        selected_current_linker_result='core_result.literal_output_linker',
        selected_current_GGC_partial_ledger='core_result.native_original_shared_storage.partial_ledger',
        accounting='No invocation/numeric rows are added to the GCC partial ledger. Repeated component projections are correspondence checks, not additive costs.',
        open_joins=dict(
            native_remaining_lifetime_and_collector='Other metadata/physical/late heaps, later shared/warning consumers, remaining passes, RTL/DF ceilings and complete global event/UID/collector lifetimes. Numeric selected interval is attached; no complete original or native total follows.',
            native_materializing_parent_storage='Complete selected parent source/map/project/driver/library graph storage and shared name pools remain open. Fixed Silver compile regeneration is not a job on this graph.',
            producer_frontends_and_consumers='Complete datarep/light frontend, producer launch, fixed Silver library proof jobs, report/flow/Why/server consumers and final reports remain open. Common Main path binding does not supply their argv graph.',
            production_adoption='Selected design graph is computable but no production launcher is adopted.'),
        whole_literal_pipeline_capacity_established=False, complete_native_capacity=False,
        complete_proof_pipeline_capacity=False, complete_parent_storage_closed=False,
        complete_imported_allocation_events=None, complete_imported_allocation_bytes=None,
        production_launcher_adopted=False, production_admission_changed=False, aggregate_RAM_gate=False,
        native_tool_executions=0, validation=context.validation,
        conditional_premises=core['conditional_premises']+[
            'Selected cwd has 109 ASCII spelling bytes and temporary root has 48; descriptor fixes P=512 spelling bytes and 4096-byte host pages.',
            'Fresh owned directories, listed fixed source/object/ALI identities, coherent required timestamps and complete selected environments are materialization configuration premises.',
            'Checked filesystem inputs remain stable through materialization and use; ordinary external resources/services remain assumptions.'])


def evaluate(descriptor_path, context, source_override=None):
    descriptor_path = Path(descriptor_path).resolve(); descriptor = read(descriptor_path)
    require(set(descriptor) == {'scope','core_descriptor','runtime','host_page_bytes'} and
            descriptor['scope'] == 'selected literal invocation and numeric design route', 'selected route descriptor schema')
    core_path = (descriptor_path.parent/descriptor['core_descriptor']).resolve()
    core_descriptor = read(core_path)
    require(core_descriptor['complete_path_bound'] == 512 and descriptor['host_page_bytes'] == 4096,
            'selected route fixed path/page class')
    source_path = Path(source_override).resolve() if source_override else (core_path.parent/core_descriptor['source']).resolve()
    raw = source_path.read_bytes()
    core = context.core['evaluate'](core_path, context.core_context, source_path)
    invocation = context.invocation['build'](raw, context.invocation_context, descriptor['runtime'],
        path_bytes=core['complete_path_bound']+1, host_page_bytes=descriptor['host_page_bytes'])
    numeric = context.numeric['compose'](raw, context.numeric_context)
    return attach(raw, core, invocation, numeric, context)


if __name__ == '__main__':
    start=datetime.now(timezone.utc).isoformat(); timer=time.perf_counter()
    parser=argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(HERE/'compose.py'))['arguments'](parser)
    parser.add_argument('--descriptor',type=Path,default=HERE/'selected-route.json')
    parser.add_argument('--source',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    result=evaluate(args.descriptor,Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),args.source)
    result['offline_run']=dict(started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('evaluated_predicates_pass','unresolved_predicates','whole_literal_pipeline_capacity_established')}))

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
import re
import runpy
import time
from types import SimpleNamespace

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
        self.frontend = runpy.run_path(str(E/'retained-literal-frontend-storage-20261018/compose.py'))
        self.location = runpy.run_path(str(E/'retained-literal-location-lifetime-20261018/derive.py'))
        self.location_context = self.location['Context'](gcc_root, ada_root)
        roots = dict(repository=REPO, ada=Path(ada_root), plugin=Path(plugin_include))
        frontend_pins = read(E/'retained-literal-frontend-storage-20261018/inputs.json')
        for row in frontend_pins['files']+manifest['native_shape_inputs']:
            require(identity((roots[row['root']]/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')}, 'frontend/ABI input: '+row['path'])
        retained_runtime = read(E/'retained-literal-frontend-storage-20261018/result.json')['components']['physical_sources']['runtime']
        def reuse_runtime(directory):
            require(str(directory) == retained_runtime['directory'], 'same retained verified runtime census')
            return copy.deepcopy(retained_runtime)
        prior = E/'unbounded-programs/retained-native-expansion-20261017'
        self.frontend_context = SimpleNamespace(ada=Path(ada_root), numeric=self.numeric,
            numeric_context=self.numeric_context, front=self.numeric_context.front, model=self.numeric_context.model,
            invocation=self.invocation, invocation_context=self.invocation_context,
            indexed=read(prior/'native-indexed-invocation.json')['indexed_configuration_delta'],
            indexed_physical=read(prior/'native-indexed-source-buffers.json'), runtime_inventory=reuse_runtime)
        self.virtual_template_lines = {}
        for name in ('a-unccon.ads','s-imagei.ads','s-imagei.adb'):
            raw=(Path(ada_root)/'libgnat'/name).read_bytes()
            require(raw == (Path(retained_runtime['directory'])/name).read_bytes(), 'virtual template/runtime identity')
            self.virtual_template_lines['libgnat/'+name] = len(re.split(rb'\r\n|[\r\n]',raw))
        types=(Path(ada_root)/'types.ads').read_text(); c_types=(Path(ada_root)/'types.h').read_text()
        sinput=(Path(ada_root)/'sinput.ads').read_text(); load=(Path(ada_root)/'sinput-l.adb').read_text()
        host=(Path(plugin_include)/'auto-host.h').read_text()
        require(all(anchor in types for anchor in ('type Int is range -2 ** 31 .. +2 ** 31 - 1;',
            "type Text_Ptr is new Int range -4 .. Int'Last;", 'subtype Source_Ptr is Text_Ptr;')) and
            all(anchor in c_types for anchor in ('typedef int Int;','typedef Int Text_Ptr;','typedef Text_Ptr Source_Ptr;')) and
            '#define SIZEOF_INT 4' in host and '#define SIZEOF_VOID_P 8' in host and
            all(anchor in sinput for anchor in ('First, Last : Source_Ptr\'Base;',
                "Dope_Rec_Size : constant := 2 * Source_Ptr'Base'Size;",
                "for Dope_Rec'Size use Dope_Rec_Size;", "for Dope_Rec'Alignment use Dope_Rec_Size / 8;")) and
            "new Dope_Rec'(Snew.Source_First, Snew.Source_Last);" in load, 'selected 32-bit source-pointer Dope_Rec ABI')
        self.dope_abi = dict(Source_Ptr_Base_bits=32, Dope_Rec_bits=64, alignment_bytes=8,
            individual_caller_bytes=8, selected_Linux_Int_and_pointer_bytes=[4,8],
            source_and_selected_host_ABI_checked=True, aggregate_RAM_gate=False)
        self.validation = dict(current_attachment_input_records=len(manifest['files']),
            numeric_input_freeze=manifest['numeric_freeze'],
            original_numeric_review_scope=manifest.get('original_numeric_review_scope', 'original numeric input'),
            historical_acceptance_review_records=len(manifest['reviews']),
            core_current_input_records=self.core_context.inputs_verified,
            core_distinct_current_files=self.core_context.source_files_verified,
            invocation_current_repository_records=self.invocation_context.input_count,
            invocation_complete_retained_sources=len(self.invocation_context.sources),
            invocation_installed_configuration_records=len(self.invocation_context.installed_inputs),
            numeric_identity_records=len(self.numeric_context.identity['files']),
            frontend_direct_identity_records=len(frontend_pins['files']),
            location_repository_identity_records=self.location_context.repository_inputs_verified,
            location_complete_source_identity_records=self.location_context.source_inputs_verified,
            runtime_census_reused_from=manifest['frontend_freeze'], runtime_census_reinventoried=False,
            native_shape_identity_records=len(manifest['native_shape_inputs']),
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
    scope_digits = context.numeric_context.model['uint_digits'](c+2)
    require(rows['selected_scanner'] == dict(Uints=front['scanner_pools']['Uint_entries'],
                Udigits=front['scanner_pools']['Uint_digits'], Ureals=0, Rep_Table=0) and
            rows['Main_constructor'] == dict(Uints=front['Main_constructor']['total']['uint'],
                Udigits=front['Main_constructor']['total']['retained_digit_words'], Ureals=0, Rep_Table=0) and
            rows['original_Main_constant_size_callbacks'] == dict(Uints=demand['Uint_entries'],
                Udigits=demand['Udigits_words'], Ureals=0, Rep_Table=0) and
            numeric['UI_Ints']['original_Main_wrapper_calls'] == demand['UI_Ints_wrapper_calls'] and
            numeric['demands'] == dict(Uints=28420+9*c, Udigits=107726+(70+scope_digits)*c, Ureals=67, Rep_Table=504),
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


def join_frontend_location(raw, core, invocation, numeric, frontend, location, context):
    """Bind actual component inputs and export current indexed shared boundaries."""
    counts, source = core['source_counts'], identity(raw)
    require(frontend['source'] == source == location['source'] and
            frontend['source_counts'] == counts == location['source_counts'], 'frontend/location actual source/count join')
    launch=frontend['selected_launch']; graph=invocation['graph']
    require(launch['Main'] == graph['Main'] and launch['native'] == graph['native'] and
            launch['path_spelling_characters'] == core['complete_path_bound'] == 512 and
            launch['path_bytes_including_NUL'] == invocation['path_bytes'] == 513 and
            launch['gnat1_argv_positions_upper'] == invocation['processes'][0]['child_frontend']['argv_positions_upper'],
            'frontend selected path/configuration join')
    require(frontend['configuration_input_identities'] == core['actual_shared_inputs'], 'frontend shared byte identities')
    files={row['role']:row for row in invocation['materialization']}
    require(frontend['mapping'] == dict(path=files['source_mapping']['path'],
        **identity(files['source_mapping']['text'].encode()),records=4), 'frontend actual mapping join')
    logical=frontend['frontend_logical_join_before_numeric_callbacks']
    require(logical['Main_constructor'] == core['native_Main_frontend_interface']['Main_constructor'] and
            logical['scanner_pool_inputs'] == core['native_Main_frontend_interface']['scanner_pools'] and
            frontend['components']['numeric'] == numeric and frontend['numeric_lifetime_projection'] == numeric['demands'] and
            all(frontend['joined_logical_tables'][key] == numeric['demands'][name] for name,key in
                (('Uints','Uint_entries'),('Udigits','Uint_digits'),('Ureals','Ureal_entries'))),
            'frontend exact Main/scanner/numeric projection join')
    physical=frontend['components']['physical_sources']; gigi=frontend['components']['gigi_array_and_name_input']
    for role,key in (('Main',None),('configuration','configuration'),
                     ('additional_indexed_System','System'),('silver_io.ads','silver_io.ads'),
                     ('silver_output_libc.ads','silver_output_libc.ads')):
        require({k:physical['extra_physical_objects'][role][k] for k in ('bytes','sha256')} ==
                (source if key is None else core['actual_shared_inputs'][key]), 'frontend physical source identity: '+role)
    require(physical['runtime']['directory'] == str(Path(invocation['shared_System']['path']).parent) and
            physical['pattern_String_allocations_upper'] == 14 and
            physical['pattern_String_individual_bytes_upper'] == 21 and
            physical['pattern_String_allocation_rows']['default_lifetime_objects'] == 8 and
            physical['pattern_String_allocation_rows']['configuration_delta_objects'] == 6,
            'frontend selected runtime and pattern String lifetime join')
    n=frontend['joined_logical_tables']['node_identities']
    require(n == logical['tables']['node_identities'] ==
            logical['fixed']['node_identities']+logical['Main_constructor']['total']['node_identities'] and
            frontend['components']['core_tables']['tables']['Node_Offsets']['demand'] == n and
            gigi['joined_frontend_node_identities_upper'] == n and
            gigi['association_array_requests'] == 2 and gigi['each_association_array_raw_bytes_upper'] == 8*n,
            'frontend exact node and association-array join')
    expected=dict(physical_files_upper=1580,virtual_files_upper=9,permanent_source_entries_upper=1589,
        failed_load_transient_slots_upper=1,Source_File_backing_demand=1590,backend_File_Info_entries_upper=1589,
        insertion_capable_filename_lookups_upper=1590,direct_filename_identifier_calls_upper=3180)
    require(frontend['exported_source_entry_bounds'] == expected and
            all(physical[key] == value for key,value in expected.items()) and
            physical['tables']['Source_File']['demand'] == 1590 and
            physical['virtual_source_Dope_Rec_metadata_objects_upper'] == 9 and
            sum(row['Dope_Rec_metadata_objects_upper'] for row in physical['virtual_sources']) == 9,
            'frontend indexed source population and transient ownership join')
    filename=location['filename_ingress']; warning=core['native_warning_map_demand']
    require(location['counts'] == dict(output_calls=counts['output_calls'],null_statements=counts['null_statements']) and
            location['later_warning']['incoming'] == warning['conditional_map_transfer'] and
            warning['other_original_gigi_put_calls'] == 5 and
            filename['source_file_entries_upper'] == 1589 and filename['lookup_calls_upper'] == 1590 and
            filename['direct_GGC_requests_upper'] == 3180 and filename['each_character_caller_bytes_upper'] == 513 and
            filename['shared_identifier_backing_owned_elsewhere'] and not filename['included_in_new_location_warning_delta'] and
            location['later_warning']['original_and_initial_warning_requests_added_again'] == 0 and
            location['initial_ad_hoc_state']['initial_objects_owned_by_fixed_prefix'] and
            location['ad_hoc_storage']['initial_ordinary_objects_added_again'] == 0 and
            location['later_warning']['additional_controls'] == 0 and
            location['later_warning']['additional_finalizer_registrations'] == 0 and
            location['additional_location_and_later_warning_finalizer_registrations'] == 0 and
            location['additional_location_and_later_warning_GGC_events_upper'] ==
                location['ad_hoc_storage']['additional_GGC_backing_requests_upper']+
                location['later_warning']['additional_GGC_backing_requests_upper'] and
            location['total_GGC_events'] is None and not location['complete_global_counter_lifetime_closed'] and
            not location['complete_collector_lifetime_closed'] and not frontend['complete_native_frontend'],
            'location warning R5/path and filename ownership join')
    shared=core['native_original_shared_storage']['interface']
    corrected=context.location['corrected_shared_identifier_projection'](shared,source,counts)
    require(corrected['filename_lookups_upper'] == 1590 and corrected['direct_filename_GGC_requests_upper'] == 3180 and
            corrected['original_shared_GGC_backing_delta_unchanged'] == shared['additional_shared_GGC_backing_request_events_upper'] and
            corrected['extra_shared_GGC_backing_events'] == 0, 'source-bound corrected shared identifier ownership join')
    main_lines=physical['extra_physical_objects']['Main']['physical_line_entries_bound']
    require(location['Main_physical_line_entries_upper'] == main_lines and
            location['Main_ordinary_map_line_guard'] == (1 <= main_lines <= 2**24) and
            all(row['shared_physical_text_and_line_arrays'] and row['new_text_or_line_array_objects'] == 0 and
                row['template'] in context.virtual_template_lines for row in physical['virtual_sources']),
            'Main and virtual ordinary-map line premises join')
    line_checks=dict(Main_ordinary_map_lines=location['Main_ordinary_map_line_guard'],
        fixed_runtime_ordinary_map_lines=1 <= physical['runtime']['physical_line_entries_bound_maximum'] <= 2**24,
        fixed_extra_ordinary_map_lines=all(1 <= row['physical_line_entries_bound'] <= 2**24
            for name,row in physical['extra_physical_objects'].items() if name != 'Main'),
        virtual_template_ordinary_map_lines=all(1 <= context.virtual_template_lines[row['template']] <= 2**24
            for row in physical['virtual_sources']))
    require(tuple(context.dope_abi[key] for key in ('Source_Ptr_Base_bits','Dope_Rec_bits','alignment_bytes',
            'individual_caller_bytes')) == (32,64,8,8) and context.dope_abi['source_and_selected_host_ABI_checked'],
            'exact selected Dope_Rec individual-object ABI join')
    abi=dict(context.dope_abi,objects_upper=9,individual_storage_closed_under_selected_ABI=True,
        individual_request_fits=context.dope_abi['individual_caller_bytes'] <= 2**63-1,
        leaf_remainder_discharged_by_this_attachment='Per-virtual-source Dope_Rec individual object only; no summed RAM gate.')
    guards={**{'native_frontend_'+key:value for key,value in frontend['component_checks'].items()},
        **{'native_location_'+key:value for key,value in location['conditions'].items()},
        **{'native_location_'+key:value for key,value in line_checks.items()},
        **{'native_indexed_identifier_'+key:value for key,value in corrected['identifier_hash']['checks'].items()},
        **{'native_indexed_serial_'+key:value for key,value in corrected['temporary_name_serial']['checks'].items()},
        'native_virtual_Dope_Rec_individual_request':abi['individual_request_fits']}
    counters=copy.deepcopy(shared['counter_endpoints'])
    counters['incoming_temporary_name_serial_upper']=corrected['temporary_name_serial']['incoming_upper']
    counters['next_temporary_name_serial_upper']=corrected['temporary_name_serial']['next_upper']
    counters['checks'].update(corrected['temporary_name_serial']['checks'])
    current_shared=dict(source=source,source_counts=counts,filename_ingress=filename,
        identifier_hash=corrected['identifier_hash'],counter_endpoints=counters,
        unchanged_other_shared_projections={key:shared[key] for key in
            ('type_hash','integer_hash','global_decls','stmt_list_cache','alias_sets','scalar_finalizers')},
        additional_shared_GGC_backing_request_events_upper=shared['additional_shared_GGC_backing_request_events_upper'],
        extra_shared_GGC_backing_events=0,corrected_identifier_projection_applied_to_actual_source=True,
        complete_global_counter_lifetime_closed=False,complete_collector_lifetime_closed=False)
    return dict(frontend_source_path_numeric_and_node_projections_equal=True,
        indexed_permanent_transient_and_filename_populations_equal=True,
        warning_incoming_equals_existing_R5_boundary=True,ordinary_map_line_checks=line_checks,
        virtual_Dope_Rec=abi,corrected_shared_identifier_projection=corrected,
        current_source_bound_shared_storage=current_shared,guards=guards,
        location_delta_ownership='New combined-location backings and later warning puts only; no filename, prefix, old warning or original shared delta added again.',
        partial_ledger_ownership='Existing source-specific partial ledger remains separate and unchanged; no total GGC count follows.',
        ordinary_line_map_backing_and_other_late_shared_storage_closed=False)


def attach(raw, core, invocation, numeric, frontend, location, context):
    route_join = join_invocation(raw, core, invocation, context)
    numeric_join = join_numeric(raw, core, numeric, context)
    storage_join = join_frontend_location(raw,core,invocation,numeric,frontend,location,context)
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
    for key,value in storage_join['guards'].items():
        conditions[key] = conditional[key] = value
    return dict(scope='selected literal native frontend, location and numeric design route; incomplete whole pipeline',
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
        core_result_scope='Unmodified core evaluated before selected attachments. Its predicates, old1588/1589/3178 shared population/identifier/serial fields and open joins are scoped historical-in-derivation intermediates. Current populations and corrected shared fields are selected_native_frontend_storage and selected_current_source_bound_shared_storage; all original local guards remain above.',
        selected_native_invocation=invocation,
        invocation_result_scope='Unmodified accepted leaf; its remaining aggregate-integration item is discharged by invocation_join. Its conservative linker arithmetic remains diagnostic; core_result.literal_output_linker is the joined reviewed refinement.',
        invocation_join=route_join, native_Ada_numeric=numeric, numeric_join=numeric_join,
        selected_native_frontend_storage=frontend,selected_native_location_lifetime=location,
        frontend_location_join=storage_join,
        selected_current_source_bound_shared_storage=storage_join['current_source_bound_shared_storage'],
        frontend_leaf_scope='Unmodified accepted leaf; its Dope_Rec individual-object remainder is discharged by frontend_location_join.virtual_Dope_Rec. Its other remaining/global flags stay scoped to that leaf.',
        location_leaf_scope='Unmodified accepted actual-source leaf. Frontend/ordinary-line premises and actual-source indexed identifier correction are supplied by frontend_location_join. Total GGC, ordinary line-map backing and later shared lifetimes remain open.',
        selected_current_linker_result='core_result.literal_output_linker',
        selected_current_GGC_partial_ledger='core_result.native_original_shared_storage.partial_ledger',
        accounting='No invocation/numeric/frontend/filename/prefix/old-warning/shared rows are added to the GCC partial ledger. The location/later-warning delta is separate. Repeated projections check correspondence; current corrected shared state supersedes only the scoped old identifier/filename/serial projections.',
        open_joins=dict(
            native_remaining_lifetime_and_collector='Ordinary source line-map backing, other late frontend/name/ALI/local/recursive heaps, later shared consumers, remaining passes, RTL/DF ceilings and complete global event/UID/collector lifetimes. Named frontend/numeric/location/later-warning intervals are attached; no complete original or native total follows.',
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
    frontend = context.frontend['compose'](raw,context.frontend_context,descriptor_path)
    location = context.location['evaluate_source'](raw,context.location_context,core['complete_path_bound'])
    return attach(raw, core, invocation, numeric, frontend, location, context)


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

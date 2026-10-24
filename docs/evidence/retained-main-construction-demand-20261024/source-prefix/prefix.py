"""Actual C -> first Typing.type_mlw_file owner projection.

Only a retained launch role/configuration is selected. No arbitrary counter,
table profile, successful typed-tree count or demand certificate is accepted.
Parser/converter auxiliary representation obligations remain named below.
"""
import copy
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PROVIDER = ROOT/'docs/evidence/retained-main-entry-capacity-20261024/result.json'
CONFIGURATION = 'r78_repaired_quiet_timeless_j12_logging'
OWNER_NAMES = {'Ident': 'Ident', 'Hsty': 'Ty.Hsty', 'Hsity': 'Ity.Hsity'}


def typing_entry(role, configuration=CONFIGURATION):
    """Project the accepted populated state to the real pre-typing cut T.

    The theorem covers each selected Main launch under the provider's exact
    filename/configuration and relevant native/service relation. Reaching T
    is conditional on the successful parser/converter prefix; this interface
    does not assert that every representation obligation of that prefix is
    discharged. A partial reader/converter execution has the same zero owner
    calls only until it returns or unwinds; caller error handling is excluded.
    """
    packet = json.loads(PROVIDER.read_text())
    if configuration != CONFIGURATION or packet['configuration'] != CONFIGURATION:
        raise ValueError('only the accepted populated C configuration is attached')
    if type(role) is not str or role not in packet['entry_envelopes']:
        raise ValueError('one accepted launch role is required')
    c = packet['entry_envelopes'][role]
    owners = {}
    table_states = {}
    for name, provider_name in OWNER_NAMES.items():
        v = copy.deepcopy(c['owners'][provider_name])
        owners[name] = {
            'provider_owner': provider_name,
            'counter_upper_at_C': v['counter_value_upper'],
            'counter_upper_at_T': v['counter_value_upper'],
            'actual_counter_equal_at_C_and_T': True,
            'exact_actual_counter_known': False,
            'new_constructor_requests': 0, 'new_counter_increments': 0,
        }
        if name != 'Ident':
            backing = v['backing']
            table_states[name] = {
                'outer_length': backing['outer_length_upper'],
                'bucket_max': backing['bucket_length_upper'],
                'allocated_slots': backing['allocated_bucket_slots_upper'],
            }
            owners[name]['same_backing_geometry_upper_at_C_and_T'] = table_states[name]
            owners[name]['actual_outer_and_bucket_lengths_unchanged'] = True
            owners[name]['weak_clearing_allowed'] = True
            owners[name]['live_contents_or_occupancy_claimed_unchanged'] = False
    return {
        'role': role, 'configuration': configuration,
        'provider_commit': 'e45ee72a42d6cc669e95b80c2c991cbc65fe4e73',
        'start_cut_C': 'after Controller_itp.create_controller, before Controller_itp.add_file; gnat_checks.ml:396-399',
        'end_cut_T': 'entry, before body, of Typing.type_mlw_file at gnat_ast_to_ptree.ml:1410',
        'failure_scope': 'reader/converter execution before return or unwind; caller catch, post-read registration and later diagnostics are outside this cut',
        'owners': owners,
        'source_entry_multiplicities_on_path_reaching_T': {
            'Controller_itp.add_file_outer': 1,
            'Controller_itp.add_file_inner': 1,
            'Session_itp.read_file': 1,
            'Env.read_file': 1,
            'Env.read_lib_file': 1,
            'gnat_json.read_channel': 1,
            'Yojson.Safe.from_channel': 1,
            'Gnat_ast.From_json.file_from_json': 1,
            'Gnat_ast_to_ptree.mlw_file': 1,
            'Typing.type_mlw_file_entry': 1,
            'Typing.type_mlw_file_body': 0,
            'imported_library_parser_entries': 0,
            'typed_contract_builder_entries': 0,
            'typing_proxy_or_overload_candidates': 0,
            'Session_itp.post_read_identifier_registrations': 0,
            'Env.post_parser_store': 0,
        },
        'constructor_orphan_increment_allowance_added': 0,
        'source_selected_partial_prefix_three_owner_requests': {'Ident': 0, 'Hsty': 0, 'Hsity': 0},
        'state_bounds_usable_at_T': {
            'counter_upper': {o: row['counter_upper_at_T'] for o, row in owners.items()},
            'table_upper_envelopes': table_states,
            'bounds_denote_populated_actual_state': True,
            'can_skip_T_to_builder_transport': False,
            'reason': 'Typing.open_file, module imports/clones/declarations and every earlier typing/proxy/candidate request still precede a selected builder entry.',
        },
        'auxiliary_prefix_interfaces': {
            'Ident.Hsattr': {
                'counter_upper_at_C': c['owners']['Ident.Hsattr']['counter_value_upper'],
                'backing_at_C': copy.deepcopy(c['owners']['Ident.Hsattr']['backing']),
                'new_external_hashcons_attempts_upper': None,
                'required_source_demand': 'A: every create_attribute attempt from converter labels, comments, call-id labels, fixed attribute constructors and named terms (including pre/post, assertions and loop invariants), including discarded results',
                'counter_endpoint_interface': 'C_Hsattr + A',
                'backing_provider': 'accepted weak_transfer(L_C,B_C,S_C,A); do not use three-owner zero increment result for Hsattr',
                'argument_and_string_representation_closed': False,
            },
            'Loc.FileTags': {
                'current_counter_upper_at_C': None,
                'current_geometry_upper_at_C': c['managed_static_carrier_words_upper'],
                'new_get_file_tag_attempts_upper': None,
                'required_source_demand': 'F: all Loc.user_position calls on <dummy>, raw filenames and marker-prefixed filenames; partial/caught work is retained',
                'required_transport': 'attach completed C counter/domain and strong-table stored sizes, then all prefix find/add requests; R71 fixed post-registration D0 membership and numerical bounds do not apply to fresh Main metadata',
                'representation_closed': False,
            },
            'Ptree_constructors.loc_counter': {
                'source_initializer': 0,
                'initialization_get_pos_calls': 1,
                'counter_at_C': 1,
                'new_increments_upper': None,
                'required_source_demand': 'G: each get_pos None attempt, including eager argument constructions and Ptree nodes later discarded by simplification',
                'endpoint_interface': '1 + G',
                'required_guard': '1 + G <= 2^47 - 1 before Loc.user_position line packing; OCaml increment must also remain representable',
                'representation_closed': False,
            },
            'Gnat_ast_to_ptree.next_call_id': {
                'counter_at_C': 0,
                'new_increments_upper': None,
                'required_source_demand': 'R: every selected mk_call_id_str request, including term calls and abandoned conversion results; R77 successful typed application count is not substituted',
                'endpoint_interface': 'R',
                'required_guard': 'R <= 2^62 - 1; decimal formatting and resulting attribute-string requests remain attached separately',
                'representation_closed': False,
            },
            'parser_converter_storage_and_arithmetic': {
                'required_source_demand': 'actual serialized Main JSON and occurrence graph from accepted producer, through Yojson/From_json, synthetic Ptree construction, string/number helpers and balanced Connection arrays',
                'accepted_input_provider': 'retained-producer-composition.md exact serialization/byte recurrence; R77 source/typed and R79 VC outputs are later structural providers, not parsing allocation histories',
                'representation_closed': False,
            },
        },
        'actual_populated_three_owner_transport_to_T_established': True,
        'complete_parser_converter_representation_closed': False,
        'actual_selected_builder_entry_attachment_established': False,
        'complete_Main_source_candidate_multiplicities': False,
        'complete_source_to_initial_vc_storage': False,
        'process_budget': copy.deepcopy(c['process_budget']),
        'new_callback_or_save_allowance': 0,
        'aggregate_physical_memory_or_stack_gate': False,
        'C_carrier_is_not_an_exit_heap_or_new_JSON_storage_bound': True,
    }

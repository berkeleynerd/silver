"""Source-level KB initialization objects, for the fixed prospective inputs.

No execution of GPR, XML/Ada or GNAT.Regpat. This is an arithmetic provider,
not a complete parser, process-capacity certificate or admission predicate.
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
I32 = 2**31 - 1
I64 = 2**63 - 1
SCALAR_SLOT = 16
STRING_OVERHEAD = 16


def weighted_vector(weights, component_bytes):
    """One-item appends from an empty Ada.Containers.Vector.

    Weights count the separately allocated linked-list nodes within elements.
    Source-level temporary/copy allowance: original local list plus five
    incoming-item copy shells, and two copy shells per relocated old element.
    Empty default-initialized capacity slots allocate no list nodes.
    """
    capacity = 0
    prefix = 0
    relocated = 0
    growth = []
    for count, weight in enumerate(weights, 1):
        if count > capacity:
            if capacity:
                relocated += prefix
            capacity = max(1, 2 * capacity)
            growth.append(capacity)
        prefix += weight
    gross = 6 * prefix + 2 * relocated
    return dict(elements=len(weights), capacity=capacity,
                component_bytes=component_bytes,
                backing_bytes=STRING_OVERHEAD + capacity * component_bytes,
                backing_allocation_events=len(growth),
                capacity_sequence=growth, final_list_nodes=prefix,
                relocated_list_node_weight=relocated,
                gross_list_node_allocation_events_upper=gross,
                list_node_bytes=3 * SCALAR_SLOT,
                vector_descriptor_bytes=5 * SCALAR_SLOT,
                list_descriptor_bytes=6 * SCALAR_SLOT,
                guards_passed=(capacity < I32 and prefix < I32
                               and gross < I32
                               and STRING_OVERHEAD + capacity * component_bytes < I64))


def regexp_compilation(patterns):
    # The source-derived charging proof is in README.md. Each fixed target
    # gets both anchors. This is deliberately not a Python regexp bytecode size.
    widths = [len(('^' + p + '$').encode('ascii')) for p in patterns]
    n = max(widths)
    program = 96 * n + 32
    return dict(patterns=len(patterns), anchored_input_bytes=n,
                anchored_String_bytes=n + STRING_OVERHEAD,
                program_bytes_upper=program,
                Pattern_Matcher_bytes_upper=program + 7 * SCALAR_SLOT,
                dummy_Pattern_Matcher_bytes_upper=1000 + 7 * SCALAR_SLOT,
                explicit_Pattern_Matcher_allocator_events=len(patterns),
                compile_passes_upper=2 * len(patterns),
                source_result_objects_upper=2 * len(patterns),
                Pattern_Matcher_header_scalar_slots=7,
                compile_recursion_parenthesis_depth_upper=n + 1,
                program_arithmetic_guard=program + 17 < 2**15 - 1,
                parenthesis_guard=n < 255,
                match_execution_storage_closed=False)


def initialization(phase):
    if phase not in ('datarep', 'phase1', 'translation'):
        raise ValueError('Unknown fixed prospective phase')
    fixed = json.loads((HERE / 'inputs/kb-targets.json').read_text())
    inventory = json.loads((HERE / 'inputs/phase-inputs.json').read_text())[phase]
    targets = fixed['targetsets']
    fallback = fixed['fallbacks']
    patterns = [p for row in targets for p in row['patterns']]
    strings = [p for row in fallback for p in row['values']]
    target_vector = weighted_vector([len(r['patterns']) for r in targets], 112)
    fallback_vector = weighted_vector([len(r['values']) for r in fallback], 96)
    fallback_vector['separate_String_allocator_events_upper'] = (
        fallback_vector['gross_list_node_allocation_events_upper'])
    fallback_vector['separate_String_bytes_upper'] = max(map(len, strings)) + 16
    fallback_vector['maximum_list_length'] = max(len(r['values']) for r in fallback)
    target_vector['maximum_list_length'] = max(len(r['patterns']) for r in targets)
    longest_file = max(row['bytes'] for row in inventory['files'])
    longest_external = max((r['bytes'] for r in inventory['external_events']), default=0)
    longest_path = max(len(row['effective_path']) for row in inventory['files'])
    directories = inventory['directories']
    files = len(inventory['files'])
    result = dict(
        phase=phase, process_boundary='One selected process; no cross-process sum',
        target_vector=target_vector, fallback_vector=fallback_vector,
        regexp=regexp_compilation(patterns),
        canonical_GPR_Name_requests_already_in_prior_baseline=len(targets),
        canonical_GPR_Name_payload_upper=max(len(r['canonical'] or r['patterns'][0]) for r in targets),
        sorted_input_file_set=dict(
            insertion_events=files, final_nodes_per_directory_upper=max(inventory['files_per_directory']),
            gross_node_allocator_events=files, gross_String_allocator_events=files,
            node_bytes_upper=80, set_descriptor_bytes_upper=128,
            String_bytes_upper=longest_path + 16,
            maximum_effective_path_payload=longest_path,
            shortname_allocator_events=files,
            shortname_String_bytes_upper=max(len(Path(r['path']).name) for r in inventory['files']) + 16,
            cleared_after_each_directory=True,
            OS_directory_search_storage_closed=False),
        RTS_List=dict(initial_capacity=4, initial_backing_bytes_upper=4 * 16 + 16,
                      initial_backing_allocation_events=1,
                      directory_String_allocator_events=len(directories),
                      directory_String_bytes_upper=max(map(len, directories)) + 16,
                      growth_allocation_events=0,
                      guards_passed=len(directories) <= 4),
        File_Input_buffer=dict(
            top_level_open_events=files,
            external_open_events=len(inventory['external_events']),
            external_event_interpretation='Lexical XML entity expansion; no native parser execution',
            buffer_allocator_events_upper=files + len(inventory['external_events']),
            largest_top_level_payload=longest_file,
            largest_external_payload=longest_external,
            individual_String_bytes_upper=max(longest_file, longest_external, 1) + 16,
            length_and_one_past_guard=max(longest_file, longest_external, 1) + 1 <= I32,
            File_Input_record_and_public_system_id_storage_closed=False),
        attribute_initialization_sets=dict(
            Attr_Set_gross_node_allocator_events_upper=216,
            Attr_Set_peak_nodes_upper=216, Attr_Set_explicit_clear_calls=19,
            Pack_Set_gross_node_allocator_events_upper=19,
            Pack_Set_peak_nodes_upper=19, node_bytes_upper=80,
            each_set_descriptor_bytes_upper=128,
            finalization_does_not_subtract_gross_events=True),
        enumerated_initialization_objects_closed=True,
        complete_KB_parser_storage_closed=False,
        later_target_lookup_and_match_storage_closed=False,
        complete_nonparsed_GPR_Names_closed=False,
        complete_Gprconfig_closed=False,
        complete_GNATprove_GPR2_closed=False,
        complete_producer_capacity_closed=False)
    assert result['regexp']['program_arithmetic_guard']
    assert result['regexp']['parenthesis_guard']
    assert target_vector['guards_passed'] and fallback_vector['guards_passed']
    assert result['RTS_List']['guards_passed']
    assert result['File_Input_buffer']['length_and_one_past_guard']
    return result

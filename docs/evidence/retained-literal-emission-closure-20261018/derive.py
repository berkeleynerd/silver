#!/usr/bin/env python3
"""Selected literal emission closure; never a production capacity verdict.

The companion note supplies the source case argument. Arithmetic alone does
not verify selected compiler options, C++ semantics, or installed behavior.
"""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32 = (1 << 31) - 1
PREFIX_EVENTS = 39257


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def evaluate(calls, nulls, decoded_bytes, maximum_literal_length):
    """Internal transfer: counts must come from the accepted complete scan.

    This entry also permits mathematical endpoint tests too large to store as
    source files. It does not validate source membership or materialize argv.
    """
    c, n, w, longest = calls, nulls, decoded_bytes, maximum_literal_length
    require(all(type(v) is int and v >= 0 for v in (c, n, w, longest))
            and c >= 1, 'natural counts and at least one output call')
    require(longest <= w <= c * longest, 'consistent literal lengths')
    chain, text = 7*c + 7*n + 45, 31*c + 4*n + 22
    counters = dict(
        fixed_prefix_positive_GGC_events_upper=PREFIX_EVENTS,
        ordinary_label_initial_value=1,
        ordinary_label_next_at_prefix_exit_upper=1+PREFIX_EVENTS,
        target_cost_setup_ordinary_label_increments=0,
        imported_and_non_Main_ordinary_label_increments=0,
        Main_ordinary_label_increments_upper=chain,
        ordinary_label_next_at_exit_upper=1+PREFIX_EVENTS+chain,
        Main_label_alignment_span_upper=chain+1,
        constant_label_initial_value=0,
        constant_label_next_at_prefix_exit_upper=PREFIX_EVENTS,
        target_cost_setup_constant_label_increments=0,
        additional_imported_constant_label_increments=0,
        Main_tree_constant_label_increments_upper=2*c,
        post_prefix_RTL_pool_static_space_partition_label_increments=0,
        constant_label_next_at_exit_upper=PREFIX_EVENTS+2*c,
        final_scan_counter_initial_value=0,
        final_scan_counter_at_exit_upper=chain,
        CFI_label_counter_initial_value=0,
        CFI_label_counter_at_exit_upper=5,
        CFI_label_signed_temporary_maximum=4,
        Main_function_definition_number=1,
        next_function_definition_number=4)
    guards = dict(
        literal_length_signed_int=longest <= I32,
        ordinary_label_next_signed_int=counters['ordinary_label_next_at_exit_upper'] <= I32,
        constant_label_next_signed_int=counters['constant_label_next_at_exit_upper'] <= I32,
        Main_instruction_UID_and_label_span_signed_int=chain+1 <= I32,
        final_scan_counter_signed_int=chain <= I32,
        text_and_CFI_location_signed_int=text <= I32,
        CFI_label_temporary_and_next_signed_int=5 <= I32,
        function_definition_next_signed_int=4 <= I32)
    return dict(
        counts=dict(calls=c, nulls=n, decoded_bytes=w, maximum_literal_length=longest),
        source_family_emission_routes_closed_under_selected_descriptor=True,
        counter_bounds=counters,
        counter_and_emission_guards=guards,
        counter_and_emission_guards_fit=all(guards.values()),
        final_chain=chain,
        text_bytes_upper=text,
        assembly=dict(lines_upper=114+chain+w+8*c,
                      bytes_upper=7410+65*chain+13*w+512*c,
                      longest_line_excluding_LF_upper=512,
                      scrub_buffer_bytes_upper=65539),
        emission=dict(emitted_function_bodies=1,
                      Main_boundary_labels=['.LFB1', '.LFE1'],
                      additional_non_Main_emitted_lines=0,
                      selected_pending_external_directive_lines=0,
                      external_pending_declarations_upper=min(2,c),
                      constant_label_definitions_upper=2*c,
                      additional_data_sections_upper=1,
                      additional_data_section='.rodata',
                      rodata_bytes_upper=w+22*c,
                      constant_data_relocations=0,
                      local_label_bytes_excluding_NUL_upper=25,
                      symbol_name_bytes_including_NUL_upper=26,
                      instruction_line_bytes_excluding_LF_upper=64),
        complete_selected_stream_source_correspondence_conditional=all(guards.values()),
        production_invocation_and_materialization_established=False,
        installed_relevant_behavior_correspondence_is_external_premise=True,
        complete_non_label_global_counter_lifetime_closed=False,
        complete_shared_backing_and_collector_capacity_closed=False,
        whole_literal_pipeline_capacity_established=False,
        native_tool_executions=0,
        production_admission_changed=False)


def evaluate_source(raw):
    """Run the pinned existing recognizer with today's narrower byte alphabet."""
    require(isinstance(raw, bytes), 'source must be bytes')
    require(all(32 <= b <= 126 or b in (9, 10, 13) for b in raw),
            'current ASCII source alphabet')
    manifest = json.loads((HERE/'source-manifest.json').read_bytes())
    relative = ('docs/evidence/unbounded-programs/retained-native-expansion-20261017/'
                'derive-literal-output.py')
    pin = next(row for row in manifest['historical_silver_inputs'] if row['path'] == relative)
    path = REPO/relative
    require(identity(path.read_bytes()) == {key: pin[key] for key in ('bytes', 'sha256')},
            'changed complete source recognizer')
    counts = runpy.run_path(str(path))['source_counts'](raw)
    result = evaluate(counts['output_calls'], counts['null_statements'],
                      counts['decoded_literal_bytes'], counts['maximum_literal_length'])
    result['source_counts'] = counts
    result['source_identity'] = identity(raw)
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = json.dumps(evaluate_source(args.source.read_bytes()), indent=2)+'\n'
    if args.output:
        args.output.write_text(result)
    else:
        print(result, end='')

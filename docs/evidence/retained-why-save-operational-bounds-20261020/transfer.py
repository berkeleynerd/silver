"""Conditional operational bounds; mathematical integers, no native execution.

Null is unknown, never an empty entry state. Contracts are caller obligations;
this module does not infer them from numerical guards or observed snapshots.
"""
from __future__ import annotations

MAX_INT = (1 << 62) - 1
MAX_STRING = 144115188075855863


def natural(value):
    if value is not None and (type(value) is not int or value < 0):
        raise ValueError("expected a nonnegative mathematical integer or null")
    return value


def lift(function, *values):
    for value in values:
        natural(value)
    return None if any(value is None for value in values) else function(*values)


def transfer(forest, entry=None, serializer=None, remaining_callbacks=2,
             explanation_prefix_count=None):
    entry = {} if entry is None else entry
    serializer = {} if serializer is None else serializer
    k = natural(remaining_callbacks)
    if k is not None and k > 2:
        raise ValueError("ordinary-ending contract permits at most two callbacks")
    r = None if k is None else 1 + k
    g, j, length = (natural(forest.get(key)) for key in ("G", "J", "L"))
    if forest.get("shape_output_input_ready") is not True:
        length = None
    c = lift(lambda a, b: a * b, r, j)
    visits = lift(lambda a, b: a * b, r, g)
    extent = lift(lambda a, b: a * b, r, length)
    p = natural(explanation_prefix_count)
    explanation = forest.get("explanation", {})
    e = lift(lambda count, size, prefixes: max(11, prefixes * (size + 2 * count) + 1),
             explanation.get("attribute_union_count"),
             explanation.get("attribute_union_bytes"), p)
    if explanation.get("typed_attribute_closure_established") is not True:
        e = None
    n = lift(lambda a, b: a + b, entry.get("gshape_n"), c)
    h = lift(lambda a, b: a + b, entry.get("hyp_map_bindings"), c)
    i = lift(lambda a, b: a + b, entry.get("index_map_bindings"), c)
    s = lift(max, entry.get("dictionary_string_bytes_max"), extent, e)
    index_abs = lift(max, entry.get("hyp_value_abs_max"),
                     entry.get("bound_index_abs_max"), n, 1)
    list_length = lift(max, entry.get("bound_list_length_max"), j)
    # One extra byte covers a minus sign; one covers each separator.
    bound_text = lift(lambda count, index: count * (len(str(index)) + 2),
                      list_length, index_abs)
    shape_text = lift(max, bound_text, entry.get("old_shape_bytes_max"))
    dictionary_bytes = lift(lambda count, size: count * (size + 1), i, s)
    # SV6 header and separator: 24 + 1 bytes. Old shape versions emit less.
    shape_file = lift(lambda dictionary, goals, checksum, shape:
                      25 + dictionary + goals * (checksum + shape + 2),
                      dictionary_bytes, g, entry.get("checksum_bytes_max"), shape_text)
    d = lift(max, h, i)
    map_allocations = lift(lambda calls, size: 8 * calls * (size + 1), c, d)
    shape_binding_limit = lift(lambda old, new: old + new,
                               entry.get("bound_table_bindings"), visits)
    buffer_capacity = lift(lambda old, new: max(old, min(MAX_STRING, 2 * max(1, new))),
                           entry.get("shape_buffer_capacity"), extent)

    a = natural(serializer.get("attempt_stat_visits"))
    ax = natural(serializer.get("attempt_xml_visits"))
    prover_adds = lift(lambda rounds, attempts: rounds * attempts, r, a)
    prover_bindings = lift(lambda old, new: old + new,
                          entry.get("prover_id_bindings"), prover_adds)
    prover_size = lift(lambda old, new: old + new,
                      entry.get("prover_id_scalar_size"), prover_adds)
    no_resize = lift(lambda size, buckets: buckets > 0 and size <= 2 * buckets,
                     prover_size, entry.get("prover_id_bucket_capacity"))
    prover_id_abs = lift(max, entry.get("prover_id_abs_max"), prover_bindings)
    sorts = lift(lambda attempts, transformations: attempts + transformations,
                 ax, serializer.get("transformation_visits"))
    q = lift(lambda *parts: 1 + sum(parts), g, a, ax,
             serializer.get("file_visits"), serializer.get("theory_visits"),
             serializer.get("transformation_visits"), serializer.get("argument_visits"),
             serializer.get("path_component_visits"))
    u = natural(serializer.get("raw_string_bytes_sum"))
    scalar = natural(serializer.get("scalar_format_bytes_max"))
    xml_text = lift(lambda units, strings, decimals:
                    1024 * units + 6 * strings + 32 * units * decimals, q, u, scalar)
    source_format_events = lift(lambda units, strings: 128 * units + strings, q, u)
    filename = lift(lambda directory: directory + 20, entry.get("session_dir_bytes"))
    result = {
        "case": forest.get("case"),
        "conditional_save_entries": r,
        "gshape_add_calls": c,
        "apn_visits": visits,
        "shape_append_bytes": extent,
        "explanation_bytes_per_insertion": e,
        "gshape_n_upper": n,
        "hyp_map_bindings_upper": h,
        "index_map_bindings_upper": i,
        "dictionary_string_bytes_upper": s,
        "new_extmap_node_allocations_upper": map_allocations,
        "new_bound_list_cells_upper": c,
        "bound_table_bindings_upper_under_prefix_contract": shape_binding_limit,
        "bound_shape_text_bytes_upper": bound_text,
        "shape_file_bytes_per_save_upper": shape_file,
        "shape_file_bytes_all_saves_upper": lift(lambda x, y: x * y, r, shape_file),
        "shape_buffer_capacity_upper": buffer_capacity,
        "prover_id_add_calls_upper": prover_adds,
        "prover_id_bindings_upper_under_prefix_contract": prover_bindings,
        "prover_id_scalar_size_upper": prover_size,
        "prover_id_abs_upper": prover_id_abs,
        "prover_id_no_resize_guard": no_resize,
        "prover_frequency_upper": a,
        "sort_input_cells_per_save_upper": sorts,
        "sort_allocation_cells_per_save_upper": lift(lambda count: 4 * count * (count + 1), sorts),
        "transformation_arg_counter_upper": serializer.get("argument_visits"),
        "xml_source_text_bytes_per_save_upper": xml_text,
        "xml_source_format_events_per_save_upper": source_format_events,
        "filename_including_backup_bytes_upper": filename,
        "channel_open_calls_upper": lift(lambda rounds: 2 * rounds, r),
        "file_exists_calls_upper": lift(lambda rounds: 6 * rounds, r),
        "rename_calls_upper": lift(lambda rounds: 3 * rounds, r),
        "remove_calls_upper": lift(lambda rounds: 3 * rounds, r),
        "guards": {
            "shape_buffer_extent": lift(lambda value: value <= MAX_STRING, extent),
            "gshape_counter": lift(lambda value: value <= MAX_INT, n),
            "extmap_height_arithmetic": lift(lambda value: value + 2 <= MAX_INT, d),
            "dictionary_strings": lift(lambda value: value <= MAX_STRING, s),
            "bound_shape_string": lift(lambda value: value <= MAX_STRING, bound_text),
            "filename": lift(lambda value: value <= MAX_STRING, filename),
            "prover_scalar_size": lift(lambda value: value <= MAX_INT, prover_size),
            "prover_id_search_successor": lift(lambda value: value + 1 <= MAX_INT, prover_bindings),
            "frequency_increment": lift(lambda value: value <= MAX_INT, a),
            "sort_length": lift(lambda value: value <= MAX_INT, sorts),
        },
        "ordinary_source_configuration_join_established": False,
        "entry_state_join_established": False,
        "hashtbl_prefix_contract_established": False,
        "formatter_native_capacity_established": False,
        "complete_save_capacity_established": False,
        "complete_identifier_counter_established": False,
        "whole_pipeline_capacity_established": False,
    }
    return result

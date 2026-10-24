"""C->T auxiliary capacities from actual serialized JSON, not a demand vector.

The evidence API is not a producer or a language admission check. Its input is
the actual byte stream in the accepted producer/native filename relation.
Repeated serialized occurrences and evaluated-but-discarded work are charged.
"""
import ast
import importlib.util
import json
from collections import Counter
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SCHEMA_PATH = ROOT / 'docs/evidence/retained-producer-storage-20261018/serialization.json'
SCHEMA = json.loads(SCHEMA_PATH.read_text())['schema']
CONFIGURATION = 'r78_repaired_quiet_timeless_j12_logging'
JSON_BYTE_LIMIT = (1 << 31) - 2
INT_MAX = (1 << 62) - 1
ARRAY_MAX = (1 << 54) - 1
STRING_MAX = (1 << 57) - 9
LINE_MAX = (1 << 47) - 1
LOCAL_TICKETS = 128

spec = importlib.util.spec_from_file_location('accepted_main_prefix', HERE.parent / 'source-prefix/prefix.py')
prefix = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prefix)

# Only these accepted pure definitions execute. No compose/check module runs.
transfer_path = ROOT / 'docs/evidence/retained-why-inline-operations-20261018/compose.py'
tree = ast.parse(transfer_path.read_text())
defs = [n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in {'natural', 'weak_transfer'}]
assert {n.name for n in defs} == {'natural', 'weak_transfer'}
transfers = {}
exec(compile(ast.Module(body=defs, type_ignores=[]), str(transfer_path), 'exec'), transfers)


class Pairs(list):
    """Retain JSON object pairs, including duplicates, instead of overwriting."""


def _string_bytes(s):
    return len(s.encode('utf-8', errors='surrogatepass'))


def serialized_fold(data):
    if type(data) is not bytes:
        raise ValueError('actual serialized JSON bytes are required')
    # The accepted T_file excludes Outputs.Close's one terminating LF.
    # That LF is consumed by Yojson but creates no JSON value/cell/string.
    terminal_lf = int(data.endswith(b'\n'))
    body_bytes = len(data) - terminal_lf
    if not 0 < body_bytes <= JSON_BYTE_LIMIT:
        raise ValueError('outside the existing producer byte interface')
    def reject_constant(s):
        raise ValueError('not ordinary producer JSON: ' + s)
    obj = json.loads(data, object_pairs_hook=Pairs, parse_constant=reject_constant)
    plain = Counter(values=0, list_cells=0, string_bytes=0)
    weighted = Counter(values=0, list_cells=0, string_bytes=0, binder_label_pairs=0)
    kinds = Counter()
    max_labels = 0
    max_replay_depth = 0
    unknown_node_shapes = []
    # Iterative, occurrence-based walk: never deduplicate equal objects/IDs.
    stack = [(obj, 1, 0)]
    while stack:
        value, weight, depth = stack.pop()
        plain['values'] += 1
        weighted['values'] += weight
        max_replay_depth = max(max_replay_depth, depth)
        if isinstance(value, Pairs):
            plain['list_cells'] += len(value)
            weighted['list_cells'] += weight * len(value)
            for key, child in value:
                stack.append((key, weight, depth))
                stack.append((child, weight, depth))
        elif type(value) is list:
            plain['list_cells'] += len(value)
            weighted['list_cells'] += weight * len(value)
            field_map = {}
            node_kind = None
            if value and type(value[0]) is str and value[0].startswith('W_'):
                node_kind = value[0]
                fields = SCHEMA.get(node_kind)
                if fields is None or len(value) != len(fields) + 3:
                    unknown_node_shapes.append(node_kind)
                else:
                    kinds[node_kind] += 1
                    field_map = {f['name'].lower(): (i + 3, value[i + 3], f['type'])
                                 for i, f in enumerate(fields)}
                    for _, item, ty in field_map.values():
                        if ty in {'Symbol_Set', 'String_Sets.Set'} and type(item) is list:
                            max_labels = max(max_labels, len(item))
                    if node_kind in {'W_UNIVERSAL_QUANTIF', 'W_EXISTENTIAL_QUANTIF'}:
                        binders, labels = field_map['binders'][1], field_map['labels'][1]
                        if type(binders) is list and type(labels) is list:
                            weighted['binder_label_pairs'] += weight * len(binders) * len(labels)
            replay_index = field_map.get('expr', (None,))[0] if node_kind == 'W_VARIANT' else None
            for i, child in enumerate(value):
                extra = int(i == replay_index)
                stack.append((child, weight * (2 if extra else 1), depth + extra))
        elif type(value) is str:
            size = _string_bytes(value)
            plain['string_bytes'] += size
            weighted['string_bytes'] += weight * size
    potential = sum(weighted.values())
    q = LOCAL_TICKETS * potential
    return {
        'serialized_bytes': len(data), 'producer_json_body_bytes': body_bytes,
        'terminating_lf_bytes': terminal_lf, 'plain': dict(plain), 'weighted': dict(weighted),
        'kind_occurrences': dict(sorted(kinds.items())),
        'maximum_label_set_length': max_labels,
        'maximum_variant_expr_replay_depth': max_replay_depth,
        'unknown_node_shapes': unknown_node_shapes,
        'potential': potential, 'combined_auxiliary_event_upper': q,
        'plain_component_byte_guards': {k: v <= body_bytes for k, v in plain.items()},
        'ordinary_linear_envelope_applies': max_labels <= 3 and max_replay_depth <= 1 and not unknown_node_shapes,
        'linear_potential_upper': 12 * body_bytes,
        'is_native_parser_or_complete_schema_validator': False,
        'producer_source_relation_required': True,
    }


def _transport(role, q, byte_upper, configuration):
    incoming = prefix.typing_entry(role, configuration)
    c = json.loads(prefix.PROVIDER.read_text())['entry_envelopes'][role]
    hs = c['owners']['Ident.Hsattr']
    b = hs['backing']
    weak = transfers['weak_transfer'](b['outer_length_upper'], b['bucket_length_upper'],
                                      b['allocated_bucket_slots_upper'], q)
    wa = weak['individual_outer_array_length_upper']
    wb = weak['individual_bucket_length_upper']
    # R71 native Cons = 4 words; accepted C minor history counts every such
    # forward-cell allocation before each completed FileTags increment.
    initial_files = c['minor_history_words_upper'] // 4
    files = initial_files + q
    strong_extent = max(16, files)
    # These are lengths of individual constructed converter/error strings,
    # not a bound on formatting queue storage or Yojson's internal buffers.
    new_string = 64 * byte_upper + 128
    resident_string = max(8 * c['managed_static_carrier_words_upper'], new_string)
    guards = {
        'Hsattr_counter': hs['counter_value_upper'] + q <= INT_MAX,
        'weak_growth_shrink': 3 * max(wa, wb) + 6 <= INT_MAX,
        'weak_outer_array': wa <= ARRAY_MAX,
        'weak_bucket': wb + 2 <= ARRAY_MAX - 2,
        'FileTags_counter_and_sizes': files <= INT_MAX,
        'FileTags_doubling_and_threshold': 2 * strong_extent <= INT_MAX,
        'FileTags_arrays': strong_extent <= ARRAY_MAX,
        'synthetic_increment_and_line': 1 + q <= LINE_MAX,
        'call_id_increment': q <= INT_MAX,
        'individual_string_length': resident_string <= STRING_MAX,
        'string_size_and_index_arithmetic': 2 * resident_string + 16 <= INT_MAX,
        'individual_native_array_byte_request': 8 * (max(wa, wb + 2, strong_extent) + 1) <= (1 << 64) - 1,
        'Connection_array_payload': byte_upper <= ARRAY_MAX,
        'Connection_midpoint_and_index': 2 * byte_upper + 1 <= INT_MAX,
        'Connection_array_bytes': 8 * (byte_upper + 1) <= (1 << 64) - 1,
    }
    return {
        'role': role, 'configuration': configuration,
        'C_to_T': incoming['start_cut_C'] + ' -> ' + incoming['end_cut_T'],
        'combined_auxiliary_event_upper': q,
        'producer_json_body_bytes_upper': byte_upper,
        'native_input_file_bytes_upper_including_Close_LF': byte_upper + 1,
        'each_A_F_G_R_upper': q,
        'Hsattr': {'counter_upper_at_C': hs['counter_value_upper'],
                   'counter_upper_at_T': hs['counter_value_upper'] + q,
                   'actual_populated_backing_at_C': b, 'weak_transfer': weak,
                   'per_outer_array_bytes': 8 * (wa + 1),
                   'per_hash_bucket_bytes': 8 * (wb + 1),
                   'per_weak_bucket_bytes': 8 * (wb + 3)},
        'FileTags': {'counter_and_each_size_upper_at_C': initial_files,
                     'actual_initial_counter_not_known': True,
                     'counter_and_each_size_upper_at_T': files,
                     'each_backing_or_tail_extent_upper': strong_extent,
                     'each_backing_or_tail_bytes_upper': 8 * (strong_extent + 1),
                     'each_chain_cells_upper': files,
                     'fresh_filenames_allowed': True, 'old_R71_D0_membership_used': False,
                     'completed_C_maps_are_inverse': True,
                     'no_source_selected_interrupted_mutation_before_T': True},
        'synthetic_location_counter_upper_at_T': 1 + q,
        'call_id_counter_upper_at_T': q,
        'new_content_derived_string_length_upper': new_string,
        'new_converter_string_length_upper': resident_string,
        'old_or_new_string_length_upper': resident_string,
        'fixed_payload_words': {'attribute': 2, 'attribute_tag_copy': 2,
                                'FileTags_bucket_cell': 3, 'position': 3, 'include_Set_node': 4},
        'fixed_Gnat_Ptree_requests_and_Connection': {
            'source_fixed_record_tuple_list_and_closure_arities': True,
            'maximum_serialized_Gnat_record_fields': max(map(len, SCHEMA.values())),
            'Connection_array_length_upper': byte_upper,
            'Connection_midpoint_numerator_upper': 2 * byte_upper + 1,
            'Connection_array_bytes_upper': 8 * (byte_upper + 1),
            'List_length_and_include_set_height_upper': byte_upper + 1,
            'finite_traversal_under_physical_premise': True,
            'closed_under_inherited_fixed_constructor_correspondence': True,
            'new_native_fixed_byte_census_claimed': False,
        },
        'guards': guards, 'auxiliary_owner_representation_guards_hold': all(guards.values()),
        'inherited_three_owner_projection': incoming['owners'],
        'genuine_remaining_operands': {
            'Yojson.Safe.from_channel': 'Input buffer/token/lexbuf/JSON container and exception construction requests for B+1 file bytes, including Outputs.Close LF; existing Json_base output escaper is not this parser',
            'Big_int_Z_and_Number': 'Actual Uint/Ureal decimal strings plus selected denominator/exponent and Number.real_literal/real_value/normalize origins; d=40 bounds serialized digits only, not a numeric exponent/shift or intermediate allocation. Derive those operands before pricing powers; later five-atom contract is not substituted',
            'Format_and_error_buffers': 'Format.sprintf/ksprintf/kasprintf storage mechanics for bounded scalar/string/path outputs; bound on result string is not a complete buffer/queue proof',
        },
        'full_parser_converter_representation_closed': False,
        'T_to_builder_transport_closed': False,
        'process_budget': incoming['process_budget'],
        'save_origin_callbacks_before_T': 0, 'new_callback_or_save_allowance': 0,
        'aggregate_RAM_stack_or_cumulative_local_bytes': False,
    }


def from_serialized_json(role, data, configuration=CONFIGURATION):
    fold = serialized_fold(data)
    out = _transport(role, fold['combined_auxiliary_event_upper'], fold['producer_json_body_bytes'], configuration)
    out['source_fold'] = fold
    out['source_attachment'] = 'Actual accepted producer serialization at the retained filename; not an arbitrary demand/counter certificate. The 63-kind source-demand proof applies to successful decoding and every earlier converter prefix.'
    return out


def producer_envelope(role, configuration=CONFIGURATION):
    """Existing B cap + label/domain source facts, no arbitrary count input."""
    out = _transport(role, LOCAL_TICKETS * 12 * JSON_BYTE_LIMIT, JSON_BYTE_LIMIT, configuration)
    out['source_attachment'] = 'Conditional on the existing producer JSON body B<=2^31-2 (file B+1 with Close LF), <=3 labels and at most one Variant.expr replay layer. Current Main actually has zero variants: R77 source loop induction plus accepted fixed F_VARIANT=F_VARIANTS=0 and Include/Module-only imports. No new admission bound. Actual-JSON fold does not need the linear shortcut.'
    out['source_fold_or_linear_source_proof_required'] = True
    return out

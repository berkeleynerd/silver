"""Numeric cut-C envelopes under the research note's source/config relation.

This is evidence arithmetic, not a launcher, runtime observer or admission rule.
The actual populated source-produced state remains the state being bounded.
No synthetic counter/table value is substituted for it.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
MAX_INT = 2**62-1
ARRAY_MAX = 2**54-1
WEAK_MAX = ARRAY_MAX-2
IMAGE_WORDS = 2152771
CONFIGURATION = 'r78_repaired_quiet_timeless_j12_logging'
OWNERS = {
    'Ident': {'initial': 0, 'minimum_minor_words': 5, 'kind':'ident'},
    'Ident.Hsattr': {'initial': 0, 'minimum_minor_words': 3, 'kind':'weak'},
    'Ty.Hsty': {'initial': 0, 'minimum_minor_words': 3, 'kind':'weak'},
    'Ity.Hsity': {'initial': 0, 'minimum_minor_words': 4, 'kind':'weak'},
    'Decl.Hsdecl': {'initial': 0, 'minimum_minor_words': 4, 'kind':'weak'},
    'Theory.Hstdecl': {'initial': 0, 'minimum_minor_words': 3, 'kind':'weak'},
    'Task.Hstask': {'initial': 0, 'minimum_minor_words': 7, 'kind':'weak'},
    'Task.Stdecl.Hcpt': {'initial': 1, 'minimum_minor_words': 4, 'kind':'ephemeron'},
}


def projection():
    return json.loads((ROOT/'docs/evidence/retained-combined-parallel-startup-20261020/projection.json').read_text())


def entry_envelope(role, configuration=CONFIGURATION):
    if configuration != CONFIGURATION:
        raise ValueError('this source restriction is attached only to the frozen R78 recipe')
    rows = projection()['domains']
    if role not in rows:
        raise ValueError('matching retained launch role required')
    bounds = rows[role]['bounds']
    minor = bounds['minor_words']
    major = bounds['all_major_words']
    history = minor + major
    carrier = history + IMAGE_WORDS
    owners = {}
    for name, specification in OWNERS.items():
        requests = minor // specification['minimum_minor_words']
        row = {**specification, 'completed_requests_upper':requests,
               'counter_value_upper':specification['initial']+requests,
               'exact_populated_counter_known':False}
        if specification['kind'] == 'weak':
            row['backing'] = {
                'creation_outer_length':5003, 'creation_allocated_bucket_slots':0,
                'outer_length_upper':carrier, 'bucket_length_upper':carrier,
                'allocated_bucket_slots_upper':carrier,
                'live_entries_upper':requests, 'limit':7,
                'oversize_upper':carrier, 'rover_strict_upper':carrier,
                'cache_hash_arrays_same_lengths':True,
                'current_state_is_creation_state':False,
            }
        elif specification['kind'] == 'ephemeron':
            row['backing'] = {'initial_size':8192, 'seed':0,
                              'outer_length_upper':carrier,
                              'stored_bucket_cells_upper':requests,
                              'size_upper':requests, 'power_of_two':True,
                              'current_state_is_creation_state':False}
        owners[name] = row
    return {
        'role':role, 'configuration':configuration, 'cut':'after create_controller, before add_file',
        'minor_history_words_upper':minor, 'all_major_history_words_upper':major,
        'protected_managed_history_words_upper':history,
        'managed_static_carrier_words_upper':carrier,
        'one_byte_payload_upper':8*carrier,
        'owners':owners,
        'Introduction.Hsdecl': {'next_tag':0, 'outer_length':5003,
                               'allocated_bucket_slots':0, 'limit':7,
                               'oversize':0, 'rover':0, 'calls_before_C':0},
        'other_reachable_managed_memos': {
            'physical_backing_words_upper':carrier,
            'individual_array_slots_upper':carrier,
            'physical_list_map_bucket_cells_upper':carrier,
            'logical_unfolded_occurrence_bound_claimed':False,
            'future_lookup_or_value_semantics_supplied':False,
            'foreign_native_backings_included':False,
        },
        'guards': {
            'all_named_counters':all(v['counter_value_upper'] <= MAX_INT for v in owners.values()),
            'weak_growth_operands':3*carrier+3 <= MAX_INT,
            'weak_max_size_unreached':carrier < WEAK_MAX,
            'ordinary_array_max_unreached':carrier < ARRAY_MAX,
            'map_and_container_arithmetic':2*carrier+3 <= MAX_INT,
            'paired_byte_arithmetic':16*carrier+2 <= MAX_INT,
            'minor_prefix_margin':minor < 2**28,
            'major_arena_margin':major < 2**24,
            'remembered_entry_margin':bounds['remembered_entries'] < 2**25,
            'ephemeron_entry_margin':bounds['ephemeron_entries'] < 2**25,
            'custom_entry_margin':bounds['custom_entries'] < 2**25,
            'minor_custom_resource_margin':bounds['extra_minor_resources'] < 1,
            'major_custom_resource_margin':bounds['extra_major_resources'] < 1,
        },
        'full_Main_storage_closed':False,
        'configuration_206_extension_available':False,
        'process_budget':{'escaping_save_exceptions':2,'save_entering_callbacks':2,'saves':3},
    }


def all_envelopes():
    return {role:entry_envelope(role) for role in sorted(projection()['domains'])}

"""Conditional shared representation join for the accepted builder partition.

These are mathematical source-fold inputs, never admission certificates.
The caller supplies one inherited owner/table state and keeps accumulating
requests in the same Demand. No cache-hit discount or fresh episode allowance.
"""
import ast
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('shared_accepted_local', HERE.parent/'builder-locals/local.py')
local = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = local
spec.loader.exec_module(local)
b, k = local.b, local.k
create_cty, c_app = local.create_cty, local.c_app
INT_MAX = (1 << 62) - 1
ARRAY_MAX = (1 << 54) - 1
EPHE_MAX = ARRAY_MAX - 2

# Reuse exactly the accepted pure definitions, without importing or running
# that packet's compose/check functions or their dependency traversal.
TRANSFER = ROOT/'docs/evidence/retained-why-inline-operations-20261018/compose.py'
tree = ast.parse(TRANSFER.read_text())
names = {'natural', 'counter_transfer', 'weak_transfer'}
defs = [n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in names]
assert {n.name for n in defs} == names
transfers = {'INT_MAX': INT_MAX}
exec(compile(ast.Module(body=defs, type_ignores=[]), str(TRANSFER), 'exec'), transfers)


def natural(value):
    if type(value) is not int or value < 0:
        raise ValueError('expected nonnegative integer, excluding bool')
    return value


def backing(state, requests):
    """State is L, B, S at the same cut as the Demand's counter entries.

    S includes every allocated bucket slot, including empty/dead slots.
    All are exact values or conservative upper bounds attached by the caller;
    validity of the represented table is a separate source-state premise.
    """
    if type(state) is not dict or set(state) != {'outer_length', 'bucket_max', 'allocated_slots'}:
        raise ValueError('expected exactly outer_length, bucket_max, allocated_slots')
    l, bmax, slots = (natural(state[n]) for n in ('outer_length', 'bucket_max', 'allocated_slots'))
    natural(requests)
    if l < 7 or bmax > slots:
        raise ValueError('invalid weak-table envelope')
    out = transfers['weak_transfer'](l, bmax, slots, requests)
    a, bkt = out['individual_outer_array_length_upper'], out['individual_bucket_length_upper']
    guards = {
        'growth_shrink_and_index_arithmetic': 3*max(a, bkt)+6 <= INT_MAX,
        'outer_array_payload': a <= ARRAY_MAX,
        # Preserve the accepted conservative Weak/Ephemeron condition.
        'weak_bucket_payload': bkt+2 <= EPHE_MAX,
        'array_request_bytes_size_t': 8*(a+1) <= (1 << 64)-1,
        'weak_request_bytes_size_t': 8*(bkt+3) <= (1 << 64)-1,
    }
    return {
        'inherited': dict(state), 'external_merge_requests_upper': requests,
        'accepted_weak_transfer': out, 'guards': guards,
        'per_request_bytes_upper': {
            'each_outer_array_including_header': 8*(a+1),
            'each_hash_bucket_array_including_header': 8*(bkt+1),
            'each_weak_bucket_including_two_extra_fields_and_header': 8*(bkt+3),
        },
        'representation_guards_hold': all(guards.values()),
        'allocated_slots_are_not_live_occupancy': True,
        'backing_total_bytes_computed': False,
    }


class Demand(local.Demand):
    def shared_export(self, table_states=None):
        """Join this cumulative builder ledger at its original incoming cut.

        Missing states produce an explicitly incomplete export. Supplied numeric
        states evaluate conditional guards; they do not establish actual Main
        process attachment or source/candidate multiplicity completeness.
        """
        old = self.local_export()
        vector = old['accepted_request_vector']
        entries = {'Ident': self.ident_entry, 'Hsty': self.hsty_entry, 'Hsity': self.hsity_entry}
        requests = {o: natural(vector['owner_requests_upper'].get(o, 0)) for o in entries}
        counters = {o: transfers['counter_transfer'](natural(entries[o]), requests[o]) for o in entries}
        for o in entries:
            assert counters[o]['final_upper'] == vector['owner_endpoints_upper'][o]
        if table_states is not None and (type(table_states) is not dict or set(table_states) != {'Hsty', 'Hsity'}):
            raise ValueError('supply both Hsty and Hsity inherited states')
        tables = None if table_states is None else {
            o: backing(table_states[o], requests[o]) for o in ('Hsty', 'Hsity')}
        local_ok = old['new_local_representation_safety_closed']
        arithmetic_ok = all(v['signed_ocaml_int_fits'] for v in counters.values())
        backing_ok = tables is not None and all(v['representation_guards_hold'] for v in tables.values())
        memos = vector['memo_reads']
        allowed_memos = {'Ity.vs_to_pv.restore', 'ts_tuple', 'fs_tuple', 'its_tuple', 'fs_tuple_ids.mem'}
        if set(memos)-allowed_memos:
            raise ValueError('unattached memo service')
        return {
            'accepted_local_export': old,
            'owner_counters': counters, 'weak_backing': tables,
            'callbacks': {
                'Hsty_candidate_child_hash_reads_per_request_upper': 2,
                'Hsty_child_identity_tests_per_comparison_upper': 2,
                'Hsity_candidate_child_hash_reads_per_request_upper': 0,
                'Hsity_child_identity_tests_per_comparison_upper': 0,
                'Hsity_purity_child_reads_per_request_upper': 0,
                'hashcons_tag_copy_payload_words': {'Hsty': 2, 'Hsity': 3},
                'weak_old_shallow_copy_payload_words': {'Hsty': 2, 'Hsity': 3},
                'callback_owner_increments': 0,
                'callback_hashcons_requests': 0,
                'weak_resize_reuses_cached_hashes': True,
                'hash_mixing_has_intended_modular_semantics': True,
                'bounds_require_accepted_source_partition': True,
            },
            'lookup_only_services': {
                'reads': dict(memos), 'owner_increments': 0,
                'new_backing_arrays_or_bucket_nodes': 0,
                'stored_size_counter_writes': 0,
                'finite_valid_inherited_chain_required': True,
                'warm_tuple_zero_required_and_source_justified': True,
                'weak_get_key_and_data_are_not_payload_copies': True,
            },
            'supplied_diagram_local_domain_guard': local_ok,
            'supplied_diagram_counter_guards': arithmetic_ok,
            'supplied_diagram_backing_guards': backing_ok,
            'conditional_shared_representation_interface_applies': local_ok and arithmetic_ok and backing_ok,
            'actual_Main_initial_process_attachment_established': False,
            'complete_source_entry_and_candidate_multiplicities': False,
            'complete_main_builder_classification': False,
            'complete_source_to_initial_vc_storage': False,
            'aggregate_physical_memory_or_stack_gate': False,
            'new_exception_or_save_allowance': 0,
            'provider_or_remaining_attachment': json.loads((HERE/'source-joins.json').read_text())['remaining_attachments'],
            'premises': [
                'accepted partition and finite valid immutable source/type records with correctly registered child and symbol tags',
                'actual cumulative request ledger, including failed candidates, with counters and both table envelopes attached at one incoming cut',
                'valid inherited Weak tables and finite valid Wvs/strong table chains; well-formed old type representatives',
                'selected source/compiler/runtime correspondence and sufficient ordinary physical memory/stack',
                'no uncharged concurrent owner writes; all asynchronous work remains in the existing process-global accounting',
            ],
        }

"""Interrupted preparation and conditional Theory writer accounting."""
from math import isqrt

MAX_INT = (1 << 62)-1
MIN_INT = -(1 << 62)
CELL_CEILING = (1 << 64)//32
TASK_CELL_CEILING = (1 << 64)//56
PREMISES = (
    'selected_source_native_pending_frame_relation',
    'accepted_fresh_status_configuration_and_serial_ownership',
    'accepted_metadata_key_counter_and_result_preservation',
    'continued_global_signal_escape_budget',
    'selected_writer_effects_and_valid_immutable_task_relation',
)


def nat(n, v):
    if type(v) is not int or v < 0:
        raise ValueError(n + ' must be a nonnegative integer')
    return v


def size_drift(failed_mutations):
    f = nat('failed_mutations', failed_mutations)
    # At most f abandoned count-changing mutations, and one current prefix.
    lo, hi = -(f+1)*CELL_CEILING, (f+2)*CELL_CEILING
    return {'abandoned_count_changing_mutations_upper': f,
            'active_mutation_prefix_allowance': 1,
            'size_lower': lo, 'size_upper': hi,
            'tagged_size_guard': MIN_INT <= lo <= hi <= MAX_INT,
            'failure_count_established_here': False}


def writer_bounds(initial_cells, publications, initial_size):
    v0 = nat('initial_cells', initial_cells)
    s0 = nat('initial_size', initial_size)
    w = nat('publications', publications)
    if v0 > CELL_CEILING:
        raise ValueError('invalid initial cell count')
    v, l = min(CELL_CEILING, v0+w), min(CELL_CEILING, 7+w)
    decrement = w*v
    copies = min(w, 41)*v
    return {'publications_upper': w, 'current_cells_upper': v,
            'bucket_nodes_upper': l, 'clean_invocations_upper': w,
            'successful_array_doublings_upper': min(w, 41),
            'clean_node_visits_and_cons_requests_upper': decrement,
            'resize_node_visits_and_cons_requests_upper': copies,
            'initial_scalar_size': s0,
            'size_lower': s0-decrement, 'size_upper': s0+w,
            'tagged_size_guard': MIN_INT <= s0-decrement and s0+w <= MAX_INT,
            'recursive_bucket_own_frames_and_return_bytes_upper': 32*(l+1),
            'whole_native_stack_capacity_established': False,
            'all_writer_allocations_bounded': False}


def publication_threshold(initial_cells, initial_size):
    v0 = nat('initial_cells', initial_cells)
    s0 = nat('initial_size', initial_size)
    candidate = min(MAX_INT-s0, (isqrt(v0*v0+4*(s0-MIN_INT))-v0)//2)
    if not 0 <= candidate < CELL_CEILING-v0:
        raise ValueError('threshold helper only covers the selected quadratic branch')
    return candidate


def compose(registered_goals, initial_cells, escapes=2, library_charge=None,
            task_cells=TASK_CELL_CEILING, premises=None, initial_size=None):
    g = nat('registered_goals', registered_goals)
    e = nat('escapes', escapes)
    d = nat('task_cells', task_cells)
    if e > 2 or d > TASK_CELL_CEILING:
        raise ValueError('outside selected signal or represented-task range')
    if library_charge is not None:
        nat('library_charge', library_charge)
    supplied = {} if premises is None else dict(premises)
    if set(supplied)-set(PREMISES) or any(type(v) is not bool for v in supplied.values()):
        raise ValueError('invalid premises')
    missing = [p for p in PREMISES if not supplied.get(p, False)]
    episodes = 3*g+e
    dispatch = {'preparation_episodes_intersecting_suffix_upper': episodes,
                'outer_directive_applications_upper': 40*g+15*e,
                'literal_initializations_upper': episodes,
                'direct_library_roots_upper': 2*episodes,
                'algebraic_tuple_fold_entries_upper': episodes,
                'direct_algebraic_tuple_publications_upper': 3*d*episodes}
    w = None if library_charge is None else episodes*(3*d+2*library_charge)
    return {'missing_premises': missing, 'candidate_dispatch': dispatch,
            'dispatch_bounds': None if missing else dispatch,
            'library_publication_charge_per_direct_root': library_charge,
            'task_chain_cells_per_algebraic_fold_upper': d,
            'candidate_publications_upper': w,
            'publication_bound': None if missing else w,
            'candidate_writer_bounds': None if w is None or initial_size is None else writer_bounds(initial_cells, w, initial_size),
            'actual_library_charge_established': False,
            'actual_writer_size_arithmetic_established': False,
            'complete_writer_capacity_established': False,
            'complete_restore_table_capacity_established': False,
            'complete_save_capacity_established': False,
            'whole_pipeline_capacity_established': False}

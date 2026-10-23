"""Callable six-owner demand join, with explicit unfilled continuation contracts.

Only frozen JSON and three frozen pure arithmetic transfers are consumed.
No claimed whole-process theorem can be obtained by omitting a residual.
"""
import json
from project import HERE, REPO, EVIDENCE, CASES, read, pure_functions, identity

INT_MAX = (1 << 62) - 1
# Selected Linux/64-bit limits, checked against retained native return bytes below.
ARRAY_MAX = (1 << 54) - 1
EPHE_MAX = ARRAY_MAX - 2
OWNERS = ('Ident', 'Decl.Hsdecl', 'Ty.Hsty', 'Theory.Hstdecl',
          'Task.Hstask', 'Task.Stdecl.Hcpt')
RESIDUALS = ('lookup_library_constructors', 'later_preparation',
             'solver_request_printers', 'other_callbacks_and_shutdown')
TRANSFERS = pure_functions(EVIDENCE / 'retained-why-inline-operations-20261018/compose.py',
    ['natural', 'counter_transfer', 'weak_transfer', 'ephemeron_transfer'], {'INT_MAX': INT_MAX})


def natural(n):
    if type(n) is not int or n < 0:
        raise ValueError('demand must be a nonnegative integer, excluding bool')
    return n


def zero():
    return {o: dict(increments=0, requests=0) for o in OWNERS}


def vector(ident=0, decl=0, unique=0, ty=0, td=0, task=0, hcpt=0):
    assert 0 <= unique <= decl
    return {'Ident': dict(increments=ident, requests=0),
            'Decl.Hsdecl': dict(increments=decl, requests=decl-unique),
            'Ty.Hsty': dict(increments=ty, requests=ty),
            'Theory.Hstdecl': dict(increments=td, requests=td),
            'Task.Hstask': dict(increments=task, requests=task),
            'Task.Stdecl.Hcpt': dict(increments=hcpt, requests=hcpt)}


def sum_vectors(vectors):
    out = zero()
    for v in vectors:
        for owner in OWNERS:
            for field in ('increments', 'requests'):
                out[owner][field] += v[owner][field]
    return out


def validate_vector(v):
    if type(v) is not dict or set(v) != set(OWNERS):
        raise ValueError('each residual must explicitly name all six owners')
    for owner in OWNERS:
        if type(v[owner]) is not dict or set(v[owner]) != {'increments', 'requests'}:
            raise ValueError('each owner requires increments and requests')
        for n in v[owner].values():
            natural(n)
        if owner == 'Ident' and v[owner]['requests'] != 0:
            raise ValueError('Ident has no hash table backing')
    return v


def weighted(ordinary, possible, e):
    """All stage maxima use this same process escape variable."""
    out = zero()
    for owner in OWNERS:
        for field in ('increments', 'requests'):
            out[owner][field] = (sum(v[owner][field] for v in ordinary)
                + e * max(v[owner][field] for v in possible))
    return out


def attached_components(case, e):
    cert = read(EVIDENCE / 'retained-why-preinline-prefix-20261020' / f'{case}-certificate.json')
    family = read(EVIDENCE / 'retained-why-fixed-inline-family-20261020' / f'{case}-family.json')
    post = next(d for d in read(EVIDENCE / 'retained-why-postinline-preparation-20261020/result.json')['domains']
                if d['case'] == case)
    inv = read(EVIDENCE / 'retained-why-postinline-preparation-20261020' / f'{case}-inventory.json')
    raw_goals = {r['goal']: r for r in cert['all_raw_goals']}
    selected = {r['goal']: r for r in cert['selected']}
    roots = [r['goal'] for r in family['stages']['raw']['roots']]
    # The frozen root map is attached by the R56 family checker. Rejoin its
    # goal/task/formula here; old selected raw leaves are never the family count.
    assert len(roots) == family['registered_roots']
    C, H = inv['context_declarations'] + 1, post['task_nodes_upper']
    rows = {name: [] for name in ('driver_update', 'CE_and_monomorphise', 'first_inline', 'R58')}
    route_rows = []
    for route, drivers in [('raw', ('z3',)), ('ce', ('cvc5', 'altergo'))]:
        inline = {r['goal']: r for r in family['stages'][route]['roots']}
        post_roots = {r['goal']: r for r in post['routes'][route]}
        for goal in roots:
            r = inline[goal]; pre = selected[goal]; raw = raw_goals[goal]
            assert r['task'] == pre['task'] == raw['task']
            assert r['raw_formula'] == raw['raw_formula']
            for driver in drivers:
                # Metadata clone calls make at most H tdecls. The only MAty
                # arguments are the accepted two one-node ground types.
                update = vector(ident=raw['raw_coordinates']['b'], ty=2,
                                td=H, task=H, hcpt=64*H)
                ce = (vector(ident=pre['ce_direct_Ident_upper'], decl=C, unique=1,
                             td=C, task=H, hcpt=64*H) if route == 'ce' else zero())
                if driver == 'altergo':
                    ce = sum_vectors([ce, vector(ident=pre['altergo_mono_goal_validation_Ident_upper'],
                                                decl=1, unique=1, td=1, task=1)])
                first = vector(ident=r['Ident']['total'], decl=C, unique=1,
                               ty=r['kernel']['type_instantiation_requests'],
                               td=C, task=H, hcpt=64*H)
                stages = ['eliminate_builtin', 'remove_unused']
                if driver != 'altergo':
                    stages.append('detect_polymorphism')
                later = []
                for stage in stages:
                    d = post_roots[goal]['demand'][stage]
                    later.append(vector(ident=d['direct_Ident_registrations'],
                        decl=d['Hsdecl_constructor_requests'], ty=d['type_application_requests'],
                        td=d['tdecl_constructor_requests'], task=d['task_add_requests'],
                        hcpt=64*d['task_add_requests']))
                for name, v in zip(rows, [update, ce, first, sum_vectors(later)]):
                    rows[name].append(v)
                route_rows.append(dict(goal=goal, driver=driver))
    assert len(route_rows) == 3*len(roots)
    components = {name: weighted(vs, vs, e) for name, vs in rows.items()}
    # Full accepted save interval already includes r<=3 and shared e<=2.
    # Keep its conservative bound unchanged when caller chooses smaller e.
    save = next(d for d in read(EVIDENCE / 'retained-why-save-shape-builder-allocation-20261020/result.json')['cases']
                if d['case'].replace('_', '-') == case)
    bound = save['under_named_existing_external_premises']['candidate']
    assert bound['global_save_entries_upper'] == 3 and bound['global_escaping_signal_exceptions_upper'] == 2
    components['save_binder_registrations'] = vector(ident=bound['fresh_variable_calls_upper'])
    return dict(components=components, registered_roots=len(roots), ordinary_pairs=len(route_rows),
                preparation_episodes_upper=len(route_rows)+e, task_nodes_upper=H,
                logical_declarations_upper=C,
                preinline_completed_call_allowance_subtracted=0,
                source_demand_scope='named transform bodies and direct save binders; lookup constructors remain explicit',
                per_pair_inputs=route_rows)


def apply_transfers(state, demand):
    result = {}
    for owner in OWNERS:
        s, d = state[owner], demand[owner]
        row = dict(counter=TRANSFERS['counter_transfer'](s['counter'], d['increments']))
        if owner == 'Ident':
            row['native_operands_fit'] = row['counter']['signed_ocaml_int_fits']
        elif owner == 'Task.Stdecl.Hcpt':
            backing = TRANSFERS['ephemeron_transfer'](s['outer_length'], s['bucket_nodes'], d['requests'])
            a = backing['individual_array_length_upper']
            row['backing'] = backing
            row['native_operands_fit'] = row['counter']['signed_ocaml_int_fits'] and 2*a <= min(INT_MAX, ARRAY_MAX)
        else:
            backing = TRANSFERS['weak_transfer'](s['outer_length'], s['maximum_bucket_length'],
                                                 s['allocated_key_slots'], d['requests'])
            a, b = backing['individual_outer_array_length_upper'], backing['individual_bucket_length_upper']
            row['backing'] = backing
            row['native_operands_fit'] = (row['counter']['signed_ocaml_int_fits']
                and 3*max(a,b)+6 <= INT_MAX and a <= ARRAY_MAX and b+2 <= EPHE_MAX)
        result[owner] = row
    return result


def native_runtime_limits(witness=None):
    """Decode an existing checked native constant, without executing a target."""
    path = 'retained-why-session-save-outcomes-20261019/runtime-limits.json'
    w = read(EVIDENCE / path) if witness is None else witness
    assert w['elf_identity'] == read(HERE / 'input-state.json')['installed_elf_identity']
    window, = [row for row in w['windows'] if row['address'] == 0x9d5540]
    raw = bytes.fromhex(window['hex'])
    # x86_64 endbr64; movabs immediate64,%rax; ret. No intervening branch/call.
    assert len(raw) == 15 and raw[:6] == bytes.fromhex('f30f1efa48b8') and raw[-1] == 0xc3
    tagged = int.from_bytes(raw[6:14], 'little')
    assert tagged & 1 and tagged < 1 << 63
    decoded = (tagged-1)//2
    assert decoded == w['max_wosize'] == ARRAY_MAX
    return dict(source=path, elf_identity=w['elf_identity'], function_address=0x9d5540,
                tagged_return=tagged, max_array_length=decoded, max_ephemeron_keys=decoded-2,
                new_disassembler_runs=0, target_executions=0)


def verify_inputs():
    manifest = read(HERE / 'inputs.json')
    for name, expected in manifest['files'].items():
        assert identity((REPO / name).read_bytes()) == expected, name
    for name, expected in manifest['local_data'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    native_runtime_limits()


def compose(residuals=None, *, escape=2):
    """Residuals: case -> each RESIDUALS name -> explicit six-owner vector.

    Supplying a vector is a caller hypothesis, not verified native provenance.
    Component results and full conditional arithmetic are separate fields.
    Unknown residuals are never replaced by zero. Whole-process capacity stays
    false: this interface does not cover all other counters, memo owners,
    strings, callbacks or native operands.
    """
    verify_inputs()
    natural(escape)
    if escape > 2:
        raise ValueError('one process-global e <= 2; no per-stage budget')
    if residuals is None:
        residuals = {}
    if type(residuals) is not dict or not set(residuals) <= set(CASES):
        raise ValueError('unknown process')
    states = read(HERE / 'attachment.json')
    publication = {r['case'].replace('_','-'): r for r in read(
        EVIDENCE / 'retained-why-publication-composition-20261020/result.json')['cases']}
    rows = []
    for state in states:
        case = state['case']; components = attached_components(case, escape)
        supplied = residuals.get(case, {})
        if type(supplied) is not dict or not set(supplied) <= set(RESIDUALS):
            raise ValueError('unknown residual category')
        for v in supplied.values():
            validate_vector(v)
        known = sum_vectors(components['components'].values())
        missing = sorted(set(RESIDUALS)-set(supplied))
        partial = sum_vectors([known, *supplied.values()])
        transfer = apply_transfers(state['owners'], partial)
        fits = all(v['native_operands_fit'] for v in transfer.values())
        rows.append(dict(case=case, attachment=state, demand=components,
                         known_demand=known, caller_supplied_residuals=supplied,
                         missing_residual_contracts=missing,
                         joined_known_and_supplied_demand=partial,
                         conditional_transfers=transfer, known_and_supplied_operands_fit=fits,
                         complete_six_owner_numeric_input=not missing,
                         six_owner_capacity_conditional_on_supplied_contracts=not missing and fits,
                         through_R58_complete_including_lookup=False,
                         actual_whole_process_headroom=False,
                         separate_Theory_restore_path_publications_upper=publication[case]['publications_upper'],
                         publication_count_is_constructor_count=False))
    tables = read(EVIDENCE / 'retained-why-save-table-contract-join-20261020/result.json')
    assert tables['shared_table_applications_attached'] == 206
    return dict(scope='six shared owners attached at registration; actual bounded component demand through R58 plus save binders',
                native_limits=native_runtime_limits(), cases=rows, budgets=dict(per_process_escape=escape, save_entering_callbacks_upper=2,
                    saves_upper=3, allowance_renewed_at_stage_boundary=False),
                saved_component_reused=dict(applications=206, no_resize=tables['no_resize_applications'],
                    selected_theory_replacements=tables['selected_theory_resize_replacements'],
                    source='retained-why-save-table-contract-join-20261020/result.json',
                    original_process_and_behavior_premises_retained=True,
                    next_proofAttemptID_upper={r['case']: r['usable_under_external_premises']['next_proofAttemptID_upper']
                        for r in tables['cases']}),
                actual_whole_process_headroom=False, whole_pipeline_capacity=False,
                all_memo_owner_states_and_native_operands_closed=False,
                source_argument_machine_checked=False, predecessor_checker_replays=0, native_runs=0)


if __name__ == '__main__':
    print(json.dumps(compose(), indent=2, sort_keys=True))

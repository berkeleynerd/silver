#!/usr/bin/env python3
"""Join retained task/explanation call closures and native stack witnesses.

Reads retained sources/disassembly/ELF only. Does not run predecessors, capture,
execute gnatwhy3, disassemble, solve, or reinterpret opened terms.
"""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent
DISASM = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
ELF = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
inputs = {}


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(p):
    p = Path(p)
    raw = p.read_bytes()
    inputs[str(p.relative_to(REPO)) if p.is_relative_to(REPO) else str(p)] = identity(raw)
    return raw


def js(p):
    return json.loads(read(p))


def write(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def source_witnesses():
    selections = {
        'src/core/task.ml': [(17, 74), (103, 180), (223, 276)],
        'src/core/theory.ml': [(178, 210)],
        'src/core/ident.ml': [(156, 192)],
        'src/core/ident.mli': [(1, 180)],
        'src/util/wstdlib.ml': [(13, 18), (45, 100)],
        'src/util/hcpt.ml': [(120, 158), (180, 280), (311, 343), (510, 548)],
        'src/util/extmap.ml': [(97, 249), (258, 336), (496, 540)],
        'src/util/extset.ml': [(35, 100)],
        'src/util/strings.ml': [(55, 90)],
        'src/session/termcode.ml': [(20, 98)],
        'src/gnat/gnat_main.ml': [(298, 309)],
    }
    archive = E / 'retained-why-session-helper-source-20261019/sources.tar.gz'
    read(archive)
    out = []
    with tarfile.open(archive) as stream:
        for path, ranges in selections.items():
            member = 'why3/' + path
            raw = stream.extractfile(member).read()
            lines = raw.decode().splitlines(keepends=True)
            for first, last in ranges:
                text = ''.join(lines[first-1:last])
                out.append(dict(archive=str(archive.relative_to(REPO)), member=member,
                    member_identity=identity(raw), first=first, last=min(last, len(lines)),
                    text=text, excerpt_identity=identity(text.encode())))
    # Reuse exact retained runtime source slices, independently compare to archive.
    prior = js(E / 'retained-why-ordinary-ending-control-20261020/source-excerpts.json')
    for row in prior:
        if '/runtime/signals.c' not in row['member']:
            continue
        archive = REPO / row['archive']
        read(archive)
        with tarfile.open(archive) as stream:
            raw = stream.extractfile(row['member']).read()
        assert identity(raw) == dict(bytes=row['member_bytes'], sha256=row['member_sha256'])
        text = ''.join(raw.decode().splitlines(keepends=True)[row['first']-1:row['last']])
        assert text == row['text']
        assert hashlib.sha256(text.encode()).hexdigest() == row['excerpt_sha256']
        out.append(row)
    # OCaml string/list source makes tail loops and scalar service frontier explicit.
    archive = E / 'retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
    read(archive)
    prefix = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/'
    with tarfile.open(archive) as stream:
        for path, ranges in {'stdlib/string.ml': [(1, 100)],
                             'stdlib/list.ml': [(45, 125)],
                             'stdlib/bytes.ml': [(55, 90)]}.items():
            raw = stream.extractfile(prefix+path).read()
            for first, last in ranges:
                text = ''.join(raw.decode().splitlines(keepends=True)[first-1:last])
                out.append(dict(archive=str(archive.relative_to(REPO)), member=prefix+path,
                    member_identity=identity(raw), first=first, last=last,
                    text=text, excerpt_identity=identity(text.encode())))
    write('source-witnesses.json', out)


TASK_ROOTS = ['camlWhy3__Task__used_theories_2572',
              'camlWhy3__Task__used_symbols_2581',
              'camlWhy3__Task__local_decls_2592']
EXPL_ROOTS = ['camlWhy3__Termcode__collect_expls_927',
              'camlWhy3__Termcode__concat_expls_995']

# Source-selected closure identities. These are explicit higher-order edges,
# not inferred from a symbol inventory or a name-only direct-call walk.
TASK_INDIRECT = {
    'camlWhy3__Task__task_clone_2058': ['camlWhy3__Task__fun_7131'],
    'camlWhy3__Task__filter_2602': ['camlWhy3__Extmap__min_binding_424'],
    'camlWhy3__Extmap__map_filter_859': ['camlWhy3__Task__used_2575'],
    'camlWhy3__Extmap__map_467': ['camlWhy3__Task__dict_2584', 'camlWhy3__Task__fun_7250'],
    'camlWhy3__Hcpt__fun_2987': ['camlWhy3__Task__check_use_2569'],
    'camlWhy3__Wstdlib__compare_1830': ['camlWhy3__Wstdlib__tag_2176'],
    'camlWhy3__Wstdlib__tag_2176': ['camlWhy3__Ident__tag_2120'],
    'caml_apply2': ['camlWhy3__Task__fun_7227', 'camlWhy3__Hcpt__fun_2987',
                    'camlWhy3__Wstdlib__compare_1830', 'caml_curry2', 'caml_curry2_1'],
    'caml_apply3': ['camlWhy3__Task__join_2588', 'camlWhy3__Task__fun_7254',
                    'camlWhy3__Task__fun_7260', 'caml_curry2', 'caml_curry2_1'],
    'caml_curry2_1': ['camlWhy3__Task__fun_7260', 'camlWhy3__Task__fun_7227',
                     'camlWhy3__Task__fun_7254', 'camlWhy3__Hcpt__fun_2987',
                     'camlWhy3__Wstdlib__compare_1830'],
}
EXPL_INDIRECT = {
    'camlWhy3__Extset__fun_1837': ['caml_curry2'],
    'caml_apply2': ['camlWhy3__Termcode__fun_9251', 'caml_curry2', 'caml_curry2_1'],
    'caml_apply3': ['camlWhy3__Extmap__fold_489', 'camlWhy3__Extset__fun_1837',
                    'caml_curry2', 'caml_curry2_1'],
    'caml_curry2_1': ['camlWhy3__Termcode__fun_9245',
                     'camlWhy3__Termcode__fun_9251', 'camlWhy3__Extset__fun_1837'],
}
# Closure creation references are separately retained. They do not execute the
# entry immediately, but explain the indirect target supplied at the call site.
TASK_FACTORIES = {
    'camlWhy3__Hcpt__exists_1265': ['camlWhy3__Hcpt__fun_2987'],
    'camlWhy3__Task__join_2588': ['camlWhy3__Task__fun_7260'],
    'camlWhy3__Task__dict_2584': ['camlWhy3__Task__fun_7250'],
}
EXPL_FACTORIES = {
    'camlWhy3__Extset__fold_580': ['camlWhy3__Extset__fun_1837'],
    'camlWhy3__Termcode__collect_expls_927': ['camlWhy3__Termcode__fun_9251'],
    'camlWhy3__Termcode__match_prefix_638': ['camlWhy3__Termcode__fun_9245'],
}
SERVICES = {'caml_raise_exn', 'caml_call_gc', 'caml_c_call',
            'caml_blit_bytes', 'caml_blit_string', 'caml_ml_array_bound_error'}
DISPATCH = ['caml_process_pending_actions_exn', 'caml_process_pending_actions_with_root_exn',
            'caml_process_pending_actions', 'caml_process_pending_actions_with_root',
            'caml_do_pending_actions_exn', 'caml_process_pending_signals_exn',
            'caml_execute_signal_exn', 'caml_callback_exn', 'caml_callback_asm',
            'caml_start_program', 'camlGnat_main__save_session_and_exit_3133',
            'camlGnat_main__fun_14206', 'camlGnat_main__entry',
            'caml_call_gc', 'caml_c_call']


def direct(body):
    return sorted(set(n.split('+')[0] for n in re.findall(
        r'\b(?:call|jmp)\s+[0-9a-f]+ <([^>]+)>', body)))


def closure(bodies, roots, indirect, factories):
    seen, frontier, rows = set(), set(), {}
    todo = list(roots)
    while todo:
        n = todo.pop()
        if n in SERVICES:
            frontier.add(n)
            continue
        if n in seen:
            continue
        seen.add(n)
        assert n.startswith(('camlWhy3__', 'camlStdlib__', 'caml_apply', 'caml_curry')), n
        body = bodies[n]
        transfers = direct(body)
        sites = re.findall(r'^\s*([0-9a-f]+):.*\b(?:call|jmp)\s+\*([^\n]+)', body, re.M)
        assert bool(sites) == (n in indirect), (n, sites)
        callbacks = indirect.get(n, [])
        made = factories.get(n, [])
        bridge_targets = []
        if 'caml_c_call' in transfers:
            # The bridge's register target is a concrete allocation primitive,
            # not an arbitrary unclassified C function pointer.
            assert n in ['camlStdlib__$5e_141', 'camlStdlib__Bytes__sub_302',
                         'camlStdlib__String__concat_419'], n
            assert '<caml_create_bytes>' in body, n
            bridge_targets = ['caml_create_bytes']
        for target in made:
            assert '<' + target + '>' in body, (n, target)
        rows[n] = dict(direct=transfers, indirect_sites=sites,
                       selected_indirect_targets=callbacks, created_closure_entries=made,
                       selected_c_bridge_service_targets=bridge_targets)
        todo += transfers + callbacks + made
    assert set(indirect) <= seen
    assert set(factories) <= seen
    return dict(roots=roots, bodies=sorted(seen), services=sorted(frontier), transfers=rows)


def native():
    raw = read(DISASM)
    assert identity(raw) == dict(bytes=69046582, sha256='f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5')
    bodies = {m[1]:m[0] for m in re.finditer(
        r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)', raw.decode(), re.M | re.S)}
    task = closure(bodies, TASK_ROOTS, TASK_INDIRECT, TASK_FACTORIES)
    expl = closure(bodies, EXPL_ROOTS, EXPL_INDIRECT, EXPL_FACTORIES)
    write('call-closures.json', dict(task=task, explanation_helpers=expl,
        claim='Source-selected complete five-root closures to explicit services; excludes callers.'))
    keep = sorted(set(task['bodies'] + expl['bodies'] + DISPATCH))
    elf = read(ELF)
    assert identity(elf) == dict(bytes=24561432, sha256='7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368')
    h = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
    segments = [struct.unpack_from('<IIQQQQQQ', elf, h[5]+i*h[9]) for i in range(h[10])]
    frames, total = {}, 0
    for n in keep:
        body = bodies[n]
        code = []
        for line in body.splitlines()[1:]:
            m = re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)', line)
            if not m:
                assert not line.strip(), line
                continue
            address, bs = int(m[1], 16), bytes.fromhex(m[2])
            seg = next(s for s in segments if s[0] == 1 and s[3] <= address and address+len(bs) <= s[3]+s[5])
            offset = seg[2]+address-seg[3]
            assert elf[offset:offset+len(bs)] == bs, (n, address)
            total += len(bs)
            if m[3]:
                code.append(m[3])
        if n in task['bodies'] or n in expl['bodies']:
            reservations = re.findall(r'\bsub\s+\$0x([0-9a-f]+),%rsp', body)
            pushes = re.findall(r'\bpush\s+[^\n]+', body)
            assert len(reservations) <= 1, n
            if reservations:
                assert code[0] == f'sub    $0x{reservations[0]},%rsp', n
            assert len(pushes) in [0, 2], n
            traps = 16 if pushes else 0
            assert bool(traps) == (n in ['camlWhy3__Task__filter_2602',
                'camlWhy3__Termcode__collect_expls_927', 'camlWhy3__Termcode__fun_9245']), n
            base = 8 + (int(reservations[0],16) if reservations else 0)
            frames[n] = dict(base_own_bytes=base, trap_bytes=traps,
                own_high_water_upper=base+traps, body_identity=identity(body.encode()))
    # Body-wide checks support the selected-path C frame facts; they are not a
    # general x86 stack interpreter. Path arithmetic is retained in dispatch.json.
    expected = {
        'caml_process_pending_actions_exn': (['60'], 1),
        'caml_process_pending_actions_with_root_exn': (['60'], 1),
        'caml_process_pending_actions': (['60'], 1),
        'caml_process_pending_actions_with_root': (['60'], 1),
        'caml_do_pending_actions_exn': (['8'], 0),
        'caml_process_pending_signals_exn': (['98'], 4),
        'caml_execute_signal_exn': (['118'], 4),
        'caml_callback_exn': (['18'], 0),
        'caml_callback_asm': (['8'], 6),
        'caml_start_program': (['8', '8'], 11),
        'camlGnat_main__save_session_and_exit_3133': (['18'], 2),
        'camlGnat_main__fun_14206': ([], 0),
        'caml_call_gc': (['1000', '80'], 13),
        'caml_c_call': (['8', '1000'], 0),
    }
    for n, (subs, pushes) in expected.items():
        assert re.findall(r'\bsub\s+\$0x([0-9a-f]+),%rsp', bodies[n]) == subs, n
        assert len(re.findall(r'\bpush\s', bodies[n])) == pushes, n
    assert 'jmp    9e3fec <caml_start_program+0x18>' in bodies['caml_callback_asm']
    assert 'jmp    52e680 <camlGnat_main__save_session_and_exit_3133>' in bodies['camlGnat_main__fun_14206']
    assert '<camlGnat_main__fun_14206>' in bodies['camlGnat_main__entry']
    handler = bodies['camlGnat_main__save_session_and_exit_3133']
    assert handler.index('pop    0x10(%r14)') < handler.index('call   7fc850 <camlWhy3__Session_itp__save_session_4339>')
    for n in ['caml_c_call', 'caml_call_gc']:
        v = bodies[n]
        assert v.index('sub    $0x1000,%rsp') < v.index('(%rsp)', v.index('sub    $0x1000,%rsp')) < v.index('add    $0x1000,%rsp')
    loops = {
        'camlStdlib__List__rev_append_308': '948d14',
        'camlStdlib__List__fold_left_521': '9491c4',
        'camlStdlib__String__sum_lengths_403': '951b44',
        'camlStdlib__String__unsafe_blits_410': '951be4',
        'camlWhy3__Strings__remove_prefix_576': '546e89',
        'camlWhy3__Hcpt__min_binding_947': '551fb4',
    }
    for n, address in loops.items():
        assert re.search(r'\bj(?:mp|a)\s+'+address+r'\s', bodies[n]), (n,address)
        assert not re.search(r'\bcall\s+[0-9a-f]+ <'+re.escape(n)+'>', bodies[n]), n
        frames[n]['tail_loop_backedge'] = address
    write('native-bodies.json', {n:bodies[n] for n in keep})
    write('native-frames.json', frames)
    return task, expl, frames, dict(bodies=len(keep), checked_instruction_bytes=total)


def bounds(task, expl, frames, checked):
    old = js(E / 'retained-why-save-stack-composition-20261020/result.json')
    initial = {r['case']:r for r in js(E / 'retained-why-initial-registration-bound-20261020/result.json')['cases']}
    attrs = {r['case']:r['explanation'] for r in js(E / 'retained-why-session-shape-transfer-20261020/bounds.json')}
    # Exact native bodies, loose per-body simultaneous multiplicities. These are
    # context counts, not a maximum frame size assigned to unknown functions.
    recursive = {
        'camlWhy3__Task__filter_2602': 'C+1',
        'camlWhy3__Extmap__map_467': '2*(I+1)',
        'camlWhy3__Extmap__map_filter_859': 'I+1',
        'camlWhy3__Extmap__fold_489': 'I+1',
        'camlWhy3__Extmap__union_590': '2*I+1',
        'camlWhy3__Extmap__split_557': '2*I+1',
        'camlWhy3__Extmap__join_527': '2*I+1',
        'camlWhy3__Extmap__add_min_binding_511': '2*I+1',
        'camlWhy3__Extmap__add_max_binding_519': '2*I+1',
        'camlWhy3__Extmap__remove_min_binding_434': '2*I+1',
        'camlWhy3__Hcpt__exists_908': '64',
        'caml_apply2': '4', 'caml_apply3': '4',
        'caml_curry2': '4', 'caml_curry2_1': '4',
    }
    task_factors = {n:recursive.get(n,'1') for n in task['bodies']}
    expl_factors = {n:('A+1' if n == 'camlWhy3__Extmap__fold_489' else
                       '4' if n.startswith(('caml_apply','caml_curry')) else '1')
                    for n in expl['bodies']}
    write('multiplicities.json', dict(task=task_factors, explanation_helpers=expl_factors,
        rationale='See note: two nested map contexts; fold plus union; strict subtree and task suffix; 63-bit Patricia depth; bounded application contexts.'))
    cases = []
    for row in old['cases']:
        case = row['case']
        I, C, A = initial[case]['initial_registration_count'], row['max_task_chain_length'], attrs[case]['attribute_union_count']
        assert initial[case]['pid'] == row['fresh_pid']
        assert attrs[case]['typed_attribute_closure_established']
        env = dict(I=I,C=C,A=A)
        def subtotal(factors):
            return sum(frames[n]['own_high_water_upper'] * eval(f, {'__builtins__':{}}, env)
                       for n,f in factors.items())
        T, X = subtotal(task_factors), subtotal(expl_factors)
        assert T == 688*I + 64*C + 3440
        assert X == 32*A + 768
        # Old task_filter projection is wholly replaced by the closed three-root
        # component. Other duplicated leaf/context charges merely overcount.
        P = row['scoped_projection_per_save_bytes'] - row['scoped_components_per_save']['task_filter'] + T + X
        cases.append(dict(case=case, fresh_pid=row['fresh_pid'], logical_pid=row['logical_pid'],
            I=I,C=C,explanation_attribute_union=A,
            task_selection_complete_to_services_bytes=T,
            explanation_helpers_complete_to_services_bytes=X,
            substituted_covered_projection_per_save_bytes=P,
            covered_projection_three_saves_with_dispatch_and_direct_bridges_bytes=3*P+2*816+3*4104,
            complete_save_added_stack_upper=None,
            complete_tool_owned_stack_established=False,
            trusted_service_stack=None, preexisting_preparation_stack=None))
    dispatch = dict(selected_pending_wrapper_bytes=112, do_pending_bytes=16,
        pending_signals_bytes=192, execute_signal_bytes=320, callback_exn_bytes=32,
        callback_asm_and_shared_continuation_bytes=112, handler_while_saving_bytes=32,
        dispatch_to_save_shell_bytes=816, complete_handler_setter_exit_stack=None,
        callback_asm_formula='8 return + 6*8 saved registers + 8 local + 8 shared local + 3*8 runtime fields + 2*8 trap',
        bridge_gc_live_bytes=240, bridge_transient_high_water_bytes=4104,
        bridge_scope='One direct OCaml-to-service crossing per active selected save; service-owned nested crossings stay in R. Handler setter/exit phases and other callback owners are not silently included.',
        complete_pending_callback_stack_established=False)
    assert sum(dispatch[k] for k in ['selected_pending_wrapper_bytes','do_pending_bytes',
        'pending_signals_bytes','execute_signal_bytes','callback_exn_bytes',
        'callback_asm_and_shared_continuation_bytes','handler_while_saving_bytes']) == 816
    write('dispatch.json', dispatch)
    result = dict(cases=cases, native=checked, task_selection_roots_closed_to_services=True,
        collect_concat_roots_closed_to_services=True, complete_save_stack_established=False,
        complete_save_added_stack_upper=None, native_target_runs=0, captures=0,
        new_disassembly_runs=0, predecessor_checker_replays=0, solver_runs=0,
        unresolved_tool_owned_instances=[
            'goal_expl_task/search_attrs/t_fold caller and binder-construction descendants',
            'shape identifier printer/string/constant and fresh-variable/attribute-copy descendants',
            'serializer statistics/table/sort/predicate and filename/path wrappers',
            'selected formatter core and all XML/shape/decoded-name callback instances',
            'handler setter/exit and other selected reporting/callback owners outside dispatch-to-save shell'])
    write('result.json', result)
    write('inputs.json', inputs)
    print(json.dumps(dict(ok=True, native=checked,
        task_bodies=len(task['bodies']), explanation_helper_bodies=len(expl['bodies']),
        task_selection_bytes=[r['task_selection_complete_to_services_bytes'] for r in cases],
        explanation_helper_bytes=[r['explanation_helpers_complete_to_services_bytes'] for r in cases],
        complete_save_added_stack_upper=None), sort_keys=True))


source_witnesses()
bounds(*native())

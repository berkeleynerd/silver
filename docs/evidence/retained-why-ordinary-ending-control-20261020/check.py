#!/usr/bin/env python3
"""Focused source-binding/protocol checks; not a source-semantics machine proof."""
from pathlib import Path
from collections import deque
import argparse
import hashlib
import importlib.util
import json
import re
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]

def sha(data):
    return hashlib.sha256(data).hexdigest()

def read(name):
    return json.loads((HERE/name).read_text())

def require(condition, message):
    if not condition:
        raise AssertionError(message)

def ocaml_code(text):
    """Mask nested comments and strings for the narrowly used keyword checks."""
    out = list(text)
    i, depth, quoted = 0, 0, False
    while i < len(text):
        if depth:
            if text.startswith('(*', i):
                out[i:i+2] = '  '; depth += 1; i += 2
            elif text.startswith('*)', i):
                out[i:i+2] = '  '; depth -= 1; i += 2
            else:
                if text[i] != '\n': out[i] = ' '
                i += 1
        elif quoted:
            if text[i] == '\\' and i+1 < len(text):
                out[i:i+2] = '  '; i += 2
            else:
                if text[i] == '"': quoted = False
                if text[i] != '\n': out[i] = ' '
                i += 1
        elif text.startswith('(*', i):
            out[i:i+2] = '  '; depth = 1; i += 2
        elif text[i] == '"':
            out[i] = ' '; quoted = True; i += 1
        else:
            i += 1
    require(depth == 0 and not quoted, 'complete comment/string projection')
    return ''.join(out)

def protocol_model():
    """Selected successful mask/ignore protocol; no cap imposed on save count.

    State is (phase, OS-ignore committed, old runtime pending bit, saves).
    External deliveries before blocking can set the bit arbitrarily often.
    Blocked OS deliveries cannot enter the OCaml callback; ignore discards them.
    An exception can return to a higher ordinary-save catch and permit dispatch.
    There is deliberately no handler-normal-return edge.
    """
    initial = [('idle', ignored, bit, 0) for ignored in (False,True) for bit in (0,1)]
    seen = set(initial)
    todo = deque(initial)
    edges = 0
    while todo:
        phase, ignored, bit, saves = state = todo.popleft()
        successors = []
        if phase != 'terminal':
            # Unbounded external-delivery stutters are represented by this edge.
            successors.append((phase,ignored,1 if not ignored and phase in ('idle','selected') else bit,saves))
        if phase == 'idle' and bit:
            successors.append(('selected',ignored,0,saves))
        if phase == 'selected':
            successors.append(('blocked',ignored,bit,saves))
        if phase == 'blocked':
            successors += [('committed',True,bit,saves), ('idle',ignored,bit,saves)]
        if phase == 'committed':
            successors += [('saving',True,bit,saves+1), ('idle',True,bit,saves)]
        if phase == 'saving':
            successors += [('idle',True,bit,saves), ('terminal',True,bit,saves)]
        for successor in successors:
            edges += 1
            require(successor[3] <= 2, 'protocol-derived save callback bound')
            if successor not in seen:
                seen.add(successor); todo.append(successor)
    require(any(s[3] == 2 for s in seen), 'stale-bit second save is represented')
    require(not any(s[0] == 'saving' and not s[1] for s in seen), 'save follows ignore commit')
    return dict(states=len(seen), edges=edges, maximum_save_callbacks=max(s[3] for s in seen),
        handler_normal_return_edges=0, simultaneous_signal_saves=1,
        interpretation='conditional finite model, not machine-checked source refinement')

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write-result', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    inputs = read('inputs.json')
    for path, expected in inputs['inputs'].items():
        b = (ROOT/path).read_bytes()
        require(len(b) == expected['bytes'] and sha(b) == expected['sha256'], f'input identity: {path}')
    excerpts = read('source-excerpts.json')
    ids = {x['id']:x for x in excerpts}
    require(len(ids) == len(excerpts), 'unique excerpt IDs')
    members = {}
    archives = {}
    try:
        for row in excerpts:
            archive = archives.setdefault(row['archive'], None)
            if archive is None:
                archive = archives[row['archive']] = tarfile.open(ROOT/row['archive'])
            key = (row['archive'], row['member'])
            if key not in members:
                members[key] = archive.extractfile(row['member']).read()
            b = members[key]
            require(len(b) == row['member_bytes'] and sha(b) == row['member_sha256'], f'member identity: {row["id"]}')
            text = ''.join(b.decode().splitlines(keepends=True)[row['first']-1:row['last']])
            require(text == row['text'] and sha(text.encode()) == row['excerpt_sha256'], f'exact LF excerpt: {row["id"]}')
    finally:
        for archive in archives.values():
            if archive is not None: archive.close()
    ledger = read('control-ledger.json')
    require(len({r['id'] for r in ledger}) == len(ledger), 'unique receiving families')
    for row in ledger:
        require(row['source_refs'] and all(ref in ids for ref in row['source_refs']), f'ledger correspondence: {row["id"]}')
        require(bool(row['receives']) and bool(row['effect']), 'explicit receiving/effect partition')

    source_assertions = 0
    def contains(key, *tokens):
        nonlocal source_assertions
        for token in tokens:
            require(token in ids[key]['text'], f'source anchor {key}: {token}')
            source_assertions += 1
    contains('scheduler','with Exit -> ending ()')
    contains('ending_handler','C.remove_all_valid_ce_attempt','(fun () -> C.save_session c);',
        'Gnat_checks.iter (report_messages c);','with Invalid_argument _ -> () end;',
        'C.save_session c;\n  exit signum','Gnat_scheduler.main_loop (ending c)',
        'Gnat_util.abort_with_message ~internal:true s')
    contains('session_mutators','Hpn.add s.session_raw_tasks node_id t;',
        'pn.proofn_transformations <- node_id::pn.proofn_transformations')
    contains('session_save','Sshape.clear_only_shape s;','Termcode.goal_expl_task ~root t',
        'Sshape.compute_and_add_shape s ~expl g t;','save f fs s')
    contains('session_fold','f acc (APa paid)','f acc (APn pnid)')
    contains('ending_cleanup','| Session_itp.APa paid ->','Session_itp.remove_subtree')
    contains('shape_dictionary','let current_shape = ref []','Buffer.clear Shape.shape_buffer;',
        'with Shape.ShapeTooLong -> ()','let pr = Ident.create_ident_printer []')
    contains('task_selection','try filter acc (skip (Mid.find id symbmap) rest)',
        'with Not_found -> filter (d::acc) rest')
    contains('exit','do_at_exit ();','sys_exit retcode','if Atomic.compare_and_set f_yet_to_run true false then f ()')
    contains('signal_dispatch','caml_callback_exn(','return res;')
    contains('pending_actions','if (Is_exception_result(exn)) goto exception;')
    contains('raise_result','if (Is_exception_result(res)) caml_raise(Extract_exception(res));')
    contains('protect','| exception work_exn ->','finally_no_exn () ;')
    # Verify the claimed absence across the full retained implementations, not
    # only the selected excerpts. The source graph/primitive relation is separate.
    no_receiving_catch = []
    for key in ('buffer','format_buffer'):
        row = ids[key]
        code = ocaml_code(members[(row['archive'],row['member'])].decode())
        require(re.search(r'\btry\b|\|\s*exception\b',code) is None, f'no receiving catch in full {key} implementation')
        no_receiving_catch.append(row['member'])
    protocol = protocol_model()

    spec = importlib.util.spec_from_file_location('ordinary_transfer', HERE/'transfer.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    checks = 0
    for k in (0,1,2):
        for b,j,g,l in [(0,0,0,0),(7,5,3,101),(2**62,2**62,2**62,2**62)]:
            r = module.transfer(binders=b,shape_insertions=j,apn_visits=g,shape_bytes=l,
                signal_protocol_established=True,ordinary_source_transfer_established=True,remaining_signals=k)
            require(r['save_traversals_upper'] == 1+k, 'ordinary plus remaining callbacks')
            require(r['mathematical_upper'] == dict(binders=(1+k)*b,shape_insertions=(1+k)*j,
                apn_visits=(1+k)*g,shape_bytes=(1+k)*l), 'mathematical products')
            require(not r['whole_pipeline_capacity_established'] and not r['complete_save_capacity_established'], 'no lifted complete capacity')
            checks += 3
    for missing in ('signal_protocol_established','ordinary_source_transfer_established','remaining_signals'):
        kw = dict(binders=7,shape_insertions=5,apn_visits=3,shape_bytes=101,
            signal_protocol_established=True,ordinary_source_transfer_established=True,remaining_signals=2)
        kw[missing] = None
        r = module.transfer(**kw)
        require(r['save_traversals_upper'] is None and all(v is None for v in r['mathematical_upper'].values()), 'unestablished control remains unknown')
        checks += 1
    r = module.transfer(signal_protocol_established=True,ordinary_source_transfer_established=True,remaining_signals=2)
    require(all(v is None for v in r['mathematical_upper'].values()), 'unjoined forest remains unknown')
    checks += 1
    require(r['shape_buffer_bound_scope'] == 'position after the first save-owned clear; entry position/backing require separate bounds', 'shape byte product excludes entry backing')
    checks += 1
    for bad in (-1,True,1.5,'1'):
        try: module.transfer(binders=bad)
        except ValueError: pass
        else: raise AssertionError('malformed mathematical input accepted')
        checks += 1
    try: module.transfer(remaining_signals=3)
    except ValueError: pass
    else: raise AssertionError('unproved extra callbacks accepted')
    checks += 1
    result = dict(scope='ordinary-ending source/control transfer with uninstantiated forest bounds',
        input_files=len(inputs['inputs']), source_members=len(members), exact_excerpts=len(excerpts),
        receiving_families=len(ledger), source_anchor_checks=source_assertions,
        no_receiving_catch_in=no_receiving_catch, protocol_model=protocol,
        transfer_checks=checks, source_semantics_machine_proved=False,
        actual_forest_join_established=False, source_control_argument_review_status='pending',
        complete_save_capacity_established=False, shape_dictionary_consistency_established=False,
        whole_pipeline_capacity_established=False, native_target_executions=0)
    if args.write_result:
        (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    else:
        require(result == read('result.json'), 'retained result equality')
    print(json.dumps(dict(result=result,check_seconds=time.monotonic()-start)))

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Offline packet checks, optionally regenerating static ELF extraction.

Witness checks establish retained evidence consistency, not semantic closure.
No native target, debugger, compiler or solver is executed.
"""
import argparse
import json
from pathlib import Path
import tarfile
import time
import audit

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def checked_archive(path, spec):
    assert audit.identity(path.read_bytes()) == spec['identity'], path
    with tarfile.open(path) as t:
        assert sorted(t.getnames()) == sorted(spec['members']), path
        out = {}
        for n, expected in spec['members'].items():
            b = t.extractfile(n).read()
            assert audit.identity(b) == expected, (path, n)
            out[n] = b
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--regenerate', action='store_true')
    parser.add_argument('--install', type=Path, default=audit.INSTALL)
    parser.add_argument('--objdump', type=Path, default=audit.OBJDUMP)
    args = parser.parse_args()
    started = time.monotonic()
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for n, h in inputs['predecessor_files'].items():
        assert audit.identity((ROOT / n).read_bytes()) == h, n
    for n, h in inputs['local_inputs'].items():
        assert audit.identity((HERE / n).read_bytes()) == h, n
    sources = checked_archive(HERE / 'sources.tar.gz', inputs['archives']['sources.tar.gz'])
    native = checked_archive(HERE / 'native.tar.gz', inputs['archives']['native.tar.gz'])
    index = json.loads(sources['source-index.json'])
    assert set(index) == set(sources) - {'source-index.json'}
    for n, h in index.items():
        assert audit.identity(sources[n]) == {k: h[k] for k in ('bytes', 'sha256')}
        rev = inputs['ocaml_revision'] if n.startswith('ocaml/') else inputs['why3_revision']
        assert h['revision'] == rev
    facts = json.loads(native['native-audit.json'])
    bodies = native['native-bodies.txt'].decode()
    binding = json.loads((HERE / 'binding.json').read_text())
    predecessor = HERE.parent / 'retained-why-inline-identifier-state-20261018'
    with tarfile.open(predecessor / 'capture.tar.gz') as t:
        members = {n: t.extractfile(n).read() for n in binding['predecessor_capture_members']}
    for n, b in members.items():
        assert audit.identity(b) == binding['predecessor_capture_members'][n]
    summary = json.loads(members['capture/summary.json'])
    plan = json.loads(members['plan.json'])
    assert summary['completed'] and not summary['failures']
    assert summary['mapped_files'] == binding['mapped_files']
    assert binding['planned_executable'] == {
        k: v for k, v in plan['file_identities'].items() if k.endswith('/gnatwhy3')}
    mapped = {Path(p).name: v for p, v in summary['mapped_files'].items()}
    assert {n for n in mapped if n.endswith('.cmxs')} == {'ada_terms.cmxs', 'gnat_json.cmxs'}
    for n, h in facts['input_identities'].items():
        assert h == mapped[n]
        assert (h['bytes'], h['sha256']) == audit.EXPECTED[n]
    assert list(binding['planned_executable'].values()) == [mapped['gnatwhy3']]
    old = json.loads((predecessor / 'result.json').read_text())
    result = json.loads((HERE / 'result.json').read_text())
    assert result['registration_transfer'] == old['registration_transfer']
    assert result['registration_transfer']['counter_after_call_upper'] == 61641
    assert result['registration_transfer']['initial'] == 60496
    assert result['registration_transfer']['registrations_upper'] == 1145
    assert result['private_counter_plus_accounted_source_increment_fit'] is True
    for k in ['complete_continuing_call_counter_capacity_established',
              'runtime_identifier_reentrancy_closure_established',
              'complete_OCaml_callback_registration_reachability_established',
              'live_finalizer_registry_observed', 'source_argument_machine_checked',
              'actual_signal_or_missing_task_observed',
              'prior_history_no_overflow_established', 'prior_freshness_established',
              'family_wide_counter_invariance_established',
              'future_or_other_invocations_bounded', 'auxiliary_continuing_capacity_established',
              'complete_transform_capacity_established', 'whole_pipeline_capacity_established',
              'SIGINT_mask_enforced_or_validated']:
        assert result[k] is False, k
    assert result['new_native_target_runs'] == result['solver_runs'] == 0

    # Source witness assertions protect the named argument from accidental drift.
    def src(name, *snippets):
        s = sources[name].decode()
        for snippet in snippets:
            assert snippet in s, (name, snippet)
    src('why3/src/gnat/gnat_main.ml',
        'with Invalid_argument _ -> () end;\n  C.save_session c;\n  exit signum',
        'Sys.set_signal Sys.sigint (Sys.Signal_handle (save_session_and_exit c))')
    src('why3/src/session/session_itp.ml',
        'let get_task s id =\n  Hpn.find s.session_raw_tasks id',
        '| APn g when not (is_detached s any)', 'let t = get_task s g',
        'Sshape.compute_and_add_shape s ~expl g t',
        'Gshape.t_bound_shape_task gs ~version ~expl t')
    src('why3/src/session/termcode.ml', 'Shape.t_shape ~version pr c m f',
        't_open_branch b', 't_open_bound b', 't_open_quant b')
    src('why3/src/core/term.ml', 'create_vsymbol (id_clone v.vs_name) v.vs_ty',
        'vs_name = id_register name;')
    src('why3/src/core/ident.ml', 'id_tag    = (incr r; Weakhtbl.create_tag !r);')
    src('why3/src/core/trans.ml', 'try Some (Wtask.find h task)\n    with Not_found -> None',
        '| None   -> accum (task::todo) task.task_prev')
    src('ocaml/runtime/signals.c', 'res = caml_callback_exn(',
        'exn = caml_process_pending_signals_exn();',
        'if (Is_exception_result(exn)) goto exception;', 'return exn;')
    src('ocaml/stdlib/stdlib.ml', 'do_at_exit ();\n  sys_exit retcode',
        'if Atomic.compare_and_set f_yet_to_run true false then f () ;')
    # Exact pinned instruction address and text, without claiming a CFG proof.
    for addr, text in [
        ('52e6d1', 'pop    0x10(%r14)'),
        ('52e6fb', 'call   7fc850 <camlWhy3__Session_itp__save_session_4339>'),
        ('52e709', 'jmp    9415f0 <camlStdlib__exit_488>'),
        ('5aea7e', 'mov    %rsp,0x10(%r14)'),
        ('5aea98', 'call   9a0000 <camlStdlib__Ephemeron__find_730>'),
        ('5aeacb', 'mov    0x38(%rbx),%rbx'),
        ('99ff17', 'cmp    (%r14),%r15'),
        ('99ff1a', 'jbe    99ffe8'),
        ('99ff20', 'test   $0x1,%dil'),
        ('99ffe8', '<caml_call_gc>')]:
        assert any(line.lstrip().startswith(addr + ':') and text in line
                   for line in bodies.splitlines()), (addr, text)
    external_gc = [r for r in facts['code_references']
                   if 'camlStdlib__Gc:code' in r['groups']
                   and not r['function'].startswith('camlStdlib__Gc')]
    assert [r['function'] for r in external_gc] == ['caml_program']
    hook_refs = [r for r in facts['code_references'] if 'caml_channel_mutex_free' in r['groups']]
    assert {r['function'] for r in hook_refs} == {
        'caml_thread_initialize', 'caml_finalize_channel', 'caml_close_channel'}
    assert not [r for r in facts['data_references'] if 'caml_channel_mutex_free' in r['groups']]
    sites = facts['custom_allocator_sites']
    assert len(sites) == 128 and len({r['function'] for r in sites}) == 96
    unknown = [r for r in sites if not any('<' + n + '>' in (r['last_textual_rdi_write'] or '')
                                         for n in audit.OPS)]
    assert len(unknown) == 1 and unknown[0]['function'] == 'caml_alloc_final'
    for n in ['finalisable_first', 'finalisable_last', 'running_finalisation_function']:
        storage = facts['selected_storage'][n]
        assert storage['zero_fill'] and not storage['runtime_value_observed']
        assert 'file_bytes' not in storage

    # Focused regressions for earlier unsafe BSS file slices and false RIP hits.
    e = audit.ELF.__new__(audit.ELF)
    e.data = bytes(16)
    e.segments = [dict(type=1, vaddr=0x1000, offset=0, filesz=8, memsz=16)]
    assert e.read(0x1000, 8) == bytes(8)
    try:
        e.read(0x1008, 8)
    except ValueError:
        pass
    else:
        raise AssertionError('zero-fill tail incorrectly read as file bytes')
    assert audit.operand_addresses('lea 0x20(%rip),%rax', 0x1000, 7) == {0x1027}
    assert audit.operand_addresses('mov 0x20(%rax),%rax', 0x1000, 7) == set()
    assert audit.operand_addresses('mov $0x1234,%rax', 0x1000, 7) == {0x1234}
    assert audit.operand_addresses('call 1234 <f>', 0x1000, 5) == {0x1234}
    if args.regenerate:
        regenerated, rbodies = audit.audit(args.install, args.objdump)
        # tuples in the in-memory ranges serialize as the frozen JSON arrays.
        assert json.loads(json.dumps(regenerated)) == facts
        assert rbodies.encode() == native['native-bodies.txt']
    print(json.dumps(dict(status='pass', elapsed_seconds=time.monotonic() - started,
                         regenerated_ELF_extraction=args.regenerate,
                         new_native_target_runs=0, source_files=len(index),
                         code_references=len(facts['code_references']),
                         data_references=len(facts['data_references']),
                         accounted_endpoint=61641, complete_endpoint_established=False,
                         checks='input/member hashes; retained capture binding; source/native witnesses; scoped result flags; BSS and numeric-operand regressions')))


if __name__ == '__main__':
    main()

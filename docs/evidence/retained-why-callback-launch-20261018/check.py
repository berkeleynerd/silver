#!/usr/bin/env python3
"""Focused retained-source, ELF-byte and finite-abstraction checks only."""
import hashlib
from html.parser import HTMLParser
import importlib.util
import json
from pathlib import Path
import re
import tarfile
import time
import xml.etree.ElementTree as ET
import multiplicity

P = Path(__file__).resolve().parent
ROOT = P.parents[2]
PRE = P.parent / 'retained-why-inline-callback-closure-20261018'
spec = importlib.util.spec_from_file_location('retained_audit', PRE / 'audit.py')
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


def archive(path, expected):
    assert audit.identity(path.read_bytes()) == expected['identity'], path
    with tarfile.open(path) as t:
        assert sorted(t.getnames()) == sorted(expected['members'])
        out = {n: t.extractfile(n).read() for n in t.getnames()}
    for n, h in expected['members'].items():
        assert audit.identity(out[n]) == h, n
    return out


class Plain(HTMLParser):
    def __init__(self):
        super().__init__()
        self.parts = []

    def handle_data(self, data):
        self.parts.append(data)


def main():
    start = time.monotonic()
    inputs = json.loads((P / 'inputs.json').read_text())
    for n, h in inputs['reused_files'].items():
        assert audit.identity((ROOT / n).read_bytes()) == h, n
    for n, h in inputs['local_inputs'].items():
        assert audit.identity((P / n).read_bytes()) == h, n
    src = archive(P / 'sources.tar.gz', inputs['archives']['sources.tar.gz'])
    old_inputs = json.loads((PRE / 'inputs.json').read_text())
    old_src = archive(PRE / 'sources.tar.gz', old_inputs['archives']['sources.tar.gz'])
    index = json.loads(src.pop('source-index.json'))
    for n, h in index.items():
        assert audit.identity(src[n]) == {k: h[k] for k in ('bytes', 'sha256')}
    src.update({n: b for n, b in old_src.items() if n != 'source-index.json'})

    def has(n, *snippets):
        s = src[n].decode()
        for text in snippets:
            assert text in s, (n, text)

    has('ocaml/runtime/signals_nat.c', 'caml_record_signal(sig);',
        'sigact.sa_handler = SIG_IGN;',
        'if (sigaction(signo, &sigact, &oldsigact) == -1) return -1;')
    has('ocaml/runtime/signals.c', 'caml_pending_signals[signal_number] = 1;',
        'if(sigismember(&set, i))\n      continue;',
        'caml_pending_signals[i] = 0;', 'caml_execute_signal_exn(i, 0)',
        'caml_sigmask_hook(SIG_BLOCK, &nsigs, &sigs);',
        'caml_sigmask_hook(SIG_SETMASK, &sigs, NULL);')
    s = src['ocaml/runtime/signals.c'].decode()
    install = s[s.index('CAMLprim value caml_install_signal_handler'):]
    assert install.index('oldact = caml_set_signal_action(sig, act);') < install.index('res = caml_alloc_small (1, 0);') < install.index('caml_process_pending_signals_exn()')
    has('why3/src/gnat/gnat_main.ml',
        'Sys.set_signal Sys.sigint Sys.Signal_ignore;',
        'with Invalid_argument _ -> () end;\n  C.save_session c;\n  exit signum')
    has('ocaml/otherlibs/systhreads/st_posix.h',
        'pthread_sigmask(SIG_BLOCK, &mask, NULL);',
        '#define SIGPREEMPTION SIGVTALRM', 'caml_record_signal(SIGPREEMPTION);')
    has('why3/src/session/termcode.ml', 'Term.t_fold aux acc f',
        'let res = get_expls_fmla (Task.task_goal_fmla task)',
        'let vl,triggers,f1 = t_open_quant b in',
        'Shape.t_shape ~version pr c m f',
        'if Buffer.length shape_buffer >= 1024 then raise ShapeTooLong')
    has('why3/src/core/term.ml', 'let _, tl, f1 = t_open_quant b in tr_fold fn (fn acc f1) tl',
        'create_vsymbol (id_clone v.vs_name) v.vs_ty')
    has('why3/src/gnat/gnat_checks.ml',
        'if Gnat_config.stand_alone then begin',
        'Prove_client.connect_external Gnat_config.socket_name')
    has('why3/src/server/server-unix.c', 'if (setpgid(0, 0) == -1)',
        'kill_processes(client->fd, NULL);', 'if (single_client && list_is_empty(clients))')
    has('why3/src/server/proc.c', 'kill(-p->id, SIGKILL);')
    for n, text in [
        ('posix/V2_chap02.html', 'Setting a signal action to SIG_IGN for a signal that is pending shall cause the pending signal to be discarded, whether or not it is blocked.'),
        ('posix/posix_spawn.html', 'the child process shall initially have the signal mask specified in the spawn-sigmask attribute')]:
        parser = Plain()
        parser.feed(src[n].decode())
        plain = ' '.join(' '.join(parser.parts).split())
        assert text in plain, n
    native = json.loads((P / 'native-witnesses.json').read_text())
    elf = audit.ELF((audit.INSTALL / 'bin/gnatwhy3').read_bytes())
    assert audit.identity(elf.data) == native['executable']
    checked = 0
    for name, body in native['bodies'].items():
        for line in body.splitlines():
            m = re.match(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)', line)
            if m:
                data = bytes.fromhex(m[2])
                assert elf.read(int(m[1], 16), len(data)) == data, (name, line)
                checked += len(data)
    assert checked == native['checked_instruction_bytes'] == 1520
    inv = json.loads((P / 'invocation.json').read_text())
    cap = ROOT / 'docs/evidence/retained-why-inline-identifier-state-20261018/capture.tar.gz'
    with tarfile.open(cap) as t:
        process = t.extractfile('capture/process.json').read()
        plan = t.extractfile('plan.json').read()
    assert audit.identity(process) == inv['capture_process_identity']
    assert audit.identity(plan) == inv['capture_plan_identity']
    assert json.loads(process) == inv['process']
    assert json.loads(plan)['inputs'][0] == inv['selected_plan_input']
    assert '--socket' in inv['process']['argv'] and '--debug' not in inv['process']['argv']
    assert inv['process']['initial_threads'] == 1
    seed = json.loads((P / 'fixed-session-seed.json').read_text())
    with tarfile.open(ROOT / seed['archive']) as t:
        members = {n: t.extractfile(n).read() for n in seed['members']}
    for n, b in members.items():
        assert audit.identity(b) == seed['members'][n]
    xml = ET.fromstring(members[seed['session_member']])
    assert {tag: len(xml.findall('.//' + tag)) for tag in seed['xml_occurrences']} == seed['xml_occurrences']
    assert seed['members'][seed['json_member']] == inv['selected_plan_input']['input']
    model = multiplicity.explore()
    result = json.loads((P / 'result.json').read_text())
    assert model == result['finite_abstraction']
    assert result['conditional_save_entry_upper'] == 2
    assert result['accounted_source_endpoint'] == 61641
    assert result['per_callback_charge_limit'] == ((1 << 62) - 1 - 61641) // 2
    for key in ['unbounded_SIGINT_identifier_registration_established',
                'actual_two_callback_execution_observed',
                'source_refinement_machine_checked', 'full_handler_registration_charge_established',
                'current_session_graph_join_established', 'complete_continuing_call_counter_capacity_established',
                'complete_callback_allocation_capacity_established', 'launch_mask_implemented',
                'launch_mask_preservation_established', 'masked_launch_counter_join_established',
                'cancellation_integration_validated', 'prior_history_no_overflow_established',
                'family_wide_capacity_established', 'whole_pipeline_capacity_established']:
        assert result[key] is False, key
    print(json.dumps(dict(status='pass', elapsed_seconds=time.monotonic() - start,
                         native_instruction_bytes_checked=checked,
                         abstract_states=model['abstract_states'], conditional_save_entry_upper=2,
                         target_runs=0, disassembler_runs=0,
                         scope='source/native identities and ordering, finite abstraction, fixed-session seed and retained invocation binding; no session charge or masked-launch execution join')))


if __name__ == '__main__':
    main()

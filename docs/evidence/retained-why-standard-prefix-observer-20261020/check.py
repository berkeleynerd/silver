#!/usr/bin/env python3
"""Check a retained-prefix attachment, never execute observers or their target.

The exception-family/reachability argument is source reasoning for review, not
an implication of these hashes or of a lexical call census.
"""
import argparse
import ast
import hashlib
import json
import platform
import re
import struct
import tarfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def encode(value):
    return (json.dumps(value, indent=2) + '\n').encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    started = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
    spec = json.loads((HERE / 'inputs.json').read_bytes())
    for path, expected in spec['imports'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path

    # Reuse the accepted target-free query as a premise; do not rerun GDB.
    query = json.loads((ROOT / spec['signal_query']).read_bytes())
    assert query['returncode'] == 0
    assert query['target_loaded'] is False and query['target_executed'] is False
    for signal in ['SIGINT', 'SIGSEGV', 'SIGBUS']:
        assert re.search(r'^' + signal + r'\s+Yes\s+Yes\s+', query['stdout'], re.M)

    # Only selected metadata/scripts are read. No memory graph is replayed.
    capture_dir = ROOT / spec['capture_directory']
    manifest = json.loads((capture_dir / 'capture-manifest.json').read_bytes())
    retained, member_ids = {}, {}
    for archive in manifest['archives']:
        path = capture_dir / archive['path']
        assert identity(path.read_bytes()) == {k: archive[k] for k in ['bytes', 'sha256']}
        members = {m['path']: m for m in archive['members']}
        wanted = set(spec['capture_members'].get(archive['path'], []))
        with tarfile.open(path) as tar:
            for name in sorted(wanted):
                raw = tar.extractfile(name).read()
                assert identity(raw) == {k: members[name][k] for k in ['bytes', 'sha256']}
                retained[name] = raw
                member_ids[name] = dict(archive=archive['path'], **identity(raw))

    protocol = {}
    for group in ['registration', 'inline']:
        run = retained[group + '/run.py'].decode()
        probe = retained[group + '/probe.py'].decode()
        assert "'-nx','-q','-batch','-x'" in run
        assert 'signal.SIGTERM' in run and 'signal.SIGINT' not in run
        assert 'start_new_session=True' in run
        assert "'stopped before endpoint without a handled guard'" in probe
        commands = []
        for name, raw in retained.items():
            if not name.startswith(group + '/') or not name.endswith('.py'):
                continue
            tree = ast.parse(raw)
            for node in ast.walk(tree):
                if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute):
                    if isinstance(node.func.value, ast.Name) and node.func.value.id == 'gdb' and node.func.attr == 'execute':
                        commands.append(dict(member=name, line=node.lineno,
                                             expression=ast.unparse(node.args[0])))
        protocol[group] = dict(
            debugger_launch='-nx -q -batch -x probe.gdb --args target',
            timeout_signal='SIGTERM to debugger process group; actual timed_out=false',
            gdb_execute_sites=commands,
            semantic_control='accepted fixed-observer/default-policy relation, not proved by AST census')

    cases = []
    for case in spec['cases']:
        group, name, pid = case
        prefix = group + '/' + name + '/capture/'
        result = json.loads(retained[prefix + 'result.json'])
        process = json.loads(retained[prefix + 'process.json'])
        summary = json.loads(retained[prefix + 'summary.json'])
        script = retained[prefix + 'probe.gdb'].decode()
        log = retained[prefix + 'debugger.log'].decode()
        plan = json.loads(retained[group + '/plan.json'])
        assert process['pid'] == pid and process['initial_threads'] == 1
        assert result['returncode'] == 0 and not result['timed_out']
        assert result['completed'] and not result['failures']
        assert summary['completed'] and not summary['failures']
        assert not summary['guard_hits'] and not summary['new_threads']
        lines = script.splitlines()
        assert lines.count('continue') == 1 and lines.count('starti') == 1
        assert lines.index('starti') < lines.index('continue') < lines.index('finish_capture()') < lines.index('kill')
        assert 'set auto-load off' in lines and 'set breakpoint always-inserted on' in lines
        assert not re.search(r'(?m)^\s*(handle|signal|run|step|next|jump|finish)\b', script)
        assert 'received signal' not in log and f'(process {pid}) killed]' in log
        assert result['command'][0] == query['command'][0]
        assert result['command'][1:5] == ['-nx', '-q', '-batch', '-x']
        assert result['debugger_environment'] == query['environment']
        assert plan['file_identities'][query['command'][0]] == query['binary']
        assert all(v['hits'] == 0 for v in summary['forbidden_calls'].values())
        guards = {}
        biases = set()
        for symbol, row in summary['forbidden_calls'].items():
            expected = plan['forbidden_calls'][symbol]
            assert row['first32'] == expected['first32']
            biases.add(row['address'] - expected['address'])
            guards[symbol] = dict(hits=row['hits'], native_address=expected['address'],
                                  process_address=row['address'], first32=row['first32'])
        assert len(biases) == 1
        projection = dict(name=name, pid=pid, group=group, sole_continue=True,
                          completed=True, failures=[], protected_guard_hits=[],
                          startup_guard_names=[x['guard'] for x in summary['startup_guard_hits']],
                          new_threads=[], forbidden_calls=guards,
                          load_bias=biases.pop(),
                          phase='Gnat_checks.iter entry' if group == 'registration' else 'first cvc5 inline_trivial entry')
        if group == 'inline':
            save_symbols = ['camlGnat_main__save_session_and_exit_3133',
                            'camlWhy3__Session_itp__save_session_4339']
            assert all(s in guards for s in save_symbols)
            assert len(summary['driver_preparation']) == 1
            preparation = summary['driver_preparation'][0]
            assert preparation['visited_directives'] == ['counterexamples_dependent_intros', 'inline_trivial']
            projection['driver_preparation_count'] = 1
            projection['visited_directives'] = preparation['visited_directives']
            projection['save_entry_guards'] = save_symbols
        cases.append(projection)

    sources = {}
    for archive, entry in spec['source_archives'].items():
        path = ROOT / archive
        assert identity(path.read_bytes()) == entry['identity']
        with tarfile.open(path) as tar:
            for source in sorted({r[1] for r in spec['source_ranges'] if r[0] == entry['family']}):
                member = entry['prefix'] + source
                raw = tar.extractfile(member).read()
                sources[(entry['family'], source)] = (raw, dict(archive=archive, member=member, **identity(raw)))
    source_witnesses = []
    for family, path, first, last in spec['source_ranges']:
        raw, source_id = sources[(family, path)]
        lines = raw.decode().splitlines(keepends=True)
        assert 1 <= first <= last <= len(lines)
        excerpt = ''.join(lines[first - 1:last])
        source_witnesses.append(dict(source=family + '/' + path, first=first, last=last,
                                     source_identity=source_id, excerpt=excerpt,
                                     excerpt_identity=identity(excerpt.encode())))

    elf = Path(spec['elf']['path']).read_bytes()
    disassembly = Path(spec['disassembly']['path']).read_bytes()
    assert identity(elf) == spec['elf']['identity']
    assert identity(disassembly) == spec['disassembly']['identity']
    bodies = {m[1]: m[0] for m in re.finditer(
        r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)', disassembly.decode(), re.M | re.S)}
    h = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
    assert h[0][:6] == b'\x7fELF\x02\x01' and h[2] == 62
    segments = [struct.unpack_from('<IIQQQQQQ', elf, h[5] + i * h[9]) for i in range(h[10])]

    def read(address, size):
        s = next(s for s in segments if s[0] == 1 and s[3] <= address and address + size <= s[3] + s[5])
        offset = s[2] + address - s[3]
        return elf[offset:offset + size]

    native, checked_bytes = {}, 0
    for symbol in spec['native_symbols']:
        body, count = bodies[symbol], 0
        for line in body.splitlines()[1:]:
            m = re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)', line)
            if not m:
                assert not line.strip(), (symbol, line)
                continue
            address, code = int(m[1], 16), bytes.fromhex(m[2])
            assert read(address, len(code)) == code, (symbol, m[1])
            count += len(code)
        checked_bytes += count
        native[symbol] = dict(body=body, identity=identity(body.encode()), checked_instruction_bytes=count)
    for case in cases:
        for guard in case['forbidden_calls'].values():
            assert read(guard['native_address'], 32).hex() == guard['first32']

    result = dict(
        scope='five retained debugger-controlled pre-cut prefixes only',
        reused_signal_exclusion='accepted 66ba7f63647e72f0b1e683c39f4017803fc78149 and independent review',
        conditional_source_results={
            'pre_cut_SIGINT_save_interruption_excluded': True,
            'ordinary_abort_JSON_failure_is_Not_found': False,
            'registration_iter_leafs_can_recover_after_ordinary_abort_output_failure': False,
            'controller_driver_loading_can_resume_after_Printer_diagnostic': False},
        initial_standard_dynamic_state={'stdout': None, 'stderr': None},
        complete_prefix_writer_exclusion_exported=False,
        complete_formatter_capacity_established=False,
        post_cut_signal_exclusion=False,
        uncontrolled_production_prefix_claim=False,
        global_budget_reset=False,
        evidence=dict(cases=len(cases), retained_members=len(retained), source_excerpts=len(source_witnesses),
                      native_bodies=len(native), checked_instruction_bytes=checked_bytes),
        executions=dict(target=0, capture=0, debugger_query=0, disassembler=0, source_fetch=0,
                        predecessor_checker=0, solver=0, proof_suite=0),
        review_status='source/control argument awaits parent review; identities are not semantics')
    outputs = {'capture-projection.json': dict(members=member_ids, protocol=protocol, cases=cases),
               'source-witnesses.json': source_witnesses, 'native-witnesses.json': native, 'result.json': result}
    for name, value in outputs.items():
        if args.write:
            (HERE / name).write_bytes(encode(value))
        else:
            assert json.loads((HERE / name).read_bytes()) == value, name
    round_record = dict(started_utc=started, completed_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
                        focused_check_seconds=time.monotonic() - start, native_platform=platform.system() + '-' + platform.machine(),
                        selected_model='GPT-6 Astra', selected_effort='Extra High',
                        runtime_confirmed_model=None, runtime_confirmed_effort=None, token_usage=None, monetary_cost=None,
                        live_harness_goal=None, intended='attach accepted observer exclusion and ordinary-failure receiving-catch analysis',
                        achieved=result['conditional_source_results'],
                        material_finding='reuse accepted signal remedy; narrow no-Not_found closure; global dynamic graph still unexported',
                        review='parent owns independent acceptance and integration', executions=result['executions'])
    if args.write:
        (HERE / 'round.json').write_bytes(encode(round_record))
    print(json.dumps(dict(status='pass', seconds=round_record['focused_check_seconds'], **result['evidence'])))


if __name__ == '__main__':
    main()

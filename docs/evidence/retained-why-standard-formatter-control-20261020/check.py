#!/usr/bin/env python3
"""Bind the new standard-formatter control packet; no target or prior replay.

This is a witness/identity check, not a complete reachability, native refinement,
formatter invariant, or capacity proof. Source/control conclusions need review.
"""
import argparse
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
DEFAULT_ELF = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
DEFAULT_DISASSEMBLY = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def encode(value):
    return (json.dumps(value, indent=2) + '\n').encode()


def config_sections(raw):
    """Retain this small checked configuration's literal section/key inventory.

    Not a substitute implementation or an execution of Why3's Rc parser.
    """
    sections = []
    for line in raw.decode().splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if line.startswith('['):
            assert line.endswith(']')
            sections.append(dict(section=line[1:-1], fields={}))
        else:
            key, val = (x.strip() for x in line.split('=', 1))
            assert sections and key not in sections[-1]['fields']
            sections[-1]['fields'][key] = val
    return sections


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--elf', type=Path, default=DEFAULT_ELF)
    parser.add_argument('--disassembly', type=Path, default=DEFAULT_DISASSEMBLY)
    args = parser.parse_args()
    started = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
    start = time.monotonic()
    spec = json.loads((HERE / 'inputs.json').read_bytes())
    for path, expected in spec['imports'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path

    sources, source_ids = {}, {}
    for path, expected in spec['archives'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
        family = 'why3' if 'session-helper-source' in path else 'ocaml'
        prefix = 'why3/' if family == 'why3' else 'ocaml-' + spec['ocaml_revision'] + '/'
        needed = {r[1] for r in spec['source_ranges'] if r[0] == family}
        with tarfile.open(ROOT / path) as tar:
            for member in tar:
                if not member.isfile() or not member.name.startswith(prefix):
                    continue
                rel = member.name.removeprefix(prefix)
                if rel not in needed and not (family == 'why3' and rel.endswith(('.ml', '.mli'))):
                    continue
                raw = tar.extractfile(member).read()
                key = family + '/' + rel
                sources[key] = raw.decode()
                source_ids[key] = dict(archive=path, member=member.name, **identity(raw))
    why_sources = sorted(k for k in sources if k.startswith('why3/') and k.endswith(('.ml', '.mli')))
    assert len(why_sources) == 528
    pattern = re.compile(r'\b(?:eprintf|std_formatter|err_formatter|set_debug_formatter|set_warning_hook|wnl|pp_set_\w+|set_formatter_\w+|pp_open_tbox|pp_set_tab)\b|Format\.printf')
    census = [dict(source=k, line=i, text=line) for k in why_sources
              for i, line in enumerate(sources[k].splitlines(), 1) if pattern.search(line)]
    witnesses = []
    for family, rel, first, last in spec['source_ranges']:
        key = family + '/' + rel
        lines = sources[key].splitlines(keepends=True)
        assert 1 <= first <= last <= len(lines), key
        excerpt = ''.join(lines[first - 1:last])
        witnesses.append(dict(source=key, first=first, last=last,
                              source_identity=source_ids[key], excerpt=excerpt,
                              excerpt_identity=identity(excerpt.encode())))

    # Full selected native bodies are checked against the retained ELF. The
    # calls ledger is diagnostic; no indirect completeness follows from it.
    disassembly = args.disassembly.read_bytes()
    elf = args.elf.read_bytes()
    assert identity(disassembly) == spec['disassembly']
    assert identity(elf) == spec['elf']
    bodies = {m[1]: m[0] for m in re.finditer(
        r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)', disassembly.decode(), re.M | re.S)}
    h = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
    assert h[0][:6] == b'\x7fELF\x02\x01' and h[2] == 62
    segments = [struct.unpack_from('<IIQQQQQQ', elf, h[5] + i * h[9]) for i in range(h[10])]

    def read(address, size):
        s = next(s for s in segments if s[0] == 1 and s[3] <= address
                 and address + size <= s[3] + s[5])
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
        native[symbol] = dict(body=body, identity=identity(body.encode()),
                              checked_instruction_bytes=count)
    for address, symbol in [(0xea64c0, 'camlDynlink_compilerlibs__Misc__fun_4278'),
                            (0xea64d8, 'camlDynlink_compilerlibs__Misc__fun_4276')]:
        assert struct.unpack('<Q', read(address, 8))[0] == int(bodies[symbol].split()[0], 16)
    format_entry = bodies['camlStdlib__Format__entry']
    for anchor in ['98c3a0:', '98c3b7:', '98c3df:', '0x360(%rbx)', '98c3eb:', '0x368(%rbx)']:
        assert anchor in format_entry, anchor
    init_ledger = []
    for symbol in spec['compiler_initializers']:
        body = bodies[symbol]
        init_ledger.append(dict(symbol=symbol,
            direct_calls=re.findall(r'\bcall\s+[0-9a-f]+ <([^>]+)>', body),
            indirect_calls=[line.strip() for line in body.splitlines() if re.search(r'\b(?:call|jmp)\s+\*', line)]))
    assert [r['symbol'] for r in init_ledger if r['indirect_calls']] == [
        'camlDynlink_compilerlibs__Env__entry', 'camlDynlink_compilerlibs__Profile__entry']

    # Retain actual configuration/process/gate inputs and check whether any
    # existing raw read covers either standard-global pointer slot. No read of
    # a different formatter is substituted, and no new process is run.
    capture_dir = ROOT / 'docs/evidence/retained-why-save-state-capture-20261020'
    manifest = json.loads((capture_dir / 'capture-manifest.json').read_bytes())
    archive_specs = {Path(r['path']).name: r for r in manifest['archives']}
    projections = []
    common = 'capture-common.tar.gz'
    assert identity((capture_dir / common).read_bytes()) == {k: archive_specs[common][k] for k in ('bytes', 'sha256')}
    common_members = {r['path']: r for r in archive_specs[common]['members']}
    overlays = {}
    with tarfile.open(capture_dir / common) as tar:
        for prefix in ('registration', 'inline'):
            member = prefix + '/overlay/why3.conf'
            raw = tar.extractfile(member).read()
            assert identity(raw) == {k: common_members[member][k] for k in ('bytes', 'sha256')}
            assert raw == b'[main]\nmagic = 14\n'
            overlays[prefix] = dict(member=member, **identity(raw), text=raw.decode())
    for case, pid in zip(spec['cases'], spec['pids']):
        archive = 'capture-' + case.replace('_', '-') + '.tar.gz'
        expected = archive_specs[archive]
        assert identity((capture_dir / archive).read_bytes()) == {k: expected[k] for k in ('bytes', 'sha256')}
        members = {r['path']: r for r in expected['members']}
        prefix = 'inline' if case == 'input_is_valid' else 'registration'
        base = prefix + '/' + case + '/'
        selected = {}
        with tarfile.open(capture_dir / archive) as tar:
            def raw_member(member):
                raw = tar.extractfile(member).read()
                assert identity(raw) == {k: members[member][k] for k in ('bytes', 'sha256')}, member
                selected[member] = identity(raw)
                return raw
            process = json.loads(raw_member(base + 'capture/process.json'))
            hooks = json.loads(raw_member(base + 'capture/exit-hook-roots.json'))
            config = raw_member(base + 'why3.conf')
            assert process['pid'] == pid and process['initial_threads'] == 1
            assert set(process['environment']) == {'PATH', 'LC_ALL', 'TMPDIR', 'OCAMLRUNPARAM'}
            argv = process['argv']
            for flag, value in [('--proof', 'per_check'), ('--prover', 'cvc5,z3,altergo'), ('--counterexample', 'off')]:
                assert argv[argv.index(flag) + 1] == value
            assert '--debug' not in argv and '--replay' not in argv
            assert [x['gate'] for x in hooks['exit_chain'][:2]] == [3, 3]
            bias = hooks['exit_chain'][0]['callback']['code'] - 0x55a680
            assert hooks['exit_chain'][1]['callback']['code'] - bias == 0x98b6a0
            slots = {k: bias + int(v, 16) for k, v in spec['standard_slots'].items()}
            coverage = {k: [] for k in slots}
            for member in members:
                if member.startswith(base + 'capture/') and member.endswith('memory-reads.jsonl'):
                    raw = raw_member(member)
                    for line, encoded in enumerate(raw.splitlines(), 1):
                        rec = json.loads(encoded)
                        if not {'address', 'bytes', 'hex'} <= rec.keys():
                            continue
                        lo, count = rec['address'], rec['bytes']
                        for name, address in slots.items():
                            if lo <= address and address + 8 <= lo + count:
                                content = bytes.fromhex(rec['hex'])
                                assert len(content) == count
                                value = struct.unpack_from('<Q', content, address - lo)[0]
                                coverage[name].append(dict(member=member, line=line,
                                    read_address=lo, read_bytes=count, raw_root_word=value))
            sections = config_sections(config)
            assert len(sections) == 11
            assert sections[0]['section'] == 'main' and sections[0]['fields']['magic'] == '14'
            assert sections[1]['section'] == 'editor coqide' and 'command' in sections[1]['fields']
            assert all(x['section'] == 'prover' and {'name', 'driver', 'command'} <= x['fields'].keys() for x in sections[2:])
            projections.append(dict(case=case, pid=pid, archive=archive,
                process=process, selected_members=selected, config_sections=sections,
                config_identity=identity(config), overlay=overlays[prefix], load_bias=bias,
                standard_root_slots=slots, standard_slot_read_coverage=coverage,
                observed_debug_formatter=hooks['formatter_record'], persistent_gates=[True, True],
                initial_standard_dynamic_state=None))
    assert len({r['config_identity']['sha256'] for r in projections}) == 1

    result = dict(schema=1, native_platform=platform.system() + ' ' + platform.machine(),
        status='source-control component; initial standard dynamic graph remains unestablished',
        source_files_in_why_census=len(why_sources), source_excerpts=len(witnesses),
        native_bodies=len(native), native_instruction_bytes=checked_bytes,
        compiler_initializer_bodies=len(init_ledger),
        profile_claim=dict(scope='selected source/native behavior relation; review required',
            margin=78, min_space_left=10, max_indent=68, max_boxes=2**62-1, ellipsis='.',
            stdout_newline_wrapper_depth=0, stderr_debug_newline_wrapper_depth=1,
            location_output_wrapper_depth=0, color_marker_wrapper_depth=0,
            print_tags=False, mark_tags=False, tag_mark_tab_stacks_empty=True,
            post_cut_setter_preservation=True),
        cases=[dict(case=x['case'], pid=x['pid'], initial_dynamic_state=None,
            standard_slot_read_counts={k: len(v) for k, v in x['standard_slot_read_coverage'].items()}) for x in projections],
        initial_standard_queue_freshness=None, global_queue_prefix_preservation=None,
        model_diagnostic_excluded_by_task_meta=None, whole_output_capacity=None,
        complete_R=None, complete_U=None, issue_153_complete=False,
        global_budget_reset=False, assumed_precut_signal_budget=None,
        new_targets=0, new_captures=0, disassemblers=0, source_fetches=0, predecessor_checkers=0)
    outputs = {'source-witnesses.json': witnesses, 'source-census.json': census,
               'native-witnesses.json': native, 'initializer-calls.json': init_ledger,
               'initial-inputs.json': projections, 'result.json': result}
    for name, obj in outputs.items():
        raw = encode(obj)
        if args.write:
            (HERE / name).write_bytes(raw)
        else:
            assert (HERE / name).read_bytes() == raw, name
    elapsed = time.monotonic() - start
    if args.write:
        (HERE / 'round.json').write_bytes(encode(dict(
            date='2026-10-20', selected_model='GPT-6 Astra', selected_effort='Extra High',
            runtime_confirmed_model=None, runtime_confirmed_effort=None,
            author_elapsed_seconds=None, token_usage=None, cost=None,
            focused_check_started_utc=started, focused_check_elapsed_seconds=elapsed,
            intent='Establish selected standard formatter control and identify exact missing initial state',
            achieved='Fixed callback/settings profile and writer/catch control; initial queue state remains null',
            material_findings=['Gnat_report replaces Loc warning hook after config',
                'True exit gates do not exclude abandoned pre-cut standard output',
                'Color/Location linked definitions require selected initializer/loader analysis',
                'CE-off alone is not a task-meta proof excluding model diagnostic'],
            review='Parent-owned independent review pending',
            setup_failure='Initial excerpt specification extended Plugin.ml past line 67; corrected to 59–67 and bounded plugin tail to actual line 1446 before focused check',
            successful_identical_input_reruns=0, new_targets=0, new_captures=0,
            disassemblers=0, source_fetches=0, predecessor_checkers=0)))
    print(json.dumps(dict(ok=True, seconds=elapsed, source_excerpts=len(witnesses),
                          native_bodies=len(native), native_instruction_bytes=checked_bytes,
                          standard_root_read_counts=result['cases']), indent=2))


if __name__ == '__main__':
    main()

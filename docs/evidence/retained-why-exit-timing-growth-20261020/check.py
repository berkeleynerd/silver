#!/usr/bin/env python3
"""Focused retained source/native/input/arithmetic check; no predecessor replay.

The source control and mutation arguments in the accompanying note require
review. This checker binds their inputs and witnesses; it is not a compiler
refinement proof or a complete runtime-service/capacity checker.
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
DEFAULT_DISASM = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
CASES = ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid')
PIDS = (17310, 17514, 17631, 17704, 17869)
MAX_INT = 2**62 - 1


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def encode(value):
    return (json.dumps(value, indent=2) + '\n').encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--elf', type=Path, default=DEFAULT_ELF)
    parser.add_argument('--disassembly', type=Path, default=DEFAULT_DISASM)
    args = parser.parse_args()
    start = time.monotonic()
    started = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
    spec = json.loads((HERE / 'inputs.json').read_bytes())
    imports = {}
    for path, expected in spec['imports'].items():
        raw = (ROOT / path).read_bytes()
        assert identity(raw) == expected, path
        if path.endswith('.json'):
            imports[path] = json.loads(raw)

    # Read exactly the retained archives. No checkout/source fetch is needed.
    source = {}
    source_ids = {}
    for path, expected in spec['archives'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
        family = 'why3' if 'session-helper-source' in path else 'ocaml'
        with tarfile.open(ROOT / path) as tar:
            for member in tar:
                if not member.isfile():
                    continue
                if family == 'why3':
                    if not member.name.startswith('why3/'):
                        continue
                    rel = member.name.removeprefix('why3/')
                    if not rel.endswith(('.ml', '.mli')):
                        continue
                else:
                    prefix = 'ocaml-' + spec['ocaml_revision'] + '/'
                    assert member.name.startswith(prefix), member.name
                    rel = member.name.removeprefix(prefix)
                    if rel not in {r[1] for r in spec['source_ranges'] if r[0] == family}:
                        continue
                raw = tar.extractfile(member).read()
                key = family + '/' + rel
                source[key] = raw.decode()
                source_ids[key] = dict(archive=path, member=member.name, **identity(raw))
    why3_keys = sorted(k for k in source if k.startswith('why3/'))
    assert len(why3_keys) == 528
    terms = re.compile(r'\b(?:Stats|record_timing|add_timing|get_timings|timing_map)\b')
    census = []
    for key in why3_keys:
        for line, text in enumerate(source[key].splitlines(), 1):
            if terms.search(text):
                census.append(dict(source=key, line=line, text=text))
    # Every lexical reference is retained for the no-alias/source-client review.
    timing_clients = sorted({r['source'] for r in census
                             if re.search(r'\b(?:record_timing|add_timing|get_timings|timing_map)\b', r['text'])})
    assert timing_clients == sorted('why3/' + p for p in (
        'src/driver/driver.ml', 'src/gnat/gnat_main.ml', 'src/gnat/gnat_report.ml',
        'src/mlw/rac.ml', 'src/session/session_itp.ml', 'src/util/debug.ml',
        'src/util/debug.mli'))
    witnesses = []
    for family, rel, first, last in spec['source_ranges']:
        key = family + '/' + rel
        lines = source[key].splitlines(keepends=True)
        assert 1 <= first <= last <= len(lines), key
        text = ''.join(lines[first - 1:last])
        witnesses.append(dict(source=key, first=first, last=last,
                              source_identity=source_ids[key], excerpt=text,
                              excerpt_identity=identity(text.encode())))
    required_source = {
        'why3/src/util/debug.ml': ['try Hashtbl.find timing_map name',
            'with Not_found -> 0.0, 0 in',
            'Hashtbl.replace timing_map name (old_t +. time, old_n + 1)',
            '~finally:(fun () -> add_timing name'],
        'ocaml/stdlib/hashtbl.ml': ['h.data.(i) <- Cons{key; data; next=l};',
            'h.size <- h.size + 1;',
            'if h.size > Array.length h.data lsl 1 then resize key_index h',
            'then (slot.key <- key; slot.data <- data; false)'],
        'ocaml/stdlib/fun.ml': ['| result -> finally_no_exn () ; result',
            '| exception work_exn ->', 'Printexc.raise_with_backtrace (Finally_raised e) bt'],
    }
    for key, anchors in required_source.items():
        for anchor in anchors:
            assert anchor in source[key], (key, anchor)

    # Reuse the one retained disassembly and compare its complete selected
    # bodies directly to the accepted ELF; never run a disassembler/target.
    raw_disasm = args.disassembly.read_bytes()
    assert identity(raw_disasm) == dict(bytes=69046582, sha256='f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5')
    elf = args.elf.read_bytes()
    assert identity(elf) == dict(bytes=24561432, sha256='7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368')
    bodies = {m[1]: m[0] for m in re.finditer(
        r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)', raw_disasm.decode(), re.M | re.S)}
    header = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
    assert header[0][:6] == b'\x7fELF\x02\x01' and header[2] == 62
    segments = [struct.unpack_from('<IIQQQQQQ', elf, header[5] + i * header[9])
                for i in range(header[10])]

    def read_native(address, size):
        s = next(s for s in segments if s[0] == 1 and s[3] <= address
                 and address + size <= s[3] + s[5])
        offset = s[2] + address - s[3]
        return elf[offset:offset + size]

    native = {}
    literals = {}
    checked_bytes = 0
    for symbol in spec['native_symbols']:
        body = bodies[symbol]
        count = 0
        for line in body.splitlines()[1:]:
            m = re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)', line)
            if not m:
                assert not line.strip(), (symbol, line)
                continue
            address, code = int(m[1], 16), bytes.fromhex(m[2])
            assert read_native(address, len(code)) == code, (symbol, m[1])
            count += len(code)
        checked_bytes += count
        native[symbol] = dict(body=body, identity=identity(body.encode()),
                              checked_instruction_bytes=count)
        for address, label in re.findall(r'#\s*([0-9a-f]+) <([^>]+)>', body):
            if label in bodies or '+' in label:
                continue
            address = int(address, 16)
            tag = struct.unpack('<Q', read_native(address - 8, 8))[0]
            if tag & 255 == 252 and tag >> 10 < 4096:
                raw = read_native(address, 8 * (tag >> 10))
                assert raw[-1] < 8
                value = raw[:len(raw) - raw[-1] - 1]
                if value.startswith(b'gnatwhy3.'):
                    literals[label] = dict(address=hex(address), value=value.decode(),
                                           bytes=len(value), raw_hex=raw.hex())
    assert {r['value'] for r in literals.values()} >= {
        'gnatwhy3.transformations.', 'gnatwhy3.init', 'gnatwhy3.register_vcs',
        'gnatwhy3.schedule_vcs', 'gnatwhy3.run_vcs', 'gnatwhy3.save_session'}
    # These site anchors bind the reviewed trap, store and allocation argument.
    anchors = {
        'camlStdlib__Fun__protect_317': ['97eee7:', '97eeee:', '97eef8:', '97ef20:', '97ef4a:'],
        'camlStdlib__Fun__finally_no_exn_321': ['97ef91:', '97efa0:', 'sub    $0x18,%r15'],
        'camlWhy3__Debug__add_timing_1632': ['55a372:', '55a37e:', '55a388:',
            'sub    $0x28,%r15', 'add    $0x2,%rbx', '55a407:'],
        'camlWhy3__Debug__record_timing_1638': ['sub    $0x38,%r15', '55a49c:'],
        'camlWhy3__Debug__fun_3043': ['sub    $0x10,%r15', '55a50a:'],
        'camlStdlib__Hashtbl__replace_1352': ['983ec8:', 'sub    $0x20,%r15',
            '983f1a:', '983f1f:', '983f3e:', '983f52:'],
        'camlStdlib__Hashtbl__replace_bucket_1345': ['983e23:', '983e34:', '983e52:'],
        'camlGnat_main__save_session_and_exit_3133': ['52e6d1:', '52e6fb:', '52e709:'],
    }
    for symbol, expected in anchors.items():
        for anchor in expected:
            assert anchor in bodies[symbol], (symbol, anchor)
    assert 'record_timing' not in bodies['camlGnat_main__save_session_and_exit_3133']

    def imported(stem):
        return imports['docs/evidence/' + stem + '-20261020/result.json']

    initial = imported('retained-why-exit-initial-values')
    episodes = imported('retained-why-path-writer-capacity')
    driver = imports['docs/evidence/retained-producer-driver-envelope-20261018/result.json']
    lists = {k: [r['name'] for r in v['transformations']]
             for k, v in driver['selected_driver_dispatch'].items()}
    assert {k: len(v) for k, v in lists.items()} == dict(cvc5=15, z3=13, altergo=12)
    assert all(len(v) == len(set(v)) for v in lists.values())
    transform_names = set().union(*map(set, lists.values()))
    prefix = 'gnatwhy3.transformations.'
    initial_only = {'gnatwhy3.init', 'gnatwhy3.register_vcs', prefix + 'split_goal_wp_conj'}
    outer = {'gnatwhy3.schedule_vcs', 'gnatwhy3.run_vcs', 'gnatwhy3.save_session'}
    possible_keys = initial_only | outer | {prefix + n for n in transform_names}
    assert len(transform_names) == 20 and len(possible_keys) == 26
    assert max(map(len, possible_keys)) == 59 and sum(map(len, possible_keys)) == 1051
    assert spec['global_signal_escapes_upper'] == 2 and spec['global_save_entries_upper'] == 3
    rows = []
    for case, pid in zip(CASES, PIDS, strict=True):
        i = next(c for c in initial['cases'] if c['case'] == case)
        e = next(c for c in episodes['cases'] if c['case'] == case)
        assert i['pid'] == e['pid'] == pid
        t = i['timing_table']
        assert t['backing_slots'] == t['initial_size'] == 64 and t['seed'] == 0
        values = {v['name']: v for v in t['values']}
        expected_initial = initial_only | ({prefix + 'counterexamples_dependent_intros'}
                                          if case == 'input_is_valid' else set())
        assert set(values) == expected_initial and t['entries'] == len(values)
        assert all(v['count'] == 1 for v in values.values())
        assert not e['under_named_existing_premises']['missing_premises']
        dispatch = e['under_named_existing_premises']['dispatch_bounds']
        E = dispatch['preparation_episodes_intersecting_suffix_upper']
        D = dispatch['outer_directive_applications_upper']
        G = e['registered_goals_upper']
        assert E == 3 * G + 2 and D == 40 * G + 30 and D <= 15 * E
        U = D + 3
        counters = {key: (1 if key in initial_only | outer else E + int(key in values))
                    for key in sorted(possible_keys)}
        assert max(counters.values()) <= E + 1 <= MAX_INT
        assert len(possible_keys) < 2 * t['backing_slots'] <= MAX_INT
        rows.append(dict(case=case, pid=pid, registered_goals_upper=G,
            preparation_episodes_intersecting_suffix_upper=E,
            active_preparation_episodes_at_cut=e['active_preparation_episodes_at_cut'],
            outer_schedule_scope_pending_at_cut_upper=1,
            suspended_init_registration_or_session_timing_updates=0,
            driver_scope_and_name_construction_attempts_upper=D,
            candidate_update_attempts_15E_plus_3=15*E+3,
            tighter_update_attempts_upper=U,
            per_scope_finalizer_attempts_upper=1,
            signal_save_direct_timing_updates=0,
            additional_session_or_rac_timing_updates=0,
            initial_entries=t['entries'], initial_counts_max=1,
            reachable_timing_cells_upper=26, distinct_key_values_upper=26,
            new_successfully_published_cells_upper=26-t['entries'],
            possible_cell_allocation_attempts_upper=U,
            scalar_size_lower=t['entries'], scalar_size_upper=26,
            backing_slots=64, post_cut_resize_entries=0,
            initial_size_field_values=[-64,64],
            per_key_counter_upper=counters,
            uniform_counter_upper=E+1,
            counter_decimal_digits_upper=len(str(E+1)),
            sum_visible_counts_upper=t['entries']+U,
            timing_key_bytes_upper=59, total_distinct_key_bytes_upper=1051,
            table_iteration_callback_entries_per_traversal_upper=26,
            debug_timing_callback_entries_whole_suffix_upper=26,
            timing_table_control_and_scalar_bounds_established=True,
            finite_elapsed_time_or_float_magnitude_bound=None,
            complete_timing_runtime_capacity_established=False,
            complete_exit_capacity_established=False,
            complete_save_capacity_established=False))
    assert [r['preparation_episodes_intersecting_suffix_upper'] for r in rows] == [194,161,98,11,5]
    assert [r['tighter_update_attempts_upper'] for r in rows] == [2593,2153,1313,153,73]
    block = lambda n: 8 * ((n + 8) // 8) + 8
    assert block(59) == 72
    allocation_projection = {
        'scope': 'Named local instrumentation/table requests only; excludes work, output, backtraces and runtime services',
        'name_concat_payload_bytes_upper': 59,
        'name_string_heap_block_bytes_upper': block(59),
        'driver_work_closure_native_reservation_bytes': 40,
        'record_timing_begin_float_and_finally_closure_reservation_bytes': 56,
        'protect_finalizer_wrapper_closure_reservation_bytes': 32,
        'duration_box_reservation_bytes': 16,
        'sum_box_and_pair_reservation_bytes': 40,
        'insert_cell_reservation_bytes': 32,
        'finally_raised_record_reservation_bytes': 24,
        'largest_named_local_individual_heap_request_bytes': 72,
        'complete_call_allocation_bound': None,
    }
    result = dict(schema=1, scope='Whole post-cut selected timing-table growth and iteration inputs',
        source_behavior_relation='Existing selected-source/native/runtime premise; no compiler refinement claim',
        global_signal_escapes_upper=2, global_save_entries_upper=3,
        budgets_restarted=False, configured_driver_transformations=lists,
        possible_keys=[dict(name=k, bytes=len(k)) for k in sorted(possible_keys)],
        native_body_count=len(native), checked_instruction_bytes=checked_bytes,
        source_excerpt_count=len(witnesses), source_census_file_count=len(why3_keys),
        cases=rows, local_individual_requests=allocation_projection,
        exclusions=['Format conversion/output and formatter state',
            'backtrace, gettimeofday, hash/compare, write barrier, allocation/GC and pending runtime-service internals',
            'work performed by timed functions', 'complete native stack and ambient frames',
            'physical sufficiency, successful termination or accurate wall-clock accounting'])
    outputs = {'result.json': result, 'source-witnesses.json': witnesses,
        'source-census.json': dict(files={k:source_ids[k] for k in why3_keys}, references=census),
        'native-witnesses.json': dict(elf_identity=identity(elf), disassembly_identity=identity(raw_disasm),
                                     bodies=native, static_timing_literals=literals, checked_site_anchors=anchors)}
    for name, value in outputs.items():
        raw = encode(value)
        if args.write:
            (HERE / name).write_bytes(raw)
        else:
            assert (HERE / name).read_bytes() == raw, name
    elapsed = time.monotonic() - start
    if args.write:
        round_record = dict(date='2026-10-20', selected_model='GPT-6 Astra',
            selected_effort='Extra High', runtime_confirmed_model=None,
            runtime_confirmed_effort=None, author_elapsed_seconds=None,
            token_usage=None, cost=None, native_platform=platform.system()+' '+platform.machine(),
            focused_check_started_utc=started, focused_check_elapsed_seconds=elapsed,
            intent='Close timing updates, key/counter domains, local individual requests and table traversal',
            result='Candidate and sharper update bounds, 26 keys, no resize, bounded timing iteration inputs',
            material_finding='Signal saves are untimed; work trap excludes finalizer; insertion publishes before size increment; exported alias fold changes only traversal sign',
            review='Parent-owned independent review pending',
            predecessor_checkers_run=0, native_targets_run=0, captures=0,
            disassemblers_run=0, source_fetches=0, successful_identical_input_reruns=0,
            setup_failures=[dict(stage='source excerpt bounds',
                reason='Requested Fun.ml line 41 but retained file ends at line 38',
                correction='Bound the excerpt to actual lines 21 through 38; no result was produced',
                command_wall_seconds=0.223085843)])
        (HERE / 'round.json').write_bytes(encode(round_record))
        local = ['check.py','inputs.json','README.md','round.json',*outputs]
        manifest = dict(local={name:identity((HERE/name).read_bytes()) for name in local},
            research_note=identity((ROOT/'docs/research/retained-why-exit-timing-growth.md').read_bytes()))
        (HERE / 'manifest.json').write_bytes(encode(manifest))
    else:
        manifest = json.loads((HERE/'manifest.json').read_bytes())
        assert all(identity((HERE/name).read_bytes()) == expected
                   for name,expected in manifest['local'].items())
        assert identity((ROOT/'docs/research/retained-why-exit-timing-growth.md').read_bytes()) == manifest['research_note']
    print(json.dumps(dict(status='passed', focused_check_elapsed_seconds=elapsed,
        bodies=len(native), checked_instruction_bytes=checked_bytes,
        updates=[r['tighter_update_attempts_upper'] for r in rows],
        keys=26, longest_key_bytes=59, complete_exit_capacity=False)))


if __name__ == '__main__':
    main()

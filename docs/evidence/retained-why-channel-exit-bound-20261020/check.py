#!/usr/bin/env python3
"""Check retained exit/channel attachments and scoped arithmetic; never run target."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INSN = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')

def read(path):
    return json.loads(path.read_text())

def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}

def derive():
    inputs = read(HERE / 'inputs.json')
    for name, expected in inputs['files'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    for name, expected in inputs['local_files'].items():
        assert identity((HERE / name).read_bytes()) == expected, name
    slices = read(HERE / 'source-witnesses.json')
    for archive in {r['archive'] for r in slices}:
        with tarfile.open(ROOT / archive) as stream:
            cache = {}
            for row in (r for r in slices if r['archive'] == archive):
                member = row['member']
                if member not in cache:
                    cache[member] = stream.extractfile(member).read()
                raw = cache[member]
                assert identity(raw) == row['member_identity']
                assert ''.join(raw.decode().splitlines(keepends=True)[
                    row['first_line']-1:row['last_line']]) == row['text']
    meta = read(HERE / 'native-witnesses.json')
    binary = Path(meta['executable']['path']).read_bytes()
    assert identity(binary) == meta['executable']['identity']
    assert binary[:6] == b'\x7fELF\x02\x01'
    phoff = struct.unpack_from('<Q', binary, 32)[0]
    size, count = struct.unpack_from('<HH', binary, 54)
    loads = []
    for i in range(count):
        kind, flags, off, addr, _, n, _, _ = struct.unpack_from(
            '<IIQQQQQQ', binary, phoff+i*size)
        if kind == 1:
            loads.append((addr, addr+n, off, flags))
    def at(addr, raw, executable=False):
        return any(lo <= addr and addr+len(raw) <= hi and
                   (not executable or flags & 1) and
                   binary[off+addr-lo:off+addr-lo+len(raw)] == raw
                   for lo, hi, off, flags in loads)
    bodies = read(HERE / 'native-bodies.json')
    assert len(bodies) == meta['body_count'] == 41
    checked = 0
    for name, body in bodies.items():
        assert re.match(r'[0-9a-f]+ <'+re.escape(name)+r'>:', body)
        for line in body.splitlines():
            if not (m := INSN.match(line)):
                continue
            raw = bytes.fromhex(m[2])
            assert at(int(m[1], 16), raw, True), name
            checked += len(raw)
    assert checked == meta['instruction_bytes']
    for row in read(HERE / 'native-data.json'):
        assert at(row['address'], bytes.fromhex(row['bytes_hex']))
    # Concrete edges/values supplement, but do not prove, the source control argument.
    for caller, callee in [
        ('caml_program', 'camlStd_exit__entry'),
        ('caml_program', 'camlGnat_main__entry'),
        ('camlGnat_main__entry', 'camlGnat_util__abort_with_message_462'),
        ('camlGnat_main__save_session_and_exit_3133', 'camlStdlib__exit_488'),
        ('camlGnat_util__abort_with_message_462', 'camlStdlib__exit_488'),
        ('camlGnat_util__fun_12123', 'camlGnat_util__abort_with_message_462'),
        ('camlStdlib__exit_488', 'caml_sys_exit'),
        ('camlStdlib__flush_all_236', 'caml_ml_out_channels_list'),
        ('caml_ml_out_channels_list', 'caml_alloc_custom_mem'),
        ('caml_ml_out_channels_list', 'caml_alloc_small'),
        ('camlStdlib__Filename__try_name_1001', 'camlStdlib__open_out_gen_222'),
    ]:
        assert '<'+callee+'>' in bodies[caller], (caller, callee)
    assert re.search(r'addl\s+\$0x1,0x40\(', bodies['caml_ml_out_channels_list'])
    assert re.search(r'\$0x7d1', bodies['camlStdlib__Filename__try_name_1001'])
    prefixes = read(ROOT/'docs/evidence/retained-why-path-initial-state-20261020/prefix-attachment.json')
    initial = read(ROOT/'docs/evidence/retained-why-channel-initial-bound-20261020/result.json')
    episodes = read(ROOT/'docs/evidence/retained-why-path-writer-capacity-20261020/result.json')
    assert initial['conditional_initial_count_and_no_wrap_established']
    rows = []
    for qrow, erow, prefix in zip(initial['cases'], episodes['cases'], prefixes, strict=True):
        assert qrow['case'] == erow['case'] == prefix['case']
        assert prefix['environment']['OCAMLRUNPARAM'] == 's=256M,h=16M,M=1000'
        assert prefix['exit_chain_code_offsets'] == ['0x941560', '0x941560', '0x9406e0']
        assert prefix['exit_callback_code_offsets'] == ['0x55a680', '0x98b6a0']
        e = erow['under_named_existing_premises']['dispatch_bounds']['preparation_episodes_intersecting_suffix_upper']
        q = qrow['initial_managed_output_channels_upper']
        assert q == qrow['initial_each_refcount_upper'] and q >= 1
        f = 2+1+1+1+1  # Signal, main handler, Std_exit, Printexc, custom handler.
        drivers = 1001*e
        created = drivers+6
        managed_outputs = q+created
        refcount = max(q, 1)+f
        assert refcount < 2**31-1
        bounds = {
            'flush_all_entries_upper': f,
            'driver_output_channel_constructors_upper': drivers,
            'save_output_channel_constructors_upper': 6,
            'new_output_channel_constructors_upper': created,
            'managed_output_channels_upper': managed_outputs,
            'each_channel_refcount_upper': refcount,
            'out_channels_list_selected_visits_upper': f*managed_outputs,
            'out_channels_list_direct_ocaml_bytes_upper': 48*f*managed_outputs,
            'driver_constructor_wrapper_bytes_upper': 24*drivers,
            'driver_constructor_channel_record_bytes_upper': 65616*drivers,
            'additional_ocaml_bytes_excluding_owned_save_wrappers': 48*f*managed_outputs+24*drivers,
        }
        rows.append({'case': qrow['case'], 'preparation_episodes_upper': e,
                     'initial_output_and_refcount_upper': q,
                     'without_named_relation': None,
                     'under_named_existing_relation': bounds})
    assert len(rows) == 5
    return {
        'scope': 'Selected post-cut exit roots, managed-output list requests and refcounts',
        'cases': rows,
        'exit_root_and_refcount_bounds_under_named_relation': True,
        'global_service_positive_write_premise_added': False,
        'earlier_e_plus_two_flush_claim_valid': False,
        'direct_global_flush_countertrace_entries_with_zero_signal_saves': 3,
        'complete_channel_capacity_established': False,
        'complete_failure_exit_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
        'physical_memory_sufficiency_established': False,
        'native_runs': 0, 'predecessor_checker_replays': 0,
        'new_disassembler_runs': 0, 'native_bodies': len(bodies),
        'checked_native_bytes': checked, 'source_slices': len(slices),
    }

if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--write', action='store_true')
    args = p.parse_args()
    start = time.monotonic()
    result = derive()
    raw = (json.dumps(result, indent=2)+'\n').encode()
    if args.write:
        (HERE/'result.json').write_bytes(raw)
    else:
        assert (HERE/'result.json').read_bytes() == raw
    print(json.dumps({'status':'pass', 'cases':len(result['cases']),
        'source_slices':result['source_slices'], 'native_bodies':result['native_bodies'],
        'native_bytes':result['checked_native_bytes'], 'elapsed_seconds':time.monotonic()-start,
        'native_runs':0, 'predecessor_checker_replays':0},indent=2))

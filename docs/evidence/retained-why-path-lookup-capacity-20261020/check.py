#!/usr/bin/env python3
"""Focused retained-byte/topology checks and transfer challenges, no native run."""
import argparse
from collections import Counter
import hashlib
import itertools
import json
from pathlib import Path
import re
import struct
import tarfile
import time

from transfer import lookup_bounds, PREMISES, REPRESENTED_CHAIN_MAX, MAX_ARRAY_LENGTH

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INSN = re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')
INVENTORY = 'docs/evidence/retained-why-path-input-inventory-20261020/capture-inventory.json'
ATTACHMENT = 'docs/evidence/retained-why-path-initial-state-20261020/prefix-attachment.json'
DEPENDENCIES = [INVENTORY, ATTACHMENT,
    'docs/research/retained-why-path-initial-state.md',
    'docs/research/retained-why-path-library-origins.md',
    'docs/research/retained-why-save-attempt-growth.md',
    'docs/research/retained-why-save-path-input-join.md',
    'docs/evidence/retained-why-path-library-origins-20261020/result.json',
    'docs/reviews/review-save-capacity-round32-20261020.md',
    'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz',
    'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz']


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(p):
    return json.loads(p.read_text())


def seal(name, value, writing):
    raw = (json.dumps(value, indent=2) + '\n').encode()
    if writing:
        (HERE/name).write_bytes(raw)
    else:
        assert (HERE/name).read_bytes() == raw, name


def topology(heads, entries):
    by_cell = {e['cell']: e for e in entries}
    assert len(by_cell) == len(entries)
    visited = set()
    lengths = []
    for bucket, head in enumerate(heads):
        length = 0
        while head != 1:
            assert head not in visited, ('cycle or shared cell', head)
            e = by_cell[head]
            assert e['bucket'] == bucket and e['hash'] & (len(heads)-1) == bucket
            visited.add(head)
            head = e['next']
            length += 1
        lengths.append(length)
    assert visited == set(by_cell)
    return lengths


def initial_projection():
    inventory = read(ROOT/INVENTORY)
    attached = {c['case']: c for c in read(ROOT/ATTACHMENT)}
    projections = []
    members = []
    for c in inventory['cases']:
        case = c['case']
        archive = 'docs/evidence/retained-why-save-state-capture-20261020/capture-' + case.replace('_', '-') + '.tar.gz'
        with tarfile.open(ROOT/archive) as tf:
            raw = tf.extractfile(c['projection_member']).read()
        assert identity(raw) == c['projection_identity']
        members.append({'archive': archive, 'member': c['projection_member'], 'identity': identity(raw)})
        value = json.loads(raw)['sections']['restore_paths']['value']
        assert value['table'] == c['current_table_root']
        assert value['bucket_capacity'] == c['current_bucket_capacity'] == 4096
        assert value['initial_size'] == 32 and value['seed'] == 0
        assert value['disjoint_finite_chains'] and value['size_equals_binding_visits']
        assert c['current_cell_projection_matches_retained_raw_blocks'] is True
        assert value['size'] == value['binding_visits'] == c['current_entry_count'] == len(value['entries'])
        lengths = topology(value['bucket_heads'], value['entries'])
        assert len(lengths) == 4096 and max(lengths) == 7
        selected = [{'id_tag': s['id_tag'], 'occurrences': s['serializer_visits'],
                     'initial_bucket': s['id_tag'] & 4095,
                     'initial_bucket_length': lengths[s['id_tag'] & 4095]}
                    for s in c['serialized_identifier_selections']]
        projections.append({'case': case, 'pid': attached[case]['pid'],
            'cut_elf_relative_pc': attached[case]['cut_elf_relative_pc'],
            'initial_cells': len(value['entries']), 'initial_capacity': 4096,
            'initial_bucket_max': max(lengths),
            'initial_bucket_length_histogram': dict(sorted(Counter(lengths).items())),
            'identifier_occurrences': sum(s['occurrences'] for s in selected),
            'initial_serialized_bucket_visits_upper_per_save': sum(s['occurrences']*s['initial_bucket_length'] for s in selected),
            'selected_buckets': selected,
            'initial_only_counts_are_not_whole_interval_counts': True})
    return projections, members


def native_check():
    meta = read(HERE/'native-witnesses.json')
    elf = Path(meta['executable']['path']).read_bytes()
    assert identity(elf) == meta['executable']['identity']
    assert elf[:6] == b'\x7fELF\x02\x01'
    phoff = struct.unpack_from('<Q', elf, 32)[0]
    entsize, count = struct.unpack_from('<HH', elf, 54)
    loads = []
    for i in range(count):
        kind, flags, off, addr, _, size, _, _ = struct.unpack_from('<IIQQQQQQ', elf, phoff+i*entsize)
        if kind == 1:
            loads.append((addr, addr+size, off, flags))
    def at(addr, size, executable=False):
        for lo, hi, off, flags in loads:
            if lo <= addr and addr+size <= hi and (not executable or flags & 1):
                return elf[off+addr-lo:off+addr-lo+size]
        raise AssertionError((addr, size))
    bodies = read(HERE/'native-bodies.json')
    assert sorted(bodies) == meta['body_names']
    checked = 0
    for name, body in bodies.items():
        assert re.match(r'^[0-9a-f]+ <'+re.escape(name)+r'>:\n', body)
        for line in body.splitlines():
            match = INSN.match(line)
            if match:
                addr, data = int(match[1], 16), bytes.fromhex(match[2])
                assert at(addr, len(data), True) == data
                checked += len(data)
    assert checked == meta['instruction_bytes']
    literal = meta['ident_tag_closure']
    raw = at(int(literal['address'], 16), 16)
    assert raw.hex() == literal['bytes_hex']
    assert struct.unpack_from('<Q', raw)[0] == int(literal['code_address'], 16)
    # Route/backedge diagnostics corroborate, but do not replace, the reviewed proof.
    rec = bodies['camlStdlib__Ephemeron__find_rec_721']
    assert rec.count('jmp    99ff14 ') == 3
    assert 'jmp    99ff20 ' in rec and 'sub    $0x28,%rsp' in rec
    assert 'call   99ff10 ' not in rec
    assert 'jmp    99ff10 ' in bodies['camlStdlib__Ephemeron__find_730']
    assert 'jmp    9a0000 ' in bodies['camlWhy3__Theory__restore_path_4035']
    assert 'mov    0x18(%rax),%rax' in bodies['camlWhy3__Ident__tag_2120']
    assert '<camlWhy3__Ident__148>' in bodies['camlWhy3__Ident__entry']
    assert 'call   554720 ' in bodies['camlWhy3__Ident__entry']
    assert 'call   54f3a0 ' in bodies['camlWhy3__Wstdlib__fun_4401']
    assert '$0x7fffffffffffff' in bodies['caml_sys_const_max_wosize']
    assert '$0x7fffffffffffff' in bodies['camlStdlib__Ephemeron__resize_684']
    assert '$0xc00,' in bodies['camlStdlib__Ephemeron__replace_761']
    assert '<caml_alloc_small>' in bodies['optionalize']
    assert '<caml_process_pending_actions>' in bodies['optionalize']
    return len(bodies), checked


def challenges():
    full = {p: True for p in PREMISES}
    base = (6941, 7, 66)
    for p in PREMISES:
        assert lookup_bounds(*base, premises={**full, p: False})['direct_lookup_bounds'] is None
    assert lookup_bounds(*base)['direct_lookup_bounds'] is None
    assert lookup_bounds(*base, premises=full)['direct_lookup_bounds'] is not None
    assert lookup_bounds(*base, writes=0, premises=full)['candidate']['captured_chain_nodes_per_lookup_upper'] == 7
    assert lookup_bounds(*base, writes=REPRESENTED_CHAIN_MAX, premises=full)['candidate']['captured_chain_nodes_per_lookup_upper'] == REPRESENTED_CHAIN_MAX
    for args in ((True, 0, 1), (-1, 0, 1), (1, 2, 1), (1, 1, -1)):
        try:
            lookup_bounds(*args)
        except ValueError:
            pass
        else:
            raise AssertionError(args)
    for kw in ({'writes': -1}, {'writes': True}, {'saves': 4}, {'premises': {'unknown': True}}, {'premises': {PREMISES[0]: 1}}):
        try:
            lookup_bounds(*base, **kw)
        except ValueError:
            pass
        else:
            raise AssertionError(kw)
    # Tagged machine masking, negative tags and actual last admissible doubling.
    checked_indices = 0
    mask64 = (1 << 64)-1
    for exponent in range(12, 54):
        capacity = 1 << exponent
        for tag in (-(1 << 62), -(1 << 62)+1, -4097, -1, 0, 1, capacity-1, capacity, (1 << 62)-1):
            tagged = ((tag << 1) | 1) & mask64
            idx_tagged = tagged & (2*capacity-1)
            idx = tag & (capacity-1)
            assert idx_tagged == 2*idx+1 and idx_tagged < 2*capacity
            assert 4*idx_tagged-4 == 8*idx and 0 <= 8*idx <= 8*(capacity-1)
            assert 2*capacity < 1 << 62
            checked_indices += 1
        assert (2*capacity < MAX_ARRAY_LENGTH) == (exponent < 53)
    # Adversarial abstract mutation prefixes: duplicate/negative cached hashes,
    # arbitrary clean deletions, abort at every resize copy and fresh-node prepend.
    # These finite challenges are not a substitute for the source induction.
    mutation_prefixes = 0
    for hashes in ((-1, 3, 3, 0), (0, 4, 8, 12), (-4, -8, 1, 5)):
        initial = [[] for _ in range(4)]
        for key in hashes:
            initial[key & 3].append(key)
        max0 = max(map(len, initial))
        for keep in itertools.product((False, True), repeat=len(hashes)):
            live = []
            for i, key in enumerate(hashes):
                if keep[i]:
                    live.append(key)
            # Each resize destination is a new Cons; copied hashes never merge
            # different old buckets under the doubled mask.
            destination = [[] for _ in range(8)]
            for key in [None] + live:
                if key is not None:
                    destination[key & 7].append(key)
                assert sum(map(len, destination)) <= len(hashes)
                assert max(map(len, destination)) <= max0
                # A caught Not_found may prepend even an already present hash.
                for added in (-1, 0, 3, 4):
                    branch = [b[:] for b in destination]
                    branch[added & 7].insert(0, added)
                    assert sum(map(len, branch)) <= len(hashes)+1
                    assert max(map(len, branch)) <= max0+1
                    mutation_prefixes += 1
    for bad_entries in ([{'bucket': 0, 'cell': 8, 'hash': 0, 'next': 8}],
                        [{'bucket': 0, 'cell': 8, 'hash': 1, 'next': 1}]):
        try:
            topology([8, 1], bad_entries)
        except AssertionError:
            pass
        else:
            raise AssertionError('bad topology accepted')
    return checked_indices, mutation_prefixes


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    writing = parser.parse_args().write
    start = time.monotonic()
    sources = read(HERE/'source-witnesses.json')
    for s in sources:
        with tarfile.open(ROOT/s['archive']) as tf:
            raw = tf.extractfile(s['member']).read()
        assert identity(raw) == s['member_identity']
        text = ''.join(raw.decode().splitlines(keepends=True)[s['first_line']-1:s['last_line']])
        assert text == s['text'] and identity(text.encode()) == s['excerpt_identity']
    bodies, instruction_bytes = native_check()
    projection, members = initial_projection()
    seal('initial-topology.json', projection, writing)
    full = {p: True for p in PREMISES}
    result = {'scope': 'direct lookup structure and caller demand, not runtime service capacity',
        'represented_chain_ceiling': REPRESENTED_CHAIN_MAX,
        'actual_post_cut_replace_publications_upper': None,
        'cases': [{'case': c['case'], 'pid': c['pid'],
            'no_external_assertion': lookup_bounds(c['initial_cells'], c['initial_bucket_max'], c['identifier_occurrences']),
            'under_named_existing_external_premises': lookup_bounds(c['initial_cells'], c['initial_bucket_max'], c['identifier_occurrences'], premises=full)}
            for c in projection]}
    seal('result.json', result, writing)
    inputs = {'files': {f: identity((ROOT/f).read_bytes()) for f in DEPENDENCIES},
        'members': members,
        'local_files': {f: identity((HERE/f).read_bytes()) for f in
            ('source-witnesses.json', 'native-witnesses.json', 'native-bodies.json', 'initial-topology.json', 'transfer.py', 'result.json')}}
    seal('inputs.json', inputs, writing)
    index_checks, mutation_prefixes = challenges()
    print(json.dumps({'status': 'pass', 'source_excerpts': len(sources),
        'native_bodies': bodies, 'instruction_bytes': instruction_bytes,
        'native_literal_bytes': 16, 'attached_topologies': len(projection),
        'tagged_index_boundary_checks': index_checks, 'mutation_prefix_challenges': mutation_prefixes,
        'direct_lookup_structure_under_named_premises': True,
        'actual_post_cut_replace_publications_upper': None,
        'complete_restore_table_capacity_established': False, 'native_runs': 0,
        'elapsed_seconds': time.monotonic()-start}, indent=2))


if __name__ == '__main__':
    main()

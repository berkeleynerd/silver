#!/usr/bin/env python3
"""Offline identity, layout, warning-route and hash-envelope checks."""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import random
import re
import time

from derive import PRIMES, P0, evaluate, prime_at_least

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def require(value, message):
    if not value:
        raise AssertionError(message)


def main():
    start = time.monotonic()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-root', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--ada-root', type=Path,
                        default=Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada'))
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE / 'source-manifest.json').read_text())
    sources = {}
    for row in manifest['files']:
        root = args.ada_root if row['root'] == 'ada' else args.source_root
        path = row['path'].removeprefix('gcc/ada/') if row['root'] == 'ada' else row['path']
        data = (root / path).read_bytes()
        require(len(data) == row['bytes'] and hashlib.sha256(data).hexdigest() == row['sha256'],
                'source identity: ' + row['path'])
        sources[row['path']] = data.decode()
    for row in manifest['retained_inputs']:
        data = (REPO / row['path']).read_bytes()
        require(hashlib.sha256(data).hexdigest() == row['sha256'], 'retained input: '+row['path'])

    raw_primes = re.findall(r'^\s*\{\s*(\d+|0x[0-9a-f]+),', sources['gcc/hash-table.cc'], re.M)
    require(tuple(int(n, 0) for n in raw_primes) == PRIMES, 'complete prime sequence')
    prefix = json.loads((REPO / manifest['retained_inputs'][0]['path']).read_bytes())
    require(not prefix['counter_wrap_or_reset'] and not prefix['collection_or_new_thread_observed'],
            'prefix capture conditions')
    largest = prefix['counters']['ggc_bytes']['largest_increment']
    require(largest == 65536 and max(p for p in PRIMES if 16*p <= largest) == P0,
            'incoming backing-byte derivation')

    class Entry(ctypes.Structure):
        _fields_ = [('location', ctypes.c_uint64), ('bits', ctypes.c_uint)]

    class ControlWithChecking(ctypes.Structure):
        _fields_ = [('inserting', ctypes.c_void_p), ('entries', ctypes.c_void_p),
                    ('size', ctypes.c_size_t), ('occupied', ctypes.c_size_t),
                    ('deleted', ctypes.c_size_t), ('searches', ctypes.c_uint),
                    ('collisions', ctypes.c_uint), ('prime_index', ctypes.c_uint),
                    ('ggc', ctypes.c_bool), ('sanitize', ctypes.c_bool)]

    require(ctypes.sizeof(ctypes.c_void_p) == 8 and ctypes.sizeof(ctypes.c_uint) == 4,
            'selected LP64 layout')
    require(ctypes.sizeof(Entry) == 16 and ctypes.sizeof(ControlWithChecking) <= 64,
            'entry/control layout arithmetic')
    require('typedef uint64_t location_t;' in sources['libcpp/include/line-map.h'], 'location width')
    require('unsigned m_bits;' in sources['gcc/gcc-diagnostic-spec.h'], 'inline warning bitset')
    require('typedef unsigned int hashval_t;' in sources['include/hashtab.h'], 'probe width')

    # LF-based source inventory; line numbers agree even when source contains FF.
    pattern = re.compile(r'\b(copy_warning|suppress_warning)\s*\(')
    inventory = {}
    for path, source in sources.items():
        if path.startswith('gcc/ada/gcc-interface/') and path.endswith('.cc'):
            inventory[path] = [dict(line=i, call=m.group(1), text=line.strip())
                               for i, line in enumerate(source.split('\n'), 1)
                               if (m := pattern.search(line))]
    require([(p, r['line']) for p, rows in inventory.items() for r in rows]
            == [('gcc/ada/gcc-interface/trans.cc', 9420),
                ('gcc/ada/gcc-interface/utils.cc', 959)], 'direct Ada warning frontier')
    gimplify = sources['gcc/gimplify.cc']
    direct_sites = [i for i, line in enumerate(gimplify.split('\n'), 1) if pattern.search(line)]
    require(direct_sites == [1886, 1948, 1962, 5728, 7296, 7406, 7601, 8529, 20903],
            'complete direct gimplifier warning inventory')
    gimple = sources['gcc/gimple.cc']
    call_builder = gimple[gimple.index('gimple_build_call_from_tree ('):gimple.index('gimple_build_call_from_tree (')+2600]
    require(call_builder.index('gimple_set_block (call, TREE_BLOCK (t));')
            < call_builder.index('gimple_set_location (call, EXPR_LOCATION (t));')
            < call_builder.index('copy_warning (call, t);'), 'call builder setter/copy order')
    require('if (g->location != UNKNOWN_LOCATION)\n    copy_warning (location, g->location);'
            in sources['gcc/gimple.h'], 'location copy ignores no_warning bit')
    require('if (!gimple_has_location (gs)' in gimple, 'annotation missing-location guard')
    require('stmt = ggc_alloc_cleared_gimple_statement_stat (size PASS_MEM_STAT);' in gimple,
            'new tuples cleared')
    copier = sources['gcc/tree-inline.cc'].split('copy_tree_r (tree *tp,')[1].split('remap_save_expr (')[0]
    require('copy_warning' not in copier and 'suppress_warning' not in copier,
            'ordinary copying has no warning mutation')
    utils = sources['gcc/ada/gcc-interface/utils.cc']
    require(utils.index('suppress_warning (decl);')
            < utils.index('Sloc_to_locus (Sloc (gnat_node), &DECL_SOURCE_LOCATION (decl));'),
            'suppression precedes declaration location replacement')

    # Independent counter-state stress: arbitrary removals, hits and fresh-key
    # puts. Tombstone reuse versus unused-slot insertion is chosen adversarially.
    rng = random.Random(119)
    examined = expansions_on_hits = 0
    for trial in range(150):
        capacity, occupied, deleted, puts, backings = 61, 0, 0, 0, 1
        for _ in range(400):
            live = occupied-deleted
            if live and rng.randrange(5) == 0:
                deleted += 1
            else:
                hit = bool(live and rng.randrange(3) == 0)
                puts += 1
                if 3*capacity <= 4*occupied:
                    if 2*live > capacity or ((8*live) & (2**32-1)) < capacity and capacity > 32:
                        capacity = prime_at_least(2*live)
                    occupied, deleted = live, 0
                    backings += 1
                    expansions_on_hits += int(hit)
                if not hit:
                    if deleted and rng.randrange(2):
                        deleted -= 1
                    else:
                        occupied += 1
            require(0 <= deleted <= occupied < capacity, 'one empty slot retained')
            require(occupied <= puts and capacity <= prime_at_least(max(32, 2*puts)),
                    'put-count growth envelope')
            require(backings <= max(1, puts), 'initial plus replacement backing count')
            examined += 1
    require(expansions_on_hits > 0, 'replacement-before-hit exercised')

    unspecified = evaluate(1, 0)
    require(unspecified['conditional_map_transfer'] is None, 'missing R stays missing')
    hypothetical = evaluate(1, 0, 0)
    require(not hypothetical['original_gigi_source_count_closed'], 'R=0 is not source closure')
    endpoint_R = (2**30-1)-P0-2-3
    endpoint = evaluate(1, 0, endpoint_R)['conditional_map_transfer']
    require(endpoint['conditional_map_interface_fits'], 'sufficient endpoint accepted')
    require(endpoint['outgoing_capacity_ceiling'] == 2147483647, 'endpoint prime')
    require(not evaluate(1, 0, endpoint_R+1)['conditional_map_transfer']['conditional_map_interface_fits'],
            'outside sufficient region rejected')
    require(not evaluate(2**64, 0, 0)['conditional_map_transfer']['conditional_map_interface_fits'],
            'prime exhaustion handled without indexing past table')
    for bad in [(0, 0, None), (1, -1, None), (True, 0, None), (1, 0, -1)]:
        try:
            evaluate(*bad)
        except ValueError:
            pass
        else:
            raise AssertionError('invalid input accepted')
    result = dict(
        source_files_verified=len(sources), retained_inputs_verified=len(manifest['retained_inputs']),
        source_commit=manifest['commit'], native_execution=False,
        model_or_semantic_proof=False, prefix_maximum_rounded_request=largest,
        prefix_capacity_ceiling=P0, entry_bytes=ctypes.sizeof(Entry),
        checking_control_layout_bytes=ctypes.sizeof(ControlWithChecking),
        direct_Ada_warning_sites=inventory, direct_gimplifier_warning_lines=direct_sites,
        counter_states_exercised=examined, expansions_before_existing_key_hits=expansions_on_hits,
        missing_R=unspecified, hypothetical_R_zero=hypothetical,
        sufficient_endpoint_R=endpoint_R, sufficient_endpoint=endpoint,
        result='PASS', elapsed_seconds=round(time.monotonic()-start, 6))
    rendered = json.dumps(result, indent=2, sort_keys=True)+'\n'
    if args.output:
        args.output.write_text(rendered)
    print(rendered, end='')


if __name__ == '__main__':
    main()

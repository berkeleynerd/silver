#!/usr/bin/env python3
"""Focused offline identities, source interfaces, growth and ownership checks."""
import argparse
import copy
import ctypes
from datetime import datetime, timezone
import json
from pathlib import Path
import random
import re
import tempfile
import time

from derive import (Context, HERE, REPO, I32, U32, REGION, derive, evaluate,
                    evaluate_source, identity, corrected_shared_identifier_projection)
from inventory import scan


def main():
    started = datetime.now(timezone.utc).isoformat()
    start = time.monotonic()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path, default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--ada-root', type=Path, default=Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada'))
    parser.add_argument('--output', type=Path, default=HERE/'check-results.json')
    args = parser.parse_args()
    context = Context(args.gcc_root, args.ada_root)
    checks = []

    def check(name, condition):
        if not condition:
            raise AssertionError(name)
        checks.append(name)

    def reject(name, function):
        try:
            function()
        except (ValueError, TypeError):
            checks.append(name)
        else:
            raise AssertionError('accepted '+name)

    census, _ = scan(args.gcc_root)
    check('exact complete retained source corpus and writer inventory',
          census == json.loads((HERE/'writer-inventory.json').read_bytes()))
    source = {r['path']:(context.roots[r['root']]/r['path']).read_text()
              for r in context.manifest['files'] if r['root'] != 'repository'}
    snippets = {
        'libcpp/line-map.cc': [
            'new (set) line_maps();',
            'htab_create (100, location_adhoc_data_hash, location_adhoc_data_eq, NULL);',
            'if (locus == 0 && data == NULL)',
            'htab_find_slot (m_location_adhoc_data_map.htab, &lb, INSERT)',
            'm_location_adhoc_data_map.allocated = 128;',
            'm_location_adhoc_data_map.allocated *= 2;',
            'm_location_adhoc_data_map.data[m_location_adhoc_data_map.curr_loc++]',
            'htab_traverse (m_location_adhoc_data_map.htab,',
            '(CHAR_BIT * sizeof (linenum_type) - column_bits)',
        ],
        'libcpp/include/line-map.h': ['typedef unsigned int linenum_type;',
            'typedef uint64_t location_t;', 'unsigned discriminator;',
            'location_t curr_loc;', 'line_map_uint_t allocated;'],
        'gcc/gimple.h': ['gimple_set_location (g, set_block (g->location, block));',
            'if (g->location != UNKNOWN_LOCATION)\n    copy_warning (location, g->location);'],
        'gcc/tree.cc': ['return line_table->get_or_create_combined_loc (pure_loc, src_range, block,',
                        't->exp.locus = set_block (t->exp.locus, b);'],
        'gcc/gimple-low.cc': ['gimple_set_block (stmt, data->block);',
            'if (EXPR_P (arg))\n\t      TREE_SET_BLOCK (arg, data->block);',
            'gimple_set_location (tmp_rs.stmt, UNKNOWN_LOCATION);'],
        'gcc/tree-cfg.cc': ['assign_discriminators ();',
            'unsigned int bb_id = 0;', 'e.discrim++;',
            'return location_with_discriminator (loc, e.discrim);',
            'gimple_set_location (stmt, prev_replacement);',
            'e->goto_locus = assign_discriminator (e->goto_locus, bb_id, map);'],
        'gcc/input.cc': ['location_with_discriminator (location_t locus, int discriminator)',
            'int\nget_discriminator_from_loc (location_t locus)'],
        'gcc/tree-ssa-live.cc': ['if (VAR_P (t) && DECL_HAS_VALUE_EXPR_P (t))',
            'if (!is_gimple_debug (stmt) && !gimple_clobber_p (stmt))'],
        'gcc/toplev.cc': ['line_table->m_reallocator = realloc_for_line_map;',
                          'return ggc_realloc (ptr, len);'],
        'gcc/ggc-common.cc': ['if (size <= old_size)', 'return ggc_internal_alloc (size PASS_MEM_STAT);'],
        'libiberty/hashtab.c': ['if (insert == INSERT && size * 3 <= htab->n_elements * 4)',
                              'else if ((*htab->eq_f) (entry, element))',
                              'if (htab_elements (htab) * 8 < size && size > 32)\n    htab_expand (htab);'],
        'gcc/fold-const.cc': ['copy_warning (ret, arg);',
                             'if (TREE_CODE (op0) == MODIFY_EXPR',
                             'suppress_warning (tem /* What warning? */);'],
        'gcc/stringpool.cc': ['ident_hash = ht_create (14);',
                             'ident_hash->alloc_subobject = stringpool_ggc_alloc;'],
        'libcpp/symtab.cc': ['if (++table->nelements * 4 >= table->nslots * 3)',
                            'size = table->nslots * 2;',
                            'char *chars = (char *) table->alloc_subobject (len + 1);'],
        'gcc/gimple-expr.cc': ['static GTY(()) unsigned int tmp_var_id_num;',
                             'ASM_FORMAT_PRIVATE_NAME (tmp_name, prefix ? prefix : "T", tmp_var_id_num++);'],
        'gcc/gcc-diagnostic-spec.cc': ['copy_warning (location_t to, location_t from)',
            'if (!nowarn_map)\n    return;', 'if (RESERVED_LOCATION_P (to))',
            'nowarn_map->put (to, tem);'],
    }
    for path, rows in snippets.items():
        for row in rows:
            check('source landmark '+path+': '+row.split('\n')[0], row in source[path])
    call = source['gcc/gimple.cc'].split('gimple_build_call_from_tree (')[1].split('\n}\n', 1)[0]
    check('initial call block/locus/warning order',
          call.index('gimple_set_block (') < call.index('gimple_set_location (') < call.index('copy_warning ('))
    expansion = source['gcc/cfgexpand.cc']
    check('RTL call reconstruction location then warning copy',
          'SET_EXPR_LOCATION (exp, gimple_location (stmt));\n\n  /* Must come after copying location.  */\n  copy_warning (exp, stmt);' in expansion)
    check('no direct Ada combined-location API', all(
        name not in source[path]
        for path in ('gcc/ada/gcc-interface/trans.cc', 'gcc/ada/gcc-interface/utils.cc',
                     'gcc/ada/gcc-interface/decl.cc', 'gcc/ada/gcc-interface/utils2.cc')
        for name in ('get_or_create_combined_loc', 'TREE_SET_BLOCK', 'make_location (', 'set_source_range (')))

    class Adhoc(ctypes.Structure):
        _fields_ = [('locus', ctypes.c_uint64), ('start', ctypes.c_uint64),
                    ('finish', ctypes.c_uint64), ('data', ctypes.c_void_p),
                    ('discriminator', ctypes.c_uint)]
    check('actual checker host LP64 and source-derived ad-hoc layout',
          ctypes.sizeof(ctypes.c_void_p) == 8 and ctypes.sizeof(ctypes.c_uint) == 4
          and ctypes.sizeof(Adhoc) == 40)

    hello = (REPO/'samples/hello_world.adb').read_bytes()
    result = evaluate_source(hello, context)
    check('retained Hello result exact', result == json.loads((HERE/'result.json').read_bytes()))
    check('Hello independently counted request owners',
          result['location_requests']['fresh_entries_upper'] == 1+6+8 == 15 and
          result['later_warning']['insertion_capable_put_calls_upper'] == 6+5+1 == 12 and
          result['additional_location_and_later_warning_GGC_events_upper'] == 13)
    check('predecessor retained unchanged',
          result['later_warning']['incoming'] == context.warning(1, 0, 5)['conditional_map_transfer'])
    check('filename objects are separate direct ownership',
          result['filename_ingress']['direct_GGC_requests_upper'] == 3180 and
          not result['filename_ingress']['included_in_new_location_warning_delta'])
    filename = result['filename_ingress']
    check('indexed filename correction preserves old explicit counts',
          filename['predecessor_source_file_entries_upper'] == 1588 and
          filename['source_file_entries_upper'] == 1589 and
          filename['predecessor_lookup_calls_upper'] == 1589 and
          filename['lookup_calls_upper'] == 1590 and
          not filename['original_shared_packet_modified'])
    before = copy.deepcopy(context.shared)
    correction = corrected_shared_identifier_projection(context.shared, result['source'], result['source_counts'])
    check('retained source-bound shared correction exact',
          correction == json.loads((HERE/'shared-identifier-correction.json').read_bytes()))
    check('shared predecessor remains unchanged', context.shared == before and
          correction['predecessor_identifier_hash'] == context.shared['identifier_hash'])
    corrected = correction['identifier_hash']
    check('Hello corrected shared identifier and temporary endpoints',
          corrected['incoming_historical_insertions_upper'] == 40847 and
          corrected['historical_insertions_upper'] == 40883 and
          corrected['allocated_slots_upper'] == 65536 and
          corrected['variable_ingress_backing_requests_upper'] == 1590 and
          corrected['post_prefix_backing_requests_upper'] == 36 and
          all(corrected['checks'].values()) and
          correction['temporary_name_serial']['incoming_upper'] == 40847 and
          correction['temporary_name_serial']['next_upper'] == 40883 and
          all(correction['temporary_name_serial']['checks'].values()))
    check('shared filename correction adds no shared GGC backing delta',
          correction['original_shared_GGC_backing_delta_unchanged'] == 768 and
          correction['extra_shared_GGC_backing_events'] == 0 and
          not correction['aggregate_attachment_complete'])
    wrong_source = dict(result['source'], sha256='0'*64)
    reject('shared projection mismatched source identity', lambda:corrected_shared_identifier_projection(
        context.shared, wrong_source, result['source_counts']))
    wrong_counts = dict(result['source_counts'], output_calls=2)
    reject('shared projection mismatched recognized counts', lambda:corrected_shared_identifier_projection(
        context.shared, result['source'], wrong_counts))
    changed_shared = copy.deepcopy(context.shared)
    changed_shared['identifier_hash']['incoming_occupied_upper'] = 0
    reject('shared projection altered incoming state', lambda:corrected_shared_identifier_projection(
        changed_shared, result['source'], result['source_counts']))
    # Artificial arithmetic boundary interfaces retain source markers only for
    # exercising the projection, not as claims about those source demands.
    for history in (49151, U32//4, U32):
        changed_shared = copy.deepcopy(context.shared)
        additions = history-40846
        slots = 16384
        while 3*slots <= 4*history:
            slots *= 2
        old = changed_shared['identifier_hash']
        old.update(historical_insertions_upper=history, occupied_upper=history,
            allocated_slots_upper=slots, each_ordinary_backing_bytes_upper=8*slots,
            post_prefix_backing_requests_upper=additions)
        old['checks'] = dict(historical_insertions_unsigned=4*history <= U32,
            slot_threshold_unsigned=3*slots <= U32, doubling_unsigned=slots <= U32,
            individual_request=8*slots <= 2**63-1)
        old['fits'] = all(old['checks'].values())
        changed_shared['source_bound_demands']['identifier_new_entries'] = additions
        changed_shared['counter_endpoints']['next_temporary_name_serial_upper'] = history
        projected = corrected_shared_identifier_projection(changed_shared, result['source'], result['source_counts'])
        new_slots = slots
        while 3*new_slots <= 4*(history+1):
            new_slots *= 2
        check('corrected shared arithmetic endpoint '+str(history),
              projected['identifier_hash']['allocated_slots_upper'] == new_slots and
              projected['identifier_hash']['checks']['historical_insertions_unsigned'] == (history+1 <= U32//4) and
              projected['temporary_name_serial']['checks']['temporary_name_serial_unsigned'] == (history+1 <= U32))
    check('no new controls or finalizers',
          result['later_warning']['additional_controls'] == 0 and
          result['additional_location_and_later_warning_finalizer_registrations'] == 0 and
          result['ad_hoc_storage']['initial_ordinary_objects_added_again'] == 0)
    check('whole compiler and collector remain unestablished',
          result['total_GGC_events'] is None and result['whole_original_gigi_allocation_events'] is None and
          not any(result[k] for k in ('whole_literal_pipeline_capacity_established',
              'complete_global_counter_lifetime_closed', 'complete_collector_lifetime_closed',
              'complete_gimplifier_lifetime_closed', 'production_admission_changed', 'aggregate_RAM_gate')))

    def program(body, ending=b'\n'):
        return b'with Silver_IO;'+ending+b'procedure Main is pragma SPARK_Mode (On); begin'+ending+body+ending+b'end Main;'+ending

    cases = [
        (program(b'Silver_IO.Put ("");'), 1, 0),
        (program(b'null; Silver_IO.Put ("a""b"); null; Silver_IO.Put_Line ("");'), 2, 2),
        (program(b'-- Put("x")\r\nSilver_IO.Put ("literal null;");', b'\r\n'), 1, 0),
        (program(b'sIlVeR_iO.pUt_Line ("'+b'x'*8192+b'");'), 1, 0),
        (program(b'Silver_IO.Put ("x");'*31+b'null;'*9), 31, 9),
        (program(b'Silver_IO.Put_Line ("x");'*5000), 5000, 0),
    ]
    for i, (raw, c, n) in enumerate(cases):
        actual = evaluate_source(raw, context)
        check('actual source case '+str(i), actual['counts'] == dict(output_calls=c, null_statements=n)
              and all(actual['conditions'].values()) and actual['Main_ordinary_map_line_guard'])
    for i, raw in enumerate([b'', program(b'null;'), program(b'Silver_IO.Put (x);'),
            program(b'Put ("x");'), program(b'Silver_IO.Put ("x");\v'),
            program(b'Silver_IO.Put ("x"); pragma Source_Reference (1, "x");')]):
        reject('invalid source '+str(i), lambda raw=raw:evaluate_source(raw, context))
    for values in [(0, 0), (1, -1), (True, 0), (1, False), (1.0, 0)]:
        reject('invalid counters '+repr(values), lambda values=values:evaluate(*values, context))
    old = context.warning(1, 0, 5)
    for field, value in [('prefix_capacity_ceiling', 0), ('other_original_gigi_put_calls', 0),
                         ('selected_initial_gimplifier_warning_put_call_ceiling', 2)]:
        changed = copy.deepcopy(old); changed[field] = value
        reject('predecessor mutation '+field, lambda changed=changed:derive(1, 0, changed, context.primes))
    changed = copy.deepcopy(old)
    changed['conditional_map_transfer']['outgoing_live_or_occupied_ceiling'] = 0
    reject('predecessor occupancy mutation', lambda:derive(1, 0, changed, context.primes))

    check('Q=127 last initial backing', evaluate(15, 0, context)['ad_hoc_storage']['allocated_entries_upper'] == 128)
    check('Q=131 first doubled backing', evaluate(15, 1, context)['ad_hoc_storage']['allocated_entries_upper'] == 256)
    check('relocation traversal ordinary hash charge starts with second array backing',
          evaluate(15, 0, context)['ad_hoc_storage']['additional_ordinary_hash_backings_upper'] == 127 and
          evaluate(15, 1, context)['ad_hoc_storage']['lookup_ordinary_hash_backings_upper'] == 131 and
          evaluate(15, 1, context)['ad_hoc_storage']['relocation_traversal_possible_hash_backings_upper'] == 1 and
          evaluate(15, 1, context)['ad_hoc_storage']['additional_ordinary_hash_backings_upper'] == 132)
    n = (REGION-4115)//4
    at, beyond = evaluate(1, n, context), evaluate(1, n+1, context)
    check('warning occupied exact sufficient endpoint', at['later_warning']['outgoing_live_or_occupied_upper'] == REGION
          and at['conditions']['later_warning_storage'])
    check('warning endpoint immediate successor rejected', not beyond['conditions']['later_warning_storage'])
    c = (REGION-7)//8
    check('ad-hoc sufficient endpoint neighboring counts',
          evaluate(c, 0, context)['conditions']['ad_hoc_storage'] and
          not evaluate(c+1, 0, context)['conditions']['ad_hoc_storage'])
    check('signed discriminator bridge exact guard',
          evaluate(I32-4, 0, context)['local_checks']['locations']['discriminator_unsigned_to_signed_int'] and
          not evaluate(I32-3, 0, context)['local_checks']['locations']['discriminator_unsigned_to_signed_int'])
    check('path Short boundary and separate object guard',
          evaluate(1, 0, context, 32767)['conditions']['filename_direct_objects'] and
          not evaluate(1, 0, context, 32768)['conditions']['filename_direct_objects'])

    # Independent small insertion simulation: pre-hit C hash expansion, fresh
    # ad-hoc records, array growth and reallocation slack. No GCC execution.
    prime = lambda v:next(p for p in context.primes if p >= v)
    rng = random.Random(119)
    for budget in (15, 95, 96, 127, 128, 129, 255, 256, 257, 1024, 4096):
        for mode in ('fresh', 'repeated', 'mixed'):
            keys, slots, cap, allocated_bytes, ggc, hashes, traversals = set(), 127, 0, 0, 0, 0, 0
            for i in range(budget):
                if mode == 'mixed' and i % 11 == 0:
                    continue  # Reserved/compact early return, already charged.
                key = i if mode == 'fresh' else (i//3 if mode == 'repeated' else rng.randrange(i+1))
                if slots*3 <= len(keys)*4:
                    slots = prime(2*len(keys)); hashes += 1
                if key in keys:
                    continue
                if len(keys) >= cap:
                    cap = 128 if cap == 0 else 2*cap
                    needed = 40*cap
                    if needed > allocated_bytes:
                        allocated_bytes = 1 << (needed-1).bit_length(); ggc += 1
                    if cap > 128:
                        traversals += 1
                        # INSERT has already reserved the new empty slot and
                        # incremented the C hash element count before traversal.
                        if 8*(len(keys)+1) < slots and slots > 32:
                            slots = prime(2*(len(keys)+1)); hashes += 1
                keys.add(key)
            ceiling = 128
            events = 1
            while ceiling < budget:
                ceiling *= 2; events += 1
            check('independent ad-hoc simulation '+str(budget)+' '+mode,
                  len(keys) <= budget and cap <= ceiling and ggc <= events and
                  traversals <= events-1 and hashes <= budget+events-1 and
                  slots <= prime(max(127, 2*budget)))

    # Existing incoming warning state can include tombstones. Compare later
    # replacement/occupancy bounds with independent hit/remove histories.
    for mode in ('fresh', 'hits', 'mixed'):
        c, n = 2000, 1
        envelope = evaluate(c, n, context)['later_warning']
        keys = set(range(3000)); occupied = len(keys); slots = 4093; requests = 0
        original_initial = (2*c+n+5)+(2*c+1)
        total_calls = original_initial+envelope['insertion_capable_put_calls_upper']
        for i in range(total_calls):
            if mode == 'mixed' and i % 7 == 0:
                keys.discard(i % 3000)  # Tombstone remains occupied.
                continue
            if slots*3 <= occupied*4:
                live = len(keys)
                if 2*live > slots or (8*live < slots and slots > 32):
                    slots = prime(max(2*live, 7))
                occupied = live
                requests += 1
            key = 3000+i if mode == 'fresh' else (i % 3000 if mode == 'hits' else 3000+i//2)
            if key not in keys:
                keys.add(key); occupied += 1
        check('independent warning hit/remove history '+mode,
              requests <= total_calls and occupied <= envelope['outgoing_live_or_occupied_upper'] and
              slots <= envelope['outgoing_capacity_upper'])

    # Substitute one altered source while sharing every other retained input.
    with tempfile.TemporaryDirectory(prefix='silver-location-negative-') as temporary:
        root = Path(temporary)
        for row in context.manifest['files']:
            if row['root'] == 'gcc':
                target = root/row['path']; target.parent.mkdir(parents=True, exist_ok=True)
                target.symlink_to(args.gcc_root/row['path'])
        changed = root/'gcc/gimple.h'; changed.unlink()
        changed.write_text(source['gcc/gimple.h'].replace('if (g->location != UNKNOWN_LOCATION)', 'if (false)'))
        reject('changed full source rejected', lambda:Context(root, args.ada_root))

    report = dict(scope='Focused literal location/warning identity and arithmetic checks',
        passed=True, checks=len(checks), cases=checks, started_utc=started,
        completed_utc=datetime.now(timezone.utc).isoformat(), elapsed_seconds=time.monotonic()-start,
        corpus_files=census['corpus_files'], source_files=context.source_inputs_verified,
        repository_inputs=context.repository_inputs_verified,
        callable_identity=identity((HERE/'derive.py').read_bytes()),
        source_argument_identity=identity((REPO/'docs/research/retained-literal-location-lifetime.md').read_bytes()),
        native_tool_executions=0, compiler_builds=0, prover_runs=0, selected_model='GPT-6 Astra',
        selected_effort='Extra High', runtime_confirmed_model_effort=None, token_cost_evidence=None,
        independent_review='pending')
    args.output.write_text(json.dumps(report, indent=2, sort_keys=True)+'\n')
    print(json.dumps({k:report[k] for k in ('passed', 'checks', 'elapsed_seconds', 'native_tool_executions')}))


if __name__ == '__main__':
    main()

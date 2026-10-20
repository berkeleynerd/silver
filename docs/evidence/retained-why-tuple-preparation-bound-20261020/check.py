"""Focused retained Ddata-family projection; no native or predecessor replay.

The source argument is in the companion note. This is not an OCaml interpreter.
"""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EVIDENCE = HERE.parent
CAPTURE = EVIDENCE / 'retained-why-save-state-capture-20261020'
CASES = [('put_line', 63, 194), ('put', 63, 161),
         ('first_or_default', 61, 98), ('is_message', 58, 11),
         ('input_is_valid', 59, 5)]
SOURCES = ['core/decl.ml', 'core/decl.mli', 'core/task.ml', 'core/trans.ml',
           'core/theory.ml', 'core/ty.ml', 'driver/driver.ml', 'util/hashcons.ml',
           'util/weakhtbl.ml', 'transform/prepare_for_counterexmp.ml',
           'transform/inlining.ml', 'transform/eliminate_definition.ml',
           'transform/remove_unused.ml', 'transform/detect_polymorphism.ml',
           'transform/eliminate_inductive.ml', 'transform/eliminate_epsilon.ml',
           'transform/eliminate_gnatprove_guard_epsilon.ml',
           'transform/eliminate_literal.ml', 'transform/simplify_formula.ml',
           'transform/eliminate_algebraic.ml', 'transform/libencoding.ml',
           'transform/introduction.ml', 'transform/discriminate.ml',
           'transform/encoding.ml', 'transform/encoding_twin.ml',
           'transform/encoding_guards.ml', 'transform/encoding_tags.ml',
           'transform/encoding_guards_full.ml', 'transform/encoding_tags_full.ml',
           'transform/encoding_select.ml', 'transform/encoding_sort.ml',
           'transform/split_goal.ml', 'parser/typing.ml', 'mlw/pdecl.ml',
           'mlw/pmodule.ml', 'mlw/vc.ml']


def ident(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def dump(obj):
    return (json.dumps(obj, indent=2, sort_keys=True) + '\n').encode()


def decoded(raw):
    assert raw & 1
    return (raw - (1 << 64) if raw >= 1 << 63 else raw) >> 1


def compute():
    inputs, rows = {}, []
    manifest_path = CAPTURE / 'capture-manifest.json'
    inputs[str(manifest_path.relative_to(ROOT))] = ident(manifest_path.read_bytes())
    manifest = json.loads(manifest_path.read_bytes())
    # Selected member identities below also bind this new projection to the
    # retained capture manifest; no old observer/comparator is invoked.
    members = {member['path']: {k: member[k] for k in ('bytes', 'sha256')}
               for archive in manifest['archives'] for member in archive['members']}
    writers = json.loads((EVIDENCE / 'retained-why-path-writer-capacity-20261020/result.json').read_bytes())
    statuses = json.loads((EVIDENCE / 'retained-why-status-entry-20261020/result.json').read_bytes())
    assert statuses['capture_manifest_identity'] == ident(manifest_path.read_bytes())

    for case, expected_heads, episodes in CASES:
        path = CAPTURE / ('capture-' + case.replace('_', '-') + '.tar.gz')
        with tarfile.open(path) as archive:
            names = archive.getnames()
            selected = {}
            def read(suffix):
                found = [n for n in names if n.endswith('/' + suffix)]
                assert len(found) == 1
                name = found[0]
                data = archive.extractfile(name).read()
                selected[name] = ident(data)
                assert selected[name] == members[name]
                if name in statuses['consumed_archive_members']:
                    old = statuses['consumed_archive_members'][name]
                    assert selected[name] == {k: old[k] for k in ('bytes', 'sha256')}
                return data
            graph = json.loads(read('inline-entry-graph.json' if case == 'input_is_valid'
                                    else 'representative-graph.json'))
            table = json.loads(read('hsdecl-table.json'))
            chains = json.loads(read('session-task-chains.json'))
            process = json.loads(read('process.json'))
            writer = next(r for r in writers['cases'] if r['case'] == case)
            status = next(r for r in statuses['cases'] if r['case'] == case)
            assert process['pid'] == writer['pid'] == status['pid']
            assert episodes == writer['under_named_existing_premises']['dispatch_bounds'][
                'algebraic_tuple_fold_entries_upper']
            blocks = graph['blocks']
            roots = table['retained_unique_declarations']
            assert roots == graph.get('hsdecl_declaration_roots', graph['roots'])
            # Every allocated Hsdecl bucket/key slot, including duplicate keys,
            # is enumerated. Ddata nodes are read for every distinct key.
            present, slots, seen = 0, 0, []
            assert len(table['buckets']) == table['outer_length']
            for i, bucket in enumerate(table['buckets']):
                assert bucket['index'] == i
                assert bucket['address'] == table['outer_array']['fields'][i]
                payload = bucket['payload']
                assert bucket['header'] & 255 == 251
                assert bucket['header'] >> 10 == len(payload)
                assert payload[1] == table['ephe_none_value']
                assert len(bucket['hash_array']['fields']) == len(payload) - 2
                slots += len(payload) - 2
                for key in payload[2:]:
                    if key == table['ephe_none_value']:
                        continue
                    present += 1
                    if key not in seen:
                        seen.append(key)
            assert seen == roots
            assert slots == table['allocated_key_slots']
            assert present == table['nonempty_key_slots']

            def fields(pointer, tag, words):
                block = blocks[str(pointer)]
                assert block['tag'] == tag and block['words'] == words
                assert block['header'] & 255 == tag
                assert block['header'] >> 10 == words
                assert len(block['fields']) == words
                return block['fields']

            def seq(pointer):
                values, visited = [], set()
                while pointer != 1:
                    assert pointer not in visited
                    visited.add(pointer)
                    head, pointer = fields(pointer, 0, 2)
                    values.append(head)
                return values

            def string(pointer):
                block = blocks[str(pointer)]
                assert block['tag'] == 252
                raw = bytes.fromhex(block['payload_hex'])
                assert len(raw) == block['words'] * 8
                return raw[:-raw[-1]-1].decode()

            declarations, heads = [], {}
            for declaration in roots:
                node = fields(declaration, 0, 3)[0]
                kind = blocks[str(node)]['tag']
                assert 0 <= kind <= 5
                if kind != 1:
                    continue
                row = {'declaration': declaration, 'type_heads': []}
                for pair in seq(fields(node, 1, 1)[0]):
                    ts, _constructors = fields(pair, 0, 2)
                    identifier, args, _definition = fields(ts, 0, 3)
                    name, _attrs, _loc, tag = fields(identifier, 0, 4)
                    detail = {'type_symbol': ts, 'identifier': identifier,
                              'identifier_tag': decoded(tag), 'name': string(name),
                              'arity': len(seq(args))}
                    assert heads.setdefault(ts, detail) == detail
                    row['type_heads'].append(ts)
                assert row['type_heads']
                declarations.append(row)
            assert len(heads) == expected_heads
            assert sorted({h['arity'] for h in heads.values()}) == list(range(5))
            # Raw context chains are a distinct input domain. Check every
            # Ddata declaration against the global representative census.
            session_blocks = {}
            for line in read('session-blocks.jsonl').splitlines():
                block = json.loads(line)
                session_blocks[block['address']] = block
            def sfields(pointer, tag, words):
                b = session_blocks[pointer]
                assert b['tag'] == tag and b['words'] == words
                return struct.unpack('<' + 'Q' * words, bytes.fromhex(b['payload_hex']))
            raw_data, raw_heads = set(), set()
            chain_rows = []
            for root, chain in chains.items():
                ds = []
                for entry in chain:
                    td = sfields(entry['tdecl'], 0, 2)[0]
                    node = session_blocks[td]
                    if node['tag'] != 0:
                        continue
                    declaration = sfields(td, 0, 1)[0]
                    dnode = sfields(declaration, 0, 3)[0]
                    if session_blocks[dnode]['tag'] != 1:
                        continue
                    assert declaration in roots
                    assert dnode == fields(declaration, 0, 3)[0]
                    ds.append(declaration)
                    raw_data.add(declaration)
                    row = next(d for d in declarations if d['declaration'] == declaration)
                    raw_heads.update(row['type_heads'])
                assert len(ds) == len(set(ds))
                chain_rows.append({'task_option': int(root), 'length': len(chain),
                                   'data_declarations': ds})
            rows.append({'case': case, 'process': process,
                         'capture_members': selected,
                         'all_initial_hsdecl_roots': len(roots),
                         'data_declarations': declarations,
                         'data_type_heads': sorted(heads.values(), key=lambda h: h['type_symbol']),
                         'raw_context_chains': chain_rows,
                         'raw_context_distinct_data_declarations': len(raw_data),
                         'raw_context_distinct_data_heads': len(raw_heads),
                         'T_prepared': len(heads), 'episodes': episodes,
                         'direct_tuple_publications': 3 * episodes * len(heads),
                         'algebraic_type_test_arities': list(range(5))})

    # Reuse the retained lexer helper, not its predecessor computation.
    origin = EVIDENCE / 'retained-why-path-library-origins-20261020/check.py'
    spec = importlib.util.spec_from_file_location('tuple_driver_lexer', origin)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    inputs[str(origin.relative_to(ROOT))] = ident(origin.read_bytes())
    with tarfile.open(EVIDENCE / 'retained-producer-fixed-tail-20261018/observations.tar.gz') as archive:
        resolution_bytes = archive.extractfile('driver-resolution.json').read()
        resolution = json.loads(resolution_bytes)
        texts = {'/tmp/silver-producer-fixed-tail-20261018/' + m.name:
                 archive.extractfile(m).read() for m in archive.getmembers()
                 if m.name.startswith('overlay/') and m.isfile()}
    dimensions = EVIDENCE / 'retained-producer-prefix-gc-20261018/dimensions-inputs.json'
    dim = json.loads(dimensions.read_bytes())
    with tarfile.open(EVIDENCE / 'retained-producer-prefix-gc-20261018/dimensions-sources.tar.gz') as archive:
        texts.update({p: archive.extractfile(v['member']).read()
                      for p, v in dim['installed_text'].items()})
    import re
    driver_rows = []
    for path, row in sorted(resolution.items()):
        data = texts[path]
        assert ident(data) == row['identity']
        code = module.uncomment(data.decode())
        assert not re.search(r'\buse\b', code)
        driver_rows.append({'path': path, **ident(data), 'use_tokens': 0})
    assert len(driver_rows) == 14

    # New targeted closure check: the type-declaration VC arm is the sole
    # vc:true exception to nonempty-library-path program VC suppression.
    # Consume already retained lexical spans instead of rerunning the lexer.
    inventory_path = EVIDENCE / 'retained-why-path-input-inventory-20261020/library-inventory.json'
    inventory_bytes = inventory_path.read_bytes()
    inventory = json.loads(inventory_bytes)
    inputs[str(inventory_path.relative_to(ROOT))] = ident(inventory_bytes)
    library_rows = []
    with tarfile.open(EVIDENCE / 'retained-producer-fixed-context-20261018/sources.tar.gz') as archive:
        for entry in inventory['files']:
            raw = archive.extractfile(entry['member']).read()
            assert ident(raw) == entry['identity']
            code = bytearray(raw)
            for span in entry['comments']:
                a, b = span['first_byte'], span['past_last_byte']
                assert raw[a:a+2] == b'(*' and raw[b-2:b] == b'*)'
                code[a:b] = bytes(10 if c == 10 else 32 for c in raw[a:b])
            for span in entry['string_literals']:
                a, b = span['first_byte'], span['past_last_byte']
                assert raw[a:b].decode() == span['source_literal']
                code[a:b] = bytes(10 if c == 10 else 32 for c in raw[a:b])
            assert not re.search(rb'\b(?:invariant|by)\b', code)
            library_rows.append({'library': entry['library'], 'member': entry['member'],
                                 **ident(raw), 'type_invariant_or_witness_keywords': 0,
                                 'nonempty_library_path': [entry['library']]})
    assert {r['library'] for r in library_rows} == {'int', 'real', 'algebra', 'relations'}

    witnesses = []
    with tarfile.open(EVIDENCE / 'retained-why-session-helper-source-20261019/sources.tar.gz') as archive:
        for source in SOURCES:
            member = 'why3/src/' + source
            raw = archive.extractfile(member).read()
            witnesses.append({'member': member, **ident(raw), 'text': raw.decode()})
    for rel in ['retained-why-path-library-origins-20261020/selected-dispatch.json',
                'retained-why-path-writer-capacity-20261020/result.json',
                'retained-why-status-entry-20261020/result.json']:
        inputs['docs/evidence/' + rel] = ident((EVIDENCE / rel).read_bytes())
    inputs['driver-resolution.json'] = ident(resolution_bytes)
    result = {'scope': 'actual direct algebraic tuple callbacks per preparation episode',
              'native_platform': 'linux-x86_64',
              'rows': [{key: row[key] for key in ('case', 'T_prepared', 'episodes',
                       'direct_tuple_publications', 'raw_context_distinct_data_heads',
                       'all_initial_hsdecl_roots', 'algebraic_type_test_arities')}
                       for row in rows],
              'direct_tuple_publications_sum_across_separate_processes':
                  sum(row['direct_tuple_publications'] for row in rows),
              'driver_thuse_empty': True,
              'premise_scope': 'under the named existing source/native, immutable-value, runtime and continuation premises in the companion note',
              'complete_direct_tuple_preparation_bound_established': True,
              'initial_tuple_registry_complete': False,
              'C_lib': None, 'W': None,
              'complete_writer_capacity_established': False,
              'complete_restore_table_capacity_established': False,
              'complete_save_capacity_established': False,
              'whole_pipeline_capacity_established': False,
              'new_native_runs': 0, 'predecessor_checker_replays': 0}
    return {'inputs.json': inputs, 'data-family.json': rows,
            'driver-exports.json': driver_rows, 'source-witnesses.json': witnesses,
            'library-cache-isolation.json': library_rows,
            'result.json': result}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    outputs = compute()
    for name, obj in outputs.items():
        raw = dump(obj)
        if args.write:
            (HERE / name).write_bytes(raw)
        else:
            assert (HERE / name).read_bytes() == raw, name
    print(json.dumps({'status': 'pass', 'elapsed_seconds': time.monotonic() - start,
                      'cases': len(CASES), 'source_members': len(SOURCES),
                      'new_native_runs': 0, 'predecessor_checker_replays': 0}))

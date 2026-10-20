#!/usr/bin/env python3
"""Extract/check new save-entry dimensions from accepted retained projections.

No target, debugger, observer replay, binder/alpha interpreter or solver runs.
The complete raw-read logs are scanned only for new missing-object coverage.
"""
import argparse
import bisect
import collections
import hashlib
import json
from pathlib import Path
import platform
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent
DOMAIN = E / 'retained-why-fixed-session-domain-20261020'
STATE = E / 'retained-why-session-save-state-20261019'
CASES = ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid')


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(path.read_bytes())


class Archive:
    def __init__(self, path, expected, members):
        assert identity(path.read_bytes()) == expected, path
        self.path, self.identity, self.members = path, expected, members
        self.tar = tarfile.open(path)
        self.consumed = {}

    def get(self, name):
        row = self.tar.getmember(name)
        assert row.isfile() and not row.issym() and not row.islnk(), name
        raw = self.tar.extractfile(row).read()
        assert identity(raw) == self.members[name], name
        self.consumed[name] = self.members[name]
        return raw

    def data(self, name):
        return json.loads(self.get(name))

    def scan_coverage(self, name, pointers, known_words):
        """Count retained bytes at each absent block's header/first word.

        An address is evidence only where a raw read covers it. No memory read
        is requested and no pointer proximity or allocation-order inference is
        used. String headers extend the query to their complete payload range.
        """
        masks = {p: 0 for p in pointers}
        spans = collections.defaultdict(list)
        extended = {p: p+8*n for p, n in known_words.items()}
        pointers = sorted(pointers)
        digest, size, records = hashlib.sha256(), 0, 0
        row = self.tar.getmember(name)
        assert row.isfile() and not row.issym() and not row.islnk()
        with self.tar.extractfile(row) as stream:
            for line in stream:
                digest.update(line)
                size += len(line)
                value = json.loads(line)
                a, n = value['address'], value['bytes']
                assert len(value['hex']) == 2*n
                b = a+n
                lo = bisect.bisect_right(pointers, a-8)
                hi = bisect.bisect_left(pointers, b+8)
                candidates = set(pointers[lo:hi])
                candidates.update(p for p, end in extended.items() if a < end and b > p-8)
                for p in candidates:
                    start, stop = max(a, p-8), min(b, p+8)
                    if stop > start:
                        masks[p] |= ((1 << (stop-start))-1) << (start-(p-8))
                    raw = bytes.fromhex(value['hex'])
                    spans[p].append((a, raw))
                    if a == p-8 and n >= 8:
                        header = int.from_bytes(raw[:8], 'little')
                        if header & 255 == 252 and header >> 10 <= 1 << 20:
                            extended[p] = p+8*(header >> 10)
                records += 1
        actual = dict(bytes=size, sha256=digest.hexdigest())
        assert actual == self.members[name], name
        self.consumed[name] = actual
        return masks, spans, dict(member=name, identity=actual, records_scanned=records)


class Projection:
    def __init__(self, raw):
        self.blocks, self.missing = {}, collections.defaultdict(set)
        for line in raw.splitlines():
            row = json.loads(line)
            p = row['address']
            assert p not in self.blocks
            data = bytes.fromhex(row['payload_hex'])
            assert int.from_bytes(bytes.fromhex(row['header_hex']), 'little') == row['header']
            assert (row['tag'], row['words']) == (row['header'] & 255, row['header'] >> 10)
            assert len(data) == row['words']*8
            self.blocks[p] = (row['tag'], row['words'], data)

    def fields(self, p, words=None, tag=0):
        t, n, raw = self.blocks[p]
        assert t == tag and (words is None or words == n), (p, t, n)
        return struct.unpack('<'+'Q'*n, raw)

    @staticmethod
    def integer(value):
        assert value & 1
        return (value-(1 << 64) if value >= 1 << 63 else value) >> 1

    def absent(self, p, label):
        assert p not in self.blocks and p != 0 and p % 8 == 0
        self.missing[p].add(label)
        return dict(pointer=p, value=None, reason='block absent from retained session projection')

    def seq(self, p, label, required=False):
        values, seen = [], set()
        while p != 1:
            if p not in self.blocks:
                self.absent(p, label)
                assert not required, label
                return None
            assert p not in seen, ('list cycle', p)
            seen.add(p)
            item, p = self.fields(p, 2)
            values.append(item)
        return values

    def string(self, p, label):
        if p not in self.blocks:
            return self.absent(p, label)
        tag, words, raw = self.blocks[p]
        assert tag == 252 and words > 0 and raw[-1] <= 7
        n = len(raw)-1-raw[-1]
        assert n >= 0 and raw[n] == 0
        data = raw[:n]
        return dict(pointer=p, bytes=n, hex=data.hex(), sha256=hashlib.sha256(data).hexdigest())

    def ident(self, p, label):
        if p not in self.blocks:
            return self.absent(p, label)
        name, _, _, tag = self.fields(p, 4)
        return dict(pointer=p, id_tag=self.integer(tag), id_string=self.string(name, label+'.id_string'),
                    restored_path=None)

    def path(self, p, label):
        values = self.seq(p, label)
        if values is None:
            return dict(pointer=p, component_count=None, total_bytes=None, max_component_bytes=None)
        strings = [self.string(v, label+'.component') for v in values]
        complete = all('bytes' in s for s in strings)
        return dict(pointer=p, component_count=len(values), components=strings,
                    total_bytes=sum(s['bytes'] for s in strings) if complete else None,
                    max_component_bytes=max((s['bytes'] for s in strings), default=0) if complete else None)

    def table(self, p, int_keys=True):
        size, buckets, seed, initial = self.fields(p, 4)
        heads = self.fields(buckets)
        rows = []
        for bucket, cell in enumerate(heads):
            seen = set()
            while cell != 1:
                assert cell not in seen, ('table cycle', cell)
                seen.add(cell)
                key, value, following = self.fields(cell, 3)
                rows.append(dict(bucket=bucket, cell=cell, key=key, value=value, next=following))
                cell = following
        assert self.integer(size) == len(rows)
        first = {}
        for row in rows:
            key = self.integer(row['key']) if int_keys else row['key']
            first.setdefault(key, row['value'])
        return dict(address=p, array=buckets, entries=rows), first


def extract_case(name, manifest, summary, common):
    old = name == 'input_is_valid'
    if old:
        index = read(STATE/'capture-identities.json')
        archive = Archive(STATE/'capture.tar.gz', index['identity'], index['members'])
        plan = archive.data('plan.json')
        analysis_path, certificate_path = STATE/'result.json', STATE/'binder-certificate.json'
        cert = read(certificate_path)
    else:
        item, = [x for x in manifest['archives'] if x['path'] == 'capture-'+name.replace('_', '-')+'.tar.gz']
        archive = Archive(DOMAIN/item['path'], dict(bytes=item['bytes'], sha256=item['sha256']),
                          {x['path']: dict(bytes=x['bytes'], sha256=x['sha256']) for x in item['members']})
        plan = common.data('plan.json')
        analysis_path = certificate_path = DOMAIN/(name.replace('_', '-')+'-analysis.json')
        cert = read(analysis_path)['full_certificate']
    accepted, = [x for x in summary['cases'] if x['case'] == name]
    assert identity(analysis_path.read_bytes()) == accepted['analysis_identity']
    prefix = name+'/capture/'
    get = lambda filename: archive.data(prefix+filename)
    process, roots, saved_tables, forest = [get(n) for n in (
        'process.json', 'session-root.json', 'session-tables.json', 'session-forest.json')]
    p = Projection(archive.get(prefix+'session-blocks.jsonl'))
    assert roots['complete'] and process['pid'] == accepted['pid']
    if old:
        metadata = get('session-observer.json')
        symbols, bias = metadata['symbols'], metadata['load_bias']
        assert metadata['pid'] == process['pid']
    else:
        metadata = get('session-symbols.json')
        symbols = {k: v['address'] for k, v in metadata['checks'].items()}
        bias = metadata['load_bias']
    case, = [c for c in plan['inputs'] if c.get('name', name) == name]
    assert process['argv'] == case['argv'] and process['environment'] == case['environment']
    argv = process['argv']
    assert argv.count('--prover') == argv.count('--why3-conf') == 1
    selected = argv[argv.index('--prover')+1].split(',')
    assert all(selected) and len(selected) == len(set(selected))
    config_archive = archive if old else common
    config_raw = config_archive.get('overlay/why3.conf')
    config_path = argv[argv.index('--why3-conf')+1]
    assert identity(config_raw) == plan['file_identities'][config_path]
    input_raw = archive.get(name+'/'+argv[-1])
    input_path = str(Path(case['cwd'])/argv[-1])
    assert identity(input_raw) == plan['file_identities'][input_path]
    handlers = p.fields(roots['root_words']['signal_handlers']['value'])
    assert handlers[2] == roots['sigint_closure']
    closure = p.fields(roots['sigint_closure'], 4, 247)
    assert closure[0] == symbols['camlGnat_main__fun_14206'] and closure[2] == roots['controller']
    controller = p.fields(roots['controller'], 6)
    assert controller[0] == roots['session']
    sf = p.fields(roots['session'], 17)
    tables, lookup = {}, {}
    for field, i in [('files', 8), ('proof_nodes', 2), ('transformations', 4), ('raw_tasks', 11), ('proof_attempts', 0)]:
        tables[field], lookup[field] = p.table(sf[i])
        assert tables[field] == saved_tables[field]
    stats = []
    for row in tables['proof_attempts']['entries']:
        parent, prover, limits, state, obsolete, script = p.fields(row['value'], 6)
        # No absent prover/limits/result record is interpreted as a value.
        if prover not in p.blocks:
            p.absent(prover, 'proof_attempt.prover')
        script_path = None
        if script != 1:
            if script not in p.blocks:
                script_path = p.absent(script, 'proof_attempt.proof_script.option')
            else:
                value, = p.fields(script, 1)
                script_path = p.path(value, 'proof_attempt.proof_script.path')
        stats.append(dict(id=p.integer(row['key']), pointer=row['value'], parent=p.integer(parent),
            prover_pointer=prover, limits_pointer=limits, state_word=state,
            obsolete=p.integer(obsolete), proof_script_word=script, proof_script=script_path))
    files, theories, goals, transformations = {}, {}, {}, {}
    counts, depth, visits, all_events = collections.Counter(), 0, [], []
    work = [('file', r['value'], 1) for r in reversed(tables['files']['entries'])]
    active = set()
    while work:
        kind, value, d = work.pop()
        if kind == 'leave':
            active.remove(value)
            continue
        if kind == 'visit':
            goal, node, root = value
            task = lookup['raw_tasks'].get(goal)
            visit = dict(goal=goal, root=root, proof_node=node, detached=task is None, task=task)
            slots = None if task is None else len(cert['tasks'][str(task)]['propositions'])+1
            visits.append(dict(**visit, depth=d, D_t_chain_slots_upper=slots))
            continue
        token = (kind, value)
        assert token not in active, ('forest cycle', token)
        active.add(token)
        work.append(('leave', token, d))
        counts[kind] += 1
        depth = max(depth, d)
        all_events.append(dict(kind=kind, value=value, depth=d))
        if kind == 'file':
            fid, path, fmt, detached, children = p.fields(value, 5)
            children = p.seq(children, 'file.theories', True)
            files[str(value)] = dict(id=p.integer(fid), path=p.path(path, 'file.path'),
                format=p.string(fmt, 'file.format'), detached=p.integer(detached), theory_pointers=children)
            children = [('theory', c, d+1) for c in children]
        elif kind == 'theory':
            ident, children, parent, detached = p.fields(value, 4)
            children = [p.integer(c) for c in p.seq(children, 'theory.goals', True)]
            counts['nonempty_theory'] += bool(children)
            theories[str(value)] = dict(name=p.ident(ident, 'theory.name'), goals=children,
                parent_file=p.integer(parent), detached=p.integer(detached))
            children = [('goal', c, d+1) for c in children]
        elif kind == 'goal':
            node = lookup['proof_nodes'][value]
            ident, expl, parent, attempts, children = p.fields(node, 5)
            parent_tag = p.blocks[parent][0]
            assert parent_tag in (0, 1)
            p.fields(parent, 1, parent_tag)
            memberships, _ = p.table(attempts, False)
            members = [dict(prover_pointer=r['key'], attempt_id=p.integer(r['value'])) for r in memberships['entries']]
            for m in members:
                assert m['attempt_id'] in lookup['proof_attempts']
            children = [p.integer(c) for c in p.seq(children, 'goal.transformations', True)]
            goals[str(value)] = dict(pointer=node, name=p.ident(ident, 'goal.name'),
                explanation=p.string(expl, 'goal.explanation'), proof_parent_tag=parent_tag,
                attempts_table=attempts, attempt_memberships=members, transformations=children)
            counts['A_xml'] += len(members)
            work.append(('visit', (value, node, parent_tag == 1), d))
            children = [('transformation', c, d+1) for c in children]
        else:
            assert kind == 'transformation'
            node = lookup['transformations'][value]
            name_ptr, args, children, parent, detached = p.fields(node, 5)
            args = p.seq(args, 'transformation.args')
            args = None if args is None else [p.string(a, 'transformation.arg') for a in args]
            children = [p.integer(c) for c in p.seq(children, 'transformation.subtasks', True)]
            transformations[str(value)] = dict(pointer=node, name=p.string(name_ptr, 'transformation.name'),
                args=args, subtasks=children, parent_goal=p.integer(parent), detached=p.integer(detached))
            children = [('goal', c, d+1) for c in children]
        work.extend(reversed(children))
    assert [{k:v[k] for k in ('goal','root','proof_node','detached','task')} for v in visits] == forest['visits']
    assert len(visits) == accepted['forest_visits']
    sh = p.fields(sf[10], 6)
    missing_roots = dict(session_prover_ids=sf[9], global_shapes=sh[2],
        bound_shape_table=sh[3], old_shape_table=sh[4], checksum_table=sh[5])
    known_words = {pointer: 3 if label == 'global_shapes' else 4 for label, pointer in missing_roots.items()}
    for label, pointer in missing_roots.items():
        p.absent(pointer, label)
    logs = ['memory-reads.jsonl'] + (['session-memory-reads.jsonl'] if old else [])
    masks, scans, spans = {x: 0 for x in p.missing}, [], collections.defaultdict(list)
    for log in logs:
        more, chunks, scan = archive.scan_coverage(prefix+log, masks, known_words)
        scans.append(scan)
        for pointer, mask in more.items():
            masks[pointer] |= mask
            spans[pointer].extend(chunks[pointer])
    recovered, partial = [], []
    def retained_bytes(pointer, size, chunks, require_complete=True):
        result, covered = bytearray(size), bytearray(size)
        for address, raw in chunks:
            a, b = max(pointer, address), min(pointer+size, address+len(raw))
            for pos in range(a, b):
                value = raw[pos-address]
                i = pos-pointer
                assert not covered[i] or result[i] == value, ('inconsistent retained bytes', pos)
                result[i], covered[i] = value, 1
        if not all(covered):
            assert not require_complete, ('partial retained block', pointer, size)
            return None, sum(covered)
        return bytes(result), size
    for pointer, labels in list(p.missing.items()):
        mask = masks[pointer]
        if mask & 255:
            assert mask & 255 == 255, ('partial retained header', pointer, labels, mask)
            header_raw, _ = retained_bytes(pointer-8, 8, spans[pointer])
            header = int.from_bytes(header_raw, 'little')
            tag, words = header & 255, header >> 10
            # Only string recovery is needed by these inputs. Any newly
            # covered record/list root requires an explicit decoder extension.
            assert tag == 252 and 0 < words <= 1 << 20, (pointer, labels, tag, words)
            raw, covered = retained_bytes(pointer, words*8, spans[pointer], False)
            if raw is None:
                partial.append(dict(pointer=pointer, fields=sorted(labels), header=header,
                    tag=tag, words=words, header_hex=header_raw.hex(),
                    payload_bytes_covered=covered, payload_bytes_required=words*8))
                continue
            p.blocks[pointer] = (tag, words, raw)
            recovered.append(dict(pointer=pointer, fields=sorted(labels), header=header,
                tag=tag, words=words, header_hex=header_raw.hex(), payload_hex=raw.hex()))
            del p.missing[pointer]
    recovered_pointers = {x['pointer'] for x in recovered}
    def resolve(value):
        if isinstance(value, dict):
            if value.get('pointer') in recovered_pointers and value.get('reason') == 'block absent from retained session projection':
                return p.string(value['pointer'], 'raw-recovered string')
            return {k: resolve(v) for k, v in value.items()}
        if isinstance(value, list):
            return [resolve(v) for v in value]
        return value
    files, theories, goals, transformations = [resolve(v) for v in (files, theories, goals, transformations)]
    missing = []
    for pointer, labels in sorted(p.missing.items()):
        mask = masks[pointer]
        row = dict(pointer=pointer, fields=sorted(labels), header_bytes_covered=(mask & 255).bit_count(),
                   first_payload_word_bytes_covered=(mask >> 8).bit_count())
        if pointer in known_words:
            _, covered = retained_bytes(pointer, 8*known_words[pointer], spans[pointer], False)
            row.update(source_record_words=known_words[pointer], payload_bytes_covered=covered,
                       payload_bytes_required=8*known_words[pointer])
        missing.append(row)
    distinct_provers = len({x['prover_pointer'] for x in stats})
    slots = [v['D_t_chain_slots_upper'] for v in visits if not v['detached']]
    result = dict(case=name, unit=accepted['unit'], pid=process['pid'], phase=accepted['phase'],
        endpoint=accepted['endpoint'], managed_run=(manifest['retained_Input_Is_Valid']['managed_run'] if old else manifest['managed_run']),
        capture=dict(archive=str(archive.path.relative_to(REPO)), identity=archive.identity,
            consumed_members=archive.consumed),
        accepted_occurrences=dict(path=str(certificate_path.relative_to(REPO)), identity=identity(certificate_path.read_bytes())),
        configuration=dict(argv=argv, environment=process['environment'], selected_provers=selected,
            plan_archive=str(config_archive.path.relative_to(REPO)), plan_member='plan.json',
            plan_identity=config_archive.consumed['plan.json'], why3_conf_recorded_path=config_path,
            why3_conf_member='overlay/why3.conf', why3_conf_identity=identity(config_raw),
            why3_conf_utf8=config_raw.decode(), input_member=name+'/'+argv[-1], input_identity=identity(input_raw),
            retained_plugin_identities={path:ident for path,ident in plan['file_identities'].items() if path.endswith('.cmxs')}),
        controller_join=dict(load_bias=bias, signal_handlers=roots['root_words']['signal_handlers'],
            sigint_closure=roots['sigint_closure'], sigint_code=closure[0], controller=roots['controller'],
            controller_words=list(controller), session=roots['session'], session_words=list(sf)),
        session_dir=p.string(sf[7], 'session.session_dir'),
        session_next_ids=dict(proof_attempt=p.integer(sf[1]), proof_node=p.integer(sf[3]),
            transformation=p.integer(sf[5]), file=p.integer(sf[6])),
        table_bindings={k:len(v['entries']) for k,v in tables.items()},
        forest=dict(visit_counts=dict(counts), max_depth=depth, entry_depth_convention='file=1; each theory/goal/transformation child adds 1',
            source_order_entries=all_events, APn_visits=visits, G=len(visits),
            D_t_chain_slots_upper_max=max(slots, default=0), J_chain_slots_upper_sum=sum(slots)),
        attempts=dict(A_stats=len(stats), A_xml=counts['A_xml'], distinct_prover_pointers=distinct_provers,
            P_stats_exact=distinct_provers if distinct_provers <= 1 else None,
            P_stats_upper=distinct_provers, stats_bindings=stats),
        files=files, theories=theories, goals=goals, transformations=transformations,
        shape_entry=dict(pointer=sf[10], raw_words=list(sh), version_constructor=p.integer(sh[0]), has_shapes=p.integer(sh[1]),
            missing_roots=missing_roots, H0=None, prover_id_min=None, prover_id_max=None,
            prover_id_duplicate_bindings=None, hyp_shape_bindings=None, index_sh_bindings=None, n=None,
            dictionary_string_bytes_max=None, dictionary_index_max=None, bound_shape_bindings=None,
            bound_shape_list_length_max=None, bound_shape_index_max=None, old_shape_bindings=None,
            old_shape_string_bytes_max=None, checksum_bindings=None, checksum_string_bytes_max=None),
        unidentified_globals=dict(Shape_buffer_root=None, Shape_buffer_position=None, Shape_buffer_capacity=None,
            Shape_buffer_initial_capacity=None, save_ident_restored_path_table=None,
            save_ident_restored_component_count_max=None, save_ident_restored_bytes_max=None),
        missing_blocks=missing, missing_block_raw_read_scans=scans, raw_recovered_string_blocks=recovered,
        raw_partially_retained_string_blocks=partial)
    archive.tar.close()
    return result


def run():
    start = time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='write first extraction instead of checking retained output')
    parser.add_argument('--case', action='append', choices=CASES, help='extract/check selected cases only')
    parser.add_argument('--output', type=Path, required=True, help='new check/timing result path')
    args = parser.parse_args()
    inputs = read(HERE/'inputs.json')
    for path, expected in inputs['dependencies'].items():
        assert identity((REPO/path).read_bytes()) == expected, path
    for name, expected in inputs['local_inputs'].items():
        assert identity((HERE/name).read_bytes()) == expected, name
    layout = read(HERE/'source-layout.json')
    with tarfile.open(REPO/layout['archive']) as stream:
        for row in layout['excerpts']:
            raw = stream.extractfile(row['member']).read()
            assert identity(raw) == row['member_identity']
            assert '\n'.join(raw.decode().splitlines()[row['first']-1:row['last']])+'\n' == row['text']
    manifest, summary = read(DOMAIN/'capture-manifest.json'), read(DOMAIN/'summary.json')
    item, = [x for x in manifest['archives'] if x['path'] == 'capture-common.tar.gz']
    common = Archive(DOMAIN/item['path'], dict(bytes=item['bytes'], sha256=item['sha256']),
        {x['path']:dict(bytes=x['bytes'], sha256=x['sha256']) for x in item['members']})
    cases, timings = [], {}
    for name in args.case or CASES:
        begin = time.perf_counter()
        case = extract_case(name, manifest, summary, common)
        cases.append(case)
        target = HERE/(name.replace('_', '-')+'.json')
        if args.write:
            target.write_text(json.dumps(case, indent=2)+'\n')
        else:
            assert case == read(target), ('new entry-input projection differs', name)
        timings[name] = time.perf_counter()-begin
        print(json.dumps(dict(case=name, G=case['forest']['G'], A_stats=case['attempts']['A_stats'],
            A_xml=case['attempts']['A_xml'], missing_blocks=len(case['missing_blocks']), seconds=timings[name])), flush=True)
    common.tar.close()
    case_inputs = []
    for name in CASES:
        path = HERE/(name.replace('_', '-')+'.json')
        case = read(path)
        case_inputs.append(dict(case=name, path=path.name, identity=identity(path.read_bytes()), pid=case['pid'],
            phase=case['phase'], G=case['forest']['G'], J_chain_slots_upper_sum=case['forest']['J_chain_slots_upper_sum'],
            D_t_chain_slots_upper_max=case['forest']['D_t_chain_slots_upper_max'], A_stats=case['attempts']['A_stats'],
            A_xml=case['attempts']['A_xml'], max_depth=case['forest']['max_depth'], missing_blocks=len(case['missing_blocks'])))
    data = dict(scope='Exact captured stopped states; not later save-entry invariants or completed save bounds',
        source_contract_scope='Accepted retained source-family/layout contracts; no historical installed-source identity claim',
        cases=case_inputs,
        old_observer_replays=0, binder_recomputations=0, alpha_replays=0, native_runs=0, proof_runs=0,
        missing_values_defaulted_to_zero=False, later_entry_equals_capture_established=False)
    target = HERE/'entry-inputs.json'
    if args.write:
        target.write_text(json.dumps(data, indent=2)+'\n')
    else:
        assert data == read(target), 'new entry-input projection differs'
    result = dict(outcome='extracted' if args.write else 'passed', entry_inputs_identity=identity(target.read_bytes()),
        checked_cases=list(args.case or CASES),
        case_seconds=timings, elapsed_seconds=time.perf_counter()-start, native_platform=platform.platform(),
        selected_model='GPT-6.1 Sol', selected_effort='Extra High', runtime_confirmation=False,
        token_and_monetary_measurements=None, old_observer_replays=0, binder_recomputations=0,
        alpha_replays=0, native_runs=0, proof_runs=0)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result))


if __name__ == '__main__':
    run()

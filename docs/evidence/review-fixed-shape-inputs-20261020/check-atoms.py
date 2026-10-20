#!/usr/bin/env python3
"""Independent finite-domain closure and summary checks; no logical opening.

The author's byte-correspondence checker runs once. Additional checks inspect
each stored term's direct edges, establish exact root reachability, and recompute
summary fields from retained atoms. This is not binder/alpha or native replay.
"""
import collections
import gzip
import hashlib
import json
from pathlib import Path
import platform
import runpy
import struct
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = HERE.parent / 'retained-why-fixed-session-atoms-20261020'
TARGET = '0ec7f4b5082830501f51764bfd4652d157c31104'
BASE = 'b1c0d89f7b652a1c12e957caa986887be890786e'


def check():
    start = time.perf_counter()
    paths = subprocess.check_output(['git', 'diff', '--name-only', BASE, TARGET], cwd=ROOT).decode().splitlines()
    for path in paths:
        assert (ROOT/path).read_bytes() == subprocess.check_output(['git', 'show', f'{TARGET}:{path}'], cwd=ROOT)
    author = runpy.run_path(str(PACKET/'check.py'))['check']()
    loader = runpy.run_path(str(PACKET/'extract.py'))['load_case']
    cases = []
    for packet in json.loads((PACKET/'inputs.json').read_text())['packets']:
        value = json.loads(gzip.decompress((PACKET/packet['path']).read_bytes()))
        cert, blocks, _, _ = loader(value['case'])

        def fields(pointer, count=None, tag=0):
            row = blocks[pointer]
            assert row['tag'] == tag
            raw = bytes.fromhex(row['payload_hex'])
            assert len(raw) == row['words']*8
            assert count is None or row['words'] == count
            return struct.unpack('<'+'Q'*row['words'], raw)

        def seq(pointer):
            seen, out = set(), []
            while pointer != 1:
                assert pointer not in seen
                seen.add(pointer)
                item, pointer = fields(pointer, 2)
                out.append(item)
            return out

        def mapping(pointer):
            todo, seen, out = [pointer], set(), []
            while todo:
                pointer = todo.pop()
                if pointer == 1:
                    continue
                assert pointer not in seen
                seen.add(pointer)
                left, key, item, right, height = fields(pointer, 5)
                assert height & 1
                out.append((key, item))
                todo.extend([left, right])
            return out

        domain = set(value['covered_term_pointers'])
        roots = {p['formula'] for task in cert['tasks'].values() for p in task['propositions']}
        assert roots == set(map(int, cert['formulas'])) == set(value['formula_roots'])
        assert set(map(int, value['term_attributes'])) == domain
        assert not value['pattern_pointers'] and not value['case_patterns']
        assert value['max_case_pattern_occurrences'] == 0
        graph, identifiers, constants, kinds, substitutions = {}, set(), set(), collections.Counter(), {}
        def vs(pointer):
            identifiers.add(fields(pointer, 2)[0])
        def ls(pointer):
            identifiers.add(fields(pointer, 5)[0])
        for pointer in sorted(domain):
            node, _, attrs, _ = fields(pointer, 4)
            attr_items = mapping(attrs)
            assert all(unit == 1 for _, unit in attr_items)
            assert {a for a, _ in attr_items} == set(value['term_attributes'][str(pointer)])
            edges = []
            def info(pointer):
                _, deferred = fields(pointer, 2)
                pairs = mapping(deferred)
                substitutions[pointer] = pairs
                for variable, term in pairs:
                    vs(variable)
                    edges.append(term)
            if node & 1:
                assert node in (1, 3)
                kinds['Ttrue' if node == 1 else 'Tfalse'] += 1
            else:
                tag = blocks[node]['tag']
                name = ('Tvar','Tconst','Tapp','Tif','Tlet','Tcase','Teps','Tquant','Tbinop','Tnot')[tag]
                kinds[name] += 1
                fs = fields(node, (1,1,2,3,2,2,1,2,3,1)[tag], tag)
                if tag == 0:
                    vs(fs[0])
                elif tag == 1:
                    constants.add(fs[0])
                elif tag == 2:
                    ls(fs[0]); edges.extend(seq(fs[1]))
                elif tag == 3:
                    edges.extend(fs)
                elif tag in (4,6):
                    if tag == 4:
                        edges.append(fs[0])
                    variable, bi, body = fields(fs[-1], 3)
                    vs(variable); info(bi); edges.append(body)
                elif tag == 5:
                    raise AssertionError('New Tcase requires extending this finite review')
                elif tag == 7:
                    assert fs[0] in (1,3)
                    variables, bi, triggers, body = fields(fs[1],4)
                    for variable in seq(variables):
                        vs(variable)
                    info(bi)
                    for trigger in seq(triggers):
                        edges.extend(seq(trigger))
                    edges.append(body)
                elif tag == 8:
                    assert fs[0] in (1,3,5,7)
                    edges.extend(fs[1:])
                else:
                    assert tag == 9
                    edges.append(fs[0])
            assert set(edges) <= domain
            graph[pointer] = edges
        reachable, todo = set(), list(roots)
        while todo:
            pointer = todo.pop()
            if pointer not in reachable:
                reachable.add(pointer)
                todo.extend(graph[pointer])
        assert reachable == domain
        for task in cert['tasks'].values():
            identifiers.update(fields(p['symbol'],1)[0] for p in task['propositions'])
        assert identifiers == set(map(int,value['identifiers']))
        assert constants == set(map(int,value['constants']))
        assert dict(kinds) == value['term_constructor_counts']
        attr_union = set()
        for pointer in identifiers:
            _, attrs, _, _ = fields(pointer,4)
            entries = mapping(attrs)
            assert all(unit == 1 for _,unit in entries)
            assert {a for a,_ in entries} == set(value['identifier_attributes'][str(pointer)])
            attr_union.update(a for a,_ in entries)
        attr_union.update(a for attrs in value['term_attributes'].values() for a in attrs)
        assert attr_union == set(map(int,value['attributes']))
        assert max(a['length'] for a in value['identifiers'].values()) == value['original_name_bytes_max']
        assert min(a['length'] for a in value['identifiers'].values()) == value['original_name_bytes_min']
        nums, reps, used, heap = [], collections.Counter(), [], []
        for atom in value['constants'].values():
            assert atom['kind'] == 'int'
            part, = atom['parts']
            n = int(part['value'])
            nums.append(n); reps[part['representation']] += 1
            if part['representation'] == 'heap_Zarith_custom':
                words = fields(part['pointer'],part['words'],255)
                assert part['header'] == blocks[part['pointer']]['header']
                assert part['custom_ops_pointer'] == words[0]
                size = words[1] & (2**63-1)
                sign = -1 if words[1] >> 63 else 1
                assert part['sign'] == sign and part['limbs'] == list(words[2:2+size])
                assert words[size+1] != 0
                assert part['unused_payload_words'] == list(words[2+size:])
                assert n == sign*sum(limb*2**(64*i) for i,limb in enumerate(words[2:2+size]))
                assert len(str(n)) <= 64*size+1
                used.append(size); heap.append(n)
            else:
                used.append(int(n != 0))
        assert value['numeric_summary'] == dict(component_occurrences=len(nums), representations=dict(reps),
            minimum_value=str(min(nums)),maximum_value=str(max(nums)),decimal_bytes_min=min(len(str(n)) for n in nums),
            decimal_bytes_max=max(len(str(n)) for n in nums),bit_length_max=max(abs(n).bit_length() for n in nums),
            used_limbs_max=max(used))
        def attr_summary(collection):
            groups = list(collection)
            sizes = [sum(value['attributes'][str(a)]['bytes'] for a in group) for group in groups]
            return dict(min_count=min(map(len,groups)),max_count=max(map(len,groups)),min_sum_bytes=min(sizes),max_sum_bytes=max(sizes))
        assert value['term_attribute_summary'] == attr_summary(value['term_attributes'].values())
        assert value['goal_identifier_attribute_summary'] == attr_summary(value['identifier_attributes'][str(p)] for p in value['goal_identifier_by_task'].values())
        J = 0
        for visit in cert['visits']:
            if not visit['detached']:
                task = cert['tasks'][str(visit['task'])]
                J += 1+len(task['propositions'])
                assert task['goal_formula'] in roots
        assert J == value['proposition_and_explanation_requests_per_save']
        cases.append(dict(case=value['case'], exact_reachable_terms=len(reachable),
            direct_term_edges=sum(map(len,graph.values())), deferred_records=len(substitutions),
            nonempty_deferred_records=sum(bool(pairs) for pairs in substitutions.values()),
            deferred_value_edges=sum(map(len,substitutions.values())), exact_identifiers=len(identifiers),
            exact_constants=len(constants), heap_integer_values=sorted(heap), J=J))
    return dict(passed=True,target=TARGET,base=BASE,git_exact_paths=paths,
        reviewer_checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        author_checker=author,cases=cases,elapsed_seconds=time.perf_counter()-start,
        platform=platform.platform(),logical_opening_runs=0,binder_replays=0,alpha_replays=0,native_runs=0,
        solver_runs=0,source_fetches=0)


if __name__ == '__main__':
    print(json.dumps(check(),indent=2,sort_keys=True))

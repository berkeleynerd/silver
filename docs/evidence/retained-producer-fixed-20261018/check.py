#!/usr/bin/env python3
"""Reconcile retained raw graphs and counters; does not execute a toolchain."""
import hashlib
import json
from pathlib import Path
import tarfile


def check_graph(row):
    nodes = {int(k): v for k, v in row['graph']['nodes'].items()}
    lists = {int(k): v for k, v in row['graph']['lists'].items()}
    assert sorted(nodes) == list(range(row['nodes'] + 1))
    assert sorted(lists) == list(range(2**30, 2**30 + row['lists']))
    assert sum(map(len, lists.values())) == row['retained_elements']
    kinds = {v: int(k) for k, v in row['layout']['kinds'].items()}
    fields = row['layout']['child_fields']
    edges = {}
    for i, node in nodes.items():
        children = []
        for name, offset, size, tag, optional in fields.get(str(kinds[node['kind']]), []):
            field = node['fields'][name]
            assert field['kind'] == tag
            value = field['value']
            if tag == 'list':
                children.extend(lists[value])
            elif value or not optional:
                assert value in nodes
                children.append(value)
        edges[i] = children
    cache, active = {}, set()

    def occurrences(i):
        if i in cache:
            return cache[i]
        assert i not in active
        active.add(i)
        total = 1 + sum(occurrences(child) for child in edges[i])
        active.remove(i)
        cache[i] = total
        return total

    roots = sorted(i for i, n in nodes.items() if n['kind'].endswith('w_theory_declaration'))
    assert roots == row['theory_roots']
    actual = {str(i): occurrences(i) for i in roots}
    assert actual == row['theory_occurrences']
    assert sum(actual.values()) == row['all_theory_occurrences']
    return {k: row[k] for k in ('phase', 'nodes', 'lists', 'retained_elements',
                               'temporary_names', 'all_theory_occurrences')}


def main():
    root = Path(__file__).resolve().parent
    result = json.loads((root / 'result.json').read_text())
    assert result['debugger_exit'] == 0
    graphs = {}
    with tarfile.open(root / 'graphs.tar.gz') as archive:
        for member in archive.getmembers():
            row = json.load(archive.extractfile(member))
            graphs[row['phase']] = check_graph(row)
    for row in result['snapshots']:
        assert graphs[row['phase']] == {k: row[k] for k in graphs[row['phase']]}
    before, after = graphs['before_standard'], graphs['after_standard']
    increment = {k: after[k] - before[k] for k in after if k != 'phase'}
    assert increment == dict(nodes=5036, lists=1293, retained_elements=1714,
                             temporary_names=168, all_theory_occurrences=9562)
    manifest = json.loads((root / 'MANIFEST.json').read_text())
    for row in manifest['files']:
        data = (root / row['path']).read_bytes()
        assert len(data) == row['bytes'], row['path']
        assert hashlib.sha256(data).hexdigest() == row['sha256'], row['path']
    print('Verified retained graph structure, counters, Standard delta and file hashes')


if __name__ == '__main__':
    main()

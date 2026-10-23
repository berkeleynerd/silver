"""New finite syntax/origin census. No transforms or predecessor checker replay."""
from collections import Counter
from functools import cache
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile
import time

ROOT = Path(sys.argv[1])
FREEZE = sys.argv[2]
HERE = Path(__file__).resolve().parent
EV = Path('docs/evidence')
inputs = {}


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def frozen(path):
    data = (ROOT / path).read_bytes()
    old = subprocess.check_output(['git', 'show', f'{FREEZE}:{path}'], cwd=ROOT)
    assert data == old, str(path)
    inputs[str(path)] = identity(data)
    return data


def read(path):
    return json.loads(frozen(path))


def uncomment(text):
    """Preserve quoted strings and line positions; (*) is a logic operator."""
    out = list(text)
    i = 0
    depth = 0
    while i < len(text):
        if text[i] == '"':
            end = i + 1
            while end < len(text):
                if text[end] == '\\':
                    end += 2
                elif text[end] == '"':
                    end += 1
                    break
                else:
                    end += 1
            if depth:
                for j in range(i, end):
                    if out[j] != '\n': out[j] = ' '
            i = end
        elif text.startswith('(*', i) and (depth or not text.startswith('(*)', i)):
            out[i:i+2] = '  '
            depth += 1
            i += 2
        elif depth and text.startswith('*)', i):
            out[i:i+2] = '  '
            depth -= 1
            i += 2
        else:
            if depth and out[i] != '\n': out[i] = ' '
            i += 1
    assert depth == 0
    return ''.join(out)


def multiplicities(text):
    return dict(sorted(Counter(re.findall(r'%(\d+)', text)).items()))


def main():
    start = time.perf_counter()
    driver_dir = EV / 'retained-solver-request-bytes-20261020'
    manifest = read(driver_dir / 'driver-inputs.json')
    connection = read(EV / 'retained-why-returned-storage-20261020/driver-connection.json')
    reachable = read(EV / 'retained-cvc5-task-acceptance-20261020/result.json')['reachable_modules']
    directives = []
    for name, row in sorted(manifest.items()):
        data = frozen(driver_dir / 'drivers' / name)
        assert identity(data) == row['identity']
        active = uncomment(data.decode())
        owners = list(re.finditer(r'^\s*theory\s+(\S+)', active, re.M))
        for match in re.finditer(r'\bsyntax\s+(function|predicate|type)\s+([^\n"]+?)\s*"((?:\\.|[^"\\])*)"', active, re.S):
            theory = next(m.group(1) for m in reversed(owners) if m.start() < match.start())
            template = match.group(3).replace('\\\n', '')
            mult = multiplicities(template)
            directives.append({'file': name, 'line': active.count('\n', 0, match.start())+1,
                               'theory': theory, 'kind': match.group(1),
                               'symbol': match.group(2).strip(), 'template': template,
                               'argument_multiplicities': mult})
    assert len(manifest) == 14
    assert all(max(d['argument_multiplicities'].values(), default=0) <= 1
               for d in directives if d['kind'] == 'type')
    assert not any(re.search(r'%[tv]\d+', d['template']) for d in directives)
    nonaffine = [d for d in directives if max(d['argument_multiplicities'].values(), default=0) > 1]
    attachable = [d for d in nonaffine if d['theory'] in reachable]
    assert {(d['theory'], d['symbol']) for d in attachable} == {
        ('bv.BV64', 'rotate_left_bv'), ('bv.BV64', 'rotate_right_bv')}
    allowed_templates = {d['template'] for d in attachable}
    per_case = []
    for case in ['put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid']:
        graph = json.loads(gzip.decompress(frozen(EV / f'retained-why-preinline-prefix-20261020/{case}-graph.json.gz')))
        metadata = read(EV / f'retained-why-parallel-symbol-exclusion-20261020/{case}-metadata.json')
        assert not any(e['origin'] == 'raw' and e['meta'] in
                       ('syntax_logic', 'syntax_type', 'encoding:lsinst') for e in metadata['update_events'])
        assert 'encoding:lsinst' not in metadata['updated_counts']
        event_rows = []
        heads = {}
        for event in metadata['update_events']:
            if event['meta'] not in ('syntax_logic', 'syntax_type'): continue
            text = next(v for k,v in event['arguments'] if k == 4)
            if max(multiplicities(text).values(), default=0) <= 1: continue
            assert text in allowed_templates
            pointer = next(v for k,v in event['arguments'] if k == 2)
            symbol = next(s for s in metadata['selected_symbols']['syntax_logic'] if s['pointer'] == pointer)
            old = symbol['old_pointer']
            assert graph['symbols'][str(old)]['name'] == symbol['name']
            heads[old] = symbol['name']
            event_rows.append({'event': event, 'symbol_connection': symbol})
        assert len(heads) == (2 if case in ('put-line', 'put') else 0)
        def children(index):
            node = graph['terms'][index]
            kind, args = node['kind'], node['args']
            bindings = []
            if kind == 'app': nodes = args[1]
            elif kind == 'bin': nodes = args[1:]
            elif kind in ('if', 'not'): nodes = args
            elif kind == 'let': nodes = [args[0]]; bindings = [args[1]]
            elif kind == 'quant': nodes = []; bindings = [args[1]]
            elif kind == 'eps': nodes = []; bindings = [args[0]]
            elif kind == 'case': nodes = [args[0]]; bindings = [b for _,b in args[1]]
            else: nodes = []
            nodes = list(nodes)
            for b in bindings:
                row = graph['bindings'][b]
                nodes += [row['body']] + list(row['saved'].values()) + [n for tr in row['triggers'] for n in tr]
            return nodes
        @cache
        def contained(index):
            node = graph['terms'][index]
            own = {index} if node['kind'] == 'app' and node['args'][0] in heads else set()
            return frozenset(own.union(*(contained(n) for n in children(index))))
        occurrences = [i for i,n in enumerate(graph['terms']) if n['kind'] == 'app' and n['args'][0] in heads]
        assert len(occurrences) == len(heads)
        origins = []
        for decl in graph['declarations']:
            roots = set(decl['raw_root_indexes'] + decl['seed_root_indexes'] + decl['candidate_root_indexes'])
            relevant = {r: contained(r) for r in roots if contained(r)}
            if not relevant: continue
            assert decl['kind'] == 5 and len(relevant) == 1
            root, hits = next(iter(relevant.items()))
            assert len(hits) == 1
            hit, = hits
            quant = graph['terms'][root]
            assert quant['kind'] == 'quant'
            binding = graph['bindings'][quant['args'][1]]
            assert len(binding['variables']) == 2
            assert binding['saved'] == {} and binding['triggers'] == [] and binding['free_variables'] == {}
            equality = graph['terms'][binding['body']]
            assert equality['kind'] == 'app' and equality['args'][1][0] == hit
            assert graph['symbols'][str(equality['args'][0])]['name'] == 'infix ='
            application = graph['terms'][hit]
            arguments = [graph['terms'][n] for n in application['args'][1]]
            assert all(a['kind'] == 'var' for a in arguments)
            assert [a['args'][0] for a in arguments] == binding['variables']
            head = application['args'][0]
            param = [d for d in graph['declarations'] if d['symbol'] == head]
            assert len(param) == 1 and param[0]['kind'] == 2
            origins.append({'declaration': decl['declaration'], 'proposition': decl['symbol'],
                            'raw_seed_candidate_roots': sorted(roots), 'root': root,
                            'binding_index': quant['args'][1], 'binding': binding,
                            'application_index': hit, 'head': head, 'name': heads[head],
                            'arguments': arguments, 'parameter_declaration': param[0]['declaration'],
                            'let_ancestors': 0, 'argument_bound_slots': 0})
        assert len(origins) == len(heads)
        per_case.append({'case': case, 'complete_stored_term_records': len(graph['terms']),
                         'nonaffine_events': event_rows, 'nonaffine_term_occurrences': occurrences,
                         'origins': origins})
    # Exact source identities/excerpts; no OCaml code is executed.
    source_manifest = read(EV / 'retained-why-printer-entry-20261020/source-witnesses.json')
    archive = source_manifest['archive']
    archive_bytes = frozen(Path(archive))
    assert identity(archive_bytes) == source_manifest['archive_identity']
    sections = {'printer/smtv2.ml': [(228,235),(359,551),(585,650),(676,734),(736,834),(1003,1082)],
                'core/printer.ml': [(196,208),(285,343),(518,541)],
                'core/term.ml': [(799,831),(1284,1299)],
                'core/decl.ml': [(60,67)],
                'transform/discriminate.ml': [(489,504)]}
    witnesses = {'archive': archive, 'archive_identity': identity(archive_bytes), 'sources': {}}
    with tarfile.open(ROOT / archive) as tar:
        for name, spans in sections.items():
            member = 'why3/src/' + name
            data = tar.extractfile(member).read()
            lines = data.decode().splitlines(keepends=True)
            witnesses['sources'][name] = {'member': member, **identity(data), 'sections': [
                {'first': first, 'last': last, 'text': ''.join(lines[first-1:last])} for first,last in spans]}
    for name in ['retained-why-printer-entry.md','retained-why-returned-storage.md',
                 'retained-cvc5-task-acceptance.md','retained-why-debug-formatter-control.md',
                 'retained-why-model-meta-control.md']:
        frozen(Path('docs/research') / name)
    result = {'status': 'pass', 'reviewed_integration_freeze': FREEZE,
              'script_identity': identity(Path(__file__).read_bytes()), 'exact_inputs': inputs,
              'driver_closures': connection['driver_closures'], 'driver_syntax_directives': len(directives),
              'type_templates_affine': True, 'active_typed_type_placeholders': [],
              'nonaffine_driver_directives': nonaffine, 'attachable_nonaffine_directives': attachable,
              'cases': per_case, 'elapsed_seconds': time.perf_counter()-start,
              'native_runs': 0, 'predecessor_checker_replays': 0, 'transforms_executed': False,
              'limit': 'Finite census and source identities; source preservation/recursion argument is in the review report. Not whole-printer acceptance.'}
    (HERE / 'source-witnesses.json').write_text(json.dumps(witnesses,indent=2)+'\n')
    (HERE / 'census-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({'status': result['status'], 'elapsed_seconds': result['elapsed_seconds'],
                      'inputs': len(inputs), 'syntax_directives': len(directives),
                      'nonaffine_directives': len(nonaffine), 'attachable': len(attachable),
                      'occurrences_by_case': {r['case']: r['nonaffine_term_occurrences'] for r in per_case}},indent=2))


if __name__ == '__main__':
    main()

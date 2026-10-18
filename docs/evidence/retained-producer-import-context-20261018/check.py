#!/usr/bin/env python3
"""Offline configured-driver/file import closure; no Why3/compiler execution."""
import collections
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[2]
DRIVERS = 'installed/libexec/spark/share/why3/drivers/'
LOADPATH = ['installed/libexec/spark/share/why3/theories/',
            'installed/libexec/spark/share/why3/modules/',
            'installed/share/spark/theories/']
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_']*\Z")
TOKEN = re.compile(r'"(?:\\.|[^"\\])*"|\[@[^\]\n]*\]|[A-Za-z_][A-Za-z0-9_\']*|\S', re.S)


def mask_comments(source):
    """Preserve offsets/newlines, quoted strings and the lexer (*) special case."""
    result = list(source)
    i = depth = 0
    quoted = False
    while i < len(source):
        if depth:
            n = 1
            if source[i:i+3] == '(*)':
                n = 3
            elif source[i:i+2] == '(*':
                depth += 1
                n = 2
            elif source[i:i+2] == '*)':
                depth -= 1
                n = 2
            for j in range(i, i+n):
                if source[j] != '\n':
                    result[j] = ' '
            i += n
        elif quoted:
            if source[i] == '\\':
                i += 2
                continue
            if source[i] == '"':
                quoted = False
            i += 1
        elif source[i:i+3] == '(*)':
            i += 3
        elif source[i:i+2] == '(*':
            depth = 1
            result[i:i+2] = [' ', ' ']
            i += 2
        else:
            quoted = source[i] == '"'
            i += 1
    assert depth == 0 and not quoted
    clean = ''.join(result)
    assert len(clean) == len(source)
    return clean


def tokens(source):
    return [(m[0], m.start()) for m in TOKEN.finditer(mask_comments(source))]


def qualid(ts, i):
    result = []
    while True:
        token = ts[i][0]
        assert IDENT.fullmatch(token) or token.startswith('"'), token
        result.append(json.loads(token) if token.startswith('"') else token)
        i += 1
        if i == len(ts) or ts[i][0] != '.':
            return result, i
        i += 1


def use_clone(source):
    ts = tokens(source)
    result = []
    for i, (token, pos) in enumerate(ts):
        if token not in ('use', 'clone'):
            continue
        j = i+1
        mode = None
        if ts[j][0] in ('import', 'export'):
            mode = ts[j][0]
            j += 1
        while True:
            path, j = qualid(ts, j)
            alias = None
            if ts[j][0] == 'as':
                alias = ts[j+1][0]
                j += 2
            result.append({'kind': token, 'path': path, 'mode': mode, 'alias': alias,
                           'position': pos, 'line': source[:pos].count('\n')+1})
            if token != 'use' or ts[j][0] != ',':
                break
            j += 1
    return result


def native_nodes(value):
    if isinstance(value, list):
        if value and isinstance(value[0], str) and value[0].startswith('W_'):
            yield value
        for child in value:
            yield from native_nodes(child)


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    archive = HERE / 'sources.tar.gz'
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity['source_archive_sha256']
    with tarfile.open(archive) as tar:
        data = {m.name: tar.extractfile(m).read() for m in tar if m.isfile()}
    assert len(data) == len(identity['files'])
    for row in identity['files']:
        assert len(data[row['path']]) == row['bytes']
        assert hashlib.sha256(data[row['path']]).hexdigest() == row['sha256']
    sources = {name: value.decode() for name, value in data.items()}

    def has(path, fragment):
        assert ' '.join(fragment.split()) in ' '.join(sources[path].split()), path

    has('spark/src/gnatprove/gnatprove.adb', 'for Index in 1 .. Length (Provers) loop Write_Prover_Config (Get (Provers, Index));')
    has('why3/src/session/controller_itp.ml', 'let provers = Whyconf.get_provers config in')
    has('why3/src/driver/driver.ml', 'let th = Loc.try3 ~loc Env.read_theory env f id in')
    has('why3/src/core/env.ml', 'push = (fun env path c -> store parent env path (convert c));')
    has('why3/src/core/env.ml', 'try Hpath.find (Wenv.find lang.memo env) path with Not_found -> read_library lang env path;')
    has('why3/src/parser/parser.mly', 'mlw_module mlw_module_no_decl* EOF { Typing.close_file () }')
    has('why3/src/parser/lexer.mll', 'Env.register_format mlw_language whyml_format ["mlw";"why"]')
    has('why3/src/parser/typing.ml', 'let vc = muc.muc_theory.uc_path = [] &&')
    has('why3/src/parser/typing.ml', 'let add muc d = add_pdecl ~vc:true muc d in')
    has('why3/src/mlw/pmodule.ml', '| Uuse m -> use_export uc m')
    has('why3/src/core/theory.ml', '| Use th -> Use th')

    config = json.loads(sources['installed/share/spark/config/gnatprove.conf'])
    driver_roots = sorted(p['driver'] + '.drv' for p in config['provers'])
    pending = driver_roots.copy()
    drivers = {}
    root_modules = []
    while pending:
        name = pending.pop()
        if name in drivers:
            continue
        ts = tokens(sources[DRIVERS + name])
        imports, modules = [], []
        for i, (token, _) in enumerate(ts):
            if token == 'import':
                imported = json.loads(ts[i+1][0])
                imports.append(imported)
                pending.append(imported)
            elif token in ('theory', 'use'):
                q, _ = qualid(ts, i+1)
                modules.append(q)
                root_modules.append(q)
        drivers[name] = {'bytes': len(data[DRIVERS + name]), 'imports': imports,
                         'read_theories': ['.'.join(q) for q in modules]}

    fixed_path = PROJECT / identity['fixed_archive']['path']
    assert hashlib.sha256(fixed_path.read_bytes()).hexdigest() == identity['fixed_archive']['sha256']
    fixed = []
    with tarfile.open(fixed_path) as tar:
        for name in identity['fixed_members']:
            tree = json.loads(tar.extractfile(name).read())['theory_declarations']
            nodes = list(native_nodes(tree))
            imports = sorted({n[3] for n in nodes if n[0] == 'W_MODULE' and n[3]})
            assert imports == ['_gnatprove_standard', 'ada__model', 'int']
            root_modules.extend([[name, '*'] for name in imports])
            clones = [n for n in nodes if n[0] == 'W_CLONE_DECLARATION']
            targets = ['.'.join(n[3][3:5]) for n in clones]
            fixed.append({'input': name, 'direct_clones': len(clones), 'clone_targets': targets})
    assert [r['direct_clones'] for r in fixed] == [8, 7, 10, 13, 13]

    def locate(path):
        name = '/'.join(path)
        matches = [prefix + name + ext for prefix in LOADPATH for ext in ('.mlw', '.why')
                   if prefix + name + ext in sources]
        assert len(matches) == 1, (path, matches)
        return matches[0]

    pending = [tuple(q[:-1]) for q in root_modules if len(q) > 1 and q[0] != 'why3']
    builtins = {'.'.join(q) for q in root_modules if len(q) == 1 or q[0] == 'why3'}
    files, modules = {}, {}
    while pending:
        path = pending.pop()
        if path in files:
            continue
        filename = locate(path)
        source = sources[filename]
        clean, ts = mask_comments(source), tokens(source)
        statements = use_clone(source)
        assert all(s['mode'] != 'import' for s in statements)
        starts = [(m.start(), m[2]) for m in re.finditer(r"^(module|theory)\s+([A-Za-z_][A-Za-z0-9_']*)", clean, re.M)]
        # These exact files put each module and its closing end at column zero.
        # Nested scopes/matches have indented ends. Assert this frontier.
        assert len(starts) == sum(t in ('module', 'theory') for t, _ in ts)
        assert len(starts) == len(re.findall(r'^end\b', clean, re.M))
        imports = set()
        for index, (start, name) in enumerate(starts):
            end = starts[index+1][0] if index+1 < len(starts) else len(source)
            local = []
            for statement in statements:
                if not start <= statement['position'] < end:
                    continue
                q = statement['path']
                if len(q) > 1:
                    target = tuple(q)
                    if q[0] == 'why3':
                        builtins.add('.'.join(q))
                    else:
                        imports.add(tuple(q[:-1]))
                        pending.append(tuple(q[:-1]))
                elif q[0] in [n for _, n in starts[:index]]:
                    target = path + tuple(q)
                else:
                    target = tuple(q)
                    builtins.add('.'.join(q))
                local.append({k: v for k, v in statement.items() if k not in ('path', 'position')} | {'target': '.'.join(target)})
            key = '.'.join(path + (name,))
            modules[key] = {'source_bytes': len(source[start:end].encode()),
                            'lexical_pieces': sum(start <= pos < end for _, pos in ts),
                            'invariant_tokens': sum(t == 'invariant' and start <= pos < end for t, pos in ts),
                            'witness_by_tokens': sum(t == 'by' and start <= pos < end for t, pos in ts),
                            'statements': local}
        counts = collections.Counter(t for t, _ in ts if t in ('use', 'clone', 'exists', 'match', 'invariant', 'by'))
        files[path] = {'path': filename, 'bytes': len(data[filename]), 'modules': len(starts),
                       'uses_and_clones': len(statements), 'imports': ['.'.join(p) for p in sorted(imports)],
                       'syntax_counts': dict(counts),
                       'max_line_bytes': max(map(len, data[filename].splitlines())),
                       'lines': len(data[filename].splitlines())}
    # A closed archive may not hide another discovered import behind a missing
    # retained file: every installed .mlw/.why in it is reached exactly once.
    assert {r['path'] for r in files.values()} == {p for p in sources if p.startswith('installed/') and p.endswith(('.mlw', '.why'))}
    assert len(config['provers']) == 9 and len(drivers) == 26
    assert (len(files), len(modules), sum(r['uses_and_clones'] for r in files.values())) == (21, 352, 728)
    invariants = {k: v['invariant_tokens'] for k, v in modules.items() if v['invariant_tokens']}
    witnesses = {k: v['witness_by_tokens'] for k, v in modules.items() if v['witness_by_tokens']}
    assert invariants == {'map.MapPermutation': 2, 'set.SetAppInt': 1, 'set.SetAppString': 1, 'string.Char': 1}, invariants
    assert witnesses == {'set.SetAppInt': 1, 'set.SetAppString': 1}, witnesses
    refinements = []
    for path, row in files.items():
        source = sources[row['path']]
        ts = tokens(source)
        for i, (token, pos) in enumerate(ts):
            if token == 'val' and i and ts[i-1][0] in (',', 'with'):
                assert path == ('set',) and [x[0] for x in ts[i+1:i+3]] == ['eq', '=']
                refinements.append({'file': 'set', 'line': source[:pos].count('\n')+1})
    assert [r['line'] for r in refinements] == [607, 663, 781]

    # Source dependency multiplicities only. A clone's existing use references
    # remain references; no exponential "inline every use" assumption is made.
    cache, active = {}, set()
    def copies(key):
        if key in cache:
            return cache[key]
        assert key not in active, ('clone cycle', key)
        active.add(key)
        result = collections.Counter({key: 1})
        for st in modules[key]['statements']:
            if st['kind'] == 'clone':
                assert st['target'] in modules
                result.update(copies(st['target']))
        active.remove(key)
        cache[key] = result
        return result
    total = collections.Counter()
    for key in modules:
        total.update(copies(key))
    # None of the modules that introduce the three type invariants is cloned.
    assert all(total[k] == 1 for k in ('set.SetAppInt', 'set.SetAppString', 'string.Char'))
    direct_clones = sum(r['syntax_counts'].get('clone', 0) for r in files.values())
    assert direct_clones == 205
    clone_targets = [s['target'] for m in modules.values() for s in m['statements'] if s['kind'] == 'clone']
    clone_targets += [t for row in fixed for t in row['clone_targets']]
    longest_target = max(map(len, clone_targets))
    assert longest_target <= 70
    # 4 signed63 coordinate strings and wrapper punctuation, fixed warning
    # text, and full source module name fit the per-warning non-path allowance.
    clone_text = 'cloned theory . does not contain any abstract symbol; it should be used instead'
    assert 4*20 + len(':(:)-(:): ') + len(clone_text) + longest_target < 256
    for row in fixed:
        row['clone_warning_bound'] = direct_clones + row['direct_clones']
    total_warnings = sum(r['clone_warning_bound'] for r in fixed)
    assert total_warnings == 1076
    assert 1076*(3+6*256) == 1655964 and 1076*6 == 6456
    assert 38739343 + 1655964 == 40395307
    assert 35444698 + 1655964 == 37100662
    result = {'native_or_proof_executions': 0, 'configured_driver_roots': driver_roots,
              'drivers': drivers, 'files': {'.'.join(k): v for k, v in sorted(files.items())},
              'modules': modules, 'explicit_builtin_targets': sorted(builtins),
              'additional_library_vc_frontier': {'type_invariant_modules': ['set.SetAppInt', 'set.SetAppString', 'string.Char'],
                                                  'program_value_refinements': refinements,
                                                  'map_loop_invariants_have_imported_program_vc_disabled': 2},
              'source_clone_dependency_coefficients': dict(sorted(total.items())),
              'summary': {'driver_files': len(drivers), 'driver_bytes': sum(r['bytes'] for r in drivers.values()),
                          'library_files': len(files), 'library_bytes': sum(r['bytes'] for r in files.values()),
                          'source_modules': len(modules), 'source_use_clone_directives': 728,
                          'source_clone_directives': direct_clones,
                          'max_source_clone_coefficient': max(total.values()),
                          'clone_weighted_lexical_pieces': sum(total[k]*modules[k]['lexical_pieces'] for k in modules),
                          'clone_weighted_source_bytes': sum(total[k]*modules[k]['source_bytes'] for k in modules),
                          'maximum_clone_target_name_bytes': longest_target,
                          'sum_fixed_clone_warning_bound': total_warnings},
              'fixed_inputs': fixed,
              'scope': 'Configured-driver and native explicit import file closure, source clone dependency coefficients and clone-warning count; not typed-term/allocation bounds or all runtime transformation dependencies'}
    (HERE / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result['summary']))


if __name__ == '__main__':
    main()

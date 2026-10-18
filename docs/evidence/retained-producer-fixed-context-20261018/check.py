#!/usr/bin/env python3
"""Replay fixed JSON declaration conversion and the imported Why3 file closure.

No compiler, prover, native executable or network access is used. This is not a
Why3 type checker and does not report typed allocation counts.
"""
import argparse
import collections
import hashlib
import json
import re
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent


def digest(data):
    return hashlib.sha256(data).hexdigest()


def nodes(value):
    if isinstance(value, dict):
        for child in value.values():
            yield from nodes(child)
    elif isinstance(value, list):
        if value and isinstance(value[0], str) and value[0].startswith('W_'):
            yield value
        for child in value:
            yield from nodes(child)


def native_projection(value):
    """Exact D* multiplicities of mk_declaration, before Why3 typing."""
    decls = collections.Counter()
    roles = collections.Counter()
    imports = collections.Counter()
    clone_origins = collections.Counter()
    functions = []
    native = collections.Counter(n[0] for n in nodes(value))
    modules = value['theory_declarations']

    def declare(n, scope):
        k = n[0]
        if k == 'W_FUNCTION_DECL':
            assert len(n) == 12
            domain, binders, definition = n[2], n[4] or [], n[9]
            name = n[3][3][3]
            functions.append({'scope': scope, 'name': name, 'domain': domain,
                              'parameters': len(binders), 'defined': definition is not None,
                              'definition_nodes': sum(1 for _ in nodes(definition)),
                              'pre_nodes': sum(1 for _ in nodes(n[6])),
                              'post_nodes': sum(1 for _ in nodes(n[7]))})
            if domain == 1:  # Term
                decls['Dlogic'] += 1
                roles['logic_defined' if definition else 'logic_abstract'] += 1
            elif domain == 2:  # Pterm
                decls['Dlet'] += 1
                roles['Ptree_Eany'] += 1
                if binders and definition:
                    decls['Dlogic'] += 1
                    roles['logic_defined'] += 1
                    roles['generated_application_post'] += 1
                elif definition:
                    roles['generated_constant_post'] += 1
            elif domain == 3:  # Pred
                decls['Dlet'] += 1
                roles['Ptree_Eany'] += 1
                if definition:
                    decls['Dlogic'] += 1
                    roles['logic_defined'] += 1
                    roles['generated_predicate_post'] += 1
            else:
                assert domain == 4
                decls['Dlet'] += 1
                roles['Ptree_Efun' if definition else 'Ptree_Eany'] += 1
                if definition:
                    roles['program_body_nodes'] += sum(1 for _ in nodes(definition))
        elif k == 'W_TYPE_DECL':
            decls['Dtype'] += 1
            definition = n[6]
            roles['type_' + (definition[0][2:] if definition else 'abstract')] += 1
        elif k == 'W_GLOBAL_REF_DECLARATION':
            decls['Dlet'] += 1
            roles['Ptree_Eany'] += 1
        elif k == 'W_AXIOM':
            decls['Dprop_axiom'] += 1
            roles['axiom_callable_candidates'] += 1
            roles['axiom_native_nodes'] += sum(1 for _ in nodes(n[4]))
            if n[5] is not None:
                decls['Dmeta'] += 1
        elif k == 'W_GOAL':
            decls['Dprop_goal'] += 1
        elif k == 'W_META_DECLARATION':
            decls['Dmeta'] += 1
        elif k == 'W_EXCEPTION_DECLARATION':
            decls['Dexn'] += 1
        elif k == 'W_CLONE_DECLARATION':
            decls['Dcloneexport' if n[5] == 1 else 'Dcloneimport'] += 1
            origin = '.'.join(x for x in n[3][3:] if x)
            clone_origins[origin] += 1
            roles['clone_substitutions'] += len(n[6] or [])
            for sub in n[6] or []:
                assert sub[0] == 'W_CLONE_SUBSTITUTION' and sub[3] in (0, 1, 2)
                roles['clone_' + ('type_symbol', 'logic_function', 'logic_predicate')[sub[3]]] += 1
        elif k == 'W_NAMESPACE_DECLARATION':
            decls['Dscope'] += 1
            assert isinstance(n[4], str) and isinstance(n[3], list)
            for child in n[3]:
                declare(child, scope + '.' + n[4])
        else:
            raise AssertionError(('unhandled declaration', k))

    for theory in modules:
        assert theory[0] == 'W_THEORY_DECLARATION'
        seen = set()
        for inc in theory[6] or []:
            assert inc[0] == 'W_INCLUDE_DECLARATION'
            qid = tuple(x for x in inc[3][3:] if x)
            # Clone_default adds the imported module name as alias. Import and
            # Export are separate variants even for identical qualified names.
            key = (inc[5], qid)
            if key in seen:
                continue
            seen.add(key)
            assert inc[5] in (0, 1, 2)
            decls['Duseexport' if inc[5] == 1 else 'Duseimport'] += 1
            imports['.'.join(qid)] += 1
        for decl in theory[3] or []:
            declare(decl, theory[4])
    external = sorted({n[3] for n in nodes(value) if n[0] == 'W_MODULE' and n[3]})
    return {'native_node_occurrences': sum(native.values()),
            'native_kinds': dict(sorted(native.items())), 'modules': len(modules),
            'ptree_declarations': dict(sorted(decls.items())),
            'ptree_declaration_total': sum(decls.values()),
            'roles': dict(sorted(roles.items())),
            'function_declarations': functions,
            'includes_after_deduplication': dict(sorted(imports.items())),
            'clone_origins': dict(sorted(clone_origins.items())),
            'external_file_roots': external}


TOKEN = re.compile(r'"(?:[^"\\]|\\.)*"|[A-Za-z_][A-Za-z_0-9\']*|[^\s]')


def tokenize(source):
    """Retain source lines; skip nested Why3 comments and quoted strings safely."""
    out = []
    pos, line = 0, 1
    while pos < len(source):
        if source.startswith('(*)', pos):
            out.append(('(*)', line))
            pos += 3
        elif source.startswith('(*', pos):
            level, end = 1, pos + 2
            while level:
                assert end < len(source), 'unterminated comment'
                if source.startswith('(*)', end):
                    end += 3
                elif source.startswith('(*', end):
                    level += 1
                    end += 2
                elif source.startswith('*)', end):
                    level -= 1
                    end += 2
                else:
                    end += 1
            line += source[pos:end].count('\n')
            pos = end
        elif source[pos].isspace():
            line += source[pos] == '\n'
            pos += 1
        else:
            m = TOKEN.match(source, pos)
            assert m
            out.append((m.group(), line))
            line += m.group().count('\n')
            pos = m.end()
    return out


def library_projection(source):
    tokens = tokenize(source)
    modules, directives = [], []
    for i, (tok, line) in enumerate(tokens):
        if tok in ('module', 'theory'):
            modules.append(tokens[i + 1][0])
        if tok not in ('use', 'clone'):
            continue
        j = i + 1
        if tokens[j][0] in ('import', 'export'):
            j += 1
        qid = [tokens[j][0].strip('"')]
        assert re.fullmatch(r'[A-Za-z_][A-Za-z_0-9\']*', qid[0]), (line, qid)
        j += 1
        while j < len(tokens) and tokens[j][0] == '.':
            qid.append(tokens[j + 1][0].strip('"'))
            j += 2
        # The retained closure uses single targets per use declaration. Fail
        # instead of silently missing any future comma-separated target.
        end = j + (2 if j < len(tokens) and tokens[j][0] == 'as' else 0)
        assert end >= len(tokens) or tokens[end][0] != ',', (line, qid)
        directives.append({'kind': tok, 'line': line, 'target': '.'.join(qid),
                           'file': '/'.join(qid[:-1]) if len(qid) > 1 else None})
    local = set(modules)
    builtin = {'BuiltIn', 'Bool', 'Unit', 'Tuple0', 'HighOrd', 'Ref', 'WellFounded'}
    for d in directives:
        assert d['file'] is not None or d['target'] in local | builtin, d
    return {'modules': modules, 'tokens': len(tokens), 'directives': directives,
            'external_files': sorted({d['file'] for d in directives if d['file']
                                      and not d['file'].startswith('why3')})}


def calculate(prior, identity, sources):
    packet = prior / identity['fixed_archive']['path']
    assert digest(packet.read_bytes()) == identity['fixed_archive']['sha256']
    inputs = {}
    roots = set()
    with tarfile.open(packet) as tar:
        for row in identity['fixed_inputs']:
            data = tar.extractfile(row['path']).read()
            assert len(data) == row['bytes'] and digest(data) == row['sha256']
            result = native_projection(json.loads(data))
            inputs[row['name']] = result
            roots.update(result['external_file_roots'])
    files = {row['library_path']: row['path'] for row in identity['files']
             if 'library_path' in row}
    queue, closure = sorted(roots), {}
    while queue:
        name = queue.pop(0)
        if name in closure:
            continue
        result = library_projection(sources[files[name]].decode())
        closure[name] = result
        queue.extend(result['external_files'])
    assert set(closure) == set(files)
    return {'scope': 'exact pretyping declaration counts and whole-file import closure; not typed allocations',
            'inputs': inputs, 'library_closure': dict(sorted(closure.items())),
            'library_files': len(closure),
            'library_bytes': sum(len(sources[files[k]]) for k in closure),
            'library_modules': sum(len(v['modules']) for v in closure.values()),
            'library_use_directives': sum(d['kind'] == 'use' for v in closure.values() for d in v['directives']),
            'library_clone_directives': sum(d['kind'] == 'clone' for v in closure.values() for d in v['directives']),
            'native_backend_processes': len(inputs)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prior-repo', type=Path, default=HERE.parents[2])
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    identity = json.loads((HERE / 'identity.json').read_text())
    archive = HERE / 'sources.tar.gz'
    assert digest(archive.read_bytes()) == identity['source_archive_sha256']
    sources = {}
    with tarfile.open(archive) as tar:
        for row in identity['files']:
            data = tar.extractfile(row['path']).read()
            assert len(data) == row['bytes'] and digest(data) == row['sha256']
            sources[row['path']] = data
    result = calculate(args.prior_repo, identity, sources)
    if args.output:
        args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    else:
        assert result == json.loads((HERE / 'result.json').read_text())
    print(json.dumps({k: v for k, v in result.items() if k not in ('inputs', 'library_closure')}, sort_keys=True))


if __name__ == '__main__':
    main()

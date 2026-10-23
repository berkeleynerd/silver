"""Checkable lexical/source projection, not a WhyML semantic parser."""
import json
import re
import tarfile
from compose import HERE, ROOT

FIXED = 'docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz'


def uncomment(text):
    # lexer.mll:108-111 and Lexlib.comment:82-96. In particular (*) is
    # special inside comments too; the OCaml/driver-only scanner is unsuitable.
    out = list(text)
    i = depth = 0
    while i < len(text):
        if text.startswith('(*)', i):
            if depth:
                out[i:i+3] = '   '
            i += 3
        elif depth:
            if text.startswith('(*', i):
                depth += 1; out[i:i+2] = '  '; i += 2
            elif text.startswith('*)', i):
                depth -= 1; out[i:i+2] = '  '; i += 2
            else:
                if text[i] != '\n': out[i] = ' '
                i += 1
        elif text.startswith('(*', i):
            depth = 1; out[i:i+2] = '  '; i += 2
        elif text[i] == '"':
            i += 1
            while i < len(text):
                if text[i] == '\\': i += 2
                elif text[i] == '"': i += 1; break
                else: i += 1
            else:
                raise ValueError('unclosed string')
        else:
            i += 1
    if depth:
        raise ValueError('unclosed comment')
    return ''.join(out)


def project():
    from freeze import identity
    lib = json.loads((HERE.parent / 'retained-why-library-publication-bound-20261020/bound.json').read_text())
    rows, files = [], {}
    with tarfile.open(ROOT / FIXED) as archive:
        for family in ('int', 'real', 'algebra', 'relations'):
            member = f'installed/libexec/spark/share/why3/theories/{family}.mlw'
            raw = archive.extractfile(member).read()
            text = uncomment(raw.decode())
            files[family] = dict(member=member, **identity(raw))
            # The retained family uses these top-level indentation positions.
            # Internal match ends are indented further; a module end is column0.
            starts = list(re.finditer(r'^(?: {0,2}(?:module|type|constant|function|predicate|inductive|axiom|lemma|let|val|use|clone|meta)\b|end\b)', text, re.M))
            module = None
            for j, match in enumerate(starts):
                end = starts[j+1].start() if j+1 < len(starts) else len(text)
                body = text[match.start():end].strip()
                first = body.splitlines()[0]
                if first.startswith('module '):
                    module = family + '.' + first.split()[1]
                    continue
                if first == 'end':
                    continue
                units = re.findall(r"[A-Za-z_][A-Za-z0-9_']*|[0-9]+|\S", body)
                rows.append(dict(module=module, line=text.count('\n', 0, match.start())+1,
                    units=len(units), bytes=len(body.encode()), first=first, source=body))
    recurrence = lib['module_recurrence']
    def depth(module):
        return 1 + max([depth(t) for t in recurrence[module]['clone_targets']] or [0])
    targets = set()
    def visit(module):
        for target in recurrence[module]['clone_targets']:
            if target not in targets:
                targets.add(target); visit(target)
    for module in recurrence:
        visit(module)
    explicit_program_cloned = [r for r in rows if r['module'] in targets
        and re.match(r'(?:let|val)\b', r['first'])]
    recursive = [r for r in rows if re.search(r'\blet\s+rec\b', r['source'])]
    return dict(schema='silver.retained-why-library-shape-projection.v1', archive=FIXED,
        files=files, declarations=rows, maximum_declaration_lexical_units=max(r['units'] for r in rows),
        clone_ancestry_maximum=max(map(depth, recurrence)),
        cloned_targets=sorted(targets), explicit_program_declarations_in_cloned_targets=explicit_program_cloned,
        recursive_declarations=recursive, lexical_projection_is_not_semantic_proof=True)


if __name__ == '__main__':
    (HERE / 'family-shapes.json').write_text(json.dumps(project(), indent=2, sort_keys=True)+'\n')

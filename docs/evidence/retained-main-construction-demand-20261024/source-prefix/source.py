"""Read-only source inventory supporting the human closure argument.

This lexer is a reference inventory, not an OCaml parser or call-graph proof.
Nested comments and strings are masked while line numbers are preserved.
"""
import hashlib
import re
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
ARCHIVE = 'docs/evidence/retained-producer-prefix-composition-20261018/sources.tar.gz'
SPANS = {
    'src/gnat/gnat_checks.ml': [(380, 412)],
    'src/session/controller_itp.ml': [(271, 285)],
    'src/session/session_itp.ml': [(1843, 1863)],
    'src/core/env.ml': [(66, 119), (133, 166), (191, 228)],
    'plugins/gnat_json/gnat_ast.ml': [(1306, 1397), (2504, 2511)],
    'plugins/gnat_json/gnat_ast_to_ptree.ml': [
        (1, 46), (50, 70), (125, 180), (225, 256), (330, 395),
        (422, 451), (495, 537), (817, 842), (950, 1009), (1011, 1073),
        (1315, 1333), (1337, 1359), (1373, 1446)],
    'plugins/gnat_json/ptree_constructors.ml': [(1, 61), (89, 258)],
    'src/core/ident.ml': [(16, 39), (75, 78), (187, 192)],
    'src/core/ty.ml': [(90, 122)],
    'src/mlw/ity.ml': [(125, 160)],
    'src/util/loc.ml': [(26, 70), (75, 84), (254, 282)],
    'src/util/constant.ml': [(33, 43)],
    'src/util/number.ml': [(76, 165)],
    'src/util/bigInt.ml': [(11, 70)],
    'src/util/strings.ml': [(76, 90)],
    'src/util/hashcons.ml': [(31, 55)],
    'src/util/wstdlib.ml': [(11, 30)],
    'src/util/exthtbl.ml': [(11, 60)],
}
INVENTORY_RANGES = {
    'plugins/gnat_json/gnat_ast.ml': (1, 2511),
    'plugins/gnat_json/gnat_ast_to_ptree.ml': (1, 1333),
    'plugins/gnat_json/ptree_constructors.ml': (1, 258),
}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def mask_ocaml(text):
    out = list(text)
    i = 0
    depth = 0
    string = False
    while i < len(text):
        if string:
            if text[i] == '\\':
                out[i] = ' '
                if i + 1 < len(text):
                    out[i + 1] = '\n' if text[i + 1] == '\n' else ' '
                i += 2
                continue
            if text[i] == '"':
                string = False
            out[i] = '\n' if text[i] == '\n' else ' '
            i += 1
        elif text.startswith('(*', i):
            depth += 1
            out[i:i + 2] = '  '
            i += 2
        elif depth and text.startswith('*)', i):
            depth -= 1
            out[i:i + 2] = '  '
            i += 2
        elif text[i] == '"':
            string = True
            out[i] = ' '
            i += 1
        elif depth:
            out[i] = '\n' if text[i] == '\n' else ' '
            i += 1
        else:
            i += 1
    if depth or string:
        raise ValueError('unterminated OCaml comment/string in selected source')
    return ''.join(out)


def read_sources():
    with tarfile.open(ROOT / ARCHIVE) as archive:
        return {name: archive.extractfile(name).read() for name in SPANS}


def reference_inventory(sources):
    records = {}
    for name, (first, last) in INVENTORY_RANGES.items():
        code = mask_ocaml(sources[name].decode())
        selected = '\n' * (first - 1) + ''.join(code.splitlines(True)[first - 1:last])
        refs = {}
        # Include module-local-open forms M.(...) and full qualified names.
        pattern = r'\b[A-Z][A-Za-z0-9_]*(?:\.[A-Za-z_][A-Za-z0-9_\']*)+|\b[A-Z][A-Za-z0-9_]*\.(?=\()'
        for m in re.finditer(pattern, selected):
            refs.setdefault(m.group(), []).append(selected.count('\n', 0, m.start()) + 1)
        opens = [{'module': m.group(1), 'line': selected.count('\n', 0, m.start()) + 1}
                 for m in re.finditer(r'\bopen\s+([A-Z][A-Za-z0-9_]*)', selected)]
        records[name] = {'qualified_references': refs, 'opens': opens}
    return records


def source_witnesses(sources):
    records = []
    for name, ranges in SPANS.items():
        data = sources[name]
        lines = data.splitlines(True)
        spans = []
        for first, last in ranges:
            if not 1 <= first <= last <= len(lines):
                raise ValueError((name, first, last, len(lines)))
            chunk = b''.join(lines[first - 1:last])
            spans.append({'first': first, 'last': last, 'sha256': digest(chunk),
                          'text': chunk.decode()})
        records.append({'path': name, 'bytes': len(data), 'sha256': digest(data),
                        'spans': spans})
    return records

"""Retain identities/ranges from existing archives; no target or checker run."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


providers = [
    'oracle.md', 'docs/trusted-boundary.md',
    'docs/research/retained-tool-source-identity.md',
    'docs/research/retained-why-parallel-state-attachment.md',
    'docs/evidence/retained-parallel-state-round55-20261020/README.md',
    'docs/research/retained-why-shared-demand.md',
    'docs/research/retained-why-printer-entry.md',
    'docs/research/retained-why-introduction-counter.md',
    'docs/research/retained-why-printer-private-owners.md',
    'docs/evidence/retained-name-attribute-round65-20261023/composition-result.json',
    'docs/evidence/retained-name-attribute-round65-20261023/integration-result.json',
    'docs/evidence/retained-printer-pause-round61-20261023/integration-result.json',
    'docs/evidence/retained-why-printer-entry-20261020/result.json',
    'docs/evidence/retained-why-inline-operations-20261018/compose.py',
    'docs/evidence/retained-why-inline-operations-20261018/representatives.py',
    WHY, OCAML,
    'docs/evidence/retained-why-session-save-outcomes-20261019/runtime-limits.json',
]
why_spans = {
    'why3/src/core/trans.ml': [(45, 59), (76, 140), (233, 247)],
    'why3/src/driver/driver.ml': [(327, 395)],
    'why3/src/util/weakhtbl.ml': [(65, 122)],
    'why3/src/core/task.ml': [(14, 33)],
    'why3/src/core/ty.ml': [(86, 122)],
    'why3/src/core/decl.ml': [(372, 419)],
    'why3/src/core/term.ml': [(1145, 1157)],
    'why3/src/util/hcpt.ml': [(126, 159), (500, 528)],
    'why3/src/util/wstdlib.ml': [(86, 100)],
    'why3/src/core/ident.ml': [(175, 230)],
    'why3/src/util/hashcons.ml': [(30, 61)],
    'why3/src/transform/introduction.ml': [(33, 53), (119, 134), (175, 188), (200, 221), (308, 331)],
    'why3/src/transform/remove_unused.ml': [(32, 60), (94, 126), (259, 286)],
    'why3/src/transform/detect_polymorphism.ml': [(53, 63), (101, 128)],
    'why3/src/transform/inlining.ml': [(86, 101), (137, 145)],
}
ocaml_spans = {
    'ephemeron.ml': [(126, 211), (315, 337), (493, 560)],
    'hashtbl.ml': [(65, 77), (115, 151), (354, 363)],
    'queue.ml': [(20, 70)],
}

if __name__ == '__main__':
    sources = {}
    for archive in (WHY, OCAML):
        with tarfile.open(ROOT / archive) as source:
            for member in source:
                if not member.isfile():
                    continue
                ranges = (why_spans.get(member.name) if archive == WHY
                          else ocaml_spans.get(Path(member.name).name))
                if ranges is None:
                    continue
                data = source.extractfile(member).read()
                lines = data.splitlines(keepends=True)
                assert all(1 <= a <= b <= len(lines) for a, b in ranges), member.name
                sources[member.name] = {
                    'archive': archive, **identity(data),
                    'spans': [{'first': a, 'last': b, **identity(b''.join(lines[a-1:b]))}
                              for a, b in ranges],
                }
    assert all(name in sources for name in why_spans)
    assert len(sources) == len(why_spans) + len(ocaml_spans)
    result = {'providers': {p: identity((ROOT / p).read_bytes()) for p in providers},
              'source_members': sources}
    (HERE / 'inputs.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'providers': len(providers), 'source_members': len(sources)}))

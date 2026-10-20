#!/usr/bin/env python3
"""Freeze only already retained source bytes and evidence identities."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
RANGES = [
    ('serializer', WHY, 'why3/src/session/session_itp.ml', 2099, 2107),
    ('private-path-writers', WHY, 'why3/src/core/theory.ml', 472, 516),
    ('theory-declarations', WHY, 'why3/src/core/theory.ml', 549, 591),
    ('theory-clone-export', WHY, 'why3/src/core/theory.ml', 897, 959),
    ('fresh-theory-record', WHY, 'why3/src/core/theory.ml', 305, 336),
    ('tuple-theory', WHY, 'why3/src/core/theory.ml', 1047, 1075),
    ('theory-interface', WHY, 'why3/src/core/theory.mli', 163, 188),
    ('identifier-tags', WHY, 'why3/src/core/ident.ml', 158, 214),
    ('weak-key-equality', WHY, 'why3/src/util/weakhtbl.ml', 50, 89),
    ('task-constructors', WHY, 'why3/src/core/task.ml', 148, 200),
    ('driver-update-and-prepare', WHY, 'why3/src/driver/driver.ml', 330, 391),
    ('driver-loading-export', WHY, 'why3/src/driver/driver.ml', 232, 247),
    ('literal-environment-lookup', WHY, 'why3/src/transform/eliminate_literal.ml', 193, 228),
    ('algebraic-tuple-registration', WHY, 'why3/src/transform/eliminate_algebraic.ml', 470, 487),
    ('environment-read', WHY, 'why3/src/core/env.ml', 191, 222),
    ('environment-builtins', WHY, 'why3/src/core/env.ml', 225, 244),
    ('registration-and-lookup', WHY, 'why3/src/core/trans.ml', 355, 404),
    ('encoding-indirect-flags', WHY, 'why3/src/transform/encoding.ml', 51, 76),
    ('encoding-selected-composition', WHY, 'why3/src/transform/encoding.ml', 106, 137),
    ('ephemeron-resize', OCAML, 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/ephemeron.ml', 160, 212),
    ('ephemeron-replace-mem', OCAML, 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/ephemeron.ml', 315, 347),
    ('ephemeron-key-data', OCAML, 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/ephemeron.ml', 527, 551),
    ('string-concat', OCAML, 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/string.ml', 56, 77),
    ('runtime-block-cap', OCAML, 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/runtime/caml/mlvalues.h', 150, 172),
]


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def write(name, data):
    (HERE / name).write_text(json.dumps(data, indent=2) + '\n')


def main():
    excerpts = []
    for name, archive, member, first, last in RANGES:
        with tarfile.open(ROOT / archive) as t:
            raw = t.extractfile(member).read()
        text = ''.join(raw.decode().splitlines(keepends=True)[first - 1:last])
        excerpts.append({'id': name, 'archive': archive, 'member': member,
                         'member_identity': identity(raw), 'first': first, 'last': last,
                         'text': text, 'excerpt_identity': identity(text.encode())})
    write('source-excerpts.json', excerpts)
    census = []
    with tarfile.open(ROOT / WHY) as t:
        for m in t.getmembers():
            if not m.isfile() or not m.name.endswith(('.ml', '.mli')):
                continue
            text = t.extractfile(m).read().decode()
            for i, line in enumerate(text.splitlines(), 1):
                if re.search(r'\b(store_path|store_theory|id_to_path)\b', line):
                    census.append({'member': m.name, 'line': i, 'text': line})
    write('private-writer-census.json', census)
    paths = [WHY, OCAML,
             'docs/evidence/retained-why-session-helper-source-20261019/source-identities.json',
             'docs/evidence/retained-why-save-serializer-inputs-20261020/result.json',
             'docs/evidence/retained-why-session-save-outcomes-20261019/runtime-limits.json',
             'docs/evidence/retained-why-session-helper-source-20261019/runtime-version.json',
             'docs/evidence/retained-producer-driver-envelope-20261018/result.json',
             'docs/evidence/retained-why-save-operational-bounds-20261020/transfer.py',
             'docs/research/retained-why-save-serializer-inputs.md',
             'docs/research/retained-why-save-attempt-growth.md',
             'docs/research/retained-why-native-effect-completeness.md',
             'docs/reviews/review-save-capacity-round29-20261020.md']
    write('inputs.json', {p: identity((ROOT / p).read_bytes()) for p in paths})


if __name__ == '__main__':
    main()

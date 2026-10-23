"""Freeze retained source/provider bytes once; no native/proof/predecessor run."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(blob):
    return {'bytes': len(blob), 'sha256': hashlib.sha256(blob).hexdigest()}


def main():
    providers = [
        'docs/research/retained-why-printer-demand.md',
        'docs/reviews/review-printer-demand-20261023.md',
        'docs/reviews/review-printer-syntax-20261023.md',
        'docs/research/retained-why-printer-entry.md',
        'docs/reviews/review-printer-entry-20261023.md',
        'docs/evidence/retained-why-printer-demand-20261023/result.json',
        'docs/research/retained-tool-source-identity.md',
        'docs/research/retained-why-save-hashtbl-prefix.md',
        'docs/evidence/retained-why-save-hashtbl-prefix-20261020/native-witnesses.json',
        'docs/research/retained-why-ordinary-ending-control.md',
        'docs/reviews/review-why-ordinary-ending-control-20261020.md',
        'docs/research/retained-why-native-effect-completeness.md',
        'docs/research/retained-why-model-meta-control.md',
        'docs/research/retained-why-debug-formatter-control.md',
    ]
    archives = {
        'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz': {
            'why3/src/core/ident.ml': [[113, 120], [156, 215], [223, 351]],
            'why3/src/printer/smtv2.ml': [[31, 196], [228, 318], [344, 356], [359, 654], [654, 923], [959, 1075]],
            'why3/src/util/wstdlib.ml': [[11, 30], [60, 100]],
            'why3/src/util/exthtbl.ml': [[38, 65]],
            'why3/src/core/term.ml': [[739, 833]],
            'why3/src/core/printer.ml': [[299, 343]],
            'why3/src/driver/driver.ml': [[391, 404], [456, 474]],
        },
        'docs/evidence/retained-why-inline-operations-20261018/sources.tar.gz': {
            'ocaml/stdlib/hashtbl.ml': [[21, 45], [66, 76], [115, 152], [344, 399], [431, 454], [477, 488]],
        },
    }
    manifest = {
        'base_commit': '7cd4282223',
        'why3_revision': '9390baf120ef260547dfa14f08e11c890b203d9c',
        'ocaml_revision': '8eb41f72ded84df884c3671734c947f612091f84',
        'providers': {p: identity((ROOT / p).read_bytes()) for p in providers},
        'archives': {p: identity((ROOT / p).read_bytes()) for p in archives},
        'raw_name_entry_bytes_upper': None,
    }
    witnesses = []
    for archive, members in archives.items():
        with tarfile.open(ROOT / archive) as tf:
            for member, sections in members.items():
                blob = tf.extractfile(member).read()
                lines = blob.decode().splitlines(keepends=True)
                assert all(type(start) is int and type(end) is int
                           and 1 <= start <= end <= len(lines)
                           for start, end in sections), member
                witnesses.append({'archive': archive, 'member': member,
                                  'identity': identity(blob),
                                  'sections': [
                                      {'start': start, 'end': end,
                                       'text': ''.join(lines[start-1:end])}
                                      for start, end in sections]})
    (HERE / 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (HERE / 'source-witnesses.json').write_text(json.dumps(witnesses, indent=2) + '\n')


if __name__ == '__main__':
    main()

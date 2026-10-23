"""Freeze existing source/provider bytes; no source fetch or prior checker run."""
import json
from pathlib import Path
import subprocess
import tarfile
from project import CASES, ROOT, HERE, EV, identity

WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
LIB = 'docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz'
HYP_COMMIT = '62f686fe7331c2faf74c3c9f66df93f2626f1fa0'


def freeze():
    paths = [
        'docs/research/retained-why-preinline-prefix.md',
        'docs/research/retained-why-fixed-inline-family.md',
        'docs/research/retained-why-returned-storage.md',
        'docs/research/retained-why-printer-entry.md',
        'docs/reviews/review-printer-entry-20261023.md',
        'docs/research/retained-why-printer-demand.md',
        'docs/reviews/review-printer-demand-20261023.md',
        'docs/reviews/review-printer-syntax-20261023.md',
        'docs/research/retained-why-printer-name-tables.md',
        'docs/reviews/review-printer-name-tables-20261023.md',
        'docs/evidence/retained-why-printer-name-tables-20261023/transfer.py',
        'docs/evidence/retained-why-printer-name-tables-20261023/result.json',
        'docs/research/retained-why-path-library-origins.md',
        'docs/research/retained-why-library-constructors.md',
        'docs/research/retained-tool-source-identity.md',
        'docs/evidence/retained-why-parallel-symbol-exclusion-20261020/inputs.json',
        WHY, LIB,
    ]
    for case in CASES:
        row = json.loads((HERE / (case + '-names.json')).read_bytes())
        paths.extend([
            f'docs/evidence/retained-why-preinline-prefix-20261020/{case}-graph.json.gz',
            f'docs/evidence/retained-why-fixed-inline-family-20261020/{case}-types.json',
            f'docs/evidence/retained-why-parallel-symbol-exclusion-20261020/{case}-metadata.json',
            row['capture']['archive'], row['address_map_file'],
        ])
    driver_inputs = EV / 'retained-solver-request-bytes-20261020/driver-inputs.json'
    paths.append(str(driver_inputs.relative_to(ROOT)))
    paths.extend(str((driver_inputs.parent / 'drivers' / n).relative_to(ROOT))
                 for n in json.loads(driver_inputs.read_bytes()))
    sources = {
        WHY: {
            'why3/src/core/ident.ml': [[63, 88], [156, 219], [282, 298], [307, 351], [506, 513], [557, 559]],
            'why3/src/core/ty.ml': [[16, 18], [44, 63], [256, 266], [278, 289]],
            'why3/src/core/term.ml': [[17, 49], [795, 831], [1036, 1048], [1085, 1115], [1675, 1686]],
            'why3/src/core/decl.ml': [[324, 336]],
            'why3/src/transform/eliminate_algebraic.ml': [[280, 392], [608, 636]],
            'why3/src/transform/eliminate_literal.ml': [[21, 48], [92, 125], [193, 223]],
            'why3/src/transform/eliminate_epsilon.ml': [[145, 202]],
            'why3/src/transform/introduction.ml': [[23, 31], [109, 136], [175, 191], [205, 258]],
            'why3/src/parser/parser_common.mly': [[1560, 1566]],
            'why3/src/parser/typing.ml': [[188, 200]],
            'why3/src/mlw/expr.ml': [[138, 150]],
            'why3/src/mlw/pmodule.ml': [[729, 738]],
            'why3/src/printer/smtv2.ml': [[654, 674], [770, 775], [810, 825], [855, 891]],
        },
        LIB: {
            'installed/libexec/spark/share/why3/theories/int.mlw': [[11, 31]],
            'installed/libexec/spark/share/why3/theories/real.mlw': [[11, 30]],
        },
    }
    witnesses = []
    for archive, members in sources.items():
        with tarfile.open(ROOT / archive) as tf:
            for member, ranges in members.items():
                blob = tf.extractfile(member).read()
                lines = blob.decode().splitlines(keepends=True)
                sections = []
                for first, last in ranges:
                    assert 1 <= first <= last <= len(lines), (member, first, last)
                    sections.append({'first': first, 'last': last, 'text': ''.join(lines[first-1:last])})
                witnesses.append({'archive': archive, 'member': member,
                                  'identity': identity(blob), 'sections': sections})
    # Portable exact copies for the ONE imported hypothesis-name interface.
    # No other Hsattr count or owner result is consumed or revalidated here.
    hyp = []
    for original, local in [
        ('docs/research/retained-why-hsattr-demand.md', 'hyp-name-provider.md'),
        ('docs/evidence/retained-why-hsattr-demand-20261023/result.json', 'hyp-name-provider-result.json')]:
        blob = subprocess.check_output(['git', 'show', HYP_COMMIT + ':' + original], cwd=ROOT)
        (HERE / local).write_bytes(blob)
        hyp.append({'commit': HYP_COMMIT, 'path': original, 'retained_copy': local,
                    'identity': identity(blob), 'consumed_claim': 'hyp_name value bytes at most13'})
    manifest = {'base_commit': '8b651049e46c8800df92e9efed4832ddfcbad8ab',
                'why3_revision': '9390baf120ef260547dfa14f08e11c890b203d9c',
                'files': {p: identity((ROOT / p).read_bytes()) for p in dict.fromkeys(paths)},
                'hyp_name_provider': hyp,
                'hyp_name_provider_independent_review_at_author_freeze': 'pending joint review'}
    (HERE / 'inputs.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (HERE / 'source-witnesses.json').write_text(json.dumps(witnesses, indent=2) + '\n')


if __name__ == '__main__':
    freeze()

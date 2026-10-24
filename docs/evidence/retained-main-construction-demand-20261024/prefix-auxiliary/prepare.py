"""Freeze existing provider/source bytes for the auxiliary author packet."""
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BASE = '028176177b'
RESEARCH = 'docs/research/retained-main-construction-demand.md'
PACKET = 'docs/evidence/retained-main-construction-demand-20261024'
WHY = 'docs/evidence/retained-producer-prefix-composition-20261018/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
PROVIDERS = [WHY, OCAML,
    'docs/evidence/retained-main-entry-capacity-20261024/result.json',
    'docs/research/retained-main-entry-capacity.md',
    'docs/reviews/review-main-entry-capacity-20261024.md',
    'docs/reviews/review-main-source-prefix-20261024.md',
    'docs/evidence/review-main-source-prefix-20261024/result.json',
    'docs/research/retained-why-filetags-capacity.md',
    'docs/evidence/retained-why-filetags-capacity-20261023/inputs.json',
    'docs/evidence/retained-why-filetags-capacity-20261023/source-ranges.json',
    'docs/evidence/retained-why-filetags-capacity-20261023/source-witnesses.md',
    'docs/evidence/retained-why-save-hashtbl-prefix-20261020/native-witnesses.json',
    'docs/research/retained-why-hsattr-demand.md',
    'docs/evidence/retained-why-hsattr-demand-20261023/inputs.json',
    'docs/evidence/retained-why-hsattr-demand-20261023/source-witnesses.json',
    'docs/evidence/retained-why-inline-operations-20261018/compose.py',
    'docs/evidence/retained-why-session-save-outcomes-20261019/runtime-limits.json',
    'docs/research/retained-producer-composition.md',
    'docs/evidence/retained-producer-composition-20261018/result.json',
    'docs/research/retained-producer-storage.md',
    'docs/research/retained-producer-capacity.md',
    'docs/evidence/retained-producer-storage-20261018/serialization.json',
    'docs/research/retained-main-callers-profile.md',
    'docs/evidence/retained-main-callers-profile-20261023/source.py',
    'docs/evidence/retained-main-callers-profile-20261023/body.py',
    'docs/reviews/review-main-callers-4a4d15cd02.md',
]


def digest(b):
    return hashlib.sha256(b).hexdigest()


def pin(path, data=None):
    data = (ROOT / path).read_bytes() if data is None else data
    return {'path': path, 'bytes': len(data), 'sha256': digest(data)}


def write(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2) + '\n')


if __name__ == '__main__':
    caps = json.loads((HERE / 'source-caps.json').read_text())
    converter_ranges = sorted(set(tuple(r) for family in caps['families'] for r in family['source']) |
                              {(225, 256), (271, 321), (950, 982), (1337, 1359), (1382, 1410)})
    specs = {
        WHY: {
            'src/gnat/gnat_main.ml': [(310, 346)],
            'src/gnat/gnat_checks.ml': [(380, 412)],
            'plugins/gnat_json/gnat_ast_to_ptree.ml': converter_ranges,
            'plugins/gnat_json/ptree_constructors.ml': [(6, 61), (89, 258)],
            'plugins/gnat_json/gnat_ast.ml': [(79, 81), (149, 240), (1306, 1355), (1430, 1476), (2504, 2511)],
            'src/util/loc.ml': [(42, 80), (254, 282)],
            'src/util/wstdlib.ml': [(13, 30)],
            'src/util/exthtbl.ml': [(38, 50)],
            'src/core/ident.ml': [(16, 39)],
            'src/util/number.ml': [(91, 165)],
        },
        OCAML: {
            'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/hashtbl.ml': [(20, 40), (64, 76), (115, 152), (340, 405), (477, 488)],
            'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/set.ml': [(72, 141), (246, 250)],
        },
    }
    rows = []
    for archive_name, names in specs.items():
        with tarfile.open(ROOT / archive_name) as archive:
            for name, spans in names.items():
                data = archive.extractfile(name).read()
                lines = data.splitlines(True)
                pieces = []
                for first, last in spans:
                    assert 1 <= first <= last <= len(lines)
                    chunk = b''.join(lines[first-1:last])
                    pieces.append({'first': first, 'last': last, 'sha256': digest(chunk), 'text': chunk.decode()})
                rows.append({'archive': archive_name, **pin(name, data), 'spans': pieces})
    write('source-witnesses.json', rows)
    names = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', PACKET], cwd=ROOT, text=True).splitlines()
    immutable = [pin(p, subprocess.check_output(['git', 'show', f'{BASE}:{p}'], cwd=ROOT)) for p in names]
    old_research = subprocess.check_output(['git', 'show', f'{BASE}:{RESEARCH}'], cwd=ROOT)
    write('inputs.json', {
        'base_commit': BASE,
        'source_prefix_author': 'a75ca51a31e2b50357032b5d7fe0155eeda434b0',
        'source_prefix_review': '948869ace9fdc65ea8fb1ff17cda17809e502bc5',
        'providers': [pin(p) for p in PROVIDERS],
        'immutable_earlier_packets': immutable,
        'research_prefix': pin(RESEARCH, old_research),
        'source_native_status': 'Existing accepted C/R65/R71/shared-service source/native/runtime facts reused. No fresh capture, disassembly or compiler proof; scalar/table source argument remains human-reviewed.',
    })
    print('Frozen auxiliary provider/source identities; no checker or native run.')

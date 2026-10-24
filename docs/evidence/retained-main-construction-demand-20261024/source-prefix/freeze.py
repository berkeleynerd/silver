"""Extract retained sources/provider identities; never execute a predecessor."""
import json
import subprocess
import sys

sys.dont_write_bytecode = True
from source import ARCHIVE, HERE, ROOT, digest, read_sources, reference_inventory, source_witnesses

BASE = 'c122e0159b'
RESEARCH = 'docs/research/retained-main-construction-demand.md'
PACKET = 'docs/evidence/retained-main-construction-demand-20261024'
PROVIDERS = [
    'docs/research/retained-main-entry-capacity.md',
    'docs/evidence/retained-main-entry-capacity-20261024/result.json',
    'docs/evidence/retained-main-entry-capacity-20261024/identity.json',
    'docs/reviews/review-main-entry-capacity-20261024.md',
    'docs/research/retained-main-callers-profile.md',
    'docs/evidence/retained-main-callers-profile-20261023/identity.json',
    'docs/evidence/retained-main-callers-profile-20261023/result.json',
    'docs/reviews/review-main-callers-4a4d15cd02.md',
    'docs/research/retained-main-vc-composition.md',
    'docs/evidence/retained-main-vc-composition-20261023/identity.json',
    'docs/evidence/retained-main-vc-composition-20261023/result.json',
    'docs/reviews/review-main-vc-composition-20261023.md',
    'docs/reviews/review-main-shared-services-20261024.md',
    'docs/evidence/review-main-shared-services-20261024/source-elf-result.json',
    'docs/research/retained-producer-composition.md',
    'docs/research/retained-producer-capacity.md',
    'docs/research/retained-why-filetags-capacity.md',
    'docs/evidence/retained-why-filetags-capacity-20261023/inputs.json',
    'docs/research/retained-why-hsattr-demand.md',
    'docs/evidence/retained-why-hsattr-demand-20261023/inputs.json',
    'docs/evidence/retained-why-inline-operations-20261018/compose.py',
]


def write(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2) + '\n')


def file_pin(path):
    data = (ROOT / path).read_bytes()
    return {'path': path, 'bytes': len(data), 'sha256': digest(data)}


if __name__ == '__main__':
    sources = read_sources()
    write('source-witnesses.json', source_witnesses(sources))
    write('reference-inventory.json', reference_inventory(sources))
    old_names = subprocess.check_output(
        ['git', 'ls-tree', '-r', '--name-only', BASE, '--', PACKET], cwd=ROOT,
        text=True).splitlines()
    old = []
    for path in old_names:
        data = subprocess.check_output(['git', 'show', f'{BASE}:{path}'], cwd=ROOT)
        old.append({'path': path, 'bytes': len(data), 'sha256': digest(data)})
    prefix = subprocess.check_output(['git', 'show', f'{BASE}:{RESEARCH}'], cwd=ROOT)
    write('inputs.json', {
        'base_commit': BASE,
        'populated_C_author': 'e45ee72a42d6cc669e95b80c2c991cbc65fe4e73',
        'populated_C_review': 'bd5025636d85bcc58da8d716ef03860cf828c951',
        'shared_author': '22cdc0d78c850525c78f8c3bda05424462324f84',
        'shared_review': '7f3357b0289ff57fbd8303ca024534b209868234',
        'R77_author': 'ebe36e4b9c9a12cc6a5ad4fd4269f2faafeec58c',
        'R77_receipt': '7ab729be0bfaf393f462f070d9a09af614c87567',
        'R77_review': '6031a189e04b710a2858823b9e38165838a37079',
        'R79_author': '59e4ff13433b6c3ee3b1dc3888896db416682b1d',
        'R79_review': '23fd53e56981653755565eccaa5ef2e8f1e431c5',
        'why_revision': '9390baf120ef260547dfa14f08e11c890b203d9c',
        'ocaml_revision': '8eb41f72ded84df884c3671734c947f612091f84',
        'archive': file_pin(ARCHIVE),
        'providers': [file_pin(p) for p in PROVIDERS],
        'immutable_earlier_packet': old,
        'research_prefix': {'path': RESEARCH, 'bytes': len(prefix), 'sha256': digest(prefix)},
        'source_native_correspondence': 'Reused accepted C/source/compiler/runtime/plugin relation; no fresh native capture or decoder disassembly. Source argument and library no-application-callback interfaces remain trusted, not machine-proved.',
    })
    print('Frozen retained source identities and complete reference inventory; no target or checker run.')

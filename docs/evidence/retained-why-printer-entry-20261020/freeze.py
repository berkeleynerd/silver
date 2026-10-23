"""Freeze new source excerpts and provider identities; never execute providers."""
from pathlib import Path
import hashlib
import json
import subprocess
import tarfile
from collections import Counter

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EV = HERE.parent

def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def dump(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')

SECTIONS = {
    'core/term.ml': [(570, 660), (739, 862), (878, 920), (1031, 1062), (1080, 1215), (1240, 1340), (1668, 1715), (1794, 1835)],
    'core/decl.ml': [(38, 94), (340, 419), (495, 535), (604, 710), (743, 860)],
    'core/task.ml': [(25, 107), (145, 212)],
    'core/trans.ml': [(25, 140), (210, 275), (450, 566)],
    'core/ty.ml': [(78, 135), (205, 257), (277, 292)],
    'core/theory.ml': [(645, 665), (965, 990), (1040, 1058)],
    'core/pattern.ml': [(85, 110)],
    'driver/driver.ml': [(371, 408)],
    'gnat/gnat_main.ml': [(292, 365)],
    'gnat/gnat_checks.ml': [(282, 324), (540, 597), (630, 663), (733, 755)],
    'transform/gnat_split_conj.ml': [(282, 327)],
    'transform/gnat_rewrite.ml': [(1, 137)],
    'transform/gnat_trivial.ml': [(1, 25)],
    'transform/prepare_for_counterexmp.ml': [(15, 37)],
    'transform/eliminate_definition.ml': [(120, 136), (190, 211)],
    'transform/eliminate_inductive.ml': [(1, 61)],
    'transform/eliminate_algebraic.ml': [(53, 205), (206, 701)],
    'transform/eliminate_epsilon.ml': [(23, 74), (114, 224)],
    'transform/eliminate_gnatprove_guard_epsilon.ml': [(23, 129)],
    'transform/eliminate_literal.ml': [(26, 225)],
    'transform/introduction.ml': [(20, 284), (485, 528)],
    'transform/simplify_formula.ml': [(15, 50)],
    'util/hashcons.ml': [(26, 67)],
}

archive = EV / 'retained-why-session-helper-source-20261019/sources.tar.gz'
witnesses = {}
with tarfile.open(archive) as tf:
    for path, ranges in SECTIONS.items():
        member = 'why3/src/' + path
        data = tf.extractfile(member).read()
        lines = data.decode().splitlines(keepends=True)
        witnesses[path] = dict(member=member, **identity(data), sections=[
            dict(first=a, last=min(b, len(lines)), text=''.join(lines[a-1:b]))
            for a, b in ranges])
dump('source-witnesses.json', {'archive': str(archive.relative_to(REPO)),
     'archive_identity': identity(archive.read_bytes()), 'sources': witnesses,
     'source_argument_machine_checked': False})

inputs = json.loads((HERE / 'inputs.json').read_text())
inputs['retained_inputs'].update({str(p.relative_to(REPO)): identity(p.read_bytes()) for p in [
    EV / 'retained-why-returned-storage-20261020/driver-connection.json',
    EV / 'retained-why-postinline-preparation-20261020/driver-inventory.json',
    REPO / 'docs/research/retained-why-model-meta-control.md',
    REPO / 'docs/research/retained-why-standard-initial-state.md',
]})
for p in sorted((EV / 'retained-solver-request-bytes-20261020/drivers').glob('*')):
    if p.is_file():
        inputs['retained_inputs'][str(p.relative_to(REPO))] = identity(p.read_bytes())
metadata = []
for case in ['put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid']:
    p = EV / 'retained-why-parallel-symbol-exclusion-20261020' / (case + '-metadata.json')
    inputs['retained_inputs'][str(p.relative_to(REPO))] = identity(p.read_bytes())
    obj = json.loads(p.read_text())
    absent = ['material_type_arg', 'eliminate_algebraic', 'introduced_lsymbol', 'introduced_prsymbol']
    assert all(not obj['updated_metadata'].get(key) for key in absent)
    deps = obj['updated_metadata'].get('remove_unused:dependency', [])
    maximum = max(Counter(row[0][1] for row in deps).values(), default=0)
    assert maximum <= 2
    metadata.append(dict(case=case, absent_in_complete_updated_metadata=absent,
                         maximum_dependency_heads_per_axiom=maximum,
                         source_connection='Raw metas are a subset; driver directives and later writer absence are source arguments.'))
connection = json.loads((EV / 'retained-why-returned-storage-20261020/driver-connection.json').read_text())
alt = connection['driver_closures']['alt_ergo_gnatprove_smt2.drv']
for filename in alt:
    text = (EV / 'retained-solver-request-bytes-20261020/drivers' / filename).read_text()
    assert 'material_type_arg' not in text and 'meta "eliminate_algebraic"' not in text
dump('metadata-attachment.json', {'cases': metadata, 'alt_ergo_import_closure': alt,
                                 'material_meta_and_configuration_directives_absent_in_alt_ergo_closure': True})
inputs['external_frozen_inputs'] = {}
for commit, paths in [
    ('d551c0c33ea767057fa732904faf2e1325dfe07c', [
        'docs/research/retained-why-right-split.md',
        'docs/evidence/retained-why-right-split-20261023/bounds.py',
        'docs/evidence/retained-why-right-split-20261023/check-result.json']),
    ('65ade88b39', [
        'docs/research/retained-why-collision-comparison.md',
        'docs/evidence/retained-why-collision-comparison-20261020/result.json']),
]:
    full = subprocess.check_output(['git', 'rev-parse', commit], cwd=REPO, text=True).strip()
    for path in paths:
        key = full + ':' + path
        data = subprocess.check_output(['git', 'show', key], cwd=REPO)
        inputs['external_frozen_inputs'][key] = identity(data)
inputs['source_excerpt_or_theorem_checker_complete'] = False
inputs['finite_source_excerpt_checker_available'] = True
inputs['source_argument_machine_checked'] = False
inputs['inspected_sources'].update({p: {k: v[k] for k in ['bytes', 'sha256']} for p, v in witnesses.items()})
dump('inputs.json', inputs)
packet_files = [p for p in HERE.iterdir() if p.is_file() and p.name not in
                ['packet-inputs.json', 'check-result.json', 'round.json', 'README.md']]
packet_files.append(REPO / 'docs/research/retained-why-printer-entry.md')
dump('packet-inputs.json', {str(p.relative_to(REPO)): identity(p.read_bytes()) for p in packet_files})
print('frozen', len(witnesses), 'source members,', len(inputs['retained_inputs']), 'providers,', len(inputs['external_frozen_inputs']), 'external frozen inputs')

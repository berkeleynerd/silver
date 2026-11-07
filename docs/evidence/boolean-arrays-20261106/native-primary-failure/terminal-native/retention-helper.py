"""Retain the original audit's terminal failure. Never launch validation."""
from pathlib import Path
from datetime import datetime, timezone
from collections import Counter
import gzip
import hashlib
import importlib.util
import json
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

NATIVE = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/empty-loop-repair')
FEATURE = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/boolean-arrays')
SCRATCH = NATIVE / 'tmp/boolean-array-producer'
RUN = Path('/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/20261106T232644-673fc5a9c06b')
PACKET = FEATURE / 'docs/evidence/boolean-arrays-20261106/native-primary-failure'
REPORTS = NATIVE / '.silver/linux-x86_64/compiler/obj/review-final/gnatprove'
SOURCE_SHA = '1686b0b61da8c684ce185995621fb08bc5a6932893d2cc859a82ced9922ce4e8'

spec = importlib.util.spec_from_file_location('old_retention_helpers', SCRATCH / 'retain-final-native.py')
helpers = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helpers)
sha, write, archive = helpers.sha, helpers.write, helpers.add_archive

def main():
    events = [json.loads(line) for line in (RUN / 'events.jsonl').read_text().splitlines()]
    assert events[-1]['event'] == 'finished', 'Original audit still active; retain nothing terminal.'
    assert events[-1]['outcome'] != 'success', 'Known unresolved helpers cannot be relabelled successful.'
    assert sha(NATIVE / 'src/silver_output_profile.adb') == SOURCE_SHA
    frozen = PACKET / 'checkpoint-artifact-inventory.json'
    assert sha(frozen) == '8a4a6bb9d6cb043f9c3e09a8509fa34b7bd6f16852240543324eaab04258fdcc'
    for row in json.loads(frozen.read_text())['files']:
        assert sha(PACKET / row['path']) == row['sha256'], row['path']
    destination = PACKET / 'terminal-native'
    stage = SCRATCH / 'terminal-native-retained'
    assert not destination.exists() and not stage.exists()
    stage.mkdir()
    native_comparison, feature_comparison = [], []
    prepared = next(e['inputs'] for e in events if e['event'] == 'prepared')
    sys.path.insert(0, str(NATIVE))
    from scripts.platforms import native_layout
    from scripts.proof_provenance import input_hashes
    current_all_inputs = input_hashes(native_layout(NATIVE))
    assert current_all_inputs == prepared['inputs_sha256'], 'Original full preflight input drift'
    tool_comparison = []
    for name, identity in prepared.get('tools', {}).items():
        if isinstance(identity, dict) and identity.get('path') and identity.get('sha256'):
            current = sha(Path(identity['path']))
            assert current == identity['sha256'], name
            tool_comparison.append({'tool': name, 'path': identity['path'], 'sha256': current})
    snapshot = json.loads((SCRATCH / 'validation-final-inputs.json').read_text())
    for name, expected in snapshot['inputs'].items():
        native, feature = NATIVE / name, FEATURE / name
        assert sha(native) == expected, name
        native_comparison.append({'path': name, 'sha256': expected})
        actual = sha(feature) if feature.is_file() else None
        if actual != expected:
            feature_comparison.append({'path': name, 'original_sha256': expected, 'feature_sha256': actual})
    write(stage / 'input-comparison.json', {
        'native_source_sha256': SOURCE_SHA,
        'native_selected_inputs': native_comparison,
        'native_snapshot_matches': True,
        'all_native_preflight_inputs_match': True,
        'all_native_preflight_input_count': len(current_all_inputs),
        'tool_comparison': tool_comparison,
        'feature_differences_from_original': feature_comparison,
        'feature_comparison_scope': 'Dated comparison only; the feature source may contain reviewed repairs absent from this failed audit.',
        'native_head': helpers.git(NATIVE, 'rev-parse', 'HEAD'),
        'feature_head': helpers.git(FEATURE, 'rev-parse', 'HEAD'),
    })
    inventories = {}
    for label, members in [
        ('managed-run', [(p, str(p.relative_to(RUN))) for p in sorted(RUN.rglob('*')) if p.is_file() and p.name != 'lease']),
        ('selected-native-sources', [(NATIVE / name, name) for name in sorted(snapshot['inputs'])]),
        ('native-reports', [(p, p.name) for p in sorted(REPORTS.iterdir()) if p.is_file() and p.suffix in {'.spark', '.spark_error', '.out', '.sarif', '.json'}]),
    ]:
        inventory = archive(stage / (label + '.tar.gz'), members)
        write(stage / (label + '.inventory.json'), inventory)
        inventories[label] = {'members': len(inventory), 'source_bytes': sum(r['bytes'] for r in inventory)}
    complete_task_members = [
        (p, str(p.relative_to(REPORTS))) for p in sorted(REPORTS.rglob('*'))
        if p.is_file() and (p.suffix in {'.gnat-json', '.conf', '.why', '.mlw'}
                            or p.name in {'why3session.xml', 'why3shapes', 'why3shapes.gz'})
    ]
    complete_task_inventory = archive(stage / 'all-native-tasks-and-sessions.tar.gz', complete_task_members)
    write(stage / 'all-native-tasks-and-sessions.inventory.json', complete_task_inventory)
    inventories['all-native-tasks-and-sessions'] = {
        'members': len(complete_task_inventory),
        'source_bytes': sum(row['bytes'] for row in complete_task_inventory),
        'scope': 'All available original generated task/session/shape/configuration files before same-path refresh; not only unresolved helpers.',
    }
    failures, session_members, all_sessions = [], [], []
    threshold = datetime.fromisoformat(events[0]['utc']).timestamp()
    for xml in sorted(REPORTS.glob('silver_output_profile__*/why3session.xml')):
        if xml.stat().st_mtime < threshold:
            continue
        tree = ET.parse(xml).getroot()
        top = [g for f in tree.findall('file') for th in f.findall('theory') for g in th.findall('goal')]
        all_sessions.append({'entity': xml.parent.name, 'proved': bool(top) and all(g.get('proved') == 'true' for g in top)})
        if not all_sessions[-1]['proved']:
            leaves = [g for g in tree.iter('goal') if g.get('proved') != 'true' and g.find('proof') is not None]
            failures.append({'entity': xml.parent.name, 'unresolved_attempt_nodes': [g.attrib for g in leaves],
                             'unresolved_attempt_xml': [ET.tostring(g, encoding='unicode') for g in leaves]})
            for p in (REPORTS / (xml.parent.name + '.gnat-json'), xml, xml.parent / 'why3shapes', xml.parent / 'why3shapes.gz'):
                if p.is_file():
                    session_members.append((p, str(p.relative_to(REPORTS))))
    inventory = archive(stage / 'unresolved-helper-tasks-and-sessions.tar.gz', session_members)
    write(stage / 'unresolved-helper-tasks-and-sessions.inventory.json', inventory)
    counts, severities, unresolved_records = Counter(), {}, []
    for p in sorted(REPORTS.glob('*.spark')):
        data = json.loads(p.read_text())
        counts['units'] += 1
        counts['entities'] += len(data.get('entities', {}))
        for kind in ('proof', 'flow'):
            records = data.get(kind, [])
            counts[kind + '_records'] += len(records)
            counter = Counter(r.get('severity', '<absent>') for r in records)
            severities.setdefault(kind, Counter()).update(counter)
            unresolved_records.extend({'report': p.name, 'kind': kind, 'record': r} for r in records if r.get('severity') != 'info')
    record = {
        'recorded_utc': datetime.now(timezone.utc).isoformat(), 'run_id': RUN.name,
        'started': events[0], 'finished': events[-1], 'native_source_sha256': SOURCE_SHA,
        'command': next(e['command'] for e in events if e['event'] == 'command'),
        'actual_unresolved_report_records': unresolved_records,
        'fresh_output_profile_helper_sessions': all_sessions,
        'unresolved_helper_sessions': failures, 'counts': dict(counts),
        'severity_census': {k: dict(v) for k, v in severities.items()},
        'archives': inventories,
        'selected_model_effort': 'GPT-6.1 Sol / Extra High per original assignment; runtime confirmation and token/cost unavailable.',
        'scope': 'Terminal failure/interruption of the original complete audit on old source. Original failed evidence remains failed. Later repaired assurance requires its own complete current-input audit. No proof, source mutation, build or application execution performed by retention.',
    }
    write(stage / 'record.json', record)
    shutil.copy2(Path(__file__), stage / 'retention-helper.py')
    (stage / 'README.md').write_text('# Original audit terminal evidence\n\nThe terminal outcome, exact original inputs, complete available native reports, managed logs/events, failed helper tasks/sessions and report census are retained in [record.json](record.json). This is failed original-source evidence; it makes no successful native-assurance claim for the later repaired feature.\n')
    write(stage / 'artifact-inventory.json', [{'path': p.name, 'bytes': p.stat().st_size, 'sha256': sha(p)} for p in sorted(stage.iterdir()) if p.is_file()])
    shutil.copytree(stage, destination)
    for row in json.loads((destination / 'artifact-inventory.json').read_text()):
        assert sha(destination / row['path']) == row['sha256']
    print(json.dumps({'destination': str(destination), 'outcome': events[-1]['outcome'], 'counts': dict(counts), 'unresolved_helpers': [r['entity'] for r in failures]}, indent=2))

if __name__ == '__main__':
    main()

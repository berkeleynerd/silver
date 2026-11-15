#!/usr/bin/env python3
"""Retain exact inputs and mapping controls for the isolated Rosetta delivery."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
import platform
import subprocess
import sys

ROOT = next(path for path in Path(__file__).resolve().parents if (path / '.git').exists())
OUT = Path(__file__).resolve().parent
BASE = '8ccbc84210346596bc8417cbf8b6bc40f8075ed7'
PROPOSAL = 'dea5d04ad708d2c0d710b99c276a8b27526f975e'
sys.path.insert(0, str(ROOT))
from rosetta import refresh


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def digest(data):
    return hashlib.sha256(data).hexdigest()


def inventory(paths):
    return {path: {'bytes': (ROOT / path).stat().st_size,
                   'sha256': digest((ROOT / path).read_bytes())} for path in sorted(paths)}


def positions(coverage, manifest):
    candidates = [{'title': task['title'], 'task': task,
                   'assessed': coverage['tasks'][task['title']]}
                  for task in manifest
                  if task['title'] in coverage['tasks']
                  and refresh.verdict(coverage['tasks'][task['title']],
                                      refresh.reasons(coverage['tasks'][task['title']],
                                                      coverage['policy'])) in refresh.OUTLOOKS]
    stage, result, drivers = 0, {}, {}
    for rank, (item, new) in enumerate(refresh.progression(candidates, coverage['supported']), 1):
        stage += bool(new) or rank == 1
        result[item['title']] = {'rank': rank, 'stage': stage}
        if new or rank == 1:
            drivers[str(stage)] = {'title': item['title'], 'introduces': new}
    return result, drivers


def main():
    current = json.loads((ROOT / 'rosetta/coverage.json').read_bytes())
    original = json.loads(git('show', f'{BASE}:rosetta/coverage.json'))
    proposal = json.loads(git('show', f'{PROPOSAL}:rosetta/coverage.json'))
    manifest_bytes = (ROOT / 'rosetta/manifest.json').read_bytes()
    assert manifest_bytes == git('show', f'{BASE}:rosetta/manifest.json')
    manifest = json.loads(manifest_bytes)['tasks']
    changed_tasks = [name for name in current['tasks'] if
                     current['tasks'][name] != original['tasks'][name]]
    assert changed_tasks == ['Return multiple values'], changed_tasks
    assert set(current['tasks']) == set(original['tasks'])
    assert current['policy'] == original['policy']
    added = sorted(set(current['supported']) - set(original['supported']))
    removed = sorted(set(original['supported']) - set(current['supported']))
    assert added == ['scalar-procedures'] and not removed
    assert not set(['procedures', 'integers', 'ranged-subtypes', 'scalar-image']) & set(current['supported'])
    before, before_drivers = positions(original, manifest)
    after, after_drivers = positions(current, manifest)
    changed_stages = [name for name in before if before[name]['stage'] != after[name]['stage']]
    entered = [name for name in after if after[name]['stage'] == 1 and before[name]['stage'] != 1]
    left = [name for name in before if before[name]['stage'] == 1 and after[name]['stage'] != 1]
    assert changed_stages == entered == ['Return multiple values'] and not left
    assert before['Return multiple values'] == {'rank': 85, 'stage': 2}
    assert after['Return multiple values'] == {'rank': 59, 'stage': 1}
    assert sum(item['stage'] == 1 for item in before.values()) == 83
    assert sum(item['stage'] == 1 for item in after.values()) == 84
    assert len(before_drivers) == len(after_drivers) == 44
    assert before_drivers == after_drivers
    assert after_drivers['2']['title'] == 'Law of cosines - triples'
    assert after_drivers['2']['introduces'] == ['for-loops', 'integers', 'procedures',
                                               'ranged-subtypes', 'scalar-image']
    provenance = ['revision', 'assessed', 'rubric', 'tier', 'model', 'effort']
    task = current['tasks']['Return multiple values']
    assert all(task[key] == original['tasks']['Return multiple values'][key] for key in provenance)
    for path in ['rosetta/assessment-scalar-procedures-20261109.md',
                 'samples/manifest.json', 'samples/rosetta_return_multiple_values.adb',
                 'rosetta/r/return-multiple-values/task.wiki',
                 'rosetta/r/return-multiple-values/ada.wiki',
                 'rosetta/r/return-multiple-values/ada-1.ada']:
        assert (ROOT / path).read_bytes() == git('show', f'{BASE}:{path}'), path
    source = (ROOT / 'samples/rosetta_return_multiple_values.adb').read_bytes()
    assert len(source) == 912 and digest(source) == 'fe82cee9e09fb5911c02049998bb580defec6168af792664427231880c7b547d'
    samples = json.loads((ROOT / 'samples/manifest.json').read_bytes())['samples']
    sample = next(item for item in samples if item['source'] == 'rosetta_return_multiple_values.adb')
    image = lambda value: (' ' if value >= 0 else '') + str(value)
    expected = ''.join(f'Sum:{image(left + right)}\nDifference:{image(left - right)}\n'
                       for left, right in [(5, 3), (-100, 100), (100, 100)]).encode()
    assert sample['expected'] == {'stdout': expected.decode(), 'stderr': '', 'exit_status': 0}
    assert len(expected) == 67 and digest(expected) == '4af8f788ee41cd6f93e9d9f7bd4c98550618eeea59c5f53f16329781b8cd138a'
    assert all(-200 <= left + right <= 200 and -200 <= left - right <= 200
               for left in range(-100, 101) for right in range(-100, 101))
    original_paths = git('diff', '--name-only', BASE, PROPOSAL).decode().splitlines()
    current_paths = git('diff', '--name-only', BASE, '--', 'rosetta', 'rosetta.md').decode().splitlines()
    assert len(original_paths) == 40 and set(current_paths) == set(original_paths)
    generated = ['rosetta.md', 'rosetta/progression.md',
                 *[str(path.relative_to(ROOT)) for path in (ROOT / 'rosetta').rglob('silver.md')]]
    generated_inventory = inventory(generated)
    inputs = inventory(['rosetta/manifest.json', 'rosetta/coverage.json', 'rosetta/refresh.py',
                        'rosetta/assess.js', 'tests/test_rosetta.py',
                        'samples/manifest.json', 'samples/rosetta_return_multiple_values.adb',
                        'rosetta/r/return-multiple-values/task.wiki',
                        'rosetta/r/return-multiple-values/ada.wiki',
                        'rosetta/r/return-multiple-values/ada-1.ada',
                        'rosetta/assessment-scalar-procedures-20261109.md'])
    report = {
        'baseline_commit': BASE, 'original_proposal_commit': PROPOSAL,
        'host': platform.platform(), 'machine': platform.machine(),
        'python': sys.version, 'python_executable': sys.executable,
        'python_executable_sha256': digest(Path(sys.executable).read_bytes()),
        'inputs': inputs, 'render_inputs': ['rosetta/manifest.json', 'rosetta/coverage.json', 'rosetta/refresh.py'],
        'changed_task_assessments': changed_tasks,
        'metadata_fields_changed_since_proposal': [key for key in task if task[key] != proposal['tasks']['Return multiple values'][key]],
        'supported_added': added, 'supported_removed': removed,
        'stage_1_before': 83, 'stage_1_after': 84, 'stages_before': 44, 'stages_after': 44,
        'entered_stage_1': entered, 'left_stage_1': left, 'changed_task_stages': changed_stages,
        'return_multiple_values_before': before['Return multiple values'],
        'return_multiple_values_after': after['Return multiple values'],
        'stage_drivers_and_introduced_constructs_unchanged': True,
        'stage_2': after_drivers['2'], 'broad_stage_issue_11_must_remain_open': True,
        'original_attribution': {key: task[key] for key in provenance},
        'historical_pending_assessment_unchanged': True,
        'changed_proposal_paths': original_paths,
        'sample_source_bytes': len(source), 'sample_source_sha256': digest(source),
        'expected_stdout_bytes': len(expected), 'expected_stdout_sha256': digest(expected),
        'exact_input_pairs_checked': 40401,
        'generated_file_count': len(generated_inventory),
        'generated_inventory_sha256': digest(json.dumps(generated_inventory, sort_keys=True, separators=(',', ':')).encode()),
        'result': 'all controls passed',
    }
    (OUT / 'generated-file-hashes.json').write_text(json.dumps(generated_inventory, indent=2) + '\n')
    (OUT / 'controls.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ['result', 'generated_file_count',
                                                 'generated_inventory_sha256',
                                                 'changed_task_assessments', 'entered_stage_1']}))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Independent #219 overlay audit; never imports or runs an old checker."""
import hashlib
import importlib.util
import inspect
import json
import platform
import re
import subprocess
import tarfile
import time
from copy import deepcopy
from pathlib import Path
from xml.etree import ElementTree as ET

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = ROOT / 'docs/evidence/retained-fixed-report-composition-20261024/gpr-baseline'
FIX = BASE / 'repair-f1'
AUTHOR = 'c7f0191bb8de07a1ebe2988c35f5a8f66ef89f58'
INITIAL = '17569ceaa8daf41892852cc4ab8b423b28d9091e'
REVIEW = 'ad92df5c3658b7495f1747226cde54a0dadc3f20'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def calls(text):
    # Consume strings/comments first, so their semicolons/words cannot be calls.
    clean = re.sub(r'"(?:""|[^"])*"|--[^\n]*', ' ', text).lower()
    selectors = re.findall(r'(?<!end )\bcase\s+([a-z][a-z0-9_]*)\s+is\b', clean)
    rhs = []
    for statement in clean.split(';'):
        op = re.search(r'\buse\b|:=', statement)
        if op:
            expression = statement[op.end():]
            assert '.' not in expression  # selected prefix names have one part
            refs = re.findall(r"[a-z][a-z0-9_]*(?:\s*'\s*[a-z][a-z0-9_]*)?", expression)
            rhs.extend(re.sub(r'\s+', '', ref) for ref in refs if ref != 'at')
    return rhs, selectors


def main():
    start = time.monotonic()
    changed = git('diff-tree', '--no-commit-id', '--name-only', '-r', AUTHOR).decode().splitlines()
    assert len(changed) == 10
    changed_pins = {}
    for path in changed:
        raw = (ROOT / path).read_bytes()
        assert raw == git('show', f'{AUTHOR}:{path}')
        changed_pins[path] = sha(raw)
    # The original author packet and initial independent review remain immutable.
    preserved = {}
    for commit, paths in [(INITIAL, [str(BASE.relative_to(ROOT))]),
                          (REVIEW, ['docs/evidence/review-gpr-baseline-20261024',
                                    'docs/reviews/review-gpr-baseline-20261024.md'])]:
        names = git('ls-tree', '-r', '--name-only', commit, '--', *paths).decode().splitlines()
        for path in names:
            raw = (ROOT / path).read_bytes()
            assert raw == git('show', f'{commit}:{path}')
            preserved[path] = sha(raw)
    assert len(preserved) == 24
    research = 'docs/research/retained-fixed-report-composition.md'
    assert (ROOT / research).read_bytes().startswith(git('show', f'{AUTHOR}^:{research}'))
    manifest = json.loads((FIX / 'source-manifest.json').read_text())
    assert len(manifest['providers']) == 13
    for path, pin in manifest['providers'].items():
        assert sha((ROOT / path).read_bytes()) == pin
    with tarfile.open(ROOT / manifest['gpr_archive']) as tf:
        sources = {}
        for name, pin in manifest['selected_sources'].items():
            data = tf.extractfile(name).read()
            assert sha(data) == pin['sha256'] and len(data) == pin['bytes']
            sources[name.rsplit('/', 1)[-1]] = data.decode().splitlines()
    dect, strt = sources['gpr-dect.adb'], sources['gpr-strt.adb']
    # Retained case-selector route and ordinary RHS route both enter the reset.
    assert 'Parse_Variable_Reference' in dect[888]
    assert 'Allow_Attribute => False' in dect[894]
    assert 'when Tok_Identifier =>' in strt[1591]
    assert 'Parse_Variable_Reference' in strt[1637]
    assert strt[845].strip() == 'Names.Init;'
    assert 'Add_To_Names (NL => (Name => Token_Name, Location => Token_Ptr))' in strt[855]
    assert strt[857].strip() == 'exit when Token /= Tok_Dot;'
    assert strt[164].strip() == 'Names.Increment_Last;'
    receipt = json.loads((FIX / 'result.json').read_text())
    handoff = json.loads((FIX / 'handoff.json').read_text())
    assert receipt['capacity_sha256'] == sha((FIX / 'capacity.py').read_bytes())
    assert receipt['retained_baseline_sha256'] == sha((BASE / 'result.json').read_bytes())
    # Read only the previously accepted fragment. Do not run selection.
    with tarfile.open(ROOT / manifest['config_archive']) as tf:
        xml = tf.extractfile('db/gnat.xml').read()
    fragment = ET.fromstring(xml).findall('configuration')[13].findtext('config')
    assert sha(xml) == receipt['selected_XML_sha256']
    assert sha(fragment.encode()) == receipt['selected_fragment_sha256']
    expected_rts = ["compiler'leading_required_switches", "binder'required_switches"]
    assert calls(fragment) == (expected_rts, [])
    assert fragment.count('--RTS=${RUNTIME_DIR(ada)}') == 2
    expected_rhs = ['gcc_no_pie', "compiler'leading_required_switches",
                    "binder'required_switches", "linker'required_switches",
                    "compiler'driver", "clean'artifacts_in_object_dir"]
    assert calls((BASE / 'inputs/program.gpr').read_text()) == ([], [])
    spec = importlib.util.spec_from_file_location('reviewed_reset_overlay', FIX / 'capacity.py')
    overlay = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(overlay)
    fn = overlay.effective_prefix
    assert all(p.default is inspect.Parameter.empty for p in inspect.signature(fn).parameters.values())
    original = json.loads((BASE / 'result.json').read_text())
    phase_receipts = {}
    for phase, prefix in original['phases'].items():
        rhs, selectors = calls((BASE / f'inputs/{phase}-before-extra-clauses.gpr').read_text())
        assert rhs == expected_rhs and selectors == ['gcc_prefix']
        before = deepcopy(prefix)
        fixed = fn(prefix, len(expected_rts))
        assert prefix == before and prefix['reference_prefix_reset_events_upper'] == 6
        assert fixed['reference_prefix_reset_events_upper'] == 7
        assert fixed['reference_prefix_singleton_push_events_upper'] == 7
        events = fixed['reference_prefix_events']
        assert events == receipt['effective_exports'][phase] == handoff['effective_exports'][phase]
        assert (events['baseline_rhs_reference_calls'], events['baseline_case_selector_calls'],
                events['baseline_reset_events_upper'], events['baseline_singleton_push_events_upper'],
                events['added_RTS_reference_calls'], events['prospective_reset_events_upper'],
                events['prospective_singleton_push_events_upper'], events['selected_peak_entries'],
                events['backing_bytes']) == (6, 1, 7, 7, 2, 9, 9, 1, 672)
        assert events['complete_allocator_event_join_closed'] is False
        expected_keys = set(prefix) | {'reference_prefix_singleton_push_events_upper', 'reference_prefix_events'}
        assert set(fixed) == expected_keys
        for key, value in prefix.items():
            if key != 'reference_prefix_reset_events_upper':
                assert fixed[key] == value
        assert fn(fixed, 2) == fixed
        assert fn(prefix, 0)['reference_prefix_events']['prospective_reset_events_upper'] == 7
        for invalid in (-1, True, 2.0):
            try:
                fn(prefix, invalid)
            except AssertionError:
                pass
            else:
                raise AssertionError(('invalid explicit contribution accepted', invalid))
        try:
            fn(prefix)
        except TypeError:
            pass
        else:
            raise AssertionError('missing RTS operand accepted')
        # Check the deep copy guarantee, without modifying the retained input.
        detached = fn(prefix, 2)
        detached['gross_shared_table_bounds']['Reference_Prefix']['bytes'] = -1
        assert prefix == before
        phase_receipts[phase] = dict(rhs_reference_names=rhs, case_selector_names=selectors,
                                     effective_events=events, all_other_coordinates_unchanged=True)
    assert handoff['complete_producer_configuration_capacity_closed'] is False
    assert handoff['production_or_admission_changed'] is False and handoff['physical_premises_unchanged']
    assert (handoff['report_P'], handoff['e_upper'], handoff['save_entering_callbacks_upper'],
            handoff['saves_upper']) == (188, 2, 2, 3)
    result = dict(reviewed_commit=AUTHOR, initial_review=REVIEW, disposition='accept_F1_219_repair',
                  platform=platform.system() + ' ' + platform.machine(), input_sha256=changed_pins,
                  preserved_original_files_sha256=preserved, providers=13, complete_GPR_sources=2,
                  accepted_XML_fragment='db/gnat.xml configuration[13], zero-based; selection reused',
                  added_RTS_reference_names=expected_rts, phases=phase_receipts,
                  material_findings=[], author_or_old_checker_runs=0, baseline_or_selector_replays=0,
                  native_compiler_prover_Lean_capture_service_runs=0, runtime_corpus_rescans=0,
                  elapsed_seconds=round(time.monotonic() - start, 6))
    (HERE / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
    print(json.dumps({k: result[k] for k in ('reviewed_commit', 'disposition', 'providers',
                                           'complete_GPR_sources', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()

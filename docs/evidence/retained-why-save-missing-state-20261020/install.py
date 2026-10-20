#!/usr/bin/env python3
"""Install the observer extension in a lead-prepared, unrun relocated harness.

This does not edit plan.json, run a target, or overwrite historical captures.
The lead applies plan-additions.json before the existing runner is used.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import missing_state

HERE = Path(__file__).resolve().parent


def identity(p):
    b = p.read_bytes()
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}


def install(root):
    root = root.resolve()
    plan = json.loads((root/'plan.json').read_text())
    inline = root.name == 'why-session-save-capture-ready-20261020'
    assert inline or root.name == 'wse-20261020', 'use the coordinated fresh roots'
    assert len(plan['inputs']) == (1 if inline else 4)
    if not inline:
        assert plan['endpoint']['symbol'] == 'camlGnat_checks__iter_2373'
    assert all(not (Path(c['cwd'])/'capture').exists() for c in plan['inputs']), 'already-run harness'
    target = root/'missing_state.py'
    assert not target.exists(), 'extension already present'
    probe = root/('gdb_adapter.py' if inline else 'probe.py')
    text = probe.read_text()
    anchor = "        helpers=session.capture_helpers();assert helpers['complete'],helpers\n"
    if inline:
        anchor = '        helpers = _session_capture.capture_helpers()\n'
    assert text.count(anchor)==1, 'unexpected accepted observer integration'
    insertion = """        _missing_spec=importlib.util.spec_from_file_location('save_missing_state',ROOT/'missing_state.py')
        _missing_module=importlib.util.module_from_spec(_missing_spec);_missing_spec.loader.exec_module(_missing_module)
        _missing=_missing_module.collect(session,PLAN,'pre-scheduling registration; before driver preparation')
        SUMMARY['save_missing_state']={'complete':_missing['complete'],'identity':identity(OUT/'save-missing-state.json')}
        assert _missing['complete'],_missing['failures']
"""
    if inline:
        insertion = insertion.replace('importlib.util', '_session_import').replace('collect(session,PLAN,', 'collect(_session_capture,PLAN,').replace('pre-scheduling registration; before driver preparation', 'first cvc5 inline entry')
    old = identity(probe)
    shutil.copyfile(HERE/'missing_state.py', target)
    probe.write_text(text.replace(anchor, anchor+insertion))
    additions = {'session_observer_symbols': missing_state.SYMBOLS,
                 'file_identities': {str(p): identity(p) for p in [probe, target]},
                 'inherited_probe_before_extension': old,
                 'instructions': 'Merge symbols into session_observer.symbols and these two file_identities; preserve all other plan fields and guards. Review the separate source-layout.json witnesses.'}
    (root/'plan-additions.json').write_text(json.dumps(additions, indent=2)+'\n')
    return additions


if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--root', type=Path, required=True)
    print(json.dumps(install(p.parse_args().root), indent=2))

#!/usr/bin/env python3
"""Only #219 changed-count/source/interface verification; no old checker import."""
import hashlib
import json
from pathlib import Path
import platform
import re
import tarfile
import time
from xml.etree import ElementTree as ET
import capacity

HERE = Path(__file__).resolve().parent
BASE = HERE.parent
REPO = HERE.parents[4]


def sha(data):
    return hashlib.sha256(data).hexdigest()


def count_reference_calls(data):
    """Count this fixed syntax's references independently of the old reader."""
    lexemes = re.findall(r'--[^\n]*|"(?:[^"]|"")*"|[A-Za-z][A-Za-z0-9_]*|[0-9]+|:=|=>|[^\s]', data)
    tokens = []
    for token in lexemes:
        if token.startswith('--'):
            continue
        tokens.append('@string' if token.startswith('"') else token.lower())
    selectors = sum(token == 'case' and (i == 0 or tokens[i - 1] != 'end')
                    for i, token in enumerate(tokens))
    rhs = 0
    statement = []
    for token in tokens:
        if token != ';':
            statement.append(token)
            continue
        operation = next((i for i, t in enumerate(statement) if t in ('use', ':=')), None)
        if operation is not None:
            expression = statement[operation + 1:]
            assert '.' not in expression  # every selected prefix is a singleton
            for i, term in enumerate(expression):
                if re.fullmatch(r'[a-z][a-z0-9_]*', term) and term != 'at':
                    if i == 0 or expression[i - 1] != "'":
                        rhs += 1
        statement = []
    return rhs, selectors


def main():
    started = time.monotonic()
    manifest = json.loads((HERE / 'source-manifest.json').read_text())
    for name, digest in manifest['providers'].items():
        assert sha((REPO / name).read_bytes()) == digest, name
    archive = REPO / manifest['gpr_archive']
    with tarfile.open(archive) as source_archive:
        sources = {}
        for name, pin in manifest['selected_sources'].items():
            raw = source_archive.extractfile(name).read()
            assert sha(raw) == pin['sha256'] and len(raw) == pin['bytes']
            sources[name.rsplit('/', 1)[-1]] = raw.decode()
    dect = sources['gpr-dect.adb'].splitlines()
    strt = sources['gpr-strt.adb'].splitlines()
    assert 'Parse_Variable_Reference' in dect[888]
    assert 'Allow_Attribute => False' in dect[894]
    assert strt[845].strip() == 'Names.Init;'
    assert 'Add_To_Names' in strt[855]
    assert 'exit when Token /= Tok_Dot;' in strt[857]
    # Read only the already accepted added fragment, without rerunning selection.
    with tarfile.open(REPO / manifest['config_archive']) as config_archive:
        gnat_xml = config_archive.extractfile('db/gnat.xml').read()
    fragment = ET.fromstring(gnat_xml).findall('configuration')[13].findtext('config')
    assert fragment.count('--RTS=${RUNTIME_DIR(ada)}') == 2
    assert count_reference_calls(fragment) == (2, 0)
    baseline = json.loads((BASE / 'result.json').read_text())
    user_calls = count_reference_calls((BASE / 'inputs/program.gpr').read_text())
    assert user_calls == (0, 0)
    exports = {}
    for phase, original in baseline['phases'].items():
        config_calls = count_reference_calls((BASE / 'inputs' / f'{phase}-before-extra-clauses.gpr').read_text())
        assert config_calls == (6, 1)
        assert original['reference_prefix_reset_events_upper'] == 6  # retained F1
        old_bytes = json.dumps(original, sort_keys=True)
        fixed = capacity.effective_prefix(original, 2)
        assert json.dumps(original, sort_keys=True) == old_bytes
        assert fixed['reference_prefix_reset_events_upper'] == 7
        assert fixed['reference_prefix_singleton_push_events_upper'] == 7
        events = fixed['reference_prefix_events']
        assert events['prospective_reset_events_upper'] == 9
        assert events['prospective_singleton_push_events_upper'] == 9
        assert events['selected_peak_entries'] == 1 and events['backing_bytes'] == 672
        # Every original coordinate except the defective event field is identical.
        for key, value in original.items():
            if key != 'reference_prefix_reset_events_upper':
                assert fixed[key] == value, (phase, key)
        assert fixed['gross_shared_table_bounds']['Reference_Prefix']['demand'] == 1
        assert not fixed['complete_GPR_process_capacity_closed']
        assert capacity.effective_prefix(fixed, 2) == fixed  # stable effective overlay
        exports[phase] = events
    try:
        capacity.effective_prefix(baseline['phases']['translation'])
    except TypeError:
        pass
    else:
        raise AssertionError('RTS contribution must be explicit')
    receipt = {
        'scope': '#219 scratch reset/singleton-push count repair only',
        'platform': platform.system() + ' ' + platform.machine(),
        'author': manifest['original_author'],
        'review': manifest['review'],
        'providers_checked': len(manifest['providers']),
        'complete_selected_sources_checked': len(sources),
        'capacity_sha256': sha((HERE / 'capacity.py').read_bytes()),
        'retained_baseline_sha256': sha((BASE / 'result.json').read_bytes()),
        'selected_XML_fragment': 'db/gnat.xml configuration[13], zero-based',
        'selected_XML_sha256': sha(gnat_xml),
        'selected_fragment_sha256': sha(fragment.encode()),
        'effective_exports': exports,
        'original_input_not_mutated': True,
        'all_other_original_prefix_coordinates_unchanged': True,
        'auxiliary_backing_receipt_unchanged': True,
        'baseline_or_selection_replays': 0,
        'native_prover_Lean_or_service_runs': 0,
        'complete_producer_configuration_capacity_closed': False,
        'passed': True,
        'elapsed_seconds': round(time.monotonic() - started, 6),
    }
    (HERE / 'result.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({k: receipt[k] for k in ('passed', 'providers_checked', 'complete_selected_sources_checked', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()

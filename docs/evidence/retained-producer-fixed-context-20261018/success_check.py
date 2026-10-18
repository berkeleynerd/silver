"""Reconcile retained successful fixed inputs; never launches a native tool."""

import collections
import hashlib
import json
import re
import tarfile
import xml.etree.ElementTree as ET
from pathlib import Path


def digest(data):
    return hashlib.sha256(data).hexdigest()


def check_success(here, prior, context_identity, sources):
    identity = json.loads((here / 'success-identity.json').read_text())
    archive = here / 'success-witness.tar.gz'
    assert digest(archive.read_bytes()) == identity['archive_sha256']
    with tarfile.open(archive) as tar:
        assert sorted(tar.getnames()) == sorted(r['path'] for r in identity['files'])
        files = {}
        for row in identity['files']:
            data = tar.extractfile(row['path']).read()
            assert len(data) == row['bytes'] and digest(data) == row['sha256']
            files[row['path']] = data

    validation = json.loads((prior / identity['managed_record']).read_text())
    run = validation['runs'][identity['managed_record_key']]
    assert run['run_id'] == identity['managed_run'] and run['state'] == 'success'
    for leaf in ('native.log', 'events.jsonl'):
        row = next(r for r in run['artifacts'] if r['path'].endswith('/' + leaf))
        data = files['managed/' + leaf]
        assert len(data) == row['bytes'] and digest(data) == row['sha256']
    events = [json.loads(line) for line in files['managed/events.jsonl'].splitlines()]
    assert {e['run_id'] for e in events} == {identity['managed_run']}
    assert events[-1]['event'] == 'finished' and events[-1]['outcome'] == 'success'
    prepared = next(e for e in events if e['event'] == 'prepared')
    inputs = prepared['inputs']['inputs_sha256']
    root = identity['workspace'].split('/.silver/', 1)[0]
    assert digest(files['executed-source/silver.adb']) == inputs[root + '/src/silver.adb']
    assert b'--steps=100000 --timeout=0 --memlimit=1000' in files['executed-source/silver.adb']
    assert not any('gnatwhy3' in p for p in inputs), 'reassess historical tool-identity limit'

    fixed_sources = ['silver_io.ads', 'silver_io.adb', 'silver_output_libc.ads',
                     'silver_arguments.ads', 'silver_arguments.adb', 'silver_runtime.ads']
    for name in fixed_sources:
        data = files['workspace/' + name]
        assert data == (prior / 'src' / name).read_bytes()
        assert digest(data) == inputs[root + '/src/' + name]

    managed = files['managed/native.log']
    local = files['workspace/mutable-integers-test.log']
    assert local in managed
    assert b'Success: all checks proved (71 checks).' in local
    for prefix, suffix in [('Summary logged in ', '/obj/gnatprove/gnatprove.out'),
                           ('Source: ', '/main.adb'), ('Executable: ', '/bin/main')]:
        assert (prefix + identity['workspace'] + suffix).encode() in local

    sessions = {}
    with tarfile.open(prior / context_identity['fixed_archive']['path']) as tar:
        for row in context_identity['fixed_inputs']:
            name = Path(row['path']).name
            data = files['workspace/obj/gnatprove/' + name]
            assert data == tar.extractfile(row['path']).read()
            assert len(data) == row['bytes'] and digest(data) == row['sha256']
            stem = name.removesuffix('.gnat-json')
            xml = ET.fromstring(files[f'workspace/obj/gnatprove/{stem}/why3session.xml'])
            file_nodes = xml.findall('file')
            assert len(file_nodes) == 1
            node = file_nodes[0]
            assert node.attrib == {'format': 'gnat-json', 'proved': 'true'}
            assert [p.attrib['name'] for p in node.findall('path')] == ['..', name]
            assert all(t.attrib['proved'] == 'true' for t in node.findall('theory'))
            statuses = collections.Counter(p.attrib['status'] for p in xml.findall('.//result'))
            assert statuses['valid'] > 0
            sessions[row['name']] = {
                'bytes': len(data), 'sha256': digest(data), 'byte_equal_to_fixed_capture': True,
                'file_proved': True, 'proof_attempt_results': dict(sorted(statuses.items())),
                'provers': [p.attrib for p in xml.findall('prover')],
            }

    proof_records = {}
    for name, expected in [('silver_io', 36), ('silver_arguments', 11)]:
        spark = json.loads(files[f'workspace/obj/gnatprove/{name}.spark'])
        assert len(spark['proof']) == expected
        assert all(p['severity'] == 'info' and 'proved' in p['message']['text']
                   for p in spark['proof'])
        counts = collections.Counter(spark['entities'][f" {p['entity']}"]['name']
                                     for p in spark['proof'])
        proof_records.update(dict(sorted(counts.items())))
    assert proof_records == {'Silver_Arguments.First_Or_Default': 9,
                             'Silver_Arguments.Input_Is_Valid': 1,
                             'Silver_Arguments.Is_Message': 1,
                             'Silver_IO.Put': 16, 'Silver_IO.Put_Line': 20}
    summary = files['workspace/obj/gnatprove/gnatprove.out'].decode()
    for entity, count in proof_records.items():
        assert re.search(re.escape(entity) + r' at .* and proved \(' + str(count) + r' checks\)', summary)

    # Source anchors support the written control/read projection. They do not
    # turn this offline reconciliation into an execution or a type checker.
    checks = sources['why3/src/gnat/gnat_checks.ml'].decode()
    assert 'Controller_itp.add_file c Gnat_config.filename' in checks
    assert 'Controller_itp.reload_files ~ignore_shapes:false c' in checks
    controller = sources['why3/src/session/controller_itp.ml'].decode()
    assert 'load_drivers c;\n  c' in controller
    assert 'Session_itp.read_file c.controller_env ~format fname' in controller
    session = sources['why3/src/session/session_itp.ml'].decode()
    assert 'fst (read_file env file_name ~format)' in session
    assert 'Env.read_file Env.base_language env ?format fn' in session
    weak = sources['why3/src/util/weakhtbl.ml'].decode()
    assert 'let dummy_tag = -1' in weak
    assert 'assert (k != dummy_tag)' in weak
    assert 'let equal k1 k2 = S.tag k1 == S.tag k2' in weak

    return {
        'scope': 'retained successful fixed ordinary inputs; no new native execution',
        'managed_run': identity['managed_run'], 'workspace': identity['workspace'],
        'byte_equal_inputs': sessions, 'current_library_source_files_equal': len(fixed_sources),
        'fixed_library_proof_records': proof_records, 'fixed_library_proof_record_total': 47,
        'local_log_is_exact_substring_of_managed_log': True,
        'historical_gnatwhy3_executable_hash_captured_by_test_run': False,
        'exact_counter_history_or_aggregate_heap_bound_claimed': False,
    }

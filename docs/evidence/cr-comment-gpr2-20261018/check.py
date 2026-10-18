#!/usr/bin/env python3
"""Replay retained identities and observations; no native tool execution."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent


def main():
    identity = json.loads((HERE/'identity.json').read_text())
    for row in identity['files']:
        data = (HERE/row['path']).read_bytes()
        assert len(data) == row['bytes'], row['path']
        assert hashlib.sha256(data).hexdigest() == row['sha256'], row['path']
    probe = HERE/'probe'
    lf = (probe/'lf/main.adb').read_bytes()
    cr = (probe/'cr/main.adb').read_bytes()
    assert cr.replace(b'\r', b'\n') == lf and cr.count(b'\r') == 1
    assert cr == (probe/'naming-body/main.adb').read_bytes()
    assert cr == (probe/'naming-body-indexed/main.adb').read_bytes()
    rows = json.loads((probe/'result.json').read_text())['runs']
    assert [r['returncode'] for r in rows] == [0, 0, 0, 1]
    assert rows[0]['stdout'] == rows[2]['stdout'] == 'Accepted: silver.\n'
    assert 'SPARK_MODE' in rows[3]['stderr']
    endtoend = json.loads((probe/'endtoend.json').read_text())
    assert endtoend['returncode'] == 3
    assert 'Verification failure for admitted Silver' in endtoend['stdout']
    unindexed = json.loads((probe/'candidate.json').read_text())
    indexed = json.loads((probe/'candidate-indexed.json').read_text())
    assert unindexed['returncode'] == indexed['returncode'] == 0
    assert 'SPARK_MODE' in unindexed['stderr'] and indexed['stderr'] == ''
    native = json.loads((probe/'candidate-native-indexed.json').read_text())
    assert [r['returncode'] for r in native['runs']] == [0, 0]
    assert native['runs'][1]['stdout'] == native['runs'][1]['stderr'] == ''
    phase = probe/'naming-body-indexed/obj/explore/cr-comment/gnatprove'
    ali = (phase/'phase1/main~1.ali').read_text()
    switches = [line[2:] for line in ali.splitlines() if line.startswith('A ')]
    assert len(switches) == 9 and sum(map(len, switches)) == 53
    assert max(map(len, switches)) == 9 and switches[-1] == '-gnateI1'
    assert len([line for line in ali.splitlines() if line.startswith('D ')]) == 2
    report = json.loads((phase/'main~1.spark').read_text())
    assert report['entities'][' 1']['name'] == 'Main'
    assert report['entities'][' 1']['sloc'][0]['file'] == 'main.adb'
    archive = HERE/'gpr-96e4283834e3c56d51f986c059770be48efaf22a.tar.gz'
    with tarfile.open(archive) as t:
        prefix = 'gpr-96e4283834e3c56d51f986c059770be48efaf22a/'
        lexer = t.extractfile(prefix+'langkit/gen/src/gpr_parser-lexer_state_machine.adb').read().decode()
        caller = t.extractfile(prefix+'src/private/gpr2-build-view_tables-update_sources_list.adb').read().decode()
        assert "Character_Type'Val (16#b#) .. Character_Type'Val (16#10ffff#) => goto State_75;" in lexer
        assert 'and then not Units.Is_Indexed_List' in caller
        assert 'The source will be ignored.' in caller
    print(json.dumps({'identity_files':len(identity['files']),
                      'managed_runs':identity['run_ids'],
                      'installed_defect_confirmed':True,
                      'indexed_candidate_proof_build_execution_passed':True,
                      'production_fix_delivered':False}, indent=2))


if __name__ == '__main__':
    main()

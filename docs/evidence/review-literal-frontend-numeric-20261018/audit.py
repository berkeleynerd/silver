#!/usr/bin/env python3
"""Narrow frozen-input and finding audit; no model/suite/native execution."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

FRONT = 'd7034d952050df0e015958158131b6ccc2e70f64'
NUMERIC = '64237926eb736cf8d675d5609ff4b4cca8e59efc'
ATTACHMENT = 'b9b3ef960e'
E = 'docs/evidence/'
FP = E+'retained-literal-frontend-storage-20261018/'
NP = E+'retained-literal-ada-numeric-20261018/'
AP = E+'retained-literal-pipeline-20261018/'


def ident(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    start = time.perf_counter()
    started = datetime.now(timezone.utc).isoformat()
    checked = []
    identities = {}

    def blob(commit, path):
        raw = subprocess.check_output(['git', 'show', commit+':'+path])
        identities[commit+':'+path] = ident(raw)
        return raw

    def check(label, condition):
        if not condition:
            raise AssertionError(label)
        checked.append(label)

    front = json.loads(blob(FRONT, FP+'result.json'))
    check('frontend carries exact corrected numeric implementation',
          blob(FRONT, NP+'compose.py') == blob(NUMERIC, NP+'compose.py'))
    manifest = json.loads(blob(ATTACHMENT, AP+'selected-route-inputs.json'))
    changed_numeric = [row for row in manifest['files'] if
                       row['path'].startswith(NP) or row['path'].endswith('/retained-literal-ada-numeric.md')]
    check('attachment corrected numeric pins equal frozen numeric objects',
          all(ident(blob(NUMERIC, row['path'])) == {k:row[k] for k in ('bytes','sha256')}
              for row in changed_numeric))
    check('historical review explicitly scoped', manifest['numeric_freeze'] == '64237926eb'
          and 'Historical acceptance of 3a7d590389' in manifest['original_numeric_review_scope'])
    before = json.loads(blob('64237926eb', AP+'selected-route-result.json'))
    after = json.loads(blob(ATTACHMENT, AP+'selected-route-result.json'))
    numeric_key = next(k for k in after if isinstance(after[k], dict)
                       and after[k].get('demands') == front['numeric_lifetime_projection'])
    check('Hello numeric projection byte-equivalent as JSON data', before[numeric_key] == after[numeric_key])
    check('Hello all 48 conditions unchanged', len(after['conditions']) == 48
          and before['conditions'] == after['conditions'])
    evidence = json.loads(blob(ATTACHMENT, AP+'selected-route-check-results.json'))
    cases = next(v for v in evidence.values() if isinstance(v, list)
                 and any(isinstance(x, dict) and x.get('name') == '32766_calls' for x in v))
    transition = next(x for x in cases if x.get('name') == '32766_calls')
    raw = (b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
           + b'Silver_IO.Put ("x");\n'*32766 + b'\nend Main;\n')
    check('transition evidence names actual 32766-call source', transition['source'] == ident(raw))
    check('transition numeric demands and separate linker failure retained',
          transition['demands'] == dict(Uints=28420+9*32766, Udigits=107726+72*32766,
                                       Ureals=67, Rep_Table=504)
          and transition['failed_predicates'] == ['literal_output_linker_representation'])
    check('Hello callback lifetime replacement and separate Rep table',
          front['numeric_base_projection'] == dict(Uints=24331, Udigits=75019, Ureals=60)
          and front['numeric_lifetime_projection'] == dict(Uints=28429, Udigits=107797, Ureals=67, Rep_Table=504)
          and front['joined_logical_tables']['Uint_entries'] == 28429
          and 'Rep_Table' not in front['joined_logical_tables'])
    physical = front['components']['physical_sources']
    check('permanent/transient and filename populations distinguished',
          physical['permanent_source_entries_upper'] == 1589
          and physical['Source_File_backing_demand'] == 1590
          and physical['backend_File_Info_entries_upper'] == 1589
          and physical['insertion_capable_filename_lookups_upper'] == 1590)
    pins = json.loads(blob(FRONT, FP+'inputs.json'))['files']
    source = {}
    for name in ('fname-uf.adb', 'frontend.adb', 'sinput-l.adb'):
        raw = (args.ada_root/name).read_bytes()
        pin = next(row for row in pins if row['root'] == 'ada' and row['path'] == name)
        check('finding source identity '+name, ident(raw) == {k:pin[k] for k in ('bytes','sha256')})
        source[name] = raw.decode()
        identities['ada:'+name] = ident(raw)
    fname = source['fname-uf.adb']
    init = fname[fname.index('procedure Initialize is'):fname.index('end Initialize;')]
    check('four allocations per default initialization', init.count("new String'") == 4)
    check('two selected initialization sites',
          'Fname.UF.Initialize;' in fname[fname.rindex('\nbegin'):]
          and 'Fname.UF.Initialize;' in source['frontend.adb'])
    check('frozen frontend exports config-only six as unqualified total',
          physical['pattern_String_allocations_upper'] == 6)
    check('virtual text sharing has separate descriptor allocation',
          "new Dope_Rec'(Snew.Source_First, Snew.Source_Last)" in source['sinput-l.adb'])
    result = dict(started_utc=started, completed_utc=datetime.now(timezone.utc).isoformat(),
                  elapsed_seconds=time.perf_counter()-start, checks=len(checked), passed=checked,
                  inputs=identities, native_tool_executions=0, retained_suites_repeated=False,
                  finding=dict(id='F1', frozen_export=6, default_initialization_requests=8,
                               configuration_requests=6, selected_lifetime_requests=14),
                  qualification='Source anchors plus manual reachability review; green checks are not a soundness proof.')
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('checks','elapsed_seconds','finding')}))


if __name__ == '__main__':
    main()

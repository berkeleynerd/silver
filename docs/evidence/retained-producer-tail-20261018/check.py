#!/usr/bin/env python3
"""Retain the source frontier for producer registration and output consumers.

Offline inventory only. The source reachability and process-boundary arguments
are in docs/research/retained-producer-tail.md; this is not an admission test.
"""
import argparse
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import tarfile


HERE = Path(__file__).resolve().parent
EVIDENCE = HERE.parent
ROOT = EVIDENCE.parent.parent
NAMES = ('Emit_Static_Proof_Result','Emit_Always_True_Range_Check','Register_VC',
         'New_VC_Labels','New_Shape_Label','New_Loc_Label')


def main():
    argparse.ArgumentParser(description=__doc__).parse_args()
    spec = importlib.util.spec_from_file_location('strings',EVIDENCE/
        'retained-producer-strings-20261018/check.py')
    strings = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(strings)
    source_path = EVIDENCE/'unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz'
    digest = hashlib.sha256(source_path.read_bytes()).hexdigest()
    assert digest == 'f2e7dd7bbef086a36ddf97f9bd3bd669ca895fcc28e3ac23ffe0c9f85fc5d952'
    with tarfile.open(source_path) as archive:
        files = {m.name:archive.extractfile(m).read().decode()
                 for m in archive.getmembers() if m.isfile()
                 and m.name.startswith('spark-source/src/')
                 and m.name.endswith(('.adb','.ads'))}
    assert len(files) == 279
    calls = []
    for path,source in sorted(files.items()):
        for position,name,actual in strings.scan_calls(source,NAMES):
            calls.append(dict(file=path.removeprefix('spark-source/'),
                line=source.count('\n',0,position)+1,name=name,
                actual=' '.join(actual.split())))
    counts = Counter(x['name'] for x in calls)
    assert counts['Register_VC'] == 2
    assert counts['New_VC_Labels'] == 3
    assert counts['New_Shape_Label'] == 1
    assert counts['New_Loc_Label'] == 1
    assert counts['Emit_Always_True_Range_Check'] == 2
    assert counts['Emit_Static_Proof_Result'] == 23
    libraries = ('silver_io.ads','silver_io.adb','silver_arguments.ads',
                 'silver_arguments.adb','silver_output_libc.ads','silver_runtime.ads')
    library_digests = {name:hashlib.sha256((ROOT/'src'/name).read_bytes()).hexdigest()
                       for name in libraries}
    result = dict(source_archive_sha256=digest,source_files=len(files),
                  calls_by_name=dict(sorted(counts.items())),calls=calls,
                  library_sha256=library_digests,
                  scope='source frontier; full process response/report bounds remain separate')
    (HERE/'inventory.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(source_files=len(files),calls_by_name=dict(counts))))


if __name__ == '__main__':
    main()

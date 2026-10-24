#!/usr/bin/env python3
"""Focused final source correspondence: absolute RTS is not renamed default.

No fixture, executable, service or predecessor check; read one retained archive.
"""
from pathlib import Path
import hashlib
import json
import tarfile
import time

start = time.monotonic()
here = Path(__file__).resolve().parent
root = here.parents[3]
manifest = json.loads((here/'source-manifest.json').read_text())
origin = manifest['sources']['gpr/gpr/src/gpr-conf.adb']['origin']
archive = root/origin['archive']
assert hashlib.sha256(archive.read_bytes()).hexdigest() == origin['archive_sha256']
member = 'gprbuild-bdfb879cf03643ec8e48a09ce07b08c4a6ff0263/gpr/src/gpr-knowledge.adb'
with tarfile.open(archive) as stream:
    data = stream.extractfile(member).read()
text = data.decode()
assert '''if Rts'Length > 0 and then Is_Absolute_Path (Rts) then
                        Compiler.Runtime := Get_String_No_Adalib (Rts);
                        Compiler.Runtime_Dir := Compiler.Runtime;''' in text
assert '''if El.Runtime_Dir /= No_Name then
                  Ncomp.Runtime_Dir := El.Runtime_Dir;
                  Ncomp.Runtime := El.Runtime;''' in text
result = dict(status='pass', question='Does an absolute RTS remain the XML runtime operand, or become default?',
    answer='The absolute argument sets Runtime and Runtime_Dir; the selected compiler copies both from the explicit filter.',
    archive=origin['archive'], archive_sha256=origin['archive_sha256'], member=member,
    complete_source_bytes=len(data), complete_source_sha256=hashlib.sha256(data).hexdigest(),
    source_loci=['gpr-conf.adb:1418-1420', 'gpr-knowledge.adb:3968-3973', 'gpr-knowledge.adb:4638-4645'],
    source_identity_premise_unchanged=True, target_executions=0, predecessor_replays=0,
    elapsed_seconds=time.monotonic()-start)
(here/'runtime-selection.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(result,indent=2))

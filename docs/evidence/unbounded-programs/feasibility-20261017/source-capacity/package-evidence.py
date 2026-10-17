#!/usr/bin/env python3
"""Package existing evidence only; never launches a compiler or modifies caches."""
from pathlib import Path
import gzip, hashlib, io, json, re, shutil, tarfile

SRC = Path('/tmp/silver-unbounded-feasibility-20261017/source-capacity')
DST = Path('/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/unbounded-planning-corrections/docs/evidence/unbounded-programs/feasibility-20261017/source-capacity')
COMMIT = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
if DST.exists():
    raise SystemExit('Refusing to overwrite packaged evidence')
DST.mkdir(parents=True)

fetched = {x['path']: x for x in json.loads((SRC/'upstream-fetches.json').read_text())['files']}
darwin = {x['path']: x for x in json.loads((SRC/'darwin-comparison.json').read_text())['files']}
sources = []
for p in sorted((SRC/'upstream').iterdir()):
    b = p.read_bytes()
    blob = hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
    record = {'path':p.name,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'git_blob_sha1':blob,'url':f'https://github.com/gcc-mirror/gcc/blob/{COMMIT}/gcc/ada/{p.name}','origin':'new exact-pin retrieval' if p.name in fetched else 'retained T3 source, copied unchanged'}
    if p.name in fetched:
        record['retrieved_git_blob_sha1']=fetched[p.name]['sha']
        if blob != fetched[p.name]['sha']:
            raise SystemExit(f'Fetched source hash mismatch: {p.name}')
    if p.name in darwin:
        record['darwin_recipe_source']=darwin[p.name]
    sources.append(record)
(DST/'source-manifest.json').write_text(json.dumps({'upstream_commit':COMMIT,'binary_attestation':False,'sources':sources},indent=2)+'\n')

# Preserve upstream copyright/license headers inside a compact immutable snapshot.
with (DST/'source-snapshots.tar.gz').open('wb') as raw:
    with gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as gz:
        with tarfile.open(fileobj=gz,mode='w') as tar:
            for p in sorted((SRC/'upstream').iterdir()):
                b=p.read_bytes();info=tarfile.TarInfo('upstream/'+p.name)
                info.size=len(b);info.mode=0o644;info.mtime=0
                tar.addfile(info,io.BytesIO(b))

for name in ['probe-source.py','package-evidence.py','probe-results.json','host-preflight.json','gcc-version.txt','trace-summary.json','upstream-fetches.json','darwin-comparison.json']:
    shutil.copyfile(SRC/name,DST/name)
shutil.copytree(SRC/'probes',DST/'probes')

facts={'status':'partial source-derived arithmetic, not observed native boundaries', 'source_position_sufficient_max_final_hi':2**31-1-4096, 'string_chars':{'initial':2500,'increment_percent':150,'table_factor':1,'valid_length_sequence':[]}, 'zero_decimal_exponent_799999_udigits':177170}
n=2500
while n<=2**31-1:
    facts['string_chars']['valid_length_sequence'].append(n)
    n=n*250//100
facts['string_chars']['first_unrepresentable_next_length']=n
(DST/'derived-arithmetic.json').write_text(json.dumps(facts,indent=2)+'\n')

manifest=[]
for p in sorted(DST.rglob('*')):
    if p.is_file():
        b=p.read_bytes();manifest.append({'path':str(p.relative_to(DST)),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()})
(DST/'MANIFEST.json').write_text(json.dumps({'status':'partial research handoff; no new membership adopted','files':manifest},indent=2)+'\n')
print(json.dumps({'destination':str(DST),'files':len(manifest),'bytes':sum(x['bytes'] for x in manifest),'source_files':len(sources)},indent=2))

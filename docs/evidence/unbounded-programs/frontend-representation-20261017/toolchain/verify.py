"""Verify packaged #113 evidence offline; does not attest installed tools."""
import hashlib
import io
import json
from pathlib import Path
import tarfile

root = Path(__file__).resolve().parent
manifest = json.loads((root / 'MANIFEST.json').read_text())

def check(data, entry):
    assert len(data) == entry['bytes'], entry['path']
    assert hashlib.sha256(data).hexdigest() == entry['sha256'], entry['path']

def blob(data):
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()

for entry in manifest['files']:
    check((root / entry['path']).read_bytes(), entry)
with tarfile.open(fileobj=io.BytesIO((root / 'raw-evidence.tar.gz').read_bytes()), mode='r:gz') as archive:
    raw = {entry.name: archive.extractfile(entry).read() for entry in archive if entry.isfile()}
assert set(raw) == {e['path'] for e in manifest['archive_members']}
for entry in manifest['archive_members']:
    check(raw[entry['path']], entry)
spark = json.loads(raw['spark-source-manifest.json'])
tree = json.loads(raw['spark-fsf16-tree.json'])
assert not tree['truncated']
tree_blobs = {e['path']: e['sha'] for e in tree['tree'] if e['type'] == 'blob'}
for entry in spark['files']:
    data = raw['spark-source/' + entry['path']]
    check(data, entry)
    assert blob(data) == entry['git_blob'] == tree_blobs[entry['path']]
contents = 0
for name, data in raw.items():
    if name.endswith('.source'):
        response = json.loads(raw[name.removesuffix('.source') + '.json'])
        assert blob(data) == response['sha'], name
        contents += 1
retrievals = 0
for name, data in raw.items():
    if name.endswith('.retrieval.json'):
        record = json.loads(data)
        payload = raw[name.removesuffix('.retrieval.json') + '.json']
        assert len(payload) == record['bytes'], name
        assert hashlib.sha256(payload).hexdigest() == record['sha256'], name
        retrievals += 1
print(json.dumps({'status': 'pass', 'archive_members': len(raw),
                  'spark_git_blobs': len(spark['files']), 'contents_git_blobs': contents,
                  'api_retrievals': retrievals, 'scope': 'Offline integrity; not binary attestation'}, indent=2))

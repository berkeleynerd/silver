"""Package the retained #113 source/API inspection; no network or tool runs."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

parser = argparse.ArgumentParser()
parser.add_argument('raw', type=Path)
args = parser.parse_args()
out = Path(__file__).resolve().parent
members = []
with (out / 'raw-evidence.tar.gz').open('wb') as target:
    with gzip.GzipFile(fileobj=target, mode='wb', filename='', mtime=0) as zipped:
        with tarfile.open(fileobj=zipped, mode='w') as archive:
            for path in sorted(args.raw.rglob('*')):
                if not path.is_file() or path.name == 'spark-fsf16.tar.gz':
                    continue
                name = path.relative_to(args.raw).as_posix()
                data = path.read_bytes()
                info = tarfile.TarInfo(name)
                info.size = len(data)
                info.mode = 0o644
                archive.addfile(info, io.BytesIO(data))
                members.append({'path': name, 'bytes': len(data),
                                'sha256': hashlib.sha256(data).hexdigest()})
files = []
for path in sorted(out.iterdir()):
    if path.is_file() and path.name not in ('MANIFEST.json', 'verification.json'):
        data = path.read_bytes()
        files.append({'path': path.name, 'bytes': len(data),
                      'sha256': hashlib.sha256(data).hexdigest()})
record = {'scope': 'Source/package inspection, no compiler or proof execution',
          'raw_scratch': str(args.raw.resolve()), 'archive_members': members,
          'files': files}
(out / 'MANIFEST.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps({'members': len(members), 'bytes': sum(e['bytes'] for e in members),
                  'archive_bytes': (out / 'raw-evidence.tar.gz').stat().st_size}))

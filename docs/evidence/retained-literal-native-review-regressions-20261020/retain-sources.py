#!/usr/bin/env python3
"""Retain two already pinned GCC files from an existing local source mirror.

No download or installed-tool mutation. The tar/gzip bytes are deterministic.
"""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
NATIVE = Path('docs/evidence/unbounded-programs/retained-native-expansion-20261017')


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path, required=True)
    args = parser.parse_args()
    references = [NATIVE / name for name in ('static-lifecycle-inputs.json',
        'rtl-helpers-source-identity.json', 'rtl-emission-source-identity.json')]
    manifests = {str(path): json.loads((REPO / path).read_bytes()) for path in references}
    revision = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
    assert manifests[str(references[1])]['commit'] == revision
    assert manifests[str(references[2])]['commit'] == revision
    files = []
    tar_bytes = io.BytesIO()
    with tarfile.open(fileobj=tar_bytes, mode='w', format=tarfile.USTAR_FORMAT) as archive:
        for path in ('gcc/gimple-range-edge.cc', 'gcc/value-query.cc'):
            raw = (args.gcc_root / path).read_bytes()
            matches = []
            for name, manifest in manifests.items():
                entry = next(row for row in manifest['files'] if row['path'] == path)
                assert identity(raw) == {k: entry[k] for k in ('bytes', 'sha256')}, (path, name)
                matches.append(dict(manifest=name, array='files'))
            info = tarfile.TarInfo(path)
            info.size = len(raw)
            info.mode = 0o644
            info.mtime = 0
            info.uid = info.gid = 0
            info.uname = info.gname = ''
            archive.addfile(info, io.BytesIO(raw))
            files.append(dict(path=path, identity=identity(raw),
                observed_local_origin=str((args.gcc_root / path).resolve()),
                matching_manifest_entries=matches))
    compressed = io.BytesIO()
    with gzip.GzipFile(filename='', fileobj=compressed, mode='wb', mtime=0) as stream:
        stream.write(tar_bytes.getvalue())
    data = compressed.getvalue()
    (HERE / 'sources.tar.gz').write_bytes(data)
    manifest = dict(scope='L17 retention of existing hash-pinned GCC source bytes',
        target_commit='a3af18004743d36328a499760699305357389fb8',
        gcc_revision=revision, revision_provenance='existing rtl-helpers and rtl-emission source manifests; no new upstream checkout verification',
        origin_kind='existing local mirror; no network fetch', archive='sources.tar.gz',
        archive_identity=identity(data), deterministic_archive=dict(format='USTAR', member_order='lexical',
            uid=0, gid=0, mtime=0, mode='0644', owner_names='', gzip_filename='', gzip_mtime=0),
        files=files, new_source_claim=False, new_universal_claim=False)
    (HERE / 'sources.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print(json.dumps(dict(files=len(files), archive=identity(data))))


if __name__ == '__main__':
    main()

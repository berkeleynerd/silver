#!/usr/bin/env python3
"""Package inspected sources and installed identities, without executing tools."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import tarfile


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--gpr2', type=Path, required=True)
    p.add_argument('--spark', type=Path, required=True)
    p.add_argument('--ada', type=Path, required=True)
    p.add_argument('--gcc', type=Path, required=True)
    p.add_argument('--repository', type=Path, required=True)
    a = p.parse_args()
    out = Path(__file__).resolve().parent
    files = {}
    for name in ('src/lib/gpr2-project-tree.ads', 'src/lib/gpr2-project-tree.adb',
                 'src/lib/gpr2-project-view.adb', 'src/private/gpr2-tree_internal.adb',
                 'src/build/gpr2-build-tree_db.adb', 'src/build/gpr2-build-source_base.adb',
                 'src/build/gpr2-build-compilation_unit.adb',
                 'src/private/gpr2-build-view_tables.adb',
                 'src/private/gpr2-build-view_tables-update_sources_list.adb'):
        files['gpr2/' + name] = a.gpr2 / name
    for name in ('configuration.ads', 'configuration.adb', 'gnatprove.adb'):
        files['spark/src/gnatprove/' + name] = a.spark / 'src/gnatprove' / name
    files['spark/src/why/gnat2why-driver.adb'] = a.spark / 'src/why/gnat2why-driver.adb'
    for name in ('switch-c.adb', 'opt.ads', 'osint-c.adb', 'repinfo.adb',
                 'back_end.adb', 'sem_ch13.adb', 'adabkend.adb', 'backend_utils.adb'):
        files['gcc/ada/' + name] = a.ada / name
    for name in ('fixed-gcc-prefix-source-identity.json', 'fixed-root-source-identity.json'):
        for row in json.loads((out / name).read_bytes())['files']:
            path = a.gcc / row['path']
            if not path.exists() and row['path'].startswith('gcc/ada/'):
                path = a.ada / row['path'].removeprefix('gcc/ada/')
            assert identity(path.read_bytes()) == dict(bytes=row['bytes'], sha256=row['sha256'])
            files[row['path']] = path
    rows = {}
    with tarfile.open(out / 'sources.tar.gz', 'w:gz') as tar:
        for name, path in sorted(files.items()):
            raw = path.read_bytes()
            member = tarfile.TarInfo(name)
            member.size = len(raw)
            tar.addfile(member, io.BytesIO(raw))
            rows[name] = dict(**identity(raw), original_path=str(path))
    overlay = a.repository / '.silver/linux-x86_64/image-tools/libexec/spark'
    native = a.repository / '.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a'
    installed = {}
    for label, root in (('producer', overlay), ('native', native)):
        for name in ('bin/gcc', 'libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1',
                     'lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude/system.ads'):
            path = root / name
            installed[label + '/' + name] = dict(**identity(path.read_bytes()),
                                                original_path=str(path), resolved_path=str(path.resolve()))
    manifest = dict(scope='offline source packaging and identity reads',
                    gpr2_commit='96e4283834e3c56d51f986c059770be48efaf22a',
                    gcc_commit='6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea',
                    spark_source_identity='inspected source under retained relevant-behavior premise',
                    archive=identity((out / 'sources.tar.gz').read_bytes()),
                    sources=rows, installed=installed)
    (out / 'sources.json').write_text(json.dumps(manifest, indent=2, sort_keys=True) + '\n')


if __name__ == '__main__':
    main()

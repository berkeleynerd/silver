#!/usr/bin/env python3
"""Package existing GPR parent captures and inspected source; executes no tool."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import tarfile

FILES = (
    'gpr/src/gpr.ads', 'gpr/src/gpr.adb', 'gpr/src/gpr-sinput.ads',
    'gpr/src/gpr-sinput.adb', 'gpr/src/gpr-err-scanner.adb',
    'gpr/src/gpr-nmsc.adb', 'gpr/src/gpr-part.adb', 'gpr/src/gpr-conf.adb',
    'gpr/src/gpr-osint.ads', 'gpr/src/gpr-osint.adb', 'gpr/src/gpr-util.adb',
    'gpr/src/gpr-ali.ads', 'gpr/src/gpr-ali.adb', 'gpr/src/gpr-opt.ads',
    'src/gprbuild-compile.adb', 'src/gprbuild-post_compile.adb',
)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def archive(out, files):
    rows = {}
    with tarfile.open(out, 'w:gz') as tar:
        for name, path in sorted(files.items()):
            raw = path.read_bytes()
            info = tarfile.TarInfo(name)
            info.size = len(raw)
            tar.addfile(info, io.BytesIO(raw))
            rows[name] = dict(**identity(raw), original_path=str(path))
    return dict(archive=identity(out.read_bytes()), members=rows)


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--gpr-source', type=Path, required=True)
    p.add_argument('--run-registry', type=Path, required=True)
    p.add_argument('--output', type=Path, default=Path(__file__).resolve().parent)
    a = p.parse_args()
    a.output.mkdir(parents=True, exist_ok=True)
    captures = {}
    for label, directory, run_id in (
        ('ordinary', '/tmp/silver-gpr-parent-fixed-20261018', '20261018T122943-c12e0db35e8a'),
        ('retained-config', '/tmp/silver-gpr-parent-retain-20261018', '20261018T123112-8c4245919445'),
    ):
        root = Path(directory)
        inv = json.loads((root / 'invocation.json').read_bytes())
        work = Path(inv['cwd'])
        for name in ('run.py', 'invocation.json', 'result.json', 'stdout', 'stderr'):
            captures[f'{label}/{name}'] = root / name
        for name in json.loads((root / 'result.json').read_bytes())['generated']:
            captures[f'{label}/work/{name}'] = work / name
        for name in ('events.jsonl', 'native.log'):
            captures[f'{label}/managed/{name}'] = a.run_registry / run_id / name
    manifest = dict(scope='two retained small native GPR builds; offline collection only',
                    source_commit='bdfb879cf03643ec8e48a09ce07b08c4a6ff0263',
                    archives={
                        'sources.tar.gz': archive(a.output / 'sources.tar.gz',
                            {n: a.gpr_source / n for n in FILES}),
                        'witnesses.tar.gz': archive(a.output / 'witnesses.tar.gz', captures),
                    })
    (a.output / 'manifest.json').write_text(json.dumps(manifest, indent=2, sort_keys=True) + '\n')


if __name__ == '__main__':
    main()

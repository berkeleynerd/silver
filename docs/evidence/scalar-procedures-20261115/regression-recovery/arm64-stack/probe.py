"""Bounded, read-only-binary stack diagnosis for the exact scalar-guard cases."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import resource
import subprocess
import time


def program(declarations: bytes, body: bytes) -> bytes:
    return (b'with Silver_IO;procedure Main is pragma SPARK_Mode(On);'
            + declarations + b'begin ' + body + b'end Main;')


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('binary', type=Path)
    parser.add_argument('--limits-kib', type=int, nargs='+',
                        default=[8192, 12288, 16384])
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    binary = args.binary.resolve(strict=True)
    args.output.mkdir(parents=True, exist_ok=True)
    before = resource.getrlimit(resource.RLIMIT_STACK)
    results = []
    for count in (0, 1, 32):
        declarations = b''.join(f'X{index}:Integer:=0;'.encode()
                                for index in range(count))
        predicate = b'X0=0' if count else b'0=0'
        fixed = program(declarations, b'if ' + predicate + b' then null;end if;')
        depth = (4096 - len(fixed)) // 2
        nested = program(declarations, b'if ' + b'(' * depth + predicate
                         + b')' * depth + b' then null;end if;')
        nested += b' ' * (4096 - len(nested))
        assert len(nested) == 4096
        cases = [('exact', nested), ('over', nested + b' '), ('shallow', fixed)]
        for kind, source in cases:
            path = args.output / f'count-{count}-{kind}.adb'
            path.write_bytes(source)
            for limit_kib in args.limits_kib:
                def set_child_limit() -> None:
                    resource.setrlimit(resource.RLIMIT_STACK,
                                       (limit_kib * 1024, before[1]))

                start = time.monotonic()
                result = subprocess.run([str(binary), 'check', str(path.resolve())],
                                        text=True, capture_output=True, timeout=120,
                                        preexec_fn=set_child_limit)
                assert path.read_bytes() == source
                row = {'count': count, 'depth': depth if kind != 'shallow' else 0,
                       'kind': kind, 'source_bytes': len(source),
                       'source_sha256': hashlib.sha256(source).hexdigest(),
                       'stack_limit_kib': limit_kib, 'returncode': result.returncode,
                       'stdout': result.stdout, 'stderr': result.stderr,
                       'elapsed_seconds': time.monotonic() - start}
                results.append(row)
                print(json.dumps(row), flush=True)
    after = resource.getrlimit(resource.RLIMIT_STACK)
    assert before == after
    record = {'platform': platform.platform(), 'machine': platform.machine(),
              'binary': str(binary), 'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
              'parent_stack_limits_bytes_before': before,
              'parent_stack_limits_bytes_after': after, 'pid': os.getpid(),
              'results': results}
    (args.output / 'results.json').write_text(json.dumps(record, indent=2) + '\n')


if __name__ == '__main__':
    main()

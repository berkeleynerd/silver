"""Capture fixture construction and expectations without invoking a toolchain.

Run from any directory. No compiler, prover, build or program is executed.
The captured compile/run calls are plans, never validation results.
"""
from __future__ import annotations

from collections import Counter
import hashlib
import importlib
import inspect
import json
from pathlib import Path
import subprocess
import sys
import types
import unittest


ROOT = Path(__file__).resolve().parents[4]
BASELINE = '877c382f6d07c1e0a2573d4cf70fa13876a399b4'
CLASSES = (
    ('tests/test_scalar_functions.py', 'ScalarFunctionTests'),
    ('tests/test_scalar_procedures.py', 'ScalarProcedureTests'),
)


def capture(cls: type[unittest.TestCase], filename: str) -> list[dict]:
    rows = []
    for method in unittest.defaultTestLoader.getTestCaseNames(cls):
        # These methods already compile and execute their sources. The repair
        # adds twins to the admission-only methods, including generated cases.
        if method.startswith('test_native_'):
            continue
        checks = []

        def check(self, source, expected=0):
            frame = inspect.currentframe().f_back
            while frame.f_code.co_name != method:
                frame = frame.f_back
            checks.append(dict(file=filename, method=method, line=frame.f_lineno,
                               check_ordinal=len(checks) + 1, source=source.decode('ascii'),
                               source_sha256=hashlib.sha256(source).hexdigest(), expected=expected))

        def compile_plan(self, source, kind, **metadata):
            assert checks[-1]['expected'] == 0
            assert checks[-1]['source'].encode('ascii') == source
            assert 'full_route' not in checks[-1]
            checks[-1]['full_route'] = dict(kind=kind, **metadata, runs=[])
            return None, {}

        def execution_plan(self, executable, output, arguments=(), status=0):
            assert executable is None
            checks[-1]['full_route']['runs'].append(dict(
                arguments=[value.decode('ascii') for value in arguments],
                stdout=output.decode('ascii'), stderr='', exit_status=status))

        case = cls(method)
        case.check = types.MethodType(check, case)
        case.compile = types.MethodType(compile_plan, case)
        case.run_program = types.MethodType(execution_plan, case)
        case.setUp()
        try:
            getattr(case, method)()
        finally:
            case.doCleanups()
        rows.extend(checks)
    return rows


def original_class(filename: str, class_name: str) -> type[unittest.TestCase]:
    contents = subprocess.run(['git', 'show', f'{BASELINE}:{filename}'], cwd=ROOT,
                              check=True, capture_output=True).stdout
    module = types.ModuleType('_original_' + class_name)
    module.__file__ = str(ROOT / filename)
    sys.modules[module.__name__] = module
    exec(compile(contents, module.__file__, 'exec'), module.__dict__)
    return getattr(module, class_name)


def projection(rows: list[dict]) -> list[tuple]:
    return [(row['file'], row['method'], row['check_ordinal'], row['source'], row['expected'])
            for row in rows]


def main() -> None:
    sys.path.insert(0, str(ROOT))
    original = []
    current = []
    for filename, name in CLASSES:
        original.extend(capture(original_class(filename, name), filename))
        module = importlib.import_module(filename[:-3].replace('/', '.'))
        current.extend(capture(getattr(module, name), filename))
    assert projection(current) == projection(original), 'original source/verdict inventory changed'
    positives = []
    for before, after in zip(original, current):
        if after['expected'] == 0:
            assert after.get('full_route', {}).get('runs'), 'positive fixture lacks full route/output'
            after['original_line'] = before['line']
            after['fixture_id'] = f"{after['file']}::{after['method']}::check[{after['check_ordinal']}]"
            positives.append(after)
        else:
            assert 'full_route' not in after, 'negative fixture took the full route'
    assert len(current) == 288 and len(positives) == 88
    assert len({row['source_sha256'] for row in positives}) == 88
    output = dict(
        status='expectation inventory; toolchain validation is recorded separately',
        baseline=BASELINE,
        comparison='all original source bytes, verdicts and per-method check order are unchanged',
        source_verdict_sha256=hashlib.sha256(json.dumps(projection(current)).encode()).hexdigest(),
        original_checks=len(current), negative_checks=len(current) - len(positives),
        positive_fixtures=len(positives),
        positive_by_file=dict(Counter(row['file'] for row in positives)),
        policy_kinds=dict(Counter(row['full_route']['kind'] for row in positives)),
        expected_execution_cases=sum(len(row['full_route']['runs']) for row in positives),
        test_sources={filename: hashlib.sha256((ROOT / filename).read_bytes()).hexdigest()
                      for filename in (*[item[0] for item in CLASSES], 'tests/test_shared_bindings.py')},
        fixtures=positives,
    )
    target = Path(__file__).with_name('inventory.json')
    target.write_text(json.dumps(output, indent=2) + '\n')
    print(f'{len(positives)} positive fixtures, {len(current) - len(positives)} negative checks; '
          f"{output['expected_execution_cases']} expected execution cases; {target}")


if __name__ == '__main__':
    main()

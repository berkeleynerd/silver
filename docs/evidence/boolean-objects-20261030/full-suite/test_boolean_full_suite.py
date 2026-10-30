"""Run unchanged full discovery with inherited producer CPU affinity."""
import json
import os
from pathlib import Path
import unittest

CPUS = sorted(os.sched_getaffinity(0))[:2]
os.sched_setaffinity(0, CPUS)
print("Full-suite worker CPU affinity:", sorted(os.sched_getaffinity(0)), flush=True)
_LOADING = False

def _ids(suite):
    for test in suite:
        if isinstance(test, unittest.TestSuite):
            yield from _ids(test)
        else:
            yield test.id()

def load_tests(loader, existing, pattern):
    global _LOADING
    if _LOADING:
        return unittest.TestSuite()
    _LOADING = True
    try:
        suite = loader.discover(str(Path(__file__).parent), pattern="test_*.py")
        expected = json.loads((Path(__file__).parents[1] / "tmp/boolean-full-test-inventory.json").read_text())
        actual = sorted(_ids(suite))
        if actual != expected:
            raise AssertionError("Full-suite discovery differs from unchanged standard inventory")
        print("Full-suite standard inventory:", len(actual), "test identities", flush=True)
        return suite
    finally:
        _LOADING = False

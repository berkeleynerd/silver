"""Use the repository's normal unittest discovery from an isolated tool run."""
from pathlib import Path
import json
import os
import sys
import unittest

root = Path(__file__).resolve().parents[1]
os.chdir(root)
sys.path.insert(0, str(root))
print(json.dumps({'root': str(root), 'cpu_affinity': sorted(os.sched_getaffinity(0))}), flush=True)
suite = unittest.defaultTestLoader.discover('tests', pattern='test_scalar_functions.py')
result = unittest.TextTestRunner(verbosity=2).run(suite)
raise SystemExit(0 if result.wasSuccessful() else 1)

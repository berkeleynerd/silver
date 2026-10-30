"""Run the unchanged maximum-expression test with its allocated eight CPUs."""
import os
import unittest
CPUS = sorted(os.sched_getaffinity(0))[:8]
os.sched_setaffinity(0, CPUS)
print("Maximum-expression worker CPU affinity:", sorted(os.sched_getaffinity(0)), flush=True)
import test_samples

def load_tests(loader, existing, pattern):
    return unittest.TestSuite([
        test_samples.SupportedSampleTests("test_maximum_dynamic_expression"),
    ])

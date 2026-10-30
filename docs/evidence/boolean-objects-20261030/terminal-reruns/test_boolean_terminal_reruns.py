"""Rerun the exact reviewed or failed identities after the frozen full suite."""
import os
import unittest
CPUS = sorted(os.sched_getaffinity(0))[:2]
os.sched_setaffinity(0, CPUS)
print("Terminal rerun worker CPU affinity:", sorted(os.sched_getaffinity(0)), flush=True)
import test_branching
import test_samples

def load_tests(loader, existing, pattern):
    return unittest.TestSuite([
        test_branching.BranchingTests("test_admitted_literals_binding_and_layout"),
        test_branching.BranchingTests("test_rejected_guard_equality_and_branch_neighbours"),
        test_samples.SupportedSampleTests("test_maximum_dynamic_expression"),
    ])

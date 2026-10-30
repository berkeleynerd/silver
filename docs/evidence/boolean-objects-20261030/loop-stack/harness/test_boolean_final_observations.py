"""Managed focused observations with two-CPU child affinity."""
import os
import unittest

CPUS = sorted(os.sched_getaffinity(0))[:2]
os.sched_setaffinity(0, CPUS)
print("Focused test worker CPU affinity:", sorted(os.sched_getaffinity(0)), flush=True)

from tests import test_boolean_objects, test_silver, test_boolean_loop_observations

def load_tests(loader, existing, pattern):
    suite = unittest.TestSuite()
    suite.addTests(loader.loadTestsFromTestCase(test_boolean_objects.BooleanObjectTests))
    suite.addTest(test_silver.SilverIntegrationTests("test_catalogue_is_json"))
    suite.addTests(loader.loadTestsFromTestCase(test_boolean_loop_observations.RetainedStackObservations))
    return suite

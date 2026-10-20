"""Small branch/negative regressions; these are not a source-proof substitute."""
import unittest

from transfer import STRING_MAX, constant_bound, derive, task_bound


def small_forest():
    return dict(case="synthetic", provenance={},
        saved_occurrence_certificate=dict(B_binders=2,
            tasks={"1": dict(propositions=[dict(formula=7)])},
            formulas={"7": dict(opened_term_occurrences=3, opened_binder_occurrences=1)},
            visits=[dict(task=1), dict(task=1)]),
        proposition_and_explanation_requests_per_save=4, imported_APn_visits=2,
        constants={}, typed_graph_complete=True, numeric_components_complete=True,
        coverage_failures=[], unsupported_numeric_components=[],
        imported_shape_term_visits_per_task={"1": 3}, max_case_pattern_occurrences=4,
        original_name_bytes_max=2, shape_attribute_union=dict(count=2, sum_bytes=9))


class TransferTests(unittest.TestCase):
    def test_constant_families_and_punctuation(self):
        part = dict(decimal_bytes=3, representation="immediate_OCaml_int")
        self.assertEqual(constant_bound(dict(kind="int", parts=[part])), 3)
        self.assertEqual(constant_bound(dict(kind="real", parts=[part]*3)), 12)
        self.assertEqual(constant_bound(dict(kind="string", bytes=256)), 1026)
        self.assertIsNone(constant_bound(dict(kind="real", parts=[part])))
        self.assertIsNone(constant_bound(dict(kind="other")))
        bad = dict(decimal_bytes=3, representation="unclassified_custom")
        self.assertIsNone(constant_bound(dict(kind="int", parts=[bad])))

    def test_full_byte_string_escape(self):
        def escaped_size(c):
            if c in (92, 10, 13, 9, 8, 34):
                return 2
            return 1 if 32 <= c <= 126 else 4
        actual = 2 + sum(map(escaped_size, range(256)))
        self.assertLessEqual(actual, constant_bound(dict(kind="string", bytes=256)))

    def test_patterns_and_repeated_visits_are_not_deduplicated(self):
        row = derive(small_forest())
        task = row["task_bounds"]["1"]
        self.assertEqual((task["T"], task["Q"], task["P"], task["A"]), (3, 12, 15, 13))
        self.assertEqual(row["J"], 4)
        self.assertEqual(row["L"], 2 * task["shape_bytes_upper"])
        atoms = small_forest()
        atoms["saved_occurrence_certificate"]["visits"][0]["detached"] = True
        with self.assertRaises(ValueError):
            derive(atoms)

    def test_unknown_atom_prevents_L_but_retains_J(self):
        atoms = small_forest()
        atoms["constants"] = {"99": dict(kind="unknown")}
        row = derive(atoms)
        self.assertEqual(row["J"], 4)
        self.assertIsNone(row["L"])
        self.assertEqual(row["unsupported_constant_pointers"], ["99"])
        atoms["constants"] = {}
        atoms["typed_graph_complete"] = False
        self.assertIsNone(derive(atoms)["L"])
        incomplete = derive(atoms, explanation_prefix_count=5)
        self.assertIsNone(incomplete["explanation"]["per_insertion_bytes_upper"])
        self.assertFalse(incomplete["explanation"]["typed_attribute_closure_established"])

    def test_explanation_configuration_does_not_change_shape_buffer_L(self):
        unknown = derive(small_forest())
        known = derive(small_forest(), explanation_prefix_count=5)
        self.assertEqual(unknown["L"], known["L"])
        self.assertIsNone(unknown["explanation"]["per_save_bytes_upper"])
        self.assertEqual(known["explanation"]["per_save_bytes_upper"], 132)
        self.assertFalse(known["complete_save_capacity_established"])

    def test_representation_guard_is_separate_from_mathematical_bound(self):
        result = task_bound(term_occurrences=1, binder_occurrences=0,
                            max_case_patterns=0, original_name_max=0,
                            constant_max=STRING_MAX + 1)
        self.assertGreater(result["shape_bytes_upper"], STRING_MAX)
        self.assertFalse(result["guards"]["individual_constant_string"])
        with self.assertRaises(ValueError):
            derive(small_forest(), explanation_prefix_count=-1)


if __name__ == "__main__":
    unittest.main()

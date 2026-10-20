#!/usr/bin/env python3
"""Boundary checks for occurrence counting, unknowns and captured provenance."""
import copy
import unittest

import extract


def s(text):
    raw = text.encode()
    return {'hex': raw.hex(), **extract.ident(raw)}


def p(parts):
    return {'components': [s(x) for x in parts], 'component_count': len(parts),
        'total_bytes': sum(len(x) for x in parts),
        'joined_dot_bytes': sum(len(x) for x in parts) + max(0, len(parts)-1)}


def fixture():
    theory = {'pointer': 10, 'id_tag': 10, 'id_string': s('Th')}
    goal = {'pointer': 20, 'id_tag': 20, 'id_string': s('G')}
    ser = {'files': [{'id': 0, 'format': s('f'), 'path': p(['x']),
        'theories': [{'name': theory, 'goals': [0]}]}],
        'goals': [{'goal': 0, 'name': goal, 'explanation': s('xy'), 'transformations': []}],
        'transformations': []}
    restore = {'required_identifiers': [{'ident': x, 'binding': None,
        'restore_path': None, 'serializer_name_bytes': x['id_string']['bytes'],
        'fallback': True} for x in (theory, goal)]}
    return ser, restore


class ExtractionChecks(unittest.TestCase):
    def test_shared_node_keeps_output_occurrence_multiplicity(self):
        ser, restore = fixture()
        once = extract.forest_inventory(ser, restore)
        ser['files'][0]['theories'][0]['goals'].append(0)
        twice = extract.forest_inventory(ser, restore)
        self.assertEqual(twice['visits']['goals'], 2)
        self.assertEqual(twice['candidate_forest_string_bytes'] - once['candidate_forest_string_bytes'], 3)

    def test_unknown_and_absence_are_not_future_empty_paths(self):
        ser, restore = fixture()
        row = extract.forest_inventory(ser, restore)['identifiers'][1]
        self.assertIsNone(row['captured_qualified_path'])
        self.assertFalse(row['whole_interval_name_bound_established'])
        with self.assertRaisesRegex(AssertionError, 'unknown string'):
            extract.string(None)
        malformed = copy.deepcopy(restore)
        malformed['required_identifiers'][0]['restore_path'] = {'qualified_path': p([])}
        with self.assertRaises(AssertionError):
            extract.forest_inventory(ser, malformed)

    def test_restored_qualified_length_and_fallback_both_count(self):
        ser, restore = fixture()
        r = restore['required_identifiers'][1]
        r.update(binding={'captured': True}, restore_path={'qualified_path': p(['long', 'name'])},
            fallback=False, serializer_name_bytes=9)
        row = extract.forest_inventory(ser, restore)['identifiers'][1]
        self.assertEqual(row['fallback']['bytes'], 1)
        self.assertEqual(row['fallback_or_captured_qualified_bytes_upper'], 9)

    def test_archive_member_identity_mutation_rejected(self):
        archive = extract.CaptureArchive()
        member = 'registration/overlay/why3.conf'
        name, expected = archive.members[member]
        archive.members[member] = (name, {**expected, 'sha256': '0'*64})
        try:
            with self.assertRaisesRegex(AssertionError, 'input identity mismatch'):
                archive.read(member)
        finally:
            archive.close()


if __name__ == '__main__':
    unittest.main()

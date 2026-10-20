#!/usr/bin/env python3
"""Meaningful boundary checks for missing status bytes and cache provenance."""
import json
import struct
import types
import unittest

import extract


def raw_block(pointer, fields, tag=0):
    header = (len(fields) << 10) | tag
    return {'address': pointer, 'header': header, 'header_hex': header.to_bytes(8, 'little').hex(),
            'tag': tag, 'words': len(fields), 'payload_hex': struct.pack('<' + 'Q'*len(fields), *fields).hex()}


def blocks(*rows):
    return extract.Blocks(b'\n'.join(json.dumps(row).encode() for row in rows))


class StatusChecks(unittest.TestCase):
    def test_missing_result_is_not_none_or_false(self):
        projection = extract.status(blocks(raw_block(0x100, [0x200])), 0x100)
        self.assertFalse(projection['known'])
        self.assertEqual(projection['proof_state'], 'Some')
        self.assertEqual(projection['result_pointer'], 0x200)
        self.assertEqual(projection['missing_raw_block'], 0x200)
        self.assertIsNone(projection['answer'])
        self.assertEqual(extract.status(blocks(), 1)['proof_state'], 'None')

    def test_valid_answer_uses_checked_record_layout(self):
        memory = blocks(raw_block(0x100, [0x200]), raw_block(0x200, [1, 1, 1, 1, 3, 1]))
        self.assertEqual(extract.status(memory, 0x100)['answer'], 'Valid')
        bad = blocks(raw_block(0x100, [0x200]), raw_block(0x200, [1, 1, 1, 1, 3]))
        with self.assertRaisesRegex(AssertionError, 'block size mismatch'):
            extract.status(bad, 0x100)

    def test_absent_cache_and_cached_false_remain_distinct(self):
        missing = extract.observed_and_getter({}, 0, False)
        present = extract.observed_and_getter({0: False}, 0, False)
        self.assertEqual(missing['source_getter_value'], present['source_getter_value'])
        self.assertIsNone(missing['observed_cache_entry'])
        self.assertIs(present['observed_cache_entry'], False)
        self.assertFalse(missing['observed_cache_binding_present'])
        self.assertTrue(present['observed_cache_binding_present'])

    def test_duplicate_cache_bindings_keep_first_lookup_and_all_visits(self):
        table = {'pointer': 8, 'size': 2, 'bucket_capacity': 16, 'entries': [
            {'raw_key': 3, 'raw_value': 3}, {'raw_key': 3, 'raw_value': 1}]}
        projection, first = extract.cache_projection(table, [1, 2])
        self.assertEqual(len(projection['bindings']), 2)
        self.assertEqual(projection['duplicate_keys'], [1])
        self.assertEqual(projection['missing_domain_keys'], [2])
        self.assertIs(first[1], True)

    def test_overlapping_fresh_raw_identities_must_match(self):
        expected = {'bytes': 8, 'sha256': 'a'*64}
        comparison = {'matched': True, 'new_inputs': {'session-blocks.jsonl': expected}}
        replay = {'complete': True, 'input_identities': {
            'session-blocks.jsonl': {**expected, 'sha256': 'b'*64}}}
        archive = types.SimpleNamespace(members={})
        with self.assertRaisesRegex(AssertionError, 'overlapping raw identity mismatch'):
            extract.check_lineage(archive, 'case/capture', comparison, replay)


if __name__ == '__main__':
    unittest.main()

"""Negative evidence-join checks; no target or previous analyses are executed."""
import copy
import tempfile
import unittest
from pathlib import Path

from join import identity, validate_initial_metadata, validate_provenance


def prover(name):
    return {k: {'hex': v.encode().hex()} for k, v in
            [('name', name), ('version', '1'), ('alternative', '')]}


def metadata():
    p = prover('A')
    return {'attempts': [{'prover': p}], 'goals': [
        {'goal': 0, 'attempts': {'pointer': 16, 'binding_visits': 1, 'entries': [{'key': p}]}},
        {'goal': 1, 'attempts': {'pointer': 32, 'binding_visits': 0, 'entries': []}},
    ]}


class Joins(unittest.TestCase):
    def test_fresh_structural_domain_not_pointer_count(self):
        ser = metadata()
        ser['attempts'].append({'prover': copy.deepcopy(prover('A'))})
        result = validate_initial_metadata(ser, {'prover_domain0_upper': 1}, {'0': 1, '1': 0})
        self.assertEqual(result['structural_prover_key_count'], 1)
        ser['attempts'].append({'prover': prover('B')})
        with self.assertRaisesRegex(AssertionError, 'prover domain'):
            validate_initial_metadata(ser, {'prover_domain0_upper': 1}, {'0': 1, '1': 0})

    def test_same_totals_do_not_establish_goal_membership(self):
        ser = metadata()
        with self.assertRaisesRegex(AssertionError, 'membership counts'):
            validate_initial_metadata(ser, {'prover_domain0_upper': 1}, {'0': 0, '1': 1})
        ser['goals'][1]['attempts']['pointer'] = 16
        with self.assertRaisesRegex(AssertionError, 'aliased'):
            validate_initial_metadata(ser, {'prover_domain0_upper': 1}, {'0': 1, '1': 0})

    def test_derived_match_cannot_hide_changed_raw_input(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root/'projection.json').write_text('{}')
            (root/'raw.jsonl').write_text('raw')
            ids = {name: identity(root/name) for name in ['projection.json', 'raw.jsonl']}
            comparison, replay = {'new_inputs': ids}, {'input_identities': copy.deepcopy(ids)}
            validate_provenance(root, comparison, replay)
            replay['input_identities']['raw.jsonl']['sha256'] = '0'*64
            with self.assertRaisesRegex(AssertionError, 'overlapping raw input'):
                validate_provenance(root, comparison, replay)
            replay['input_identities'] = copy.deepcopy(ids)
            (root/'raw.jsonl').write_text('changed')
            with self.assertRaisesRegex(AssertionError, 'captured input differs'):
                validate_provenance(root, comparison, replay)


if __name__ == '__main__':
    unittest.main()

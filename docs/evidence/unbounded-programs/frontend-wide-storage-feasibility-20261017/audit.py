#!/usr/bin/env python3
"""Recheck selected pinned sources and reproduce exact design arithmetic.

Usage: python3 audit.py /path/to/gcc/ada /path/to/output-directory
No compiler, proof tool or large allocation is invoked. This script is a
research calculation/search aid, not a proof of compiler correctness.
"""

import hashlib
import json
from pathlib import Path
import re
import sys


root, out = map(Path, sys.argv[1:])
out.mkdir(parents=True, exist_ok=True)
record = json.loads((Path(__file__).parent / 'source-files.json').read_text())
verified = []
for entry in record['files']:
    data = (root / entry['path']).read_bytes()
    actual = {
        'path': entry['path'],
        'bytes': len(data),
        'git_blob_sha1': hashlib.sha1(
            b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest(),
        'sha256': hashlib.sha256(data).hexdigest(),
    }
    if any(actual[k] != entry[k] for k in actual):
        raise SystemExit('source mismatch: ' + entry['path'])
    verified.append(actual)


def save(name, value):
    (out / name).write_text(json.dumps(value, indent=2) + '\n')


# Check that the numeric premises actually occur in the rechecked source.
types = (root / 'types.ads').read_text()
for needle in (
    'type Int is range -2 ** 31 .. +2 ** 31 - 1;',
    'Strings_Low_Bound : constant := -499_999_999;',
    'Strings_High_Bound : constant := -400_000_000;',
    'No_String : constant String_Id := Strings_Low_Bound;',
    'First_String_Id : constant String_Id := No_String + 1;',
    "for Char_Code'Object_Size use 32;",
):
    if needle not in types:
        raise SystemExit('source premise not found: ' + needle)

int_last = 2**31 - 1
int64_last = 2**63 - 1
low = -499_999_999
high = -400_000_000
first = low + 1
n = high - first + 1
p = n * int_last
checks = {
    'pool_slots_below_2_58': p < 2**58,
    'pool_bytes_below_2_60': 4*p < 2**60,
    'pool_bits_fit_signed64': 32*p <= int64_last,
    'one_past_nominal_array_bits_fit_signed64': 32*(p+1) <= int64_last,
    'candidate_growth_product_fit_signed64': 5*p <= int64_last,
    'candidate_growth_addition_fit_signed64': p+10 <= int64_last,
    'old_percentage_product_exceeds_signed64': 250*p > int64_last,
}
if not all(checks.values()):
    raise SystemExit('arithmetic premise failed')


def proposed_capacity(old, requested):
    if not 0 <= old < requested <= p:
        raise ValueError((old, requested))
    return max(requested, min(p, max(old+10, (5*old)//2)))


growth_examples = []
for old, requested in (
    (0, 1), (1, 2), (2500, 2501), (2500, 2**31),
    (p//2, p//2+1), (p-11, p-10), (p-1, p),
):
    capacity = proposed_capacity(old, requested)
    if not requested <= capacity <= p or not capacity > old:
        raise SystemExit('invalid growth example')
    growth_examples.append({
        'old': old, 'requested': requested, 'new_capacity': capacity,
    })

save('derived-arithmetic.json', {
    'status': 'conditional source-derived representation design; not native limits',
    'method': 'exact Python integers; growth examples are not universal proof',
    'No_String': low, 'First_String_Id': first, 'Last_String_Id': high,
    'descriptor_ids_including_null_descriptor': n,
    'per_descriptor_length_limit': int_last,
    'pool_character_slot_bound': p,
    'pool_payload_byte_bound': 4*p,
    'pool_payload_bit_bound': 32*p,
    'one_past_nominal_array_bit_bound': 32*(p+1),
    'candidate_growth_5P': 5*p,
    'old_percentage_growth_250P': 250*p,
    'signed64_last': int64_last,
    'checks': checks,
    'growth_examples': growth_examples,
    'two_chain_minimum_character_bytes': 4*(2**31),
    'candidate_16_byte_descriptor_payload_at_N': 16*n,
    'nonzero_numeral_magnitude_bound': 2**31,
    'largest_base_2_exponent_for_nonzero_mantissa': 31,
    'largest_base_10_exponent_for_nonzero_mantissa': 9,
})
save('source-recheck.json', {
    'upstream_commit': record['upstream_commit'],
    'ada_tree': record['ada_tree'],
    'files_checked': len(verified),
    'bytes_checked': sum(f['bytes'] for f in verified),
    'mismatches': [],
    'scope': 'selected interface sources only; full-tree lifetime audit reused',
})

# Raw, deliberately inclusive candidate-change search. This is neither a
# resolved call graph nor a completeness proof; the full files are retained.
offsets = re.compile(
    r'\bUdigits_Min\b|\bSave_Udigit\b|\.Loc\b|\b\w*_Loc\b'
    r'|\bLoc\s*:|\bUdigits\.(?:Last|Set_Last|Append)\b')
hits = []
for number, line in enumerate((root / 'uintp.adb').read_text().splitlines(), 1):
    if offsets.search(line):
        hits.append({'path': 'uintp.adb', 'line': number, 'text': line})
save('uintp-offset-inventory.json', {
    'method': 'raw inclusive search aid; comments retained; not a call graph',
    'regex': offsets.pattern, 'matches': hits,
})
print(json.dumps({'source_files': len(verified), 'arithmetic_checks': checks,
                  'uintp_search_matches': len(hits)}, sort_keys=True))

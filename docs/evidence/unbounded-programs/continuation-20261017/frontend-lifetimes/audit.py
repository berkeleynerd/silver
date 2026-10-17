#!/usr/bin/env python3
"""Reproduce source inventory, lexical call-site search and exact arithmetic.

Usage: python3 audit.py /path/to/upstream-gcc /path/to/output-directory
The input directory contains gcc/ada/ and ada-tree.json. Obtain the exact tree
from the URL in complete-source-manifest.json, extracting only gcc/ada. This
script does not compile or execute the hypothetical large Ada input.
"""

import hashlib
import json
from pathlib import Path
import re
import sys


def ada_code(text):
    """Blank comments/string literals while retaining line positions.

    This is a lexical search aid, not an Ada parser or a proof of call resolution.
    Character literals are blanked before their quote can start a string match.
    """
    return re.sub(r'''--[^\n]*|'(?:[^'\n]|')'|"(?:""|[^"])*"''',
                  lambda m: ''.join('\n' if c == '\n' else ' ' for c in m[0]),
                  text)


root, out = map(Path, sys.argv[1:])
out.mkdir(parents=True, exist_ok=True)
tree = json.loads((root / 'ada-tree.json').read_text())
errors = []
references = []
lifetime_tokens = []
mutations = []
files = []
symbols = re.compile(r'\b(?:mark|release|release_and_save)\b', re.I)
mutator = re.compile(
    r'\b(?:Stringt|Uintp)\s*\.\s*(?:Initialize|Lock|Unlock|Mark|Release)\b'
    r'|\b(?:String_Chars|Strings|Udigits|Uints)\s*\.\s*'
    r'(?:Init|Set_Last|Clear|Free|Restore|Decrement_Last|Release)\b'
    r'|\bUnstore_String_Char\b|\b(?:String_Chars_Ptr|Strings_Ptr)\b', re.I)
for entry in tree['tree']:
    if entry['type'] != 'blob':
        continue
    path = root / 'gcc/ada' / entry['path']
    data = path.read_bytes()
    blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    if blob != entry['sha']:
        errors.append(entry['path'])
    files.append({'path': entry['path'], 'bytes': len(data), 'git_blob_sha1': blob,
                  'sha256': hashlib.sha256(data).hexdigest()})
    raw = data.decode('utf-8', errors='replace')
    # Preserve all raw package/symbol references across all 2,490 files,
    # including changelogs, templates, generated-code support and C/C++.
    for number, line in enumerate(raw.splitlines(), 1):
        if re.search(r'\b(?:Stringt|Uintp)\b|stringt__|uintp__', line, re.I):
            references.append({'path': entry['path'], 'line': number, 'text': line})
    if path.suffix.lower() not in ('.adb', '.ads'):
        continue
    original_lines = raw.splitlines()
    for number, line in enumerate(ada_code(raw).splitlines(), 1):
        hit = {'path': entry['path'], 'line': number,
               'text': original_lines[number - 1]}
        if symbols.search(line):
            lifetime_tokens.append(hit)
        if mutator.search(line):
            mutations.append(hit)

def save(name, obj):
    (out / name).write_text(json.dumps(obj, indent=2) + '\n')

save('verified-tree.json', {
    'upstream_commit': '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea',
    'ada_tree': tree['sha'], 'truncated': tree['truncated'],
    'files': len(files), 'bytes': sum(f['bytes'] for f in files),
    'mismatches': errors,
})
save('all-package-references.json', references)
save('all-ada-lifetime-tokens.json', lifetime_tokens)
save('all-ada-pool-mutation-tokens.json', mutations)

length = 2500
growth = [length]
while length <= (2**31 - 1):
    length = max(length * 250 // 100, length + 10)
    growth.append(length)
digit_counts = {}
for base in (2, 10, 16):
    bits = (base**799999).bit_length()
    digits = (bits + 14) // 15
    digit_counts[str(base)] = {
        'exponent': 799999, 'exact_bit_length': bits,
        'base_32768_digit_words': digits, 'digit_word_bytes': digits * 4,
        'first_repetition_exceeding_Int_Last_words': (2**31 - 1) // digits + 1,
    }
save('derived-arithmetic.json', {
    'method': 'exact Python integer arithmetic; no floating-point logs',
    'status': 'source-derived quantities, not observed native capacity limits',
    'Int_Last': 2**31 - 1, 'two_chain_final_lengths': [2**30, 2**30],
    'two_chain_final_character_lower_bound': 2**31,
    'two_chain_character_bytes_lower_bound': 4 * 2**31,
    'String_Chars_default_mathematical_growth': growth,
    'last_representable_default_growth_length': growth[-2],
    'first_unrepresentable_default_growth_length': growth[-1],
    'zero_mantissa_powers': digit_counts,
})
assert not tree['truncated'] and not errors
print(json.dumps({'files': len(files), 'mismatches': errors,
                  'lifetime_token_matches': len(lifetime_tokens),
                  'mutation_token_matches': len(mutations)}))

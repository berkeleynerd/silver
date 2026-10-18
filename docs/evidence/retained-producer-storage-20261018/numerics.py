#!/usr/bin/env python3
"""Reconcile numeric constructor coverage; no compiler or prover execution."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent / 'retained-producer-capacity-20261017'))
from auxiliary_domains import check, clean
from string_lengths import body_events

PATTERN = re.compile(
    r'\bNew_(?:(?:Integer|Modular|Fixed|Real|Float|Range|Discrete)_Constant'
    r'|Range_Type_Definition)\s*\(')


def inventory(source_root):
    rows = []
    for path in sorted((source_root / 'src/why').glob('*.adb')):
        source = path.read_text()
        code = clean(source)
        events = body_events(code)
        for match in PATTERN.finditer(code):
            if re.search(r'\bfunction\s*$', code[max(0, match.start()-40):match.start()]):
                continue
            events.append((match.start(), 'numeric', match))
        stack = []
        for position, kind, value in sorted(events, key=lambda e: e[0]):
            if kind == 'start':
                stack.append(value)
            elif kind == 'end':
                if stack and stack[-1].lower() == value.lower():
                    stack.pop()
            else:
                start = value.end()
                depth, end = 1, start
                while depth:
                    if code[end] == '(':
                        depth += 1
                    elif code[end] == ')':
                        depth -= 1
                    end += 1
                rows.append(dict(
                    file=str(path.relative_to(source_root)),
                    line=source.count('\n', 0, position)+1,
                    enclosing_entity='.'.join(stack),
                    constructor=value.group().split('(')[0].strip(),
                    arguments=' '.join(source[start:end-1].split())))
    assert len(rows) == 190
    # The only numeric-constructor calls in handwritten Why specs are these
    # two overloads. Other matches are declarations, not calls.
    forwarders = []
    for path in sorted((source_root / 'src/why').glob('*.ads')):
        source = path.read_text()
        code = clean(source)
        for match in PATTERN.finditer(code):
            if re.search(r'\bfunction\s*$', code[max(0, match.start()-40):match.start()]):
                continue
            forwarders.append((path.name, source.count('\n', 0, match.start())+1))
    assert forwarders == [('why-gen-expr.ads', 370), ('why-gen-expr.ads', 375)]
    assert max(len(str(v)) for v in (-2**31, 2**31, 0, 1, 255, 12)) == 11
    return dict(body_calls=rows, spec_forwarders=forwarders,
                counts=dict(sorted(Counter(r['constructor'] for r in rows).items())),
                main_decimal_image_bound=11,
                scope='Lexical inventory and arithmetic; manual caller proof in retained-producer-numerics.md')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--spark-source', type=Path, required=True)
    parser.add_argument('--spark-archive', type=Path, required=True)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    verified = check(args.spark_source, args.spark_archive)
    result = inventory(args.spark_source)
    result['verified_source_archive'] = {
        key: verified[key]
        for key in ('archive_sha256', 'verified_complete_ada_files')}
    data = json.dumps(result, indent=2) + '\n'
    if args.output:
        args.output.write_text(data)
    print(json.dumps(dict(body_calls=len(result['body_calls']),
                         spec_forwarders=len(result['spec_forwarders']),
                         main_decimal_image_bound=11)))


if __name__ == '__main__':
    main()

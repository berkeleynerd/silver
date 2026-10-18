#!/usr/bin/env python3
"""Offline identity, matcher-root extraction and transfer boundary checks.

This is supporting evidence for the handwritten argument, not a GCC parser,
C++ semantic verifier, native compilation, or proof of the established 3W lemma.
"""

import argparse
import hashlib
import json
from pathlib import Path
import platform
import re
import time

from derive import PRIMES, evaluate, higher_prime


HERE = Path(__file__).resolve().parent
EXPECTED_CONVERT_LINES = [1156, 2308, 2318, 2590, 3260, 4253, 5025, 5705,
                          5721, 5806, 5939, 6253, 6682, 9500, 9511, 9524,
                          9539, 9687, 12089]


class Form:
    def __init__(self, start):
        self.start = start
        self.end = None
        self.items = []


def forms(raw):
    """Preserve offsets; skip comments, strings, directives and C brace blocks.

    Both #if branches remain, making the simplify inventory a superset of
    GENERIC. Macro directives here define only builtin lists / C expressions.
    Parentheses inside if-conditions remain harmless nested forms.
    """
    clean = list(raw)
    pattern = re.compile(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|'
                         r"'(?:\\.|[^'\\])*'", re.S)
    for match in pattern.finditer(raw):
        for pos in range(match.start(), match.end()):
            if clean[pos] != "\n":
                clean[pos] = " "
    # A directive's backslash continuation is part of the same directive.
    offset, continuation = 0, False
    for line in "".join(clean).splitlines(keepends=True):
        directive = continuation or line.lstrip().startswith("#")
        continuation = directive and line.rstrip("\n").endswith("\\")
        if directive:
            for pos in range(offset, offset+len(line)):
                if clean[pos] != "\n":
                    clean[pos] = " "
        offset += len(line)
    depth = 0
    for pos, char in enumerate(clean):
        if char == "{":
            depth += 1
        if depth and char != "\n":
            clean[pos] = " "
        if char == "}":
            depth -= 1
            assert depth >= 0
    assert depth == 0
    result, stack = [], []
    for tok in re.finditer(r'\(|\)|[^\s()]+', "".join(clean)):
        value = tok.group()
        if value == "(":
            form = Form(tok.start())
            (stack[-1].items if stack else result).append(form)
            stack.append(form)
        elif value == ")":
            assert stack, f"unmatched close at {tok.start()}"
            stack.pop().end = tok.end()
        elif stack:
            stack[-1].items.append(value)
    assert not stack
    return result


def operator(token):
    name = re.split(r'[:@?]', token)[0]
    # genmatch::parse_operation strips a trailing group digit for opN?.
    return name[:-1] if "?" in token and name[-1:].isdigit() else name


def matcher_inventory(raw):
    trees = forms(raw)
    definitions = {}
    predicates = set()
    all_forms = []

    def collect(form):
        all_forms.append(form)
        items = form.items
        if items and items[0] == "define_operator_list":
            definitions[items[1]] = items[2:]
        if items and items[0] == "match":
            name = items[1].items[0] if isinstance(items[1], Form) else items[1]
            predicates.add(operator(name))
        for item in items:
            if isinstance(item, Form):
                collect(item)

    for tree in trees:
        collect(tree)

    def resolve(name, env, seen=()):
        name = operator(name)
        assert name not in seen, (name, seen)
        if name in env:
            result = set()
            for value in env[name]:
                assert isinstance(value, str)
                result |= resolve(value, env, seen+(name,))
            return result
        return {name}

    def roots(pattern, env):
        assert isinstance(pattern, Form), "nonexpression simplify root"
        token = pattern.items[0]
        possible = resolve(token, env)
        # Optional outer expressions can expose their operand as a root.
        if "?" in token:
            assert len(pattern.items) == 2
            possible |= roots(pattern.items[1], env)
        return possible

    result = []
    count = 0

    def visit(form, env):
        nonlocal count
        items = form.items
        if not items:
            return
        if items[0] == "for":
            env = dict(env)
            pos = 1
            while (pos+1 < len(items) and isinstance(items[pos], str)
                   and isinstance(items[pos+1], Form)):
                # Resolve a list against the enclosing environment before
                # shadowing a same-named iterator.
                values = set()
                for value in items[pos+1].items:
                    assert isinstance(value, str)
                    values |= resolve(value, env)
                env[items[pos]] = sorted(values)
                pos += 2
        if items[0] == "simplify":
            count += 1
            pattern = items[1]
            possible = roots(pattern, env)
            assert not (possible & predicates), (form.start, possible & predicates)
            assert not any(p.startswith("@") for p in possible)
            if possible & {"convert", "nop", "NOP_EXPR", "CONVERT_EXPR"}:
                result.append(dict(
                    line=raw.count("\n", 0, form.start)+1,
                    pattern=raw[pattern.start:pattern.end],
                    resolved_possible_root_operators=sorted(possible),
                    enclosing_conversion_aliases={k: v for k, v in env.items()
                        if "convert" in v},
                    source=raw[form.start:form.end]))
        for item in items:
            if isinstance(item, Form):
                visit(item, env)

    for tree in trees:
        visit(tree, definitions)
    assert [item["line"] for item in result] == EXPECTED_CONVERT_LINES
    return dict(simplify_forms_in_both_preprocessor_branches=count,
                conversion_root_forms=len(result),
                only_wildcard_operand_candidate_line=5721,
                conversion_root_patterns=result)


def check(source_root, ada_root, match_path):
    start = time.monotonic()
    manifest = json.loads((HERE/"source-manifest.json").read_text())
    checked = []
    for entry in manifest["files"]:
        if entry["path"] == "gcc/match.pd":
            path = match_path
        elif entry["source_root"] == "ada":
            path = ada_root/entry["path"].removeprefix("gcc/ada/")
        else:
            path = source_root/entry["path"]
        raw = path.read_bytes()
        assert len(raw) == entry["bytes"], path
        assert hashlib.sha256(raw).hexdigest() == entry["sha256"], path
        checked.append(entry["path"])
    matcher = matcher_inventory(match_path.read_text())
    # Check the prime sequence against source, including its hexadecimal tail.
    hsource = (source_root/"gcc/hash-table.cc").read_text()
    body = hsource.split("prime_tab[] = {", 1)[1].split("};", 1)[0]
    primes = tuple(int(x, 0) for x in re.findall(r'\{\s*(0x[0-9a-f]+|\d+),', body))
    assert primes == PRIMES
    # One fresh stack, with reserve(8) meaning eight additional free slots.
    alloc = 0
    allocations = []
    for length in (0, 1, 1, 1):
        if length+8 > alloc:
            growth = 4 if not alloc else alloc*2 if alloc < 16 else alloc*3//2
            alloc = max(growth, length+8)
            allocations.append((alloc, 8+8*alloc))
    assert allocations == [(8, 72), (16, 136)]
    # Exhaust small no-delete hash populations, allowing an extra repeated
    # insertion attempt after every insertion (growth precedes lookup).
    hash_cases = 0
    for population in range(0, 257):
        size, occupied, requests = 13, 0, 1
        for _ in range(population):
            for fresh in (True, False):
                if 3*size <= 4*occupied:
                    size = higher_prime(2*occupied)
                    requests += 1
                occupied += fresh
        assert size <= higher_prime(max(13, 2*population))
        assert requests <= 1+population
        hash_cases += 1
    cases = [(1, 0), (1, 1), (2, 0), (2, 3), (5000, 5000),
             (2147483644, 0), (2147483645, 0), (2147483647, 2147483647)]
    results = [evaluate(c, n) for c, n in cases]
    for result, (c, n) in zip(results, cases):
        assert result["whole_body_copy_weight_upper"] == 9*c+3*n+1
        assert result["whole_body_GGC_request_events_upper"] == 33*c+9*n+3
        assert result["whole_body_raw_request_bytes_sum_upper"] == 1320*c+288*n+96
        assert result["whole_body_rounded_request_bytes_sum_upper"] == 1728*c+288*n+96
        assert not result["complete_gimplifier_lifetime_closed"]
    assert results[-3]["protected_set"]["selected_prime_table_condition"]
    assert not results[-2]["protected_set"]["selected_prime_table_condition"]
    invalid = [(0, 0), (-1, 0), (1, -1), (True, 0), (1, False), (1.0, 0)]
    for c, n in invalid:
        try:
            evaluate(c, n)
        except ValueError:
            continue
        raise AssertionError((c, n))
    return dict(status="passed", platform=platform.platform(),
                source_files_checked=checked, matcher=matcher,
                binding_stack_allocations=allocations,
                no_delete_hash_population_cases=hash_cases,
                arithmetic_boundary_cases=len(cases), invalid_counter_cases=len(invalid),
                example_C1_N0=results[0],
                elapsed_seconds=time.monotonic()-start,
                native_compiler_prover_debugger_executions=0,
                complete_gimplifier_lifetime_closed=False,
                whole_pipeline_capacity_established=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path,
                        default=Path("/tmp/silver-backend-compose-20261018/full-source"))
    parser.add_argument("--ada-root", type=Path,
                        default=Path("/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada"))
    parser.add_argument("--match", type=Path,
                        default=Path("/tmp/silver-backend-compose-20261018/folding-sources/match.pd"))
    args = parser.parse_args()
    print(json.dumps(check(args.source_root, args.ada_root, args.match),
                     indent=2, sort_keys=True))

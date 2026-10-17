#!/usr/bin/env python3
"""Count reviewed Why AST child occurrences; does not run an external tool."""

from dataclasses import dataclass
import json


@dataclass(frozen=True)
class Node:
    kind: str
    children: tuple = ()


def node(kind, *children):
    return Node(kind, tuple(children))


def occurrences(tree):
    return 1 + sum(occurrences(child) for child in tree.children)


name = node("W_Name")
integer_type = node("W_Type", name)
module = node("W_Module")


def identifier(with_module=True):
    return node("W_Identifier",
                node("W_Name", *([module] if with_module else [])),
                integer_type)


def call(function, *args):
    return node("W_Call", function, *args, integer_type)


def label(tree):
    return node("W_Label", tree, integer_type)


def overflow(tree):
    return node("W_Loc_Label", label(call(identifier(), tree)))


leaf = node("W_Integer_Constant")
normalized = label(node("W_Deref", identifier(), integer_type))
binary = call(identifier(), leaf, leaf)
unary = call(identifier(False), leaf)
checks = {
    "builtin_integer_type": occurrences(integer_type),
    "identifier_with_module": occurrences(identifier()),
    "normalized_mutable_identifier": occurrences(normalized),
    "binary_core_excluding_children": occurrences(binary) - 2 * occurrences(leaf),
    "unary_minus_core_excluding_child": occurrences(unary) - occurrences(leaf),
    "overflow_wrapper_excluding_child": occurrences(overflow(leaf)) - occurrences(leaf),
    "binary_with_overflow_excluding_children": occurrences(overflow(binary)) - 2 * occurrences(leaf),
    "unary_minus_with_overflow_excluding_child": occurrences(overflow(unary)) - occurrences(leaf),
    "static_subtype_boundary_excluding_child": occurrences(label(overflow(leaf))) - occurrences(leaf),
}
assert list(checks.values()) == [2, 5, 11, 8, 7, 12, 20, 19, 15]

# Shared type/identifier references must be counted on every occurrence.
trees = 0
for length in range(1, 65):
    tree = normalized
    for _ in range(length - 1):
        tree = overflow(call(identifier(), tree, normalized))
    assert occurrences(tree) == 11 * length + 20 * (length - 1)
    trees += 1
checks["left_chain_compositions_checked"] = trees
checks["scope"] = (
    "Independent AST child-occurrence arithmetic only; source caller review "
    "establishes applicability. This is not a compiler or proof execution."
)
print(json.dumps(checks, indent=2))

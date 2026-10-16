"""Read-only source-directed Integer constructor review; not producer execution.

Reconstructs fields from the reviewed pinned constructor route and generator
defaults, then independently decodes the embedded Ada template for comparison.
Only occurrence IDs are normalized. Run from the Silver repository root.
"""

from collections import Counter
import hashlib
import json
from pathlib import Path
import re


def node(kind, domain, *fields):
    return ["W_" + kind, 0, domain, *fields]


def name(symbol, module=None, infix=False):
    return node("NAME", 1, symbol, "", module, infix)


def module(file, symbol):
    return node("MODULE", 1, file, symbol)


def typ(symbol, abstract=False):
    return node("TYPE", 1, 2 if abstract else 0, name(symbol), False, False)


def ident(symbol, value_type=None, domain=1, mod=None, infix=False):
    return node("IDENTIFIER", domain, name(symbol, mod, infix), value_type, [])


def binder(symbol, value_type, domain, ident_domain=1):
    return node("BINDER", domain, ident(symbol, value_type, ident_domain), value_type)


def effects(writes=None):
    # xtree_sinfo.adb:139 overrides the earlier EW_Prog domain to EW_Term.
    return node("EFFECTS", 1, None, writes, None)


def function(domain, symbol, identifier_type=None, binders=None, eff=None,
             pre=None, post=None, result=None, definition=None, labels=None):
    return node("FUNCTION_DECL", domain, ident(symbol, identifier_type), binders,
                eff, pre, post, result, definition, labels or [], None)


int_type = typ("int")
bool_type = typ("bool")
integer_type = typ("integer", abstract=True)
integer_ref = typ("integer__ref", abstract=True)
true_pred = node("LITERAL", 3, 0, None)
int_module = module("int", "Int")

# why-gen-scalars.adb:832-918,1117-1279: type, first, last, predicate, clone.
declarations = [node("TYPE_DECL", 1, None, name("integer"), [],
                     node("RANGE_TYPE_DEFINITION", 1, "-2147483648", "2147483647"))]
for symbol, value in [("first", "-2147483648"), ("last", "2147483647")]:
    declarations.append(function(2, symbol, int_type, eff=effects(),
                                 pre=true_pred, post=true_pred, result=int_type,
                                 definition=node("INTEGER_CONSTANT", 1, value)))


def comparison(left, right, bound_label):
    return node("LABEL", 3, ["GP_Pretty_Ada:" + str(bound_label)],
                node("CALL", 3, ident("<=", bool_type, mod=int_module, infix=True),
                     [ident(left, int_type), ident(right, int_type)], bool_type),
                None)


declarations.append(function(
    3, "in_range", bool_type, [binder("x", int_type, 3)], effects(),
    true_pred, true_pred,
    definition=node("CONNECTION", 3, comparison("first", "x", -1), 5,
                    comparison("x", "last", -2), None), labels=["GP_Inline"]))
declarations.append(node("CLONE_DECLARATION", 1, module("ada__model", "Static_Discrete"),
                         "", 1, [node("CLONE_SUBSTITUTION", 1, kind, name(origin), name(image))
                                 for kind, origin, image in [(0, "t", "integer"),
                                                             (1, "first", "first"),
                                                             (1, "last", "last"),
                                                             (2, "in_range", "in_range")]], 1))

# why-gen-decl.adb:94-268: ref, projection, two metas, havoc (raw builders).
content = ident("integer__content", integer_type)
declarations.append(node("TYPE_DECL", 1, None, name("integer__ref"), [],
                         node("RECORD_DEFINITION", 1,
                              [node("RECORD_BINDER", 1, content, integer_type, [], True)])))
projection = "integer__ref_integer__content__projection"
declarations.append(function(
    1, projection, binders=[binder("a", integer_ref, 4)], result=integer_type,
    definition=node("RECORD_ACCESS", 1, ident("a", integer_ref), content, None)))
for meta in ["model_projection", "inline:no"]:
    declarations.append(node("META_DECLARATION", 1, meta, "function " + projection))
declarations.append(function(4, "integer__havoc", binders=[binder("x", integer_ref, 4, 4)],
                             eff=effects([ident("x", integer_ref, 4)]), result=typ("unit")))

# why-inter.adb:562,683-710: collect Int, append Main/Int, append collected Int.
includes = [node("INCLUDE_DECLARATION", 1, mod, 1, 0)
            for mod in [module("_gnatprove_standard", "Main"), int_module, int_module]]
expected = node("THEORY_DECLARATION", 4, declarations, "Standard__integer", 1, includes,
                'Module for axiomatizing type "integer", created in Gnat2Why.Types.Translate_Type')

template_path = Path("src/silver_image_model_templates.adb")
source = template_path.read_text()
match = re.search(r"Integer_Template_Data\s*:.*?:=\s*\((.*?)\);", source, re.S)
assert match is not None
raw = "".join(chunk.replace('""', '"') for chunk in
              re.findall(r'\d+\s*=>\s*"((?:""|[^"])*)"', match.group(1))).rstrip()
actual = json.loads(raw)


def erase_ids(value):
    if not isinstance(value, list):
        return value
    result = [erase_ids(item) for item in value]
    if result and isinstance(result[0], str) and result[0].startswith("W_"):
        assert len(result) >= 3 and type(result[1]) is int
        result[1] = 0
    return result


compact = json.dumps(expected, separators=(",", ":"), ensure_ascii=True)
assert json.dumps(erase_ids(actual), separators=(",", ":")) == compact
assert raw == compact, "Canonical serialized bytes differ despite tree equality"

nodes, strings, numbers = [], [], []


def visit(value):
    if isinstance(value, list):
        if value and isinstance(value[0], str) and value[0].startswith("W_"):
            nodes.append(value)
        for item in value:
            visit(item)
    elif isinstance(value, str):
        strings.append(value)
    elif type(value) is int:
        numbers.append(value)


visit(expected)
print(json.dumps({
    "result": "exact tree and canonical-byte parity; IDs alone erased",
    "declarations": len(declarations), "includes": len(includes),
    "canonical_bytes": len(raw.encode()),
    "canonical_sha256": hashlib.sha256(raw.encode()).hexdigest(),
    "template_file_sha256": hashlib.sha256(template_path.read_bytes()).hexdigest(),
    "serialized_node_occurrences": len(nodes),
    "max_decoded_string_bytes": max(map(len, strings)),
    "max_number_with_zeroed_ids": max(numbers),
    "max_quoted_integer_bound_bytes": 11,
    "node_kinds": dict(sorted(Counter(item[0] for item in nodes).items())),
}, indent=2))

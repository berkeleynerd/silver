"""Read-only constructor review for pinned producer String/Image templates.

Expected trees follow the cited source constructors and generated defaults;
native template extraction occurs only after expected trees are assembled.
This is a source review witness, not execution or verification of GNATprove.
"""
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

def node(kind, domain, *fields):
    return ["W_" + kind, 0, domain, *fields]

def module(file, symbol):
    return node("MODULE", 1, file, symbol)

def name(symbol, mod=None, infix=False):
    return node("NAME", 1, symbol, "", mod, infix)

def typ(symbol, abstract=False, mod=None):
    return node("TYPE", 1, 2 if abstract else 0, name(symbol, mod), False, False)

def ident(symbol, value_type=None, domain=1, mod=None, infix=False):
    return node("IDENTIFIER", domain, name(symbol, mod, infix), value_type, [])

def binder(symbol, value_type, domain, ident_domain=1):
    return node("BINDER", domain, ident(symbol, value_type, ident_domain), value_type)

def effects(writes=None):
    return node("EFFECTS", 1, None, writes, None)

def function(domain, symbol, binders=None, eff=None, pre=None, post=None,
             result=None, definition=None):
    return node("FUNCTION_DECL", domain, ident(symbol), binders, eff, pre, post,
                result, definition, [], None)

def alias(symbol, value_type):
    # why-gen-decl.adb:283-296: transparent definition explicitly uses EW_Prog.
    return node("TYPE_DECL", 1, None, name(symbol), [],
                node("TRANSPARENT_TYPE_DEFINITION", 4, value_type))

def metas(symbol):
    return [node("META_DECLARATION", 1, meta, "function " + symbol)
            for meta in ["model_projection", "inline:no"]]

int_type = typ("int")
bool_type = typ("bool")
int_module = module("int", "Int")
main_module = module("_gnatprove_standard", "Main")
string_module = module("", "Standard__string")
integer_module = module("", "Standard__integer")
positive_module = module("", "Standard__positive")
character_module = module("", "Standard__character")
array_module = module("", "Array__Int__Standard__character")
rep_module = module("", "Standard__integer___rep")
true_pred = node("LITERAL", 3, 0, None)

# why-gen-arrays.adb:1534-1623,2652-2807: unconstrained 1-dimensional String.
string_declarations = [alias("component_type", typ("character", True, character_module))]
string_declarations.append(function(1, "index_1_id", [binder("x", int_type, 1)],
                                    effects(), true_pred, true_pred, int_type,
                                    ident("x", int_type)))
substitutions = [
    (0, "map", "map", array_module),
    (2, "has_bounds", "has_bounds", array_module),
    (2, "eq_ext", "eq_ext", array_module),
    (1, "array_bool_eq", "bool_eq", array_module),
    (0, "index_base_type", "integer", integer_module),
    (0, "index_rep_type", "int", None),
    (1, "to_rep", "to_rep", rep_module),
    (1, "rep_to_int", "index_1_id", None),
    (2, "in_range_base", "in_range", integer_module),
    (2, "index_dynamic_property", "dynamic_property", positive_module),
    (2, "index_rep_le", "<=", int_module),
]
string_declarations.append(node("CLONE_DECLARATION", 1,
    module("ada__model", "Unconstr_Array"), "", 1,
    [node("CLONE_SUBSTITUTION", 1, kind, name(origin), name(image, mod, image == "<="))
     for kind, origin, image, mod in substitutions], 1))
string_declarations.append(alias("string__", typ("__t", True)))
for symbol in ["to_array", "first", "last"]:
    string_declarations.extend(metas(symbol))

# why-gen-decl.adb:94-268 and Translate_Type's Generate_Ref_Type_And_Havoc_Fun.
local_string = typ("string__", True)
string_ref = typ("string____ref", True)
content = ident("string____content", local_string)
string_declarations.append(node("TYPE_DECL", 1, None, name("string____ref"), [],
    node("RECORD_DEFINITION", 1,
         [node("RECORD_BINDER", 1, content, local_string, [], True)])))
projection = "string____ref_string____content__projection"
string_declarations.append(function(1, projection, [binder("a", string_ref, 4)],
    result=local_string, definition=node("RECORD_ACCESS", 1, ident("a", string_ref), content, None)))
string_declarations.extend(metas(projection))
string_declarations.append(function(4, "string____havoc", [binder("x", string_ref, 4, 4)],
    effects([ident("x", string_ref, 4)]), result=typ("unit")))

# Close_Theory adds Main, Int, then Compute_Module_Set's ordered dependencies.
string_includes = [node("INCLUDE_DECLARATION", 1, mod, 1, use)
    for mod, use in [(main_module, 0), (int_module, 0), (int_module, 0),
                     (integer_module, 2), (positive_module, 2), (character_module, 2),
                     (array_module, 2), (rep_module, 2)]]
string_expected = node("THEORY_DECLARATION", 4, string_declarations, "Standard__string", 1,
    string_includes, 'Module for axiomatizing type "string", created in Gnat2Why.Types.Translate_Type')

# why-gen-arrays.adb:1629-1766; why-gen-binders.adb:1282-1307,1346-1370,1392-1411.
image_type = typ("__image", True, main_module)
string_type = typ("string__", True, string_module)
image_binders = lambda domain: [binder("x", image_type, domain), binder("s", int_type, domain)]
image_declarations = [
    function(2, "to_string", image_binders(2), effects(), true_pred, true_pred, string_type),
    function(2, "from_string", [binder("x", string_type, 2)], effects(), true_pred, true_pred, image_type),
]
call = node("CALL", 1, ident("to_string"), [ident("x", image_type), ident("s", int_type)], string_type)
triggers = node("TRIGGERS", 1, [node("TRIGGER", 1, [call])])
dep = node("AXIOM_DEP", 1, ident("to_string"), 0)

def comparison(symbol, left, right, mod=None):
    return node("CALL", 3, ident(symbol, bool_type, mod=mod, infix=True), [left, right], bool_type)

first = node("CALL", 1, ident("first", int_type, mod=string_module), [call], int_type)
length = node("CALL", 1, ident("length", int_type, mod=string_module), [call], int_type)
guard = comparison(">=", ident("s", int_type), node("INTEGER_CONSTANT", 1, "0"), int_module)
assertions = [
    ("to_string__first", comparison("=", first, node("INTEGER_CONSTANT", 1, "1"))),
    ("to_string__length", node("CONNECTION", 3, guard, 2,
        comparison("<=", length, ident("s", int_type), int_module), None)),
    ("to_string__wf", node("CALL", 3, ident("well_formed", domain=3, mod=string_module), [call], None)),
]
for symbol, assertion in assertions:
    image_declarations.append(node("AXIOM", 1, symbol,
        node("UNIVERSAL_QUANTIF", 3, image_binders(3), [], triggers, assertion), dep))
image_includes = [node("INCLUDE_DECLARATION", 1, mod, 1, use) for mod, use in
                  [(int_module, 0), (string_module, 2), (main_module, 0), (int_module, 0)]]
image_expected = node("THEORY_DECLARATION", 4, image_declarations, "Standard_String__Img", 1,
    image_includes, "Module defining to_string/of_string functions, created in Gnat2Why.Types.Translate_Type")

source_path = Path("src/silver_image_model_templates.adb")
source = source_path.read_text()
results = {}
for label, expected in [("String", string_expected), ("Image", image_expected)]:
    match = re.search(label + r"_Template_Data\s*:.*?:=\s*\((.*?)\);", source, re.S)
    assert match is not None
    raw = "".join(chunk.replace('""', '"') for chunk in
                  re.findall(r'\d+\s*=>\s*"((?:""|[^"])*)"', match.group(1))).rstrip()
    actual = json.loads(raw)
    compact = json.dumps(expected, separators=(",", ":"), ensure_ascii=True)
    assert actual == expected, label + " full producer-constructor tree differs"
    assert raw == compact, label + " canonical bytes differ"
    nodes, strings, numbers = [], [], []
    def visit(value):
        if isinstance(value, list):
            if value and isinstance(value[0], str) and value[0].startswith("W_"):
                nodes.append(value)
            for item in value:
                visit(item)
        elif isinstance(value, str): strings.append(value)
        elif type(value) is int: numbers.append(value)
    visit(expected)
    results[label] = {"result": "exact constructor-tree and canonical-byte parity; IDs alone normalized",
        "declarations": len(expected[3]), "includes": len(expected[6]), "canonical_bytes": len(raw.encode()),
        "canonical_sha256": hashlib.sha256(raw.encode()).hexdigest(), "serialized_node_occurrences": len(nodes),
        "max_decoded_string_bytes": max(map(len, strings)), "max_number_with_zeroed_ids": max(numbers),
        "node_kinds": dict(sorted(Counter(item[0] for item in nodes).items()))}
print(json.dumps({"template_file_sha256": hashlib.sha256(source_path.read_bytes()).hexdigest(),
                  "templates": results}, indent=2))

module

public import Silver.ApplicationPackageDeclarationsReaderSourceRequirements

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ReaderSourceChecks
namespace SpecificationTokens

/- Original procedure and appended Object header SHA-256 70b741d1d1adf438e07a1f26bbc3a7fa42c08ee42f178483323d8e752832b6f9 -/
def header : List String := [
  "procedure", "package_spec_at", "(", "text", ":", "string", ";", "info", ":", "in", "out", "packages",
  ".", "metadata", ";", "exports", ":", "out", "parser_state", ")", "with", "global", "=>", "null",
  ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'",
  "length", "in", "1", "..", "max_source_length", ",", "post", "=>", "valid_state", "(", "text", ",",
  "exports", ")", "is"
]

def declarations : List String := [
  "first", ":", "constant", "literal_position", ":=", "skip_at", "(", "text", ",", "package_word", "(", "text",
  ",", "1", ",", "\"package\"", ")", ")", ";", "last", ":", "constant", "literal_position", ":=",
  "name_after", "(", "text", ",", "first", ")", ";", "next", ":", "parser_state", ";", "object",
  ":", "package_object_result", ";", "export", ":", "packages", ".", "export_declaration", ";", "end_first", ",", "end_last",
  ",", "following", ":", "literal_position", ";", "before", ":", "literal_position", ";"
]

def beginBody : List String := [
  "begin"
]

def entry : List String := [
  "exports", ":=", "invalid_state", ";", "if", "not", "package_name_allowed", "(", "text", ",", "(", "first",
  ",", "last", ")", ")", "then", "return", ";", "end", "if", ";", "info", ".",
  "name_first", ":=", "first", ";", "info", ".", "name_after", ":=", "last", ";", "exports", ":=",
  "(", "initial_state", "with", "delta", "position", "=>", "spark_pragma_after", "(", "text", ",", "take_token", "(",
  "text", ",", "last", ",", "is_keyword", ")", ")", ",", "package_first", "=>", "first", ",",
  "package_after", "=>", "last", ")", ";", "if", "exports", ".", "position", "=", "0", "then",
  "return", ";", "end", "if", ";"
]

def openLoop : List String := [
  "loop"
]

def untilRoutine : List String := [
  "pragma", "loop_invariant", "(", "valid_state", "(", "text", ",", "exports", ")", ")", ";", "pragma",
  "loop_invariant", "(", "exports", ".", "position", ">", "0", ")", ";", "pragma", "loop_variant", "(",
  "increases", "=>", "exports", ".", "position", ")", ";", "before", ":=", "exports", ".", "position",
  ";", "exit", "when", "take_token", "(", "text", ",", "exports", ".", "position", ",", "end_keyword",
  ")", "/=", "0", ";", "if", "take_token", "(", "text", ",", "exports", ".", "position",
  ",", "function_keyword", ")", "/=", "0", "or", "else", "take_token", "(", "text", ",", "exports",
  ".", "position", ",", "procedure_keyword", ")", "/=", "0", "then"
]

def signatureBranch : List String := [
  "package_signature_at", "(", "text", ",", "exports", ",", "info", ",", "false", ",", "next", ")",
  ";", "if", "next", ".", "position", "=", "0", "or", "else", "info", ".", "routine_count",
  "=", "0", "then", "exports", ":=", "invalid_state", ";", "return", ";", "end", "if", ";",
  "exports", ".", "position", ":=", "next", ".", "position", ";", "exports", ".", "hiding", ":=",
  "hide_name", "(", "text", ",", "exports", ".", "hiding", ",", "info", ".", "routines", "(",
  "info", ".", "routine_count", ")", ".", "spec_name", ".", "first", ",", "info", ".", "routines",
  "(", "info", ".", "routine_count", ")", ".", "spec_name", ".", "after", ")", ";"
]

def untilSubtype : List String := [
  "else", "if", "info", ".", "export_count", "=", "packages", ".", "max_exports", "then", "exports", ":=",
  "invalid_state", ";", "return", ";", "end", "if", ";", "if", "take_token", "(", "text", ",",
  "exports", ".", "position", ",", "subtype_keyword", ")", "/=", "0", "then"
]

def subtypeBranch : List String := [
  "next", ":=", "subtype_declaration_at", "(", "text", ",", "exports", ",", "false", ")", ";", "if",
  "next", ".", "position", "=", "0", "then", "exports", ":=", "invalid_state", ";", "return", ";",
  "end", "if", ";", "declare", "item", ":", "constant", "subtype_binding", ":=", "next", ".", "subtype_names",
  ".", "items", "(", "next", ".", "subtype_names", ".", "count", ")", ";", "begin", "if",
  "not", "package_name_fresh", "(", "text", ",", "info", ",", "(", "item", ".", "first", ",",
  "item", ".", "after", ")", ")", "then", "exports", ":=", "invalid_state", ";", "return", ";",
  "end", "if", ";", "export", ":=", "(", "name", "=>", "(", "item", ".", "first",
  ",", "item", ".", "after", ")", ",", "kind", "=>", "packages", ".", "integer_subtype", ",",
  "bounds", "=>", "item", ".", "bounds", ",", "type_identity", "=>", "info", ".", "export_count", "+",
  "2", ",", "others", "=>", "<", ">", ")", ";", "end", ";"
]

def beforeObject : List String := [
  "else"
]

def objectBranch : List String := [
  "object", ":=", "package_object_at", "(", "text", ",", "exports", ",", "info", ")", ";", "if",
  "object", ".", "frame", ".", "position", "=", "0", "or", "else", "not", "object", ".",
  "constant_object", "then", "exports", ":=", "invalid_state", ";", "return", ";", "end", "if", ";", "next",
  ":=", "object", ".", "frame", ";", "export", ":=", "(", "name", "=>", "object", ".",
  "name", ",", "kind", "=>", "packages", ".", "boolean_constant", ",", "bounds", "=>", "scalars", ".",
  "full", ",", "type_name", "=>", "object", ".", "mark", ".", "name", ",", "type_identity", "=>",
  "object", ".", "mark", ".", "identity", ",", "initializer_first", "=>", "object", ".", "init_first", ",",
  "initializer_after", "=>", "object", ".", "init_after", ",", "boolean_value", "=>", "object", ".", "boolean_value", ")",
  ";", "if", "object", ".", "mark", ".", "kind", "=", "functions", ".", "integer_kind", "then",
  "export", ".", "kind", ":=", "packages", ".", "integer_constant", ";", "export", ".", "bounds", ":=",
  "object", ".", "initial_bounds", ";", "end", "if", ";"
]

def endObject : List String := [
  "end", "if", ";"
]

def storeExport : List String := [
  "info", ".", "export_count", ":=", "info", ".", "export_count", "+", "1", ";", "info", ".",
  "exports", "(", "info", ".", "export_count", ")", ":=", "export", ";", "exports", ":=", "next",
  ";"
]

def endRoutine : List String := [
  "end", "if", ";"
]

def progressCheck : List String := [
  "if", "exports", ".", "position", "<=", "before", "or", "else", "not", "valid_state", "(", "text",
  ",", "exports", ")", "then", "exports", ":=", "invalid_state", ";", "return", ";", "end", "if",
  ";"
]

def closeLoop : List String := [
  "end", "loop", ";"
]

def finish : List String := [
  "end_first", ":=", "skip_at", "(", "text", ",", "take_token", "(", "text", ",", "exports", ".",
  "position", ",", "end_keyword", ")", ")", ";", "end_last", ":=", "name_after", "(", "text", ",",
  "end_first", ")", ";", "following", ":=", "take_token", "(", "text", ",", "end_last", ",", "semicolon",
  ")", ";", "if", "info", ".", "routine_count", "=", "0", "or", "else", "not", "packages",
  ".", "same_name", "(", "text", ",", "(", "first", ",", "last", ")", ",", "(",
  "end_first", ",", "end_last", ")", ")", "or", "else", "following", "=", "0", "or", "else",
  "skip_at", "(", "text", ",", "following", ")", "/=", "text", "'", "last", "+", "1",
  "then", "exports", ":=", "invalid_state", ";", "else", "exports", ".", "position", ":=", "following", ";",
  "end", "if", ";"
]

def endBody : List String := [
  "end", "package_spec_at", ";"
]

def objectDeclaration : List String := [
  "function", "package_object_at", "(", "text", ":", "string", ";", "frame", ":", "parser_state", ";", "info",
  ":", "packages", ".", "metadata", ";", "local", ":", "boolean", ":=", "false", ")", "return",
  "package_object_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=",
  "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then",
  "valid_state", "(", "text", ",", "frame", ")", ",", "post", "=>", "valid_state", "(", "text",
  ",", "package_object_at", "'", "result", ".", "frame", ")", "and", "then", "package_object_at", "'", "result",
  ".", "init_first", "<=", "text", "'", "last", "+", "1", "and", "then", "package_object_at", "'",
  "result", ".", "init_after", "<=", "text", "'", "last", "+", "1", "and", "then", "(",
  "package_object_at", "'", "result", ".", "frame", ".", "position", "=", "0", "or", "else", "package_object_at",
  "'", "result", ".", "frame", ".", "position", ">", "frame", ".", "position", ")", "is"
]

def iteration : List String :=
  untilRoutine ++ signatureBranch ++ untilSubtype ++ subtypeBranch ++ beforeObject ++ objectBranch ++
    endObject ++ storeExport ++ endRoutine ++ progressCheck

def body : List String :=
  declarations ++ beginBody ++ entry ++ openLoop ++ iteration ++ closeLoop ++ finish ++ endBody

end SpecificationTokens

def specificationProfile : List String :=
  SpecificationTokens.header ++ SpecificationTokens.body ++ SpecificationTokens.objectDeclaration

/- Copied source fragment SHA-256 bd8806fa2864ae1490ef6dced61f4a9e255f1e8eab7b27a3b66da61f1af96bb1 -/
def specificationPackages : List String := [
  "type", "export_declaration", "is", "record", "name", ":", "name_span", ":=", "no_name", ";", "kind", ":",
  "export_kind", ":=", "integer_subtype", ";", "bounds", ":", "silver_scalars", ".", "interval", ":=", "silver_scalars", ".",
  "empty", ";", "type_name", ":", "name_span", ":=", "no_name", ";", "type_identity", ":", "type_id", ":=",
  "integer_type", ";", "initializer_first", ",", "initializer_after", ":", "literal_position", ":=", "0", ";", "boolean_value", ":",
  "boolean", ":=", "false", ";", "end", "record", ";"
]

open Silver.SourceBridge
open ApplicationPackageBodies.SourceChecks (ordinaryProcedure)

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem specification_body_source : ordinaryProcedure "package_spec_at" specificationProfile = some SpecificationTokens.body :=
  by decide +kernel

theorem specification_header_source : procedureHeader "package_spec_at" "is" specificationProfile = some specificationHeader :=
  by decide +kernel

theorem specification_object_header_source :
    functionHeader "package_object_at" "is" specificationProfile = some ObjectSourceChecks.objectHeader := by decide +kernel

end Silver.ApplicationPackageDeclarations.ReaderSourceChecks

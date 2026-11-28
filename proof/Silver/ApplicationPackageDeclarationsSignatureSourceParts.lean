module

public import Silver.ApplicationPackageDeclarationsReaderSourceRequirements

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ReaderSourceChecks
namespace SignatureTokens

/- Original procedure updated for the unit-preservation contract in 1013fedd26.
The appended helper header is unchanged. Actual-source binding is checked separately. -/
def header : List String := [
  "procedure", "package_signature_at", "(", "text", ":", "string", ";", "outer", ":", "parser_state", ";", "info",
  ":", "in", "out", "packages", ".", "metadata", ";", "completing", ":", "boolean", ";", "header",
  ":", "out", "parser_state", ")", "with", "global", "=>", "null", ",", "pre", "=>", "text",
  "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..",
  "max_source_length", "and", "then", "valid_state", "(", "text", ",", "outer", ")", ",", "post", "=>",
  "info", ".", "units", "=", "info", ".", "units", "'", "old", "and", "then",
  "valid_state", "(", "text", ",", "header", ")", "and", "then", "(", "header", ".", "position",
  "=", "0", "or", "else", "header", ".", "position", ">", "outer", ".", "position", ")",
  "and", "then", "(", "if", "header", ".", "position", "/=", "0", "and", "then", "not",
  "completing", "then", "info", ".", "routine_count", ">", "0", "and", "then", "info", ".", "routines",
  "(", "info", ".", "routine_count", ")", ".", "spec_name", ".", "first", ">", "0", "and",
  "then", "valid_name_state", "(", "text", ",", "info", ".", "routines", "(", "info", ".", "routine_count",
  ")", ".", "spec_name", ".", "first", ",", "info", ".", "routines", "(", "info", ".",
  "routine_count", ")", ".", "spec_name", ".", "after", ")", ")", "is"
]

def declarations : List String := [
  "original", ":", "constant", "literal_position", ":=", "skip_at", "(", "text", ",", "outer", ".", "position",
  ")", ";", "function_end", ":", "constant", "literal_position", ":=", "take_token", "(", "text", ",", "outer",
  ".", "position", ",", "function_keyword", ")", ";", "procedure_end", ":", "constant", "literal_position", ":=", "take_token",
  "(", "text", ",", "outer", ".", "position", ",", "procedure_keyword", ")", ";", "name_first", ":",
  "constant", "literal_position", ":=", "skip_at", "(", "text", ",", "(", "if", "function_end", "/=", "0",
  "then", "function_end", "else", "procedure_end", ")", ")", ";", "name_after", ":", "constant", "literal_position", ":=",
  "silver_output_profile", ".", "name_after", "(", "text", ",", "name_first", ")", ";", "item", ":", "packages",
  ".", "routine", ";", "routine_id", ":", "packages", ".", "routine_count_type", ";", "formal_count", ":", "packages",
  ".", "formal_count_type", ":=", "0", ";", "formal_start", ":", "packages", ".", "formal_count_type", ":=", "0",
  ";", "open", ",", "first", ",", "last", ",", "next", ",", "mode_end", ":", "literal_position",
  ";", "mode", ":", "procedures", ".", "parameter_mode", ";", "mark", ":", "package_type_result", ";", "parameter",
  ":", "packages", ".", "formal", ";", "slot", ":", "packages", ".", "formal_count_type", ";", "before",
  ":", "literal_position", ";"
]

def beginBody : List String := [
  "begin"
]

def entry : List String := [
  "header", ":=", "invalid_state", ";", "if", "original", "=", "0", "or", "else", "(", "function_end",
  "=", "0", "and", "then", "procedure_end", "=", "0", ")", "or", "else", "name_first", "=",
  "0", "or", "else", "name_after", "<=", "name_first", "then", "return", ";", "end", "if", ";",
  "if", "completing", "then", "if", "info", ".", "completed", ">=", "info", ".", "routine_count", "then",
  "return", ";", "end", "if", ";", "routine_id", ":=", "info", ".", "completed", "+", "1",
  ";", "item", ":=", "info", ".", "routines", "(", "routine_id", ")", ";", "if", "item",
  ".", "count", ">", "0", "and", "then", "(", "item", ".", "formal_first", "=", "0",
  "or", "else", "item", ".", "formal_first", ">", "info", ".", "parameter_count", "or", "else", "item",
  ".", "count", ">", "info", ".", "parameter_count", "-", "item", ".", "formal_first", "+", "1",
  ")", "then", "return", ";", "end", "if", ";", "if", "not", "packages", ".", "same_name",
  "(", "text", ",", "item", ".", "spec_name", ",", "(", "name_first", ",", "name_after", ")",
  ")", "or", "else", "(", "item", ".", "kind", "=", "packages", ".", "function_routine", ")",
  "/=", "(", "function_end", "/=", "0", ")", "then", "return", ";", "end", "if", ";",
  "formal_start", ":=", "item", ".", "formal_first", ";", "item", ".", "body_name", ":=", "(", "name_first",
  ",", "name_after", ")", ";", "item", ".", "body_first", ":=", "original", ";", "else", "if",
  "info", ".", "routine_count", "=", "packages", ".", "max_routines", "or", "else", "not", "package_name_fresh", "(",
  "text", ",", "info", ",", "(", "name_first", ",", "name_after", ")", ")", "then", "return",
  ";", "end", "if", ";", "routine_id", ":=", "info", ".", "routine_count", "+", "1", ";",
  "item", ":=", "(", "others", "=>", "<", ">", ")", ";", "item", ".", "kind",
  ":=", "(", "if", "function_end", "/=", "0", "then", "packages", ".", "function_routine", "else", "packages",
  ".", "procedure_routine", ")", ";", "item", ".", "spec_name", ":=", "(", "name_first", ",", "name_after",
  ")", ";", "item", ".", "spec_first", ":=", "original", ";", "end", "if", ";", "header",
  ":=", "(", "outer", "with", "delta", "position", "=>", "name_after", ",", "pure", "=>", "true",
  ",", "hiding", "=>", "hide_name", "(", "text", ",", "outer", ".", "hiding", ",", "name_first",
  ",", "name_after", ")", ")", ";", "open", ":=", "take_token", "(", "text", ",", "header",
  ".", "position", ",", "left_parenthesis", ")", ";"
]

def openLoop : List String := [
  "if", "open", "/=", "0", "then", "header", ".", "position", ":=", "open", ";", "loop"
]

def invariants : List String := [
  "pragma", "loop_invariant", "(", "info", ".", "units", "=", "info", "'", "loop_entry", ".", "units", ")", ";",
  "pragma", "loop_invariant", "(", "valid_state", "(", "text", ",", "header", ")", ")", ";", "pragma",
  "loop_invariant", "(", "header", ".", "position", ">", "0", ")", ";", "pragma", "loop_invariant", "(",
  "formal_count", "<=", "info", ".", "parameter_count", ")", ";", "pragma", "loop_invariant", "(", "if", "formal_count",
  ">", "0", "then", "formal_start", ">", "0", "and", "then", "formal_start", "<=", "info", ".",
  "parameter_count", "and", "then", "formal_count", "<=", "info", ".", "parameter_count", "-", "formal_start", "+", "1",
  ")", ";", "pragma", "loop_invariant", "(", "if", "completing", "then", "formal_start", "=", "item", ".",
  "formal_first", "and", "then", "formal_count", "<=", "item", ".", "count", "and", "then", "info", ".",
  "parameter_count", "=", "info", "'", "loop_entry", ".", "parameter_count", ")", ";", "pragma", "loop_variant", "(",
  "increases", "=>", "header", ".", "position", ")", ";"
]

def readName : List String := [
  "before", ":=", "header", ".", "position", ";", "first", ":=", "skip_at", "(", "text", ",",
  "header", ".", "position", ")", ";", "last", ":=", "silver_output_profile", ".", "name_after", "(", "text",
  ",", "first", ")", ";", "if", "not", "packages", ".", "valid_name", "(", "text", ",",
  "(", "first", ",", "last", ")", ")", "then", "header", ":=", "invalid_state", ";", "return",
  ";", "end", "if", ";"
]

def selectSlot : List String := [
  "if", "completing", "then", "if", "formal_count", ">=", "item", ".", "count", "then", "header", ":=",
  "invalid_state", ";", "return", ";", "end", "if", ";", "slot", ":=", "formal_start", "+", "formal_count",
  ";", "else", "if", "info", ".", "parameter_count", "=", "packages", ".", "max_formals", "then", "header",
  ":=", "invalid_state", ";", "return", ";", "end", "if", ";", "slot", ":=", "info", ".",
  "parameter_count", "+", "1", ";", "if", "formal_count", "=", "0", "then", "formal_start", ":=", "slot",
  ";", "end", "if", ";", "end", "if", ";"
]

def hideOuter : List String := [
  "if", "formal_count", ">", "0", "and", "then", "(", "for", "some", "i", "in", "formal_start",
  "..", "formal_start", "+", "formal_count", "-", "1", "=>", "packages", ".", "same_name", "(", "text",
  ",", "(", "first", ",", "last", ")", ",", "(", "if", "completing", "then", "info",
  ".", "parameters", "(", "i", ")", ".", "body_name", "else", "info", ".", "parameters", "(",
  "i", ")", ".", "spec_name", ")", ")", ")", "then", "header", ":=", "invalid_state", ";",
  "return", ";", "end", "if", ";", "header", ":=", "hide_outer", "(", "text", ",", "header",
  ",", "info", ",", "(", "first", ",", "last", ")", ")", ";", "pragma", "assert",
  "(", "array_bindings", ".", "valid_environment", "(", "text", ",", "header", ".", "array_names", ")", ")",
  ";", "pragma", "assert", "(", "functions", ".", "valid_metadata", "(", "text", ",", "header", ".",
  "functions", ")", ")", ";", "if", "header", ".", "position", "=", "0", "then", "return",
  ";", "end", "if", ";"
]

def readMode : List String := [
  "next", ":=", "take_token", "(", "text", ",", "last", ",", "colon", ")", ";", "mode_end",
  ":=", "take_token", "(", "text", ",", "next", ",", "in_keyword", ")", ";", "if", "mode_end",
  "/=", "0", "then", "next", ":=", "take_token", "(", "text", ",", "mode_end", ",", "out_keyword",
  ")", ";", "mode", ":=", "(", "if", "next", "/=", "0", "then", "procedures", ".",
  "input_output", "else", "procedures", ".", "input", ")", ";", "if", "next", "=", "0", "then",
  "next", ":=", "mode_end", ";", "end", "if", ";", "else", "next", ":=", "take_token", "(",
  "text", ",", "next", ",", "out_keyword", ")", ";", "mode", ":=", "procedures", ".", "output",
  ";", "end", "if", ";", "if", "next", "=", "0", "or", "else", "(", "item",
  ".", "kind", "=", "packages", ".", "function_routine", "and", "then", "mode", "/=", "procedures", ".",
  "input", ")", "then", "header", ":=", "invalid_state", ";", "return", ";", "end", "if", ";",
  "mark", ":=", "package_type_at", "(", "text", ",", "header", ",", "info", ",", "next", ")",
  ";", "if", "mark", ".", "after", "=", "0", "then", "header", ":=", "invalid_state", ";",
  "return", ";", "end", "if", ";"
]

def storeParameter : List String := [
  "if", "completing", "then", "parameter", ":=", "info", ".", "parameters", "(", "slot", ")", ";",
  "if", "not", "packages", ".", "same_name", "(", "text", ",", "parameter", ".", "spec_name", ",",
  "(", "first", ",", "last", ")", ")", "or", "else", "parameter", ".", "mode", "/=",
  "mode", "or", "else", "parameter", ".", "kind", "/=", "mark", ".", "kind", "or", "else",
  "parameter", ".", "type_identity", "/=", "mark", ".", "identity", "or", "else", "parameter", ".", "bounds",
  "/=", "mark", ".", "bounds", "then", "header", ":=", "invalid_state", ";", "return", ";", "end",
  "if", ";", "parameter", ".", "body_name", ":=", "(", "first", ",", "last", ")", ";",
  "parameter", ".", "body_type_name", ":=", "mark", ".", "name", ";", "else", "parameter", ":=", "(",
  "spec_name", "=>", "(", "first", ",", "last", ")", ",", "spec_type_name", "=>", "mark", ".",
  "name", ",", "kind", "=>", "mark", ".", "kind", ",", "bounds", "=>", "mark", ".",
  "bounds", ",", "type_identity", "=>", "mark", ".", "identity", ",", "mode", "=>", "mode", ",",
  "others", "=>", "<", ">", ")", ";", "info", ".", "parameter_count", ":=", "slot", ";",
  "end", "if", ";", "info", ".", "parameters", "(", "slot", ")", ":=", "parameter", ";",
  "formal_count", ":=", "formal_count", "+", "1", ";", "header", ".", "position", ":=", "mark", ".",
  "after", ";", "append_package_formal", "(", "header", ",", "(", "first", ",", "last", ")", ",",
  "mark", ",", "mode", ")", ";", "pragma", "assert", "(", "array_bindings", ".", "valid_environment", "(",
  "text", ",", "header", ".", "array_names", ")", ")", ";", "pragma", "assert", "(", "functions",
  ".", "valid_metadata", "(", "text", ",", "header", ".", "functions", ")", ")", ";", "if",
  "header", ".", "position", "=", "0", "then", "return", ";", "end", "if", ";"
]

def endParameter : List String := [
  "next", ":=", "take_token", "(", "text", ",", "header", ".", "position", ",", "right_parenthesis", ")",
  ";", "if", "next", "/=", "0", "then", "header", ".", "position", ":=", "next", ";",
  "pragma", "assert", "(", "header", ".", "position", ">", "0", ")", ";", "pragma", "assert",
  "(", "valid_state", "(", "text", ",", "header", ")", ")", ";", "exit", ";", "end",
  "if", ";", "header", ".", "position", ":=", "take_token", "(", "text", ",", "header", ".",
  "position", ",", "semicolon", ")", ";", "if", "header", ".", "position", "<=", "before", "then",
  "header", ":=", "invalid_state", ";", "return", ";", "end", "if", ";"
]

def closeLoop : List String := [
  "end", "loop", ";", "end", "if", ";"
]

def finish : List String := [
  "if", "completing", "and", "then", "formal_count", "/=", "item", ".", "count", "then", "header", ":=",
  "invalid_state", ";", "return", ";", "end", "if", ";", "if", "not", "completing", "then", "item",
  ".", "count", ":=", "formal_count", ";", "item", ".", "formal_first", ":=", "formal_start", ";", "end",
  "if", ";", "if", "item", ".", "kind", "=", "packages", ".", "function_routine", "then", "mark",
  ":=", "package_type_at", "(", "text", ",", "header", ",", "info", ",", "take_token", "(", "text",
  ",", "header", ".", "position", ",", "return_keyword", ")", ")", ";", "if", "mark", ".",
  "after", "=", "0", "then", "header", ":=", "invalid_state", ";", "return", ";", "end", "if",
  ";", "if", "completing", "then", "if", "item", ".", "result_kind", "/=", "mark", ".", "kind",
  "or", "else", "item", ".", "result_type_identity", "/=", "mark", ".", "identity", "or", "else", "item",
  ".", "result_bounds", "/=", "mark", ".", "bounds", "then", "header", ":=", "invalid_state", ";", "return",
  ";", "end", "if", ";", "item", ".", "body_result_name", ":=", "mark", ".", "name", ";",
  "else", "item", ".", "result_kind", ":=", "mark", ".", "kind", ";", "item", ".", "result_bounds",
  ":=", "mark", ".", "bounds", ";", "item", ".", "result_type_identity", ":=", "mark", ".", "identity",
  ";", "item", ".", "spec_result_name", ":=", "mark", ".", "name", ";", "end", "if", ";",
  "header", ".", "position", ":=", "mark", ".", "after", ";", "end", "if", ";", "header",
  ".", "position", ":=", "take_token", "(", "text", ",", "header", ".", "position", ",", "(",
  "if", "completing", "then", "is_keyword", "else", "semicolon", ")", ")", ";", "if", "header", ".",
  "position", "<=", "outer", ".", "position", "or", "else", "not", "valid_state", "(", "text", ",",
  "header", ")", "then", "header", ":=", "invalid_state", ";", "return", ";", "end", "if", ";",
  "if", "not", "completing", "then", "item", ".", "spec_after", ":=", "header", ".", "position", ";",
  "info", ".", "routine_count", ":=", "routine_id", ";", "end", "if", ";", "info", ".", "routines",
  "(", "routine_id", ")", ":=", "item", ";"
]

def endBody : List String := [
  "end", "package_signature_at", ";"
]

def appendDeclaration : List String := [
  "procedure", "append_package_formal", "(", "frame", ":", "in", "out", "parser_state", ";", "name", ":", "packages",
  ".", "name_span", ";", "mark", ":", "package_type_result", ";", "mode", ":", "procedures", ".", "parameter_mode",
  ")", "with", "global", "=>", "null", ",", "pre", "=>", "name", ".", "first", ">",
  "0", "and", "then", "name", ".", "after", ">", "name", ".", "first", ",", "post",
  "=>", "frame", ".", "context_first", "=", "frame", "'", "old", ".", "context_first", "and", "then",
  "frame", ".", "package_first", "=", "frame", "'", "old", ".", "package_first", "and", "then", "frame",
  ".", "package_after", "=", "frame", "'", "old", ".", "package_after", "and", "then", "frame", ".",
  "functions", "=", "frame", "'", "old", ".", "functions", "and", "then", "frame", ".", "procedures",
  "=", "frame", "'", "old", ".", "procedures", "and", "then", "frame", ".", "first_parameter", "=",
  "frame", "'", "old", ".", "first_parameter", "and", "then", "frame", ".", "first_procedure_parameter", "=", "frame",
  "'", "old", ".", "first_procedure_parameter", "and", "then", "frame", ".", "names", "=", "frame", "'",
  "old", ".", "names", "and", "then", "frame", ".", "array_names", "=", "frame", "'", "old",
  ".", "array_names", "and", "then", "frame", ".", "subtype_names", "=", "frame", "'", "old", ".",
  "subtype_names", "and", "then", "frame", ".", "dynamic_first", "=", "frame", "'", "old", ".", "dynamic_first",
  "and", "then", "frame", ".", "dynamic_after", "=", "frame", "'", "old", ".", "dynamic_after", "and",
  "then", "frame", ".", "target", "=", "frame", "'", "old", ".", "target", "and", "then",
  "frame", ".", "pure", "=", "frame", "'", "old", ".", "pure", "and", "then", "frame",
  ".", "assigned_in_functions", "=", "frame", "'", "old", ".", "assigned_in_functions", "and", "then", "frame", ".",
  "hiding", "=", "frame", "'", "old", ".", "hiding", "and", "then", "frame", ".", "capacity",
  "=", "frame", "'", "old", ".", "capacity", "and", "then", "(", "if", "mark", ".",
  "kind", "=", "functions", ".", "integer_kind", "and", "then", "frame", "'", "old", ".", "scalar_names",
  ".", "count", "<", "scalar_expressions", ".", "max_bindings", "then", "frame", "=", "(", "frame", "'",
  "old", "with", "delta", "scalar_names", "=>", "scalar_expressions", ".", "append", "(", "frame", "'", "old",
  ".", "scalar_names", ",", "(", "name", ".", "first", ",", "name", ".", "after", ",",
  "mark", ".", "bounds", ",", "false", ",", "mark", ".", "bounds", ",", "mode", "/=",
  "procedures", ".", "input", ",", "0", ",", "0", ")", ")", ")", "elsif", "mark",
  ".", "kind", "=", "functions", ".", "boolean_kind", "and", "then", "frame", "'", "old", ".",
  "boolean_names", ".", "count", "<", "max_boolean_bindings", "then", "frame", "=", "(", "frame", "'", "old",
  "with", "delta", "boolean_names", "=>", "(", "count", "=>", "frame", "'", "old", ".", "boolean_names",
  ".", "count", "+", "1", ",", "items", "=>", "(", "frame", "'", "old", ".",
  "boolean_names", ".", "items", "with", "delta", "frame", "'", "old", ".", "boolean_names", ".", "count",
  "+", "1", "=>", "(", "name", ".", "first", ",", "name", ".", "after", ",",
  "mode", "/=", "procedures", ".", "input", ",", "0", ",", "0", ",", "false", ",",
  "false", ")", ")", ")", ")", "else", "frame", "=", "(", "frame", "'", "old",
  "with", "delta", "position", "=>", "0", ")", ")", "is"
]

def iteration : List String :=
  invariants ++ readName ++ selectSlot ++ hideOuter ++ readMode ++ storeParameter ++ endParameter

def body : List String :=
  declarations ++ beginBody ++ entry ++ openLoop ++ iteration ++ closeLoop ++ finish ++ endBody

end SignatureTokens

def signatureProfile : List String :=
  SignatureTokens.header ++ SignatureTokens.body ++ SignatureTokens.appendDeclaration

/- Copied source fragment SHA-256 7763474a5523abfa17cac3c29a9b6c6e2d90b848de43bb972368088528c05116 -/
def signaturePackages : List String := [
  "type", "routine", "is", "record", "kind", ":", "routine_kind", ":=", "procedure_routine", ";", "spec_name", ",",
  "body_name", ":", "name_span", ":=", "no_name", ";", "spec_first", ",", "spec_after", ":", "literal_position", ":=",
  "0", ";", "body_first", ",", "body_after", ":", "literal_position", ":=", "0", ";", "formal_first", ":",
  "formal_count_type", ":=", "0", ";", "count", ":", "formal_count_type", ":=", "0", ";", "result_kind", ":",
  "silver_function_bindings", ".", "scalar_kind", ":=", "silver_function_bindings", ".", "integer_kind", ";", "result_bounds", ":", "silver_scalars", ".",
  "interval", ":=", "silver_scalars", ".", "empty", ";", "result_type_identity", ":", "type_id", ":=", "integer_type", ";",
  "spec_result_name", ",", "body_result_name", ":", "name_span", ":=", "no_name", ";", "may_read", ",", "may_write", ":",
  "state_set", ":=", "empty_state_set", ";", "assigned", ":", "boolean", ":=", "false", ";", "end", "record",
  ";", "type", "formal", "is", "record", "spec_name", ",", "body_name", ":", "name_span", ":=", "no_name",
  ";", "spec_type_name", ",", "body_type_name", ":", "name_span", ":=", "no_name", ";", "kind", ":", "silver_function_bindings",
  ".", "scalar_kind", ":=", "silver_function_bindings", ".", "integer_kind", ";", "bounds", ":", "silver_scalars", ".", "interval",
  ":=", "silver_scalars", ".", "empty", ";", "type_identity", ":", "type_id", ":=", "integer_type", ";", "mode",
  ":", "silver_procedure_bindings", ".", "parameter_mode", ":=", "silver_procedure_bindings", ".", "input", ";", "end", "record", ";"
]

/- Copied source fragment SHA-256 f956db173017e9e078bc29a5a7a9281077083c03e260fe0431464f0310e833a5 -/
def scalarAppendCandidate : List String := [
  "function", "append", "(", "names", ":", "environment", ";", "item", ":", "binding", ")", "return",
  "environment", "is", "(", "(", "count", "=>", "names", ".", "count", "+", "1", ",",
  "items", "=>", "(", "names", ".", "items", "with", "delta", "names", ".", "count", "+",
  "1", "=>", "item", ")", ")", ")", "with", "pre", "=>", "names", ".", "count",
  "<", "max_bindings", ";"
]

open Silver.SourceBridge
open ApplicationPackageBodies.SourceChecks (ordinaryProcedure)

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

theorem signature_body_source : ordinaryProcedure "package_signature_at" signatureProfile = some SignatureTokens.body :=
  by decide +kernel

theorem signature_header_source : procedureHeader "package_signature_at" "is" signatureProfile = some signatureHeader :=
  by decide +kernel

theorem signature_append_header_source : procedureHeader "append_package_formal" "is" signatureProfile = some appendHeader :=
  by decide +kernel

end Silver.ApplicationPackageDeclarations.ReaderSourceChecks

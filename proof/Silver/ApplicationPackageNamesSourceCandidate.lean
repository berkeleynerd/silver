module

public import Silver.ApplicationPackageNamesSourceRequirements
import all Init.Data.Repr

@[expose] public section

/-! Focused source-tree witness copied from the six actual helper definitions.
This fragment check is not the final authoritative whole-profile source binding;
that binding must instantiate the same Checked predicate on certified full tokens. -/
namespace Silver.ApplicationPackageNames.SourceChecks
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/- This literal token proposal avoids repeatedly evaluating the copied fragment's
lexer. It carries no authoritative-source claim. The full certified lexer tokens
must separately satisfy Checked at integration. Original fragment SHA256:
433d544268f5838b8a06e944d96f2fecf4c54769328c48615121d57430d40e2b -/
def candidateTokens : List String := [
  "function", "package_word", "(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "word",
  ":", "string", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>",
  "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1",
  "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and",
  "then", "word", "'", "first", "=", "1", "and", "then", "word", "'", "length", "in",
  "1", "..", "16", ",", "post", "=>", "package_word", "'", "result", "=", "0", "or",
  "else", "package_word", "'", "result", "in", "position", "+", "1", "..", "text", "'", "last",
  "+", "1", "is", "first", ":", "constant", "literal_position", ":=", "skip_at", "(", "text", ",",
  "position", ")", ";", "after", ":", "constant", "literal_position", ":=", "name_after", "(", "text", ",",
  "first", ")", ";", "begin", "return", "(", "if", "first", "/=", "0", "and", "then",
  "after", ">", "first", "and", "then", "name_is", "(", "text", ",", "first", ",", "after",
  ",", "word", ")", "then", "after", "else", "0", ")", ";", "end", "package_word", ";",
  "function", "spark_pragma_after", "(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return",
  "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=",
  "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then",
  "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "spark_pragma_after", "'",
  "result", "=", "0", "or", "else", "spark_pragma_after", "'", "result", "in", "position", "+", "1",
  "..", "text", "'", "last", "+", "1", "is", "begin", "return", "take_token", "(", "text",
  ",", "take_token", "(", "text", ",", "take_token", "(", "text", ",", "take_token", "(", "text",
  ",", "take_token", "(", "text", ",", "take_token", "(", "text", ",", "position", ",", "pragma_keyword",
  ")", ",", "spark_mode_name", ")", ",", "left_parenthesis", ")", ",", "on_name", ")", ",", "right_parenthesis",
  ")", ",", "semicolon", ")", ";", "end", "spark_pragma_after", ";", "function", "package_name_allowed", "(", "text",
  ":", "string", ";", "name", ":", "packages", ".", "name_span", ")", "return", "boolean", "is",
  "(", "packages", ".", "valid_name", "(", "text", ",", "name", ")", "and", "then", "not",
  "forbidden_name", "(", "text", ",", "name", ".", "first", ",", "name", ".", "after", ")",
  "and", "then", "not", "name_is", "(", "text", ",", "name", ".", "first", ",", "name",
  ".", "after", ",", "\"main\"", ")", "and", "then", "not", "name_is", "(", "text", ",",
  "name", ".", "first", ",", "name", ".", "after", ",", "\"ada\"", ")", "and", "then",
  "not", "name_is", "(", "text", ",", "name", ".", "first", ",", "name", ".", "after",
  ",", "\"interfaces\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name", ".",
  "first", ",", "name", ".", "after", ",", "\"system\"", ")", "and", "then", "not", "name_is",
  "(", "text", ",", "name", ".", "first", ",", "name", ".", "after", ",", "\"gnat\"",
  ")", "and", "then", "not", "name_is", "(", "text", ",", "name", ".", "first", ",",
  "name", ".", "after", ",", "\"silver_arguments\"", ")", "and", "then", "not", "name_is", "(", "text",
  ",", "name", ".", "first", ",", "name", ".", "after", ",", "\"silver_output_libc\"", ")", "and",
  "then", "not", "name_is", "(", "text", ",", "name", ".", "first", ",", "name", ".",
  "after", ",", "\"silver_runtime\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name",
  ".", "first", ",", "name", ".", "after", ",", "\"boolean\"", ")", "and", "then", "not",
  "name_is", "(", "text", ",", "name", ".", "first", ",", "name", ".", "after", ",",
  "\"false\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name", ".", "first",
  ",", "name", ".", "after", ",", "\"true\"", ")", "and", "then", "not", "name_is", "(",
  "text", ",", "name", ".", "first", ",", "name", ".", "after", ",", "\"integer\"", ")",
  "and", "then", "not", "name_is", "(", "text", ",", "name", ".", "first", ",", "name",
  ".", "after", ",", "\"natural\"", ")", "and", "then", "not", "name_is", "(", "text", ",",
  "name", ".", "first", ",", "name", ".", "after", ",", "\"positive\"", ")", "and", "then",
  "not", "name_is", "(", "text", ",", "name", ".", "first", ",", "name", ".", "after",
  ",", "\"short_short_integer\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name", ".",
  "first", ",", "name", ".", "after", ",", "\"short_integer\"", ")", "and", "then", "not", "name_is",
  "(", "text", ",", "name", ".", "first", ",", "name", ".", "after", ",", "\"long_integer\"",
  ")", "and", "then", "not", "name_is", "(", "text", ",", "name", ".", "first", ",",
  "name", ".", "after", ",", "\"long_long_integer\"", ")", "and", "then", "not", "name_is", "(", "text",
  ",", "name", ".", "first", ",", "name", ".", "after", ",", "\"long_long_long_integer\"", ")", "and",
  "then", "not", "name_is", "(", "text", ",", "name", ".", "first", ",", "name", ".",
  "after", ",", "\"short_float\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name",
  ".", "first", ",", "name", ".", "after", ",", "\"float\"", ")", "and", "then", "not",
  "name_is", "(", "text", ",", "name", ".", "first", ",", "name", ".", "after", ",",
  "\"long_float\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name", ".", "first",
  ",", "name", ".", "after", ",", "\"long_long_float\"", ")", "and", "then", "not", "name_is", "(",
  "text", ",", "name", ".", "first", ",", "name", ".", "after", ",", "\"character\"", ")",
  "and", "then", "not", "name_is", "(", "text", ",", "name", ".", "first", ",", "name",
  ".", "after", ",", "\"wide_character\"", ")", "and", "then", "not", "name_is", "(", "text", ",",
  "name", ".", "first", ",", "name", ".", "after", ",", "\"wide_wide_character\"", ")", "and", "then",
  "not", "name_is", "(", "text", ",", "name", ".", "first", ",", "name", ".", "after",
  ",", "\"string\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name", ".",
  "first", ",", "name", ".", "after", ",", "\"wide_string\"", ")", "and", "then", "not", "name_is",
  "(", "text", ",", "name", ".", "first", ",", "name", ".", "after", ",", "\"wide_wide_string\"",
  ")", "and", "then", "not", "name_is", "(", "text", ",", "name", ".", "first", ",",
  "name", ".", "after", ",", "\"duration\"", ")", "and", "then", "not", "name_is", "(", "text",
  ",", "name", ".", "first", ",", "name", ".", "after", ",", "\"constraint_error\"", ")", "and",
  "then", "not", "name_is", "(", "text", ",", "name", ".", "first", ",", "name", ".",
  "after", ",", "\"program_error\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name",
  ".", "first", ",", "name", ".", "after", ",", "\"storage_error\"", ")", "and", "then", "not",
  "name_is", "(", "text", ",", "name", ".", "first", ",", "name", ".", "after", ",",
  "\"tasking_error\"", ")", "and", "then", "not", "name_is", "(", "text", ",", "name", ".", "first",
  ",", "name", ".", "after", ",", "\"numeric_error\"", ")", "and", "then", "not", "name_is", "(",
  "text", ",", "name", ".", "first", ",", "name", ".", "after", ",", "\"ascii\"", ")",
  ")", "with", "global", "=>", "null", ";", "function", "package_name_fresh", "(", "text", ":", "string",
  ";", "info", ":", "packages", ".", "metadata", ";", "name", ":", "packages", ".", "name_span",
  ")", "return", "boolean", "is", "(", "packages", ".", "valid_name", "(", "text", ",", "name",
  ")", "and", "then", "not", "forbidden_name", "(", "text", ",", "name", ".", "first", ",",
  "name", ".", "after", ")", "and", "then", "not", "packages", ".", "same_name", "(", "text",
  ",", "name", ",", "(", "info", ".", "name_first", ",", "info", ".", "name_after", ")",
  ")", "and", "then", "packages", ".", "lookup_export", "(", "text", ",", "info", ",", "name",
  ")", "=", "0", "and", "then", "packages", ".", "lookup_state", "(", "text", ",", "info",
  ",", "name", ")", "=", "0", "and", "then", "(", "for", "all", "i", "in",
  "1", "..", "info", ".", "routine_count", "=>", "not", "packages", ".", "same_name", "(", "text",
  ",", "name", ",", "info", ".", "routines", "(", "i", ")", ".", "spec_name", ")",
  ")", ")", "with", "global", "=>", "null", ";", "type", "package_type_result", "is", "record", "name",
  ":", "packages", ".", "name_span", ":=", "packages", ".", "no_name", ";", "after", ":", "literal_position",
  ":=", "0", ";", "kind", ":", "functions", ".", "scalar_kind", ":=", "functions", ".", "integer_kind",
  ";", "bounds", ":", "scalars", ".", "interval", ":=", "scalars", ".", "empty", ";", "identity",
  ":", "packages", ".", "type_id", ":=", "packages", ".", "integer_type", ";", "end", "record", ";",
  "invalid_package_type", ":", "constant", "package_type_result", ":=", "(", "others", "=>", "<", ">", ")", ";",
  "function", "package_type_at", "(", "text", ":", "string", ";", "frame", ":", "parser_state", ";", "info",
  ":", "packages", ".", "metadata", ";", "position", ":", "literal_position", ")", "return", "package_type_result", "with",
  "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and",
  "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(",
  "text", ",", "frame", ")", "and", "then", "position", "<=", "text", "'", "last", "+",
  "1", ",", "post", "=>", "package_type_at", "'", "result", ".", "after", "=", "0", "or",
  "else", "(", "package_type_at", "'", "result", ".", "after", "in", "position", "+", "1", "..",
  "text", "'", "last", "+", "1", "and", "then", "packages", ".", "valid_name", "(", "text",
  ",", "package_type_at", "'", "result", ".", "name", ")", "and", "then", "not", "scalars", ".",
  "is_empty", "(", "package_type_at", "'", "result", ".", "bounds", ")", ")", "is", "first", ":",
  "constant", "literal_position", ":=", "skip_at", "(", "text", ",", "position", ")", ";", "last", ":",
  "constant", "literal_position", ":=", "name_after", "(", "text", ",", "first", ")", ";", "value", ":",
  "constant", "function_type_result", ":=", "function_type_at", "(", "text", ",", "frame", ",", "position", ")", ";",
  "export", ":", "constant", "packages", ".", "export_count_type", ":=", "packages", ".", "lookup_export", "(", "text",
  ",", "info", ",", "(", "first", ",", "last", ")", ")", ";", "begin", "if",
  "not", "packages", ".", "valid_name", "(", "text", ",", "(", "first", ",", "last", ")",
  ")", "or", "else", "value", ".", "after", "/=", "last", "then", "return", "invalid_package_type", ";",
  "elsif", "value", ".", "kind", "=", "functions", ".", "boolean_kind", "then", "return", "(", "(",
  "first", ",", "last", ")", ",", "last", ",", "value", ".", "kind", ",", "scalars",
  ".", "full", ",", "packages", ".", "boolean_type", ")", ";", "elsif", "name_is", "(", "text",
  ",", "first", ",", "last", ",", "\"integer\"", ")", "then", "return", "(", "(", "first",
  ",", "last", ")", ",", "last", ",", "value", ".", "kind", ",", "value", ".",
  "bounds", ",", "packages", ".", "integer_type", ")", ";", "elsif", "export", "/=", "0", "and",
  "then", "info", ".", "exports", "(", "export", ")", ".", "kind", "=", "packages", ".",
  "integer_subtype", "then", "return", "(", "(", "first", ",", "last", ")", ",", "last", ",",
  "value", ".", "kind", ",", "value", ".", "bounds", ",", "export", "+", "1", ")",
  ";", "else", "return", "invalid_package_type", ";", "end", "if", ";", "end", "package_type_at", ";", "function",
  "outer_declaration", "(", "info", ":", "packages", ".", "metadata", ";", "name", ":", "packages", ".",
  "name_span", ")", "return", "boolean", "is", "(", "(", "for", "some", "i", "in", "1",
  "..", "info", ".", "export_count", "=>", "info", ".", "exports", "(", "i", ")", ".",
  "name", "=", "name", ")", "or", "else", "(", "for", "some", "i", "in", "1",
  "..", "info", ".", "state_count", "=>", "info", ".", "states", "(", "i", ")", ".",
  "name", "=", "name", ")", ")", "with", "global", "=>", "null", ";"
]

theorem candidate_checked : Checked candidateTokens where
  expressions := Native.checked_precedence
  expressionScopes := Native.checked_scopes
  bodies := Native.checked_bodies
  bodyScopes := Native.checked_body_scopes
  wordBody := by
    simp only [Native.packageWordBody, ApplicationNative.Body.render,
      ApplicationNative.Command.render]
    decide +kernel
  wordSpec := by decide +kernel
  pragmaBody := by
    simp only [Native.sparkPragmaBody, ApplicationNative.Body.render,
      ApplicationNative.Command.render]
    decide +kernel
  pragmaSpec := by decide +kernel
  allowedBody := by decide +kernel
  allowedSpec := by decide +kernel
  freshBody := by decide +kernel
  freshSpec := by decide +kernel
  packageType := by decide +kernel
  invalidType := by decide +kernel
  typeBody := by
    simp only [Native.packageTypeBody, ApplicationNative.Body.render,
      ApplicationNative.Command.render, ApplicationNative.Command.renderElse]
    decide +kernel
  typeSpec := by decide +kernel
  outerBody := by decide +kernel
  outerSpec := by decide +kernel

end Silver.ApplicationPackageNames.SourceChecks

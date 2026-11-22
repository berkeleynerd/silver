module

public import Silver.ApplicationPackageFramesSource
import all Init.Data.Repr

@[expose] public section

/-! Frame fragment proposal copied from the native implementation. This local
check does not replace its binding to the certified complete-source tokens. -/
namespace Silver.ApplicationPackageFrames.Native.Source
open ApplicationNative
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

def candidateTokens : List String := [
  "function", "imported_frame", "(", "text", ":", "string", ";", "exports", ":", "parser_state", ";", "info",
  ":", "packages", ".", "metadata", ";", "position", ":", "literal_position", ")", "return", "parser_state", "with",
  "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and",
  "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(",
  "text", ",", "exports", ")", "and", "then", "position", "<=", "text", "'", "last", "+",
  "1", "and", "then", "valid_name_state", "(", "text", ",", "info", ".", "name_first", ",", "info",
  ".", "name_after", ")", "and", "then", "info", ".", "units", "(", "units", ".", "main_body",
  ")", ".", "first", "<=", "text", "'", "last", "+", "1", ",", "post", "=>",
  "valid_state", "(", "text", ",", "imported_frame", "'", "result", ")", "is", "result", ":", "parser_state",
  ":=", "(", "exports", "with", "delta", "position", "=>", "position", ",", "context_first", "=>", "info",
  ".", "units", "(", "units", ".", "main_body", ")", ".", "first", ",", "package_first", "=>",
  "info", ".", "name_first", ",", "package_after", "=>", "info", ".", "name_after", ",", "pure", "=>",
  "false", ",", "hiding", "=>", "no_hidden_marks", ")", ";", "begin", "for", "i", "in", "1",
  "..", "result", ".", "scalar_names", ".", "count", "loop", "result", ".", "scalar_names", ".", "items",
  "(", "i", ")", ".", "qualifier_first", ":=", "info", ".", "name_first", ";", "result", ".",
  "scalar_names", ".", "items", "(", "i", ")", ".", "qualifier_after", ":=", "info", ".", "name_after",
  ";", "end", "loop", ";", "for", "i", "in", "1", "..", "result", ".", "boolean_names",
  ".", "count", "loop", "result", ".", "boolean_names", ".", "items", "(", "i", ")", ".",
  "qualifier_first", ":=", "info", ".", "name_first", ";", "result", ".", "boolean_names", ".", "items", "(",
  "i", ")", ".", "qualifier_after", ":=", "info", ".", "name_after", ";", "end", "loop", ";",
  "for", "i", "in", "1", "..", "result", ".", "subtype_names", ".", "count", "loop", "result",
  ".", "subtype_names", ".", "items", "(", "i", ")", ".", "qualifier_first", ":=", "info", ".",
  "name_first", ";", "result", ".", "subtype_names", ".", "items", "(", "i", ")", ".", "qualifier_after",
  ":=", "info", ".", "name_after", ";", "end", "loop", ";", "result", ".", "subtype_names", ".",
  "hidden_calls", ":=", "(", "others", "=>", "false", ")", ";", "result", ".", "subtype_names", ".",
  "true_hidden", ":=", "false", ";", "result", ".", "subtype_names", ".", "false_hidden", ":=", "false", ";",
  "if", "not", "valid_state", "(", "text", ",", "result", ")", "then", "return", "invalid_state", ";",
  "end", "if", ";", "return", "result", ";", "end", "imported_frame", ";", "function", "hide_outer", "(",
  "text", ":", "string", ";", "frame", ":", "parser_state", ";", "info", ":", "packages", ".",
  "metadata", ";", "name", ":", "packages", ".", "name_span", ")", "return", "parser_state", "with", "global",
  "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then",
  "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text",
  ",", "frame", ")", "and", "then", "packages", ".", "valid_name", "(", "text", ",", "name",
  ")", ",", "post", "=>", "valid_state", "(", "text", ",", "hide_outer", "'", "result", ")",
  "is", "result", ":", "parser_state", ":=", "frame", ";", "scalars_kept", ":", "scalar_expressions", ".", "binding_count",
  ":=", "0", ";", "booleans_kept", ":", "boolean_count", ":=", "0", ";", "subtypes_kept", ":", "subtype_count",
  ":=", "0", ";", "begin", "if", "forbidden_name", "(", "text", ",", "name", ".", "first",
  ",", "name", ".", "after", ")", "or", "else", "packages", ".", "same_name", "(", "text",
  ",", "name", ",", "(", "info", ".", "name_first", ",", "info", ".", "name_after", ")",
  ")", "then", "return", "invalid_state", ";", "end", "if", ";", "for", "i", "in", "1",
  "..", "frame", ".", "scalar_names", ".", "count", "loop", "pragma", "loop_invariant", "(", "scalars_kept", "<",
  "i", ")", ";", "if", "frame", ".", "scalar_names", ".", "items", "(", "i", ")",
  ".", "qualifier_first", "=", "0", "and", "then", "equal_name", "(", "text", ",", "name", ".",
  "first", ",", "name", ".", "after", ",", "frame", ".", "scalar_names", ".", "items", "(",
  "i", ")", ".", "first", ",", "frame", ".", "scalar_names", ".", "items", "(", "i",
  ")", ".", "after", ")", "then", "if", "not", "outer_declaration", "(", "info", ",", "(",
  "frame", ".", "scalar_names", ".", "items", "(", "i", ")", ".", "first", ",", "frame",
  ".", "scalar_names", ".", "items", "(", "i", ")", ".", "after", ")", ")", "then",
  "return", "invalid_state", ";", "end", "if", ";", "else", "scalars_kept", ":=", "scalars_kept", "+", "1",
  ";", "result", ".", "scalar_names", ".", "items", "(", "scalars_kept", ")", ":=", "frame", ".",
  "scalar_names", ".", "items", "(", "i", ")", ";", "end", "if", ";", "end", "loop",
  ";", "for", "i", "in", "1", "..", "frame", ".", "boolean_names", ".", "count", "loop",
  "pragma", "loop_invariant", "(", "booleans_kept", "<", "i", ")", ";", "if", "frame", ".", "boolean_names",
  ".", "items", "(", "i", ")", ".", "qualifier_first", "=", "0", "and", "then", "equal_name",
  "(", "text", ",", "name", ".", "first", ",", "name", ".", "after", ",", "frame",
  ".", "boolean_names", ".", "items", "(", "i", ")", ".", "first", ",", "frame", ".",
  "boolean_names", ".", "items", "(", "i", ")", ".", "after", ")", "then", "if", "not",
  "outer_declaration", "(", "info", ",", "(", "frame", ".", "boolean_names", ".", "items", "(", "i",
  ")", ".", "first", ",", "frame", ".", "boolean_names", ".", "items", "(", "i", ")",
  ".", "after", ")", ")", "then", "return", "invalid_state", ";", "end", "if", ";", "else",
  "booleans_kept", ":=", "booleans_kept", "+", "1", ";", "result", ".", "boolean_names", ".", "items", "(",
  "booleans_kept", ")", ":=", "frame", ".", "boolean_names", ".", "items", "(", "i", ")", ";",
  "end", "if", ";", "end", "loop", ";", "for", "i", "in", "1", "..", "frame",
  ".", "subtype_names", ".", "count", "loop", "pragma", "loop_invariant", "(", "subtypes_kept", "<", "i", ")",
  ";", "if", "frame", ".", "subtype_names", ".", "items", "(", "i", ")", ".", "qualifier_first",
  "=", "0", "and", "then", "equal_name", "(", "text", ",", "name", ".", "first", ",",
  "name", ".", "after", ",", "frame", ".", "subtype_names", ".", "items", "(", "i", ")",
  ".", "first", ",", "frame", ".", "subtype_names", ".", "items", "(", "i", ")", ".",
  "after", ")", "then", "if", "not", "outer_declaration", "(", "info", ",", "(", "frame", ".",
  "subtype_names", ".", "items", "(", "i", ")", ".", "first", ",", "frame", ".", "subtype_names",
  ".", "items", "(", "i", ")", ".", "after", ")", ")", "then", "return", "invalid_state",
  ";", "end", "if", ";", "else", "subtypes_kept", ":=", "subtypes_kept", "+", "1", ";", "result",
  ".", "subtype_names", ".", "items", "(", "subtypes_kept", ")", ":=", "frame", ".", "subtype_names", ".",
  "items", "(", "i", ")", ";", "end", "if", ";", "end", "loop", ";", "result",
  ".", "scalar_names", ".", "count", ":=", "scalars_kept", ";", "result", ".", "boolean_names", ".", "count",
  ":=", "booleans_kept", ";", "result", ".", "subtype_names", ".", "count", ":=", "subtypes_kept", ";", "result",
  ".", "hiding", ":=", "hide_name", "(", "text", ",", "result", ".", "hiding", ",", "name",
  ".", "first", ",", "name", ".", "after", ")", ";", "if", "not", "valid_state", "(",
  "text", ",", "result", ")", "then", "return", "invalid_state", ";", "end", "if", ";", "return",
  "result", ";", "end", "hide_outer", ";"
]

theorem candidate_checked : Checked candidateTokens where
  trees := frameTrees_wellFormed
  importedHeader := by decide +kernel
  importedBody := by
    simp only [importedFrameBody, qualifyLoop, qualifyBody, finalState, Body.render,
      Command.list, List.foldr, Command.render, Command.renderElse]
    decide +kernel
  hideHeader := by decide +kernel
  hideBody := by
    simp only [hideOuterBody, filterLoop, filterBody, finalState, Body.render,
      Command.list, List.foldr, Command.render, Command.renderElse]
    decide +kernel

end Silver.ApplicationPackageFrames.Native.Source

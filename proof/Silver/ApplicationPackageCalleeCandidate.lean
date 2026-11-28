module

public import Silver.ApplicationPackageCalleeSource
import all Init.Data.Repr

@[expose] public section

/-! Token proposal only. The final source checkpoint must instantiate Checked
on the authoritative complete source; these literal tokens are not that proof. -/
namespace Silver.ApplicationPackageCalls.Native.CalleeSource
open ApplicationNative
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/- Fragment SHA256: 162c7ccb725da374314ef2fe18b12b431920d1db3955b16f6473361fbf2a81a1 -/
def candidateTokens : List String := [
  "function", "package_callee", "(", "text", ":", "string", ";", "context", ":", "body_context", ";", "info",
  ":", "packages", ".", "metadata", ";", "position", ":", "literal_position", ";", "kind", ":", "packages",
  ".", "routine_kind", ")", "return", "packages", ".", "routine_count_type", "with", "global", "=>", "null", ",",
  "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length",
  "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")",
  "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>",
  "package_callee", "'", "result", "<=", "info", ".", "routine_count", "is", "reference", ":", "constant", "scalar_expressions",
  ".", "name_reference", ":=", "scalar_expressions", ".", "read_reference", "(", "text", ",", "position", ")", ";",
  "callee", ":", "packages", ".", "routine_count_type", ";", "begin", "if", "info", ".", "completed", ">",
  "info", ".", "routine_count", "or", "else", "reference", ".", "after", "=", "0", "then", "return",
  "0", ";", "end", "if", ";", "if", "context", ".", "pure", "then", "if", "reference",
  ".", "qualifier_first", "/=", "0", "or", "else", "scalar_expressions", ".", "lookup", "(", "text", ",",
  "context", ".", "scalar_names", ",", "reference", ".", "first", ",", "reference", ".", "after", ")",
  "/=", "0", "or", "else", "lookup_boolean", "(", "text", ",", "context", ".", "boolean_names", ",",
  "reference", ".", "first", ",", "reference", ".", "after", ")", "/=", "0", "then", "return",
  "0", ";", "end", "if", ";", "elsif", "not", "packages", ".", "same_name", "(", "text",
  ",", "(", "reference", ".", "qualifier_first", ",", "reference", ".", "qualifier_after", ")", ",", "(",
  "info", ".", "name_first", ",", "info", ".", "name_after", ")", ")", "then", "return", "0",
  ";", "end", "if", ";", "callee", ":=", "packages", ".", "lookup_routine", "(", "text", ",",
  "info", ",", "(", "reference", ".", "first", ",", "reference", ".", "after", ")", ")",
  ";", "return", "(", "if", "callee", "/=", "0", "and", "then", "info", ".", "routines",
  "(", "callee", ")", ".", "kind", "=", "kind", "then", "callee", "else", "0", ")",
  ";", "end", "package_callee", ";"
]

theorem candidate_checked : Checked candidateTokens where
  completeHeader := by decide +kernel
  completeBody := by
    simp only [calleeBody, Body.render, calleeCommands, Command.list,
      List.foldr, Command.render, Command.renderElse]
    decide +kernel

end Silver.ApplicationPackageCalls.Native.CalleeSource

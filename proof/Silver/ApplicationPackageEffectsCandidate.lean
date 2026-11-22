module

public import Silver.ApplicationPackageEffectsSource
import all Init.Data.Repr

@[expose] public section

/-! Development token proposal. Checked on these literals does not replace the
authoritative complete-source witness required by the final source bridge. -/
namespace Silver.ApplicationPackageEffects.Native.Source
open ApplicationNative
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

/- Fragment SHA256: 8c6cc54adfa0af42b3b0ad876e1e156c78efc6aa9a4fda6e567cd59cd597c95a -/
def candidateTokens : List String := [
  "function", "visible_state", "(", "text", ":", "string", ";", "context", ":", "body_context", ";", "info",
  ":", "packages", ".", "metadata", ";", "index", ":", "packages", ".", "state_index", ")", "return",
  "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=",
  "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then",
  "valid_context", "(", "text", ",", "context", ")", ",", "post", "=>", "(", "if", "visible_state",
  "'", "result", "then", "index", "<=", "info", ".", "state_count", "and", "then", "packages", ".",
  "valid_name", "(", "text", ",", "info", ".", "states", "(", "index", ")", ".", "name",
  ")", ")", "is", "name", ":", "constant", "packages", ".", "name_span", ":=", "info", ".",
  "states", "(", "index", ")", ".", "name", ";", "scalar", ":", "scalar_expressions", ".", "binding_count",
  ";", "flag", ":", "boolean_count", ";", "begin", "if", "index", ">", "info", ".", "state_count",
  "or", "else", "not", "packages", ".", "valid_name", "(", "text", ",", "name", ")", "then",
  "return", "false", ";", "end", "if", ";", "scalar", ":=", "scalar_expressions", ".", "lookup", "(",
  "text", ",", "context", ".", "scalar_names", ",", "name", ".", "first", ",", "name", ".",
  "after", ")", ";", "if", "info", ".", "states", "(", "index", ")", ".", "kind",
  "=", "functions", ".", "integer_kind", "then", "return", "scalar", "/=", "0", "and", "then", "context",
  ".", "scalar_names", ".", "items", "(", "scalar", ")", ".", "first", "=", "name", ".",
  "first", "and", "then", "context", ".", "scalar_names", ".", "items", "(", "scalar", ")", ".",
  "after", "=", "name", ".", "after", ";", "end", "if", ";", "if", "scalar", "/=",
  "0", "then", "return", "false", ";", "end", "if", ";", "flag", ":=", "lookup_boolean", "(",
  "text", ",", "context", ".", "boolean_names", ",", "name", ".", "first", ",", "name", ".",
  "after", ")", ";", "return", "flag", "/=", "0", "and", "then", "context", ".", "boolean_names",
  ".", "items", "(", "flag", ")", ".", "first", "=", "name", ".", "first", "and",
  "then", "context", ".", "boolean_names", ".", "items", "(", "flag", ")", ".", "after", "=",
  "name", ".", "after", ";", "end", "visible_state", ";", "function", "state_target", "(", "text", ":",
  "string", ";", "context", ":", "body_context", ";", "info", ":", "packages", ".", "metadata", ";",
  "position", ":", "literal_position", ")", "return", "packages", ".", "state_id", "with", "global", "=>", "null",
  ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'",
  "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context",
  ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post",
  "=>", "state_target", "'", "result", "<=", "info", ".", "state_count", "is", "first", ":", "constant",
  "literal_position", ":=", "skip_at", "(", "text", ",", "position", ")", ";", "last", ":", "constant",
  "literal_position", ":=", "name_after", "(", "text", ",", "first", ")", ";", "found", ":", "constant",
  "packages", ".", "state_id", ":=", "packages", ".", "lookup_state", "(", "text", ",", "info", ",",
  "(", "first", ",", "last", ")", ")", ";", "begin", "return", "(", "if", "found",
  "/=", "0", "and", "then", "visible_state", "(", "text", ",", "context", ",", "info", ",",
  "found", ")", "then", "found", "else", "0", ")", ";", "end", "state_target", ";", "function",
  "state_reads", "(", "text", ":", "string", ";", "context", ":", "body_context", ";", "info", ":",
  "packages", ".", "metadata", ";", "first", ",", "after", ":", "literal_position", ")", "return", "packages",
  ".", "state_set", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first",
  "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and",
  "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "first", "<=", "text",
  "'", "last", "+", "1", "and", "then", "after", "<=", "text", "'", "last", "+",
  "1", ",", "post", "=>", "packages", ".", "within", "(", "state_reads", "'", "result", ",",
  "info", ".", "state_count", ")", "is", "result", ":", "packages", ".", "state_set", ":=", "packages",
  ".", "empty_state_set", ";", "begin", "if", "first", "=", "0", "or", "else", "after", "<=",
  "first", "then", "return", "result", ";", "end", "if", ";", "for", "i", "in", "1",
  "..", "info", ".", "state_count", "loop", "pragma", "loop_invariant", "(", "for", "all", "s", "in",
  "packages", ".", "state_index", "=>", "(", "if", "s", ">", "info", ".", "state_count", "then",
  "not", "result", "(", "s", ")", ")", ")", ";", "if", "visible_state", "(", "text",
  ",", "context", ",", "info", ",", "i", ")", "then", "result", "(", "i", ")",
  ":=", "not", "actual_name_free", "(", "text", ",", "first", ",", "after", ",", "info", ".",
  "states", "(", "i", ")", ".", "name", ".", "first", ",", "info", ".", "states",
  "(", "i", ")", ".", "name", ".", "after", ")", ";", "end", "if", ";",
  "end", "loop", ";", "return", "result", ";", "end", "state_reads", ";"
]

theorem candidate_checked : Checked candidateTokens where
  visibleHeader := by decide +kernel
  visibleBody := by
    simp only [Native.visibleBody, Body.render, Command.list, List.foldr,
      Command.render, Command.renderElse]
    decide +kernel
  targetHeader := by decide +kernel
  targetBody := by
    simp only [Native.targetBody, Body.render, Command.render]
    decide +kernel
  readsHeader := by decide +kernel
  readsBody := by
    simp only [Native.readsBody, readsLoopBody, Body.render, Command.list, List.foldr,
      Command.render, Command.renderElse]
    decide +kernel

end Silver.ApplicationPackageEffects.Native.Source

module

public import Silver.ApplicationPackageRoutineFrameSource
import all Init.Data.Repr

@[expose] public section

/-! Exact token proposal for the guarded native Routine_Frame at SHA c37214cd9bc8772c84b2f4cd775d6582748e4499f829bf282bfe81e1264871af.
Authoritative full-source reconstruction remains a separate required binding. -/
namespace Silver.ApplicationPackageRoutineFrame.SourceChecks
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

def candidateTokens : List String := [
  "function", "routine_frame", "(", "text", ":", "string", ";", "globals", ":", "parser_state", ";", "info",
  ":", "packages", ".", "metadata", ";", "routine", ":", "packages", ".", "routine_index", ";", "position",
  ":", "literal_position", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>",
  "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1",
  "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "globals", ")", "and", "then",
  "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "valid_state", "(",
  "text", ",", "routine_frame", "'", "result", ")", "is", "result", ":", "parser_state", ":=", "(",
  "globals", "with", "delta", "position", "=>", "position", ",", "pure", "=>", "true", ",", "scalar_names",
  "=>", "scalar_expressions", ".", "body_environment", "(", "globals", ".", "scalar_names", ")", ")", ";", "item",
  ":", "constant", "packages", ".", "routine", ":=", "info", ".", "routines", "(", "routine", ")",
  ";", "parameter", ":", "packages", ".", "formal", ";", "mark", ":", "package_type_result", ";", "begin",
  "if", "routine", ">", "info", ".", "routine_count", "then", "return", "invalid_state", ";", "end", "if",
  ";", "for", "i", "in", "1", "..", "result", ".", "boolean_names", ".", "count", "loop",
  "if", "result", ".", "boolean_names", ".", "items", "(", "i", ")", ".", "mutable", "then",
  "result", ".", "boolean_names", ".", "items", "(", "i", ")", ".", "known", ":=", "false",
  ";", "end", "if", ";", "end", "loop", ";", "if", "item", ".", "count", ">",
  "0", "then", "if", "item", ".", "formal_first", "=", "0", "or", "else", "item", ".",
  "formal_first", ">", "info", ".", "parameter_count", "or", "else", "item", ".", "count", ">", "info",
  ".", "parameter_count", "-", "item", ".", "formal_first", "+", "1", "then", "return", "invalid_state", ";",
  "end", "if", ";", "for", "i", "in", "item", ".", "formal_first", "..", "item", ".",
  "formal_first", "+", "item", ".", "count", "-", "1", "loop", "parameter", ":=", "info", ".",
  "parameters", "(", "i", ")", ";", "if", "not", "packages", ".", "valid_name", "(", "text",
  ",", "parameter", ".", "body_name", ")", "then", "return", "invalid_state", ";", "end", "if", ";",
  "result", ":=", "hide_outer", "(", "text", ",", "result", ",", "info", ",", "parameter", ".",
  "body_name", ")", ";", "if", "result", ".", "position", "=", "0", "then", "return", "invalid_state",
  ";", "end", "if", ";", "end", "loop", ";", "for", "i", "in", "item", ".",
  "formal_first", "..", "item", ".", "formal_first", "+", "item", ".", "count", "-", "1", "loop",
  "parameter", ":=", "info", ".", "parameters", "(", "i", ")", ";", "if", "parameter", ".",
  "mode", "/=", "procedures", ".", "output", "then", "mark", ":=", "(", "name", "=>", "parameter",
  ".", "body_type_name", ",", "after", "=>", "parameter", ".", "body_type_name", ".", "after", ",", "kind",
  "=>", "parameter", ".", "kind", ",", "bounds", "=>", "parameter", ".", "bounds", ",", "identity",
  "=>", "parameter", ".", "type_identity", ")", ";", "append_package_formal", "(", "result", ",", "parameter", ".",
  "body_name", ",", "mark", ",", "parameter", ".", "mode", ")", ";", "if", "result", ".",
  "position", "=", "0", "then", "return", "invalid_state", ";", "end", "if", ";", "end", "if",
  ";", "end", "loop", ";", "end", "if", ";", "if", "not", "valid_state", "(", "text",
  ",", "result", ")", "then", "return", "invalid_state", ";", "end", "if", ";", "return", "result",
  ";", "end", "routine_frame", ";"
]

theorem candidate_checked : Checked candidateTokens where
  tree := Native.checked_tree
  header := by decide +kernel
  body := by
    simp only [Native.body, Control.Body.render, Native.commands, Native.parameters,
      Native.forgetLoop, Native.forgetBody, Native.hideBody, Native.appendBody, Native.finalState,
      Control.Command.list, List.foldr, Control.Command.render, Control.Command.renderElse,
      Control.Command.nothing, Control.Command.assign, Control.Command.returned,
      ApplicationNative.Command.render]
    decide +kernel

end Silver.ApplicationPackageRoutineFrame.SourceChecks

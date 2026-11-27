module

public import Silver.ApplicationPackageBodiesBasicSource
import all Init.Data.Repr

@[expose] public section

/-! Exact native token proposal for Application_Basic at source SHA 2e055cecc2d9eb6000490f4aa4d3d589d0cc9bbd91b55d0c65619599cfc56004. -/
namespace Silver.ApplicationPackageBodies.Basic.SourceChecks
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

def candidateTokens : List String := [
  "function", "application_basic", "(", "text", ":", "string", ";", "context", ":", "body_context", ";", "input",
  ":", "application_scan", ";", "info", ":", "packages", ".", "metadata", ";", "catalog", ":", "functions",
  ".", "metadata", ";", "procedure_catalog", ":", "procedures", ".", "metadata", ")", "return", "application_scan", "with",
  "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and",
  "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(",
  "text", ",", "context", ")", "and", "then", "valid_body", "(", "text", ",", "context", ",",
  "input", ".", "scan", ")", "and", "then", "functions", ".", "valid_metadata", "(", "text", ",",
  "catalog", ")", "and", "then", "procedures", ".", "valid_metadata", "(", "text", ",", "procedure_catalog", ")",
  ",", "post", "=>", "application_basic", "'", "result", ".", "count", "=", "input", ".", "count",
  "and", "then", "application_basic", "'", "result", ".", "allow_procedure_calls", "=", "input", ".", "allow_procedure_calls", "and",
  "then", "valid_body", "(", "text", ",", "context", ",", "application_basic", "'", "result", ".", "scan",
  ")", "and", "then", "(", "application_basic", "'", "result", ".", "scan", ".", "position", "=",
  "0", "or", "else", "application_basic", "'", "result", ".", "scan", ".", "position", ">", "input",
  ".", "scan", ".", "position", ")", "is", "result", ":", "application_scan", "(", "input", ".",
  "count", ")", ":=", "input", ";", "first", ":", "constant", "literal_position", ":=", "skip_at", "(",
  "text", ",", "input", ".", "scan", ".", "position", ")", ";", "last", ":", "constant",
  "literal_position", ":=", "name_after", "(", "text", ",", "first", ")", ";", "value_first", ":", "constant",
  "literal_position", ":=", "take_token", "(", "text", ",", "last", ",", "assignment", ")", ";", "scalar",
  ":", "constant", "scalar_expressions", ".", "binding_count", ":=", "scalar_target", "(", "text", ",", "context", ",",
  "input", ".", "scan", ".", "position", ")", ";", "flag", ":", "constant", "boolean_count", ":=",
  "boolean_target", "(", "text", ",", "context", ",", "input", ".", "scan", ".", "position", ")",
  ";", "state", ":", "constant", "packages", ".", "state_id", ":=", "state_target", "(", "text", ",",
  "context", ",", "info", ",", "input", ".", "scan", ".", "position", ")", ";", "called",
  ":", "application_call", "(", "input", ".", "count", ")", ";", "begin", "if", "input", ".",
  "scan", ".", "position", "=", "0", "then", "return", "invalid_application", "(", "input", ")", ";",
  "end", "if", ";", "if", "value_first", "/=", "0", "and", "then", "(", "scalar", "/=",
  "0", "or", "else", "flag", "/=", "0", ")", "then", "called", ":=", "package_call_at", "(",
  "text", ",", "context", ",", "input", ",", "info", ",", "value_first", ",", "packages", ".",
  "function_routine", ")", ";", "if", "called", ".", "value", ".", "after", "/=", "0", "then",
  "result", ":=", "called", ".", "result", ";", "result", ".", "scan", ":=", "call_assignment_result", "(",
  "context", ",", "(", "result", ".", "scan", "with", "delta", "position", "=>", "input", ".",
  "scan", ".", "position", ")", ",", "scalar", ",", "flag", ",", "called", ".", "value",
  ")", ";", "result", ".", "scan", ":=", "body_token", "(", "text", ",", "context", ",",
  "result", ".", "scan", ",", "semicolon", ")", ";", "else", "result", ".", "scan", ":=",
  "basic_body", "(", "text", ",", "context", ",", "input", ".", "scan", ",", "catalog", ",",
  "procedure_catalog", ")", ";", "result", ".", "reads", ":=", "packages", ".", "union", "(", "result",
  ".", "reads", ",", "state_reads", "(", "text", ",", "context", ",", "info", ",", "value_first",
  ",", "result", ".", "scan", ".", "position", ")", ")", ";", "end", "if", ";",
  "if", "state", "/=", "0", "then", "result", ".", "writes", "(", "state", ")", ":=",
  "true", ";", "end", "if", ";", "elsif", "input", ".", "allow_procedure_calls", "and", "then", "package_callee",
  "(", "text", ",", "context", ",", "info", ",", "input", ".", "scan", ".", "position",
  ",", "packages", ".", "procedure_routine", ")", "/=", "0", "then", "called", ":=", "package_call_at", "(",
  "text", ",", "context", ",", "input", ",", "info", ",", "input", ".", "scan", ".",
  "position", ",", "packages", ".", "procedure_routine", ")", ";", "result", ":=", "called", ".", "result",
  ";", "result", ".", "scan", ":=", "body_token", "(", "text", ",", "context", ",", "result",
  ".", "scan", ",", "semicolon", ")", ";", "else", "result", ".", "scan", ":=", "basic_body",
  "(", "text", ",", "context", ",", "input", ".", "scan", ",", "catalog", ",", "procedure_catalog",
  ")", ";", "end", "if", ";", "if", "result", ".", "scan", ".", "position", "<=",
  "input", ".", "scan", ".", "position", "then", "return", "invalid_application", "(", "input", ")", ";",
  "end", "if", ";", "return", "result", ";", "end", "application_basic", ";"
]

theorem candidate_checked : Checked candidateTokens where
  tree := checked_tree
  header := by decide +kernel
  body := by
    simp only [Basic.body, ApplicationNative.Body.render, commands, dispatch, assignmentCommands, semicolon,
      ApplicationNative.Command.list, List.foldr, ApplicationNative.Command.render, ApplicationNative.Command.renderElse]
    decide +kernel

end Silver.ApplicationPackageBodies.Basic.SourceChecks

module

public import Silver.ApplicationPackageBodiesTailSource
import all Init.Data.Repr

@[expose] public section

/-! Exact native token proposal for Application_Tail at source SHA 2e055cecc2d9eb6000490f4aa4d3d589d0cc9bbd91b55d0c65619599cfc56004. -/
namespace Silver.ApplicationPackageBodies.Tail.SourceChecks
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

def candidateTokens : List String := [
  "function", "application_tail", "(", "text", ":", "string", ";", "context", ":", "body_context", ";", "input",
  ":", "application_scan", ";", "info", ":", "packages", ".", "metadata", ";", "stop", ":", "body_stop",
  ";", "require_one", ":", "boolean", ";", "catalog", ":", "functions", ".", "metadata", ";", "procedure_catalog",
  ":", "procedures", ".", "metadata", ")", "return", "application_scan", "with", "global", "=>", "null", ",",
  "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length",
  "in", "1", "..", "max_source_length", "and", "then", "valid_context", "(", "text", ",", "context", ")",
  "and", "then", "valid_body", "(", "text", ",", "context", ",", "input", ".", "scan", ")",
  "and", "then", "functions", ".", "valid_metadata", "(", "text", ",", "catalog", ")", "and", "then",
  "procedures", ".", "valid_metadata", "(", "text", ",", "procedure_catalog", ")", ",", "post", "=>", "application_tail",
  "'", "result", ".", "count", "=", "input", ".", "count", "and", "then", "application_tail", "'",
  "result", ".", "allow_procedure_calls", "=", "input", ".", "allow_procedure_calls", "and", "then", "valid_body", "(", "text",
  ",", "context", ",", "application_tail", "'", "result", ".", "scan", ")", "and", "then", "(",
  "application_tail", "'", "result", ".", "scan", ".", "position", "=", "0", "or", "else", "application_tail",
  "'", "result", ".", "scan", ".", "position", ">=", "input", ".", "scan", ".", "position",
  ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+",
  "1", ")", "-", "input", ".", "scan", ".", "position", ",", "decreases", "=>", "2",
  ")", "is", "result", ":", "application_scan", "(", "input", ".", "count", ")", ":=", "input",
  ";", "before", ":", "literal_position", ";", "seen", ":", "boolean", ":=", "false", ";", "begin",
  "while", "result", ".", "scan", ".", "position", "/=", "0", "and", "then", "not", "at_body_stop",
  "(", "text", ",", "result", ".", "scan", ".", "position", ",", "stop", ")", "loop",
  "pragma", "loop_invariant", "(", "valid_body", "(", "text", ",", "context", ",", "result", ".", "scan",
  ")", ")", ";", "pragma", "loop_invariant", "(", "result", ".", "scan", ".", "position", ">=",
  "input", ".", "scan", ".", "position", ")", ";", "pragma", "loop_invariant", "(", "result", ".",
  "allow_procedure_calls", "=", "input", ".", "allow_procedure_calls", ")", ";", "pragma", "loop_variant", "(", "increases", "=>",
  "result", ".", "scan", ".", "position", ")", ";", "before", ":=", "result", ".", "scan",
  ".", "position", ";", "result", ":=", "application_statement", "(", "text", ",", "context", ",", "result",
  ",", "info", ",", "catalog", ",", "procedure_catalog", ")", ";", "if", "result", ".", "scan",
  ".", "position", "<=", "before", "then", "return", "invalid_application", "(", "result", ")", ";", "end",
  "if", ";", "seen", ":=", "true", ";", "end", "loop", ";", "if", "result", ".",
  "scan", ".", "position", "=", "0", "or", "else", "(", "require_one", "and", "then", "not",
  "seen", ")", "then", "return", "invalid_application", "(", "result", ")", ";", "end", "if", ";",
  "return", "result", ";", "end", "application_tail", ";"
]

theorem candidate_checked : Checked candidateTokens where
  tree := checked_tree
  header := by decide +kernel
  body := by
    simp only [Tail.body, Statements.Body.render, iteration, ending, Statements.Command.list,
      List.foldr, Statements.Command.render, Statements.Command.renderElse, ApplicationNative.Command.render,
      ApplicationPackageProcedure.Command.render]
    decide +kernel

end Silver.ApplicationPackageBodies.Tail.SourceChecks

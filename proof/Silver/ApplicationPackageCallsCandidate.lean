module

public import Silver.ApplicationPackageCallsSource
import all Init.Data.Repr

@[expose] public section

/-! Literal token proposal for focused complete-tree checking. Final
validation must bind Checked to the authoritative complete Ada source. -/
namespace Silver.ApplicationPackageCalls.Native.Call.SourceChecks
open ApplicationNative
set_option maxRecDepth 100000
set_option maxHeartbeats 20000000

/- Fragment SHA256: 6232cd675b3fd66e58c90870c96c07814e62d78de1f66852f39b5cdc4e073953 -/
def candidateTokens : List String := [
  "type", "package_actual", "is", "record", "first", ",", "after", ":", "literal_position", ":=", "0", ";",
  "target", ":", "procedure_actual_result", ":=", "invalid_procedure_actual", ";", "reads", ":", "packages", ".", "state_set", ":=",
  "packages", ".", "empty_state_set", ";", "written_state", ":", "packages", ".", "state_id", ":=", "0", ";",
  "end", "record", ";", "type", "package_actual_array", "is", "array", "(", "packages", ".", "formal_index", ")",
  "of", "package_actual", ";", "type", "package_seen_array", "is", "array", "(", "packages", ".", "formal_index", ")",
  "of", "boolean", ";", "type", "application_call", "(", "count", ":", "scalar_expressions", ".", "binding_count", ")",
  "is", "record", "value", ":", "call_result", ":=", "invalid_call", ";", "result", ":", "application_scan", "(",
  "count", ")", ";", "end", "record", ";", "function", "package_call_at", "(", "text", ":", "string",
  ";", "context", ":", "body_context", ";", "input", ":", "application_scan", ";", "info", ":", "packages",
  ".", "metadata", ";", "position", ":", "literal_position", ";", "kind", ":", "packages", ".", "routine_kind",
  ")", "return", "application_call", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'",
  "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length",
  "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_body", "(",
  "text", ",", "context", ",", "input", ".", "scan", ")", "and", "then", "position", "<=",
  "text", "'", "last", "+", "1", ",", "post", "=>", "package_call_at", "'", "result", ".",
  "count", "=", "input", ".", "count", "and", "then", "package_call_at", "'", "result", ".", "result",
  ".", "allow_procedure_calls", "=", "input", ".", "allow_procedure_calls", "and", "then", "valid_body", "(", "text", ",",
  "context", ",", "package_call_at", "'", "result", ".", "result", ".", "scan", ")", "and", "then",
  "(", "package_call_at", "'", "result", ".", "value", ".", "after", "=", "0", "or", "else",
  "package_call_at", "'", "result", ".", "value", ".", "after", "in", "position", "+", "1", "..",
  "text", "'", "last", "+", "1", ")", "is", "callee", ":", "constant", "packages", ".",
  "routine_count_type", ":=", "package_callee", "(", "text", ",", "context", ",", "info", ",", "position", ",",
  "kind", ")", ";", "failure", ":", "constant", "application_call", "(", "input", ".", "count", ")",
  ":=", "(", "input", ".", "count", ",", "invalid_call", ",", "invalid_application", "(", "input", ")",
  ")", ";", "reference", ":", "constant", "scalar_expressions", ".", "name_reference", ":=", "scalar_expressions", ".", "read_reference",
  "(", "text", ",", "position", ")", ";", "result", ":", "application_call", "(", "input", ".",
  "count", ")", ":=", "(", "input", ".", "count", ",", "invalid_call", ",", "input", ")",
  ";", "actuals", ":", "package_actual_array", ":=", "(", "others", "=>", "(", "others", "=>", "<",
  ">", ")", ")", ";", "call_writes", ":", "packages", ".", "state_set", ":=", "packages", ".",
  "empty_state_set", ";", "seen", ":", "package_seen_array", ":=", "(", "others", "=>", "false", ")", ";",
  "item", ":", "packages", ".", "routine", ";", "cursor_at", ",", "first", ",", "last", ",",
  "arrow_end", ",", "following", ":", "literal_position", ";", "named", ":", "boolean", ":=", "false", ";",
  "slot", ":", "packages", ".", "formal_count_type", ";", "parameter", ":", "packages", ".", "formal", ";",
  "legacy_parameter", ":", "procedures", ".", "formal", ";", "scalar", ":", "scalar_expressions", ".", "binding_count", ";",
  "begin", "if", "callee", "=", "0", "then", "return", "failure", ";", "end", "if", ";",
  "item", ":=", "info", ".", "routines", "(", "callee", ")", ";", "call_writes", ":=", "item",
  ".", "may_write", ";", "if", "item", ".", "count", ">", "0", "and", "then", "(",
  "item", ".", "formal_first", "=", "0", "or", "else", "item", ".", "formal_first", ">", "info",
  ".", "parameter_count", "or", "else", "item", ".", "count", ">", "info", ".", "parameter_count", "-",
  "item", ".", "formal_first", "+", "1", ")", "then", "return", "failure", ";", "end", "if",
  ";", "cursor_at", ":=", "reference", ".", "after", ";", "if", "item", ".", "count", ">",
  "0", "then", "cursor_at", ":=", "take_token", "(", "text", ",", "cursor_at", ",", "left_parenthesis", ")",
  ";", "if", "cursor_at", "=", "0", "then", "return", "failure", ";", "end", "if", ";",
  "for", "ordinal", "in", "1", "..", "item", ".", "count", "loop", "first", ":=", "skip_at",
  "(", "text", ",", "cursor_at", ")", ";", "last", ":=", "name_after", "(", "text", ",",
  "first", ")", ";", "arrow_end", ":=", "take_token", "(", "text", ",", "last", ",", "arrow",
  ")", ";", "slot", ":=", "0", ";", "if", "arrow_end", "/=", "0", "then", "named",
  ":=", "true", ";", "for", "i", "in", "item", ".", "formal_first", "..", "item", ".",
  "formal_first", "+", "item", ".", "count", "-", "1", "loop", "if", "packages", ".", "same_name",
  "(", "text", ",", "(", "first", ",", "last", ")", ",", "info", ".", "parameters",
  "(", "i", ")", ".", "spec_name", ")", "then", "slot", ":=", "i", ";", "end",
  "if", ";", "end", "loop", ";", "cursor_at", ":=", "arrow_end", ";", "elsif", "named", "then",
  "return", "failure", ";", "else", "slot", ":=", "item", ".", "formal_first", "+", "ordinal", "-",
  "1", ";", "end", "if", ";", "if", "slot", "=", "0", "or", "else", "seen",
  "(", "slot", ")", "then", "return", "failure", ";", "end", "if", ";", "seen", "(",
  "slot", ")", ":=", "true", ";", "parameter", ":=", "info", ".", "parameters", "(", "slot",
  ")", ";", "actuals", "(", "slot", ")", ".", "first", ":=", "cursor_at", ";", "if",
  "parameter", ".", "mode", "=", "procedures", ".", "input", "then", "following", ":=", "actual_after", "(",
  "text", ",", "context", ",", "cursor_at", ",", "input", ".", "scan", ".", "facts", ",",
  "(", "parameter", ".", "spec_name", ".", "first", ",", "parameter", ".", "spec_name", ".", "after",
  ",", "parameter", ".", "kind", ",", "parameter", ".", "bounds", ",", "0", ")", ")",
  ";", "else", "legacy_parameter", ":=", "(", "parameter", ".", "spec_name", ".", "first", ",", "parameter",
  ".", "spec_name", ".", "after", ",", "parameter", ".", "kind", ",", "parameter", ".", "bounds",
  ",", "0", ",", "parameter", ".", "mode", ")", ";", "actuals", "(", "slot", ")",
  ".", "target", ":=", "procedure_target_actual", "(", "text", ",", "context", ",", "cursor_at", ",", "input",
  ".", "scan", ".", "facts", ",", "legacy_parameter", ")", ";", "following", ":=", "actuals", "(",
  "slot", ")", ".", "target", ".", "after", ";", "actuals", "(", "slot", ")", ".",
  "written_state", ":=", "state_target", "(", "text", ",", "context", ",", "info", ",", "cursor_at", ")",
  ";", "end", "if", ";", "if", "following", "<=", "cursor_at", "then", "return", "failure", ";",
  "end", "if", ";", "actuals", "(", "slot", ")", ".", "after", ":=", "following", ";",
  "if", "parameter", ".", "mode", "/=", "procedures", ".", "output", "then", "actuals", "(", "slot",
  ")", ".", "reads", ":=", "state_reads", "(", "text", ",", "context", ",", "info", ",",
  "cursor_at", ",", "following", ")", ";", "end", "if", ";", "result", ".", "result", ".",
  "reads", ":=", "packages", ".", "union", "(", "result", ".", "result", ".", "reads", ",",
  "actuals", "(", "slot", ")", ".", "reads", ")", ";", "if", "actuals", "(", "slot",
  ")", ".", "written_state", "/=", "0", "then", "call_writes", "(", "actuals", "(", "slot", ")",
  ".", "written_state", ")", ":=", "true", ";", "end", "if", ";", "cursor_at", ":=", "take_token",
  "(", "text", ",", "following", ",", "(", "if", "ordinal", "=", "item", ".", "count",
  "then", "right_parenthesis", "else", "comma", ")", ")", ";", "if", "cursor_at", "=", "0", "then",
  "return", "failure", ";", "end", "if", ";", "end", "loop", ";", "end", "if", ";",
  "if", "item", ".", "count", ">", "0", "then", "for", "i", "in", "item", ".",
  "formal_first", "..", "item", ".", "formal_first", "+", "item", ".", "count", "-", "1", "loop",
  "for", "s", "in", "1", "..", "info", ".", "state_count", "loop", "if", "item", ".",
  "may_write", "(", "s", ")", "and", "then", "actuals", "(", "i", ")", ".", "reads",
  "(", "s", ")", "then", "return", "failure", ";", "end", "if", ";", "end", "loop",
  ";", "if", "info", ".", "parameters", "(", "i", ")", ".", "mode", "/=", "procedures",
  ".", "input", "then", "if", "actuals", "(", "i", ")", ".", "written_state", "/=", "0",
  "and", "then", "(", "item", ".", "may_read", "(", "actuals", "(", "i", ")", ".",
  "written_state", ")", "or", "else", "item", ".", "may_write", "(", "actuals", "(", "i", ")",
  ".", "written_state", ")", ")", "then", "return", "failure", ";", "end", "if", ";", "for",
  "j", "in", "item", ".", "formal_first", "..", "item", ".", "formal_first", "+", "item", ".",
  "count", "-", "1", "loop", "if", "i", "/=", "j", "and", "then", "not", "actual_name_free",
  "(", "text", ",", "actuals", "(", "j", ")", ".", "first", ",", "actuals", "(",
  "j", ")", ".", "after", ",", "actuals", "(", "i", ")", ".", "target", ".",
  "first", ",", "actuals", "(", "i", ")", ".", "target", ".", "after", ")", "then",
  "return", "failure", ";", "end", "if", ";", "end", "loop", ";", "scalar", ":=", "actuals",
  "(", "i", ")", ".", "target", ".", "scalar", ";", "if", "scalar", "/=", "0",
  "then", "result", ".", "result", ".", "scan", ".", "facts", ".", "values", "(", "scalar",
  ")", ":=", "info", ".", "parameters", "(", "i", ")", ".", "bounds", ";", "end",
  "if", ";", "result", ".", "result", ".", "scan", ".", "assigned", ":=", "true", ";",
  "end", "if", ";", "end", "loop", ";", "end", "if", ";", "result", ".", "result",
  ".", "reads", ":=", "packages", ".", "union", "(", "result", ".", "result", ".", "reads",
  ",", "item", ".", "may_read", ")", ";", "result", ".", "result", ".", "writes", ":=",
  "packages", ".", "union", "(", "result", ".", "result", ".", "writes", ",", "call_writes", ")",
  ";", "for", "s", "in", "1", "..", "info", ".", "state_count", "loop", "if", "call_writes",
  "(", "s", ")", "and", "then", "visible_state", "(", "text", ",", "context", ",", "info",
  ",", "s", ")", "and", "then", "info", ".", "states", "(", "s", ")", ".",
  "kind", "=", "functions", ".", "integer_kind", "then", "scalar", ":=", "scalar_expressions", ".", "lookup", "(",
  "text", ",", "context", ".", "scalar_names", ",", "info", ".", "states", "(", "s", ")",
  ".", "name", ".", "first", ",", "info", ".", "states", "(", "s", ")", ".",
  "name", ".", "after", ")", ";", "if", "scalar", "/=", "0", "then", "result", ".",
  "result", ".", "scan", ".", "facts", ".", "values", "(", "scalar", ")", ":=", "context",
  ".", "scalar_names", ".", "items", "(", "scalar", ")", ".", "declared_bounds", ";", "end", "if",
  ";", "end", "if", ";", "end", "loop", ";", "result", ".", "result", ".", "scan",
  ".", "position", ":=", "cursor_at", ";", "if", "kind", "=", "packages", ".", "procedure_routine", "then",
  "result", ".", "result", ".", "scan", ".", "assigned", ":=", "true", ";", "end", "if",
  ";", "result", ".", "value", ":=", "(", "cursor_at", ",", "item", ".", "result_kind", ",",
  "item", ".", "result_bounds", ")", ";", "if", "cursor_at", "<=", "position", "or", "else", "not",
  "valid_body", "(", "text", ",", "context", ",", "result", ".", "result", ".", "scan", ")",
  "then", "return", "failure", ";", "end", "if", ";", "return", "result", ";", "end", "package_call_at",
  ";"
]

theorem candidate_checked : Checked candidateTokens where
  actualRecord := by decide +kernel
  actualArray := by decide +kernel
  seenArray := by decide +kernel
  callRecord := by decide +kernel
  completeHeader := by decide +kernel
  completeBody := by
    simp only [callBody, Body.render, callCommands, actualCommands, aliasCommands,
      resetCommands, namedScan, returnFailure, Command.list, List.foldr,
      Command.render, Command.renderElse]
    decide +kernel

end Silver.ApplicationPackageCalls.Native.Call.SourceChecks

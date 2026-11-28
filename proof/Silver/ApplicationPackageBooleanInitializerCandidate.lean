module

public import Silver.ApplicationPackageBooleanInitializer
import all Init.Data.Repr

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.BooleanInitializer

set_option maxRecDepth 12000
set_option maxHeartbeats 2000000

/-- Both original Boolean_Initializer_After declarations in source order. -/
def candidate : List String := [
  "function", "boolean_initializer_after", "(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "position", ",", "mask_first", ",",
  "mask_after", ":", "literal_position", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'",
  "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state",
  "(", "text", ",", "state", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and",
  "then", "valid_name_state", "(", "text", ",", "mask_first", ",", "mask_after", ")", ",", "post", "=>", "(", "runtime", "=>",
  "boolean_initializer_after", "'", "result", "=", "0", "or", "else", "boolean_initializer_after", "'", "result", "in", "position", "+", "1", "..",
  "text", "'", "last", "+", "1", ",", "static", "=>", "boolean_initializer_after", "'", "result", "=", "boolean_initializer_model", "(", "text",
  ",", "state", ",", "position", ",", "mask_first", ",", "mask_after", ")", ")", ";", "function", "boolean_initializer_after", "(", "text",
  ":", "string", ";", "state", ":", "parser_state", ";", "position", ",", "mask_first", ",", "mask_after", ":", "literal_position", ")",
  "return", "literal_position", "is", "context", ":", "constant", "body_context", ":=", "(", "context_of", "(", "(", "state", ",", "false",
  ",", "false", ")", ")", "with", "delta", "scalar_names", "=>", "state", ".", "scalar_names", ",", "elaborating", "=>", "true",
  ",", "mask_first", "=>", "mask_first", ",", "mask_after", "=>", "mask_after", ")", ";", "value", ":", "condition_result", "(", "state",
  ".", "scalar_names", ".", "count", ")", ";", "begin", "read_condition_into", "(", "text", ",", "context", ",", "position", ",",
  "initial_flow", "(", "context", ")", ",", "value", ",", "state", ".", "array_names", ".", "values", ")", ";", "return",
  "value", ".", "after", ";", "end", "boolean_initializer_after", ";"
]

theorem candidate_checked : Checked candidate where
  specification := by decide +kernel
  implementation := by decide +kernel
  statements := by decide +kernel

end Silver.ApplicationPackageDeclarations.BooleanInitializer

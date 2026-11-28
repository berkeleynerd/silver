module

public import Silver.ApplicationStateValidityNative
import all Init.Data.Repr

@[expose] public section

namespace Silver.ApplicationPackageFrames.ValidityNative.Source
open SourceBridge
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

def header : List String := expectedTokens
  "(Text : String; State : Parser_State) return Boolean with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length"

structure Checked (tokens : List String) : Prop where
  trees : validStateBody.wellFormed functionNames = true ∧ validStateBody.scoped scope = true
  specification : functionHeader "valid_state" ";" tokens = some header
  implementation : functionHeader "valid_state" "is" tokens =
    some (expectedTokens "(Text : String; State : Parser_State) return Boolean")
  expression : Silver.Source.expressionBody "valid_state" tokens = some (validStateBody.render functionNames)

def candidateTokens : List String := [
  "function", "valid_state", "(", "text", ":", "string", ";", "state", ":", "parser_state", ")", "return",
  "boolean", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=",
  "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", ";", "function",
  "valid_state", "(", "text", ":", "string", ";", "state", ":", "parser_state", ")", "return", "boolean",
  "is", "(", "state", ".", "position", "<=", "text", "'", "last", "+", "1", "and",
  "then", "state", ".", "context_first", "<=", "text", "'", "last", "+", "1", "and", "then",
  "valid_name_state", "(", "text", ",", "state", ".", "package_first", ",", "state", ".", "package_after", ")",
  "and", "then", "functions", ".", "valid_metadata", "(", "text", ",", "state", ".", "functions", ")",
  "and", "then", "procedures", ".", "valid_metadata", "(", "text", ",", "state", ".", "procedures", ")",
  "and", "then", "state", ".", "first_parameter", "<=", "state", ".", "functions", ".", "parameter_count", "+",
  "1", "and", "then", "state", ".", "first_procedure_parameter", "<=", "state", ".", "procedures", ".", "parameter_count",
  "+", "1", "and", "then", "valid_names", "(", "text", ",", "state", ".", "names", ")",
  "and", "then", "scalar_expressions", ".", "valid_environment", "(", "text", ",", "state", ".", "scalar_names", ")",
  "and", "then", "array_bindings", ".", "valid_environment", "(", "text", ",", "state", ".", "array_names", ")",
  "and", "then", "valid_subtypes", "(", "text", ",", "state", ".", "subtype_names", ")", "and", "then",
  "valid_booleans", "(", "text", ",", "state", ".", "boolean_names", ")", "and", "then", "valid_mutable_bounds", "(",
  "state", ".", "scalar_names", ")", "and", "then", "valid_declaration_values", "(", "state", ".", "scalar_names", ",",
  "state", ".", "scalar_names", ".", "count", ")", "and", "then", "valid_name_state", "(", "text", ",",
  "state", ".", "dynamic_first", ",", "state", ".", "dynamic_after", ")", "and", "then", "state", ".",
  "target", "<=", "state", ".", "names", ".", "count", ")", ";"
]

theorem candidate_checked : Checked candidateTokens where
  trees := validState_checked
  specification := by decide +kernel
  implementation := by decide +kernel
  expression := by
    simp only [validStateBody, List.foldl_cons, List.foldl_nil]
    decide +kernel

end Silver.ApplicationPackageFrames.ValidityNative.Source

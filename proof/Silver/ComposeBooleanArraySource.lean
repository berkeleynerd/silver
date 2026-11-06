module

public import Silver.ComposeArrayExpressions
public import Silver.ComposeBooleanInitializerNative

@[expose] public section

/-! The Boolean aggregate loop refines its checked recursive model through
its native Static postcondition. Model recursion uses the separately derived
Boolean initializer meaning on the exact state/cursor/mask domain. -/
namespace Silver.Compose.BooleanArraySource
open Silver.SourceBridge

def modelSpec : List String :=
  ["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";",
   "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".",
   "element_count", ";", "mask_first", ",", "mask_after", ":", "literal_position", ")", "return",
   "parser_state", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>",
   "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..",
   "max_source_length", "and", "then", "valid_state", "(", "text", ",", "source_state", ")", "and",
   "then", "valid_state", "(", "text", ",", "result_state", ")", "and", "then", "position", "<=",
   "text", "'", "last", "+", "1", "and", "then", "parsed", "<=", "length", "and", "then",
   "valid_name_state", "(", "text", ",", "mask_first", ",", "mask_after", ")", "and", "then",
   "length", "<=", "array_bindings", ".", "max_elements", "-", "source_state", ".", "array_names",
   ".", "used", "and", "then", "result_state", ".", "array_names", ".", "used", "=", "source_state",
   ".", "array_names", ".", "used", "+", "parsed", ",", "post", "=>", "valid_state", "(", "text",
   ",", "boolean_array_values_model", "'", "result", ")", "and", "then", "(", "if",
   "boolean_array_values_model", "'", "result", ".", "position", "/=", "0", "then",
   "boolean_array_values_model", "'", "result", ".", "position", ">=", "position", "and", "then",
   "boolean_array_values_model", "'", "result", "=", "(", "result_state", "with", "delta",
   "position", "=>", "boolean_array_values_model", "'", "result", ".", "position", ",",
   "array_names", "=>", "(", "result_state", ".", "array_names", "with", "delta", "used", "=>",
   "source_state", ".", "array_names", ".", "used", "+", "length", ",", "values", "=>",
   "boolean_array_values_model", "'", "result", ".", "array_names", ".", "values", ")", ")", "and",
   "then", "(", "for", "all", "slot", "in", "1", "..", "result_state", ".", "array_names", ".",
   "used", "=>", "boolean_array_values_model", "'", "result", ".", "array_names", ".", "values",
   "(", "slot", ")", "=", "result_state", ".", "array_names", ".", "values", "(", "slot", ")", ")",
   ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "length", "-", "parsed", ")"]

def modelImpl : List String := expectedTokens
  "(Text : String; Source_State, Result_State : Parser_State; Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count; Mask_First, Mask_After : Literal_Position) return Parser_State"

def executableSpec : List String :=
  ["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";",
   "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".",
   "element_count", ";", "mask_first", ",", "mask_after", ":", "literal_position", ")", "return",
   "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1",
   "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then",
   "valid_state", "(", "text", ",", "source_state", ")", "and", "then", "valid_state", "(", "text",
   ",", "result_state", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and",
   "then", "parsed", "<=", "length", "and", "then", "valid_name_state", "(", "text", ",",
   "mask_first", ",", "mask_after", ")", "and", "then", "length", "<=", "array_bindings", ".",
   "max_elements", "-", "source_state", ".", "array_names", ".", "used", "and", "then",
   "result_state", ".", "array_names", ".", "used", "=", "source_state", ".", "array_names", ".",
   "used", "+", "parsed", ",", "post", "=>", "(", "runtime", "=>", "valid_state", "(", "text", ",",
   "boolean_array_values_at", "'", "result", ")", "and", "then", "(", "if",
   "boolean_array_values_at", "'", "result", ".", "position", "/=", "0", "then",
   "boolean_array_values_at", "'", "result", ".", "position", ">=", "position", "and", "then",
   "boolean_array_values_at", "'", "result", "=", "(", "result_state", "with", "delta", "position",
   "=>", "boolean_array_values_at", "'", "result", ".", "position", ",", "array_names", "=>", "(",
   "result_state", ".", "array_names", "with", "delta", "used", "=>", "source_state", ".",
   "array_names", ".", "used", "+", "length", ",", "values", "=>", "boolean_array_values_at", "'",
   "result", ".", "array_names", ".", "values", ")", ")", "and", "then", "(", "for", "all", "slot",
   "in", "1", "..", "result_state", ".", "array_names", ".", "used", "=>",
   "boolean_array_values_at", "'", "result", ".", "array_names", ".", "values", "(", "slot", ")",
   "=", "result_state", ".", "array_names", ".", "values", "(", "slot", ")", ")", ")", ",",
   "static", "=>", "boolean_array_values_at", "'", "result", "=", "boolean_array_values_model", "(",
   "text", ",", "source_state", ",", "result_state", ",", "position", ",", "length", ",", "parsed",
   ",", "mask_first", ",", "mask_after", ")", "and", "then", "same_parser_state", "(",
   "boolean_array_values_at", "'", "result", ",", "boolean_array_values_model", "(", "text", ",",
   "source_state", ",", "result_state", ",", "position", ",", "length", ",", "parsed", ",",
   "mask_first", ",", "mask_after", ")", ")", ")"]

def executableImpl : List String := expectedTokens
  "(Text : String; Source_State, Result_State : Parser_State; Position : Literal_Position; Length, Parsed : Array_Bindings.Element_Count; Mask_First, Mask_After : Literal_Position) return Parser_State"

structure Checked (tokens : List String) : Prop where
  initializer : BooleanInitializerNative.SourceChecks.Checked tokens
  body : expressionDeclaration "boolean_array_values_model" tokens =
    some (Expressions.booleanArrayValuesModelBody.render, [])
  modelSpec : functionHeader "boolean_array_values_model" ";" tokens = some modelSpec
  modelImpl : functionHeader "boolean_array_values_model" "is" tokens = some modelImpl
  executableSpec : functionHeader "boolean_array_values_at" ";" tokens = some executableSpec
  executableImpl : functionHeader "boolean_array_values_at" "is" tokens = some executableImpl

end Silver.Compose.BooleanArraySource

module

public import Silver.ComposeBooleanArraySource
public import Silver.ReviewedOutputShape

@[expose] public section

/-! Kernel checks for the Boolean initializer and aggregate source requirements.
The complete source is checked against literal headers separately from lexing the
unchanged expected headers, then the equalities are composed at the exact fields. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.BooleanArraySource
open Silver.SourceBridge

private def modelSpecTokens : List String :=
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

private theorem model_spec_tokens : modelSpec = modelSpecTokens := by
  decide +kernel

private theorem model_spec_source :
    functionHeader "boolean_array_values_model" ";" Output.SourceShape.outputImplementation =
      some modelSpecTokens := by
  decide +kernel

private def executableSpecTokens : List String :=
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

private theorem executable_spec_tokens : executableSpec = executableSpecTokens := by
  decide +kernel

private theorem executable_spec_source :
    functionHeader "boolean_array_values_at" ";" Output.SourceShape.outputImplementation =
      some executableSpecTokens := by
  decide +kernel

private theorem initializer_source :
    BooleanInitializerNative.SourceChecks.Checked Output.SourceShape.outputImplementation := by
  constructor <;> decide +kernel

private theorem body_source :
    expressionDeclaration "boolean_array_values_model" Output.SourceShape.outputImplementation =
      some (Expressions.booleanArrayValuesModelBody.render, []) := by
  decide +kernel

private theorem model_impl_source :
    functionHeader "boolean_array_values_model" "is" Output.SourceShape.outputImplementation =
      some modelImpl := by
  decide +kernel

private theorem executable_impl_source :
    functionHeader "boolean_array_values_at" "is" Output.SourceShape.outputImplementation =
      some executableImpl := by
  decide +kernel

/-- Every original initializer, tree, complete header and contract requirement
is retained; the two complete spec equalities use checked literal bridges. -/
theorem candidate_checked : Checked Output.SourceShape.outputImplementation where
  initializer := initializer_source
  body := body_source
  modelSpec := model_spec_source.trans (congrArg some model_spec_tokens.symm)
  modelImpl := model_impl_source
  executableSpec := executable_spec_source.trans (congrArg some executable_spec_tokens.symm)
  executableImpl := executable_impl_source

end Silver.Compose.BooleanArraySource

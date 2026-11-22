module

public import Silver.SourceDeclarations
public import Silver.ComposeArrayDeclarationSource
public import Silver.ComposeContracts
public import Silver.ComposeBooleanDeclarationSource
public import Silver.ComposeBooleanArraySourceCandidate
public import Silver.ReviewedOutputShape
public import Silver.BooleanDeclarationExpectedTokens
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section

/-! Kernel source-shape checks for one independent part of the complete
Compose candidate. The facade transports every part to authoritative tokens. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Compose.SourceBridge
open Silver.SourceBridge

/-- Array helpers retain their exact native domains, postfix aspects and
executable-to-ghost refinement. The loop is connected through its checked
Static postcondition; no mathematical declaration equality is assumed here. -/
abbrev ArrayHelperTranslationFor (bodyTokens : List String) : Prop :=
  Expressions.ArrayWellFormedTrees ∧
  Expressions.ArrayWellScopedTrees ∧
  Source.declaration "integer_type_word" bodyTokens =
    some (["constant", "string", ":=", "\"integer\""]) ∧
  Source.declaration "boolean_type_word" bodyTokens =
    some (["constant", "string", ":=", "\"boolean\""]) ∧
  Source.declaration "character_type_word" bodyTokens =
    some (["constant", "string", ":=", "\"character\""]) ∧
  expressionDeclaration "put_array_value" bodyTokens =
    some ((Expressions.arrayPutBody.render.drop 1 |>.dropLast), (["with", "global", "=>", "null", ",", "pre", "=>", "state", ".", "array_names", ".", "used", "<", "array_bindings", ".", "max_elements"])) ∧
  expressionDeclaration "add_array_binding" bodyTokens =
    some ((Expressions.arrayAddBody.render.drop 1 |>.dropLast), (["with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", "and", "then", "state", ".", "array_names", ".", "names", ".", "count", "<", "array_bindings", ".", "max_bindings", "and", "then", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "first", ",", "after", ")", "and", "then", "array_bindings", ".", "valid_binding", "(", "(", "first", ",", "after", ",", "bounds", ",", "offset", ",", "length", ",", "mutable", ",", "component_bounds", ",", "boolean_elements", ",", "type_id", ",", "0", ")", ")", "and", "then", "type_id", "<=", "state", ".", "array_names", ".", "names", ".", "types", ".", "count", "and", "then", "(", "if", "type_id", "/=", "0", "then", "bounds", "=", "state", ".", "array_names", ".", "names", ".", "types", ".", "items", "(", "type_id", ")", ".", "bounds", "and", "then", "component_bounds", "=", "state", ".", "array_names", ".", "names", ".", "types", ".", "items", "(", "type_id", ")", ".", "component_bounds", ")", "and", "then", "offset", "+", "length", "<=", "state", ".", "array_names", ".", "used", "and", "then", "(", "if", "state", ".", "array_names", ".", "names", ".", "count", ">", "0", "then", "state", ".", "array_names", ".", "names", ".", "items", "(", "state", ".", "array_names", ".", "names", ".", "count", ")", ".", "view_slot", "=", "0", "and", "then", "offset", ">=", "state", ".", "array_names", ".", "names", ".", "items", "(", "state", ".", "array_names", ".", "names", ".", "count", ")", ".", "offset", "+", "state", ".", "array_names", ".", "names", ".", "items", "(", "state", ".", "array_names", ".", "names", ".", "count", ")", ".", "length", ")", "and", "then", "following", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "valid_state", "(", "text", ",", "add_array_binding", "'", "result", ")", "and", "then", "add_array_binding", "'", "result", ".", "position", "=", "following"])) ∧
  expressionDeclaration "array_values_model" bodyTokens =
    some (Expressions.arrayValuesModelBody.render, []) ∧
  expressionDeclaration "array_declaration_model" bodyTokens =
    some ((Expressions.arrayDeclarationBody false).render, []) ∧
  ArrayDeclarationNative.SourceChecks.Checked bodyTokens ∧
  functionHeader "put_array_value" "is" bodyTokens =
    some (["(", "state", ":", "parser_state", ";", "value", ":", "scalars", ".", "value", ")", "return", "parser_state"]) ∧
  functionHeader "add_array_binding" "is" bodyTokens =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "first", ",", "after", ":", "literal_position", ";", "bounds", ":", "scalars", ".", "interval", ";", "offset", ",", "length", ":", "array_bindings", ".", "element_count", ";", "mutable", ":", "boolean", ";", "following", ":", "literal_position", ";", "component_bounds", ":", "scalars", ".", "interval", ";", "boolean_elements", ":", "boolean", ":=", "false", ";", "type_id", ":", "array_bindings", ".", "type_count", ":=", "0", ")", "return", "parser_state"]) ∧
  functionHeader "array_values_model" ";" bodyTokens =
    some ["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "source_state", ")", "and", "then", "valid_state", "(", "text", ",", "result_state", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "parsed", "<=", "length", "and", "then", "length", "<=", "array_bindings", ".", "max_elements", "-", "source_state", ".", "array_names", ".", "used", "and", "then", "result_state", ".", "array_names", ".", "used", "=", "source_state", ".", "array_names", ".", "used", "+", "parsed", ",", "post", "=>", "valid_state", "(", "text", ",", "array_values_model", "'", "result", ")", "and", "then", "(", "if", "array_values_model", "'", "result", ".", "position", "/=", "0", "then", "array_values_model", "'", "result", ".", "position", ">=", "position", "and", "then", "array_values_model", "'", "result", "=", "(", "result_state", "with", "delta", "position", "=>", "array_values_model", "'", "result", ".", "position", ",", "array_names", "=>", "(", "result_state", ".", "array_names", "with", "delta", "used", "=>", "source_state", ".", "array_names", ".", "used", "+", "length", ",", "values", "=>", "array_values_model", "'", "result", ".", "array_names", ".", "values", ")", ")", "and", "then", "(", "for", "all", "slot", "in", "1", "..", "result_state", ".", "array_names", ".", "used", "=>", "array_values_model", "'", "result", ".", "array_names", ".", "values", "(", "slot", ")", "=", "result_state", ".", "array_names", ".", "values", "(", "slot", ")", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "length", "-", "parsed", ")"] ∧
  functionHeader "array_values_model" "is" bodyTokens =
    some (["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state"]) ∧
  functionHeader "array_values_at" ";" bodyTokens =
    some ["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "source_state", ")", "and", "then", "valid_state", "(", "text", ",", "result_state", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "parsed", "<=", "length", "and", "then", "length", "<=", "array_bindings", ".", "max_elements", "-", "source_state", ".", "array_names", ".", "used", "and", "then", "result_state", ".", "array_names", ".", "used", "=", "source_state", ".", "array_names", ".", "used", "+", "parsed", ",", "post", "=>", "(", "runtime", "=>", "valid_state", "(", "text", ",", "array_values_at", "'", "result", ")", "and", "then", "(", "if", "array_values_at", "'", "result", ".", "position", "/=", "0", "then", "array_values_at", "'", "result", ".", "position", ">=", "position", "and", "then", "array_values_at", "'", "result", "=", "(", "result_state", "with", "delta", "position", "=>", "array_values_at", "'", "result", ".", "position", ",", "array_names", "=>", "(", "result_state", ".", "array_names", "with", "delta", "used", "=>", "source_state", ".", "array_names", ".", "used", "+", "length", ",", "values", "=>", "array_values_at", "'", "result", ".", "array_names", ".", "values", ")", ")", "and", "then", "(", "for", "all", "slot", "in", "1", "..", "result_state", ".", "array_names", ".", "used", "=>", "array_values_at", "'", "result", ".", "array_names", ".", "values", "(", "slot", ")", "=", "result_state", ".", "array_names", ".", "values", "(", "slot", ")", ")", ")", ",", "static", "=>", "array_values_at", "'", "result", "=", "array_values_model", "(", "text", ",", "source_state", ",", "result_state", ",", "position", ",", "length", ",", "parsed", ",", "component_bounds", ")", "and", "then", "same_parser_state", "(", "array_values_at", "'", "result", ",", "array_values_model", "(", "text", ",", "source_state", ",", "result_state", ",", "position", ",", "length", ",", "parsed", ",", "component_bounds", ")", ")", ")"] ∧
  functionHeader "array_values_at" "is" bodyTokens =
    some (["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state"]) ∧
  functionHeader "array_declaration_model" ";" bodyTokens =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "array_declaration_model", "'", "result", ")", "and", "then", "(", "array_declaration_model", "'", "result", ".", "position", "=", "0", "or", "else", "array_declaration_model", "'", "result", ".", "position", ">", "state", ".", "position", ")"]) ∧
  functionHeader "array_declaration_model" "is" bodyTokens =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state"]) ∧
  functionHeader "array_declaration_at" ";" bodyTokens =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "(", "runtime", "=>", "valid_state", "(", "text", ",", "array_declaration_at", "'", "result", ")", "and", "then", "(", "array_declaration_at", "'", "result", ".", "position", "=", "0", "or", "else", "array_declaration_at", "'", "result", ".", "position", ">", "state", ".", "position", ")", ",", "static", "=>", "array_declaration_at", "'", "result", "=", "array_declaration_model", "(", "text", ",", "state", ",", "arguments", ")", ")"]) ∧
  functionHeader "array_declaration_at" "is" bodyTokens =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state"])

private theorem array_helper_integer_type_word :
  Source.declaration "integer_type_word" Output.SourceShape.outputImplementation =
    some (["constant", "string", ":=", "\"integer\""]) := by
  decide +kernel

private theorem array_helper_boolean_type_word :
  Source.declaration "boolean_type_word" Output.SourceShape.outputImplementation =
    some (["constant", "string", ":=", "\"boolean\""]) := by
  decide +kernel

private theorem array_helper_character_type_word :
  Source.declaration "character_type_word" Output.SourceShape.outputImplementation =
    some (["constant", "string", ":=", "\"character\""]) := by
  decide +kernel


private theorem array_helper_put_array_value_body :
  expressionDeclaration "put_array_value" Output.SourceShape.outputImplementation =
    some ((Expressions.arrayPutBody.render.drop 1 |>.dropLast), (["with", "global", "=>", "null", ",", "pre", "=>", "state", ".", "array_names", ".", "used", "<", "array_bindings", ".", "max_elements"])) := by
  decide +kernel


private theorem array_helper_add_array_binding_body :
  expressionDeclaration "add_array_binding" Output.SourceShape.outputImplementation =
    some ((Expressions.arrayAddBody.render.drop 1 |>.dropLast), (["with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", "and", "then", "state", ".", "array_names", ".", "names", ".", "count", "<", "array_bindings", ".", "max_bindings", "and", "then", "first", ">", "0", "and", "then", "valid_name_state", "(", "text", ",", "first", ",", "after", ")", "and", "then", "array_bindings", ".", "valid_binding", "(", "(", "first", ",", "after", ",", "bounds", ",", "offset", ",", "length", ",", "mutable", ",", "component_bounds", ",", "boolean_elements", ",", "type_id", ",", "0", ")", ")", "and", "then", "type_id", "<=", "state", ".", "array_names", ".", "names", ".", "types", ".", "count", "and", "then", "(", "if", "type_id", "/=", "0", "then", "bounds", "=", "state", ".", "array_names", ".", "names", ".", "types", ".", "items", "(", "type_id", ")", ".", "bounds", "and", "then", "component_bounds", "=", "state", ".", "array_names", ".", "names", ".", "types", ".", "items", "(", "type_id", ")", ".", "component_bounds", ")", "and", "then", "offset", "+", "length", "<=", "state", ".", "array_names", ".", "used", "and", "then", "(", "if", "state", ".", "array_names", ".", "names", ".", "count", ">", "0", "then", "state", ".", "array_names", ".", "names", ".", "items", "(", "state", ".", "array_names", ".", "names", ".", "count", ")", ".", "view_slot", "=", "0", "and", "then", "offset", ">=", "state", ".", "array_names", ".", "names", ".", "items", "(", "state", ".", "array_names", ".", "names", ".", "count", ")", ".", "offset", "+", "state", ".", "array_names", ".", "names", ".", "items", "(", "state", ".", "array_names", ".", "names", ".", "count", ")", ".", "length", ")", "and", "then", "following", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "valid_state", "(", "text", ",", "add_array_binding", "'", "result", ")", "and", "then", "add_array_binding", "'", "result", ".", "position", "=", "following"])) := by
  decide +kernel


private theorem array_helper_array_values_model_body :
  expressionDeclaration "array_values_model" Output.SourceShape.outputImplementation =
    some (Expressions.arrayValuesModelBody.render, []) := by
  decide +kernel


private theorem array_helper_array_declaration_model_body :
  expressionDeclaration "array_declaration_model" Output.SourceShape.outputImplementation =
    some ((Expressions.arrayDeclarationBody false).render, []) := by
  decide +kernel


private theorem array_helper_array_declaration_at_body :
  ArrayDeclarationNative.SourceChecks.Checked Output.SourceShape.outputImplementation := by
  decide +kernel


private theorem array_helper_put_array_value_impl :
  functionHeader "put_array_value" "is" Output.SourceShape.outputImplementation =
    some (["(", "state", ":", "parser_state", ";", "value", ":", "scalars", ".", "value", ")", "return", "parser_state"]) := by
  decide +kernel


private theorem array_helper_add_array_binding_impl :
  functionHeader "add_array_binding" "is" Output.SourceShape.outputImplementation =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "first", ",", "after", ":", "literal_position", ";", "bounds", ":", "scalars", ".", "interval", ";", "offset", ",", "length", ":", "array_bindings", ".", "element_count", ";", "mutable", ":", "boolean", ";", "following", ":", "literal_position", ";", "component_bounds", ":", "scalars", ".", "interval", ";", "boolean_elements", ":", "boolean", ":=", "false", ";", "type_id", ":", "array_bindings", ".", "type_count", ":=", "0", ")", "return", "parser_state"]) := by
  decide +kernel


private theorem array_helper_array_values_model_spec :
  functionHeader "array_values_model" ";" Output.SourceShape.outputImplementation =
    some ["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "source_state", ")", "and", "then", "valid_state", "(", "text", ",", "result_state", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "parsed", "<=", "length", "and", "then", "length", "<=", "array_bindings", ".", "max_elements", "-", "source_state", ".", "array_names", ".", "used", "and", "then", "result_state", ".", "array_names", ".", "used", "=", "source_state", ".", "array_names", ".", "used", "+", "parsed", ",", "post", "=>", "valid_state", "(", "text", ",", "array_values_model", "'", "result", ")", "and", "then", "(", "if", "array_values_model", "'", "result", ".", "position", "/=", "0", "then", "array_values_model", "'", "result", ".", "position", ">=", "position", "and", "then", "array_values_model", "'", "result", "=", "(", "result_state", "with", "delta", "position", "=>", "array_values_model", "'", "result", ".", "position", ",", "array_names", "=>", "(", "result_state", ".", "array_names", "with", "delta", "used", "=>", "source_state", ".", "array_names", ".", "used", "+", "length", ",", "values", "=>", "array_values_model", "'", "result", ".", "array_names", ".", "values", ")", ")", "and", "then", "(", "for", "all", "slot", "in", "1", "..", "result_state", ".", "array_names", ".", "used", "=>", "array_values_model", "'", "result", ".", "array_names", ".", "values", "(", "slot", ")", "=", "result_state", ".", "array_names", ".", "values", "(", "slot", ")", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "length", "-", "parsed", ")"] := by
  decide +kernel


private theorem array_helper_array_values_model_impl :
  functionHeader "array_values_model" "is" Output.SourceShape.outputImplementation =
    some (["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state"]) := by
  decide +kernel


private theorem array_helper_array_values_at_spec :
  functionHeader "array_values_at" ";" Output.SourceShape.outputImplementation =
    some ["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "source_state", ")", "and", "then", "valid_state", "(", "text", ",", "result_state", ")", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "parsed", "<=", "length", "and", "then", "length", "<=", "array_bindings", ".", "max_elements", "-", "source_state", ".", "array_names", ".", "used", "and", "then", "result_state", ".", "array_names", ".", "used", "=", "source_state", ".", "array_names", ".", "used", "+", "parsed", ",", "post", "=>", "(", "runtime", "=>", "valid_state", "(", "text", ",", "array_values_at", "'", "result", ")", "and", "then", "(", "if", "array_values_at", "'", "result", ".", "position", "/=", "0", "then", "array_values_at", "'", "result", ".", "position", ">=", "position", "and", "then", "array_values_at", "'", "result", "=", "(", "result_state", "with", "delta", "position", "=>", "array_values_at", "'", "result", ".", "position", ",", "array_names", "=>", "(", "result_state", ".", "array_names", "with", "delta", "used", "=>", "source_state", ".", "array_names", ".", "used", "+", "length", ",", "values", "=>", "array_values_at", "'", "result", ".", "array_names", ".", "values", ")", ")", "and", "then", "(", "for", "all", "slot", "in", "1", "..", "result_state", ".", "array_names", ".", "used", "=>", "array_values_at", "'", "result", ".", "array_names", ".", "values", "(", "slot", ")", "=", "result_state", ".", "array_names", ".", "values", "(", "slot", ")", ")", ")", ",", "static", "=>", "array_values_at", "'", "result", "=", "array_values_model", "(", "text", ",", "source_state", ",", "result_state", ",", "position", ",", "length", ",", "parsed", ",", "component_bounds", ")", "and", "then", "same_parser_state", "(", "array_values_at", "'", "result", ",", "array_values_model", "(", "text", ",", "source_state", ",", "result_state", ",", "position", ",", "length", ",", "parsed", ",", "component_bounds", ")", ")", ")"] := by
  decide +kernel


private theorem array_helper_array_values_at_impl :
  functionHeader "array_values_at" "is" Output.SourceShape.outputImplementation =
    some (["(", "text", ":", "string", ";", "source_state", ",", "result_state", ":", "parser_state", ";", "position", ":", "literal_position", ";", "length", ",", "parsed", ":", "array_bindings", ".", "element_count", ";", "component_bounds", ":", "scalars", ".", "interval", ")", "return", "parser_state"]) := by
  decide +kernel


private theorem array_helper_array_declaration_model_spec :
  functionHeader "array_declaration_model" ";" Output.SourceShape.outputImplementation =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "array_declaration_model", "'", "result", ")", "and", "then", "(", "array_declaration_model", "'", "result", ".", "position", "=", "0", "or", "else", "array_declaration_model", "'", "result", ".", "position", ">", "state", ".", "position", ")"]) := by
  decide +kernel


private theorem array_helper_array_declaration_model_impl :
  functionHeader "array_declaration_model" "is" Output.SourceShape.outputImplementation =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state"]) := by
  decide +kernel


private theorem array_helper_array_declaration_at_spec :
  functionHeader "array_declaration_at" ";" Output.SourceShape.outputImplementation =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "(", "runtime", "=>", "valid_state", "(", "text", ",", "array_declaration_at", "'", "result", ")", "and", "then", "(", "array_declaration_at", "'", "result", ".", "position", "=", "0", "or", "else", "array_declaration_at", "'", "result", ".", "position", ">", "state", ".", "position", ")", ",", "static", "=>", "array_declaration_at", "'", "result", "=", "array_declaration_model", "(", "text", ",", "state", ",", "arguments", ")", ")"]) := by
  decide +kernel


private theorem array_helper_array_declaration_at_impl :
  functionHeader "array_declaration_at" "is" Output.SourceShape.outputImplementation =
    some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state"]) := by
  decide +kernel


theorem candidate_array_helpers : ArrayHelperTranslationFor Output.SourceShape.outputImplementation := by
  exact ⟨Expressions.checked_array_precedence,
    Expressions.checked_array_scopes,
    array_helper_integer_type_word,
    array_helper_boolean_type_word,
    array_helper_character_type_word,
    array_helper_put_array_value_body,
    array_helper_add_array_binding_body,
    array_helper_array_values_model_body,
    array_helper_array_declaration_model_body,
    array_helper_array_declaration_at_body,
    array_helper_put_array_value_impl,
    array_helper_add_array_binding_impl,
    array_helper_array_values_model_spec,
    array_helper_array_values_model_impl,
    array_helper_array_values_at_spec,
    array_helper_array_values_at_impl,
    array_helper_array_declaration_model_spec,
    array_helper_array_declaration_model_impl,
    array_helper_array_declaration_at_spec,
    array_helper_array_declaration_at_impl⟩

/-- New initializer and aggregate contracts are checked alongside the shared
array trees and their scope/precedence predicates. -/
theorem candidate_boolean_array_helpers :
    BooleanArraySource.Checked Output.SourceShape.outputImplementation := by
  exact BooleanArraySource.candidate_checked

/-- The complete ordinary declaration body, including scope, precedence and
native contracts, independently matched against the reviewed complete source. -/
theorem candidate_boolean_declaration :
    BooleanDeclarationNative.SourceChecks.Checked Output.SourceShape.outputImplementation := by
  constructor
  · decide +kernel
  · decide +kernel
  · decide +kernel
  · change functionHeader "boolean_declaration_at" ";" Output.SourceShape.outputImplementation =
      some (BooleanDeclarationNative.SourceChecks.implHeader ++ expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State), Post => Valid_State (Text, Boolean_Declaration_At'Result) and then (Boolean_Declaration_At'Result.Position = 0 or else (Boolean_Declaration_At'Result.Position > State.Position and then Boolean_Declaration_At'Result.Functions = State.Functions and then Boolean_Declaration_At'Result.Procedures = State.Procedures and then Boolean_Declaration_At'Result.First_Procedure_Parameter = State.First_Procedure_Parameter and then Boolean_Declaration_At'Result.First_Parameter = State.First_Parameter and then Boolean_Declaration_At'Result.Pure = State.Pure))")
    rw [BooleanDeclarationExpectedTokens.specAspects]
    kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "boolean_declaration_at", "'", "result", ")", "and", "then", "(", "boolean_declaration_at", "'", "result", ".", "position", "=", "0", "or", "else", "(", "boolean_declaration_at", "'", "result", ".", "position", ">", "state", ".", "position", "and", "then", "boolean_declaration_at", "'", "result", ".", "functions", "=", "state", ".", "functions", "and", "then", "boolean_declaration_at", "'", "result", ".", "procedures", "=", "state", ".", "procedures", "and", "then", "boolean_declaration_at", "'", "result", ".", "first_procedure_parameter", "=", "state", ".", "first_procedure_parameter", "and", "then", "boolean_declaration_at", "'", "result", ".", "first_parameter", "=", "state", ".", "first_parameter", "and", "then", "boolean_declaration_at", "'", "result", ".", "pure", "=", "state", ".", "pure", ")", ")"]))
  · decide +kernel


/-- Complete String helper source trees, native subtypes, defaults and contracts.
The exact source excerpts are reviewed together with their typed body equations. -/
abbrev StringHelperTranslationFor (bodyTokens : List String) : Prop :=
  StringNative.WellFormedTrees ∧
  StringNative.WellScopedTrees ∧
  StringNative.SourceChecks.Checked bodyTokens ∧
  expressionDeclaration "fixed_bounds_valid" bodyTokens = some (StringNative.fixedBoundsBody.render, []) ∧
  expressionDeclaration "character_literal_after" bodyTokens = some (StringNative.characterLiteralBody.render, []) ∧
  expressionDeclaration "concatenated_first" bodyTokens = some (StringNative.concatenatedFirstBody.render, []) ∧
  functionHeader "fixed_bounds_valid" "is" bodyTokens = some (["(", "length", ":", "capacity_value", ";", "dynamic", ",", "is_character", ":", "boolean", ";", "first_index", ",", "last_index", ":", "scalars", ".", "value", ";", "slot", ":", "binding_index", ")", "return", "boolean"]) ∧
  functionHeader "character_literal_after" ";" bodyTokens = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "character_literal_after", "'", "result", "=", "0", "or", "else", "character_literal_after", "'", "result", "=", "position", "+", "3"]) ∧
  functionHeader "character_literal_after" "is" bodyTokens = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position"]) ∧
  functionHeader "indexed_at" ";" bodyTokens = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ";", "arrays", ":", "array_bindings", ".", "metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ";", "elaborating", ",", "character_element", ":", "boolean", ";", "context_first", ":", "cursor", ":=", "1", ")", "return", "value_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "context_first", "<=", "text", "'", "last", "+", "1", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_names", "(", "text", ",", "names", ")", "and", "then", "scalar_expressions", ".", "valid_environment", "(", "text", ",", "scalar_names", ")", "and", "then", "array_bindings", ".", "valid_metadata", "(", "text", ",", "arrays", ")", ",", "post", "=>", "indexed_at", "'", "result", ".", "value_first", "<=", "text", "'", "last", "+", "1", "and", "then", "indexed_at", "'", "result", ".", "reference", "<=", "names", ".", "count", "and", "then", "(", "indexed_at", "'", "result", ".", "after", "=", "0", "or", "else", "(", "indexed_at", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "indexed_at", "'", "result", ".", "operands", ">", "0", "and", "then", "(", "if", "character_element", "then", "indexed_at", "'", "result", ".", "minimum_length", "=", "1", "and", "then", "indexed_at", "'", "result", ".", "static_length", "=", "1", "and", "then", "not", "indexed_at", "'", "result", ".", "dynamic_seen", "and", "then", "indexed_at", "'", "result", ".", "first_index", "=", "scalars", ".", "singleton", "(", "1", ")", "and", "then", "indexed_at", "'", "result", ".", "last_index", "=", "scalars", ".", "singleton", "(", "1", ")", ")", ")", ")"]) ∧
  functionHeader "indexed_at" "is" bodyTokens = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ";", "arrays", ":", "array_bindings", ".", "metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ";", "elaborating", ",", "character_element", ":", "boolean", ";", "context_first", ":", "cursor", ":=", "1", ")", "return", "value_result"]) ∧
  functionHeader "character_at" ";" bodyTokens = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ";", "arrays", ":", "array_bindings", ".", "metadata", ":=", "array_bindings", ".", "empty_metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ";", "elaborating", ":", "boolean", ":=", "false", ")", "return", "value_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_names", "(", "text", ",", "names", ")", "and", "then", "scalar_expressions", ".", "valid_environment", "(", "text", ",", "scalar_names", ")", "and", "then", "array_bindings", ".", "valid_metadata", "(", "text", ",", "arrays", ")", ",", "post", "=>", "character_at", "'", "result", ".", "value_first", "<=", "text", "'", "last", "+", "1", "and", "then", "character_at", "'", "result", ".", "reference", "<=", "names", ".", "count", "and", "then", "(", "character_at", "'", "result", ".", "after", "=", "0", "or", "else", "(", "character_at", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "character_at", "'", "result", ".", "minimum_length", "=", "1", "and", "then", "character_at", "'", "result", ".", "static_length", "=", "1", "and", "then", "not", "character_at", "'", "result", ".", "dynamic_seen", "and", "then", "character_at", "'", "result", ".", "first_index", "=", "scalars", ".", "singleton", "(", "1", ")", "and", "then", "character_at", "'", "result", ".", "last_index", "=", "scalars", ".", "singleton", "(", "1", ")", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ")"]) ∧
  functionHeader "character_at" "is" bodyTokens = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ";", "arrays", ":", "array_bindings", ".", "metadata", ":=", "array_bindings", ".", "empty_metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ";", "elaborating", ":", "boolean", ":=", "false", ")", "return", "value_result"]) ∧
  functionHeader "concatenated_first" "is" bodyTokens = some (["(", "left", ":", "expression_state", ";", "right", ":", "value_result", ")", "return", "scalars", ".", "interval"]) ∧
  functionHeader "concatenated_last" "is" bodyTokens = some (["(", "left", ":", "expression_state", ";", "right", ":", "value_result", ")", "return", "scalars", ".", "interval"]) ∧
  functionHeader "character_declaration_at" ";" bodyTokens = some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "character_declaration_at", "'", "result", ")", "and", "then", "(", "character_declaration_at", "'", "result", ".", "position", "=", "0", "or", "else", "character_declaration_at", "'", "result", ".", "position", ">", "state", ".", "position", ")"]) ∧
  functionHeader "character_declaration_at" "is" bodyTokens = some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state"])

private theorem string_helper_indexed_at_ordinary :
    BooleanDeclarationNative.SourceChecks.ordinaryFunction "indexed_at"
      Output.SourceShape.outputImplementation = some StringNative.indexedBody.render := by
  simp only [StringNative.indexedBody,
    StringNative.Body.render,
    StringNative.guard,
    StringNative.Command.list,
    List.foldr_cons,
    List.foldr_nil,
    StringNative.Command.render,
    StringNative.Command.renderElse]
  rfl


private theorem string_helper_character_at_ordinary :
    BooleanDeclarationNative.SourceChecks.ordinaryFunction "character_at"
      Output.SourceShape.outputImplementation = some StringNative.characterBody.render := by
  simp only [StringNative.characterBody,
    StringNative.Body.render,
    StringNative.Command.list,
    List.foldr_cons,
    List.foldr_nil,
    StringNative.Command.render,
    StringNative.Command.renderElse]
  rfl


private theorem string_helper_concatenated_last_ordinary :
    BooleanDeclarationNative.SourceChecks.ordinaryFunction "concatenated_last"
      Output.SourceShape.outputImplementation = some StringNative.concatenatedLastBody.render := by
  simp only [StringNative.concatenatedLastBody,
    StringNative.Body.render,
    StringNative.guard,
    StringNative.Command.list,
    List.foldr_cons,
    List.foldr_nil,
    StringNative.Command.render,
    StringNative.Command.renderElse]
  rfl


private theorem string_helper_character_declaration_at_ordinary :
    BooleanDeclarationNative.SourceChecks.ordinaryFunction "character_declaration_at"
      Output.SourceShape.outputImplementation = some StringNative.characterDeclarationBody.render := by
  simp only [StringNative.characterDeclarationBody,
    StringNative.Body.render,
    StringNative.guard,
    StringNative.Command.list,
    List.foldr_cons,
    List.foldr_nil,
    StringNative.Command.render,
    StringNative.Command.renderElse]
  rfl


private theorem string_helper_guarded_at_ordinary :
    BooleanDeclarationNative.SourceChecks.ordinaryFunction "guarded_at"
      Output.SourceShape.outputImplementation = some StringNative.guardedBody.render := by
  simp only [StringNative.guardedBody,
    StringNative.Body.render,
    StringNative.Command.render]
  rfl

private theorem string_helper_guarded_at_impl :
    functionHeader "guarded_at" "is" Output.SourceShape.outputImplementation =
      some StringNative.SourceChecks.guardedHeader := by
  decide +kernel

private theorem string_helper_guarded_at_spec :
    functionHeader "guarded_at" ";" Output.SourceShape.outputImplementation =
      some StringNative.SourceChecks.guardedContract := by
  decide +kernel

private theorem string_helper_ordinary_bodies :
    StringNative.SourceChecks.Checked Output.SourceShape.outputImplementation := by
  exact ⟨string_helper_indexed_at_ordinary, string_helper_character_at_ordinary,
    string_helper_concatenated_last_ordinary, string_helper_character_declaration_at_ordinary,
    string_helper_guarded_at_ordinary, string_helper_guarded_at_impl, string_helper_guarded_at_spec⟩


private theorem string_helper_fixed_bounds_valid_body :
  expressionDeclaration "fixed_bounds_valid" Output.SourceShape.outputImplementation = some (StringNative.fixedBoundsBody.render, []) := by
  decide +kernel


private theorem string_helper_character_literal_after_body :
  expressionDeclaration "character_literal_after" Output.SourceShape.outputImplementation = some (StringNative.characterLiteralBody.render, []) := by
  decide +kernel


private theorem string_helper_concatenated_first_body :
  expressionDeclaration "concatenated_first" Output.SourceShape.outputImplementation = some (StringNative.concatenatedFirstBody.render, []) := by
  decide +kernel


private theorem string_helper_fixed_bounds_valid_impl :
  functionHeader "fixed_bounds_valid" "is" Output.SourceShape.outputImplementation = some (["(", "length", ":", "capacity_value", ";", "dynamic", ",", "is_character", ":", "boolean", ";", "first_index", ",", "last_index", ":", "scalars", ".", "value", ";", "slot", ":", "binding_index", ")", "return", "boolean"]) := by
  decide +kernel


private theorem string_helper_character_literal_after_spec :
  functionHeader "character_literal_after" ";" Output.SourceShape.outputImplementation = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "character_literal_after", "'", "result", "=", "0", "or", "else", "character_literal_after", "'", "result", "=", "position", "+", "3"]) := by
  decide +kernel


private theorem string_helper_character_literal_after_impl :
  functionHeader "character_literal_after" "is" Output.SourceShape.outputImplementation = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ")", "return", "literal_position"]) := by
  decide +kernel


private theorem string_helper_indexed_at_spec :
  functionHeader "indexed_at" ";" Output.SourceShape.outputImplementation = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ";", "arrays", ":", "array_bindings", ".", "metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ";", "elaborating", ",", "character_element", ":", "boolean", ";", "context_first", ":", "cursor", ":=", "1", ")", "return", "value_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "context_first", "<=", "text", "'", "last", "+", "1", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_names", "(", "text", ",", "names", ")", "and", "then", "scalar_expressions", ".", "valid_environment", "(", "text", ",", "scalar_names", ")", "and", "then", "array_bindings", ".", "valid_metadata", "(", "text", ",", "arrays", ")", ",", "post", "=>", "indexed_at", "'", "result", ".", "value_first", "<=", "text", "'", "last", "+", "1", "and", "then", "indexed_at", "'", "result", ".", "reference", "<=", "names", ".", "count", "and", "then", "(", "indexed_at", "'", "result", ".", "after", "=", "0", "or", "else", "(", "indexed_at", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "indexed_at", "'", "result", ".", "operands", ">", "0", "and", "then", "(", "if", "character_element", "then", "indexed_at", "'", "result", ".", "minimum_length", "=", "1", "and", "then", "indexed_at", "'", "result", ".", "static_length", "=", "1", "and", "then", "not", "indexed_at", "'", "result", ".", "dynamic_seen", "and", "then", "indexed_at", "'", "result", ".", "first_index", "=", "scalars", ".", "singleton", "(", "1", ")", "and", "then", "indexed_at", "'", "result", ".", "last_index", "=", "scalars", ".", "singleton", "(", "1", ")", ")", ")", ")"]) := by
  decide +kernel


private theorem string_helper_indexed_at_impl :
  functionHeader "indexed_at" "is" Output.SourceShape.outputImplementation = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ";", "arrays", ":", "array_bindings", ".", "metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ";", "elaborating", ",", "character_element", ":", "boolean", ";", "context_first", ":", "cursor", ":=", "1", ")", "return", "value_result"]) := by
  decide +kernel


private theorem string_helper_character_at_spec :
  functionHeader "character_at" ";" Output.SourceShape.outputImplementation = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ";", "arrays", ":", "array_bindings", ".", "metadata", ":=", "array_bindings", ".", "empty_metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ";", "elaborating", ":", "boolean", ":=", "false", ")", "return", "value_result", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_names", "(", "text", ",", "names", ")", "and", "then", "scalar_expressions", ".", "valid_environment", "(", "text", ",", "scalar_names", ")", "and", "then", "array_bindings", ".", "valid_metadata", "(", "text", ",", "arrays", ")", ",", "post", "=>", "character_at", "'", "result", ".", "value_first", "<=", "text", "'", "last", "+", "1", "and", "then", "character_at", "'", "result", ".", "reference", "<=", "names", ".", "count", "and", "then", "(", "character_at", "'", "result", ".", "after", "=", "0", "or", "else", "(", "character_at", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", "and", "then", "character_at", "'", "result", ".", "minimum_length", "=", "1", "and", "then", "character_at", "'", "result", ".", "static_length", "=", "1", "and", "then", "not", "character_at", "'", "result", ".", "dynamic_seen", "and", "then", "character_at", "'", "result", ".", "first_index", "=", "scalars", ".", "singleton", "(", "1", ")", "and", "then", "character_at", "'", "result", ".", "last_index", "=", "scalars", ".", "singleton", "(", "1", ")", ")", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ")"]) := by
  decide +kernel


private theorem string_helper_character_at_impl :
  functionHeader "character_at" "is" Output.SourceShape.outputImplementation = some (["(", "text", ":", "string", ";", "position", ":", "literal_position", ";", "names", ":", "binding_environment", ";", "scalar_names", ":", "scalar_expressions", ".", "environment", ";", "arrays", ":", "array_bindings", ".", "metadata", ":=", "array_bindings", ".", "empty_metadata", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ";", "elaborating", ":", "boolean", ":=", "false", ")", "return", "value_result"]) := by
  decide +kernel


private theorem string_helper_concatenated_first_impl :
  functionHeader "concatenated_first" "is" Output.SourceShape.outputImplementation = some (["(", "left", ":", "expression_state", ";", "right", ":", "value_result", ")", "return", "scalars", ".", "interval"]) := by
  decide +kernel


private theorem string_helper_concatenated_last_impl :
  functionHeader "concatenated_last" "is" Output.SourceShape.outputImplementation = some (["(", "left", ":", "expression_state", ";", "right", ":", "value_result", ")", "return", "scalars", ".", "interval"]) := by
  decide +kernel


private theorem string_helper_character_declaration_at_spec :
  functionHeader "character_declaration_at" ";" Output.SourceShape.outputImplementation = some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state", "with", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "valid_state", "(", "text", ",", "state", ")", ",", "post", "=>", "valid_state", "(", "text", ",", "character_declaration_at", "'", "result", ")", "and", "then", "(", "character_declaration_at", "'", "result", ".", "position", "=", "0", "or", "else", "character_declaration_at", "'", "result", ".", "position", ">", "state", ".", "position", ")"]) := by
  decide +kernel


private theorem string_helper_character_declaration_at_impl :
  functionHeader "character_declaration_at" "is" Output.SourceShape.outputImplementation = some (["(", "text", ":", "string", ";", "state", ":", "parser_state", ";", "arguments", ":", "boolean", ")", "return", "parser_state"]) := by
  decide +kernel


theorem candidate_string_helpers : StringHelperTranslationFor Output.SourceShape.outputImplementation := by
  exact ⟨StringNative.checked_precedence,
    StringNative.checked_scopes,
    string_helper_ordinary_bodies,
    string_helper_fixed_bounds_valid_body,
    string_helper_character_literal_after_body,
    string_helper_concatenated_first_body,
    string_helper_fixed_bounds_valid_impl,
    string_helper_character_literal_after_spec,
    string_helper_character_literal_after_impl,
    string_helper_indexed_at_spec,
    string_helper_indexed_at_impl,
    string_helper_character_at_spec,
    string_helper_character_at_impl,
    string_helper_concatenated_first_impl,
    string_helper_concatenated_last_impl,
    string_helper_character_declaration_at_spec,
    string_helper_character_declaration_at_impl⟩
end Silver.Compose.SourceBridge

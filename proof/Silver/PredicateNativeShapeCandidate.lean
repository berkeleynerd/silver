module

public import Silver.PredicateNativeSourceChecks
public import Silver.PredicateCharacterSourceCandidate
public import Silver.PredicateNativeShapeExpectedTokens
meta import Silver.CertificateWitness
import all Init.Data.Repr

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.Predicate.SourceChecks.NativeShapeCandidate
open Silver.SourceBridge Native NativeSourceChecks

/-! Exact native expression, header and declaration source checks.
The final source bridge transports the reviewed shape to authoritative tokens. -/

/-- The source requirements assigned to this independent proof leaf. -/
structure Checked : Prop where
  validityCallWord : Source.declaration "validity_call_word" SourceShape.bodyTokens =
    some ["constant", "string", ":=", "\"input_is_valid\""]
  same_interval_header : functionHeader "same_interval" "is" SourceShape.bodyTokens = some same_interval_header
  same_interval_body : expressionDeclaration "same_interval" SourceShape.bodyTokens = some (same_interval_expression, logical_equality_aspects)
  same_path_header : functionHeader "same_path" "is" SourceShape.bodyTokens = some same_path_header
  same_path_body : expressionDeclaration "same_path" SourceShape.bodyTokens = some (same_path_expression, logical_equality_aspects)
  same_values_header : functionHeader "same_values" "is" SourceShape.bodyTokens = some same_values_header
  same_values_body : expressionDeclaration "same_values" SourceShape.bodyTokens = some (same_values_expression, logical_equality_aspects)
  same_flow_header : functionHeader "same_flow" "is" SourceShape.bodyTokens = some same_flow_header
  same_flow_body : expressionDeclaration "same_flow" SourceShape.bodyTokens = some (same_flow_expression, logical_equality_aspects)
  same_condition_header : functionHeader "same_condition" "is" SourceShape.bodyTokens = some same_condition_header
  same_condition_body : expressionDeclaration "same_condition" SourceShape.bodyTokens = some (same_condition_expression, logical_equality_aspects)
  lemma_condition_equality_impl : procedureHeader "lemma_condition_equality" "is" SourceShape.bodyTokens = some lemma_condition_equality_impl
  lemma_flow_equality_impl : procedureHeader "lemma_flow_equality" "is" SourceShape.bodyTokens = some lemma_flow_equality_impl
  valid_condition_header : functionHeader "valid_condition" "is" SourceShape.bodyTokens = some valid_condition_header
  valid_condition_body : Source.expressionBody "valid_condition" SourceShape.bodyTokens = some valid_condition_expression
  summary_of_body : qualifiedExpressionBody "summary_of" SourceShape.bodyTokens = some ((summaryBody.render.drop 1).dropLast)
  bound_of_body : qualifiedExpressionBody "bound_of" SourceShape.bodyTokens = some ((boundBody.render.drop 1).dropLast)
  binding_summary_body : qualifiedExpressionBody "binding_summary" SourceShape.bodyTokens = some ((bindingSummaryBody.render.drop 1).dropLast)
  scalar_comparison_at_body : Source.expressionBody "scalar_comparison_at" SourceShape.bodyTokens = some (comparisonBody.render)
  character_condition_body : Source.expressionBody "character_condition" SourceShape.bodyTokens = some (characterBody.render)
  character_condition_spec_header : functionHeader "character_condition" ";" SourceShape.bodyTokens = some character_condition_spec_header
  character_condition_impl_header : functionHeader "character_condition" "is" SourceShape.bodyTokens = some character_condition_impl_header
  length_at_body : Source.expressionBody "length_at" SourceShape.bodyTokens = some (lengthBody.render)
  primary_model_body : Source.expressionBody "primary_model" SourceShape.bodyTokens = some (primaryBody.render)
  relation_model_body : Source.expressionBody "relation_model" SourceShape.bodyTokens = some (relationBody.render)
  chain_token_body : Source.expressionBody "chain_token" SourceShape.bodyTokens = some (chainTokenBody.render)
  chain_after_body : Source.expressionBody "chain_after" SourceShape.bodyTokens = some (chainAfterBody.render)
  condition_tail_body : Source.expressionBody "condition_tail" SourceShape.bodyTokens = some (tailBody.render)
  condition_model_body : Source.expressionBody "condition_model" SourceShape.bodyTokens = some (modelBody.render)
  summary_of_impl_header : functionHeader "summary_of" "is" SourceShape.bodyTokens = some summary_of_impl_header
  bound_of_impl_header : functionHeader "bound_of" "is" SourceShape.bodyTokens = some bound_of_impl_header
  binding_summary_impl_header : functionHeader "binding_summary" "is" SourceShape.bodyTokens = some binding_summary_impl_header
  scalar_comparison_at_spec_header : functionHeader "scalar_comparison_at" ";" SourceShape.bodyTokens = some scalar_comparison_at_spec_header
  scalar_comparison_at_impl_header : functionHeader "scalar_comparison_at" "is" SourceShape.bodyTokens = some scalar_comparison_at_impl_header
  length_at_spec_header : functionHeader "length_at" ";" SourceShape.bodyTokens = some length_at_spec_header
  length_at_impl_header : functionHeader "length_at" "is" SourceShape.bodyTokens = some length_at_impl_header
  primary_model_spec_header : functionHeader "primary_model" ";" SourceShape.bodyTokens = some primary_model_spec_header
  primary_model_impl_header : functionHeader "primary_model" "is" SourceShape.bodyTokens = some primary_model_impl_header
  relation_model_spec_header : functionHeader "relation_model" ";" SourceShape.bodyTokens = some relation_model_spec_header
  relation_model_impl_header : functionHeader "relation_model" "is" SourceShape.bodyTokens = some relation_model_impl_header
  chain_token_spec_header : functionHeader "chain_token" ";" SourceShape.bodyTokens = some chain_token_spec_header
  chain_token_impl_header : functionHeader "chain_token" "is" SourceShape.bodyTokens = some chain_token_impl_header
  chain_after_spec_header : functionHeader "chain_after" ";" SourceShape.bodyTokens = some chain_after_spec_header
  chain_after_impl_header : functionHeader "chain_after" "is" SourceShape.bodyTokens = some chain_after_impl_header
  condition_tail_spec_header : functionHeader "condition_tail" ";" SourceShape.bodyTokens = some condition_tail_spec_header
  condition_tail_impl_header : functionHeader "condition_tail" "is" SourceShape.bodyTokens = some condition_tail_impl_header
  condition_model_spec_header : functionHeader "condition_model" ";" SourceShape.bodyTokens = some condition_model_spec_header
  condition_model_impl_header : functionHeader "condition_model" "is" SourceShape.bodyTokens = some condition_model_impl_header
  comparison_result_declaration : Lexical.SourceBridge.recordDeclaration "comparison_result" SourceShape.bodyTokens = some comparison_result_declaration
  length_result_declaration : Lexical.SourceBridge.recordDeclaration "length_result" SourceShape.bodyTokens = some length_result_declaration
  boolean_array_after_body : Source.expressionBody "boolean_array_after" SourceShape.bodyTokens = some booleanArrayBody.render
  boolean_array_after_spec_header : functionHeader "boolean_array_after" ";" SourceShape.bodyTokens = some boolean_array_after_spec_header
  boolean_array_after_impl_header : functionHeader "boolean_array_after" "is" SourceShape.bodyTokens = some boolean_array_after_impl_header
  boolean_atom_after_body : Source.expressionBody "boolean_atom_after" SourceShape.bodyTokens = some (booleanAtomBody.render)
  boolean_atom_after_spec_header : functionHeader "boolean_atom_after" ";" SourceShape.bodyTokens = some boolean_atom_after_spec_header
  boolean_atom_after_impl_header : functionHeader "boolean_atom_after" "is" SourceShape.bodyTokens = some boolean_atom_after_impl_header
  boolean_factor_model_body : Source.expressionBody "boolean_factor_model" SourceShape.bodyTokens = some (booleanFactorBody.render)
  boolean_factor_model_spec_header : functionHeader "boolean_factor_model" ";" SourceShape.bodyTokens = some boolean_factor_model_spec_header
  boolean_factor_model_impl_header : functionHeader "boolean_factor_model" "is" SourceShape.bodyTokens = some boolean_factor_model_impl_header
  boolean_relation_model_body : Source.expressionBody "boolean_relation_model" SourceShape.bodyTokens = some (booleanRelationBody.render)
  boolean_relation_model_spec_header : functionHeader "boolean_relation_model" ";" SourceShape.bodyTokens = some boolean_relation_model_spec_header
  boolean_relation_model_impl_header : functionHeader "boolean_relation_model" "is" SourceShape.bodyTokens = some boolean_relation_model_impl_header
  chain_kind_declaration : typeDeclaration "chain_kind" SourceShape.bodyTokens = some chain_kind_declaration

private theorem native_validityCallWord : Source.declaration "validity_call_word" SourceShape.bodyTokens =
    some ["constant", "string", ":=", "\"input_is_valid\""] := by decide +kernel

private theorem native_same_interval_header : functionHeader "same_interval" "is" SourceShape.bodyTokens = some same_interval_header := by
  decide +kernel

private theorem native_same_interval_body : expressionDeclaration "same_interval" SourceShape.bodyTokens = some (same_interval_expression, logical_equality_aspects) := by
  decide +kernel

private theorem native_same_path_header : functionHeader "same_path" "is" SourceShape.bodyTokens = some same_path_header := by
  decide +kernel

private theorem native_same_path_body : expressionDeclaration "same_path" SourceShape.bodyTokens = some (same_path_expression, logical_equality_aspects) := by
  decide +kernel

private theorem native_same_values_header : functionHeader "same_values" "is" SourceShape.bodyTokens = some same_values_header := by
  decide +kernel

private theorem native_same_values_body : expressionDeclaration "same_values" SourceShape.bodyTokens = some (same_values_expression, logical_equality_aspects) := by
  decide +kernel

private theorem native_same_flow_header : functionHeader "same_flow" "is" SourceShape.bodyTokens = some same_flow_header := by
  decide +kernel

private theorem native_same_flow_body : expressionDeclaration "same_flow" SourceShape.bodyTokens = some (same_flow_expression, logical_equality_aspects) := by
  decide +kernel

private theorem native_same_condition_header : functionHeader "same_condition" "is" SourceShape.bodyTokens = some same_condition_header := by
  decide +kernel

private theorem native_same_condition_body : expressionDeclaration "same_condition" SourceShape.bodyTokens = some (same_condition_expression, logical_equality_aspects) := by
  decide +kernel

private theorem native_lemma_condition_equality_impl : procedureHeader "lemma_condition_equality" "is" SourceShape.bodyTokens = some lemma_condition_equality_impl := by
  decide +kernel

private theorem native_lemma_flow_equality_impl : procedureHeader "lemma_flow_equality" "is" SourceShape.bodyTokens = some lemma_flow_equality_impl := by
  decide +kernel

private theorem native_valid_condition_header : functionHeader "valid_condition" "is" SourceShape.bodyTokens = some valid_condition_header := by
  decide +kernel

private theorem native_valid_condition_body : Source.expressionBody "valid_condition" SourceShape.bodyTokens = some valid_condition_expression := by
  decide +kernel

private theorem native_summary_of_body : qualifiedExpressionBody "summary_of" SourceShape.bodyTokens = some ((summaryBody.render.drop 1).dropLast) := by
  simp only [summaryBody, Expr.render]
  decide +kernel

private theorem native_bound_of_body : qualifiedExpressionBody "bound_of" SourceShape.bodyTokens = some ((boundBody.render.drop 1).dropLast) := by
  simp only [boundBody, Expr.render]
  decide +kernel

private theorem native_binding_summary_body : qualifiedExpressionBody "binding_summary" SourceShape.bodyTokens = some ((bindingSummaryBody.render.drop 1).dropLast) := by
  simp only [bindingSummaryBody, Expr.render]
  decide +kernel

private theorem native_scalar_comparison_at_body : Source.expressionBody "scalar_comparison_at" SourceShape.bodyTokens = some (comparisonBody.render) := by
  simp only [comparisonBody, Expr.render]
  decide +kernel

private theorem native_character_condition_body : Source.expressionBody "character_condition" SourceShape.bodyTokens = some (characterBody.render) := CharacterSourceCandidate.character_body

private theorem native_character_condition_spec_header : functionHeader "character_condition" ";" SourceShape.bodyTokens = some character_condition_spec_header := CharacterSourceCandidate.character_spec

private theorem native_character_condition_impl_header : functionHeader "character_condition" "is" SourceShape.bodyTokens = some character_condition_impl_header := CharacterSourceCandidate.character_impl

private theorem native_length_at_body : Source.expressionBody "length_at" SourceShape.bodyTokens = some (lengthBody.render) := CharacterSourceCandidate.length_body

private theorem native_primary_model_body : Source.expressionBody "primary_model" SourceShape.bodyTokens = some (primaryBody.render) := by
  simp only [primaryBody, Expr.render, Expr.declared]
  decide +kernel

private theorem native_relation_model_body : Source.expressionBody "relation_model" SourceShape.bodyTokens = some (relationBody.render) := CharacterSourceCandidate.relation_body

private theorem native_chain_token_body : Source.expressionBody "chain_token" SourceShape.bodyTokens = some (chainTokenBody.render) := by
  simp only [chainTokenBody, Expr.render]
  decide +kernel

private theorem native_chain_after_body : Source.expressionBody "chain_after" SourceShape.bodyTokens = some (chainAfterBody.render) := by
  simp only [chainAfterBody]
  decide +kernel

private theorem native_condition_tail_body : Source.expressionBody "condition_tail" SourceShape.bodyTokens = some (tailBody.render) := by
  simp only [tailBody, Expr.render, Expr.declared]
  decide +kernel

private theorem native_condition_model_body : Source.expressionBody "condition_model" SourceShape.bodyTokens = some (modelBody.render) := by
  simp only [modelBody, Expr.render]
  decide +kernel

private theorem native_summary_of_impl_header : functionHeader "summary_of" "is" SourceShape.bodyTokens = some summary_of_impl_header := by
  decide +kernel

private theorem native_bound_of_impl_header : functionHeader "bound_of" "is" SourceShape.bodyTokens = some bound_of_impl_header := by
  decide +kernel

private theorem native_binding_summary_impl_header : functionHeader "binding_summary" "is" SourceShape.bodyTokens = some binding_summary_impl_header := by
  decide +kernel

private theorem native_scalar_comparison_at_spec_header : functionHeader "scalar_comparison_at" ";" SourceShape.bodyTokens = some scalar_comparison_at_spec_header := by
  decide +kernel

private theorem native_scalar_comparison_at_impl_header : functionHeader "scalar_comparison_at" "is" SourceShape.bodyTokens = some scalar_comparison_at_impl_header := by
  decide +kernel

private theorem native_length_at_spec_header : functionHeader "length_at" ";" SourceShape.bodyTokens = some length_at_spec_header := by
  decide +kernel

private theorem native_length_at_impl_header : functionHeader "length_at" "is" SourceShape.bodyTokens = some length_at_impl_header := by
  decide +kernel

private theorem native_primary_model_spec_header : functionHeader "primary_model" ";" SourceShape.bodyTokens = some primary_model_spec_header := by
  change functionHeader "primary_model" ";" SourceShape.bodyTokens =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => Primary_Model'Result.Count = Facts.Count and then Valid_Condition (Context, Primary_Model'Result) and then (Primary_Model'Result.After = 0 or else Primary_Model'Result.After in Position + 1 .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 1)")
  rw [NativeShapeExpectedTokens.primary_model_spec_header]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ")", "return", "condition_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", ",", "post", "=>", "primary_model", "'", "result", ".", "count", "=", "facts", ".", "count", "and", "then", "valid_condition", "(", "context", ",", "primary_model", "'", "result", ")", "and", "then", "(", "primary_model", "'", "result", ".", "after", "=", "0", "or", "else", "primary_model", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "1", ")"]))

private theorem native_primary_model_impl_header : functionHeader "primary_model" "is" SourceShape.bodyTokens = some primary_model_impl_header := by
  decide +kernel

private theorem native_relation_model_spec_header : functionHeader "relation_model" ";" SourceShape.bodyTokens = some relation_model_spec_header := by
  change functionHeader "relation_model" ";" SourceShape.bodyTokens =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => Relation_Model'Result.Count = Facts.Count and then Valid_Condition (Context, Relation_Model'Result) and then (Relation_Model'Result.After = 0 or else Relation_Model'Result.After in Position + 1 .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 4)")
  rw [NativeShapeExpectedTokens.relation_model_spec_header]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ")", "return", "condition_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", ",", "post", "=>", "relation_model", "'", "result", ".", "count", "=", "facts", ".", "count", "and", "then", "valid_condition", "(", "context", ",", "relation_model", "'", "result", ")", "and", "then", "(", "relation_model", "'", "result", ".", "after", "=", "0", "or", "else", "relation_model", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "4", ")"]))

private theorem native_relation_model_impl_header : functionHeader "relation_model" "is" SourceShape.bodyTokens = some relation_model_impl_header := by
  decide +kernel

private theorem native_chain_token_spec_header : functionHeader "chain_token" ";" SourceShape.bodyTokens = some chain_token_spec_header := by
  decide +kernel

private theorem native_chain_token_impl_header : functionHeader "chain_token" "is" SourceShape.bodyTokens = some chain_token_impl_header := by
  decide +kernel

private theorem native_chain_after_spec_header : functionHeader "chain_after" ";" SourceShape.bodyTokens = some chain_after_spec_header := by
  decide +kernel

private theorem native_chain_after_impl_header : functionHeader "chain_after" "is" SourceShape.bodyTokens = some chain_after_impl_header := by
  decide +kernel

private theorem native_condition_tail_spec_header : functionHeader "condition_tail" ";" SourceShape.bodyTokens = some condition_tail_spec_header := by
  change functionHeader "condition_tail" ";" SourceShape.bodyTokens =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Result : Condition_Result; Operator : Chain_Kind; Chained : Boolean; Incoming : Scalar_Flow; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values; Original_Start : Literal_Position) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Result.After <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Condition (Context, Result) and then Operator /= No_Chain and then Valid_Flow (Context, Incoming) and then Incoming.Count = Result.Count and then Original_Start <= Text'Last + 1, Post => Condition_Tail'Result.Count = Result.Count and then Valid_Condition (Context, Condition_Tail'Result) and then (Condition_Tail'Result.After = 0 or else Condition_Tail'Result.After in Result.After .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Result.After, Decreases => 6)")
  rw [NativeShapeExpectedTokens.condition_tail_spec_header]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "result", ":", "condition_result", ";", "operator", ":", "chain_kind", ";", "chained", ":", "boolean", ";", "incoming", ":", "scalar_flow", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ";", "original_start", ":", "literal_position", ")", "return", "condition_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "result", ".", "after", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_condition", "(", "context", ",", "result", ")", "and", "then", "operator", "/=", "no_chain", "and", "then", "valid_flow", "(", "context", ",", "incoming", ")", "and", "then", "incoming", ".", "count", "=", "result", ".", "count", "and", "then", "original_start", "<=", "text", "'", "last", "+", "1", ",", "post", "=>", "condition_tail", "'", "result", ".", "count", "=", "result", ".", "count", "and", "then", "valid_condition", "(", "context", ",", "condition_tail", "'", "result", ")", "and", "then", "(", "condition_tail", "'", "result", ".", "after", "=", "0", "or", "else", "condition_tail", "'", "result", ".", "after", "in", "result", ".", "after", "..", "text", "'", "last", "+", "1", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "result", ".", "after", ",", "decreases", "=>", "6", ")"]))

private theorem native_condition_tail_impl_header : functionHeader "condition_tail" "is" SourceShape.bodyTokens = some condition_tail_impl_header := by
  decide +kernel

private theorem native_condition_model_spec_header : functionHeader "condition_model" ";" SourceShape.bodyTokens = some condition_model_spec_header := by
  change functionHeader "condition_model" ";" SourceShape.bodyTokens =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => Condition_Model'Result.Count = Facts.Count and then Valid_Condition (Context, Condition_Model'Result) and then (Condition_Model'Result.After = 0 or else Condition_Model'Result.After in Position + 1 .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 5)")
  rw [NativeShapeExpectedTokens.condition_model_spec_header]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ")", "return", "condition_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", ",", "post", "=>", "condition_model", "'", "result", ".", "count", "=", "facts", ".", "count", "and", "then", "valid_condition", "(", "context", ",", "condition_model", "'", "result", ")", "and", "then", "(", "condition_model", "'", "result", ".", "after", "=", "0", "or", "else", "condition_model", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "5", ")"]))

private theorem native_condition_model_impl_header : functionHeader "condition_model" "is" SourceShape.bodyTokens = some condition_model_impl_header := by
  decide +kernel

private theorem native_comparison_result_declaration : Lexical.SourceBridge.recordDeclaration "comparison_result" SourceShape.bodyTokens = some comparison_result_declaration := by
  decide +kernel

private theorem native_length_result_declaration : Lexical.SourceBridge.recordDeclaration "length_result" SourceShape.bodyTokens = some length_result_declaration := by
  decide +kernel

private theorem native_boolean_array_after_body : Source.expressionBody "boolean_array_after" SourceShape.bodyTokens = some booleanArrayBody.render := by
  simp only [booleanArrayBody, Expr.render]
  decide +kernel

private theorem native_boolean_array_after_spec_header : functionHeader "boolean_array_after" ";" SourceShape.bodyTokens = some boolean_array_after_spec_header := by
  decide +kernel

private theorem native_boolean_array_after_impl_header : functionHeader "boolean_array_after" "is" SourceShape.bodyTokens = some boolean_array_after_impl_header := by
  decide +kernel

private theorem native_boolean_atom_after_body : Source.expressionBody "boolean_atom_after" SourceShape.bodyTokens = some (booleanAtomBody.render) := by
  simp only [booleanAtomBody, Expr.render]
  decide +kernel

private theorem native_boolean_atom_after_spec_header : functionHeader "boolean_atom_after" ";" SourceShape.bodyTokens = some boolean_atom_after_spec_header := by
  decide +kernel

private theorem native_boolean_atom_after_impl_header : functionHeader "boolean_atom_after" "is" SourceShape.bodyTokens = some boolean_atom_after_impl_header := by
  decide +kernel

private theorem native_boolean_factor_model_body : Source.expressionBody "boolean_factor_model" SourceShape.bodyTokens = some (booleanFactorBody.render) := by
  simp only [booleanFactorBody, Expr.render, Expr.declaredCondition]
  decide +kernel

private theorem native_boolean_factor_model_spec_header : functionHeader "boolean_factor_model" ";" SourceShape.bodyTokens = some boolean_factor_model_spec_header := by
  change functionHeader "boolean_factor_model" ";" SourceShape.bodyTokens =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => Boolean_Factor_Model'Result.Count = Facts.Count and then Valid_Condition (Context, Boolean_Factor_Model'Result) and then (Boolean_Factor_Model'Result.After = 0 or else Boolean_Factor_Model'Result.After in Position + 1 .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 2)")
  rw [NativeShapeExpectedTokens.boolean_factor_model_spec_header]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ")", "return", "condition_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", ",", "post", "=>", "boolean_factor_model", "'", "result", ".", "count", "=", "facts", ".", "count", "and", "then", "valid_condition", "(", "context", ",", "boolean_factor_model", "'", "result", ")", "and", "then", "(", "boolean_factor_model", "'", "result", ".", "after", "=", "0", "or", "else", "boolean_factor_model", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "2", ")"]))

private theorem native_boolean_factor_model_impl_header : functionHeader "boolean_factor_model" "is" SourceShape.bodyTokens = some boolean_factor_model_impl_header := by
  decide +kernel

private theorem native_boolean_relation_model_body : Source.expressionBody "boolean_relation_model" SourceShape.bodyTokens = some (booleanRelationBody.render) := by
  simp only [booleanRelationBody, Expr.render, Expr.declaredCondition]
  decide +kernel

private theorem native_boolean_relation_model_spec_header : functionHeader "boolean_relation_model" ";" SourceShape.bodyTokens = some boolean_relation_model_spec_header := by
  change functionHeader "boolean_relation_model" ";" SourceShape.bodyTokens =
    some (Silver.SourceBridge.expectedTokens "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Position <= Text'Last + 1 and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts), Post => Boolean_Relation_Model'Result.Count = Facts.Count and then Valid_Condition (Context, Boolean_Relation_Model'Result) and then (Boolean_Relation_Model'Result.After = 0 or else Boolean_Relation_Model'Result.After in Position + 1 .. Text'Last + 1), Subprogram_Variant => (Decreases => (Text'Last + 1) - Position, Decreases => 3)")
  rw [NativeShapeExpectedTokens.boolean_relation_model_spec_header]
  kernel_exact (Eq.refl (some ["(", "text", ":", "string", ";", "context", ":", "body_context", ";", "position", ":", "literal_position", ";", "facts", ":", "scalar_flow", ";", "initials", ":", "array_bindings", ".", "element_array", ":=", "array_bindings", ".", "empty_values", ")", "return", "condition_result", "with", "ghost", "=>", "static", ",", "global", "=>", "null", ",", "pre", "=>", "text", "'", "first", "=", "1", "and", "then", "text", "'", "length", "in", "1", "..", "max_source_length", "and", "then", "position", "<=", "text", "'", "last", "+", "1", "and", "then", "valid_context", "(", "text", ",", "context", ")", "and", "then", "valid_flow", "(", "context", ",", "facts", ")", ",", "post", "=>", "boolean_relation_model", "'", "result", ".", "count", "=", "facts", ".", "count", "and", "then", "valid_condition", "(", "context", ",", "boolean_relation_model", "'", "result", ")", "and", "then", "(", "boolean_relation_model", "'", "result", ".", "after", "=", "0", "or", "else", "boolean_relation_model", "'", "result", ".", "after", "in", "position", "+", "1", "..", "text", "'", "last", "+", "1", ")", ",", "subprogram_variant", "=>", "(", "decreases", "=>", "(", "text", "'", "last", "+", "1", ")", "-", "position", ",", "decreases", "=>", "3", ")"]))

private theorem native_boolean_relation_model_impl_header : functionHeader "boolean_relation_model" "is" SourceShape.bodyTokens = some boolean_relation_model_impl_header := by
  decide +kernel

private theorem native_chain_kind_declaration : typeDeclaration "chain_kind" SourceShape.bodyTokens = some chain_kind_declaration := by
  decide +kernel

/-- Assemble the independently checked private source proofs. -/
theorem checked : Checked where
  validityCallWord := native_validityCallWord
  same_interval_header := native_same_interval_header
  same_interval_body := native_same_interval_body
  same_path_header := native_same_path_header
  same_path_body := native_same_path_body
  same_values_header := native_same_values_header
  same_values_body := native_same_values_body
  same_flow_header := native_same_flow_header
  same_flow_body := native_same_flow_body
  same_condition_header := native_same_condition_header
  same_condition_body := native_same_condition_body
  lemma_condition_equality_impl := native_lemma_condition_equality_impl
  lemma_flow_equality_impl := native_lemma_flow_equality_impl
  valid_condition_header := native_valid_condition_header
  valid_condition_body := native_valid_condition_body
  summary_of_body := native_summary_of_body
  bound_of_body := native_bound_of_body
  binding_summary_body := native_binding_summary_body
  scalar_comparison_at_body := native_scalar_comparison_at_body
  character_condition_body := native_character_condition_body
  character_condition_spec_header := native_character_condition_spec_header
  character_condition_impl_header := native_character_condition_impl_header
  length_at_body := native_length_at_body
  primary_model_body := native_primary_model_body
  relation_model_body := native_relation_model_body
  chain_token_body := native_chain_token_body
  chain_after_body := native_chain_after_body
  condition_tail_body := native_condition_tail_body
  condition_model_body := native_condition_model_body
  summary_of_impl_header := native_summary_of_impl_header
  bound_of_impl_header := native_bound_of_impl_header
  binding_summary_impl_header := native_binding_summary_impl_header
  scalar_comparison_at_spec_header := native_scalar_comparison_at_spec_header
  scalar_comparison_at_impl_header := native_scalar_comparison_at_impl_header
  length_at_spec_header := native_length_at_spec_header
  length_at_impl_header := native_length_at_impl_header
  primary_model_spec_header := native_primary_model_spec_header
  primary_model_impl_header := native_primary_model_impl_header
  relation_model_spec_header := native_relation_model_spec_header
  relation_model_impl_header := native_relation_model_impl_header
  chain_token_spec_header := native_chain_token_spec_header
  chain_token_impl_header := native_chain_token_impl_header
  chain_after_spec_header := native_chain_after_spec_header
  chain_after_impl_header := native_chain_after_impl_header
  condition_tail_spec_header := native_condition_tail_spec_header
  condition_tail_impl_header := native_condition_tail_impl_header
  condition_model_spec_header := native_condition_model_spec_header
  condition_model_impl_header := native_condition_model_impl_header
  comparison_result_declaration := native_comparison_result_declaration
  length_result_declaration := native_length_result_declaration
  boolean_array_after_body := native_boolean_array_after_body
  boolean_array_after_spec_header := native_boolean_array_after_spec_header
  boolean_array_after_impl_header := native_boolean_array_after_impl_header
  boolean_atom_after_body := native_boolean_atom_after_body
  boolean_atom_after_spec_header := native_boolean_atom_after_spec_header
  boolean_atom_after_impl_header := native_boolean_atom_after_impl_header
  boolean_factor_model_body := native_boolean_factor_model_body
  boolean_factor_model_spec_header := native_boolean_factor_model_spec_header
  boolean_factor_model_impl_header := native_boolean_factor_model_impl_header
  boolean_relation_model_body := native_boolean_relation_model_body
  boolean_relation_model_spec_header := native_boolean_relation_model_spec_header
  boolean_relation_model_impl_header := native_boolean_relation_model_impl_header
  chain_kind_declaration := native_chain_kind_declaration

end Silver.Predicate.SourceChecks.NativeShapeCandidate

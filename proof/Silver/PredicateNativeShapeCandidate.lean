module

public import Silver.PredicateNativeSourceChecks
public import Silver.PredicateCharacterSourceCandidate
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

/-- Each original source decision is checked here once. -/
theorem checked : Checked where
  validityCallWord := by decide +kernel
  same_interval_header := by
    decide +kernel
  same_interval_body := by
    decide +kernel
  same_path_header := by
    decide +kernel
  same_path_body := by
    decide +kernel
  same_values_header := by
    decide +kernel
  same_values_body := by
    decide +kernel
  same_flow_header := by
    decide +kernel
  same_flow_body := by
    decide +kernel
  same_condition_header := by
    decide +kernel
  same_condition_body := by
    decide +kernel
  lemma_condition_equality_impl := by
    decide +kernel
  lemma_flow_equality_impl := by
    decide +kernel
  valid_condition_header := by
    decide +kernel
  valid_condition_body := by
    decide +kernel
  summary_of_body := by
    simp only [summaryBody, Expr.render]
    decide +kernel
  bound_of_body := by
    simp only [boundBody, Expr.render]
    decide +kernel
  binding_summary_body := by
    simp only [bindingSummaryBody, Expr.render]
    decide +kernel
  scalar_comparison_at_body := by
    simp only [comparisonBody, Expr.render]
    decide +kernel
  character_condition_body := CharacterSourceCandidate.character_body
  character_condition_spec_header := CharacterSourceCandidate.character_spec
  character_condition_impl_header := CharacterSourceCandidate.character_impl
  length_at_body := CharacterSourceCandidate.length_body
  primary_model_body := by
    simp only [primaryBody, Expr.render, Expr.declared]
    decide +kernel
  relation_model_body := CharacterSourceCandidate.relation_body
  chain_token_body := by
    simp only [chainTokenBody, Expr.render]
    decide +kernel
  chain_after_body := by
    simp only [chainAfterBody]
    decide +kernel
  condition_tail_body := by
    simp only [tailBody, Expr.render, Expr.declared]
    decide +kernel
  condition_model_body := by
    simp only [modelBody, Expr.render]
    decide +kernel
  summary_of_impl_header := by
    decide +kernel
  bound_of_impl_header := by
    decide +kernel
  binding_summary_impl_header := by
    decide +kernel
  scalar_comparison_at_spec_header := by
    decide +kernel
  scalar_comparison_at_impl_header := by
    decide +kernel
  length_at_spec_header := by
    decide +kernel
  length_at_impl_header := by
    decide +kernel
  primary_model_spec_header := by
    decide +kernel
  primary_model_impl_header := by
    decide +kernel
  relation_model_spec_header := by
    decide +kernel
  relation_model_impl_header := by
    decide +kernel
  chain_token_spec_header := by
    decide +kernel
  chain_token_impl_header := by
    decide +kernel
  chain_after_spec_header := by
    decide +kernel
  chain_after_impl_header := by
    decide +kernel
  condition_tail_spec_header := by
    decide +kernel
  condition_tail_impl_header := by
    decide +kernel
  condition_model_spec_header := by
    decide +kernel
  condition_model_impl_header := by
    decide +kernel
  comparison_result_declaration := by
    decide +kernel
  length_result_declaration := by
    decide +kernel
  boolean_atom_after_body := by
    simp only [booleanAtomBody, Expr.render]
    decide +kernel
  boolean_atom_after_spec_header := by
    decide +kernel
  boolean_atom_after_impl_header := by
    decide +kernel
  boolean_factor_model_body := by
    simp only [booleanFactorBody, Expr.render, Expr.declaredCondition]
    decide +kernel
  boolean_factor_model_spec_header := by
    decide +kernel
  boolean_factor_model_impl_header := by
    decide +kernel
  boolean_relation_model_body := by
    simp only [booleanRelationBody, Expr.render, Expr.declaredCondition]
    decide +kernel
  boolean_relation_model_spec_header := by
    decide +kernel
  boolean_relation_model_impl_header := by
    decide +kernel
  chain_kind_declaration := by
    decide +kernel

end Silver.Predicate.SourceChecks.NativeShapeCandidate

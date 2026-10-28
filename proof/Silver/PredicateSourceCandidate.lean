module

public import Silver.PredicateSourceRequirements
import Silver.PredicateScalarBodyCandidate
import all Init.Data.Repr

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.Predicate.SourceChecks
open Silver.SourceBridge Native NativeSourceChecks

/-! The complete reviewed source shape supplies every syntactic requirement.
The final bridge proves equality with freshly certified authoritative tokens. -/

private theorem native_flow_checked : FlowSourceBridge.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

private theorem native_readers_checked : FlowReaders.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

private theorem native_scalarHelpers_checked : Native.ScalarHelpers.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

private theorem native_workers_checked : Native.Workers.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

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

private theorem native_length_at_body : Source.expressionBody "length_at" SourceShape.bodyTokens = some (lengthBody.render) := by
  simp only [lengthBody, Expr.render]
  decide +kernel

private theorem native_primary_model_body : Source.expressionBody "primary_model" SourceShape.bodyTokens = some (primaryBody.render) := by
  simp only [primaryBody, Expr.render, Expr.declared]
  decide +kernel

private theorem native_relation_model_body : Source.expressionBody "relation_model" SourceShape.bodyTokens = some (relationBody.render) := by
  simp only [relationBody, Expr.render, Expr.declared]
  decide +kernel

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
  decide +kernel

private theorem native_primary_model_impl_header : functionHeader "primary_model" "is" SourceShape.bodyTokens = some primary_model_impl_header := by
  decide +kernel

private theorem native_relation_model_spec_header : functionHeader "relation_model" ";" SourceShape.bodyTokens = some relation_model_spec_header := by
  decide +kernel

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
  decide +kernel

private theorem native_condition_tail_impl_header : functionHeader "condition_tail" "is" SourceShape.bodyTokens = some condition_tail_impl_header := by
  decide +kernel

private theorem native_condition_model_spec_header : functionHeader "condition_model" ";" SourceShape.bodyTokens = some condition_model_spec_header := by
  decide +kernel

private theorem native_condition_model_impl_header : functionHeader "condition_model" "is" SourceShape.bodyTokens = some condition_model_impl_header := by
  decide +kernel

private theorem native_comparison_result_declaration : Lexical.SourceBridge.recordDeclaration "comparison_result" SourceShape.bodyTokens = some comparison_result_declaration := by
  decide +kernel

private theorem native_length_result_declaration : Lexical.SourceBridge.recordDeclaration "length_result" SourceShape.bodyTokens = some length_result_declaration := by
  decide +kernel

private theorem native_checked : NativeSourceChecks.Checked SourceShape.bodyTokens where
  flow := native_flow_checked
  readers := native_readers_checked
  scalarHelpers := native_scalarHelpers_checked
  workers := native_workers_checked
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

private theorem candidate_bodyWrappers : BodyWrappers.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

private theorem candidate_adapterWrappers : Adapter.Wrappers.Checked SourceShape.bodyTokens := by
  constructor <;> decide +kernel

private theorem candidate_lemma_joined_flow_spec : procedureHeader "lemma_joined_flow" ";" SourceShape.bodyTokens = some lemma_joined_flow_spec := by
  decide +kernel

private theorem candidate_lemma_joined_flow_impl : procedureHeader "lemma_joined_flow" "is" SourceShape.bodyTokens = some lemma_joined_flow_header := by
  decide +kernel

private theorem candidate_basic_body_body : ordinaryFunction "basic_body" SourceShape.bodyTokens = some (BasicNative.basicRender) := by
  rw [BasicNative.rendered_candidate]
  decide +kernel

private theorem candidate_statement_body_body : Source.expressionBody "statement_body" SourceShape.bodyTokens = some (BodyNative.statementRender) := by
  rw [BodyNative.rendered_statement_body]
  decide +kernel

private theorem candidate_loop_body_body : ordinaryFunction "loop_body" SourceShape.bodyTokens = some LoopNative.render := by
  rw [LoopNative.rendered_candidate]
  decide +kernel

private theorem candidate_conditional_body_body : ordinaryFunction "conditional_body" SourceShape.bodyTokens = some (BodyNative.conditionalFunction.render "conditional_body") := by
  rw [BodyNative.rendered_conditional_body]
  decide +kernel

private theorem candidate_alternative_body_body : ordinaryFunction "alternative_body" SourceShape.bodyTokens = some (BodyNative.alternativeFunction.render "alternative_body") := by
  rw [BodyNative.rendered_alternative_body]
  decide +kernel

private theorem candidate_body_tail_model_body : Source.expressionBody "body_tail_model" SourceShape.bodyTokens = some BodyNative.tailModelBody.render := by
  rw [BodyNative.rendered_body_tail_model]
  decide +kernel

private theorem candidate_body_tail_model_spec : functionHeader "body_tail_model" ";" SourceShape.bodyTokens = some body_body_tail_model_spec_header := by
  decide +kernel

private theorem candidate_body_tail_model_impl : functionHeader "body_tail_model" "is" SourceShape.bodyTokens = some body_body_tail_impl_header := by
  decide +kernel

private theorem candidate_read_body_body : ordinaryFunction "read_body" SourceShape.bodyTokens = some (BodyNative.readFunction.render "read_body") := by
  rw [BodyNative.rendered_read_body]
  decide +kernel

private theorem candidate_context_of_body : Source.expressionBody "context_of" SourceShape.bodyTokens = some ((Adapter.contextExpr.render).drop 1).dropLast := by
  rw [Adapter.context_of_candidate]
  decide +kernel

private theorem candidate_expand_body_body : Source.expressionBody "expand_body" SourceShape.bodyTokens = some ((Adapter.expandExpr.render).drop 1).dropLast := by
  rw [Adapter.expand_body_candidate]
  decide +kernel

private theorem candidate_at_body_stop_body : Source.expressionBody "at_body_stop" SourceShape.bodyTokens = some ((Adapter.atStopExpr.render).drop 1).dropLast := by
  rw [Adapter.at_body_stop_candidate]
  decide +kernel

private theorem candidate_read_statements_body : ordinaryFunction "read_statements" SourceShape.bodyTokens = some (Adapter.adapterFunction.render) := by
  rw [Adapter.read_statements_candidate]
  decide +kernel

private theorem candidate_tokens_body : Source.expressionBody "tokens" SourceShape.bodyTokens = some (Outer.tokensBody) := by
  rw [Outer.rendered_tokens]
  decide +kernel

private theorem candidate_scan_step_body : Source.expressionBody "scan_step" SourceShape.bodyTokens = some (Outer.scanStepBody.render) := by
  rw [Outer.rendered_scan_step]
  decide +kernel

private theorem candidate_scan_suffix_body : Source.expressionBody "scan_suffix" SourceShape.bodyTokens = some (Outer.suffixBody.render) := by
  rw [Outer.rendered_scan_suffix]
  decide +kernel

private theorem candidate_form_result_body : Source.expressionBody "form_result" SourceShape.bodyTokens = some (Outer.formBody.render) := by
  rw [Outer.rendered_form_result]
  decide +kernel

private theorem candidate_is_member_body : Source.expressionBody "is_member" SourceShape.bodyTokens = some (Outer.memberBody.render) := by
  rw [Outer.rendered_is_member]
  decide +kernel

private theorem candidate_has_arguments_body : Source.expressionBody "has_arguments" SourceShape.bodyTokens = some (Outer.argumentsBody.render) := by
  rw [Outer.rendered_has_arguments]
  decide +kernel

private theorem candidate_has_assignment_body : Source.expressionBody "has_assignment" SourceShape.bodyTokens = some (Outer.assignmentBody.render) := by
  rw [Outer.rendered_has_assignment]
  decide +kernel

private theorem candidate_has_output_body : Source.expressionBody "has_output" SourceShape.bodyTokens = some (Outer.outputBody.render) := by
  rw [Outer.rendered_has_output]
  decide +kernel

private theorem candidate_spec_tokens_spec_header : functionHeader "tokens" ";" SourceShape.specTokens = some spec_tokens_spec_header := by
  decide +kernel

private theorem candidate_spec_is_member_spec_header : functionHeader "is_member" ";" SourceShape.specTokens = some spec_is_member_spec_header := by
  decide +kernel

private theorem candidate_spec_has_arguments_spec_header : functionHeader "has_arguments" ";" SourceShape.specTokens = some spec_has_arguments_spec_header := by
  decide +kernel

private theorem candidate_spec_has_assignment_spec_header : functionHeader "has_assignment" ";" SourceShape.specTokens = some spec_has_assignment_spec_header := by
  decide +kernel

private theorem candidate_spec_has_output_spec_header : functionHeader "has_output" ";" SourceShape.specTokens = some spec_has_output_spec_header := by
  decide +kernel

private theorem candidate_spec_accepts_spec_header : functionHeader "accepts" ";" SourceShape.specTokens = some spec_accepts_spec_header := by
  decide +kernel

private theorem candidate_spec_uses_arguments_spec_header : functionHeader "uses_arguments" ";" SourceShape.specTokens = some spec_uses_arguments_spec_header := by
  decide +kernel

private theorem candidate_spec_uses_assignment_spec_header : functionHeader "uses_assignment" ";" SourceShape.specTokens = some spec_uses_assignment_spec_header := by
  decide +kernel

private theorem candidate_spec_uses_output_spec_header : functionHeader "uses_output" ";" SourceShape.specTokens = some spec_uses_output_spec_header := by
  decide +kernel

private theorem candidate_spec_spelling_spec_header : functionHeader "spelling" ";" SourceShape.specTokens = some spec_spelling_spec_header := by
  decide +kernel

private theorem candidate_spec_is_word_token_spec_header : functionHeader "is_word_token" ";" SourceShape.specTokens = some spec_is_word_token_spec_header := by
  decide +kernel

private theorem candidate_spec_is_argument_form_impl_header : functionHeader "is_argument_form" "is" SourceShape.specTokens = some spec_is_argument_form_impl_header := by
  decide +kernel

private theorem candidate_body_basic_body_spec_header : functionHeader "basic_body" ";" SourceShape.bodyTokens = some body_basic_body_spec_header := by
  decide +kernel

private theorem candidate_body_basic_body_impl_header : functionHeader "basic_body" "is" SourceShape.bodyTokens = some body_basic_body_impl_header := by
  decide +kernel

private theorem candidate_body_statement_body_spec_header : functionHeader "statement_body" ";" SourceShape.bodyTokens = some body_statement_body_spec_header := by
  decide +kernel

private theorem candidate_body_statement_body_impl_header : functionHeader "statement_body" "is" SourceShape.bodyTokens = some body_statement_body_impl_header := by
  decide +kernel

private theorem candidate_body_loop_body_spec_header : functionHeader "loop_body" ";" SourceShape.bodyTokens = some body_loop_body_spec_header := by
  decide +kernel

private theorem candidate_body_loop_body_impl_header : functionHeader "loop_body" "is" SourceShape.bodyTokens = some body_loop_body_impl_header := by
  decide +kernel

private theorem candidate_body_conditional_body_spec_header : functionHeader "conditional_body" ";" SourceShape.bodyTokens = some body_conditional_body_spec_header := by
  decide +kernel

private theorem candidate_body_conditional_body_impl_header : functionHeader "conditional_body" "is" SourceShape.bodyTokens = some body_conditional_body_impl_header := by
  decide +kernel

private theorem candidate_body_alternative_body_spec_header : functionHeader "alternative_body" ";" SourceShape.bodyTokens = some body_alternative_body_spec_header := by
  decide +kernel

private theorem candidate_body_alternative_body_impl_header : functionHeader "alternative_body" "is" SourceShape.bodyTokens = some body_alternative_body_impl_header := by
  decide +kernel

private theorem candidate_body_body_tail_spec_header : functionHeader "body_tail" ";" SourceShape.bodyTokens = some body_body_tail_spec_header := by
  decide +kernel

private theorem candidate_body_body_tail_impl_header : functionHeader "body_tail" "is" SourceShape.bodyTokens = some body_body_tail_impl_header := by
  decide +kernel

private theorem candidate_body_read_body_spec_header : functionHeader "read_body" ";" SourceShape.bodyTokens = some body_read_body_spec_header := by
  unfold body_read_body_spec_header
  simp only [BodyNative.readContractBody, BodyNative.ModelExpr.render.eq_def,
    BodyNative.ModelExpr.renderElse.eq_def, BodyNative.ScanExpr.render,
    BodyNative.Test.render, BodyNative.StopRef.render]
  decide +kernel

private theorem candidate_body_read_body_impl_header : functionHeader "read_body" "is" SourceShape.bodyTokens = some body_read_body_impl_header := by
  decide +kernel

private theorem candidate_body_context_of_impl_header : functionHeader "context_of" "is" SourceShape.bodyTokens = some body_context_of_impl_header := by
  decide +kernel

private theorem candidate_body_body_of_impl_header : functionHeader "body_of" "is" SourceShape.bodyTokens = some body_body_of_impl_header := by
  decide +kernel

private theorem candidate_body_expand_body_impl_header : functionHeader "expand_body" "is" SourceShape.bodyTokens = some body_expand_body_impl_header := by
  decide +kernel

private theorem candidate_body_body_token_spec_header : functionHeader "body_token" ";" SourceShape.bodyTokens = some body_body_token_spec_header := by
  decide +kernel

private theorem candidate_body_body_token_impl_header : functionHeader "body_token" "is" SourceShape.bodyTokens = some body_body_token_impl_header := by
  decide +kernel

private theorem candidate_body_at_body_stop_spec_header : functionHeader "at_body_stop" ";" SourceShape.bodyTokens = some body_at_body_stop_spec_header := by
  decide +kernel

private theorem candidate_body_at_body_stop_impl_header : functionHeader "at_body_stop" "is" SourceShape.bodyTokens = some body_at_body_stop_impl_header := by
  decide +kernel

private theorem candidate_body_read_statements_spec_header : functionHeader "read_statements" ";" SourceShape.bodyTokens = some body_read_statements_spec_header := by
  decide +kernel

private theorem candidate_body_read_statements_impl_header : functionHeader "read_statements" "is" SourceShape.bodyTokens = some body_read_statements_impl_header := by
  decide +kernel

private theorem candidate_body_tokens_impl_header : functionHeader "tokens" "is" SourceShape.bodyTokens = some body_tokens_impl_header := by
  decide +kernel

private theorem candidate_body_scan_step_spec_header : functionHeader "scan_step" ";" SourceShape.bodyTokens = some body_scan_step_spec_header := by
  decide +kernel

private theorem candidate_body_scan_step_impl_header : functionHeader "scan_step" "is" SourceShape.bodyTokens = some body_scan_step_impl_header := by
  decide +kernel

private theorem candidate_body_scan_suffix_spec_header : functionHeader "scan_suffix" ";" SourceShape.bodyTokens = some body_scan_suffix_spec_header := by
  decide +kernel

private theorem candidate_body_scan_suffix_impl_header : functionHeader "scan_suffix" "is" SourceShape.bodyTokens = some body_scan_suffix_impl_header := by
  decide +kernel

private theorem candidate_body_form_result_spec_header : functionHeader "form_result" ";" SourceShape.bodyTokens = some body_form_result_spec_header := by
  decide +kernel

private theorem candidate_body_form_result_impl_header : functionHeader "form_result" "is" SourceShape.bodyTokens = some body_form_result_impl_header := by
  decide +kernel

private theorem candidate_body_is_member_impl_header : functionHeader "is_member" "is" SourceShape.bodyTokens = some body_is_member_impl_header := by
  decide +kernel

private theorem candidate_body_has_arguments_impl_header : functionHeader "has_arguments" "is" SourceShape.bodyTokens = some body_has_arguments_impl_header := by
  decide +kernel

private theorem candidate_body_has_assignment_impl_header : functionHeader "has_assignment" "is" SourceShape.bodyTokens = some body_has_assignment_impl_header := by
  decide +kernel

private theorem candidate_body_has_output_impl_header : functionHeader "has_output" "is" SourceShape.bodyTokens = some body_has_output_impl_header := by
  decide +kernel

private theorem candidate_body_read_form_spec_header : functionHeader "read_form" ";" SourceShape.bodyTokens = some body_read_form_spec_header := by
  decide +kernel

private theorem candidate_body_read_form_impl_header : functionHeader "read_form" "is" SourceShape.bodyTokens = some body_read_form_impl_header := by
  decide +kernel

private theorem candidate_body_valid_context_spec_header : functionHeader "valid_context" ";" SourceShape.bodyTokens = some body_valid_context_spec_header := by
  decide +kernel

private theorem candidate_body_valid_context_impl_header : functionHeader "valid_context" "is" SourceShape.bodyTokens = some body_valid_context_impl_header := by
  decide +kernel

private theorem candidate_body_valid_body_spec_header : functionHeader "valid_body" ";" SourceShape.bodyTokens = some body_valid_body_spec_header := by
  decide +kernel

private theorem candidate_body_valid_body_impl_header : functionHeader "valid_body" "is" SourceShape.bodyTokens = some body_valid_body_impl_header := by
  decide +kernel

private theorem candidate_body_accepts_impl_header : functionHeader "accepts" "is" SourceShape.bodyTokens = some body_accepts_impl_header := by
  decide +kernel

private theorem candidate_body_uses_arguments_impl_header : functionHeader "uses_arguments" "is" SourceShape.bodyTokens = some body_uses_arguments_impl_header := by
  decide +kernel

private theorem candidate_body_uses_assignment_impl_header : functionHeader "uses_assignment" "is" SourceShape.bodyTokens = some body_uses_assignment_impl_header := by
  decide +kernel

private theorem candidate_body_uses_output_impl_header : functionHeader "uses_output" "is" SourceShape.bodyTokens = some body_uses_output_impl_header := by
  decide +kernel

private theorem candidate_body_spelling_impl_header : functionHeader "spelling" "is" SourceShape.bodyTokens = some body_spelling_impl_header := by
  decide +kernel

private theorem candidate_body_is_word_token_impl_header : functionHeader "is_word_token" "is" SourceShape.bodyTokens = some body_is_word_token_impl_header := by
  decide +kernel

private theorem candidate_scan_result_declaration : Lexical.SourceBridge.recordDeclaration "scan_result" SourceShape.bodyTokens = some scan_result_declaration := by
  decide +kernel

private theorem candidate_body_context_declaration : Lexical.SourceBridge.recordDeclaration "body_context" SourceShape.bodyTokens = some body_context_declaration := by
  decide +kernel

private theorem candidate_body_scan_declaration : Lexical.SourceBridge.discriminatedRecordDeclaration "body_scan" SourceShape.bodyTokens = some body_scan_declaration := by
  decide +kernel

private theorem candidate_body_stop_declaration : typeDeclaration "body_stop" SourceShape.bodyTokens = some body_stop_declaration := by
  decide +kernel

private theorem candidate_form_kind_declaration : typeDeclaration "form_kind" SourceShape.specTokens = some form_kind_declaration := by
  decide +kernel

private theorem candidate_token_kind_declaration : typeDeclaration "token_kind" SourceShape.specTokens = some token_kind_declaration := by
  decide +kernel

private theorem candidate_token_sequence_declaration : typeDeclaration "token_sequence" SourceShape.specTokens = some token_sequence_declaration := by
  decide +kernel

private theorem candidate_initial_scan_declaration : Source.declaration "initial_scan" SourceShape.bodyTokens = some initial_scan_declaration := by
  decide +kernel

private theorem candidate_invalid_scan_declaration : Source.declaration "invalid_scan" SourceShape.bodyTokens = some invalid_scan_declaration := by
  decide +kernel

private theorem candidate_max_source_length_declaration : Source.declaration "max_source_length" SourceShape.specTokens = some max_source_length_declaration := by
  decide +kernel

private theorem candidate_max_expression_operands_declaration : Source.declaration "max_expression_operands" SourceShape.specTokens = some max_expression_operands_declaration := by
  decide +kernel

private theorem candidate_max_concatenations_declaration : Source.declaration "max_concatenations" SourceShape.specTokens = some max_concatenations_declaration := by
  decide +kernel

private theorem candidate_max_bindings_declaration : Source.declaration "max_bindings" SourceShape.specTokens = some max_bindings_declaration := by
  decide +kernel

private theorem candidate_token_index_declaration : Lexical.SourceBridge.subtypeDeclaration "token_index" SourceShape.bodyTokens = some token_index_declaration := by
  decide +kernel

private theorem candidate_binding_count_declaration : Lexical.SourceBridge.subtypeDeclaration "binding_count" SourceShape.bodyTokens = some binding_count_declaration := by
  decide +kernel

private theorem candidate_binding_index_declaration : Lexical.SourceBridge.subtypeDeclaration "binding_index" SourceShape.bodyTokens = some binding_index_declaration := by
  decide +kernel

private theorem candidate_operand_count_declaration : Lexical.SourceBridge.subtypeDeclaration "operand_count" SourceShape.bodyTokens = some operand_count_declaration := by
  decide +kernel

private theorem candidate_concatenation_count_declaration : Lexical.SourceBridge.subtypeDeclaration "concatenation_count" SourceShape.bodyTokens = some concatenation_count_declaration := by
  decide +kernel

private theorem candidate_valid_flow_body : Source.expressionBody "valid_flow" SourceShape.bodyTokens = some valid_flow_expression := by
  decide +kernel

private theorem candidate_valid_flow_header : functionHeader "valid_flow" "is" SourceShape.bodyTokens = some ((Source.lexLine "(Context : Body_Context; Facts : Scalar_Flow) return Boolean").getD []) := by
  decide +kernel

private theorem candidate_included_body : Source.expressionBody "included" SourceShape.bodyTokens = some included_expression := by
  decide +kernel

private theorem candidate_included_header : functionHeader "included" "is" SourceShape.bodyTokens = some ((Source.lexLine "(Value, Bounds : Scalars.Interval) return Boolean").getD []) := by
  decide +kernel

private theorem candidate_string_target_declaration : Lexical.SourceBridge.recordDeclaration "string_target_result" SourceShape.bodyTokens = some string_target_declaration := by
  decide +kernel

private theorem candidate_valid_context_body : Source.expressionBody "valid_context" SourceShape.bodyTokens = some valid_context_expression := by
  decide +kernel

private theorem candidate_valid_body_body : Source.expressionBody "valid_body" SourceShape.bodyTokens = some valid_body_expression := by
  decide +kernel

theorem candidate_checked : Checked SourceShape.specTokens SourceShape.bodyTokens where
  spec_shape := rfl
  body_shape := rfl
  native := native_checked
  scalarBodies := ScalarBodyNative.SourceChecks.candidate_checked
  array_helpers := ArrayBodyNative.SourceChecks.candidate_checked
  bodyWrappers := candidate_bodyWrappers
  adapterWrappers := candidate_adapterWrappers
  lemma_joined_flow_spec := candidate_lemma_joined_flow_spec
  lemma_joined_flow_impl := candidate_lemma_joined_flow_impl
  basic_body_body := candidate_basic_body_body
  statement_body_body := candidate_statement_body_body
  loop_body_body := candidate_loop_body_body
  conditional_body_body := candidate_conditional_body_body
  alternative_body_body := candidate_alternative_body_body
  body_tail_model_body := candidate_body_tail_model_body
  body_tail_model_spec := candidate_body_tail_model_spec
  body_tail_model_impl := candidate_body_tail_model_impl
  read_body_body := candidate_read_body_body
  context_of_body := candidate_context_of_body
  expand_body_body := candidate_expand_body_body
  at_body_stop_body := candidate_at_body_stop_body
  read_statements_body := candidate_read_statements_body
  tokens_body := candidate_tokens_body
  scan_step_body := candidate_scan_step_body
  scan_suffix_body := candidate_scan_suffix_body
  form_result_body := candidate_form_result_body
  is_member_body := candidate_is_member_body
  has_arguments_body := candidate_has_arguments_body
  has_assignment_body := candidate_has_assignment_body
  has_output_body := candidate_has_output_body
  spec_tokens_spec_header := candidate_spec_tokens_spec_header
  spec_is_member_spec_header := candidate_spec_is_member_spec_header
  spec_has_arguments_spec_header := candidate_spec_has_arguments_spec_header
  spec_has_assignment_spec_header := candidate_spec_has_assignment_spec_header
  spec_has_output_spec_header := candidate_spec_has_output_spec_header
  spec_accepts_spec_header := candidate_spec_accepts_spec_header
  spec_uses_arguments_spec_header := candidate_spec_uses_arguments_spec_header
  spec_uses_assignment_spec_header := candidate_spec_uses_assignment_spec_header
  spec_uses_output_spec_header := candidate_spec_uses_output_spec_header
  spec_spelling_spec_header := candidate_spec_spelling_spec_header
  spec_is_word_token_spec_header := candidate_spec_is_word_token_spec_header
  spec_is_argument_form_impl_header := candidate_spec_is_argument_form_impl_header
  body_basic_body_spec_header := candidate_body_basic_body_spec_header
  body_basic_body_impl_header := candidate_body_basic_body_impl_header
  body_statement_body_spec_header := candidate_body_statement_body_spec_header
  body_statement_body_impl_header := candidate_body_statement_body_impl_header
  body_loop_body_spec_header := candidate_body_loop_body_spec_header
  body_loop_body_impl_header := candidate_body_loop_body_impl_header
  body_conditional_body_spec_header := candidate_body_conditional_body_spec_header
  body_conditional_body_impl_header := candidate_body_conditional_body_impl_header
  body_alternative_body_spec_header := candidate_body_alternative_body_spec_header
  body_alternative_body_impl_header := candidate_body_alternative_body_impl_header
  body_body_tail_spec_header := candidate_body_body_tail_spec_header
  body_body_tail_impl_header := candidate_body_body_tail_impl_header
  body_read_body_spec_header := candidate_body_read_body_spec_header
  body_read_body_impl_header := candidate_body_read_body_impl_header
  body_context_of_impl_header := candidate_body_context_of_impl_header
  body_body_of_impl_header := candidate_body_body_of_impl_header
  body_expand_body_impl_header := candidate_body_expand_body_impl_header
  body_body_token_spec_header := candidate_body_body_token_spec_header
  body_body_token_impl_header := candidate_body_body_token_impl_header
  body_at_body_stop_spec_header := candidate_body_at_body_stop_spec_header
  body_at_body_stop_impl_header := candidate_body_at_body_stop_impl_header
  body_read_statements_spec_header := candidate_body_read_statements_spec_header
  body_read_statements_impl_header := candidate_body_read_statements_impl_header
  body_tokens_impl_header := candidate_body_tokens_impl_header
  body_scan_step_spec_header := candidate_body_scan_step_spec_header
  body_scan_step_impl_header := candidate_body_scan_step_impl_header
  body_scan_suffix_spec_header := candidate_body_scan_suffix_spec_header
  body_scan_suffix_impl_header := candidate_body_scan_suffix_impl_header
  body_form_result_spec_header := candidate_body_form_result_spec_header
  body_form_result_impl_header := candidate_body_form_result_impl_header
  body_is_member_impl_header := candidate_body_is_member_impl_header
  body_has_arguments_impl_header := candidate_body_has_arguments_impl_header
  body_has_assignment_impl_header := candidate_body_has_assignment_impl_header
  body_has_output_impl_header := candidate_body_has_output_impl_header
  body_read_form_spec_header := candidate_body_read_form_spec_header
  body_read_form_impl_header := candidate_body_read_form_impl_header
  body_valid_context_spec_header := candidate_body_valid_context_spec_header
  body_valid_context_impl_header := candidate_body_valid_context_impl_header
  body_valid_body_spec_header := candidate_body_valid_body_spec_header
  body_valid_body_impl_header := candidate_body_valid_body_impl_header
  body_accepts_impl_header := candidate_body_accepts_impl_header
  body_uses_arguments_impl_header := candidate_body_uses_arguments_impl_header
  body_uses_assignment_impl_header := candidate_body_uses_assignment_impl_header
  body_uses_output_impl_header := candidate_body_uses_output_impl_header
  body_spelling_impl_header := candidate_body_spelling_impl_header
  body_is_word_token_impl_header := candidate_body_is_word_token_impl_header
  scan_result_declaration := candidate_scan_result_declaration
  body_context_declaration := candidate_body_context_declaration
  body_scan_declaration := candidate_body_scan_declaration
  body_stop_declaration := candidate_body_stop_declaration
  form_kind_declaration := candidate_form_kind_declaration
  token_kind_declaration := candidate_token_kind_declaration
  token_sequence_declaration := candidate_token_sequence_declaration
  initial_scan_declaration := candidate_initial_scan_declaration
  invalid_scan_declaration := candidate_invalid_scan_declaration
  max_source_length_declaration := candidate_max_source_length_declaration
  max_expression_operands_declaration := candidate_max_expression_operands_declaration
  max_concatenations_declaration := candidate_max_concatenations_declaration
  max_bindings_declaration := candidate_max_bindings_declaration
  token_index_declaration := candidate_token_index_declaration
  binding_count_declaration := candidate_binding_count_declaration
  binding_index_declaration := candidate_binding_index_declaration
  operand_count_declaration := candidate_operand_count_declaration
  concatenation_count_declaration := candidate_concatenation_count_declaration
  valid_flow_body := candidate_valid_flow_body
  valid_flow_header := candidate_valid_flow_header
  included_body := candidate_included_body
  included_header := candidate_included_header
  string_target_declaration := candidate_string_target_declaration
  valid_context_body := candidate_valid_context_body
  valid_body_body := candidate_valid_body_body

end Silver.Predicate.SourceChecks

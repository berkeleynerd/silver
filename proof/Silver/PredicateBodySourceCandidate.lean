module

public import Silver.PredicateSourceRequirements
import all Init.Data.Repr

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.Predicate.SourceChecks.BodySourceCandidate
open Silver.SourceBridge Native NativeSourceChecks

/-! Exact recursive-body, wrapper, header, declaration and validity source checks.
The final source bridge transports the reviewed shape to authoritative tokens. -/

/-- The source requirements assigned to this independent proof leaf. -/
structure Checked : Prop where
  bodyWrappers : BodyWrappers.Checked SourceShape.bodyTokens
  adapterWrappers : Adapter.Wrappers.Checked SourceShape.bodyTokens
  lemma_joined_flow_spec : procedureHeader "lemma_joined_flow" ";" SourceShape.bodyTokens = some lemma_joined_flow_spec
  lemma_joined_flow_impl : procedureHeader "lemma_joined_flow" "is" SourceShape.bodyTokens = some lemma_joined_flow_header
  basic_body_body : ordinaryFunction "basic_body" SourceShape.bodyTokens = some (BasicNative.basicRender)
  statement_body_body : Source.expressionBody "statement_body" SourceShape.bodyTokens = some (BodyNative.statementRender)
  loop_body_body : ordinaryFunction "loop_body" SourceShape.bodyTokens = some LoopNative.render
  conditional_body_body : ordinaryFunction "conditional_body" SourceShape.bodyTokens = some (BodyNative.conditionalFunction.render "conditional_body")
  alternative_body_body : ordinaryFunction "alternative_body" SourceShape.bodyTokens = some (BodyNative.alternativeFunction.render "alternative_body")
  body_tail_model_body : Source.expressionBody "body_tail_model" SourceShape.bodyTokens = some BodyNative.tailModelBody.render
  body_tail_model_spec : functionHeader "body_tail_model" ";" SourceShape.bodyTokens = some body_body_tail_model_spec_header
  body_tail_model_impl : functionHeader "body_tail_model" "is" SourceShape.bodyTokens = some body_body_tail_impl_header
  read_body_body : ordinaryFunction "read_body" SourceShape.bodyTokens = some (BodyNative.readFunction.render "read_body")
  context_of_body : Source.expressionBody "context_of" SourceShape.bodyTokens = some ((Adapter.contextExpr.render).drop 1).dropLast
  expand_body_body : Source.expressionBody "expand_body" SourceShape.bodyTokens = some ((Adapter.expandExpr.render).drop 1).dropLast
  at_body_stop_body : Source.expressionBody "at_body_stop" SourceShape.bodyTokens = some ((Adapter.atStopExpr.render).drop 1).dropLast
  read_statements_body : ordinaryFunction "read_statements" SourceShape.bodyTokens = some (Adapter.adapterFunction.render)
  tokens_body : Source.expressionBody "tokens" SourceShape.bodyTokens = some (Outer.tokensBody)
  scan_step_body : Source.expressionBody "scan_step" SourceShape.bodyTokens = some (Outer.scanStepBody.render)
  scan_suffix_body : Source.expressionBody "scan_suffix" SourceShape.bodyTokens = some (Outer.suffixBody.render)
  form_result_body : Source.expressionBody "form_result" SourceShape.bodyTokens = some (Outer.formBody.render)
  is_member_body : Source.expressionBody "is_member" SourceShape.bodyTokens = some (Outer.memberBody.render)
  has_arguments_body : Source.expressionBody "has_arguments" SourceShape.bodyTokens = some (Outer.argumentsBody.render)
  has_assignment_body : Source.expressionBody "has_assignment" SourceShape.bodyTokens = some (Outer.assignmentBody.render)
  has_output_body : Source.expressionBody "has_output" SourceShape.bodyTokens = some (Outer.outputBody.render)
  spec_tokens_spec_header : functionHeader "tokens" ";" SourceShape.specTokens = some spec_tokens_spec_header
  spec_is_member_spec_header : functionHeader "is_member" ";" SourceShape.specTokens = some spec_is_member_spec_header
  spec_has_arguments_spec_header : functionHeader "has_arguments" ";" SourceShape.specTokens = some spec_has_arguments_spec_header
  spec_has_assignment_spec_header : functionHeader "has_assignment" ";" SourceShape.specTokens = some spec_has_assignment_spec_header
  spec_has_output_spec_header : functionHeader "has_output" ";" SourceShape.specTokens = some spec_has_output_spec_header
  spec_accepts_spec_header : functionHeader "accepts" ";" SourceShape.specTokens = some spec_accepts_spec_header
  spec_uses_arguments_spec_header : functionHeader "uses_arguments" ";" SourceShape.specTokens = some spec_uses_arguments_spec_header
  spec_uses_assignment_spec_header : functionHeader "uses_assignment" ";" SourceShape.specTokens = some spec_uses_assignment_spec_header
  spec_uses_output_spec_header : functionHeader "uses_output" ";" SourceShape.specTokens = some spec_uses_output_spec_header
  spec_spelling_spec_header : functionHeader "spelling" ";" SourceShape.specTokens = some spec_spelling_spec_header
  spec_is_word_token_spec_header : functionHeader "is_word_token" ";" SourceShape.specTokens = some spec_is_word_token_spec_header
  spec_is_argument_form_impl_header : functionHeader "is_argument_form" "is" SourceShape.specTokens = some spec_is_argument_form_impl_header
  body_basic_body_spec_header : functionHeader "basic_body" ";" SourceShape.bodyTokens = some body_basic_body_spec_header
  body_basic_body_impl_header : functionHeader "basic_body" "is" SourceShape.bodyTokens = some body_basic_body_impl_header
  body_statement_body_spec_header : functionHeader "statement_body" ";" SourceShape.bodyTokens = some body_statement_body_spec_header
  body_statement_body_impl_header : functionHeader "statement_body" "is" SourceShape.bodyTokens = some body_statement_body_impl_header
  body_loop_body_spec_header : functionHeader "loop_body" ";" SourceShape.bodyTokens = some body_loop_body_spec_header
  body_loop_body_impl_header : functionHeader "loop_body" "is" SourceShape.bodyTokens = some body_loop_body_impl_header
  body_conditional_body_spec_header : functionHeader "conditional_body" ";" SourceShape.bodyTokens = some body_conditional_body_spec_header
  body_conditional_body_impl_header : functionHeader "conditional_body" "is" SourceShape.bodyTokens = some body_conditional_body_impl_header
  body_alternative_body_spec_header : functionHeader "alternative_body" ";" SourceShape.bodyTokens = some body_alternative_body_spec_header
  body_alternative_body_impl_header : functionHeader "alternative_body" "is" SourceShape.bodyTokens = some body_alternative_body_impl_header
  body_body_tail_spec_header : functionHeader "body_tail" ";" SourceShape.bodyTokens = some body_body_tail_spec_header
  body_body_tail_impl_header : functionHeader "body_tail" "is" SourceShape.bodyTokens = some body_body_tail_impl_header
  body_read_body_spec_header : functionHeader "read_body" ";" SourceShape.bodyTokens = some body_read_body_spec_header
  body_read_body_impl_header : functionHeader "read_body" "is" SourceShape.bodyTokens = some body_read_body_impl_header
  body_context_of_impl_header : functionHeader "context_of" "is" SourceShape.bodyTokens = some body_context_of_impl_header
  body_body_of_impl_header : functionHeader "body_of" "is" SourceShape.bodyTokens = some body_body_of_impl_header
  body_expand_body_impl_header : functionHeader "expand_body" "is" SourceShape.bodyTokens = some body_expand_body_impl_header
  body_body_token_spec_header : functionHeader "body_token" ";" SourceShape.bodyTokens = some body_body_token_spec_header
  body_body_token_impl_header : functionHeader "body_token" "is" SourceShape.bodyTokens = some body_body_token_impl_header
  body_at_body_stop_spec_header : functionHeader "at_body_stop" ";" SourceShape.bodyTokens = some body_at_body_stop_spec_header
  body_at_body_stop_impl_header : functionHeader "at_body_stop" "is" SourceShape.bodyTokens = some body_at_body_stop_impl_header
  body_read_statements_spec_header : functionHeader "read_statements" ";" SourceShape.bodyTokens = some body_read_statements_spec_header
  body_read_statements_impl_header : functionHeader "read_statements" "is" SourceShape.bodyTokens = some body_read_statements_impl_header
  body_tokens_impl_header : functionHeader "tokens" "is" SourceShape.bodyTokens = some body_tokens_impl_header
  body_scan_step_spec_header : functionHeader "scan_step" ";" SourceShape.bodyTokens = some body_scan_step_spec_header
  body_scan_step_impl_header : functionHeader "scan_step" "is" SourceShape.bodyTokens = some body_scan_step_impl_header
  body_scan_suffix_spec_header : functionHeader "scan_suffix" ";" SourceShape.bodyTokens = some body_scan_suffix_spec_header
  body_scan_suffix_impl_header : functionHeader "scan_suffix" "is" SourceShape.bodyTokens = some body_scan_suffix_impl_header
  body_form_result_spec_header : functionHeader "form_result" ";" SourceShape.bodyTokens = some body_form_result_spec_header
  body_form_result_impl_header : functionHeader "form_result" "is" SourceShape.bodyTokens = some body_form_result_impl_header
  body_is_member_impl_header : functionHeader "is_member" "is" SourceShape.bodyTokens = some body_is_member_impl_header
  body_has_arguments_impl_header : functionHeader "has_arguments" "is" SourceShape.bodyTokens = some body_has_arguments_impl_header
  body_has_assignment_impl_header : functionHeader "has_assignment" "is" SourceShape.bodyTokens = some body_has_assignment_impl_header
  body_has_output_impl_header : functionHeader "has_output" "is" SourceShape.bodyTokens = some body_has_output_impl_header
  body_read_form_spec_header : functionHeader "read_form" ";" SourceShape.bodyTokens = some body_read_form_spec_header
  body_read_form_impl_header : functionHeader "read_form" "is" SourceShape.bodyTokens = some body_read_form_impl_header
  body_valid_context_spec_header : functionHeader "valid_context" ";" SourceShape.bodyTokens = some body_valid_context_spec_header
  body_valid_context_impl_header : functionHeader "valid_context" "is" SourceShape.bodyTokens = some body_valid_context_impl_header
  body_valid_body_spec_header : functionHeader "valid_body" ";" SourceShape.bodyTokens = some body_valid_body_spec_header
  body_valid_body_impl_header : functionHeader "valid_body" "is" SourceShape.bodyTokens = some body_valid_body_impl_header
  body_accepts_impl_header : functionHeader "accepts" "is" SourceShape.bodyTokens = some body_accepts_impl_header
  body_uses_arguments_impl_header : functionHeader "uses_arguments" "is" SourceShape.bodyTokens = some body_uses_arguments_impl_header
  body_uses_assignment_impl_header : functionHeader "uses_assignment" "is" SourceShape.bodyTokens = some body_uses_assignment_impl_header
  body_uses_output_impl_header : functionHeader "uses_output" "is" SourceShape.bodyTokens = some body_uses_output_impl_header
  body_spelling_impl_header : functionHeader "spelling" "is" SourceShape.bodyTokens = some body_spelling_impl_header
  body_is_word_token_impl_header : functionHeader "is_word_token" "is" SourceShape.bodyTokens = some body_is_word_token_impl_header
  scan_result_declaration : Lexical.SourceBridge.recordDeclaration "scan_result" SourceShape.bodyTokens = some scan_result_declaration
  body_context_declaration : Lexical.SourceBridge.recordDeclaration "body_context" SourceShape.bodyTokens = some body_context_declaration
  body_scan_declaration : Lexical.SourceBridge.discriminatedRecordDeclaration "body_scan" SourceShape.bodyTokens = some body_scan_declaration
  body_stop_declaration : typeDeclaration "body_stop" SourceShape.bodyTokens = some body_stop_declaration
  form_kind_declaration : typeDeclaration "form_kind" SourceShape.specTokens = some form_kind_declaration
  token_kind_declaration : typeDeclaration "token_kind" SourceShape.specTokens = some token_kind_declaration
  token_sequence_declaration : typeDeclaration "token_sequence" SourceShape.specTokens = some token_sequence_declaration
  initial_scan_declaration : Source.declaration "initial_scan" SourceShape.bodyTokens = some initial_scan_declaration
  invalid_scan_declaration : Source.declaration "invalid_scan" SourceShape.bodyTokens = some invalid_scan_declaration
  max_source_length_declaration : Source.declaration "max_source_length" SourceShape.specTokens = some max_source_length_declaration
  max_expression_operands_declaration : Source.declaration "max_expression_operands" SourceShape.specTokens = some max_expression_operands_declaration
  max_concatenations_declaration : Source.declaration "max_concatenations" SourceShape.specTokens = some max_concatenations_declaration
  max_bindings_declaration : Source.declaration "max_bindings" SourceShape.specTokens = some max_bindings_declaration
  token_index_declaration : Lexical.SourceBridge.subtypeDeclaration "token_index" SourceShape.bodyTokens = some token_index_declaration
  binding_count_declaration : Lexical.SourceBridge.subtypeDeclaration "binding_count" SourceShape.bodyTokens = some binding_count_declaration
  binding_index_declaration : Lexical.SourceBridge.subtypeDeclaration "binding_index" SourceShape.bodyTokens = some binding_index_declaration
  operand_count_declaration : Lexical.SourceBridge.subtypeDeclaration "operand_count" SourceShape.bodyTokens = some operand_count_declaration
  concatenation_count_declaration : Lexical.SourceBridge.subtypeDeclaration "concatenation_count" SourceShape.bodyTokens = some concatenation_count_declaration
  valid_flow_body : Source.expressionBody "valid_flow" SourceShape.bodyTokens = some valid_flow_expression
  valid_flow_header : functionHeader "valid_flow" "is" SourceShape.bodyTokens = some ((Source.lexLine "(Context : Body_Context; Facts : Scalar_Flow) return Boolean").getD [])
  included_body : Source.expressionBody "included" SourceShape.bodyTokens = some included_expression
  included_header : functionHeader "included" "is" SourceShape.bodyTokens = some ((Source.lexLine "(Value, Bounds : Scalars.Interval) return Boolean").getD [])
  string_target_declaration : Lexical.SourceBridge.recordDeclaration "string_target_result" SourceShape.bodyTokens = some string_target_declaration
  valid_context_body : Source.expressionBody "valid_context" SourceShape.bodyTokens = some valid_context_expression
  valid_body_body : Source.expressionBody "valid_body" SourceShape.bodyTokens = some valid_body_expression

/-- Each original source decision is checked here once. -/
theorem checked : Checked where
  bodyWrappers := by
    constructor <;> decide +kernel
  adapterWrappers := by
    constructor <;> decide +kernel
  lemma_joined_flow_spec := by
    decide +kernel
  lemma_joined_flow_impl := by
    decide +kernel
  basic_body_body := by
    rw [BasicNative.rendered_candidate]
    decide +kernel
  statement_body_body := by
    rw [BodyNative.rendered_statement_body]
    decide +kernel
  loop_body_body := by
    rw [LoopNative.rendered_candidate]
    decide +kernel
  conditional_body_body := by
    rw [BodyNative.rendered_conditional_body]
    decide +kernel
  alternative_body_body := by
    rw [BodyNative.rendered_alternative_body]
    decide +kernel
  body_tail_model_body := by
    rw [BodyNative.rendered_body_tail_model]
    decide +kernel
  body_tail_model_spec := by
    decide +kernel
  body_tail_model_impl := by
    decide +kernel
  read_body_body := by
    rw [BodyNative.rendered_read_body]
    decide +kernel
  context_of_body := by
    rw [Adapter.context_of_candidate]
    decide +kernel
  expand_body_body := by
    rw [Adapter.expand_body_candidate]
    decide +kernel
  at_body_stop_body := by
    rw [Adapter.at_body_stop_candidate]
    decide +kernel
  read_statements_body := by
    rw [Adapter.read_statements_candidate]
    decide +kernel
  tokens_body := by
    rw [Outer.rendered_tokens]
    decide +kernel
  scan_step_body := by
    rw [Outer.rendered_scan_step]
    decide +kernel
  scan_suffix_body := by
    rw [Outer.rendered_scan_suffix]
    decide +kernel
  form_result_body := by
    rw [Outer.rendered_form_result]
    decide +kernel
  is_member_body := by
    rw [Outer.rendered_is_member]
    decide +kernel
  has_arguments_body := by
    rw [Outer.rendered_has_arguments]
    decide +kernel
  has_assignment_body := by
    rw [Outer.rendered_has_assignment]
    decide +kernel
  has_output_body := by
    rw [Outer.rendered_has_output]
    decide +kernel
  spec_tokens_spec_header := by
    decide +kernel
  spec_is_member_spec_header := by
    decide +kernel
  spec_has_arguments_spec_header := by
    decide +kernel
  spec_has_assignment_spec_header := by
    decide +kernel
  spec_has_output_spec_header := by
    decide +kernel
  spec_accepts_spec_header := by
    decide +kernel
  spec_uses_arguments_spec_header := by
    decide +kernel
  spec_uses_assignment_spec_header := by
    decide +kernel
  spec_uses_output_spec_header := by
    decide +kernel
  spec_spelling_spec_header := by
    decide +kernel
  spec_is_word_token_spec_header := by
    decide +kernel
  spec_is_argument_form_impl_header := by
    decide +kernel
  body_basic_body_spec_header := by
    decide +kernel
  body_basic_body_impl_header := by
    decide +kernel
  body_statement_body_spec_header := by
    decide +kernel
  body_statement_body_impl_header := by
    decide +kernel
  body_loop_body_spec_header := by
    decide +kernel
  body_loop_body_impl_header := by
    decide +kernel
  body_conditional_body_spec_header := by
    decide +kernel
  body_conditional_body_impl_header := by
    decide +kernel
  body_alternative_body_spec_header := by
    decide +kernel
  body_alternative_body_impl_header := by
    decide +kernel
  body_body_tail_spec_header := by
    decide +kernel
  body_body_tail_impl_header := by
    decide +kernel
  body_read_body_spec_header := by
    unfold body_read_body_spec_header
    simp only [BodyNative.readContractBody, BodyNative.ModelExpr.render.eq_def,
      BodyNative.ModelExpr.renderElse.eq_def, BodyNative.ScanExpr.render,
      BodyNative.Test.render, BodyNative.StopRef.render]
    decide +kernel
  body_read_body_impl_header := by
    decide +kernel
  body_context_of_impl_header := by
    decide +kernel
  body_body_of_impl_header := by
    decide +kernel
  body_expand_body_impl_header := by
    decide +kernel
  body_body_token_spec_header := by
    decide +kernel
  body_body_token_impl_header := by
    decide +kernel
  body_at_body_stop_spec_header := by
    decide +kernel
  body_at_body_stop_impl_header := by
    decide +kernel
  body_read_statements_spec_header := by
    decide +kernel
  body_read_statements_impl_header := by
    decide +kernel
  body_tokens_impl_header := by
    decide +kernel
  body_scan_step_spec_header := by
    decide +kernel
  body_scan_step_impl_header := by
    decide +kernel
  body_scan_suffix_spec_header := by
    decide +kernel
  body_scan_suffix_impl_header := by
    decide +kernel
  body_form_result_spec_header := by
    decide +kernel
  body_form_result_impl_header := by
    decide +kernel
  body_is_member_impl_header := by
    decide +kernel
  body_has_arguments_impl_header := by
    decide +kernel
  body_has_assignment_impl_header := by
    decide +kernel
  body_has_output_impl_header := by
    decide +kernel
  body_read_form_spec_header := by
    decide +kernel
  body_read_form_impl_header := by
    decide +kernel
  body_valid_context_spec_header := by
    decide +kernel
  body_valid_context_impl_header := by
    decide +kernel
  body_valid_body_spec_header := by
    decide +kernel
  body_valid_body_impl_header := by
    decide +kernel
  body_accepts_impl_header := by
    decide +kernel
  body_uses_arguments_impl_header := by
    decide +kernel
  body_uses_assignment_impl_header := by
    decide +kernel
  body_uses_output_impl_header := by
    decide +kernel
  body_spelling_impl_header := by
    decide +kernel
  body_is_word_token_impl_header := by
    decide +kernel
  scan_result_declaration := by
    decide +kernel
  body_context_declaration := by
    decide +kernel
  body_scan_declaration := by
    decide +kernel
  body_stop_declaration := by
    decide +kernel
  form_kind_declaration := by
    decide +kernel
  token_kind_declaration := by
    decide +kernel
  token_sequence_declaration := by
    decide +kernel
  initial_scan_declaration := by
    decide +kernel
  invalid_scan_declaration := by
    decide +kernel
  max_source_length_declaration := by
    decide +kernel
  max_expression_operands_declaration := by
    decide +kernel
  max_concatenations_declaration := by
    decide +kernel
  max_bindings_declaration := by
    decide +kernel
  token_index_declaration := by
    decide +kernel
  binding_count_declaration := by
    decide +kernel
  binding_index_declaration := by
    decide +kernel
  operand_count_declaration := by
    decide +kernel
  concatenation_count_declaration := by
    decide +kernel
  valid_flow_body := by
    decide +kernel
  valid_flow_header := by
    decide +kernel
  included_body := by
    decide +kernel
  included_header := by
    decide +kernel
  string_target_declaration := by
    decide +kernel
  valid_context_body := by
    decide +kernel
  valid_body_body := by
    decide +kernel

end Silver.Predicate.SourceChecks.BodySourceCandidate

module

public import Silver.FunctionDeclarationSource
public import Silver.FunctionVisibilitySource
public import Silver.PredicateFunctionCallSource
public import Silver.PredicateAssociationWholeSourceCandidate
public import Silver.FunctionSourceParts.CallsActualsTailModel
public import Silver.FunctionSourceParts.CallsActualsAdvance
public import Silver.FunctionSourceParts.CallsActualsAfterLoop
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

public import Silver.FunctionSourceParts.DeclarationHeaderFunctionTypeAtSpec
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionTypeAtImpl
public import Silver.FunctionSourceParts.DeclarationHeaderParameterStepSpec
public import Silver.FunctionSourceParts.DeclarationHeaderParameterStepImpl
public import Silver.FunctionSourceParts.DeclarationHeaderParametersModelSpec
public import Silver.FunctionSourceParts.DeclarationHeaderParametersModelImpl
public import Silver.FunctionSourceParts.DeclarationHeaderParametersAtSpec
public import Silver.FunctionSourceParts.DeclarationHeaderParametersAtImpl
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionLocalAtSpec
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionLocalAtImpl
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionLocalsModelSpec
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionLocalsModelImpl
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionLocalsSpec
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionLocalsImpl
public import Silver.FunctionSourceParts.DeclarationHeaderAppendParameterImpl
public import Silver.FunctionSourceParts.DeclarationHeaderParameterFrameModelSpec
public import Silver.FunctionSourceParts.DeclarationHeaderParameterFrameModelImpl
public import Silver.FunctionSourceParts.DeclarationHeaderParameterFrameSpec
public import Silver.FunctionSourceParts.DeclarationHeaderParameterFrameImpl
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionReturnAfterSpec
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionReturnAfterImpl
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionBodyAtSpec
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionBodyAtImpl
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionDeclarationAtSpec
public import Silver.FunctionSourceParts.DeclarationHeaderFunctionDeclarationAtImpl
public import Silver.FunctionSourceParts.DeclarationExpressionFunctionTypeAt
public import Silver.FunctionSourceParts.DeclarationExpressionParameterStep
public import Silver.FunctionSourceParts.DeclarationExpressionParametersModel
public import Silver.FunctionSourceParts.DeclarationExpressionFunctionLocalAt
public import Silver.FunctionSourceParts.DeclarationExpressionFunctionLocalsModel
public import Silver.FunctionSourceParts.DeclarationExpressionAppendParameter
public import Silver.FunctionSourceParts.DeclarationExpressionParameterFrameModel
public import Silver.FunctionSourceParts.DeclarationOrdinaryFunctionReturnAfter
public import Silver.FunctionSourceParts.DeclarationOrdinaryFunctionBodyAt
public import Silver.FunctionSourceParts.DeclarationOrdinaryFunctionDeclarationAt
public import Silver.FunctionSourceParts.DeclarationLoopParametersAt
public import Silver.FunctionSourceParts.DeclarationLoopFunctionLocals
public import Silver.FunctionSourceParts.DeclarationLoopParameterFrame
public import Silver.FunctionSourceParts.DeclarationTypeResult
public import Silver.FunctionSourceParts.DeclarationStepResult
public import Silver.FunctionSourceParts.DeclarationParameterCursor
public import Silver.FunctionSourceParts.VisibilityFunctionHides
public import Silver.FunctionSourceParts.VisibilityFunctionHidesHeader
public import Silver.FunctionSourceParts.VisibilityFormalHides
public import Silver.FunctionSourceParts.VisibilityFormalHidesHeader
public import Silver.FunctionSourceParts.VisibilityHiddenWord
public import Silver.FunctionSourceParts.VisibilityHiddenWordHeader
public import Silver.FunctionSourceParts.VisibilityHiddenOuter
public import Silver.FunctionSourceParts.VisibilityHiddenOuterHeader
public import Silver.FunctionSourceParts.VisibilityHideName
public import Silver.FunctionSourceParts.VisibilityHideNameHeader
public import Silver.FunctionSourceParts.CallsIncludedImpl
public import Silver.FunctionSourceParts.CallsIncludedBody
public import Silver.FunctionSourceParts.CallsActualModelSpec
public import Silver.FunctionSourceParts.CallsActualModelImpl
public import Silver.FunctionSourceParts.CallsActualAfterSpec
public import Silver.FunctionSourceParts.CallsActualAfterImpl
public import Silver.FunctionSourceParts.CallsActualsModelSpec
public import Silver.FunctionSourceParts.CallsActualsModelImpl
public import Silver.FunctionSourceParts.CallsActualsAfterSpec
public import Silver.FunctionSourceParts.CallsActualsAfterImpl
public import Silver.FunctionSourceParts.CallsCalleeAtSpec
public import Silver.FunctionSourceParts.CallsCalleeAtImpl
public import Silver.FunctionSourceParts.CallsCallModelSpec
public import Silver.FunctionSourceParts.CallsCallModelImpl
public import Silver.FunctionSourceParts.CallsReadCallSpec
public import Silver.FunctionSourceParts.CallsReadCallImpl
public import Silver.FunctionSourceParts.CallsCallAssignmentResultSpec
public import Silver.FunctionSourceParts.CallsCallAssignmentResultImpl
public import Silver.FunctionSourceParts.CallsCallAssignmentModelSpec
public import Silver.FunctionSourceParts.CallsCallAssignmentModelImpl
public import Silver.FunctionSourceParts.CallsCallAssignmentBodySpec
public import Silver.FunctionSourceParts.CallsCallAssignmentBodyImpl
public import Silver.FunctionSourceParts.CallsActualModelBody
public import Silver.FunctionSourceParts.CallsActualsModelBody
public import Silver.FunctionSourceParts.CallsCalleeAtBody
public import Silver.FunctionSourceParts.CallsCallModelBody
public import Silver.FunctionSourceParts.CallsCallAssignmentResultBody
public import Silver.FunctionSourceParts.CallsCallAssignmentModelBody
public import Silver.FunctionSourceParts.CallsCallAssignmentBodyBody

@[expose] public section

/-! Function declarations, name visibility and calls are checked against the
complete reviewed compiler source. The authoritative adapter transports these
claims through the certified equality with the actual Ada tokens. -/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate

theorem declarations :
    Compose.FunctionDeclarationNative.SourceChecks.Checked
      Output.SourceShape.outputImplementation where
  trees := Compose.FunctionDeclarationNative.checked_trees
  metadataAppend := Parts.declaration_metadata_append_header
  headers := by
    intro item present
    simp only [Silver.Compose.FunctionDeclarationNative.SourceChecks.headers, List.mem_cons, List.mem_nil_iff, or_false] at present
    rcases present with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exact Parts.declaration_header_function_type_at_spec
    · exact Parts.declaration_header_function_type_at_impl
    · exact Parts.declaration_header_parameter_step_spec
    · exact Parts.declaration_header_parameter_step_impl
    · exact Parts.declaration_header_parameters_model_spec
    · exact Parts.declaration_header_parameters_model_impl
    · exact Parts.declaration_header_parameters_at_spec
    · exact Parts.declaration_header_parameters_at_impl
    · exact Parts.declaration_header_function_local_at_spec
    · exact Parts.declaration_header_function_local_at_impl
    · exact Parts.declaration_header_function_locals_model_spec
    · exact Parts.declaration_header_function_locals_model_impl
    · exact Parts.declaration_header_function_locals_spec
    · exact Parts.declaration_header_function_locals_impl
    · exact Parts.declaration_header_append_parameter_impl
    · exact Parts.declaration_header_parameter_frame_model_spec
    · exact Parts.declaration_header_parameter_frame_model_impl
    · exact Parts.declaration_header_parameter_frame_spec
    · exact Parts.declaration_header_parameter_frame_impl
    · exact Parts.declaration_header_function_return_after_spec
    · exact Parts.declaration_header_function_return_after_impl
    · exact Parts.declaration_header_function_body_at_spec
    · exact Parts.declaration_header_function_body_at_impl
    · exact Parts.declaration_header_function_declaration_at_spec
    · exact Parts.declaration_header_function_declaration_at_impl
  expressions := by
    intro item present
    simp only [Silver.Compose.FunctionDeclarationNative.SourceChecks.expressions, List.mem_cons, List.mem_nil_iff, or_false] at present
    rcases present with rfl | rfl | rfl | rfl | rfl | rfl | rfl
    · exact Parts.declaration_expression_function_type_at
    · exact Parts.declaration_expression_parameter_step
    · exact Parts.declaration_expression_parameters_model
    · exact Parts.declaration_expression_function_local_at
    · exact Parts.declaration_expression_function_locals_model
    · exact Parts.declaration_expression_append_parameter
    · exact Parts.declaration_expression_parameter_frame_model
  ordinary := by
    intro item present
    simp only [Silver.Compose.FunctionDeclarationNative.SourceChecks.ordinary, List.mem_cons, List.mem_nil_iff, or_false] at present
    rcases present with rfl | rfl | rfl
    · exact Parts.declaration_ordinary_function_return_after
    · exact Parts.declaration_ordinary_function_body_at
    · exact Parts.declaration_ordinary_function_declaration_at
  loops := by
    intro item present
    simp only [Silver.Compose.FunctionDeclarationNative.SourceChecks.loops, List.mem_cons, List.mem_nil_iff, or_false] at present
    rcases present with rfl | rfl | rfl
    · exact Parts.declaration_loop_parameters_at
    · exact Parts.declaration_loop_function_locals
    · exact Parts.declaration_loop_parameter_frame
  typeResult := Parts.declaration_typeResult
  stepResult := Parts.declaration_stepResult
  parameterCursor := Parts.declaration_parameterCursor

theorem visibility :
    Compose.FunctionVisibilityNative.SourceChecks.Checked
      Output.SourceShape.outputImplementation where
  trees := Compose.FunctionVisibilityNative.SourceChecks.checked_trees
  functionHides := Parts.visibility_functionHides
  functionHidesHeader := Parts.visibility_functionHidesHeader
  formalHides := Parts.visibility_formalHides
  formalHidesHeader := Parts.visibility_formalHidesHeader
  hiddenWord := Parts.visibility_hiddenWord
  hiddenWordHeader := Parts.visibility_hiddenWordHeader
  hiddenOuter := Parts.visibility_hiddenOuter
  hiddenOuterHeader := Parts.visibility_hiddenOuterHeader
  hideName := Parts.visibility_hideName
  hideNameHeader := Parts.visibility_hideNameHeader

theorem calls :
    Predicate.FunctionCallNative.SourceChecks.Checked
      Output.SourceShape.outputImplementation where
  trees := Predicate.FunctionCallNative.checked_trees
  associations := PredicateAssociationWholeSourceCandidate.checked
  advance := ⟨Parts.calls_actuals_advance_spec, Parts.calls_actuals_advance_impl, Parts.calls_actuals_advance_body⟩
  actualsTailModel_spec := Parts.calls_actualsTailModel_spec
  actualsTailModel_impl := Parts.calls_actualsTailModel_impl
  actuals_tail_model_body := Parts.calls_actuals_tail_model_body
  included_impl := Parts.calls_included_impl
  included_body := Parts.calls_included_body
  actualModel_spec := Parts.calls_actualModel_spec
  actualModel_impl := Parts.calls_actualModel_impl
  actualAfter_spec := Parts.calls_actualAfter_spec
  actualAfter_impl := Parts.calls_actualAfter_impl
  actualsModel_spec := Parts.calls_actualsModel_spec
  actualsModel_impl := Parts.calls_actualsModel_impl
  actualsAfter_spec := Parts.calls_actualsAfter_spec
  actualsAfter_impl := Parts.calls_actualsAfter_impl
  actualsAfter_body := Parts.calls_actualsAfter_body
  calleeAt_spec := Parts.calls_calleeAt_spec
  calleeAt_impl := Parts.calls_calleeAt_impl
  callModel_spec := Parts.calls_callModel_spec
  callModel_impl := Parts.calls_callModel_impl
  readCall_spec := Parts.calls_readCall_spec
  readCall_impl := Parts.calls_readCall_impl
  callAssignmentResult_spec := Parts.calls_callAssignmentResult_spec
  callAssignmentResult_impl := Parts.calls_callAssignmentResult_impl
  callAssignmentModel_spec := Parts.calls_callAssignmentModel_spec
  callAssignmentModel_impl := Parts.calls_callAssignmentModel_impl
  callAssignmentBody_spec := Parts.calls_callAssignmentBody_spec
  callAssignmentBody_impl := Parts.calls_callAssignmentBody_impl
  actual_model_body := Parts.calls_actual_model_body
  actuals_model_body := Parts.calls_actuals_model_body
  callee_at_body := Parts.calls_callee_at_body
  call_model_body := Parts.calls_call_model_body
  call_assignment_result_body := Parts.calls_call_assignment_result_body
  call_assignment_model_body := Parts.calls_call_assignment_model_body
  call_assignment_body_body := Parts.calls_call_assignment_body_body

end Silver.FunctionSourceCandidate

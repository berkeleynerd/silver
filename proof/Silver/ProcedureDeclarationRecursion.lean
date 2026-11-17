module

public import Silver.ProcedureDeclarationDenotations
public import Silver.ProcedureFrameValidity
public import Silver.FunctionDeclarationRecursion

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative
open Silver.Compose.Expressions

set_option maxRecDepth 5000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

theorem parameterStep_position (text : Source) (state : ParserState) (arguments : Bool) :
    (procedureParameterStep text state arguments).state.position ≤ text.length + 1 ∧
      ((procedureParameterStep text state arguments).state.position = 0 ∨
        state.position < (procedureParameterStep text state arguments).state.position) := by
  dsimp only [procedureParameterStep]
  generalize firstEq : skipAt text state.position = first
  generalize afterEq : nameAfter text first = after
  generalize colonEq : fixedAfter text after ":" false = colonEnd
  generalize inEq : fixedAfter text colonEnd "in" true = inEnd
  generalize outEq : fixedAfter text (if inEnd = 0 then colonEnd else inEnd) "out" true = outEnd
  generalize startEq : (if outEnd ≠ 0 then outEnd else inEnd) = start
  generalize valueEq : functionTypeAt text state start = value
  have valueBound := functionTypeAt_position_bound text state start
  rw [valueEq] at valueBound
  split
  · exact ⟨Nat.zero_le _, .inl rfl⟩
  · rename_i accepted
    have advances : state.position < value.after := by
      simp only [not_or] at accepted
      omega
    split
    · rename_i nonzero
      have later := model_fixed_advances text value.after ")" false valueBound (by decide) nonzero
      exact ⟨fixedAfter_result_bound text _ ")" false (by decide), .inr (Nat.lt_trans advances later)⟩
    · split
      · rename_i later
        exact ⟨fixedAfter_result_bound text _ ";" false (by decide), .inr later⟩
      · exact ⟨Nat.zero_le _, .inl rfl⟩

theorem parameters_model_equation (text : Source) (state : ParserState) (arguments : Bool) :
    procedureParametersModel text state arguments = parametersEquation modelCalls text state arguments := by
  have progress := parameterStep_position text state arguments
  rw [procedureParametersModel]
  by_cases zero : (procedureParameterStep text state arguments).state.position = 0
  · simp [parametersEquation, modelCalls, zero]
  · have advanced : Predicate.remainingAt text (procedureParameterStep text state arguments).state.position <
        Predicate.remainingAt text state.position := by
      have later := progress.2.resolve_left zero
      unfold Predicate.remainingAt
      omega
    simp [parametersEquation, modelCalls, zero, advanced] <;> rfl

theorem appendParameter_procedures (frame : ParserState) (parameter : ProcedureBindings.Formal)
    (accepted : (appendProcedureParameter frame parameter).position ≠ 0) :
    (appendProcedureParameter frame parameter).procedures = frame.procedures := by
  have fields := appendProcedureParameter_fields frame parameter accepted
  unfold ProcedureFrameFields at fields
  have same := congrArg ParserState.procedures fields
  exact same

theorem inputFrame_model_equation (frame : ParserState) (index : Nat) :
    procedureInputFrameModel frame index = inputFrameEquation modelCalls frame index := by
  rw [procedureInputFrameModel]
  by_cases beyond : index > frame.procedures.parameters.length
  · simp [inputFrameEquation, beyond]
  · by_cases zero : (appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index)).position = 0
    · simp [inputFrameEquation, modelCalls, zero]
    · have same := appendParameter_procedures frame (ProcedureBindings.parameter frame.procedures index) zero
      have advanced : (appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index)).procedures.parameters.length - index <
          frame.procedures.parameters.length + 1 - index := by rw [same]; omega
      simp [inputFrameEquation, modelCalls, zero, advanced]

theorem prefixStep_procedures (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat)
    (accepted : (procedurePrefixStep text readFrame frame parameter declarationCount).position ≠ 0) :
    (procedurePrefixStep text readFrame frame parameter declarationCount).procedures = frame.procedures := by
  dsimp only [procedurePrefixStep] at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i permitted
    simp only [ite_eq_right permitted]
    exact appendParameter_procedures _ parameter accepted

theorem prefix_model_equation (text : Source) (readFrame frame : ParserState)
    (index declarationCount : Nat) :
    procedurePrefixModel text readFrame frame index declarationCount =
      prefixEquation modelCalls text readFrame frame index declarationCount := by
  rw [procedurePrefixModel]
  by_cases beyond : index > frame.procedures.parameters.length
  · simp [prefixEquation, beyond]
  · by_cases zero : (procedurePrefixStep text readFrame frame
        (ProcedureBindings.parameter frame.procedures index) declarationCount).position = 0
    · simp [prefixEquation, modelCalls, zero]
    · have same := prefixStep_procedures text readFrame frame
        (ProcedureBindings.parameter frame.procedures index) declarationCount zero
      have advanced : (procedurePrefixStep text readFrame frame
          (ProcedureBindings.parameter frame.procedures index) declarationCount).procedures.parameters.length - index <
          frame.procedures.parameters.length + 1 - index := by rw [same]; omega
      simp [prefixEquation, modelCalls, zero, advanced]

end Silver.Compose.ProcedureDeclarationNative

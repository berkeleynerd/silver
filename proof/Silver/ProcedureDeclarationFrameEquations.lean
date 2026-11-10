module

public import Silver.ProcedureDeclarationDomains
public import Silver.ProcedureDeclarationRecursion

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 5000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

/-- Append and the recursive model admit all component-typed failure states;
the executable wrapper additionally carries its exact written Valid_State and
positive-first-formal preconditions. -/
structure FrameEquations (calls : Calls) : Prop where
  appendParameter : ∀ frame parameter, AppendDomain frame parameter →
    calls .appendProcedureParameter frame parameter =
      appendProcedureParameterBody.eval calls ({frame, procedureParameter := parameter} : Frame).locals
  inputFrameModel : ∀ frame index, InputFrameModelDomain frame index →
    calls .procedureInputFrameModel frame index =
      procedureInputFrameModelBody.eval calls ({frame, index} : Frame).locals
  inputFrame : ∀ text frame, InputFrameDomain text frame →
    calls .procedureInputFrame text frame = calls .procedureInputFrameModel frame frame.firstProcedureParameter

/-- Scalar Append's written capacity precondition is its only logical premise.
Name spans and nonempty intervals are deliberately not added. -/
structure ScalarAppendMeaning (calls : Calls) : Prop where
  append : ∀ names item, names.length < ScalarExpression.maxBindings →
    calls .scalarAppend names item = names ++ [item]

structure AppendParameterImports (calls : Calls) (frame : ParserState)
    (parameter : ProcedureBindings.Formal) : Prop where
  scalarAppend : parameter.kind = .integer → frame.scalarNames.length ≠ ScalarExpression.maxBindings →
    calls .scalarAppend frame.scalarNames
      ⟨parameter.first, parameter.after, parameter.bounds, false, parameter.bounds, decide (parameter.mode ≠ .input)⟩ =
    frame.scalarNames ++
      [⟨parameter.first, parameter.after, parameter.bounds, false, parameter.bounds, decide (parameter.mode ≠ .input)⟩]

theorem appendParameter_imports (calls : Calls) (frame : ParserState) (parameter : ProcedureBindings.Formal)
    (imports : AppendParameterImports calls frame parameter) :
    appendProcedureParameterBody.eval calls ({frame, procedureParameter := parameter} : Frame).locals =
      appendProcedureParameter frame parameter := by
  dsimp +instances only [appendProcedureParameterBody, Expr.eval, apply2, Frame.locals,
    Field.get, StateField.set, appendProcedureParameter, Capacity.value]
  cases kindEq : parameter.kind with
  | integer =>
      by_cases full : frame.scalarNames.length = ScalarExpression.maxBindings
      · simp [full]
      · simp [full]
        simpa only [decide_not] using imports.scalarAppend kindEq full
  | boolean => simp

theorem interpreted_appendParameter (calls : Calls) (equations : FrameEquations calls)
    (scalar : ScalarAppendMeaning calls) (frame : ParserState) (parameter : ProcedureBindings.Formal)
    (valid : AppendDomain frame parameter) :
    calls .appendProcedureParameter frame parameter = appendProcedureParameter frame parameter := by
  rw [equations.appendParameter frame parameter valid]
  apply appendParameter_imports
  constructor
  intro _ notFull
  apply scalar.append
  have bound := valid.1.scalars.1
  omega

theorem interpreted_inputFrameModel (calls : Calls) (equations : FrameEquations calls)
    (scalar : ScalarAppendMeaning calls) (frame : ParserState) (index : Nat)
    (valid : InputFrameModelDomain frame index) :
    calls .procedureInputFrameModel frame index = procedureInputFrameModel frame index := by
  rw [equations.inputFrameModel frame index valid, inputFrame_denotation, inputFrame_model_equation]
  dsimp only [inputFrameEquation, modelCalls]
  by_cases zero : frame.position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    by_cases beyond : index > frame.procedures.parameters.length
    · simp only [beyond, ↓reduceIte]
    · simp only [beyond, ↓reduceIte]
      have member := ProcedureBindings.parameter_mem valid.2.1 (Nat.le_of_not_gt beyond)
      have parameterTyped := valid.1.procedures.2.2.1 _ member
      split
      · exact interpreted_inputFrameModel calls equations scalar frame (index + 1)
          ⟨valid.1, by omega, by omega⟩
      · rw [interpreted_appendParameter calls equations scalar frame _ ⟨valid.1, parameterTyped⟩]
        by_cases rejected : (appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index)).position = 0
        · simp only [rejected, ↓reduceIte]
        · simp only [rejected, ↓reduceIte]
          have same := appendParameter_procedures frame (ProcedureBindings.parameter frame.procedures index) rejected
          exact interpreted_inputFrameModel calls equations scalar
            (appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index)) (index + 1)
            ⟨FunctionDeclarationNative.appendProcedureParameter_record frame _ valid.1 parameterTyped,
              by omega, by rw [same]; omega⟩
termination_by ProcedureBindings.maxFormals + 1 - index
decreasing_by all_goals
  have capacity := valid.1.procedures.2.1
  omega

theorem interpreted_inputFrame (calls : Calls) (equations : FrameEquations calls)
    (scalar : ScalarAppendMeaning calls) (text : Source) (frame : ParserState)
    (valid : InputFrameDomain text frame) :
    calls .procedureInputFrame text frame = procedureInputFrame text frame := by
  rw [equations.inputFrame text frame valid]
  exact interpreted_inputFrameModel calls equations scalar frame frame.firstProcedureParameter
    ⟨valid.2.1.1, valid.2.2, ((FunctionDeclarationNative.nativeValidState_iff text frame).mp valid.2.1.2).2.firstProcedureParameter⟩

end Silver.Compose.ProcedureDeclarationNative

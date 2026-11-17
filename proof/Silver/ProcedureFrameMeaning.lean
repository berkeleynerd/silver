module

public import Silver.ProcedureFrameReadings
public import Silver.ProcedureMetadataSemantics
public import Silver.FunctionParameterMeaning
public import Silver.ScalarProcedureFrame

@[expose] public section

namespace Silver.Compose
open Predicate Silver.Compose.Expressions

@[simp] private theorem procedureInput_mutable :
    (ScalarProcedures.Mode.input != ScalarProcedures.Mode.input) = false := rfl

@[simp] private theorem procedureOutput_mutable :
    (ScalarProcedures.Mode.output != ScalarProcedures.Mode.input) = true := rfl

@[simp] private theorem procedureInputOutput_mutable :
    (ScalarProcedures.Mode.inputOutput != ScalarProcedures.Mode.input) = true := rfl

theorem appendProcedureParameter_valid {text frame parameter}
    (valid : ValidState text frame) (typed : ProcedureBindings.ValidFormal text parameter) :
    ValidState text (appendProcedureParameter frame parameter) := by
  unfold appendProcedureParameter
  split
  · split
    · exact model_invalid_state_valid text
    · rename_i room
      have space : frame.scalarNames.length < ScalarExpression.maxBindings := by
        have bounded := valid.2.2.2.2.2.1.1
        omega
      have scalars := ScalarExpression.validEnvironment_append valid.2.2.2.2.2.1 space
        (item := ⟨parameter.first, parameter.after, parameter.bounds, false, parameter.bounds,
          decide (parameter.mode ≠ .input)⟩)
        ⟨typed.1.1, typed.1.2.1, typed.1.2.2, typed.2.1, typed.2.1⟩
      exact ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1,
        valid.2.2.2.2.1, scalars, valid.2.2.2.2.2.2⟩
  · split
    · exact model_invalid_state_valid text
    · rename_i room
      have space : frame.booleanNames.length < BooleanBindings.maxBindings := by
        have bounded := valid.booleans.1
        omega
      have booleans := BooleanBindings.valid_append valid.booleans space
        (item := ⟨parameter.first, parameter.after, decide (parameter.mode ≠ .input)⟩) typed.1
      exact ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1,
        valid.2.2.2.2.1, valid.2.2.2.2.2.1, valid.2.2.2.2.2.2.1,
        valid.2.2.2.2.2.2.2.1, booleans, valid.2.2.2.2.2.2.2.2.2⟩

theorem appendProcedureParameter_headerReady {frame parameter}
    (ready : ScalarMetadata.HeaderReady frame.scalarNames)
    (nonempty : parameter.bounds.lower ≤ parameter.bounds.upper) :
    ScalarMetadata.HeaderReady (appendProcedureParameter frame parameter).scalarNames := by
  unfold appendProcedureParameter
  split
  · split
    · exact ScalarMetadata.headerReady_empty
    · exact ready.append (by simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not]; omega)
        (by simp)
  · split
    · exact ScalarMetadata.headerReady_empty
    · exact ready

theorem ProcedureInputFramesAt.valid {text frame index final}
    (source : ProcedureInputFramesAt frame index final) (valid : ValidState text frame)
    (positive : 0 < index) : ValidState text final := by
  induction source with
  | done => exact valid
  | skip _ _ _ _ ih => exact ih valid (by omega)
  | @next before final index _ inside _ _ _ _ ih =>
      exact ih (appendProcedureParameter_valid valid
        (valid.procedures.2.2.1 _ (ProcedureBindings.parameter_mem positive inside))) (by omega)

theorem ProcedureInputFramesAt.headerReady {text frame index final}
    (source : ProcedureInputFramesAt frame index final) (valid : ValidState text frame)
    (positive : 0 < index) (ready : ScalarMetadata.HeaderReady frame.scalarNames) :
    ScalarMetadata.HeaderReady final.scalarNames := by
  induction source with
  | done => exact ready
  | skip _ _ _ _ ih => exact ih valid (by omega) ready
  | @next before final index _ inside _ _ _ _ ih =>
      have typed := valid.procedures.2.2.1 _ (ProcedureBindings.parameter_mem positive inside)
      exact ih (appendProcedureParameter_valid valid typed) (by omega)
        (appendProcedureParameter_headerReady ready typed.2.2)

theorem procedureInputFrameModel_valid {text frame} (index : Nat)
    (valid : ValidState text frame) (positive : 0 < index) :
    ValidState text (procedureInputFrameModel frame index) := by
  rw [procedureInputFrameModel]
  split
  · exact model_invalid_state_valid text
  · split
    · exact valid
    · rename_i inside
      split
      · exact procedureInputFrameModel_valid (index + 1) valid (by omega)
      · have typed := valid.procedures.2.2.1 _ (ProcedureBindings.parameter_mem positive (by omega))
        dsimp only
        split
        · exact model_invalid_state_valid text
        · split
          · exact procedureInputFrameModel_valid (index + 1) (appendProcedureParameter_valid valid typed) (by omega)
          · exact model_invalid_state_valid text
termination_by frame.procedures.parameters.length + 1 - index
decreasing_by all_goals first | omega | assumption

/-- Unlike function formals, in out and out bindings remain mutable. All three
modes are nonstatic and use the formal's entire declared Integer interval. -/
def procedureIntegerBinding (parameter : ProcedureBindings.Formal) : ScalarExpression.Binding :=
  ⟨parameter.first, parameter.after, parameter.bounds, false, parameter.bounds,
    decide (parameter.mode ≠ .input)⟩

private theorem procedure_analysis_append (names : ScalarExpression.Environment) (declarations : Nat)
    (item : ScalarExpression.Binding) (declarationsBound : declarations ≤ names.length)
    (nonstatic : item.isStatic = false) :
    ScalarMetadata.analysis (names ++ [item]) declarations =
      ⟨Integer.put (ScalarMetadata.analysis names declarations).declared (names.length + 1) (some item.bounds),
        Integer.put (ScalarMetadata.analysis names declarations).mutable (names.length + 1) item.mutable,
        Integer.put (ScalarMetadata.analysis names declarations).static (names.length + 1) false,
        Integer.put (ScalarMetadata.analysis names declarations).refinable (names.length + 1) true⟩ := by
  unfold ScalarMetadata.analysis
  simp only [ScalarExpression.ranges_append, ScalarExpression.mutability_append]
  congr 1
  · funext index
    by_cases fresh : index = names.length + 1
    · subst index
      simp [ScalarMetadata.staticness, Integer.put, ScalarExpression.binding_append_new, nonstatic]
    · by_cases old : 0 < index ∧ index ≤ names.length
      · have extended : 0 < index ∧ index ≤ (names ++ [item]).length := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.staticness, extended, old, and_self, decide_true, Bool.true_and,
          Integer.put, fresh, ↓reduceIte, ScalarExpression.binding_append_old names item index old.1 old.2]
      · have outside : ¬(0 < index ∧ index ≤ (names ++ [item]).length) := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.staticness, outside, old, decide_false, Bool.false_and,
          Integer.put, fresh, ↓reduceIte]
  · funext index
    by_cases fresh : index = names.length + 1
    · subst index
      simp [ScalarMetadata.refinable, Integer.put, ScalarExpression.binding_append_new,
        show declarations < names.length + 1 by omega]
    · by_cases old : 0 < index ∧ index ≤ names.length
      · have extended : 0 < index ∧ index ≤ (names ++ [item]).length := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.refinable, extended, old, and_self, decide_true, Bool.true_and,
          Integer.put, fresh, ↓reduceIte, ScalarExpression.binding_append_old names item index old.1 old.2]
      · have outside : ¬(0 < index ∧ index ≤ (names ++ [item]).length) := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.refinable, outside, old, decide_false, Bool.false_and,
          Integer.put, fresh, ↓reduceIte]

theorem functionScalarAnalysis_procedureInteger (frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarations : Nat)
    (count : declarations ≤ frame.scalarNames.length) :
    functionScalarAnalysis {frame with scalarNames := frame.scalarNames ++ [procedureIntegerBinding parameter]} declarations =
      ⟨Integer.put (functionScalarAnalysis frame declarations).declared (frame.scalarNames.length + 1) (some parameter.bounds),
        Integer.put (functionScalarAnalysis frame declarations).mutable (frame.scalarNames.length + 1)
          (decide (parameter.mode ≠ .input)),
        Integer.put (functionScalarAnalysis frame declarations).static (frame.scalarNames.length + 1) false,
        Integer.put (functionScalarAnalysis frame declarations).refinable (frame.scalarNames.length + 1) true⟩ := by
  unfold functionScalarAnalysis
  have environment : ScalarExpression.bodyEnvironment
      (frame.scalarNames ++ [procedureIntegerBinding parameter]) =
      ScalarExpression.bodyEnvironment frame.scalarNames ++ [procedureIntegerBinding parameter] := by
    simp [ScalarExpression.bodyEnvironment, ScalarExpression.bodyBinding, procedureIntegerBinding]
  rw [environment, procedure_analysis_append _ _ _
    (by simpa only [ScalarExpression.bodyEnvironment_length] using count) rfl]
  simp only [ScalarExpression.bodyEnvironment_length, procedureIntegerBinding]

theorem appendProcedureParameter_analyses (frame : ParserState) (parameter : ProcedureBindings.Formal)
    (declarations : Nat) (count : declarations ≤ frame.scalarNames.length)
    (accepted : (appendProcedureParameter frame parameter).position ≠ 0) :
    functionScalarAnalysis (appendProcedureParameter frame parameter) declarations =
      ScalarProcedures.parameterAnalysis frame.scalarNames.length [ProcedureBindings.formalModel parameter]
        (functionScalarAnalysis frame declarations) ∧
    BooleanBindings.analysis (appendProcedureParameter frame parameter).booleanNames =
      ScalarProcedures.parameterBooleans frame.booleanNames.length [ProcedureBindings.formalModel parameter]
        (BooleanBindings.analysis frame.booleanNames) := by
  cases kind : parameter.kind with
  | integer =>
      have space : frame.scalarNames.length ≠ ScalarExpression.maxBindings := by
        intro full
        simp [appendProcedureParameter, kind, full, invalidState] at accepted
      have step : appendProcedureParameter frame parameter =
          {frame with scalarNames := frame.scalarNames ++ [procedureIntegerBinding parameter]} := by
        simp [appendProcedureParameter, kind, space, procedureIntegerBinding]
      rw [step, functionScalarAnalysis_procedureInteger frame parameter declarations count]
      cases mode : parameter.mode <;>
        simp [ProcedureBindings.formalModel, ProcedureBindings.modeModel, kind, mode,
          ScalarProcedures.parameterAnalysis, ScalarProcedures.parameterBooleans]
  | boolean =>
      have space : frame.booleanNames.length ≠ BooleanBindings.maxBindings := by
        intro full
        simp [appendProcedureParameter, kind, full, invalidState] at accepted
      have step : appendProcedureParameter frame parameter =
          {frame with booleanNames := frame.booleanNames ++
            [⟨parameter.first, parameter.after, decide (parameter.mode ≠ .input)⟩]} := by
        simp [appendProcedureParameter, kind, space]
      rw [step]
      cases mode : parameter.mode <;>
        simp [ProcedureBindings.formalModel, ProcedureBindings.modeModel, kind, mode,
          ScalarProcedures.parameterAnalysis, ScalarProcedures.parameterBooleans,
          functionScalarAnalysis, BooleanBindings.analysis_append]

theorem ProcedureInputFramesAt.analyses {frame index final}
    (source : ProcedureInputFramesAt frame index final) (declarations : Nat)
    (count : declarations ≤ frame.scalarNames.length) :
    functionScalarAnalysis final declarations =
      ScalarProcedures.parameterAnalysis frame.scalarNames.length
        (ScalarProcedures.inputFormals (ProcedureBindings.formalModels frame.procedures index
          (frame.procedures.parameters.length + 1 - index))) (functionScalarAnalysis frame declarations) ∧
    BooleanBindings.analysis final.booleanNames =
      ScalarProcedures.parameterBooleans frame.booleanNames.length
        (ScalarProcedures.inputFormals (ProcedureBindings.formalModels frame.procedures index
          (frame.procedures.parameters.length + 1 - index))) (BooleanBindings.analysis frame.booleanNames) := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.procedures.parameters.length + 1 - index = 0 := by omega
      simp only [empty, ProcedureBindings.formalModels, ScalarProcedures.inputFormals,
        ScalarProcedures.parameterAnalysis, ScalarProcedures.parameterBooleans, and_self]
  | @skip before final index _ more output _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      simpa only [ProcedureBindings.formalModel, output, ProcedureBindings.modeModel,
        ScalarProcedures.inputFormals] using ih count
  | @next before final index _ more input accepted _ _ ih =>
      have grows := appendProcedureParameter_grows before (ProcedureBindings.parameter before.procedures index) accepted
      have tail := ih (Nat.le_trans count grows.1)
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      cases kind : (ProcedureBindings.parameter before.procedures index).kind with
      | integer =>
          have space : before.scalarNames.length ≠ ScalarExpression.maxBindings := by
            intro full
            simp [appendProcedureParameter, kind, full, invalidState] at accepted
          have step : appendProcedureParameter before (ProcedureBindings.parameter before.procedures index) =
              {before with scalarNames := before.scalarNames ++
                [procedureIntegerBinding (ProcedureBindings.parameter before.procedures index)]} := by
            simp [appendProcedureParameter, kind, space, procedureIntegerBinding]
          rw [step] at tail
          rw [functionScalarAnalysis_procedureInteger before _ declarations count] at tail
          cases mode : (ProcedureBindings.parameter before.procedures index).mode <;>
            try exact False.elim (input mode)
          all_goals simpa [ProcedureBindings.formalModel, kind, mode, ProcedureBindings.modeModel,
            ScalarProcedures.inputFormals, ScalarProcedures.parameterAnalysis, ScalarProcedures.parameterBooleans]
            using tail
      | boolean =>
          have space : before.booleanNames.length ≠ BooleanBindings.maxBindings := by
            intro full
            simp [appendProcedureParameter, kind, full, invalidState] at accepted
          have step : appendProcedureParameter before (ProcedureBindings.parameter before.procedures index) =
              {before with booleanNames := before.booleanNames ++
                [⟨(ProcedureBindings.parameter before.procedures index).first,
                  (ProcedureBindings.parameter before.procedures index).after,
                  decide ((ProcedureBindings.parameter before.procedures index).mode ≠ .input)⟩]} := by
            simp [appendProcedureParameter, kind, space]
          rw [step] at tail
          cases mode : (ProcedureBindings.parameter before.procedures index).mode <;>
            try exact False.elim (input mode)
          all_goals simpa [ProcedureBindings.formalModel, kind, mode, ProcedureBindings.modeModel,
            ScalarProcedures.inputFormals, ScalarProcedures.parameterAnalysis, ScalarProcedures.parameterBooleans,
            functionScalarAnalysis, BooleanBindings.analysis_append] using tail


theorem ProcedureInputFramesAt.lengths {frame index final}
    (source : ProcedureInputFramesAt frame index final) :
    final.scalarNames.length = frame.scalarNames.length +
      ScalarProcedures.integerCount (ScalarProcedures.inputTypes (ProcedureBindings.formalModels frame.procedures index
        (frame.procedures.parameters.length + 1 - index))) ∧
    final.booleanNames.length = frame.booleanNames.length +
      ScalarProcedures.booleanCount (ScalarProcedures.inputTypes (ProcedureBindings.formalModels frame.procedures index
        (frame.procedures.parameters.length + 1 - index))) := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.procedures.parameters.length + 1 - index = 0 := by omega
      simp [empty, ProcedureBindings.formalModels, ScalarProcedures.inputTypes,
        ScalarProcedures.integerCount, ScalarProcedures.booleanCount]
  | @skip before final index _ more output _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      simpa only [ProcedureBindings.formalModel, output, ProcedureBindings.modeModel,
        ScalarProcedures.inputTypes] using ih
  | @next before final index _ more input accepted _ _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      cases kind : (ProcedureBindings.parameter before.procedures index).kind with
      | integer =>
          have space : before.scalarNames.length ≠ ScalarExpression.maxBindings := by
            intro full
            simp [appendProcedureParameter, kind, full, invalidState] at accepted
          simp only [appendProcedureParameter, kind, ↓reduceIte, space,
            List.length_append, List.length_singleton] at ih
          cases mode : (ProcedureBindings.parameter before.procedures index).mode <;>
            simp_all [ProcedureBindings.formalModel, ProcedureBindings.modeModel,
              ScalarProcedures.inputTypes, ScalarProcedures.integerCount, ScalarProcedures.booleanCount, Nat.add_assoc, Nat.add_comm]
      | boolean =>
          have space : before.booleanNames.length ≠ BooleanBindings.maxBindings := by
            intro full
            simp [appendProcedureParameter, kind, full, invalidState] at accepted
          simp only [appendProcedureParameter, kind, reduceCtorEq, ↓reduceIte, space,
            List.length_append, List.length_singleton] at ih
          cases mode : (ProcedureBindings.parameter before.procedures index).mode <;>
            simp_all [ProcedureBindings.formalModel, ProcedureBindings.modeModel,
              ScalarProcedures.inputTypes, ScalarProcedures.integerCount, ScalarProcedures.booleanCount, Nat.add_assoc, Nat.add_comm]

end Silver.Compose

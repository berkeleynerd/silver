module

public import Silver.ProcedureDeclarationPrefixImports

@[expose] public section
namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 2000000

structure PrefixMeaning (calls : Calls) : Prop where
  step : ∀ text readFrame frame parameter declarationCount,
    PrefixStepDomain text readFrame frame parameter declarationCount →
    PrefixImports calls text readFrame frame parameter declarationCount

theorem interpreted_prefixStep (calls : Calls) (equations : HelperEquations calls)
    (imports : PrefixMeaning calls) (text : Source) (readFrame frame : ParserState)
    (parameter : ProcedureBindings.Formal) (declarationCount : Nat)
    (valid : PrefixStepDomain text readFrame frame parameter declarationCount) :
    calls .procedurePrefixStep text readFrame frame parameter declarationCount =
      procedurePrefixStep text readFrame frame parameter declarationCount := by
  rw [equations.prefixStep text readFrame frame parameter declarationCount valid]
  exact prefixStep_imports calls text readFrame frame parameter declarationCount
    (imports.step text readFrame frame parameter declarationCount valid)

theorem interpreted_prefixModel (calls : Calls) (equations : HelperEquations calls)
    (imports : PrefixMeaning calls) (contracts : HelperContracts calls)
    (text : Source) (readFrame frame : ParserState) (index declarationCount : Nat)
    (valid : PrefixModelDomain text readFrame frame index declarationCount) :
    calls .procedurePrefixModel text readFrame frame index declarationCount =
      procedurePrefixModel text readFrame frame index declarationCount := by
  rw [equations.prefixModel text readFrame frame index declarationCount valid,
    prefix_denotation, prefix_model_equation]
  dsimp only [prefixEquation, modelCalls]
  by_cases zero : frame.position = 0
  · simp only [zero, ↓reduceIte]
  · simp only [zero, ↓reduceIte]
    by_cases beyond : index > frame.procedures.parameters.length
    · simp only [beyond, ↓reduceIte]
    · simp only [beyond, ↓reduceIte]
      have member := ProcedureBindings.parameter_mem valid.2.2.2.2.1 (Nat.le_of_not_gt beyond)
      have parameterTyped := valid.2.2.1.1.procedures.2.2.1 _ member
      have metadata := ((FunctionDeclarationNative.nativeValidState_iff text frame).mp valid.2.2.1.2).2.procedures
      have parameterValid := metadata.2.2.1 _ member
      have stepValid : PrefixStepDomain text readFrame frame
          (ProcedureBindings.parameter frame.procedures index) declarationCount :=
        ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1, parameterTyped,
          parameterValid.1.1, parameterValid.1, by
            simp only [Integer.Interval.isEmpty, Bool.not_eq_true', decide_eq_false_iff_not]
            have nonempty := parameterValid.2.2
            omega⟩
      split
      · exact interpreted_prefixModel calls equations imports contracts text readFrame frame (index + 1) declarationCount
          ⟨valid.1, valid.2.1, valid.2.2.1, valid.2.2.2.1, by omega, by omega⟩
      · have step := interpreted_prefixStep calls equations imports text readFrame frame _ declarationCount stepValid
        have next := contracts.prefixStep text readFrame frame _ declarationCount stepValid
        rw [step] at next
        rw [step]
        by_cases rejected : (procedurePrefixStep text readFrame frame
            (ProcedureBindings.parameter frame.procedures index) declarationCount).position = 0
        · simp only [rejected, ↓reduceIte]
        · simp only [rejected, ↓reduceIte]
          have same := next.2.resolve_left rejected
          exact interpreted_prefixModel calls equations imports contracts text readFrame
            (procedurePrefixStep text readFrame frame (ProcedureBindings.parameter frame.procedures index) declarationCount)
            (index + 1) declarationCount
            ⟨valid.1, valid.2.1, next.1, valid.2.2.2.1, by omega, by rw [same]; omega⟩
termination_by ProcedureBindings.maxFormals + 1 - index
decreasing_by all_goals
  have capacity := valid.2.2.1.1.procedures.2.1
  omega

theorem interpreted_prefix (calls : Calls) (equations : HelperEquations calls)
    (imports : PrefixMeaning calls) (contracts : HelperContracts calls)
    (text : Source) (frame : ParserState) (declarationCount : Nat)
    (valid : PrefixDomain text frame declarationCount) :
    calls .procedurePrefix text frame declarationCount = procedurePrefix text frame declarationCount := by
  rw [equations.prefix text frame declarationCount valid]
  exact interpreted_prefixModel calls equations imports contracts text frame frame frame.firstProcedureParameter declarationCount
    ⟨valid.1.1, valid.1.2.1, valid.1.2.1, valid.2, valid.1.2.2,
      ((FunctionDeclarationNative.nativeValidState_iff text frame).mp valid.1.2.1.2).2.firstProcedureParameter⟩

end Silver.Compose.ProcedureDeclarationNative

module

public import Silver.FunctionParameterReadings
public import Silver.PredicateFunctionCallReadings
public import Silver.ScalarFunctionDefinition

@[expose] public section

namespace Silver.Compose
open Predicate ScalarFunctions

/-- The scalar view used by a function body, with the local declaration prefix
held fixed while immutable formal bindings are appended. -/
def functionScalarAnalysis (frame : ParserState) (declarations : Nat) : Integer.Analysis :=
  ScalarMetadata.analysis (ScalarExpression.bodyEnvironment frame.scalarNames) declarations

private theorem parameter_analysis_append_index (names : ScalarExpression.Environment) (declarations : Nat)
    (item : ScalarExpression.Binding) (declarationsBound : declarations ≤ names.length)
    (immutable : item.mutable = false) (nonstatic : item.isStatic = false) :
    ScalarMetadata.analysis (names ++ [item]) declarations =
      (ScalarMetadata.analysis names declarations).withIndex (names.length + 1) item.bounds := by
  unfold ScalarMetadata.analysis Integer.Analysis.withIndex
  simp only [ScalarExpression.ranges_append, ScalarExpression.mutability_append, immutable]
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
        immutable, show declarations < names.length + 1 by omega]
    · by_cases old : 0 < index ∧ index ≤ names.length
      · have extended : 0 < index ∧ index ≤ (names ++ [item]).length := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.refinable, extended, old, and_self, decide_true, Bool.true_and,
          Integer.put, fresh, ↓reduceIte, ScalarExpression.binding_append_old names item index old.1 old.2]
      · have outside : ¬(0 < index ∧ index ≤ (names ++ [item]).length) := by
          simp only [List.length_append, List.length_singleton]; omega
        simp only [ScalarMetadata.refinable, outside, old, decide_false, Bool.false_and,
          Integer.put, fresh, ↓reduceIte]


def integerFormalBinding (parameter : FunctionBindings.Formal) : ScalarExpression.Binding :=
  {first := parameter.first, after := parameter.after, bounds := parameter.bounds, isStatic := false, declaredBounds := parameter.bounds, mutable := false}

theorem functionScalarAnalysis_integer (frame : ParserState)
    (parameter : FunctionBindings.Formal) (declarations : Nat)
    (count : declarations ≤ frame.scalarNames.length) :
    functionScalarAnalysis {frame with scalarNames := frame.scalarNames ++ [integerFormalBinding parameter]} declarations =
      (functionScalarAnalysis frame declarations).withIndex (frame.scalarNames.length + 1) parameter.bounds := by
  unfold functionScalarAnalysis
  have environment : ScalarExpression.bodyEnvironment
      (frame.scalarNames ++ [integerFormalBinding parameter]) =
      ScalarExpression.bodyEnvironment frame.scalarNames ++ [integerFormalBinding parameter] := by
    simp [ScalarExpression.bodyEnvironment, ScalarExpression.bodyBinding, integerFormalBinding]
  rw [environment]
  rw [parameter_analysis_append_index _ _ _
    (by simpa only [ScalarExpression.bodyEnvironment_length] using count) rfl rfl]
  simp only [ScalarExpression.bodyEnvironment_length, integerFormalBinding]

/-- The two analysis stores follow the same mixed formal list while assigning
Integer and Boolean identities independently after their own local prefixes. -/
theorem ParameterFramesAt.analyses {frame index final}
    (source : ParameterFramesAt frame index final) (declarations : Nat)
    (count : declarations ≤ frame.scalarNames.length) :
    functionScalarAnalysis final declarations =
      parameterAnalysis frame.scalarNames.length
        (formalTypes frame.functions index (frame.functions.parameters.length + 1 - index) frame.arrayNames.types)
        (functionScalarAnalysis frame declarations) ∧
    BooleanBindings.analysis final.booleanNames =
      parameterBooleans frame.booleanNames.length
        (formalTypes frame.functions index (frame.functions.parameters.length + 1 - index) frame.arrayNames.types)
        (BooleanBindings.analysis frame.booleanNames) := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.functions.parameters.length + 1 - index = 0 := by omega
      simp only [empty, formalTypes, parameterAnalysis, parameterBooleans, and_self]
  | @next before final index _ more accepted _ rest ih =>
      have grows := (appendParameter_scalar_count_or_rejected before
        (FunctionBindings.parameter before.functions index)).resolve_left accepted
      have tail := ih (Nat.le_trans count grows)
      have remaining : before.functions.parameters.length + 1 - index =
          (before.functions.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, formalTypes]
      by_cases named : (FunctionBindings.parameter before.functions index).typeId ≠ 0
      · have step := appendParameter_array named accepted
        rw [step] at tail
        simpa only [formalType, ite_eq_left named, parameterAnalysis, parameterBooleans,
          functionScalarAnalysis] using tail
      ·
        cases kind : (FunctionBindings.parameter before.functions index).kind with
        | integer =>
            have space : before.scalarNames.length ≠ ScalarExpression.maxBindings := by
              intro full
              simp [appendParameter, named, kind, full, invalidState] at accepted
            have step : appendParameter before (FunctionBindings.parameter before.functions index) =
                {before with scalarNames := before.scalarNames ++
                  [integerFormalBinding (FunctionBindings.parameter before.functions index)]} := by
              simp [appendParameter, named, kind, space, integerFormalBinding]
            rw [step] at tail
            rw [functionScalarAnalysis_integer before _ declarations count] at tail
            simpa only [formalType, named, ↓reduceIte, kind, parameterAnalysis, parameterBooleans,
              List.length_append, List.length_singleton] using tail
        | boolean =>
            have space : before.booleanNames.length ≠ BooleanBindings.maxBindings := by
              intro full
              simp [appendParameter, named, kind, full, invalidState] at accepted
            have step : appendParameter before (FunctionBindings.parameter before.functions index) =
                {before with booleanNames := before.booleanNames ++
                  [{first := (FunctionBindings.parameter before.functions index).first, after := (FunctionBindings.parameter before.functions index).after, mutable := false}]} := by
              simp [appendParameter, named, kind, space]
            rw [step] at tail
            simpa only [formalType, named, ↓reduceIte, kind, parameterAnalysis, parameterBooleans,
              functionScalarAnalysis, List.length_append, List.length_singleton,
              BooleanBindings.analysis_append] using tail

end Silver.Compose

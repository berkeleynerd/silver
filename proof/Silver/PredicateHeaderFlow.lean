module

public import Silver.PredicateHeader
public import Silver.PredicateScalarGuardMeaning

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

theorem ScalarMetadata.staticness_flags (names : ScalarExpression.Environment) :
    ScalarMetadata.staticness names = Integer.nameFlags (names.map (·.isStatic)) := by
  funext index
  by_cases zero : index = 0
  · simp [ScalarMetadata.staticness, Integer.nameFlags, zero]
  · by_cases inside : index - 1 < names.length
    · have active : 0 < index ∧ index ≤ names.length := by omega
      simp [ScalarMetadata.staticness, Integer.nameFlags, ScalarExpression.binding,
        active, zero, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside]
    · have outside : ¬(0 < index ∧ index ≤ names.length) := by omega
      simp [ScalarMetadata.staticness, Integer.nameFlags, outside, zero,
        List.getElem?_eq_none (by omega : names.length ≤ index - 1)]

private theorem declarationStaticFlags_append (flags : List Bool)
    (first rest : List Integer.Declaration) :
    Integer.declarationStaticFlags flags (first ++ rest) =
      Integer.declarationStaticFlags (Integer.declarationStaticFlags flags first) rest := by
  induction first generalizing flags with
  | nil => rfl
  | cons declaration remaining ih =>
      simp only [List.cons_append, Integer.declarationStaticFlags, ih]

private theorem declaration_staticFlags {text arguments state next declaration}
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    next.scalarNames.map (·.isStatic) =
      Integer.declarationStaticFlags (state.scalarNames.map (·.isStatic)) [declaration] := by
  cases parsed with
  | @declaration parts value _ _ _ reading =>
      have static := reading.staticValue
      rw [inferred_staticness reading.inferred, ScalarMetadata.staticness_flags] at static
      by_cases constant : parts.constantAfter = 0 <;>
        simp [addScalarBinding, Integer.declarationStaticFlags, Integer.Expr.freezeArrays_static, constant, static]

private theorem declarations_staticFlags {text arguments state final values}
    (parsed : ScalarDeclarationsAt text arguments state values final) :
    final.scalarNames.map (·.isStatic) =
      Integer.declarationStaticFlags (state.scalarNames.map (·.isStatic)) values := by
  induction parsed with
  | done => rfl
  | string _ _ _ _ first _ ih =>
      cases first
      exact ih
  | scalar _ _ first _ ih =>
      rw [ih, declaration_staticFlags first]
      rfl
  | array _ _ _ first _ ih =>
      rw [(array_declaration_preserves first).2] at ih
      exact ih

private theorem scalar_step_staticFlags {text form token state next values}
    (trace : Sequence.ScalarStepAt text form token state values next) :
    next.scalarNames.map (·.isStatic) =
      Integer.declarationStaticFlags (state.scalarNames.map (·.isStatic)) values := by
  cases trace with
  | declarations reading => exact declarations_staticFlags reading
  | other _ same => simp only [same, Integer.declarationStaticFlags]

theorem scalar_tokens_staticFlags {text form tokens state final values}
    (trace : Sequence.ScalarTokensAt text form tokens state values final) :
    final.scalarNames.map (·.isStatic) =
      Integer.declarationStaticFlags (state.scalarNames.map (·.isStatic)) values := by
  induction trace with
  | done => rfl
  | next _ reading _ ih =>
      rw [ih, scalar_step_staticFlags reading, declarationStaticFlags_append]

/-- Source declaration flags agree with declaration-order semantic staticness;
singleton mutable values and immutable snapshots do not create static names. -/
theorem prefix_analysis {source form values}
    (trace : Sequence.ScalarTokensAt source form.helper form.prefix initialState values
      (prefixScan source form).state) :
    (contextOf (prefixScan source form)).analysis =
      ArrayFlow.analysis (prefixScan source form).state.arrayNames.names (Integer.Analysis.ofDeclarations values) := by
  have objects := prefix_scalar_objects trace
  have flags := scalar_tokens_staticFlags trace
  simp only [initialState, List.map_nil] at flags
  have ranges := ScalarExpression.objectBindings_ranges (prefixScan source form).state.scalarNames
  have mutable := ScalarExpression.objectBindings_mutability (prefixScan source form).state.scalarNames
  rw [objects] at ranges mutable
  have static : ScalarMetadata.staticness
      (ScalarExpression.bodyEnvironment (prefixScan source form).state.scalarNames) =
      Integer.nameFlags (Integer.declarationStaticFlags [] values) := by
    rw [ScalarMetadata.staticness_flags]
    simpa only [ScalarExpression.bodyEnvironment, List.map_map, Function.comp_def,
      ScalarExpression.bodyBinding_static] using congrArg Integer.nameFlags flags
  have refinable : ScalarMetadata.refinable
      (ScalarExpression.bodyEnvironment (prefixScan source form).state.scalarNames)
      (prefixScan source form).state.scalarNames.length =
      ScalarExpression.mutability (ScalarExpression.bodyEnvironment (prefixScan source form).state.scalarNames) := by
    rw [← ScalarExpression.bodyEnvironment_length (prefixScan source form).state.scalarNames]
    exact ScalarMetadata.refinable_declarations _
  simp only [contextOf, ParseContext.analysis, ScalarMetadata.analysis, Integer.Analysis.ofDeclarations]
  congr 1
  rw [← ranges, ← mutable, static, refinable, ← mutable]

/-- Header admission supplies nonempty declared body intervals: each has the
actual checked elaboration value as a witness. -/
theorem prefix_baseReady {source form values}
    (trace : Sequence.ScalarTokensAt source form.helper form.prefix initialState values
      (prefixScan source form).state) :
    ScalarMetadata.BaseReady (contextOf (prefixScan source form)).scalarNames
      (contextOf (prefixScan source form)).declarationCount := by
  have nonempty : ScalarMetadata.DeclarationsNonempty
      (contextOf (prefixScan source form)).scalarNames
      (contextOf (prefixScan source form)).declarationCount := by
    intro index positive declared
    have active : 0 < index ∧ index ≤
        (ScalarExpression.bodyEnvironment (prefixScan source form).state.scalarNames).length := by
      simpa only [contextOf, ScalarExpression.bodyEnvironment_length] using And.intro positive declared
    have found : ScalarExpression.ranges
        (ScalarExpression.bodyEnvironment (prefixScan source form).state.scalarNames) index =
        some (ScalarExpression.binding
          (ScalarExpression.bodyEnvironment (prefixScan source form).state.scalarNames) index).bounds := by
      simp only [ScalarExpression.ranges, active, and_self, ↓reduceIte]
    rw [← ScalarExpression.objectBindings_ranges, prefix_scalar_objects trace] at found
    exact Integer.Interval.contains_nonempty
      (Integer.ObjectBindings.fits (Integer.elaborate_valid (prefix_scalar_checked trace).1) index _ found)
  refine ⟨ScalarExpression.bodyEnvironment_ready _, ?_, nonempty, ?_, ?_⟩
  · simp only [contextOf, ScalarExpression.bodyEnvironment_length]
    exact Nat.le_refl _
  · intro index positive bounded _mutable
    exact nonempty index positive
      (by simpa only [contextOf, ScalarExpression.bodyEnvironment_length] using bounded)
  · simpa only [contextOf, ScalarExpression.bodyEnvironment_length] using prefix_scalar_count_bound trace

theorem prefix_arraysReady {source form events}
    (parsed : Sequence.TokensAt source form.helper form.prefix initialState events (prefixScan source form).state) :
    (contextOf (prefixScan source form)).ArraysReady source :=
  ⟨(prefix_array_ready parsed).1.1, (prefix_array_ready parsed).2.2.1⟩

theorem bodyOf_compatible (scan : ScanResult) :
    ScalarMetadata.OverlayCompatible (contextOf scan).scalarNames (contextOf scan).declarationCount
      (bodyOf scan).facts := ScalarMetadata.initial_compatible ..

theorem bodyOf_model (scan : ScanResult) :
    (contextOf scan).flow (bodyOf scan).facts =
      Flow.initial (contextOf scan).analysis (initialFacts (contextOf scan).hasArguments) := by
  simp only [ParseContext.flow, ArrayFlow.flow, bodyOf, ActiveFlow.initial_model, Flow.initial,
    contextOf, ParseContext.analysis, ArrayFlow.analysis, ScalarMetadata.analysis]
  rfl

end Silver.Predicate

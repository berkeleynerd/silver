module

public import Silver.PredicateHeader
public import Silver.PredicateScalarGuardMeaning
public import Silver.ComposeDeclarationContext

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
  | string _ _ _ _ _ _ _ first _ _ ih =>
      rw [declaration_scalarNames first] at ih
      exact ih
  | scalar _ _ _ _ first _ _ ih =>
      rw [ih, declaration_staticFlags first]
      rfl
  | array _ _ _ _ _ first _ _ ih =>
      rw [(array_declaration_preserves first).2] at ih
      exact ih
  | booleanArray _ _ _ _ _ first _ _ ih =>
      rw [(boolean_array_declaration_preserves first).2.1] at ih
      exact ih
  | subtype _ _ _ first _ _ ih =>
      rw [(subtype_declaration_preserves first).2.1] at ih
      exact ih
  | boolean _ _ _ _ _ _ first _ _ ih =>
      rw [(boolean_declaration_preserves first).2.1] at ih
      exact ih

  | arrayType _ _ _ first _ ih =>
      have same := congrArg ParserState.scalarNames (array_type_declaration_fields first)
      dsimp only at same
      rw [same] at ih
      exact ih
  | callable _ _ accepted _ ih =>
      rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).scalarNames] at ih
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

private theorem scalar_tokens_stored {text form tokens state final values}
    (trace : Sequence.ScalarTokensAt text form tokens state values final)
    (stored : state.StoredArrays) : final.StoredArrays := by
  induction trace with
  | done => exact stored
  | next parsed _ _ ih => exact ih (Compose.step_stored parsed stored)

/-- Source declaration flags agree with declaration-order semantic staticness;
singleton mutable values and immutable snapshots do not create static names. -/
theorem prefix_analysis {source form values}
    (trace : Sequence.ScalarTokensAt source form.helper form.prefix initialState values
      (prefixScan source form).state) :
    (contextOf (prefixScan source form)).analysis =
      ArrayFlow.analysis (prefixScan source form).state.arrayNames.names (Integer.Analysis.ofDeclarations values) := by
  have stored := scalar_tokens_stored trace initialState_stored
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
  simp only [contextOf, ParseContext.analysis, ArrayViews.analysis_stored stored,
    ScalarMetadata.analysis, Integer.Analysis.ofDeclarations]
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

private theorem declarations_native_arrays {text arguments state final declarations}
    (parsed : DeclarationsAt text arguments state declarations final)
    (valid : ArrayBindings.ValidNativeEnvironment text state.arrayNames)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidNativeEnvironment text final.arrayNames := by
  induction parsed with
  | done => exact valid
  | arrayType _ _ _ first _ ih =>
      exact ih (array_type_declaration_native_valid first valid subtypes)
        (array_type_declaration_subtypes_valid first subtypes)
  | next _ _ _ _ _ _ _ first _ _ ih =>
      cases first with
      | string _ source => cases source; exact ih valid subtypes
      | character source => cases source; exact ih valid subtypes
  | scalar _ _ _ _ first _ _ ih => cases first; exact ih valid subtypes
  | boolean _ _ _ _ _ _ first _ _ ih => cases first; exact ih valid subtypes
  | subtype _ _ _ first _ _ ih =>
      have nextSubtypes := subtype_declaration_valid first subtypes
      cases first
      exact ih valid nextSubtypes
  | array _ _ _ _ _ first _ _ ih =>
      exact ih (array_declaration_native_valid first valid subtypes)
        ((array_declaration_subtypes first).symm ▸ subtypes)
  | booleanArray _ _ _ _ _ first _ _ ih =>
      exact ih (boolean_array_declaration_native_valid first valid)
        ((boolean_array_declaration_preserves first).2.2.2.symm ▸ subtypes)
  | callable _ _ accepted _ ih =>
      have kept := callableDeclarationAt_preserves_outer _ _ _ accepted
      apply ih (kept.arrayNames.symm ▸ valid)
      simpa only [IntegerSubtypes.ValidEnvironment, kept.subtypeItems] using subtypes

private theorem step_native_arrays {text form token state next event}
    (parsed : Compose.StepAt text form token state next event)
    (valid : ArrayBindings.ValidNativeEnvironment text state.arrayNames)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidNativeEnvironment text next.arrayNames := by
  by_cases declaration : token = .declarations
  · subst token
    obtain ⟨values, reading, _⟩ := parsed.payload
    exact declarations_native_arrays reading valid subtypes
  · rw [Sequence.step_arrayNames_preserved declaration parsed]
    exact valid

private theorem tokens_native_arrays {text form tokens state final events}
    (parsed : Sequence.TokensAt text form tokens state events final)
    (valid : ArrayBindings.ValidNativeEnvironment text state.arrayNames)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    ArrayBindings.ValidNativeEnvironment text final.arrayNames := by
  induction parsed with
  | done => exact valid
  | next first _ ih =>
      exact ih (step_native_arrays first valid subtypes) (Sequence.step_subtypes_valid first subtypes)

theorem prefix_arraysReady {source form events}
    (parsed : Sequence.TokensAt source form.helper form.prefix initialState events (prefixScan source form).state) :
    (contextOf (prefixScan source form)).ArraysReady source :=
  (tokens_native_arrays parsed
    (ArrayBindings.ValidNativeEnvironment.emptyItems (ArrayBindings.valid_empty_types source))
    (Sequence.initial_subtypes_valid source)).1

theorem bodyOf_compatible (scan : ScanResult) :
    ScalarMetadata.OverlayCompatible (contextOf scan).scalarNames (contextOf scan).declarationCount
      (bodyOf scan).facts := ScalarMetadata.initial_compatible ..

theorem bodyOf_model (scan : ScanResult) :
    (contextOf scan).flow (bodyOf scan).facts =
      Flow.initial (contextOf scan).analysis (initialFacts (contextOf scan).hasArguments) := by
  simp only [ParseContext.flow, bodyOf, ActiveFlow.initial_model, Flow.initial,
    contextOf, ParseContext.analysis, ArrayViews.analysis, ArrayFlow.analysis, ScalarMetadata.analysis]
  rfl

end Silver.Predicate

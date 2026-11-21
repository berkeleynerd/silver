module

public import Silver.ComposeSubtypeDeclarations
public import Silver.ScalarExpressionConstants
public import Silver.ComposeFrozenSemantics
public import Silver.IntegerArraySnapshots
public import Silver.ComposeStoredArrays

@[expose] public section

namespace Silver.Compose
open Expressions

attribute [local irreducible] ScalarExpression.ArrayGrammar.read

def ScalarDeclarationReady (text : Source) (state : ParserState) (arguments : Bool)
    (parts : ScalarDeclarationParts) : Prop :=
  newNameAllowed text state parts.first parts.after arguments = true ∧
    parts.typeAfter ≠ 0 ∧ parts.constraint.after ≠ 0 ∧ state.position < parts.following ∧
    state.scalarNames.length ≠ ScalarExpression.maxBindings ∧ parts.value.bounds.isEmpty = false ∧
    parts.value.bounds.lower = parts.value.bounds.upper ∧
    parts.constraint.bounds.lower ≤ parts.value.bounds.lower ∧
    parts.value.bounds.upper ≤ parts.constraint.bounds.upper ∧
    fixedAfter text parts.first "integer" true ≠ parts.after ∧
    lookupName text state.names parts.typeFirst parts.typeAfter = 0 ∧
    ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter = 0 ∧
    ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter = 0 ∧
    ArrayBindings.lookupType text state.arrayNames.types parts.typeFirst parts.typeAfter = 0

theorem scalarDeclarationTypeAfter_valid (text : Source) (state : ParserState) :
    scalarDeclarationTypeAfter text state ≤ text.length + 1 := by
  exact scalarTypeAt_position_valid text state (scalarDeclarationTypeFirst text state)

theorem scalarDeclarationValuePosition_valid (text : Source) (state : ParserState) :
    scalarDeclarationValuePosition text state ≤ text.length + 1 := by
  have constraint := scalarConstraintAt_position_valid text _ state.scalarNames
    (baseBounds := (scalarTypeAt text state (scalarDeclarationTypeFirst text state)).bounds)
    (arrays := state.arrayNames.table)
    (scalarDeclarationTypeAfter_valid text state)
  exact model_fixed_valid text _ ":=" false constraint

theorem scalarDeclarationParts_value (text : Source) (state : ParserState) :
    (scalarDeclarationParts text state).value =
      ScalarExpression.ArrayGrammar.read text (scalarDeclarationValuePosition text state) state.scalarNames
        (arrays := state.arrayNames.table) (initials := state.arrayNames.values) (elaborating := true) := rfl

theorem scalarDeclarationParts_following (text : Source) (state : ParserState) :
    (scalarDeclarationParts text state).following =
      fixedAfter text (scalarDeclarationParts text state).value.after ";" false := rfl

inductive ScalarDeclarationAt (text : Source) (arguments : Bool) :
    ParserState → Integer.Declaration → ParserState → Prop
  | declaration {state : ParserState} {parts : ScalarDeclarationParts} {value : Integer.Expr} :
      scalarDeclarationParts text state = parts → ScalarDeclarationReady text state arguments parts →
      ScalarObjectConstraintAt text state (scalarDeclarationTypeFirst text state) parts.constraint →
      ScalarExpression.ArrayGrammar.At text state.scalarNames (scalarDeclarationValuePosition text state) value parts.value
        (arrays := state.arrayNames.table) (initials := state.arrayNames.values) (elaborating := true) →
      ScalarDeclarationAt text arguments state
        ⟨value.freezeArrays (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values),
          parts.constraint.bounds, decide (parts.constantAfter = 0)⟩ (addScalarBinding state parts)

theorem scalar_declaration_complete {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (parsed : ScalarDeclarationAt text arguments state declaration next) :
    scalarDeclarationAt text state arguments = next := by
  cases parsed with
  | @declaration partsObj _ parts ready _ _ =>
      rcases ready with ⟨allowed, after, constraint, following, count, nonempty, singleton, lower, upper, own, strings, scalars, arrays, arrayTypes⟩
      have lower' : ¬ partsObj.value.bounds.upper < partsObj.constraint.bounds.lower := by omega
      simp [scalarDeclarationAt, parts, allowed, after, constraint, show ¬ _ ≤ _ from Nat.not_le.mpr following,
        count, nonempty, singleton, lower', show ¬ _ < _ from Int.not_lt.mpr upper, own, strings, scalars, arrays, arrayTypes]

theorem scalar_declaration_positive {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (parsed : ScalarDeclarationAt text arguments state declaration next) :
    next.position ≠ 0 := by
  cases parsed with
  | declaration _ ready _ _ =>
      have advance := ready.2.2.2.1
      simp only [addScalarBinding]
      omega

set_option maxHeartbeats 1000000 in
theorem scalar_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (scalarDeclarationAt text state arguments).position ≠ 0) :
    ∃ declaration, ScalarDeclarationAt text arguments state declaration (scalarDeclarationAt text state arguments) := by
  generalize partsEq : scalarDeclarationParts text state = parts at *
  have observed : scalarDeclarationAt text state arguments =
      if !newNameAllowed text state parts.first parts.after arguments ||
        decide (parts.typeAfter = 0 ∨ parts.constraint.after = 0 ∨
          parts.following ≤ state.position ∨ state.scalarNames.length = ScalarExpression.maxBindings) ||
        parts.value.bounds.isEmpty ||
        decide (parts.value.bounds.lower ≠ parts.value.bounds.upper ∨
          parts.value.bounds.lower < parts.constraint.bounds.lower ∨
          parts.constraint.bounds.upper < parts.value.bounds.upper) ||
        decide (fixedAfter text parts.first "integer" true = parts.after) ||
        decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0 ∨
          ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0 ∨
          ArrayBindings.lookup text state.arrayNames.names parts.typeFirst parts.typeAfter ≠ 0 ∨
          ArrayBindings.lookupType text state.arrayNames.types parts.typeFirst parts.typeAfter ≠ 0)
      then invalidState else addScalarBinding state parts := by
    simp only [scalarDeclarationAt, partsEq]
  rw [observed] at accepted ⊢
  split at accepted
  · simp [invalidState] at accepted
  · rename_i good
    have ready : ScalarDeclarationReady text state arguments parts := by
      simpa [ScalarDeclarationReady, Bool.or_eq_true, not_or, Nat.not_le, Int.not_lt, and_assoc] using good
    have valueEq := scalarDeclarationParts_value text state
    have followingEq := scalarDeclarationParts_following text state
    rw [partsEq] at valueEq followingEq
    have positive : parts.value.after ≠ 0 := by
      intro zero
      have after := ready.2.2.2.1
      simp [followingEq, zero, fixedAfter] at after
    have bound := scalarDeclarationValuePosition_valid text state
    obtain ⟨value, reading⟩ := ScalarExpression.ArrayGrammar.read_sound bound (valueEq ▸ positive)
    refine ⟨⟨value.freezeArrays (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values),
          parts.constraint.bounds, decide (parts.constantAfter = 0)⟩, ?_⟩
    simp only [good, Bool.false_eq_true, ↓reduceIte]
    have constraintEq : parts.constraint =
        scalarConstraintAt text (scalarDeclarationTypeAfter text state) state.scalarNames
          (scalarTypeAt text state (scalarDeclarationTypeFirst text state)).bounds state.arrayNames.table := by
      rw [← partsEq]
      rfl
    have constraint := scalarConstraintAt_sound text _ state.scalarNames (arrays := state.arrayNames.table)
      (scalarDeclarationTypeAfter_valid text state) (constraintEq ▸ ready.2.2.1)
    have typePositive : (scalarTypeAt text state (scalarDeclarationTypeFirst text state)).after ≠ 0 := by
      have positive := ready.2.1
      rw [← partsEq] at positive
      exact positive
    exact .declaration partsEq ready
      ⟨scalarTypeAt_sound text state _ typePositive, constraintEq.symm ▸ constraint⟩ (valueEq.symm ▸ reading)

/-- Every declaration in the semantic trace carries the exact source subtype,
interpreted in its elaboration store, rather than only a bounded model interval. -/
def ScalarDeclarationSourceBounds (text : Source) (declaration : Integer.Declaration) : Prop :=
  ∃ (state : ParserState) (position after : Nat),
    ScalarExpression.ElaboratedEnvironment state.scalarNames ∧
    ScalarTypeAt text state position (scalarTypeAt text state position) ∧
    ScalarConstraintMeaning (arrays := state.arrayNames.table) text state.scalarNames (scalarTypeAt text state position).after
      (scalarTypeAt text state position).bounds ⟨after, declaration.bounds⟩
      (Integer.Constants.store (ScalarExpression.constants state.scalarNames))

theorem scalar_declaration_source_bounds {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (elaborated : ScalarExpression.ElaboratedEnvironment state.scalarNames)
    (count : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarDeclarationSourceBounds text declaration := by
  cases parsed with
  | @declaration parts value _ _ constraint _ =>
      refine ⟨state, scalarDeclarationTypeFirst text state, parts.constraint.after,
        elaborated, constraint.typeMark, ?_⟩
      have fits : Integer.Fits (ScalarExpression.ranges state.scalarNames)
          (Integer.Constants.store (ScalarExpression.constants state.scalarNames)) := by
        rw [ScalarExpression.static_ranges elaborated]
        exact Integer.Constants.fits _
      exact constraint.constraint.evaluated count fits

theorem scalar_declaration_static {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarExpression.StaticEnvironment next.scalarNames := by
  cases parsed with
  | declaration _ ready _ reading =>
      exact ScalarExpression.elaborated_append static ready.2.2.2.2.2.2.1

theorem scalar_declaration_count_bound {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    next.scalarNames.length ≤ ArrayBindings.scalarLimit := by
  cases parsed with
  | declaration _ ready _ _ =>
      have available := ready.2.2.2.2.1
      simp only [addScalarBinding, List.length_append, List.length_singleton]
      change state.scalarNames.length ≠ ArrayBindings.scalarLimit at available
      omega

theorem scalar_initializer_frozen_inferred {text : Source} {state : ParserState}
    {parts : ScalarDeclarationParts} {value : Integer.Expr}
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (bounded : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (singleton : parts.value.bounds.lower = parts.value.bounds.upper)
    (stored : ∀ item ∈ state.arrayNames.names, item.viewSlot = 0)
    (reading : ScalarExpression.ArrayGrammar.At text state.scalarNames (scalarDeclarationValuePosition text state)
      value parts.value (arrays := state.arrayNames.table) (initials := state.arrayNames.values)
      (elaborating := true)) :
    (value.freezeArrays (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).infer
      (ScalarExpression.ranges state.scalarNames) = some parts.value.bounds := by
  have exactBounds : parts.value.bounds = Integer.Interval.singleton parts.value.bounds.lower := by
    cases equation : parts.value.bounds with
    | mk lower upper =>
        simp only [equation] at singleton
        simp only [Integer.Interval.singleton]
        cases singleton
        rfl
  have inferred := reading.inferred
  rw [exactBounds] at inferred ⊢
  apply Integer.Expr.freezeArrays_infer inferred (frozenIntegers_view_fits static stored)
  intro noArray
  apply Integer.Expr.infer_readsOnly (reading.noArray_readsOnly noArray)
  intro index inside
  exact (ArrayBindings.viewRanges_scalar _ _ _ _ (Nat.le_trans inside.2 bounded)).symm

theorem scalar_declaration_checked {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (boundedNames : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (stored : ∀ item ∈ state.arrayNames.names, item.viewSlot = 0)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    declaration.check (ScalarExpression.constants state.scalarNames) =
      some (ScalarExpression.constants next.scalarNames) := by
  cases parsed with
  | @declaration parts value partsEq ready constraint reading =>
      have singleton := ready.2.2.2.2.2.2.1
      have inferred := scalar_initializer_frozen_inferred static boundedNames singleton stored reading
      rw [ScalarExpression.static_ranges static] at inferred
      have fits : Integer.Fits (ScalarExpression.ranges state.scalarNames)
          (Integer.Constants.store (ScalarExpression.constants state.scalarNames)) := by
        rw [ScalarExpression.static_ranges static]
        exact Integer.Constants.fits _
      have sourceMeaning := constraint.constraint.evaluated boundedNames fits
      have bounded := sourceMeaning.bounded (scalarTypeAt_bounded text state _ subtypes)
      have contains : parts.constraint.bounds.Contains parts.value.bounds.lower := by
        rcases ready with ⟨_, _, _, _, _, _, equal, lower, upper, _⟩
        exact ⟨lower, equal ▸ upper⟩
      simp only [Integer.Declaration.check, inferred, Option.bind_some]
      rw [ite_eq_left ⟨singleton, bounded, contains⟩]
      simp only [addScalarBinding, ScalarExpression.constants, List.map_append, List.map_cons, List.map_nil]


theorem scalar_declaration_objects {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (exact : ScalarExpression.ElaboratedEnvironment state.scalarNames)
    (boundedNames : state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (stored : ∀ item ∈ state.arrayNames.names, item.viewSlot = 0)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarExpression.objectBindings next.scalarNames =
      ScalarExpression.objectBindings state.scalarNames ++
        [declaration.elaborate (ScalarExpression.constants state.scalarNames)] := by
  cases parsed with
  | @declaration parts value _ ready _ reading =>
      have singleton := ready.2.2.2.2.2.2.1
      have inferred := scalar_initializer_frozen_inferred exact boundedNames singleton stored reading
      rw [ScalarExpression.static_ranges exact] at inferred
      have within := (Integer.Expr.infer_sound inferred (Integer.Constants.fits _)).1
      have evaluated : (value.freezeArrays (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)).evaluate
          (Integer.Constants.store (ScalarExpression.constants state.scalarNames)) =
          parts.value.bounds.lower := by
        simp only [Integer.Interval.Contains] at within
        omega
      have same : parts.value.bounds = Integer.Interval.singleton parts.value.bounds.lower := by
        cases eq : parts.value.bounds with
        | mk lower upper =>
          simp only [eq] at singleton
          simp only [Integer.Interval.singleton]
          cases singleton
          rfl
      simp only [addScalarBinding, ScalarExpression.objectBindings_append,
        ScalarExpression.Binding.objectBinding, ScalarExpression.bodyBinding, Integer.Declaration.elaborate,
        evaluated]
      congr 2
      split
      · rfl
      · rw [same]
        rfl

theorem scalar_declaration_declared_bounds {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (valid : ScalarExpression.DeclaredBoundsValid state.scalarNames)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarExpression.DeclaredBoundsValid next.scalarNames := by
  cases parsed with
  | @declaration parts value partsEq ready constraint _ =>
      apply ScalarExpression.declaredBoundsValid_append valid
      exact constraint.bounded subtypes

theorem scalar_declaration_stored {text arguments state next declaration}
    (stored : state.StoredArrays) (reading : ScalarDeclarationAt text arguments state declaration next) :
    next.StoredArrays := by
  rw [← scalar_declaration_complete reading]
  exact scalarDeclarationAt_stored text state arguments stored

theorem scalar_declaration_subtypes {text arguments state next declaration}
    (reading : ScalarDeclarationAt text arguments state declaration next) :
    next.subtypeNames = state.subtypeNames := by
  cases reading
  rfl

theorem scalar_declaration_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : Integer.Declaration} (first : ScalarDeclarationAt text arguments state left leftState)
    (second : ScalarDeclarationAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  refine ⟨?_, (scalar_declaration_complete first).symm.trans (scalar_declaration_complete second)⟩
  cases first with
  | declaration parts _ _ value =>
      cases second with
      | declaration otherParts _ _ other =>
          have same := parts.symm.trans otherParts
          cases same
          obtain ⟨rfl, _⟩ := ScalarExpression.ArrayGrammar.at_unique value other
          rfl

end Silver.Compose

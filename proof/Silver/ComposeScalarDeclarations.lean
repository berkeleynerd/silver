module

public import Silver.ComposeBounds
public import Silver.ScalarExpressionConstants

@[expose] public section

namespace Silver.Compose
open Expressions

attribute [local irreducible] ScalarExpression.read

def ScalarDeclarationReady (text : Source) (state : ParserState) (arguments : Bool)
    (parts : ScalarDeclarationParts) : Prop :=
  newNameAllowed text state parts.first parts.after arguments = true ∧
    parts.typeAfter ≠ 0 ∧ parts.constraint.after ≠ 0 ∧ state.position < parts.following ∧
    state.scalarNames.length ≠ maxBindings ∧ parts.value.bounds.isEmpty = false ∧
    parts.value.bounds.lower = parts.value.bounds.upper ∧
    parts.constraint.bounds.lower ≤ parts.value.bounds.lower ∧
    parts.value.bounds.upper ≤ parts.constraint.bounds.upper ∧
    fixedAfter text parts.first "integer" true ≠ parts.after ∧
    lookupName text state.names parts.typeFirst parts.typeAfter = 0 ∧
    ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter = 0

theorem scalarRead_position_valid (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) (bound : position ≤ text.length + 1) :
    (ScalarExpression.read text position names).after ≤ text.length + 1 := by
  by_cases zero : (ScalarExpression.read text position names).after = 0
  · simp [zero]
  · exact (ScalarExpression.read_bounds bound zero).2.1

theorem scalarConstraintAt_position_valid (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) (bound : position ≤ text.length + 1) :
    (scalarConstraintAt text position names).after ≤ text.length + 1 := by
  have range := model_fixed_valid text position "range" true bound
  have lower := scalarRead_position_valid text _ names range
  have delimiter := model_fixed_valid text _ ".." false lower
  have upper := scalarRead_position_valid text _ names delimiter
  unfold scalarConstraintAt
  dsimp only
  split
  · exact bound
  · split
    · simp
    · exact upper

/-- Independent source reading of the optional object-local range. Both
endpoints retain their grammar, Ada-staticness and exact inferred values. -/
inductive ScalarConstraintAt (text : Source) (names : ScalarExpression.Environment)
    (position : Nat) : ScalarConstraintResult → Prop
  | absent : fixedAfter text position "range" true = 0 →
      ScalarConstraintAt text names position ⟨position, .full⟩
  | present {low high : Integer.Expr} {lower upper : ScalarExpression.Result} :
      fixedAfter text position "range" true ≠ 0 →
      ScalarExpression.At text names (fixedAfter text position "range" true) low lower →
      fixedAfter text lower.after ".." false ≠ 0 →
      ScalarExpression.At text names (fixedAfter text lower.after ".." false) high upper →
      lower.isStatic = true → upper.isStatic = true →
      lower.bounds.lower = lower.bounds.upper → upper.bounds.lower = upper.bounds.upper →
      lower.bounds.lower ≤ upper.bounds.lower →
      ScalarConstraintAt text names position
        ⟨upper.after, ⟨lower.bounds.lower, upper.bounds.lower⟩⟩

theorem scalarConstraintAt_sound (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) (bound : position ≤ text.length + 1)
    (positive : (scalarConstraintAt text position names).after ≠ 0) :
    ScalarConstraintAt text names position (scalarConstraintAt text position names) := by
  have range := model_fixed_valid text position "range" true bound
  have lower := scalarRead_position_valid text _ names range
  have delimiter := model_fixed_valid text _ ".." false lower
  unfold scalarConstraintAt at positive ⊢
  dsimp only at positive ⊢
  split
  · rename_i absent
    exact .absent absent
  · rename_i present
    split
    · simp_all
    · rename_i good
      simp only [not_or, ne_eq, Decidable.not_not, Int.not_lt, Bool.not_eq_false] at good
      obtain ⟨low, lowRead⟩ := ScalarExpression.read_sound range good.1
      obtain ⟨high, highRead⟩ := ScalarExpression.read_sound delimiter good.2.2.1
      exact .present present lowRead good.2.1 highRead
        good.2.2.2.1
        good.2.2.2.2.1
        good.2.2.2.2.2.2.2.1 good.2.2.2.2.2.2.2.2.1 good.2.2.2.2.2.2.2.2.2

/-- Exact meaning of the source subtype in any store fitting the declaration
reading environment; range syntax and endpoint cursors are retained. -/
def ScalarConstraintMeaning (text : Source) (names : ScalarExpression.Environment)
    (position : Nat) (result : ScalarConstraintResult) (values : Integer.Store) : Prop :=
  (fixedAfter text position "range" true = 0 ∧ result = ⟨position, .full⟩) ∨
  ∃ (low high : Integer.Expr) (lower upper : ScalarExpression.Result),
    fixedAfter text position "range" true ≠ 0 ∧
    ScalarExpression.At text names (fixedAfter text position "range" true) low lower ∧
    fixedAfter text lower.after ".." false ≠ 0 ∧
    ScalarExpression.At text names (fixedAfter text lower.after ".." false) high upper ∧
    ScalarExpression.isStatic names low = true ∧ ScalarExpression.isStatic names high = true ∧
    result = ⟨upper.after, ⟨low.evaluate values, high.evaluate values⟩⟩ ∧
    low.Safe values ∧ high.Safe values ∧ low.evaluate values ≤ high.evaluate values

theorem ScalarConstraintAt.evaluated {text names position result values}
    (reading : ScalarConstraintAt text names position result)
    (fits : Integer.Fits (ScalarExpression.ranges names) values) :
    ScalarConstraintMeaning text names position result values := by
  cases reading with
  | absent missing => exact .inl ⟨missing, rfl⟩
  | @present low high lower upper present lowRead delimiter highRead lowStatic highStatic lowExact highExact ordered =>
      obtain ⟨lowSafe, lowContains, _⟩ := ScalarExpression.at_safe lowRead fits
      obtain ⟨highSafe, highContains, _⟩ := ScalarExpression.at_safe highRead fits
      have lowValue : low.evaluate values = lower.bounds.lower := by
        simp only [Integer.Interval.Contains] at lowContains
        omega
      have highValue : high.evaluate values = upper.bounds.lower := by
        simp only [Integer.Interval.Contains] at highContains
        omega
      refine .inr ⟨low, high, lower, upper, present, lowRead, delimiter, highRead,
        lowRead.staticValue ▸ lowStatic, highRead.staticValue ▸ highStatic, ?_, lowSafe, highSafe, ?_⟩
      · rw [lowValue, highValue]
      · simpa only [lowValue, highValue] using ordered

theorem ScalarConstraintMeaning.bounded {text names position result values}
    (meaning : ScalarConstraintMeaning text names position result values) : result.bounds.Bounded := by
  rcases meaning with ⟨_, rfl⟩ | ⟨low, high, lower, upper, _, _, _, _, _, _, rfl, lowSafe, highSafe, _⟩
  · exact Integer.Interval.full_bounded
  · exact ⟨Integer.Expr.safe_value lowSafe, Integer.Expr.safe_value highSafe⟩

theorem ScalarConstraintAt.bounded {text names position result}
    (reading : ScalarConstraintAt text names position result) : result.bounds.Bounded := by
  cases reading with
  | absent => exact Integer.Interval.full_bounded
  | present _ lowRead _ highRead _ _ _ _ _ =>
      exact ⟨(Integer.Expr.infer_bounded lowRead.inferred).1,
        (Integer.Expr.infer_bounded highRead.inferred).1⟩

theorem scalarConstraintAt_bounded (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) (bound : position ≤ text.length + 1)
    (positive : (scalarConstraintAt text position names).after ≠ 0) :
    (scalarConstraintAt text position names).bounds.Bounded :=
  (scalarConstraintAt_sound text position names bound positive).bounded

theorem scalarDeclarationTypeAfter_valid (text : Source) (state : ParserState) :
    scalarDeclarationTypeAfter text state ≤ text.length + 1 := by
  have name := model_name_valid text (declarationFirst text state)
  have colon := model_fixed_valid text (declarationAfter text state) ":" false name
  have constant := model_fixed_valid text (declarationColonAfter text state) "constant" true colon
  have selected : (if declarationConstantAfter text state ≠ 0 then declarationConstantAfter text state
      else declarationColonAfter text state) ≤ text.length + 1 := by split <;> assumption
  have first := model_skip_valid text _ selected
  exact model_fixed_valid text (scalarDeclarationTypeFirst text state) "integer" true first

theorem scalarDeclarationValuePosition_valid (text : Source) (state : ParserState) :
    scalarDeclarationValuePosition text state ≤ text.length + 1 := by
  have constraint := scalarConstraintAt_position_valid text _ state.scalarNames
    (scalarDeclarationTypeAfter_valid text state)
  exact model_fixed_valid text _ ":=" false constraint

theorem scalarDeclarationParts_value (text : Source) (state : ParserState) :
    (scalarDeclarationParts text state).value =
      ScalarExpression.read text (scalarDeclarationValuePosition text state) state.scalarNames := rfl

theorem scalarDeclarationParts_following (text : Source) (state : ParserState) :
    (scalarDeclarationParts text state).following =
      fixedAfter text (scalarDeclarationParts text state).value.after ";" false := rfl

inductive ScalarDeclarationAt (text : Source) (arguments : Bool) :
    ParserState → Integer.Declaration → ParserState → Prop
  | declaration {state : ParserState} {parts : ScalarDeclarationParts} {value : Integer.Expr} :
      scalarDeclarationParts text state = parts → ScalarDeclarationReady text state arguments parts →
      ScalarConstraintAt text state.scalarNames (scalarDeclarationTypeAfter text state) parts.constraint →
      ScalarExpression.At text state.scalarNames (scalarDeclarationValuePosition text state) value parts.value →
      ScalarDeclarationAt text arguments state
        ⟨value, parts.constraint.bounds, decide (parts.constantAfter = 0)⟩ (addScalarBinding state parts)

theorem scalar_declaration_complete {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (parsed : ScalarDeclarationAt text arguments state declaration next) :
    scalarDeclarationAt text state arguments = next := by
  cases parsed with
  | @declaration partsObj _ parts ready _ _ =>
      rcases ready with ⟨allowed, after, constraint, following, count, nonempty, singleton, lower, upper, own, strings, scalars⟩
      have lower' : ¬ partsObj.value.bounds.upper < partsObj.constraint.bounds.lower := by omega
      simp [scalarDeclarationAt, parts, allowed, after, constraint, show ¬ _ ≤ _ from Nat.not_le.mpr following,
        count, nonempty, singleton, lower', show ¬ _ < _ from Int.not_lt.mpr upper, own, strings, scalars]

theorem scalar_declaration_positive {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (parsed : ScalarDeclarationAt text arguments state declaration next) :
    next.position ≠ 0 := by
  cases parsed with
  | declaration _ ready _ _ =>
      have advance := ready.2.2.2.1
      simp only [addScalarBinding]
      omega

theorem scalar_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (scalarDeclarationAt text state arguments).position ≠ 0) :
    ∃ declaration, ScalarDeclarationAt text arguments state declaration (scalarDeclarationAt text state arguments) := by
  generalize partsEq : scalarDeclarationParts text state = parts at *
  have observed : scalarDeclarationAt text state arguments =
      if !newNameAllowed text state parts.first parts.after arguments ||
        decide (parts.typeAfter = 0 ∨ parts.constraint.after = 0 ∨
          parts.following ≤ state.position ∨ state.scalarNames.length = maxBindings) ||
        parts.value.bounds.isEmpty ||
        decide (parts.value.bounds.lower ≠ parts.value.bounds.upper ∨
          parts.value.bounds.lower < parts.constraint.bounds.lower ∨
          parts.constraint.bounds.upper < parts.value.bounds.upper) ||
        decide (fixedAfter text parts.first "integer" true = parts.after) ||
        decide (lookupName text state.names parts.typeFirst parts.typeAfter ≠ 0 ∨
          ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter ≠ 0)
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
    obtain ⟨value, reading⟩ := ScalarExpression.read_sound bound (valueEq ▸ positive)
    refine ⟨⟨value, parts.constraint.bounds, decide (parts.constantAfter = 0)⟩, ?_⟩
    simp only [good, Bool.false_eq_true, ↓reduceIte]
    have constraintEq : parts.constraint =
        scalarConstraintAt text (scalarDeclarationTypeAfter text state) state.scalarNames := by
      rw [← partsEq]
      rfl
    have constraint := scalarConstraintAt_sound text _ state.scalarNames
      (scalarDeclarationTypeAfter_valid text state) (constraintEq ▸ ready.2.2.1)
    exact .declaration partsEq ready (constraintEq.symm ▸ constraint) (valueEq.symm ▸ reading)

/-- Every declaration in the semantic trace carries the exact source subtype,
interpreted in its elaboration store, rather than only a bounded model interval. -/
def ScalarDeclarationSourceBounds (text : Source) (declaration : Integer.Declaration) : Prop :=
  ∃ (names : ScalarExpression.Environment) (position after : Nat),
    ScalarExpression.ElaboratedEnvironment names ∧
    ScalarConstraintMeaning text names position ⟨after, declaration.bounds⟩
      (Integer.Constants.store (ScalarExpression.constants names))

theorem scalar_declaration_source_bounds {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (elaborated : ScalarExpression.ElaboratedEnvironment state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarDeclarationSourceBounds text declaration := by
  cases parsed with
  | @declaration parts value _ _ constraint _ =>
      refine ⟨state.scalarNames, scalarDeclarationTypeAfter text state, parts.constraint.after,
        elaborated, ?_⟩
      have fits : Integer.Fits (ScalarExpression.ranges state.scalarNames)
          (Integer.Constants.store (ScalarExpression.constants state.scalarNames)) := by
        rw [ScalarExpression.static_ranges elaborated]
        exact Integer.Constants.fits _
      exact constraint.evaluated fits

theorem scalar_declaration_static {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarExpression.StaticEnvironment next.scalarNames := by
  cases parsed with
  | declaration _ _ _ reading =>
      exact ScalarExpression.elaborated_append static (ScalarExpression.static_inference static reading.inferred)

theorem scalar_declaration_checked {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    declaration.check (ScalarExpression.constants state.scalarNames) =
      some (ScalarExpression.constants next.scalarNames) := by
  cases parsed with
  | @declaration parts value partsEq ready constraint reading =>
      have singleton := ScalarExpression.static_inference static reading.inferred
      have inferred := reading.inferred
      rw [ScalarExpression.static_ranges static] at inferred
      have fits : Integer.Fits (ScalarExpression.ranges state.scalarNames)
          (Integer.Constants.store (ScalarExpression.constants state.scalarNames)) := by
        rw [ScalarExpression.static_ranges static]
        exact Integer.Constants.fits _
      have sourceMeaning := constraint.evaluated fits
      have bounded := sourceMeaning.bounded
      have contains : parts.constraint.bounds.Contains parts.value.bounds.lower := by
        rcases ready with ⟨_, _, _, _, _, _, equal, lower, upper, _⟩
        exact ⟨lower, equal ▸ upper⟩
      simp only [Integer.Declaration.check, inferred, Option.bind_some]
      rw [ite_eq_left ⟨singleton, bounded, contains⟩]
      simp only [addScalarBinding, ScalarExpression.constants, List.map_append, List.map_cons, List.map_nil]


theorem scalar_declaration_objects {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (exact : ScalarExpression.ElaboratedEnvironment state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarExpression.objectBindings next.scalarNames =
      ScalarExpression.objectBindings state.scalarNames ++
        [declaration.elaborate (ScalarExpression.constants state.scalarNames)] := by
  cases parsed with
  | @declaration parts value _ _ _ reading =>
      have singleton := ScalarExpression.static_inference exact reading.inferred
      have inferred := reading.inferred
      rw [ScalarExpression.static_ranges exact] at inferred
      have within := (Integer.Expr.infer_sound inferred (Integer.Constants.fits _)).1
      have evaluated : value.evaluate (Integer.Constants.store (ScalarExpression.constants state.scalarNames)) =
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
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarExpression.DeclaredBoundsValid next.scalarNames := by
  cases parsed with
  | @declaration parts value partsEq ready constraint _ =>
      apply ScalarExpression.declaredBoundsValid_append valid
      exact constraint.bounded

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
          obtain ⟨rfl, _⟩ := ScalarExpression.at_unique value other
          rfl

end Silver.Compose

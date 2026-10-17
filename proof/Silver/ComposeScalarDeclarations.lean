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

theorem scalarConstraintAt_bounded (text : Source) (position : Nat)
    (names : ScalarExpression.Environment) (bound : position ≤ text.length + 1)
    (_positive : (scalarConstraintAt text position names).after ≠ 0) :
    (scalarConstraintAt text position names).bounds.Bounded := by
  have range := model_fixed_valid text position "range" true bound
  have lower := scalarRead_position_valid text _ names range
  have delimiter := model_fixed_valid text _ ".." false lower
  unfold scalarConstraintAt at _positive ⊢
  dsimp only at _positive ⊢
  split
  · exact Integer.Interval.full_bounded
  · split
    · exact Integer.Interval.empty_bounded
    · rename_i good
      have lowPositive : (ScalarExpression.read text (fixedAfter text position "range" true) names).after ≠ 0 := by
        intro zero
        exact good (Or.inl zero)
      have highPositive : (ScalarExpression.read text
          (fixedAfter text (ScalarExpression.read text (fixedAfter text position "range" true) names).after ".." false) names).after ≠ 0 := by
        intro zero
        exact good (Or.inr (Or.inl zero))
      obtain ⟨low, lowRead⟩ := ScalarExpression.read_sound range lowPositive
      obtain ⟨high, highRead⟩ := ScalarExpression.read_sound delimiter highPositive
      exact ⟨(Integer.Expr.infer_bounded lowRead.inferred).1,
        (Integer.Expr.infer_bounded highRead.inferred).1⟩

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
      ScalarExpression.At text state.scalarNames (scalarDeclarationValuePosition text state) value parts.value →
      ScalarDeclarationAt text arguments state
        ⟨value, parts.constraint.bounds, decide (parts.constantAfter = 0)⟩ (addScalarBinding state parts)

theorem scalar_declaration_complete {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (parsed : ScalarDeclarationAt text arguments state declaration next) :
    scalarDeclarationAt text state arguments = next := by
  cases parsed with
  | @declaration partsObj _ parts ready _ =>
      rcases ready with ⟨allowed, after, constraint, following, count, nonempty, singleton, lower, upper, own, strings, scalars⟩
      have lower' : ¬ partsObj.value.bounds.upper < partsObj.constraint.bounds.lower := by omega
      simp [scalarDeclarationAt, parts, allowed, after, constraint, show ¬ _ ≤ _ from Nat.not_le.mpr following,
        count, nonempty, singleton, lower', show ¬ _ < _ from Int.not_lt.mpr upper, own, strings, scalars]

theorem scalar_declaration_positive {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (parsed : ScalarDeclarationAt text arguments state declaration next) :
    next.position ≠ 0 := by
  cases parsed with
  | declaration _ ready _ =>
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
    exact .declaration partsEq ready (valueEq.symm ▸ reading)

theorem scalar_declaration_static {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarExpression.StaticEnvironment next.scalarNames := by
  cases parsed with
  | declaration _ _ reading =>
      exact ScalarExpression.elaborated_append static (ScalarExpression.static_inference static reading.inferred)

theorem scalar_declaration_checked {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    declaration.check (ScalarExpression.constants state.scalarNames) =
      some (ScalarExpression.constants next.scalarNames) := by
  cases parsed with
  | @declaration parts value partsEq ready reading =>
      have singleton := ScalarExpression.static_inference static reading.inferred
      have inferred := reading.inferred
      rw [ScalarExpression.static_ranges static] at inferred
      have constraintEq : parts.constraint =
          scalarConstraintAt text (scalarDeclarationTypeAfter text state) state.scalarNames := by
        rw [← partsEq]
        rfl
      have bounded : parts.constraint.bounds.Bounded := by
        rw [constraintEq]
        exact scalarConstraintAt_bounded text _ state.scalarNames
          (scalarDeclarationTypeAfter_valid text state) (constraintEq ▸ ready.2.2.1)
      have contains : parts.constraint.bounds.Contains parts.value.bounds.lower := by
        rcases ready with ⟨_, _, _, _, _, _, equal, lower, upper, _⟩
        exact ⟨lower, equal ▸ upper⟩
      simp only [Integer.Declaration.check, inferred, Option.bind_some]
      rw [ite_eq_left ⟨singleton, bounded, contains⟩]
      simp only [addScalarBinding, ScalarExpression.constants, List.map_append, List.map_cons, List.map_nil]


theorem scalar_declaration_unique {text : Source} {arguments : Bool} {state leftState rightState : ParserState}
    {left right : Integer.Declaration} (first : ScalarDeclarationAt text arguments state left leftState)
    (second : ScalarDeclarationAt text arguments state right rightState) : left = right ∧ leftState = rightState := by
  refine ⟨?_, (scalar_declaration_complete first).symm.trans (scalar_declaration_complete second)⟩
  cases first with
  | declaration parts _ value =>
      cases second with
      | declaration otherParts _ other =>
          have same := parts.symm.trans otherParts
          cases same
          obtain ⟨rfl, _⟩ := ScalarExpression.at_unique value other
          rfl

end Silver.Compose

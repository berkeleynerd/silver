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
    parts.typeAfter ≠ 0 ∧ state.position < parts.following ∧
    state.scalarNames.length ≠ maxBindings ∧ parts.value.isStatic = true ∧
    parts.value.bounds.isEmpty = false ∧ fixedAfter text parts.first "integer" true ≠ parts.after ∧
    lookupName text state.names parts.typeFirst parts.typeAfter = 0 ∧
    ScalarExpression.lookup text state.scalarNames parts.typeFirst parts.typeAfter = 0

theorem scalarDeclarationValuePosition_valid (text : Source) (state : ParserState) :
    scalarDeclarationValuePosition text state ≤ text.length + 1 := by
  have name := model_name_valid text (declarationFirst text state)
  have colon := model_fixed_valid text (declarationAfter text state) ":" false name
  have constant := model_fixed_valid text (declarationColonAfter text state) "constant" true colon
  have first := model_skip_valid text (declarationConstantAfter text state) constant
  have after := model_fixed_valid text (scalarDeclarationTypeFirst text state) "integer" true first
  exact model_fixed_valid text (scalarDeclarationTypeAfter text state) ":=" false after

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
      ScalarDeclarationAt text arguments state ⟨value⟩ (addScalarBinding state parts)

theorem scalar_declaration_complete {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (parsed : ScalarDeclarationAt text arguments state declaration next) :
    scalarDeclarationAt text state arguments = next := by
  cases parsed with
  | declaration parts ready _ =>
      rcases ready with ⟨allowed, after, following, count, static, nonempty, own, strings, scalars⟩
      simp [scalarDeclarationAt, parts, allowed, after, show ¬ _ ≤ _ from Nat.not_le.mpr following,
        count, static, nonempty, own, strings, scalars]

theorem scalar_declaration_positive {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (parsed : ScalarDeclarationAt text arguments state declaration next) :
    next.position ≠ 0 := by
  cases parsed with
  | declaration _ ready _ =>
      have advance := ready.2.2.1
      simp only [addScalarBinding]
      omega

theorem scalar_declaration_sound (text : Source) (state : ParserState) (arguments : Bool)
    (accepted : (scalarDeclarationAt text state arguments).position ≠ 0) :
    ∃ declaration, ScalarDeclarationAt text arguments state declaration (scalarDeclarationAt text state arguments) := by
  generalize partsEq : scalarDeclarationParts text state = parts at *
  have observed : scalarDeclarationAt text state arguments =
      if !newNameAllowed text state parts.first parts.after arguments ||
        decide (parts.typeAfter = 0 ∨ parts.following ≤ state.position ∨ state.scalarNames.length = maxBindings) ||
        !parts.value.isStatic || parts.value.bounds.isEmpty ||
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
      simpa [ScalarDeclarationReady, Bool.or_eq_true, not_or, Nat.not_le, and_assoc] using good
    have valueEq := scalarDeclarationParts_value text state
    have followingEq := scalarDeclarationParts_following text state
    rw [partsEq] at valueEq followingEq
    have positive : parts.value.after ≠ 0 := by
      intro zero
      have after := ready.2.2.1
      simp [followingEq, zero, fixedAfter] at after
    have bound := scalarDeclarationValuePosition_valid text state
    obtain ⟨value, reading⟩ := ScalarExpression.read_sound bound (valueEq ▸ positive)
    refine ⟨⟨value⟩, ?_⟩
    simp only [good, Bool.false_eq_true, ↓reduceIte]
    exact .declaration partsEq ready (valueEq.symm ▸ reading)

theorem scalar_declaration_static {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarExpression.StaticEnvironment next.scalarNames := by
  cases parsed with
  | declaration _ _ reading =>
      exact ScalarExpression.static_append static rfl (ScalarExpression.static_inference static reading.inferred)

theorem scalar_declaration_checked {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    declaration.check (ScalarExpression.constants state.scalarNames) =
      some (ScalarExpression.constants next.scalarNames) := by
  cases parsed with
  | @declaration parts value _ _ reading =>
      have singleton := ScalarExpression.static_inference static reading.inferred
      have inferred := reading.inferred
      rw [ScalarExpression.static_ranges static] at inferred
      have append := ScalarExpression.constants_append (names := state.scalarNames)
        (item := ⟨parts.first, parts.after, parts.value.bounds, true⟩) rfl singleton
      simp only [Integer.Declaration.check, inferred, Option.bind_some, ite_eq_left singleton,
        addScalarBinding]
      exact congrArg some append.symm

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

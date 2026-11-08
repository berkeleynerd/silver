module

public import Silver.SequenceTokens

@[expose] public section

/-! Subtype metadata validity and operation visibility follow the actual
header tokens from the empty declaration environment. -/
namespace Silver.Sequence
open Compose

theorem step_subtypes_preserved {text form token state next event}
    (ordinary : token ≠ ShellToken.declarations) (parsed : StepAt text form token state next event) :
    next.subtypeNames = state.subtypeNames := by
  have following := parsed.following
  cases token with
  | declarations => exact False.elim (ordinary rfl)
  | argumentDeclaration =>
      obtain ⟨fallback, reading, _⟩ := parsed.payload
      cases reading
      rfl
  | contextClauses | fixed | literal =>
      rw [← parsed.scanned]
      simp only [step, parsed.positive, ↓reduceIte]
  | capacity | dynamicReference | assignmentTarget | targetReference | assignmentValue |
      outputExpression | comparisonExpression =>
      rw [← parsed.scanned] at following ⊢
      simp only [step, parsed.positive, ↓reduceIte, capacityAt, dynamicAt, targetAt,
        assignmentAt, outputAt, comparisonAt] at following ⊢
      split <;> (try split) <;> simp_all [invalidState]

theorem step_functions_preserved {text form token state next event}
    (ordinary : token ≠ ShellToken.declarations) (parsed : StepAt text form token state next event) :
    next.functions = state.functions := by
  have following := parsed.following
  cases token with
  | declarations => exact False.elim (ordinary rfl)
  | argumentDeclaration =>
      obtain ⟨fallback, reading, _⟩ := parsed.payload
      cases reading
      rfl
  | contextClauses | fixed | literal =>
      rw [← parsed.scanned]
      simp only [step, parsed.positive, ↓reduceIte]
  | capacity | dynamicReference | assignmentTarget | targetReference | assignmentValue |
      outputExpression | comparisonExpression =>
      rw [← parsed.scanned] at following ⊢
      simp only [step, parsed.positive, ↓reduceIte, capacityAt, dynamicAt, targetAt,
        assignmentAt, outputAt, comparisonAt] at following ⊢
      split <;> (try split) <;> simp_all [invalidState]

theorem step_subtypes_valid {text form token state next event}
    (parsed : StepAt text form token state next event)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    IntegerSubtypes.ValidEnvironment text next.subtypeNames := by
  by_cases declaration : token = .declarations
  · subst token
    obtain ⟨values, reading, _⟩ := parsed.payload
    exact declarations_subtypes_valid reading valid
  · rw [step_subtypes_preserved declaration parsed]
    exact valid

theorem tokens_subtypes_valid {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final)
    (valid : IntegerSubtypes.ValidEnvironment text state.subtypeNames) :
    IntegerSubtypes.ValidEnvironment text final.subtypeNames := by
  induction parsed with
  | done => exact valid
  | next first _ ih => exact ih (step_subtypes_valid first valid)

theorem initial_subtypes_valid (text : Source) :
    IntegerSubtypes.ValidEnvironment text initialState.subtypeNames :=
  IntegerSubtypes.valid_empty text

theorem step_subtypes_hiding {text form token state next event}
    (parsed : StepAt text form token state next event)
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames
      (state.functions.items.map (fun item => (item.first, item.after)))) :
    IntegerSubtypes.HidingCorrect text next.subtypeNames
      (next.functions.items.map (fun item => (item.first, item.after))) := by
  by_cases declaration : token = .declarations
  · subst token
    obtain ⟨values, reading, _⟩ := parsed.payload
    exact declarations_subtypes_hiding reading correct
  · rw [step_subtypes_preserved declaration parsed, step_functions_preserved declaration parsed]
    exact correct

theorem tokens_subtypes_hiding {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final)
    (correct : IntegerSubtypes.HidingCorrect text state.subtypeNames
      (state.functions.items.map (fun item => (item.first, item.after)))) :
    IntegerSubtypes.HidingCorrect text final.subtypeNames
      (final.functions.items.map (fun item => (item.first, item.after))) := by
  induction parsed with
  | done => exact correct
  | next first _ ih => exact ih (step_subtypes_hiding first correct)

theorem initial_subtypes_hiding (text : Source) :
    IntegerSubtypes.HidingCorrect text initialState.subtypeNames :=
  IntegerSubtypes.hiding_empty text

end Silver.Sequence

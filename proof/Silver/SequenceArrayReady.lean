module

public import Silver.SequenceTokens
public import Silver.ComposeArrayElaboration

@[expose] public section

/-! Source allocation readiness follows the actual header token trace from
its empty state. No source-layout assumption is added at an admission endpoint. -/
namespace Silver.Sequence
open Compose

private theorem step_array_preserved {text form token state next event}
    (ordinary : token ≠ ShellToken.declarations) (parsed : StepAt text form token state next event) :
    next.arrayNames = state.arrayNames := by
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

theorem step_array_ready {text form token state next event}
    (parsed : StepAt text form token state next event)
    (ready : ArrayBindings.SourceReady text state.arrayNames) :
    ArrayBindings.SourceReady text next.arrayNames := by
  by_cases declaration : token = .declarations
  · subst token
    obtain ⟨values, reading, _⟩ := parsed.payload
    exact declarations_array_ready reading ready
  · rw [step_array_preserved declaration parsed]
    exact ready

theorem tokens_array_ready {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final)
    (ready : ArrayBindings.SourceReady text state.arrayNames) :
    ArrayBindings.SourceReady text final.arrayNames := by
  induction parsed with
  | done => exact ready
  | next first _ ih => exact ih (step_array_ready first ready)

theorem initial_array_ready (text : Source) : ArrayBindings.SourceReady text initialState.arrayNames := by
  simp [initialState, ArrayBindings.SourceReady, ArrayBindings.ValidEnvironment,
    ArrayBindings.ValidMetadata, ArrayBindings.ValidInitials]

end Silver.Sequence

module

public import Silver.SequenceTokens
public import Silver.ComposeScalarTrace

@[expose] public section

namespace Silver.Sequence
open Compose

private theorem step_scalar_preserved {text form token state next event}
    (ordinary : token ≠ ShellToken.declarations) (parsed : StepAt text form token state next event) :
    next.scalarNames = state.scalarNames := by
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

inductive ScalarStepAt (text : Source) (form : Compose.Form) :
    ShellToken → ParserState → List Integer.Declaration → ParserState → Prop
  | declarations {state next values} : ScalarDeclarationsAt text form.hasArguments state values next →
      ScalarStepAt text form .declarations state values next
  | other {token state next} : token ≠ ShellToken.declarations → next.scalarNames = state.scalarNames →
      ScalarStepAt text form token state [] next

theorem step_scalar_trace {text form token state next event}
    (parsed : StepAt text form token state next event) :
    ∃ values, ScalarStepAt text form token state values next := by
  by_cases declaration : token = .declarations
  · subst token
    obtain ⟨strings, reading, _⟩ := parsed.payload
    obtain ⟨values, trace⟩ := declarations_scalar_trace reading
    exact ⟨values, .declarations trace⟩
  · exact ⟨[], .other declaration (step_scalar_preserved declaration parsed)⟩

theorem scalar_step_static {text form token state next values}
    (trace : ScalarStepAt text form token state values next)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    ScalarExpression.StaticEnvironment next.scalarNames := by
  cases trace with
  | declarations reading => exact scalar_declarations_static reading static
  | other _ same => simpa only [same] using static

theorem scalar_step_checked {text form token state next values}
    (trace : ScalarStepAt text form token state values next)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    Integer.checkDeclarations (ScalarExpression.constants state.scalarNames) values =
      some (ScalarExpression.constants next.scalarNames) := by
  cases trace with
  | declarations reading => exact scalar_declarations_checked reading static
  | other _ same => simp only [Integer.checkDeclarations, same]

theorem scalar_step_unique {text form token state next left right}
    (first : ScalarStepAt text form token state left next)
    (second : ScalarStepAt text form token state right next) : left = right := by
  cases first with
  | declarations reading =>
      cases second with
      | declarations other => exact (scalar_declarations_unique reading other).1
      | other impossible _ => exact False.elim (impossible rfl)
  | other ordinary _ =>
      cases second with
      | declarations _ => exact False.elim (ordinary rfl)
      | other => rfl

inductive ScalarTokensAt (text : Source) (form : Compose.Form) :
    List ShellToken → ParserState → List Integer.Declaration → ParserState → Prop
  | done {state} : ScalarTokensAt text form [] state [] state
  | next {token tokens state middle final event first rest} :
      StepAt text form token state middle event → ScalarStepAt text form token state first middle →
      ScalarTokensAt text form tokens middle rest final →
      ScalarTokensAt text form (token :: tokens) state (first ++ rest) final

theorem tokens_scalar_trace {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final) :
    ∃ values, ScalarTokensAt text form tokens state values final := by
  induction parsed with
  | done => exact ⟨[], .done⟩
  | next head rest ih =>
      obtain ⟨first, reading⟩ := step_scalar_trace head
      obtain ⟨values, trace⟩ := ih
      exact ⟨first ++ values, .next head reading trace⟩

private theorem check_append (constants : Integer.Constants) (first rest : List Integer.Declaration) :
    Integer.checkDeclarations constants (first ++ rest) =
      (Integer.checkDeclarations constants first).bind (fun next => Integer.checkDeclarations next rest) := by
  induction first generalizing constants with
  | nil => rfl
  | cons head tail ih =>
      simp only [List.cons_append, Integer.checkDeclarations, ih, Option.bind_assoc]

theorem scalar_tokens_checked {text form tokens state values final}
    (trace : ScalarTokensAt text form tokens state values final)
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    Integer.checkDeclarations (ScalarExpression.constants state.scalarNames) values =
      some (ScalarExpression.constants final.scalarNames) ∧
      ScalarExpression.StaticEnvironment final.scalarNames := by
  induction trace with
  | done => exact ⟨rfl, static⟩
  | next head reading rest ih =>
      obtain ⟨checked, finalStatic⟩ := ih (scalar_step_static reading static)
      refine ⟨?_, finalStatic⟩
      rw [check_append, scalar_step_checked reading static]
      exact checked

theorem scalar_tokens_unique {text form tokens state left right leftState rightState}
    (first : ScalarTokensAt text form tokens state left leftState)
    (second : ScalarTokensAt text form tokens state right rightState) :
    left = right ∧ leftState = rightState := by
  induction first generalizing right rightState with
  | done => cases second; exact ⟨rfl, rfl⟩
  | next head reading rest ih =>
      cases second with
      | next other otherReading otherRest =>
          have same := head.scanned.symm.trans other.scanned
          cases same
          have values := scalar_step_unique reading otherReading
          obtain ⟨rfl, rfl⟩ := ih otherRest
          exact ⟨by rw [values], rfl⟩

end Silver.Sequence

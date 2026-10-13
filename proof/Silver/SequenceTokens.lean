module

public import Silver.SequenceAdmission

@[expose] public section

set_option backward.dsimp.instances true

/-! Finite token segments preserve the existing lexical, declaration and
expression reading relations. Unlike a whole source parse, a segment stops at
its next statement position instead of requiring end of source. -/

namespace Silver.Sequence
open Compose Bindings

inductive TokensAt (text : Source) (form : Compose.Form) :
    List ShellToken → ParserState → List Event → ParserState → Prop
  | done {state} : state.position ≠ 0 → TokensAt text form [] state [] state
  | next {token tokens state following final event rest} :
      StepAt text form token state following event →
      TokensAt text form tokens following rest final →
      TokensAt text form (token :: tokens) state (event.toList ++ rest) final

theorem tokens_positive {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final) :
    state.position ≠ 0 ∧ final.position ≠ 0 := by
  induction parsed with
  | done positive => exact ⟨positive, positive⟩
  | next head _ ih => exact ⟨head.positive, ih.2⟩

theorem step_zero (text : Source) (form : Compose.Form) (token : ShellToken)
    (state : ParserState) (zero : state.position = 0) :
    (step text form token state).position = 0 := by simp [step, zero, invalidState]

theorem scanTokens_zero (text : Source) (form : Compose.Form) (tokens : List ShellToken)
    (scan : ScanResult) (zero : scan.state.position = 0) :
    (scanTokens text form tokens scan).state.position = 0 := by
  induction tokens generalizing scan with
  | nil => exact zero
  | cons token tokens ih =>
      exact ih _ (step_zero text form token scan.state zero)

theorem tokens_sound (text : Source) (form : Compose.Form) (tokens : List ShellToken)
    (scan : ScanResult) (accepted : (scanTokens text form tokens scan).state.position ≠ 0) :
    ∃ events, TokensAt text form tokens scan.state events (scanTokens text form tokens scan).state := by
  induction tokens generalizing scan with
  | nil => exact ⟨[], .done accepted⟩
  | cons token tokens ih =>
      have positive : scan.state.position ≠ 0 := fun zero =>
        accepted (scanTokens_zero text form (token :: tokens) scan zero)
      have nextPositive : (step text form token scan.state).position ≠ 0 := fun zero =>
        accepted (scanTokens_zero text form tokens {scan with state := step text form token scan.state} zero)
      obtain ⟨event, first⟩ := step_sound text form token scan.state positive nextPositive
      obtain ⟨rest, following⟩ := ih {scan with state := step text form token scan.state} accepted
      exact ⟨event.toList ++ rest, .next first following⟩

theorem tokens_complete {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final) (scan : ScanResult)
    (same : scan.state = state) :
    (scanTokens text form tokens scan).state = final := by
  induction parsed generalizing scan with
  | done => exact same
  | next head _ ih =>
      apply ih {scan with state := step text form _ scan.state}
      simpa only [same] using head.scanned

theorem tokens_unique {text form tokens state first second left right}
    (a : TokensAt text form tokens state first left)
    (b : TokensAt text form tokens state second right) : first = second ∧ left = right := by
  induction a generalizing second right with
  | done => cases b; exact ⟨rfl, rfl⟩
  | next head _ ih =>
      cases b with
      | next other rest =>
          obtain ⟨rfl, rfl⟩ := step_unique head other
          obtain ⟨rfl, rfl⟩ := ih rest
          exact ⟨rfl, rfl⟩

theorem tokens_kinds {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final) :
    events.map Event.kind = tokens.filterMap ShellToken.eventKind := by
  induction parsed with
  | done => rfl
  | @next token tokens state following final event rest head _ ih =>
      have kind := step_kind head
      simp only [List.map_append, ih, List.filterMap_cons]
      cases event <;> simp only [Option.map, Option.toList] at kind ⊢
      all_goals rw [← kind]; rfl

theorem tokens_valid {text form tokens state events final}
    (domain : text.length ≤ maxSourceLength)
    (parsed : TokensAt text form tokens state events final) (valid : StateValid state) :
    StateValid final ∧ ∀ rest, StreamValid final.names.shape final.capacity rest →
      StreamValid state.names.shape state.capacity (events ++ rest) := by
  induction parsed with
  | done => exact ⟨valid, fun _ h => h⟩
  | next head _ ih =>
      obtain ⟨nextValid, eventValid⟩ := step_valid domain valid head
      obtain ⟨finalValid, restValid⟩ := ih nextValid
      exact ⟨finalValid, fun rest h => by simpa only [List.append_assoc] using eventValid _ (restValid rest h)⟩

def ShapeToken : ShellToken → Prop
  | .declarations | .argumentDeclaration | .capacity => False
  | _ => True

theorem step_shape {text form token state next event}
    (ordinary : ShapeToken token) (parsed : StepAt text form token state next event) :
    next.names = state.names ∧ next.capacity = state.capacity := by
  have accepted := parsed.following
  rw [← parsed.scanned] at accepted ⊢
  cases token <;> simp only [ShapeToken] at ordinary
  all_goals try contradiction
  all_goals simp only [step, parsed.positive, ↓reduceIte] at accepted ⊢
  all_goals first
    | trivial
    | exact ⟨rfl, rfl⟩
    | (simp only [targetAt, dynamicAt, assignmentAt, outputAt, comparisonAt] at accepted ⊢
       split <;> simp_all [invalidState] <;> split <;> simp_all)

theorem tokens_shape {text form tokens state events final}
    (ordinary : ∀ token ∈ tokens, ShapeToken token)
    (parsed : TokensAt text form tokens state events final) :
    final.names = state.names ∧ final.capacity = state.capacity := by
  induction parsed with
  | done => exact ⟨rfl, rfl⟩
  | next head _ ih =>
      have first := step_shape (ordinary _ (by simp)) head
      have rest := ih (fun token member => ordinary token (by simp [member]))
      exact ⟨rest.1.trans first.1, rest.2.trans first.2⟩

end Silver.Sequence

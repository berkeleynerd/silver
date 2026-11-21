module

public import Silver.SequenceArrayReady
public import Silver.ComposeInitializerTrace

@[expose] public section

namespace Silver.Sequence
open Compose

inductive InitializerStepAt (text : Source) (form : Compose.Form) :
    ShellToken → ParserState → List Integer.Obligation → ParserState → Prop
  | declarations {state next checks} : InitializerChecksAt text form.hasArguments state checks next →
      InitializerStepAt text form .declarations state checks next
  | other {token state next} : token ≠ ShellToken.declarations →
      InitializerStepAt text form token state [] next

theorem step_initializer_trace {text form token state next event}
    (parsed : StepAt text form token state next event) :
    ∃ checks, InitializerStepAt text form token state checks next := by
  by_cases declaration : token = .declarations
  · subst token
    obtain ⟨strings, reading, _⟩ := parsed.payload
    obtain ⟨checks, trace⟩ := declarations_image_trace reading
    exact ⟨checks, .declarations trace⟩
  · exact ⟨[], .other declaration⟩

theorem initializer_step_discharge {text form token state next checks}
    (trace : InitializerStepAt text form token state checks next)
    (normal : NamesNormal state.names)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) : Integer.discharged checks = true := by
  cases trace with
  | declarations reading => exact initializer_checks_discharge normal reading subtypes arrays
  | other => rfl

theorem initializer_step_unique {text form token state next left right}
    (first : InitializerStepAt text form token state left next)
    (second : InitializerStepAt text form token state right next) : left = right := by
  cases first with
  | declarations reading =>
      cases second with
      | declarations other => exact (initializer_trace_unique reading other).1
      | other impossible => exact False.elim (impossible rfl)
  | other ordinary =>
      cases second with
      | declarations => exact False.elim (ordinary rfl)
      | other => rfl

inductive InitializerTokensAt (text : Source) (form : Compose.Form) :
    List ShellToken → ParserState → List Integer.Obligation → ParserState → Prop
  | done {state} : InitializerTokensAt text form [] state [] state
  | next {token tokens state middle final event first rest} :
      StepAt text form token state middle event → InitializerStepAt text form token state first middle →
      InitializerTokensAt text form tokens middle rest final →
      InitializerTokensAt text form (token :: tokens) state (first ++ rest) final

theorem tokens_initializer_trace {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final) :
    ∃ checks, InitializerTokensAt text form tokens state checks final := by
  induction parsed with
  | done => exact ⟨[], .done⟩
  | next head _ ih =>
      obtain ⟨first, step⟩ := step_initializer_trace head
      obtain ⟨rest, following⟩ := ih
      exact ⟨first ++ rest, .next head step following⟩

theorem initializer_tokens_discharge {text form tokens state checks final}
    (domain : text.length ≤ maxSourceLength)
    (trace : InitializerTokensAt text form tokens state checks final) (valid : StateValid state)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) :
    Integer.discharged checks = true := by
  induction trace with
  | done => rfl
  | next parsed first rest ih =>
      rw [Integer.discharged_append, initializer_step_discharge first valid.1 subtypes arrays,
        ih (step_valid domain valid parsed).1 (step_subtypes_valid parsed subtypes)
          (step_array_types_valid parsed arrays subtypes)]
      rfl

theorem initializer_tokens_valid {text form tokens state checks final}
    (domain : text.length ≤ maxSourceLength)
    (trace : InitializerTokensAt text form tokens state checks final) (valid : StateValid state)
    (subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames)
    (arrays : ArrayBindings.ValidTypes text state.arrayNames.types) :
    ∀ check ∈ checks, check.Valid := by
  have all := List.all_eq_true.mp (initializer_tokens_discharge domain trace valid subtypes arrays)
  exact fun check member => Integer.Obligation.discharge_sound (all check member)

theorem initializer_tokens_unique {text form tokens state left right final}
    (first : InitializerTokensAt text form tokens state left final)
    (second : InitializerTokensAt text form tokens state right final) : left = right := by
  induction first generalizing right with
  | done => cases second; rfl
  | next head first rest ih =>
      cases second with
      | next other otherFirst otherRest =>
          obtain ⟨rfl, _⟩ := step_unique head other
          rw [initializer_step_unique first otherFirst, ih otherRest]

end Silver.Sequence

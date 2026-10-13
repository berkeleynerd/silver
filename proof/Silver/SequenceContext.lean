module

public import Silver.SequenceTokens

@[expose] public section

namespace Silver.Sequence
open Compose Bindings

def eventContext (context : Shape × Nat) : Event → Shape × Nat
  | .declarations _ names => (names.shape, context.2)
  | .argument _ => (argumentShape, context.2)
  | .capacity bound => (context.1, bound)
  | _ => context

def eventsContext (context : Shape × Nat) (events : List Event) : Shape × Nat :=
  events.foldl eventContext context

theorem step_context {text form token state next event}
    (parsed : StepAt text form token state next event) :
    eventsContext (state.names.shape, state.capacity) event.toList =
      (next.names.shape, next.capacity) := by
  have payload := parsed.payload
  have following := parsed.following
  cases token with
  | declarations =>
      obtain ⟨values, reading, rfl⟩ := payload
      have fields := declarations_fields reading
      simp [eventsContext, eventContext, fields.1]
  | argumentDeclaration =>
      obtain ⟨fallback, reading, rfl⟩ := payload
      have shape := argument_shape reading
      have fields := argument_fields reading
      simp [eventsContext, eventContext, fields.1, shape.2.1]
  | capacity =>
      change event = some (.capacity next.capacity) at payload
      subst event
      rw [← parsed.scanned] at following ⊢
      simp only [step, parsed.positive, ↓reduceIte, capacityAt] at following ⊢
      split <;> simp_all [invalidState, eventsContext, eventContext]
  | fixed | assignmentTarget | targetReference | dynamicReference =>
      have shape := step_shape (by trivial) parsed
      change event = none at payload
      subst event
      simp [eventsContext, shape.1, shape.2]
  | literal =>
      obtain ⟨bytes, _, rfl⟩ := payload
      have shape := step_shape (by trivial) parsed
      simp [eventsContext, eventContext, shape.1, shape.2]
  | assignmentValue =>
      obtain ⟨value, _, rfl⟩ := payload
      have shape := step_shape (by trivial) parsed
      simp [eventsContext, eventContext, shape.1, shape.2]
  | outputExpression =>
      obtain ⟨value, _, rfl⟩ := payload
      have shape := step_shape (by trivial) parsed
      simp [eventsContext, eventContext, shape.1, shape.2]
  | comparisonExpression =>
      obtain ⟨left, right, _, _, rfl⟩ := payload
      have shape := step_shape (by trivial) parsed
      simp [eventsContext, eventContext, shape.1, shape.2]

theorem tokens_context {text form tokens state events final}
    (parsed : TokensAt text form tokens state events final) :
    eventsContext (state.names.shape, state.capacity) events =
      (final.names.shape, final.capacity) := by
  induction parsed with
  | done => rfl
  | @next token tokens state following final event rest head _ ih =>
      simp only [eventsContext, List.foldl_append]
      change eventsContext (eventsContext (state.names.shape, state.capacity) _) _ = _
      rw [step_context head]
      exact ih

end Silver.Sequence

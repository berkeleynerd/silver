module

public import Silver.SequenceContext
public import Silver.ComposeDecode

@[expose] public section

namespace Silver.Sequence
open Compose Bindings

def decodePrefix (form : Form) (events : List Event) (items : List Statement) : Option Program :=
  match form, events with
  | .direct, [.declarations values names] => some ⟨values, names, [], ⟨.static, items⟩⟩
  | .argument, [.argument fallback, .declarations values names] =>
      some ⟨argumentDeclaration :: values, names, fallback, ⟨.argument, items⟩⟩
  | .guardedArgument, [.argument fallback, .declarations values names, .capacity bound] =>
      some ⟨argumentDeclaration :: values, names, fallback, ⟨.guardedArgument bound, items⟩⟩
  | _, _ => none

theorem prefix_decoded_valid (form : Form) (events : List Event) (items : List Statement)
    (shape : events.map Event.kind = form.prefix.filterMap ShellToken.eventKind)
    (stream : StreamValid emptyShape maxSourceLength events)
    (nonempty : items ≠ [])
    (body : StatementsValid (eventsContext (emptyShape, maxSourceLength) events).1
      (eventsContext (emptyShape, maxSourceLength) events).2 items) :
    ∃ program, decodePrefix form events items = some program ∧ program.Valid := by
  cases form with
  | direct =>
      change events.map Event.kind = [.declarations] at shape
      obtain ⟨values, names, rest, rfl, shape0⟩ := (declarations_event_shape _ _).mp shape
      have empty := List.map_eq_nil_iff.mp shape0
      subst rest
      refine ⟨⟨values, names, [], ⟨.static, items⟩⟩, rfl, ?_⟩
      exact ⟨stream.1, by simp [Bindings.Printable], by simp [maxSourceLength],
        Nat.le_refl _, nonempty, body⟩
  | argument =>
      change events.map Event.kind = [.argument, .declarations] at shape
      obtain ⟨fallback, rest, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨values, names, rest, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      have empty := List.map_eq_nil_iff.mp shape1
      subst rest
      refine ⟨⟨argumentDeclaration :: values, names, fallback, ⟨.argument, items⟩⟩, rfl, ?_⟩
      exact ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1,
        Nat.le_refl _, nonempty, body⟩
  | guardedArgument =>
      change events.map Event.kind = [.argument, .declarations, .capacity] at shape
      obtain ⟨fallback, rest, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨values, names, rest, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      obtain ⟨bound, rest, rfl, shape2⟩ := (capacity_event_shape _ _).mp shape1
      have empty := List.map_eq_nil_iff.mp shape2
      subst rest
      refine ⟨⟨argumentDeclaration :: values, names, fallback, ⟨.guardedArgument bound, items⟩⟩, rfl, ?_⟩
      exact ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1,
        stream.2.2.2.1, nonempty, body⟩

end Silver.Sequence

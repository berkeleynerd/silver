module

public import Silver.PredicateBodyAdmission
public import Silver.ComposeDecode
public import Silver.SequenceContext

@[expose] public section

/-! Decoding the shared header keeps ordered String and Integer declaration
traces separately. The static scalar certificate is checked before the body;
body obligations use exactly the resulting immutable constant ranges. -/
namespace Silver.Predicate
open Compose Bindings PathFacts

def decodePrefix (form : Form) (events : List Event) (items : List SourceStatement)
    (integerDeclarations : List Integer.Declaration := [])
    (integerConstants : Integer.Constants := []) : Option Program :=
  match form, events with
  | .direct, [.declarations values names] => some ⟨values, names, [], false, lowerStatements items, integerDeclarations, integerConstants⟩
  | .argument, [.argument fallback, .declarations values names] =>
      some ⟨argumentDeclaration :: values, names, fallback, true, lowerStatements items, integerDeclarations, integerConstants⟩
  | _, _ => none

theorem prefix_decoded_valid (form : Form) (events : List Event) (items : List SourceStatement)
    (integerDeclarations : List Integer.Declaration) (integerConstants : Integer.Constants)
    (shape : events.map Event.kind = form.prefix.filterMap ShellToken.eventKind)
    (stream : StreamValid emptyShape maxSourceLength events)
    (nonempty : items ≠ [])
    (body : SourceStatementsWellFormed form.hasArguments
      (Sequence.eventsContext (emptyShape, maxSourceLength) events).1 items)
    (checked : ∃ after, checkStatements (Sequence.eventsContext (emptyShape, maxSourceLength) events).1
      (initialFacts form.hasArguments) (lowerStatements items) integerConstants.ranges = some after ∧ completed after = true)
    (scalars : Integer.checkDeclarations [] integerDeclarations = some integerConstants) :
    ∃ program, decodePrefix form events items integerDeclarations integerConstants = some program ∧ program.Valid := by
  cases form with
  | direct =>
      change events.map Event.kind = [.declarations] at shape
      obtain ⟨values, names, rest, rfl, shape0⟩ := (declarations_event_shape _ _).mp shape
      have empty := List.map_eq_nil_iff.mp shape0
      subst rest
      refine ⟨⟨values, names, [], false, lowerStatements items, integerDeclarations, integerConstants⟩, rfl, ?_⟩
      refine ⟨stream.1, by simp [Bindings.Printable], by simp [maxSourceLength],
        lowerStatements_nonempty nonempty, lowerStatements_wellFormed body, ?_⟩
      obtain ⟨after, bodyChecked, completed⟩ := checked
      exact ⟨after, (Program.checkBody_iff _ after).mpr ⟨scalars, bodyChecked⟩, completed⟩
  | argument =>
      change events.map Event.kind = [.argument, .declarations] at shape
      obtain ⟨fallback, rest, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨values, names, rest, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      have empty := List.map_eq_nil_iff.mp shape1
      subst rest
      refine ⟨⟨argumentDeclaration :: values, names, fallback, true, lowerStatements items, integerDeclarations, integerConstants⟩, rfl, ?_⟩
      refine ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1,
        lowerStatements_nonempty nonempty, lowerStatements_wellFormed body, ?_⟩
      obtain ⟨after, bodyChecked, completed⟩ := checked
      exact ⟨after, (Program.checkBody_iff _ after).mpr ⟨scalars, bodyChecked⟩, completed⟩


end Silver.Predicate

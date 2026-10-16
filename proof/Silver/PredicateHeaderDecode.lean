module

public import Silver.PredicateBodyAdmission
public import Silver.ComposeDecode
public import Silver.SequenceContext

@[expose] public section

/-! Decoding the shared header retains ordered String and Integer declarations
and the raw Image initializer schemas. Both scalar certificates are checked
before the body, whose obligations use the resulting immutable ranges. -/
namespace Silver.Predicate
open Compose Bindings PathFacts

def decodePrefix (form : Form) (events : List Event) (items : List SourceStatement)
    (integerDeclarations : List Integer.Declaration := [])
    (integerConstants : Integer.Constants := [])
    (initializerChecks : List Integer.Obligation := []) : Option Program :=
  match form, events with
  | .direct, [.declarations values names] => some ⟨values, names, [], false, lowerStatements items, integerDeclarations, integerConstants, initializerChecks⟩
  | .argument, [.argument fallback, .declarations values names] =>
      some ⟨argumentDeclaration :: values, names, fallback, true, lowerStatements items, integerDeclarations, integerConstants, initializerChecks⟩
  | _, _ => none

theorem prefix_decoded_valid (form : Form) (events : List Event) (items : List SourceStatement)
    (integerDeclarations : List Integer.Declaration) (integerConstants : Integer.Constants)
    (initializerChecks : List Integer.Obligation)
    (shape : events.map Event.kind = form.prefix.filterMap ShellToken.eventKind)
    (stream : StreamValid emptyShape maxSourceLength events)
    (nonempty : items ≠ [])
    (body : SourceStatementsWellFormed form.hasArguments
      (Sequence.eventsContext (emptyShape, maxSourceLength) events).1 items)
    (checked : ∃ after, checkStatements (Sequence.eventsContext (emptyShape, maxSourceLength) events).1
      (initialFacts form.hasArguments) (lowerStatements items) integerConstants.ranges = some after ∧ completed after = true)
    (scalars : Integer.checkDeclarations [] integerDeclarations = some integerConstants)
    (initializers : Integer.discharged initializerChecks = true) :
    ∃ program, decodePrefix form events items integerDeclarations integerConstants initializerChecks = some program ∧ program.Valid := by
  cases form with
  | direct =>
      change events.map Event.kind = [.declarations] at shape
      obtain ⟨values, names, rest, rfl, shape0⟩ := (declarations_event_shape _ _).mp shape
      have empty := List.map_eq_nil_iff.mp shape0
      subst rest
      refine ⟨⟨values, names, [], false, lowerStatements items, integerDeclarations, integerConstants, initializerChecks⟩, rfl, ?_⟩
      refine ⟨stream.1, by simp [Bindings.Printable], by simp [maxSourceLength],
        lowerStatements_nonempty nonempty, lowerStatements_wellFormed body, ?_⟩
      obtain ⟨after, bodyChecked, completed⟩ := checked
      exact ⟨after, (Program.checkBody_iff _ after).mpr ⟨scalars, initializers, bodyChecked⟩, completed⟩
  | argument =>
      change events.map Event.kind = [.argument, .declarations] at shape
      obtain ⟨fallback, rest, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨values, names, rest, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      have empty := List.map_eq_nil_iff.mp shape1
      subst rest
      refine ⟨⟨argumentDeclaration :: values, names, fallback, true, lowerStatements items, integerDeclarations, integerConstants, initializerChecks⟩, rfl, ?_⟩
      refine ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1,
        lowerStatements_nonempty nonempty, lowerStatements_wellFormed body, ?_⟩
      obtain ⟨after, bodyChecked, completed⟩ := checked
      exact ⟨after, (Program.checkBody_iff _ after).mpr ⟨scalars, initializers, bodyChecked⟩, completed⟩


theorem decoded_initializer_checks {form events items scalars constants checks program}
    (decoded : decodePrefix form events items scalars constants checks = some program) :
    program.initializerChecks = checks := by
  unfold decodePrefix at decoded
  split at decoded <;> cases decoded <;> rfl

end Silver.Predicate

import Silver.GuardedAdmission
import Silver.NamedSemantics
import Silver.ArgumentsRuntime

namespace Silver.Guarded

open Named

inductive Bindings : Option Source → List Event → Prop
  | done (name : Option Source) : Bindings name []
  | declaration {before : Option Source} {name : Source} {events : List Event} :
      Bindings (some name) events → Bindings before (.declaration name :: events)
  | literal {name : Option Source} {value : Source} {decorated : Bool} {events : List Event} :
      Bindings name events → Bindings name (.literal value decorated :: events)
  | reference {bound : Option Source} {name : Source} {events : List Event} :
      bound = some name → Bindings bound events → Bindings bound (.reference name :: events)
  | capacity {name : Option Source} {value : Nat} {events : List Event} :
      Bindings name events → Bindings name (.capacity value :: events)

theorem parsed_bindings {text : Source} {tokens : List Token} {index position capacity decorations : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens index position state capacity decorations events)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) (valid : state.Valid text) :
    Bindings (state.meaning text) events := by
  induction parsed with
  | done => exact .done _
  | @fixed index position capacity decorations state token tokens events declaration reference cap literal matched rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have tokenBound := matched
      simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at tokenBound
      exact ih (by omega) (by omega) valid
  | @declaration index position finish capacity decorations state name tokens events nameParsed allowed rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := identifier_bounds nameParsed
      have startPositive : 1 ≤ Cursor.triviaPosition text position := by omega
      have nameValue : name.map lowercase = canonicalName text (Cursor.triviaPosition text position) finish := by
        rw [identifier_span nameParsed startPositive]
        rfl
      have nextValid : (⟨Cursor.triviaPosition text position, finish⟩ : NameState).Valid text := by
        right
        exact ⟨startPositive, bounds.2.2.1, bounds.2.2.2⟩
      have next := ih (by omega) bounds.2.2.2 nextValid
      apply Bindings.declaration
      simpa [NameState.meaning, Nat.ne_of_gt startPositive, ← nameValue] using next
  | @reference index position finish capacity decorations state name tokens events present nameParsed same rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := identifier_bounds nameParsed
      have startPositive : 1 ≤ Cursor.triviaPosition text position := by omega
      have prior : state.first < state.after ∧ state.after ≤ text.length + 1 := by
        rcases valid with empty | stored
        · omega
        · exact stored.2
      have nameValue : name.map lowercase = canonicalName text (Cursor.triviaPosition text position) finish := by
        rw [identifier_span nameParsed startPositive]
        rfl
      have sameNames := (equalName_iff text state.first state.after _ finish present
        (Nat.le_of_lt prior.1) prior.2 startPositive (Nat.le_of_lt bounds.2.2.1) bounds.2.2.2).mp same
      apply Bindings.reference _ (ih (by omega) bounds.2.2.2 valid)
      simp [NameState.meaning, Nat.ne_of_gt present, sameNames, nameValue]
  | @capacity index position finish capacity decorations value state tokens events decimal rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := decimalAt_bounds decimal
      exact .capacity (ih (by omega) bounds.2.1 valid)
  | @literal index position finish capacity decorations state value tokens events first opening literal enough rest ih =>
      have bounds := Output.literalAt_bounds literal
      exact .literal (ih (by omega) bounds.2.1 valid)

def literalBytes : List Event → Nat
  | [] => 0
  | .literal value _ :: events => value.length + literalBytes events
  | _ :: events => literalBytes events

theorem parsed_literal_consumption {text : Source} {tokens : List Token} {index position capacity decorations : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens index position state capacity decorations events)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) :
    position + literalBytes events ≤ text.length + 1 := by
  induction parsed with
  | done => simpa [literalBytes] using bounded
  | @fixed index position capacity decorations state token tokens events _ _ _ _ matched rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have tokenBound := matched
      simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at tokenBound
      have remaining := ih (by omega) (by omega)
      omega
  | @declaration index position finish capacity decorations state name tokens events nameParsed allowed rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := identifier_bounds nameParsed
      have remaining := ih (by omega) bounds.2.2.2
      simpa only [literalBytes] using (show position + literalBytes events ≤ text.length + 1 by omega)
  | @reference index position finish capacity decorations state name tokens events present nameParsed same rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := identifier_bounds nameParsed
      have remaining := ih (by omega) bounds.2.2.2
      simpa only [literalBytes] using (show position + literalBytes events ≤ text.length + 1 by omega)
  | @capacity index position finish capacity decorations value state tokens events decimal rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := decimalAt_bounds decimal
      have remaining := ih (by omega) bounds.2.1
      simpa only [literalBytes] using (show position + literalBytes events ≤ text.length + 1 by omega)
  | @literal index position finish capacity decorations state value tokens events first opening literal enough rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := Output.literalAt_bounds literal
      have remaining := ih (by omega) bounds.2.1
      simp only [literalBytes]
      omega

theorem parsed_literals {text : Source} {tokens : List Token} {index position capacity decorations : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens index position state capacity decorations events) :
    ∀ value decorated, Event.literal value decorated ∈ events → value.length ≤ text.length ∧
      ∀ byte ∈ value, Output.printable byte = true := by
  induction parsed with
  | done => simp
  | fixed _ _ _ _ _ _ ih => exact ih
  | declaration _ _ _ ih => simpa using ih
  | reference _ _ _ _ ih => simpa using ih
  | capacity _ _ ih => simpa using ih
  | literal bound opening value enough previous ih =>
      intro bytes decorated member
      simp only [List.mem_cons, Event.literal.injEq] at member
      rcases member with ⟨rfl, rfl⟩ | member
      · have facts := Output.literalAt_bounds value
        exact ⟨by omega, facts.2.2⟩
      · exact ih _ _ member

/-- Arithmetic state follows decoded events; the accepted decimal is bound to
the two actual decoration spans by the final equality. -/
def finalCapacity : List Event → Nat → Nat → Nat
  | [], capacity, decorations => capacity + decorations
  | .capacity value :: events, _, decorations => finalCapacity events value decorations
  | .literal value true :: events, capacity, decorations => finalCapacity events capacity (decorations + value.length)
  | _ :: events, capacity, decorations => finalCapacity events capacity decorations

theorem parsed_capacity {text : Source} {tokens : List Token} {index position capacity decorations : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens index position state capacity decorations events) :
    finalCapacity events capacity decorations = maxSourceLength := by
  induction parsed with
  | done _ total => exact total
  | fixed _ _ _ _ _ _ ih => exact ih
  | declaration _ _ _ ih => exact ih
  | reference _ _ _ _ ih => exact ih
  | capacity _ _ ih => exact ih
  | @literal index position finish capacity decorations state value tokens events _ _ _ _ _ ih =>
      by_cases decorated : index > 39 <;> simpa [finalCapacity, decorated] using ih

structure Program where
  declared : Source
  defaultValue : Source
  guardReference : Source
  capacity : Nat
  leading : Source
  reference : Source
  trailing : Source
  deriving DecidableEq, Repr

def Program.events (program : Program) : List Event :=
  [.declaration program.declared, .literal program.defaultValue false, .reference program.guardReference,
   .capacity program.capacity, .literal program.leading true, .reference program.reference,
   .literal program.trailing true]

def SourceMeaning (source : Source) (program : Program) : Prop :=
  Member source ∧ Parsed source requiredTokens 1 1 {} 0 0 program.events

def EventKind.Payload : EventKind → Type
  | .capacity => Nat
  | _ => Source

def EventKind.event : (kind : EventKind) → kind.Payload → Event
  | .declaration, value => .declaration value
  | .initial, value => .literal value false
  | .decoration, value => .literal value true
  | .reference, value => .reference value
  | .capacity, value => .capacity value

theorem event_fiber {event : Event} {kind : EventKind} (same : event.kind = kind) :
    ∃ value, event = kind.event value := by
  cases event with
  | declaration name => subst kind; exact ⟨name, rfl⟩
  | reference name => subst kind; exact ⟨name, rfl⟩
  | capacity value => subst kind; exact ⟨value, rfl⟩
  | literal value decorated => cases decorated <;> subst kind <;> exact ⟨value, rfl⟩

theorem event_shape {events : List Event}
    (kinds : events.map Event.kind = [.declaration, .initial, .reference, .capacity, .decoration, .reference, .decoration]) :
    ∃ program : Program, events = program.events := by
  obtain ⟨a, rest1, rfl, ak, kinds1⟩ := List.map_eq_cons_iff.mp kinds
  obtain ⟨declared, rfl⟩ := event_fiber ak
  obtain ⟨b, rest2, rfl, bk, kinds2⟩ := List.map_eq_cons_iff.mp kinds1
  obtain ⟨initial, rfl⟩ := event_fiber bk
  obtain ⟨c, rest3, rfl, ck, kinds3⟩ := List.map_eq_cons_iff.mp kinds2
  obtain ⟨guardRef, rfl⟩ := event_fiber ck
  obtain ⟨d, rest4, rfl, dk, kinds4⟩ := List.map_eq_cons_iff.mp kinds3
  obtain ⟨capacity, rfl⟩ := event_fiber dk
  obtain ⟨e, rest5, rfl, ek, kinds5⟩ := List.map_eq_cons_iff.mp kinds4
  obtain ⟨leading, rfl⟩ := event_fiber ek
  obtain ⟨f, rest6, rfl, fk, kinds6⟩ := List.map_eq_cons_iff.mp kinds5
  obtain ⟨reference, rfl⟩ := event_fiber fk
  obtain ⟨g, rest7, rfl, gk, kinds7⟩ := List.map_eq_cons_iff.mp kinds6
  obtain ⟨trailing, rfl⟩ := event_fiber gk
  have empty : rest7 = [] := List.map_eq_nil_iff.mp kinds7
  subst rest7
  exact ⟨⟨declared, initial, guardRef, capacity, leading, reference, trailing⟩, rfl⟩

theorem member_has_meaning {source : Source} (member : Member source) : ∃ program, SourceMeaning source program := by
  obtain ⟨events, parsed⟩ := member.2.2.2
  obtain ⟨program, rfl⟩ := event_shape (parsed_eventKinds parsed)
  exact ⟨program, member, parsed⟩

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  have same := parsed_unique first.2 second.2
  cases left
  cases right
  simpa [Program.events, List.cons.injEq, Event.declaration.injEq, Event.literal.injEq,
    Event.reference.injEq, Event.capacity.injEq, Program.mk.injEq] using same

theorem meaning_binds {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.declared = program.guardReference ∧ program.declared = program.reference := by
  have bindings := parsed_bindings meaning.2 (by omega) (by omega) (Or.inl ⟨rfl, rfl⟩)
  cases bindings with
  | declaration rest =>
    cases rest with
    | literal rest =>
      cases rest with
      | reference guardSame rest =>
        cases rest with
        | capacity rest =>
          cases rest with
          | literal rest =>
            cases rest with
            | reference outputSame rest => exact ⟨Option.some.inj guardSame, Option.some.inj outputSame⟩

theorem literal_bounds {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.defaultValue.length + program.leading.length + program.trailing.length ≤ source.length := by
  have consumed := parsed_literal_consumption meaning.2 (by omega) (by omega)
  simp only [Program.events, literalBytes] at consumed
  omega

theorem capacity_exact {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.capacity + program.leading.length + program.trailing.length = maxSourceLength := by
  have total := parsed_capacity meaning.2
  simpa [Program.events, finalCapacity, Nat.add_assoc] using total

theorem default_domain {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.defaultValue.length ≤ maxSourceLength ∧
    ∀ byte ∈ program.defaultValue, Output.printable byte = true := by
  have facts := parsed_literals meaning.2 program.defaultValue false (by simp [Program.events])
  exact ⟨Nat.le_trans facts.1 meaning.1.2.1, facts.2⟩

theorem default_fits_capacity {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.defaultValue.length ≤ program.capacity := by
  have consumed := literal_bounds meaning
  have exactCapacity := capacity_exact meaning
  have bounded := meaning.1.2.1
  omega

theorem default_is_message {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    Arguments.Runtime.message program.defaultValue = true := by
  apply (Arguments.Runtime.message_iff _).mpr
  obtain ⟨length, bytes⟩ := default_domain meaning
  refine ⟨length, ?_⟩
  intro byte member
  simpa [Output.printable] using bytes byte member

def selected (arguments : Arguments.Runtime.Arguments) (program : Program) : Source :=
  Arguments.Runtime.firstOrDefault program.defaultValue arguments

def guard (arguments : Arguments.Runtime.Arguments) (program : Program) : Bool :=
  Arguments.Runtime.inputIsValid arguments && decide ((selected arguments program).length ≤ program.capacity)

def decorated (arguments : Arguments.Runtime.Arguments) (program : Program) : Source :=
  (program.leading ++ selected arguments program) ++ program.trailing

theorem output_domain {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (arguments : Arguments.Runtime.Arguments) (permitted : guard arguments program = true) :
    (decorated arguments program).length ≤ maxSourceLength ∧
    ∀ byte ∈ decorated arguments program, Output.printable byte = true := by
  have exactCapacity := capacity_exact meaning
  have fits := permitted
  simp only [guard, Bool.and_eq_true, decide_eq_true_eq] at fits
  refine ⟨?_, ?_⟩
  · simp only [decorated, List.length_append]
    omega
  · intro byte member
    simp only [decorated, List.mem_append] at member
    rcases member with (leading | argument) | trailing
    · exact (parsed_literals meaning.2 program.leading true (by simp [Program.events])).2 byte leading
    · have domain := Arguments.Runtime.initializer_domain arguments program.defaultValue
      have bytes := (Arguments.Runtime.message_iff _).mp domain
      simpa [Output.printable] using bytes.2 byte argument
    · exact (parsed_literals meaning.2 program.trailing true (by simp [Program.events])).2 byte trailing

end Silver.Guarded

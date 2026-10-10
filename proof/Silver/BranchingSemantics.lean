import Silver.BranchingAdmission
import Silver.ArgumentsRuntime
import Silver.NamedSemantics

namespace Silver.Branching

open Named

theorem parsed_bindings {text : Source} {tokens : List Token} {position : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens position state events)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) (valid : state.Valid text) :
    Bindings (state.meaning text) events := by
  induction parsed with
  | done => exact .done _
  | @fixed position state token tokens events declaration reference literal matched rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have tokenBound := matched
      simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at tokenBound
      exact ih (by omega) (by omega) valid
  | @declaration position finish state name tokens events nameParsed allowed rest ih =>
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
  | @reference position finish state name tokens events present nameParsed same rest ih =>
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
  | @literal position finish state value tokens events first opening literal rest ih =>
      have bounds := Output.literalAt_bounds literal
      exact .literal (ih (by omega) bounds.2.1 valid)

theorem parsed_literals {text : Source} {tokens : List Token} {position : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens position state events) :
    ∀ value, Event.literal value ∈ events → value.length ≤ text.length ∧
      ∀ byte ∈ value, Output.printable byte = true := by
  induction parsed with
  | done => simp
  | fixed _ _ _ _ _ ih => exact ih
  | declaration _ _ _ ih => simpa using ih
  | reference _ _ _ _ ih => simpa using ih
  | literal bound opening value previous ih =>
      intro bytes member
      simp only [List.mem_cons, Event.literal.injEq] at member
      rcases member with rfl | member
      · have facts := Output.literalAt_bounds value
        exact ⟨by omega, facts.2.2⟩
      · exact ih _ member

/-- Source payloads retain all four distinct literal occurrences in order. -/
structure Program where
  declared : Source
  defaultValue : Source
  reference : Source
  comparison : Source
  yesOutput : Source
  noOutput : Source
  deriving DecidableEq, Repr

def Program.events (program : Program) : List Event :=
  [.declaration program.declared, .literal program.defaultValue, .reference program.reference,
   .literal program.comparison, .literal program.yesOutput, .literal program.noOutput]

def SourceMeaning (source : Source) (program : Program) : Prop :=
  Member source ∧ Parsed source requiredTokens 1 {} program.events

theorem event_shape {events : List Event}
    (kinds : events.map Event.kind = [.declaration, .literal, .reference, .literal, .literal, .literal]) :
    ∃ declared fallback reference comparison yesOutput noOutput,
      events = [.declaration declared, .literal fallback, .reference reference,
        .literal comparison, .literal yesOutput, .literal noOutput] := by
  cases events with
  | nil => simp at kinds
  | cons first rest0 =>
    cases rest0 with
    | nil => simp at kinds
    | cons second rest1 =>
      cases rest1 with
      | nil => simp at kinds
      | cons third rest2 =>
        cases rest2 with
        | nil => simp at kinds
        | cons fourth rest3 =>
          cases rest3 with
          | nil => simp at kinds
          | cons fifth rest4 =>
            cases rest4 with
            | nil => simp at kinds
            | cons sixth rest5 =>
              have empty : rest5 = [] := by
                have lengths := congrArg List.length kinds
                simpa using lengths
              subst rest5
              cases first <;> cases second <;> cases third <;> cases fourth <;> cases fifth <;> cases sixth <;> simp_all [Event.kind]

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ program, SourceMeaning source program := by
  obtain ⟨events, parsed⟩ := member.2.2.2
  have shape := parsed_eventKinds parsed
  have kinds : events.map Event.kind = [.declaration, .literal, .reference, .literal, .literal, .literal] := shape
  obtain ⟨declared, fallback, reference, comparison, yesOutput, noOutput, rfl⟩ := event_shape kinds
  exact ⟨⟨declared, fallback, reference, comparison, yesOutput, noOutput⟩, member, parsed⟩

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  have same := parsed_unique first.2 second.2
  cases left
  cases right
  simpa [Program.events, List.cons.injEq, Event.declaration.injEq, Event.literal.injEq, Event.reference.injEq,
    Program.mk.injEq] using same

theorem meaning_binds {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.declared = program.reference := by
  have bindings := parsed_bindings meaning.2 (by omega) (by omega) (Or.inl ⟨rfl, rfl⟩)
  cases bindings with
  | declaration rest =>
    cases rest with
    | literal rest =>
      cases rest with
      | reference same _ => exact Option.some.inj same

theorem literal_domain {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (value : Source) (present : Event.literal value ∈ program.events) :
    value.length ≤ maxSourceLength ∧ ∀ byte ∈ value, Output.printable byte = true := by
  have facts := parsed_literals meaning.2 value present
  exact ⟨Nat.le_trans facts.1 meaning.1.2.1, facts.2⟩

theorem default_domain {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.defaultValue.length ≤ maxSourceLength ∧
      ∀ byte ∈ program.defaultValue, Output.printable byte = true :=
  literal_domain meaning _ (by simp [Program.events])

theorem default_is_message {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    Arguments.Runtime.message program.defaultValue = true := by
  apply (Arguments.Runtime.message_iff _).mpr
  obtain ⟨length, bytes⟩ := default_domain meaning
  refine ⟨length, ?_⟩
  intro byte member
  simpa [Output.printable] using bytes byte member

/-- Predefined String equality compares element values, including lengths;
identifier canonicalization is deliberately absent from this operation. -/
def choose (program : Program) (value : Source) : Source :=
  if value = program.comparison then program.yesOutput else program.noOutput

def selected (arguments : Arguments.Runtime.Arguments) (program : Program) : Source :=
  Arguments.Runtime.firstOrDefault program.defaultValue arguments

def selectedOutput (arguments : Arguments.Runtime.Arguments) (program : Program) : Source :=
  choose program (selected arguments program)

theorem output_domain {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (arguments : Arguments.Runtime.Arguments) :
    (selectedOutput arguments program).length ≤ maxSourceLength ∧
      ∀ byte ∈ selectedOutput arguments program, Output.printable byte = true := by
  unfold selectedOutput choose
  split <;> exact literal_domain meaning _ (by simp [Program.events])

theorem unequal_lengths_choose_no (program : Program) (value : Source)
    (different : value.length ≠ program.comparison.length) : choose program value = program.noOutput := by
  have unequal : value ≠ program.comparison := fun same => different (congrArg List.length same)
  simp [choose, unequal]

end Silver.Branching

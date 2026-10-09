import Silver.NamedAdmission
import Silver.OutputRuntime

namespace Silver.Named

def NameState.meaning (text : Source) (state : NameState) : Option Source :=
  if state.first = 0 then none else some (canonicalName text state.first state.after)

/-- The grammar's trace carries one binding explicitly; only declarations
change it, and every reference must resolve to the current canonical name. -/
inductive Bindings : Option Source → List Event → Prop
  | done (name : Option Source) : Bindings name []
  | declaration {before : Option Source} {name : Source} {events : List Event} :
      Bindings (some name) events → Bindings before (.declaration name :: events)
  | literal {name : Option Source} {value : Source} {events : List Event} :
      Bindings name events → Bindings name (.literal value :: events)
  | reference {bound : Option Source} {name : Source} {events : List Event} :
      bound = some name → Bindings bound events → Bindings bound (.reference name :: events)

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

theorem event_shape {events : List Event}
    (kinds : events.map Event.kind = [.declaration, .literal, .reference]) :
    ∃ declared literal reference, events = [.declaration declared, .literal literal, .reference reference] := by
  cases events with
  | nil => simp at kinds
  | cons first rest =>
    cases rest with
    | nil => simp at kinds
    | cons second rest =>
      cases rest with
      | nil => simp at kinds
      | cons third rest =>
        have empty : rest = [] := by
          have lengths := congrArg List.length kinds
          simpa using lengths
        subst rest
        cases first <;> cases second <;> cases third <;> simp_all [Event.kind]

theorem binding_resolves {declared literal reference : Source}
    (bindings : Bindings none [.declaration declared, .literal literal, .reference reference]) :
    declared = reference := by
  cases bindings with
  | declaration rest =>
      cases rest with
      | literal rest =>
          cases rest with
          | reference same _ => exact Option.some.inj same

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

structure Program where
  declared : Source
  literal : Source
  reference : Source
  deriving DecidableEq, Repr

def SourceMeaning (source : Source) (program : Program) : Prop :=
  Member source ∧ Parsed source requiredTokens 1 {}
    [.declaration program.declared, .literal program.literal, .reference program.reference]

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ program, SourceMeaning source program := by
  obtain ⟨events, parsed⟩ := member.2.2.2
  have shape := parsed_eventKinds parsed
  have kinds : events.map Event.kind = [.declaration, .literal, .reference] := by
    exact shape
  obtain ⟨declared, literal, reference, rfl⟩ := event_shape kinds
  exact ⟨⟨declared, literal, reference⟩, member, parsed⟩

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  have same := parsed_unique first.2 second.2
  cases left
  cases right
  simpa [List.cons.injEq, Event.declaration.injEq, Event.literal.injEq, Event.reference.injEq,
    Program.mk.injEq] using same

theorem meaning_binds {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.declared = program.reference := by
  apply binding_resolves
  have bindings := parsed_bindings meaning.2 (by omega) (by omega) (Or.inl ⟨rfl, rfl⟩)
  simpa [NameState.meaning] using bindings

theorem literal_domain {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.literal.length ≤ maxSourceLength ∧
      ∀ byte ∈ program.literal, Output.printable byte = true := by
  have facts := parsed_literals meaning.2 program.literal (by simp)
  exact ⟨Nat.le_trans facts.1 meaning.1.2.1, facts.2⟩

/-- A single constant binding: initialization fixes the literal value/length,
and resolving its one reference cannot mutate that value. -/
structure Binding where
  name : Source
  value : Source

def initializeBinding (program : Program) : Binding := ⟨program.declared, program.literal⟩
def lookup (binding : Binding) (name : Source) : Option Source :=
  if name = binding.name then some binding.value else none

def evaluate (program : Program) : Option Source := lookup (initializeBinding program) program.reference

theorem evaluate_literal {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    evaluate program = some program.literal := by
  simp [evaluate, lookup, initializeBinding, (meaning_binds meaning).symm]

def execute (environment : Output.Runtime.Environment) (program : Program) :
    Option Output.Runtime.ProcessResult :=
  (evaluate program).map (fun value => Output.Runtime.completeMain
    (Output.Runtime.execute environment value Output.Runtime.program []))

theorem execution_refines {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) :
    execute environment program = some (Output.Runtime.completeMain
      (Output.Runtime.execute environment program.literal Output.Runtime.program [])) := by
  simp [execute, evaluate_literal meaning]

end Silver.Named

import Silver.AssignmentAdmission
import Silver.OutputRuntime

namespace Silver.Assignment
open Named

structure Program where
  declared : Source
  initial : Source
  assigned : Source
  replacement : Source
  reference : Source
  deriving DecidableEq, Repr

def Program.events (program : Program) : List Event :=
  [.declaration program.declared, .literal program.initial, .reference program.assigned,
   .literal program.replacement, .reference program.reference]

def SourceMeaning (source : Source) (program : Program) : Prop :=
  Member source ∧ Parsed source requiredTokens 1 1 {} 0 program.events

theorem event_shape {events : List Event}
    (kinds : events.map Event.kind = [.declaration, .literal, .reference, .literal, .reference]) :
    ∃ program : Program, events = program.events := by
  cases events with
  | nil => simp at kinds
  | cons a rest =>
    cases rest with
    | nil => simp at kinds
    | cons b rest =>
      cases rest with
      | nil => simp at kinds
      | cons c rest =>
        cases rest with
        | nil => simp at kinds
        | cons d rest =>
          cases rest with
          | nil => simp at kinds
          | cons e rest =>
            have empty : rest = [] := by
              have lengths := congrArg List.length kinds
              simpa using lengths
            subst rest
            cases a <;> cases b <;> cases c <;> cases d <;> cases e <;>
              simp_all [Event.kind, Program.events]
            exact ⟨⟨_, _, _, _, _⟩, rfl, rfl, rfl, rfl, rfl⟩

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ program, SourceMeaning source program := by
  obtain ⟨events, parsed⟩ := member.2.2.2
  obtain ⟨program, rfl⟩ := event_shape (Named.parsed_eventKinds (parsed_erases parsed))
  exact ⟨program, member, parsed⟩

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  have same := Named.parsed_unique (parsed_erases first.2) (parsed_erases second.2)
  cases left
  cases right
  simpa [Program.events, List.cons.injEq, Event.declaration.injEq, Event.literal.injEq,
    Event.reference.injEq, Program.mk.injEq] using same

theorem meaning_binds {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.declared = program.assigned ∧ program.declared = program.reference := by
  have bindings := Named.parsed_bindings (parsed_erases meaning.2) (by omega) (by omega) (Or.inl ⟨rfl, rfl⟩)
  cases bindings with
  | declaration rest =>
    cases rest with
    | literal rest =>
      cases rest with
      | reference assigned rest =>
        cases rest with
        | literal rest =>
          cases rest with
          | reference output _ => exact ⟨Option.some.inj assigned, Option.some.inj output⟩

/-- The checked initializer captures the cell's fixed length; the second
literal must have exactly that decoded length, including doubled quotes. -/
theorem assignment_length {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.replacement.length = program.initial.length := by
  rcases program with ⟨declared, initial, assigned, replacement, reference⟩
  have parsed := meaning.2
  change Parsed source requiredTokens 1 1 {} 0
    [.declaration declared, .literal initial, .reference assigned, .literal replacement, .reference reference] at parsed
  cases parsed with
  | fixed _ _ _ _ parsed =>
    cases parsed with
    | fixed _ _ _ _ parsed =>
      cases parsed with
      | fixed _ _ _ _ parsed =>
        cases parsed with
        | fixed _ _ _ _ parsed =>
          cases parsed with
          | fixed _ _ _ _ parsed =>
            cases parsed with
            | fixed _ _ _ _ parsed =>
              cases parsed with
              | fixed _ _ _ _ parsed =>
                cases parsed with
                | fixed _ _ _ _ parsed =>
                  cases parsed with
                  | fixed _ _ _ _ parsed =>
                    cases parsed with
                    | fixed _ _ _ _ parsed =>
                      cases parsed with
                      | fixed _ _ _ _ parsed =>
                        cases parsed with
                        | fixed _ _ _ _ parsed =>
                          cases parsed with
                          | fixed different => contradiction
                          | declaration _ _ parsed =>
                            cases parsed with
                            | fixed _ _ _ _ parsed =>
                              cases parsed with
                              | fixed _ _ _ _ parsed =>
                                cases parsed with
                                | fixed _ _ _ _ parsed =>
                                  cases parsed with
                                  | fixed _ _ different => contradiction
                                  | literal _ _ _ equal parsed =>
                                    cases parsed with
                                    | fixed _ _ _ _ parsed =>
                                      cases parsed with
                                      | fixed _ _ _ _ parsed =>
                                        cases parsed with
                                        | fixed _ different => contradiction
                                        | reference _ _ _ parsed =>
                                          cases parsed with
                                          | fixed _ _ _ _ parsed =>
                                            cases parsed with
                                            | fixed _ _ different => contradiction
                                            | literal _ _ _ equal parsed =>
                                              exact equal (by decide)

theorem output_domain {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.replacement.length ≤ maxSourceLength ∧
      ∀ byte ∈ program.replacement, Output.printable byte = true := by
  have facts := Named.parsed_literals (parsed_erases meaning.2) program.replacement (by simp [Program.events])
  exact ⟨Nat.le_trans facts.1 meaning.1.2.1, facts.2⟩

theorem initializer_domain {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.initial.length ≤ maxSourceLength ∧
      ∀ byte ∈ program.initial, Output.printable byte = true := by
  have facts := Named.parsed_literals (parsed_erases meaning.2) program.initial (by simp [Program.events])
  exact ⟨Nat.le_trans facts.1 meaning.1.2.1, facts.2⟩

/-- Ada's literal-initialized unconstrained String object is constrained by its
initial value. Mutation preserves that constraint rather than resizing storage. -/
structure Variable where
  name : Source
  length : Nat
  value : Source
  deriving DecidableEq, Repr

def initializeVariable (name value : Source) : Variable := ⟨name, value.length, value⟩

def assign (cell : Variable) (target replacement : Source) : Option Variable :=
  if target = cell.name ∧ replacement.length = cell.length then
    some {cell with value := replacement}
  else none

def lookup (cell : Variable) (reference : Source) : Option Source :=
  if reference = cell.name then some cell.value else none

def Variable.Valid (cell : Variable) : Prop := cell.value.length = cell.length

theorem initialization_valid (name value : Source) : (initializeVariable name value).Valid := rfl

theorem assignment_valid {before after : Variable} {target replacement : Source}
    (success : assign before target replacement = some after) : after.Valid := by
  unfold assign at success
  split at success
  · rename_i safe
    cases success
    exact safe.2
  · contradiction

namespace Main

inductive Expression | literal | reference deriving DecidableEq, Repr

def Expression.render : Expression → List Token
  | .literal => [.base .stringLiteral]
  | .reference => [.referenceName]

def Expression.evaluate (cell : Option Variable) : Expression → List Event → Option (Source × List Event)
  | .literal, .literal value :: events => some (value, events)
  | .reference, .reference name :: events =>
      cell.bind (fun bound => (lookup bound name).map (fun value => (value, events)))
  | _, _ => none

structure Composition where
  initializer : Expression
  replacement : Expression
  output : Expression

def Composition.render (template : Composition) : List Token :=
  [.base .withKeyword, .base .ioName, .base .semicolon,
   .base .procedureKeyword, .base .mainName, .base .isKeyword,
   .base .pragmaKeyword, .base .sparkModeName, .base .leftParenthesis,
   .base .onName, .base .rightParenthesis, .base .semicolon,
   .declarationName, .colon, .stringName, .assignment] ++ template.initializer.render ++
  [.base .semicolon, .base .beginKeyword, .referenceName, .assignment] ++ template.replacement.render ++
  [.base .semicolon, .base .ioName, .base .dot, .base .putLineName, .base .leftParenthesis] ++
  template.output.render ++ [.base .rightParenthesis, .base .semicolon, .base .endKeyword,
    .base .mainName, .base .semicolon]

/-- Ordered source events drive initialization, assignment and then output.
The old value is replaced only after the target and length check succeeds. -/
def Composition.evaluateEvents (template : Composition) : List Event → Option Source
  | .declaration name :: events =>
    (template.initializer.evaluate none events).bind (fun (initial, rest) =>
      let cell := initializeVariable name initial
      match rest with
      | .reference target :: rest =>
        (template.replacement.evaluate (some cell) rest).bind (fun (replacement, rest) =>
          (assign cell target replacement).bind (fun changed =>
            (template.output.evaluate (some changed) rest).bind (fun (value, remaining) =>
              if remaining = [] then some value else none)))
      | _ => none)
  | _ => none

def Composition.evaluate (template : Composition) (program : Program) : Option Source :=
  template.evaluateEvents program.events

def composition : Composition := ⟨.literal, .literal, .reference⟩

theorem rendered_tokens : composition.render = requiredTokens := by decide +kernel

theorem wrong_output_differs :
    ({composition with output := .literal} : Composition).render ≠ requiredTokens := by decide +kernel

def Composition.execute (template : Composition) (environment : Output.Runtime.Environment)
    (program : Program) : Option Output.Runtime.ProcessResult :=
  (template.evaluate program).map (fun value => Output.Runtime.completeMain
    (Output.Runtime.execute environment value Output.Runtime.program []))

end Main

theorem assignment_preserves_constraint {source : Source} {program : Program}
    (meaning : SourceMeaning source program) :
    assign (initializeVariable program.declared program.initial) program.assigned program.replacement =
      some ⟨program.declared, program.initial.length, program.replacement⟩ := by
  simp [assign, initializeVariable, (meaning_binds meaning).1.symm, assignment_length meaning]

theorem evaluation_refines {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    Main.composition.evaluate program = some program.replacement := by
  simp [Main.Composition.evaluate, Main.Composition.evaluateEvents, Main.composition,
    Main.Expression.evaluate, Program.events, assignment_preserves_constraint meaning,
    lookup, (meaning_binds meaning).2.symm]

def execute (environment : Output.Runtime.Environment) (program : Program) : Option Output.Runtime.ProcessResult :=
  Main.composition.execute environment program

theorem execution_refines {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) :
    execute environment program = some (Output.Runtime.completeMain
      (Output.Runtime.execute environment program.replacement Output.Runtime.program [])) := by
  simp [execute, Main.Composition.execute, evaluation_refines meaning]

end Silver.Assignment

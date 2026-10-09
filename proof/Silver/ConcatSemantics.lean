import Silver.ConcatAdmission
import Silver.NamedSemantics

namespace Silver.Concat

open Named

/-- Sum decoded bytes across the complete parse, not independent per-literal
bounds. Monotone consumption makes the three source spans disjoint. -/
def literalBytes : List Event → Nat
  | [] => 0
  | .literal value :: events => value.length + literalBytes events
  | _ :: events => literalBytes events

theorem parsed_literal_consumption {text : Source} {tokens : List Named.Token} {position : Nat}
    {state : NameState} {events : List Event} (parsed : Parsed text tokens position state events)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) :
    position + literalBytes events ≤ text.length + 1 := by
  induction parsed with
  | done => simpa [literalBytes] using bounded
  | @fixed position state token tokens events _ _ _ matched rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have tokenBound := matched
      simp only [Named.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at tokenBound
      have remaining := ih (by omega) (by omega)
      omega
  | @declaration position finish state name tokens events nameParsed allowed rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := identifier_bounds nameParsed
      have remaining := ih (by omega) bounds.2.2.2
      simpa only [literalBytes] using (show position + literalBytes events ≤ text.length + 1 by omega)
  | @reference position finish state name tokens events present nameParsed same rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := identifier_bounds nameParsed
      have remaining := ih (by omega) bounds.2.2.2
      simpa only [literalBytes] using (show position + literalBytes events ≤ text.length + 1 by omega)
  | @literal position finish state value tokens events first opening literal rest ih =>
      have trivia := Cursor.triviaPosition_bounds text position positive bounded
      have bounds := Output.literalAt_bounds literal
      have remaining := ih (by omega) bounds.2.1
      simp only [literalBytes]
      omega

structure Program where
  declared : Source
  initial : Source
  leading : Source
  reference : Source
  trailing : Source
  deriving DecidableEq, Repr

def Program.events (program : Program) : List Event :=
  [.declaration program.declared, .literal program.initial, .literal program.leading,
   .reference program.reference, .literal program.trailing]

def Program.bytes (program : Program) : Source :=
  (program.leading ++ program.initial) ++ program.trailing

def SourceMeaning (source : Source) (program : Program) : Prop :=
  Member source ∧ Parsed source requiredTokens 1 {} program.events

theorem event_shape {events : List Event}
    (kinds : events.map Event.kind = [.declaration, .literal, .literal, .reference, .literal]) :
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
  obtain ⟨program, rfl⟩ := event_shape (Named.parsed_eventKinds parsed)
  exact ⟨program, member, parsed⟩

theorem meaning_unique {source : Source} {left right : Program}
    (first : SourceMeaning source left) (second : SourceMeaning source right) : left = right := by
  have same := Named.parsed_unique first.2 second.2
  cases left
  cases right
  simpa [Program.events, List.cons.injEq, Event.declaration.injEq, Event.literal.injEq,
    Event.reference.injEq, Program.mk.injEq] using same

theorem meaning_binds {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.declared = program.reference := by
  have bindings := Named.parsed_bindings meaning.2 (by omega) (by omega) (Or.inl ⟨rfl, rfl⟩)
  cases bindings with
  | declaration rest =>
    cases rest with
    | literal rest =>
      cases rest with
      | literal rest =>
        cases rest with
        | reference same _ => exact Option.some.inj same

/-- Both intermediate and final concatenations fit the output domain. The
bound follows from total consumption, even with empty values and doubled quotes. -/
theorem concatenation_bounds {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.leading.length + program.initial.length ≤ source.length ∧
    program.leading.length + program.initial.length + program.trailing.length ≤ source.length := by
  have consumed := parsed_literal_consumption meaning.2 (by omega) (by omega)
  simp only [Program.events, literalBytes] at consumed
  omega

theorem output_domain {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.bytes.length ≤ maxSourceLength ∧ ∀ byte ∈ program.bytes, Output.printable byte = true := by
  have lengths := concatenation_bounds meaning
  have sourceBound := meaning.1.2.1
  refine ⟨?_, ?_⟩
  · simp only [Program.bytes, List.length_append]
    omega
  · intro byte member
    simp only [Program.bytes, List.mem_append] at member
    rcases member with (leading | initial) | trailing
    · exact (Named.parsed_literals meaning.2 program.leading (by simp [Program.events])).2 byte leading
    · exact (Named.parsed_literals meaning.2 program.initial (by simp [Program.events])).2 byte initial
    · exact (Named.parsed_literals meaning.2 program.trailing (by simp [Program.events])).2 byte trailing

/-! Typed application expressions share rendering and interpretation. The
well-formedness rule enforces Ada's left associativity; an unparenthesized
right-nested tree is rejected. Only `composition` is admitted. -/
namespace Main

inductive Expression
  | literal | reference
  | concatenate (left right : Expression)
  deriving DecidableEq, Repr

def Expression.primary : Expression → Bool
  | .concatenate _ _ => false
  | _ => true

def Expression.wellFormed : Expression → Bool
  | .concatenate left right => left.wellFormed && right.wellFormed && right.primary
  | _ => true

def Expression.render : Expression → List Named.Token
  | .literal => [.base .stringLiteral]
  | .reference => [.referenceName]
  | .concatenate left right => left.render ++ [.ampersand] ++ right.render

/-- Values are consumed from the parser's ordered events, not selected by
unchecked labels. Swapping two literal source spans changes this input trace. -/
def Expression.evaluate (binding : Option Named.Binding) :
    Expression → List Event → Option (Source × List Event)
  | .literal, .literal value :: events => some (value, events)
  | .reference, .reference name :: events =>
      binding.bind (fun bound => (Named.lookup bound name).map (fun value => (value, events)))
  | .concatenate left right, events =>
      (left.evaluate binding events).bind (fun (a, rest) =>
        (right.evaluate binding rest).map (fun (b, remaining) => (a ++ b, remaining)))
  | _, _ => none

structure Composition where
  initializer : Expression
  output : Expression

def Composition.render (template : Composition) : List Named.Token :=
  [.base .withKeyword, .base .ioName, .base .semicolon,
   .base .procedureKeyword, .base .mainName, .base .isKeyword,
   .base .pragmaKeyword, .base .sparkModeName, .base .leftParenthesis,
   .base .onName, .base .rightParenthesis, .base .semicolon,
   .declarationName, .colon, .constantKeyword, .stringName, .assignment] ++
   template.initializer.render ++ [.base .semicolon, .base .beginKeyword,
   .base .ioName, .base .dot, .base .putLineName, .base .leftParenthesis] ++
   template.output.render ++ [.base .rightParenthesis, .base .semicolon,
   .base .endKeyword, .base .mainName, .base .semicolon]

def Composition.evaluateEvents (template : Composition) : List Event → Option Source
  | .declaration name :: events =>
      (template.initializer.evaluate none events).bind (fun (value, rest) =>
        (template.output.evaluate (some ⟨name, value⟩) rest).bind (fun (output, remaining) =>
          if remaining = [] then some output else none))
  | _ => none

def Composition.evaluate (template : Composition) (program : Program) : Option Source :=
  template.evaluateEvents program.events

def Composition.execute (template : Composition) (environment : Output.Runtime.Environment)
    (program : Program) : Option Output.Runtime.ProcessResult :=
  (template.evaluate program).map (fun value => Output.Runtime.completeMain
    (Output.Runtime.execute environment value Output.Runtime.program []))

def composition : Composition :=
  ⟨.literal, .concatenate (.concatenate .literal .reference) .literal⟩

theorem rendered_tokens : composition.render = requiredTokens := by decide +kernel

theorem checked_precedence : composition.initializer.wellFormed = true ∧
    composition.output.wellFormed = true := by decide +kernel

theorem right_nested_rejected :
    (Expression.concatenate .literal (.concatenate .reference .literal)).wellFormed = false := by decide +kernel

theorem repeated_reference_differs :
    ({composition with output := .concatenate (.concatenate .reference .reference) .literal} : Composition).render ≠
      requiredTokens := by decide +kernel

theorem uninitialized_reference_fails (program : Program) :
    ({composition with initializer := .reference} : Composition).evaluate program = none := rfl

end Main

theorem evaluation_refines {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    Main.composition.evaluate program = some program.bytes := by
  simp [Main.Composition.evaluate, Main.Composition.evaluateEvents, Program.events, Main.composition, Main.Expression.evaluate,
    Named.lookup, (meaning_binds meaning).symm, Program.bytes]

def execute (environment : Output.Runtime.Environment) (program : Program) : Option Output.Runtime.ProcessResult :=
  Main.composition.execute environment program

theorem execution_refines {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) :
    execute environment program = some (Output.Runtime.completeMain
      (Output.Runtime.execute environment program.bytes Output.Runtime.program [])) := by
  simp [execute, Main.Composition.execute, evaluation_refines meaning]

end Silver.Concat

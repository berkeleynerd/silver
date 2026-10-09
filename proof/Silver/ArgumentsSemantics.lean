import Silver.ArgumentsAdmission
import Silver.ArgumentsRuntime
import Silver.NamedSemantics

namespace Silver.Arguments

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

structure Program where
  declared : Source
  defaultValue : Source
  reference : Source
  deriving DecidableEq, Repr

def SourceMeaning (source : Source) (program : Program) : Prop :=
  Member source ∧ Parsed source requiredTokens 1 {}
    [.declaration program.declared, .literal program.defaultValue, .reference program.reference]

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

theorem default_domain {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    program.defaultValue.length ≤ maxSourceLength ∧
      ∀ byte ∈ program.defaultValue, Output.printable byte = true := by
  have facts := parsed_literals meaning.2 program.defaultValue (by simp)
  exact ⟨Nat.le_trans facts.1 meaning.1.2.1, facts.2⟩

theorem default_is_message {source : Source} {program : Program} (meaning : SourceMeaning source program) :
    Runtime.message program.defaultValue = true := by
  apply (Runtime.message_iff _).mpr
  obtain ⟨length, bytes⟩ := default_domain meaning
  refine ⟨length, ?_⟩
  intro byte member
  simpa [Output.printable] using bytes byte member

/-- Initialization binds the exact selected argument/default before the guard.
The only identifier reference resolves this immutable value. -/
def initializeBinding (arguments : Runtime.Arguments) (program : Program) : Named.Binding :=
  ⟨program.declared, Runtime.firstOrDefault program.defaultValue arguments⟩

def evaluate (arguments : Runtime.Arguments) (program : Program) : Option Source :=
  Named.lookup (initializeBinding arguments program) program.reference

theorem evaluate_initializer {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (arguments : Runtime.Arguments) :
    evaluate arguments program = some (Runtime.firstOrDefault program.defaultValue arguments) := by
  simp [evaluate, Named.lookup, initializeBinding, (meaning_binds meaning).symm]

/-! A small application syntax, distinct from the wrapper-body syntax. Its
renderer and interpreter share the initializer, reference and branch structure.
Only `composition` is admitted: the auxiliary constructors permit meaningful
negative checks without extending the language. Ada's interpretation of these
fixed syntax nodes remains the documented frontend premise. -/
namespace Main

inductive Kind | bytes | boolean

abbrev Value : Kind → Type
  | .bytes => Source
  | .boolean => Bool

inductive Expression : Kind → Type
  | defaultValue : Expression .bytes
  | firstOrDefault (value : Expression .bytes) : Expression .bytes
  | reference : Expression .bytes
  | inputIsValid : Expression .boolean

def Expression.render : {kind : Kind} → Expression kind → List Token
  | _, .defaultValue => [.base .stringLiteral]
  | _, .firstOrDefault value =>
      [.argumentsName, .base .dot, .firstOrDefaultName, .base .leftParenthesis] ++
      value.render ++ [.base .rightParenthesis]
  | _, .reference => [.referenceName]
  | _, .inputIsValid => [.argumentsName, .base .dot, .inputIsValidName]

structure Context where
  arguments : Runtime.Arguments
  program : Program
  binding : Option Named.Binding := none

def Expression.evaluate (context : Context) : {kind : Kind} → Expression kind → Option (Value kind)
  | _, .defaultValue => some context.program.defaultValue
  | _, .firstOrDefault value =>
      (value.evaluate context).map (fun fallback => Runtime.firstOrDefault fallback context.arguments)
  | _, .reference => context.binding.bind (fun binding => Named.lookup binding context.program.reference)
  | _, .inputIsValid => some (Runtime.inputIsValid context.arguments)

inductive Statement
  | output (value : Expression .bytes)
  | reject
  | conditional (test : Expression .boolean) (yes no : Statement)

def Statement.render : Statement → List Token
  | .output value => [.base .ioName, .base .dot, .base .putLineName, .base .leftParenthesis] ++
      value.render ++ [.base .rightParenthesis, .base .semicolon]
  | .reject => [.argumentsName, .base .dot, .rejectName, .base .semicolon]
  | .conditional test yes no => [.ifKeyword] ++ test.render ++ [.thenKeyword] ++
      yes.render ++ [.elseKeyword] ++ no.render ++ [.base .endKeyword, .ifKeyword, .base .semicolon]

def Statement.execute (environment : Output.Runtime.Environment) (context : Context) :
    Statement → Option Output.Runtime.ProcessResult
  | .output value => (value.evaluate context).map (Runtime.outputMain environment)
  | .reject => some Runtime.rejectProgram.execute
  | .conditional test yes no => (test.evaluate context).bind (fun valid =>
      if valid then yes.execute environment context else no.execute environment context)

structure Composition where
  initializer : Expression .bytes
  body : Statement

def Composition.render (template : Composition) : List Token :=
  [.base .withKeyword, .base .ioName, .base .semicolon,
   .base .withKeyword, .argumentsName, .base .semicolon,
   .base .procedureKeyword, .base .mainName, .base .isKeyword,
   .base .pragmaKeyword, .base .sparkModeName, .base .leftParenthesis,
   .base .onName, .base .rightParenthesis, .base .semicolon,
   .declarationName, .colon, .constantKeyword, .stringName, .assignment] ++
  template.initializer.render ++ [.base .semicolon, .base .beginKeyword] ++
  template.body.render ++ [.base .endKeyword, .base .mainName, .base .semicolon]

/-- Initializer evaluation happens with no binding. Only its successful result
creates the immutable local before any guard or output expression is evaluated. -/
def Composition.execute (template : Composition) (environment : Output.Runtime.Environment)
    (arguments : Runtime.Arguments) (program : Program) : Option Output.Runtime.ProcessResult :=
  let context : Context := ⟨arguments, program, none⟩
  (template.initializer.evaluate context).bind (fun value =>
    template.body.execute environment {context with binding := some ⟨program.declared, value⟩})

def composition : Composition :=
  ⟨.firstOrDefault .defaultValue, .conditional .inputIsValid (.output .reference) .reject⟩

theorem rendered_tokens : composition.render = requiredTokens := by decide +kernel

/-- Branch order is visible to the renderer, rather than a semantic label. -/
theorem swapped_branches_differ :
    ({composition with body := .conditional .inputIsValid .reject (.output .reference)} : Composition).render ≠
      requiredTokens := by decide +kernel

/-- An uninitialized read is an interpreter failure, even if the body would
reject. Thus declaration-before-body order is part of the executable model. -/
theorem uninitialized_initializer_fails (environment : Output.Runtime.Environment)
    (arguments : Runtime.Arguments) (program : Program) :
    ({initializer := .reference, body := .reject} : Composition).execute environment arguments program = none := rfl

end Main

def execute (environment : Output.Runtime.Environment) (arguments : Runtime.Arguments) (program : Program) :
    Option Output.Runtime.ProcessResult :=
  Main.composition.execute environment arguments program

theorem execution_refines {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (arguments : Runtime.Arguments) :
    execute environment arguments program = Runtime.executeMain environment arguments program.defaultValue := by
  cases valid : Runtime.inputIsValid arguments <;>
    simp [execute, Main.Composition.execute, Main.composition, Main.Expression.evaluate,
      Main.Statement.execute, Named.lookup, (meaning_binds meaning).symm, Runtime.main_refines,
      valid, Runtime.rejectProgram, Runtime.Effect.execute]

theorem invalid_execution {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (arguments : Runtime.Arguments)
    (invalid : Runtime.inputIsValid arguments = false) :
    execute environment arguments program = some ⟨1, []⟩ := by
  rw [execution_refines meaning]
  exact Runtime.invalid_no_output _ _ _ invalid

theorem missing_execution {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) :
    execute environment [] program = some (Runtime.outputMain environment program.defaultValue) := by
  rw [execution_refines meaning]
  exact Runtime.missing_uses_default _ _ (default_is_message meaning)

theorem healthy_execution {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (healthy : Output.Runtime.Healthy environment)
    (arguments : Runtime.Arguments) (valid : Runtime.inputIsValid arguments = true) :
    execute environment arguments program =
      some ⟨0, Runtime.firstOrDefault program.defaultValue arguments ++ [10]⟩ := by
  rw [execution_refines meaning]
  exact Runtime.valid_healthy_output _ healthy _ _ valid

end Silver.Arguments

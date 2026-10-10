import Silver.BranchingSemantics

namespace Silver.Branching.Main

open Named

inductive Kind | bytes | boolean
  deriving DecidableEq, Repr

abbrev Value : Kind → Type
  | .bytes => Source | .boolean => Bool

inductive Expression : Kind → Type
  | literal (value : Source) : Expression .bytes
  | reference (name : Source) : Expression .bytes
  | firstOrDefault (fallback : Expression .bytes) : Expression .bytes
  | inputIsValid : Expression .boolean
  | equal (left right : Expression .bytes) : Expression .boolean

def Expression.evaluate (arguments : Arguments.Runtime.Arguments) (binding : Option Named.Binding) :
    {kind : Kind} → Expression kind → Option (Value kind)
  | _, .literal value => some value
  | _, .reference name => binding.bind (fun bound => Named.lookup bound name)
  | _, .firstOrDefault fallback => (fallback.evaluate arguments binding).map
      (fun value => Arguments.Runtime.firstOrDefault value arguments)
  | _, .inputIsValid => some (Arguments.Runtime.inputIsValid arguments)
  | _, .equal left right => (left.evaluate arguments binding).bind
      (fun a => (right.evaluate arguments binding).map (fun b => decide (a = b)))

/-- The same templates render source and consume its ordered parser events.
Instantiation resolves payloads without executing either conditional branch. -/
inductive Template : Kind → Type
  | literal : Template .bytes
  | reference : Template .bytes
  | firstOrDefault (fallback : Template .bytes) : Template .bytes
  | inputIsValid : Template .boolean
  | equal (left right : Template .bytes) : Template .boolean

def Template.render : {kind : Kind} → Template kind → List Token
  | _, .literal => [.base .stringLiteral]
  | _, .reference => [.referenceName]
  | _, .firstOrDefault fallback => [.argumentsName, .base .dot, .firstOrDefaultName, .base .leftParenthesis] ++
      fallback.render ++ [.base .rightParenthesis]
  | _, .inputIsValid => [.argumentsName, .base .dot, .inputIsValidName]
  | _, .equal left right => left.render ++ [.equal] ++ right.render

def Template.primary : {kind : Kind} → Template kind → Bool
  | _, .equal _ _ => false
  | _, _ => true

def Template.wellFormed : {kind : Kind} → Template kind → Bool
  | _, .equal left right => left.wellFormed && right.wellFormed && left.primary && right.primary
  | _, .firstOrDefault fallback => fallback.wellFormed
  | _, _ => true

def Template.instantiate : {kind : Kind} → Template kind → List Event → Option (Expression kind × List Event)
  | _, .literal, .literal bytes :: events => some (.literal bytes, events)
  | _, .reference, .reference name :: events => some (.reference name, events)
  | _, .firstOrDefault fallback, events =>
      (fallback.instantiate events).map (fun (value, rest) => (.firstOrDefault value, rest))
  | _, .inputIsValid, events => some (.inputIsValid, events)
  | _, .equal left right, events =>
      (left.instantiate events).bind (fun (a, rest) =>
        (right.instantiate rest).map (fun (b, remaining) => (.equal a b, remaining)))
  | _, _, _ => none

inductive Statement
  | output (value : Expression .bytes)
  | reject
  | conditional (test : Expression .boolean) (yes no : Statement)

def Statement.execute (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments)
    (binding : Option Named.Binding) : Statement → Option Output.Runtime.ProcessResult
  | .output value => (value.evaluate arguments binding).map (Arguments.Runtime.outputMain environment)
  | .reject => some Arguments.Runtime.rejectProgram.execute
  | .conditional test yes no => (test.evaluate arguments binding).bind
      (fun condition => if condition then yes.execute environment arguments binding else no.execute environment arguments binding)

inductive StatementTemplate
  | output (value : Template .bytes)
  | reject
  | conditional (test : Template .boolean) (yes no : StatementTemplate)

def StatementTemplate.render : StatementTemplate → List Token
  | .output value => [.base .ioName, .base .dot, .base .putLineName, .base .leftParenthesis] ++
      value.render ++ [.base .rightParenthesis, .base .semicolon]
  | .reject => [.argumentsName, .base .dot, .rejectName, .base .semicolon]
  | .conditional test yes no => [.ifKeyword] ++ test.render ++ [.thenKeyword] ++
      yes.render ++ [.elseKeyword] ++ no.render ++ [.base .endKeyword, .ifKeyword, .base .semicolon]

def StatementTemplate.instantiate : StatementTemplate → List Event → Option (Statement × List Event)
  | .output value, events => (value.instantiate events).map (fun (value, rest) => (.output value, rest))
  | .reject, events => some (.reject, events)
  | .conditional test yes no, events =>
      (test.instantiate events).bind (fun (condition, rest) =>
        (yes.instantiate rest).bind (fun (yes, rest) =>
          (no.instantiate rest).map (fun (no, remaining) => (.conditional condition yes no, remaining))))

structure Instantiated where
  declared : Source
  initializer : Expression .bytes
  body : Statement

def Instantiated.execute (program : Instantiated) (environment : Output.Runtime.Environment)
    (arguments : Arguments.Runtime.Arguments) : Option Output.Runtime.ProcessResult :=
  (program.initializer.evaluate arguments none).bind
    (fun value => program.body.execute environment arguments (some ⟨program.declared, value⟩))

structure Composition where
  initializer : Template .bytes
  body : StatementTemplate

def Composition.render (template : Composition) : List Token :=
  [.base .withKeyword, .base .ioName, .base .semicolon,
   .base .withKeyword, .argumentsName, .base .semicolon,
   .base .procedureKeyword, .base .mainName, .base .isKeyword,
   .base .pragmaKeyword, .base .sparkModeName, .base .leftParenthesis,
   .base .onName, .base .rightParenthesis, .base .semicolon,
   .declarationName, .colon, .constantKeyword, .stringName, .assignment] ++
  template.initializer.render ++ [.base .semicolon, .base .beginKeyword] ++
  template.body.render ++ [.base .endKeyword, .base .mainName, .base .semicolon]

def Composition.instantiate (template : Composition) : List Event → Option Instantiated
  | .declaration name :: events =>
      (template.initializer.instantiate events).bind (fun (initial, rest) =>
        (template.body.instantiate rest).bind (fun (body, remaining) =>
          if remaining = [] then some ⟨name, initial, body⟩ else none))
  | _ => none

def Composition.execute (template : Composition) (environment : Output.Runtime.Environment)
    (arguments : Arguments.Runtime.Arguments) (events : List Event) : Option Output.Runtime.ProcessResult :=
  (template.instantiate events).bind (fun program => program.execute environment arguments)

def comparisonExpression : Template .boolean := .equal .reference .literal

def composition : Composition :=
  ⟨.firstOrDefault .literal, .conditional .inputIsValid
    (.conditional comparisonExpression (.output .literal) (.output .literal)) .reject⟩

theorem rendered_tokens : composition.render = requiredTokens := by decide +kernel

theorem checked_precedence : composition.initializer.wellFormed = true ∧
    comparisonExpression.wellFormed = true := by decide +kernel

theorem validity_guard_required :
    ({composition with body := .conditional comparisonExpression (.output .literal) (.output .literal)} : Composition).render ≠
      requiredTokens := by decide +kernel

theorem comparison_reference_required :
    ({composition with body := (.conditional .inputIsValid
      (.conditional (.equal .literal .literal) (.output .literal) (.output .literal)) .reject)} : Composition).render ≠
      requiredTokens := by decide +kernel

theorem instantiation (program : Program) : composition.instantiate program.events =
    some ⟨program.declared, .firstOrDefault (.literal program.defaultValue),
      .conditional .inputIsValid
        (.conditional (.equal (.reference program.reference) (.literal program.comparison))
          (.output (.literal program.yesOutput)) (.output (.literal program.noOutput))) .reject⟩ := rfl

end Silver.Branching.Main

namespace Silver.Branching

def execute (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments) (program : Program) :
    Option Output.Runtime.ProcessResult :=
  Main.composition.execute environment arguments program.events

theorem execution_refines {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments) :
    execute environment arguments program = some
      (if Arguments.Runtime.inputIsValid arguments then
        Arguments.Runtime.outputMain environment (selectedOutput arguments program)
       else ⟨1, []⟩) := by
  simp only [execute, Main.Composition.execute, Main.instantiation, Option.bind_some,
    Main.Instantiated.execute, Main.Expression.evaluate, Main.Statement.execute,
    Named.lookup, (meaning_binds meaning).symm]
  cases valid : Arguments.Runtime.inputIsValid arguments <;>
    by_cases same : Arguments.Runtime.firstOrDefault program.defaultValue arguments = program.comparison <;>
    simp [selectedOutput, selected, choose, same, Arguments.Runtime.rejectProgram,
      Arguments.Runtime.Effect.execute]

theorem invalid_execution {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments)
    (invalid : Arguments.Runtime.inputIsValid arguments = false) :
    execute environment arguments program = some ⟨1, []⟩ := by
  simp [execution_refines meaning, invalid]

theorem missing_execution {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) : execute environment [] program =
    some (Arguments.Runtime.outputMain environment (choose program program.defaultValue)) := by
  simp [execution_refines meaning, selectedOutput, selected, Arguments.Runtime.inputIsValid,
    Arguments.Runtime.firstOrDefault, default_is_message meaning]

theorem single_execution {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (item : Source) (valid : Arguments.Runtime.message item = true) :
    execute environment [item] program = some (Arguments.Runtime.outputMain environment (choose program item)) := by
  simp [execution_refines meaning, selectedOutput, selected, Arguments.Runtime.inputIsValid,
    Arguments.Runtime.firstOrDefault, valid]

theorem empty_execution {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) :
    execute environment [[]] program = some (Arguments.Runtime.outputMain environment (choose program [])) :=
  single_execution meaning environment [] Arguments.Runtime.message_empty

theorem extra_arguments_rejected {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (first second : Source) (rest : Arguments.Runtime.Arguments) :
    execute environment (first :: second :: rest) program = some ⟨1, []⟩ :=
  invalid_execution meaning environment _ rfl

theorem healthy_execution {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (healthy : Output.Runtime.Healthy environment)
    (arguments : Arguments.Runtime.Arguments) (valid : Arguments.Runtime.inputIsValid arguments = true) :
    execute environment arguments program = some ⟨0, selectedOutput arguments program ++ [10]⟩ := by
  have domain := output_domain meaning arguments
  have bytes : ∀ byte ∈ selectedOutput arguments program, byte ≤ 255 := by
    intro byte member
    have bounded := domain.2 byte member
    simp only [Output.printable, decide_eq_true_eq] at bounded
    omega
  simp [execution_refines meaning, valid, Arguments.Runtime.outputMain,
    Output.Runtime.healthy_output environment healthy _ domain.1 bytes, Output.Runtime.completeMain]

theorem valid_output_failure {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments)
    (accepted : Source) (status : Nat) (valid : Arguments.Runtime.inputIsValid arguments = true)
    (failed : Output.Runtime.execute environment (selectedOutput arguments program)
      Output.Runtime.program [] = .failedReturn status accepted) :
    execute environment arguments program = some ⟨1, accepted⟩ ∧
      ∃ suffix, accepted ++ suffix = selectedOutput arguments program ++ [10] := by
  obtain ⟨code, suffix⟩ := Output.Runtime.failed_output _ _ _ _ failed
  subst status
  exact ⟨by simp [execution_refines meaning, valid, Arguments.Runtime.outputMain, failed,
    Output.Runtime.completeMain], suffix⟩

theorem valid_output_success {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments)
    (accepted : Source) (valid : Arguments.Runtime.inputIsValid arguments = true)
    (returned : Output.Runtime.execute environment (selectedOutput arguments program)
      Output.Runtime.program [] = .returned accepted) :
    execute environment arguments program = some ⟨0, accepted⟩ ∧
      accepted = selectedOutput arguments program ++ [10] ∧ environment.flushStatus = 0 := by
  have result := Output.Runtime.successful_output _ _ _ returned
  exact ⟨by simp [execution_refines meaning, valid, Arguments.Runtime.outputMain, returned,
    Output.Runtime.completeMain], result.2⟩

end Silver.Branching

import Silver.GuardedSemantics

namespace Silver.Guarded.Main

inductive Kind | bytes | boolean | natural
  deriving DecidableEq, Repr

abbrev Value : Kind → Type
  | .bytes => Source | .boolean => Bool | .natural => Nat

inductive Expression : Kind → Type
  | literal (value : Source) : Expression .bytes
  | reference (name : Source) : Expression .bytes
  | number (value : Nat) : Expression .natural
  | firstOrDefault (fallback : Expression .bytes) : Expression .bytes
  | inputIsValid : Expression .boolean
  | length (value : Expression .bytes) : Expression .natural
  | lessEqual (left right : Expression .natural) : Expression .boolean
  | andThen (left right : Expression .boolean) : Expression .boolean
  | concatenate (left right : Expression .bytes) : Expression .bytes

def Expression.evaluate (arguments : Arguments.Runtime.Arguments) (binding : Option Named.Binding) :
    {kind : Kind} → Expression kind → Option (Value kind)
  | _, .literal value => some value
  | _, .reference name => binding.bind (fun bound => Named.lookup bound name)
  | _, .number value => some value
  | _, .firstOrDefault fallback => (fallback.evaluate arguments binding).map
      (fun value => Arguments.Runtime.firstOrDefault value arguments)
  | _, .inputIsValid => some (Arguments.Runtime.inputIsValid arguments)
  | _, .length value => (value.evaluate arguments binding).map List.length
  | _, .lessEqual left right => (left.evaluate arguments binding).bind
      (fun a => (right.evaluate arguments binding).map (fun b => decide (a ≤ b)))
  | _, .andThen left right => (left.evaluate arguments binding).bind
      (fun value => if value then right.evaluate arguments binding else some false)
  | _, .concatenate left right => (left.evaluate arguments binding).bind
      (fun a => (right.evaluate arguments binding).map (fun b => a ++ b))

/-- Templates render syntax and consume parser events in that same order.
Payloads are resolved before execution; resolving syntax does not evaluate
concatenations or either conditional branch. -/
inductive Template : Kind → Type
  | literal (decoration : Bool) : Template .bytes
  | reference : Template .bytes
  | capacity : Template .natural
  | firstOrDefault (fallback : Template .bytes) : Template .bytes
  | inputIsValid : Template .boolean
  | length (value : Template .bytes) : Template .natural
  | lessEqual (left right : Template .natural) : Template .boolean
  | andThen (left right : Template .boolean) : Template .boolean
  | concatenate (left right : Template .bytes) : Template .bytes

def Template.render : {kind : Kind} → Template kind → List Token
  | _, .literal _ => [.base .stringLiteral]
  | _, .reference => [.referenceName]
  | _, .capacity => [.capacityLiteral]
  | _, .firstOrDefault fallback => [.argumentsName, .base .dot, .firstOrDefaultName, .base .leftParenthesis] ++
      fallback.render ++ [.base .rightParenthesis]
  | _, .inputIsValid => [.argumentsName, .base .dot, .inputIsValidName]
  | _, .length value => value.render ++ [.apostrophe, .lengthName]
  | _, .lessEqual left right => left.render ++ [.lessEqual] ++ right.render
  | _, .andThen left right => left.render ++ [.andKeyword, .thenKeyword] ++ right.render
  | _, .concatenate left right => left.render ++ [.ampersand] ++ right.render

def Template.primary : {kind : Kind} → Template kind → Bool
  | _, .concatenate _ _ | _, .lessEqual _ _ | _, .andThen _ _ => false
  | _, _ => true

def Template.wellFormed : {kind : Kind} → Template kind → Bool
  | _, .concatenate left right => left.wellFormed && right.wellFormed && right.primary
  | _, .lessEqual left right => left.wellFormed && right.wellFormed && left.primary && right.primary
  | _, .andThen left right => left.wellFormed && right.wellFormed
  | _, .length value => match value with | .reference => true | _ => false
  | _, .firstOrDefault fallback => fallback.wellFormed
  | _, _ => true

def Template.instantiate : {kind : Kind} → Template kind → List Event → Option (Expression kind × List Event)
  | _, .literal expected, .literal bytes decoration :: events =>
      if expected = decoration then some (.literal bytes, events) else none
  | _, .reference, .reference name :: events => some (.reference name, events)
  | _, .capacity, .capacity value :: events => some (.number value, events)
  | _, .firstOrDefault fallback, events =>
      (fallback.instantiate events).map (fun (value, rest) => (.firstOrDefault value, rest))
  | _, .inputIsValid, events => some (.inputIsValid, events)
  | _, .length value, events => (value.instantiate events).map (fun (value, rest) => (.length value, rest))
  | _, .lessEqual left right, events =>
      (left.instantiate events).bind (fun (a, rest) =>
        (right.instantiate rest).map (fun (b, remaining) => (.lessEqual a b, remaining)))
  | _, .andThen left right, events =>
      (left.instantiate events).bind (fun (a, rest) =>
        (right.instantiate rest).map (fun (b, remaining) => (.andThen a b, remaining)))
  | _, .concatenate left right, events =>
      (left.instantiate events).bind (fun (a, rest) =>
        (right.instantiate rest).map (fun (b, remaining) => (.concatenate a b, remaining)))
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

def outputExpression : Template .bytes :=
  .concatenate (.concatenate (.literal true) .reference) (.literal true)

def guardExpression : Template .boolean :=
  .andThen .inputIsValid (.lessEqual (.length .reference) .capacity)

def composition : Composition :=
  ⟨.firstOrDefault (.literal false), .conditional guardExpression (.output outputExpression) .reject⟩

theorem rendered_tokens : composition.render = requiredTokens := by decide +kernel

theorem checked_precedence : composition.initializer.wellFormed = true ∧
    guardExpression.wellFormed = true ∧ outputExpression.wellFormed = true := by decide +kernel

theorem swapped_branches_differ :
    ({composition with body := .conditional guardExpression .reject (.output outputExpression)} : Composition).render ≠
      requiredTokens := by decide +kernel

theorem right_nested_rejected :
    (Template.concatenate (.literal true) (.concatenate .reference (.literal true))).wellFormed = false := by decide +kernel

theorem instantiation (program : Program) : composition.instantiate program.events =
    some ⟨program.declared, .firstOrDefault (.literal program.defaultValue),
      .conditional (.andThen .inputIsValid (.lessEqual (.length (.reference program.guardReference)) (.number program.capacity)))
        (.output (.concatenate (.concatenate (.literal program.leading) (.reference program.reference)) (.literal program.trailing)))
        .reject⟩ := rfl

theorem short_circuit (arguments : Arguments.Runtime.Arguments) (binding : Option Named.Binding)
    (right : Expression .boolean) (invalid : Arguments.Runtime.inputIsValid arguments = false) :
    (Expression.andThen .inputIsValid right).evaluate arguments binding = some false := by
  simp [Expression.evaluate, invalid]

end Silver.Guarded.Main

namespace Silver.Guarded

def execute (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments) (program : Program) :
    Option Output.Runtime.ProcessResult := Main.composition.execute environment arguments program.events

theorem execution_refines {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments) :
    execute environment arguments program = some
      (if guard arguments program then Arguments.Runtime.outputMain environment (decorated arguments program)
       else Arguments.Runtime.rejectProgram.execute) := by
  obtain ⟨guardBinding, outputBinding⟩ := meaning_binds meaning
  rw [execute, Main.Composition.execute, Main.instantiation]
  cases valid : Arguments.Runtime.inputIsValid arguments <;>
    simp [Main.Instantiated.execute, Main.Expression.evaluate, Main.Statement.execute,
      Named.lookup, guardBinding.symm, outputBinding.symm, guard, decorated, selected, valid]
  split <;> simp_all
  intro impossible
  have fits : (Arguments.Runtime.firstOrDefault program.defaultValue arguments).length ≤ program.capacity :=
    of_decide_eq_true impossible
  omega

theorem invalid_rejects {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments)
    (invalid : Arguments.Runtime.inputIsValid arguments = false) :
    execute environment arguments program = some Arguments.Runtime.rejectProgram.execute := by
  rw [execution_refines meaning]
  simp [guard, invalid]

theorem over_capacity_rejects {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) (arguments : Arguments.Runtime.Arguments)
    (oversize : program.capacity < (selected arguments program).length) :
    execute environment arguments program = some Arguments.Runtime.rejectProgram.execute := by
  rw [execution_refines meaning]
  have notEnough : ¬ (selected arguments program).length ≤ program.capacity := by omega
  simp [guard, notEnough]

theorem missing_uses_default {source : Source} {program : Program} (meaning : SourceMeaning source program)
    (environment : Output.Runtime.Environment) :
    execute environment [] program = some
      (Arguments.Runtime.outputMain environment ((program.leading ++ program.defaultValue) ++ program.trailing)) := by
  rw [execution_refines meaning]
  have message := default_is_message meaning
  have fits := default_fits_capacity meaning
  simp [guard, selected, decorated, Arguments.Runtime.inputIsValid, Arguments.Runtime.firstOrDefault, message, fits]

end Silver.Guarded

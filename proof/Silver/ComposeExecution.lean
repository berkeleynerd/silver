module

public import Silver.ComposeDecode

@[expose] public section

/-! The admitted token shells instantiate an ordinary statement interpreter.
Declarations elaborate in order; assignment checks the existing object's bound
before updating its value. This does not substitute generated source for Main. -/

namespace Silver.Compose.Main
open Bindings

structure State where
  values : Values
  input : Source

inductive Condition
  | valid
  | capacity (bound : Nat)
  | equal (left right : Expression)
  deriving DecidableEq, Repr

def Condition.evaluate (arguments : Arguments.Runtime.Arguments) (state : State) : Condition → Bool
  | .valid => Arguments.Runtime.inputIsValid arguments
  | .capacity bound => Arguments.Runtime.inputIsValid arguments && decide (state.input.length ≤ bound)
  | .equal left right => decide (left.evaluate state.values state.input = right.evaluate state.values state.input)

inductive Statement
  | output (expression : Expression)
  | assign (update : Bindings.Assignment)
  | reject
  | conditional (condition : Condition) (yes no : Statement)
  | sequence (first second : Statement)
  deriving DecidableEq, Repr

inductive Result
  | continuing (state : State)
  | finished (action : Action)

def Statement.execute (arguments : Arguments.Runtime.Arguments) (state : State) : Statement → Option Result
  | .output expression => some (.finished (.output (expression.evaluateLeft state.values state.input)))
  | .assign update =>
      if (update.value.evaluate state.values state.input).length = (state.values update.target).length then
        some (.continuing {state with values := update.execute state.values state.input})
      else none
  | .reject => some (.finished .reject)
  | .conditional condition yes no =>
      if condition.evaluate arguments state then yes.execute arguments state else no.execute arguments state
  | .sequence first second => (first.execute arguments state).bind fun result =>
      match result with
      | .continuing next => second.execute arguments next
      | .finished action => some (.finished action)

structure Instantiated where
  declarations : List Bindings.Declaration
  fallback : Source
  body : Statement

def Instantiated.execute (program : Instantiated) (arguments : Arguments.Runtime.Arguments) : Option Action :=
  let input := selected program.fallback arguments
  let values := executeDeclarations input program.declarations emptyValues
  (program.body.execute arguments ⟨values, input⟩).bind fun result =>
    match result with
    | .finished action => some action
    | .continuing _ => none

inductive ConditionTemplate | valid | capacity | equal
  deriving DecidableEq, Repr

def ConditionTemplate.render : ConditionTemplate → List ShellToken
  | .valid => [.word "silver_arguments", .symbol ".", .word "input_is_valid"]
  | .capacity => [.word "silver_arguments", .symbol ".", .word "input_is_valid",
      .word "and", .word "then", .dynamicReference, .symbol "'", .word "length", .symbol "<=", .capacity]
  | .equal => [.comparisonExpression]

def ConditionTemplate.instantiate : ConditionTemplate → List Event → Option (Condition × List Event)
  | .valid, events => some (.valid, events)
  | .capacity, .capacity bound :: rest => some (.capacity bound, rest)
  | .equal, .comparison left right :: rest => some (.equal left right, rest)
  | _, _ => none

inductive StatementTemplate
  | output
  | assign (sameTarget : Bool)
  | reject
  | conditional (condition : ConditionTemplate) (yes no : StatementTemplate)
  | sequence (first second : StatementTemplate)
  deriving DecidableEq, Repr

def StatementTemplate.render : StatementTemplate → List ShellToken
  | .output => [.word "silver_io", .symbol ".", .word "put_line", .symbol "(",
      .outputExpression, .symbol ")", .symbol ";"]
  | .assign sameTarget => [if sameTarget then .targetReference else .assignmentTarget,
      .symbol ":=", .assignmentValue, .symbol ";"]
  | .reject => [.word "silver_arguments", .symbol ".", .word "reject", .symbol ";"]
  | .conditional condition yes no => [.word "if"] ++ condition.render ++ [.word "then"] ++
      yes.render ++ [.word "else"] ++ no.render ++ [.word "end", .word "if", .symbol ";"]
  | .sequence first second => first.render ++ second.render

def StatementTemplate.instantiate : StatementTemplate → List Event → Option (Statement × List Event)
  | .output, .output expression :: rest => some (.output expression, rest)
  | .assign _, .assignment update :: rest => some (.assign update, rest)
  | .reject, events => some (.reject, events)
  | .conditional condition yes no, events =>
      (condition.instantiate events).bind fun (condition, rest) =>
        (yes.instantiate rest).bind fun (yes, rest) =>
          (no.instantiate rest).map fun (no, rest) => (.conditional condition yes no, rest)
  | .sequence first second, events =>
      (first.instantiate events).bind fun (first, rest) =>
        (second.instantiate rest).map fun (second, rest) => (.sequence first second, rest)
  | _, _ => none

structure Composition where
  arguments : Bool
  body : StatementTemplate

def Composition.render (template : Composition) : List ShellToken :=
  header template.arguments ++ template.body.render ++ [.word "end", .word "main", .symbol ";"]

def declarationEvents : Bool → List Event → Option (List Bindings.Declaration × Source × List Event)
  | false, .declarations values _ :: rest => some (values, [], rest)
  | true, .argument fallback :: .declarations values _ :: rest => some (argumentDeclaration :: values, fallback, rest)
  | _, _ => none

def Composition.instantiate (template : Composition) (events : List Event) : Option Instantiated :=
  (declarationEvents template.arguments events).bind fun (declarations, fallback, rest) =>
    (template.body.instantiate rest).bind fun (body, remaining) =>
      if remaining = [] then some ⟨declarations, fallback, body⟩ else none

def Composition.execute (template : Composition) (events : List Event)
    (arguments : Arguments.Runtime.Arguments) : Option Action :=
  (template.instantiate events).bind fun program => program.execute arguments

def composition : Form → Composition
  | .direct => ⟨false, .output⟩
  | .assignment => ⟨false, .sequence (.assign false) .output⟩
  | .argument => ⟨true, .conditional .valid .output .reject⟩
  | .guardedArgument => ⟨true, .conditional .capacity .output .reject⟩
  | .branching => ⟨true, .conditional .valid (.conditional .equal .output .output) .reject⟩
  | .guardedBranching => ⟨true, .conditional .capacity (.conditional .equal .output .output) .reject⟩
  | .result => ⟨true,
      .conditional .valid (.sequence (.conditional .equal (.assign false) (.assign true)) .output) .reject⟩
  | .guardedResult => ⟨true,
      .conditional .capacity (.sequence (.conditional .equal (.assign false) (.assign true)) .output) .reject⟩

theorem rendered_tokens (form : Form) : (composition form).render = form.tokens := by
  cases form <;> decide +kernel

def capacityCondition : Option Nat → Condition
  | none => .valid
  | some bound => .capacity bound

def statement : Body → Statement
  | .output expression => .output expression
  | .assignment update expression => .sequence (.assign update) (.output expression)
  | .argument capacity expression => .conditional (capacityCondition capacity) (.output expression) .reject
  | .branching capacity left right yes no =>
      .conditional (capacityCondition capacity) (.conditional (.equal left right) (.output yes) (.output no)) .reject
  | .result capacity left right yes no expression =>
      .conditional (capacityCondition capacity)
        (.sequence (.conditional (.equal left right) (.assign yes) (.assign no)) (.output expression)) .reject

theorem capacity_condition (arguments : Arguments.Runtime.Arguments) (state : State) (capacity : Option Nat) :
    (capacityCondition capacity).evaluate arguments state = guard state.input capacity arguments := by
  cases capacity <;> simp [capacityCondition, Condition.evaluate, guard]

theorem statement_refines {body : Body} {shape : Shape} {state : State}
    (valid : body.Valid shape) (fits : Fits shape state.input state.values)
    (arguments : Arguments.Runtime.Arguments) :
    (statement body).execute arguments state = some (.finished (body.action arguments state.input state.values)) := by
  cases body with
  | output expression => simp [statement, Statement.execute, Body.action, Expression.left_association]
  | assignment update expression =>
      have length := assignment_length fits valid.1
      simp [statement, Statement.execute, length, Body.action, Expression.left_association]
  | argument capacity expression =>
      simp only [statement, Statement.execute, capacity_condition, Body.action, Expression.left_association]
      split <;> rfl
  | branching capacity left right yes no =>
      simp only [statement, Statement.execute, Body.action, Expression.left_association]
      rw [capacity_condition]
      by_cases accepted : guard state.input capacity arguments = true <;>
        by_cases same : left.evaluate state.values state.input = right.evaluate state.values state.input <;> simp_all [Condition.evaluate]
  | result capacity left right yes no expression =>
      have yesLength := assignment_length fits valid.2.2.2.1
      have noLength := assignment_length fits valid.2.2.2.2.2.1
      simp only [statement, Statement.execute, yesLength, noLength,
        ↓reduceIte, Body.action, Expression.left_association]
      rw [capacity_condition]
      by_cases accepted : guard state.input capacity arguments = true <;>
        by_cases same : left.evaluate state.values state.input = right.evaluate state.values state.input <;> simp_all [Condition.evaluate]

theorem instantiated_decode {form : Form} {events : List Event} {program : Program}
    (decoded : decode form events = some program) :
    (composition form).instantiate events = some ⟨program.declarations, program.fallback, statement program.body⟩ := by
  unfold decode at decoded
  split at decoded <;> simp_all only [Option.some.injEq, reduceCtorEq]
  all_goals subst program
  all_goals rfl

theorem execution_refines {form : Form} {events : List Event} {program : Program}
    (decoded : decode form events = some program) (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    (composition form).execute events arguments = some (program.action arguments) := by
  simp only [Composition.execute, instantiated_decode decoded, Option.bind_some, Instantiated.execute]
  rw [statement_refines valid.2.2.2 (initial_values_fit valid arguments)]
  rfl

end Silver.Compose.Main

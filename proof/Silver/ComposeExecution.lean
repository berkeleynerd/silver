import Silver.ComposeMain

/-! A small statement interpreter for the admitted shells. The same templates
render their source grammar and consume the parser's ordered payloads. Branch
assignments update the fixed-length cell before the common output is evaluated.
This is a proof model, not replacement source passed to GNAT. -/

namespace Silver.Compose.Main

structure State where
  staticValue : Source := []
  dynamicValue : Source := []
  deriving DecidableEq, Repr

inductive Condition
  | valid
  | capacity (bound : Nat)
  | equal (literal : Source)
  deriving DecidableEq, Repr

def Condition.evaluate (arguments : Arguments.Runtime.Arguments) (state : State) : Condition → Bool
  | .valid => Arguments.Runtime.inputIsValid arguments
  | .capacity bound => Arguments.Runtime.inputIsValid arguments && decide (state.dynamicValue.length ≤ bound)
  | .equal literal => decide (state.dynamicValue = literal)

inductive Statement
  | output (expression : Expression)
  | assign (replacement : Source)
  | reject
  | conditional (condition : Condition) (yes no : Statement)
  | sequence (first second : Statement)
  deriving DecidableEq, Repr

inductive Result
  | continuing (state : State)
  | finished (action : Action)
  deriving DecidableEq, Repr

def Statement.execute (arguments : Arguments.Runtime.Arguments) (state : State) : Statement → Option Result
  | .output expression => some (.finished (.output (expression.evaluateLeft state.staticValue state.dynamicValue)))
  | .assign replacement =>
      if replacement.length = state.staticValue.length then
        some (.continuing {state with staticValue := replacement})
      else none
  | .reject => some (.finished .reject)
  | .conditional condition yes no =>
      if condition.evaluate arguments state then yes.execute arguments state else no.execute arguments state
  | .sequence first second => (first.execute arguments state).bind fun result =>
      match result with
      | .continuing next => second.execute arguments next
      | .finished action => some (.finished action)

inductive Declaration
  | static (literal : Source)
  | argument (fallback : Source)
  deriving DecidableEq, Repr

def Declaration.execute (arguments : Arguments.Runtime.Arguments) (state : State) : Declaration → State
  | .static literal => {state with staticValue := literal}
  | .argument fallback => {state with dynamicValue := Arguments.Runtime.firstOrDefault fallback arguments}

structure Instantiated where
  declarations : List Declaration
  body : Statement

def Instantiated.execute (program : Instantiated) (arguments : Arguments.Runtime.Arguments) : Option Action :=
  let state := program.declarations.foldl (fun state declaration => declaration.execute arguments state) {}
  (program.body.execute arguments state).bind fun result =>
    match result with
    | .finished action => some action
    | .continuing _ => none

inductive ConditionTemplate | valid | capacity | equal
  deriving DecidableEq, Repr

def ConditionTemplate.render : ConditionTemplate → List ShellToken
  | .valid => [.word "silver_arguments", .symbol ".", .word "input_is_valid"]
  | .capacity => [.word "silver_arguments", .symbol ".", .word "input_is_valid",
      .word "and", .word "then", .dynamicReference, .symbol "'", .word "length", .symbol "<=", .capacity]
  | .equal => [.dynamicReference, .symbol "=", .literal .ordinary]

def ConditionTemplate.instantiate : ConditionTemplate → List Event → Option (Condition × List Event)
  | .valid, events => some (.valid, events)
  | .capacity, .reference true :: .capacity bound :: rest => some (.capacity bound, rest)
  | .equal, .reference true :: .literal .ordinary literal :: rest => some (.equal literal, rest)
  | _, _ => none

inductive StatementTemplate
  | output
  | assign
  | reject
  | conditional (condition : ConditionTemplate) (yes no : StatementTemplate)
  | sequence (first second : StatementTemplate)
  deriving DecidableEq, Repr

def StatementTemplate.render : StatementTemplate → List ShellToken
  | .output => [.word "silver_io", .symbol ".", .word "put_line", .symbol "(",
      .outputExpression, .symbol ")", .symbol ";"]
  | .assign => [.staticReference, .symbol ":=", .literal .assigned, .symbol ";"]
  | .reject => [.word "silver_arguments", .symbol ".", .word "reject", .symbol ";"]
  | .conditional condition yes no => [.word "if"] ++ condition.render ++ [.word "then"] ++
      yes.render ++ [.word "else"] ++ no.render ++ [.word "end", .word "if", .symbol ";"]
  | .sequence first second => first.render ++ second.render

def StatementTemplate.instantiate : StatementTemplate → List Event → Option (Statement × List Event)
  | .output, .output expression :: rest => some (.output expression, rest)
  | .assign, .reference false :: .literal .assigned replacement :: rest => some (.assign replacement, rest)
  | .reject, events => some (.reject, events)
  | .conditional condition yes no, events =>
      (condition.instantiate events).bind fun (condition, rest) =>
        (yes.instantiate rest).bind fun (yes, rest) =>
          (no.instantiate rest).map fun (no, rest) => (.conditional condition yes no, rest)
  | .sequence first second, events =>
      (first.instantiate events).bind fun (first, rest) =>
        (second.instantiate rest).map fun (second, rest) => (.sequence first second, rest)
  | _, _ => none

inductive DeclarationTemplate
  | static (constant : Bool)
  | argument
  deriving DecidableEq, Repr

def DeclarationTemplate.render : DeclarationTemplate → List ShellToken
  | .static constant => [.staticDeclaration, .symbol ":"] ++
      (if constant then [.word "constant"] else []) ++
      [.word "string", .symbol ":=", .literal .initial, .symbol ";"]
  | .argument => [.dynamicDeclaration, .symbol ":", .word "constant", .word "string", .symbol ":=",
      .word "silver_arguments", .symbol ".", .word "first_or_default", .symbol "(",
      .literal .ordinary, .symbol ")", .symbol ";"]

def DeclarationTemplate.instantiate : DeclarationTemplate → List Event → Option (Declaration × List Event)
  | .static _, .declaration false _ :: .literal .initial literal :: rest => some (.static literal, rest)
  | .argument, .declaration true _ :: .literal .ordinary fallback :: rest => some (.argument fallback, rest)
  | _, _ => none

def instantiateDeclarations : List DeclarationTemplate → List Event → Option (List Declaration × List Event)
  | [], events => some ([], events)
  | declaration :: declarations, events =>
      (declaration.instantiate events).bind fun (declaration, rest) =>
        (instantiateDeclarations declarations rest).map fun (declarations, rest) => (declaration :: declarations, rest)

structure Composition where
  arguments : Bool
  declarations : List DeclarationTemplate
  body : StatementTemplate

def Composition.render (template : Composition) : List ShellToken :=
  [.word "with", .word "silver_io", .symbol ";"] ++
  (if template.arguments then [.word "with", .word "silver_arguments", .symbol ";"] else []) ++
  [.word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode",
   .symbol "(", .word "on", .symbol ")", .symbol ";"] ++
  template.declarations.flatMap DeclarationTemplate.render ++ [.word "begin"] ++
  template.body.render ++ [.word "end", .word "main", .symbol ";"]

def Composition.instantiate (template : Composition) (events : List Event) : Option Instantiated :=
  (instantiateDeclarations template.declarations events).bind fun (declarations, rest) =>
    (template.body.instantiate rest).bind fun (body, remaining) =>
      if remaining = [] then some ⟨declarations, body⟩ else none

def Composition.execute (template : Composition) (events : List Event)
    (arguments : Arguments.Runtime.Arguments) : Option Action :=
  (template.instantiate events).bind fun program => program.execute arguments

def composition : Form → Composition
  | .direct => ⟨false, [], .output⟩
  | .static => ⟨false, [.static true], .output⟩
  | .assignment => ⟨false, [.static false], .sequence .assign .output⟩
  | .argument => ⟨true, [.argument], .conditional .valid .output .reject⟩
  | .guardedArgument => ⟨true, [.argument], .conditional .capacity .output .reject⟩
  | .branching => ⟨true, [.argument], .conditional .valid (.conditional .equal .output .output) .reject⟩
  | .guardedBranching => ⟨true, [.argument], .conditional .capacity (.conditional .equal .output .output) .reject⟩
  | .result => ⟨true, [.argument, .static false],
      .conditional .valid (.sequence (.conditional .equal .assign .assign) .output) .reject⟩
  | .guardedResult => ⟨true, [.argument, .static false],
      .conditional .capacity (.sequence (.conditional .equal .assign .assign) .output) .reject⟩

theorem rendered_tokens (form : Form) : (composition form).render = form.tokens := by
  cases form <;> decide +kernel

set_option backward.isDefEq.respectTransparency false in
theorem execution_refines {form : Form} {events : List Event} {program : Program}
    (decoded : decode form events = some program) (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    (composition form).execute events arguments = some (program.action arguments) := by
  unfold decode at decoded
  split at decoded <;> simp_all +instances only [Option.some.injEq, reduceCtorEq]
  all_goals subst program
  all_goals simp +instances only [Composition.execute, Composition.instantiate, composition,
    instantiateDeclarations, DeclarationTemplate.instantiate, StatementTemplate.instantiate,
    ConditionTemplate.instantiate, Option.bind_some, Option.map_some,
    ↓reduceIte, Instantiated.execute, List.foldl, Declaration.execute,
    Statement.execute, Condition.evaluate, Expression.left_association,
    Program.action, selected, guard, Bool.and_true] at *
  all_goals try dsimp +instances at *
  all_goals simp_all +instances [Program.Valid]
  all_goals (try split) <;> try simp_all +instances
  all_goals (try split) <;> try simp_all +instances
  all_goals (try split) <;> try simp_all +instances
  all_goals intro accepted; simp +instances only [decide_eq_false_iff_not]; omega

end Silver.Compose.Main

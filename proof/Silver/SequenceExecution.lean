module

public import Silver.SequenceSemantics

@[expose] public section

/-! An ordinary execution model retains Ada's assignment length check and
left-associated expression evaluation. Membership's shared fixed-shape rules
make that check succeed at every sequential state and on either choice arm. -/

namespace Silver.Sequence
open Bindings Compose

def SimpleStatement.checkedExecute (input : Source) (values : Values) :
    SimpleStatement → Option Execution
  | .null => some ⟨values, []⟩
  | .assign update =>
      if (update.value.evaluateLeft values input).length = (values update.target).length then
        some ⟨put values update.target (update.value.evaluateLeft values input), []⟩
      else none
  | .output expression => some ⟨values, [.output (expression.evaluateLeft values input)]⟩

def checkedSimple (input : Source) (values : Values) : List SimpleStatement → Option Execution
  | [] => some ⟨values, []⟩
  | item :: rest => (item.checkedExecute input values).bind fun first =>
      (checkedSimple input first.values rest).map fun following =>
        ⟨following.values, first.effects ++ following.effects⟩

def Statement.checkedExecute (input : Source) (values : Values) : Statement → Option Execution
  | .simple item => item.checkedExecute input values
  | .choice left right yes no =>
      checkedSimple input values
        (if left.evaluateLeft values input = right.evaluateLeft values input then yes else no)

def checkedStatements (input : Source) (values : Values) : List Statement → Option Execution
  | [] => some ⟨values, []⟩
  | item :: rest => (item.checkedExecute input values).bind fun first =>
      (checkedStatements input first.values rest).map fun following =>
        ⟨following.values, first.effects ++ following.effects⟩

def Body.checkedExecute (arguments : Arguments.Runtime.Arguments) (input : Source)
    (values : Values) (body : Body) : Option Execution :=
  if body.shell.guard input arguments then checkedStatements input values body.statements
  else some ⟨values, [.reject]⟩

def Program.checkedExecute (arguments : Arguments.Runtime.Arguments) (program : Program) : Option Execution :=
  program.body.checkedExecute arguments (selected program.fallback arguments) (program.initialValues arguments)

theorem simple_execution_refines {item : SimpleStatement} {shape : Shape} {capacity : Nat}
    {input : Source} {values : Values} (valid : item.Valid shape capacity)
    (state : Fits shape input values) :
    item.checkedExecute input values = some (item.execute input values) := by
  cases item with
  | null => rfl
  | assign update =>
      simp [SimpleStatement.checkedExecute, Expression.left_association,
        assignment_length state valid.1, SimpleStatement.execute, Assignment.execute]
  | output expression =>
      simp [SimpleStatement.checkedExecute, Expression.left_association, SimpleStatement.execute]

theorem simple_sequence_refines {items : List SimpleStatement} {shape : Shape} {capacity : Nat}
    {input : Source} {values : Values} (valid : SimpleStatementsValid shape capacity items)
    (state : Fits shape input values) (printable : Bindings.Printable input) (bound : input.length ≤ capacity) :
    checkedSimple input values items = some (executeSimple input values items) := by
  induction items generalizing values with
  | nil => rfl
  | cons item rest ih =>
      have headValid := valid item (by simp)
      have first := simple_execution_valid headValid state printable bound
      simp only [checkedSimple, simple_execution_refines headValid state, Option.bind_some,
        ih (fun item member => valid item (by simp [member])) first.1, Option.map_some, executeSimple]

theorem statement_execution_refines {item : Statement} {shape : Shape} {capacity : Nat}
    {input : Source} {values : Values} (valid : item.Valid shape capacity)
    (state : Fits shape input values) (printable : Bindings.Printable input) (bound : input.length ≤ capacity) :
    item.checkedExecute input values = some (item.execute input values) := by
  cases item with
  | simple item => exact simple_execution_refines valid state
  | choice left right yes no =>
      simp only [Statement.checkedExecute, Statement.execute, Expression.left_association]
      split
      · exact simple_sequence_refines valid.2.2.2.2.1 state printable bound
      · exact simple_sequence_refines valid.2.2.2.2.2 state printable bound

theorem statements_execution_refines {items : List Statement} {shape : Shape} {capacity : Nat}
    {input : Source} {values : Values} (valid : StatementsValid shape capacity items)
    (state : Fits shape input values) (printable : Bindings.Printable input) (bound : input.length ≤ capacity) :
    checkedStatements input values items = some (executeStatements input values items) := by
  induction items generalizing values with
  | nil => rfl
  | cons item rest ih =>
      have headValid := valid item (by simp)
      have first := statement_execution_valid headValid state printable bound
      simp only [checkedStatements, statement_execution_refines headValid state printable bound, Option.bind_some,
        ih (fun item member => valid item (by simp [member])) first.1, Option.map_some, executeStatements]

theorem body_execution_refines {body : Body} {shape : Shape} {input : Source} {values : Values}
    (valid : body.Valid shape) (state : Fits shape input values)
    (domain : input.length ≤ maxSourceLength ∧ Bindings.Printable input)
    (arguments : Arguments.Runtime.Arguments) :
    body.checkedExecute arguments input values = some (body.execute arguments input values) := by
  simp only [Body.checkedExecute, Body.execute]
  split
  · rename_i accepted
    exact statements_execution_refines valid.2.2 state domain.2 (shell_guard_bound domain.1 accepted)
  · rfl

theorem program_execution_refines {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    program.checkedExecute arguments = some (program.execute arguments) :=
  body_execution_refines valid.2.2.2 (initial_values_fit valid arguments)
    (selected_domain program.fallback arguments) arguments

end Silver.Sequence

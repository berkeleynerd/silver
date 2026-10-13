module

public import Silver.ComposeDeclarations
public import Silver.GuardedObligations

@[expose] public section

/-! The retained body shapes operate over one shared ordered binding region.
Static metadata determines fixed object bounds; the value store follows Ada's
sequential elaboration and branch-local assignments. -/

namespace Silver.Compose
open Bindings

abbrev Printable := Bindings.Printable

def effectiveCapacity (capacity : Option Nat) : Nat := capacity.getD maxSourceLength

inductive Body
  | output (expression : Expression)
  | assignment (assignment : Bindings.Assignment) (expression : Expression)
  | argument (capacity : Option Nat) (expression : Expression)
  | branching (capacity : Option Nat) (left right : Expression) (yes no : Expression)
  | result (capacity : Option Nat) (left right : Expression)
      (yes no : Bindings.Assignment) (expression : Expression)
  deriving DecidableEq, Repr

structure Program where
  declarations : List Bindings.Declaration
  names : BindingEnvironment
  fallback : Source
  body : Body
  deriving DecidableEq, Repr

def Body.Valid (shape : Shape) : Body → Prop
  | .output expression => SafeExpression expression shape maxSourceLength
  | .assignment update expression => update.Valid shape ∧
      SafeExpression update.value shape maxSourceLength ∧ SafeExpression expression shape maxSourceLength
  | .argument capacity expression => effectiveCapacity capacity ≤ maxSourceLength ∧
      SafeExpression expression shape (effectiveCapacity capacity)
  | .branching capacity left right yes no => effectiveCapacity capacity ≤ maxSourceLength ∧
      SafeExpression left shape (effectiveCapacity capacity) ∧
      SafeExpression right shape (effectiveCapacity capacity) ∧
      SafeExpression yes shape (effectiveCapacity capacity) ∧
      SafeExpression no shape (effectiveCapacity capacity)
  | .result capacity left right yes no expression => effectiveCapacity capacity ≤ maxSourceLength ∧
      SafeExpression left shape (effectiveCapacity capacity) ∧
      SafeExpression right shape (effectiveCapacity capacity) ∧ yes.Valid shape ∧
      SafeExpression yes.value shape (effectiveCapacity capacity) ∧ no.Valid shape ∧
      SafeExpression no.value shape (effectiveCapacity capacity) ∧
      SafeExpression expression shape (effectiveCapacity capacity)

def Program.Valid (program : Program) : Prop :=
  Bindings.DeclarationsValid emptyShape program.declarations program.names.shape ∧
    Printable program.fallback ∧ program.fallback.length ≤ maxSourceLength ∧
    program.body.Valid program.names.shape

inductive Action
  | reject
  | output (bytes : Source)
  deriving DecidableEq, Repr

def selected (fallback : Source) (arguments : Arguments.Runtime.Arguments) : Source :=
  Arguments.Runtime.firstOrDefault fallback arguments

def guard (input : Source) (capacity : Option Nat) (arguments : Arguments.Runtime.Arguments) : Bool :=
  Arguments.Runtime.inputIsValid arguments &&
    match capacity with
    | none => true
    | some bound => decide (input.length ≤ bound)

def Body.action (arguments : Arguments.Runtime.Arguments) (input : Source) (values : Values) : Body → Action
  | .output expression => .output (expression.evaluate values input)
  | .assignment update expression => .output (expression.evaluate (update.execute values input) input)
  | .argument capacity expression =>
      if guard input capacity arguments then .output (expression.evaluate values input) else .reject
  | .branching capacity left right yes no =>
      if guard input capacity arguments then
        .output ((if left.evaluate values input = right.evaluate values input then yes else no).evaluate values input)
      else .reject
  | .result capacity left right yes no expression =>
      if guard input capacity arguments then
        .output (expression.evaluate ((if left.evaluate values input = right.evaluate values input then yes else no).execute values input) input)
      else .reject

def Program.initialValues (program : Program) (arguments : Arguments.Runtime.Arguments) : Values :=
  executeDeclarations (selected program.fallback arguments) program.declarations emptyValues

def Program.action (arguments : Arguments.Runtime.Arguments) (program : Program) : Action :=
  program.body.action arguments (selected program.fallback arguments) (program.initialValues arguments)

theorem selected_domain (fallback : Source) (arguments : Arguments.Runtime.Arguments) :
    (selected fallback arguments).length ≤ maxSourceLength ∧ Printable (selected fallback arguments) := by
  have domain := (Arguments.Runtime.message_iff _).mp
    (Arguments.Runtime.initializer_domain arguments fallback)
  exact ⟨domain.1, fun byte member => decide_eq_true (domain.2 byte member)⟩

theorem guarded_length {input : Source} {capacity : Option Nat} {arguments : Arguments.Runtime.Arguments}
    (domain : input.length ≤ maxSourceLength) (accepted : guard input capacity arguments = true) :
    input.length ≤ effectiveCapacity capacity := by
  cases capacity with
  | none => exact domain
  | some capacity =>
      simp only [guard, Bool.and_eq_true, decide_eq_true_eq] at accepted
      exact accepted.2

theorem expression_domain {expression : Expression} {shape : Shape} {values : Values} {input : Source}
    {capacity : Nat} (safe : SafeExpression expression shape capacity) (state : Fits shape input values)
    (printable : Printable input) (fits : input.length ≤ capacity) :
    (expression.evaluate values input).length ≤ maxSourceLength ∧ Printable (expression.evaluate values input) :=
  ⟨Expression.output_bound safe state fits,
    Expression.evaluate_printable safe.1 safe.2.1 state printable⟩

theorem body_action_domain {body : Body} {shape : Shape} {values : Values} {input : Source}
    (valid : body.Valid shape) (state : Fits shape input values)
    (domain : input.length ≤ maxSourceLength ∧ Printable input)
    (arguments : Arguments.Runtime.Arguments) {bytes : Source}
    (output : body.action arguments input values = .output bytes) :
    bytes.length ≤ maxSourceLength ∧ Printable bytes := by
  cases body with
  | output expression =>
      cases output
      exact expression_domain valid state domain.2 domain.1
  | assignment assignment expression =>
      cases output
      exact expression_domain valid.2.2 (Bindings.assignment_preserves state domain.2 valid.1) domain.2 domain.1
  | argument capacity expression =>
      simp only [Body.action] at output
      split at output
      · rename_i accepted
        cases output
        exact expression_domain valid.2 state domain.2 (guarded_length domain.1 accepted)
      · cases output
  | branching capacity left right yes no =>
      simp only [Body.action] at output
      split at output
      · rename_i accepted
        cases output
        apply expression_domain
        · split <;> first | exact valid.2.2.2.1 | exact valid.2.2.2.2
        · exact state
        · exact domain.2
        · exact guarded_length domain.1 accepted
      · cases output
  | result capacity left right yes no expression =>
      simp only [Body.action] at output
      split at output
      · rename_i accepted
        cases output
        apply expression_domain valid.2.2.2.2.2.2.2
        · apply Bindings.assignment_preserves state domain.2
          split <;> first | exact valid.2.2.2.1 | exact valid.2.2.2.2.2.1
        · exact domain.2
        · exact guarded_length domain.1 accepted
      · cases output

theorem initial_values_fit {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) :
    Fits program.names.shape (selected program.fallback arguments) (program.initialValues arguments) :=
  declarations_preserve valid.1 _ (selected_domain program.fallback arguments).2 _ (empty_fits _)

theorem action_domain {program : Program} (valid : program.Valid)
    (arguments : Arguments.Runtime.Arguments) {bytes : Source}
    (output : program.action arguments = .output bytes) :
    bytes.length ≤ maxSourceLength ∧ Printable bytes :=
  body_action_domain valid.2.2.2 (initial_values_fit valid arguments)
    (selected_domain program.fallback arguments) arguments output

end Silver.Compose

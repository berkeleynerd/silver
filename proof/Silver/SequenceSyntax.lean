module

public import Silver.ComposeMain

@[expose] public section

/-! Finite statement composition over the existing initialized String store.
Equality choices have simple, nonempty arms; broader conditional nesting and
Boolean predicates are separate language work. -/

namespace Silver.Sequence
open Bindings Compose

inductive SimpleStatement
  | null
  | assign (update : Assignment)
  | output (expression : Expression)
  deriving DecidableEq, Repr

inductive Statement
  | simple (item : SimpleStatement)
  | choice (left right : Expression) (yes no : List SimpleStatement)
  deriving DecidableEq, Repr

inductive Shell
  | static
  | argument
  | guardedArgument (bound : Nat)
  deriving DecidableEq, Repr

def Shell.capacity : Shell → Nat
  | .guardedArgument bound => bound
  | _ => maxSourceLength

def Shell.hasArguments : Shell → Bool
  | .static => false
  | _ => true

structure Body where
  shell : Shell
  statements : List Statement
  deriving DecidableEq, Repr

structure Program where
  declarations : List Declaration
  names : Bindings.BindingEnvironment
  fallback : Source
  body : Body
  deriving DecidableEq, Repr

def SimpleStatement.hasAssignment : SimpleStatement → Bool
  | .assign _ => true
  | _ => false

def SimpleStatement.hasOutput : SimpleStatement → Bool
  | .output _ => true
  | _ => false

def Statement.hasAssignment : Statement → Bool
  | .simple item => item.hasAssignment
  | .choice _ _ yes no => yes.any SimpleStatement.hasAssignment || no.any SimpleStatement.hasAssignment

def Statement.hasOutput : Statement → Bool
  | .simple item => item.hasOutput
  | .choice _ _ yes no => yes.any SimpleStatement.hasOutput || no.any SimpleStatement.hasOutput

def Body.hasAssignment (body : Body) : Bool := body.statements.any Statement.hasAssignment

def Body.hasOutput (body : Body) : Bool := body.statements.any Statement.hasOutput

def SimpleStatement.Valid (shape : Shape) (capacity : Nat) : SimpleStatement → Prop
  | .null => True
  | .assign update => update.Valid shape ∧ SafeExpression update.value shape capacity
  | .output expression => SafeExpression expression shape capacity

def SimpleStatementsValid (shape : Shape) (capacity : Nat) (items : List SimpleStatement) : Prop :=
  ∀ item ∈ items, item.Valid shape capacity

def Statement.Valid (shape : Shape) (capacity : Nat) : Statement → Prop
  | .simple item => item.Valid shape capacity
  | .choice left right yes no =>
      SafeExpression left shape capacity ∧ SafeExpression right shape capacity ∧
      yes ≠ [] ∧ no ≠ [] ∧ SimpleStatementsValid shape capacity yes ∧
      SimpleStatementsValid shape capacity no

def StatementsValid (shape : Shape) (capacity : Nat) (items : List Statement) : Prop :=
  ∀ item ∈ items, item.Valid shape capacity

def Body.Valid (shape : Shape) (body : Body) : Prop :=
  body.shell.capacity ≤ maxSourceLength ∧ body.statements ≠ [] ∧
    StatementsValid shape body.shell.capacity body.statements

def Program.Valid (program : Program) : Prop :=
  DeclarationsValid emptyShape program.declarations program.names.shape ∧
    Bindings.Printable program.fallback ∧ program.fallback.length ≤ maxSourceLength ∧
    program.body.Valid program.names.shape

inductive Effect
  | output (bytes : Source)
  | reject
  deriving DecidableEq, Repr

def Effect.Valid : Effect → Prop
  | .output bytes => bytes.length ≤ maxSourceLength ∧ Bindings.Printable bytes
  | .reject => True

def EffectsValid (effects : List Effect) : Prop := ∀ effect ∈ effects, effect.Valid

end Silver.Sequence

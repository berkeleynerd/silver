module

public import Silver.ComposeMain

@[expose] public section

/-! Finite recursive statement composition over the initialized String store.
The alternative constructors retain omitted else and elsif spelling separately
from their execution meaning. -/

namespace Silver.Sequence
open Bindings Compose

inductive SimpleStatement
  | null
  | assign (update : Assignment)
  | output (expression : Expression)
  | put (expression : Expression)
  deriving DecidableEq, Repr

mutual
  inductive Statement
    | simple (item : SimpleStatement)
    | choice (left right : Expression) (yes : List Statement) (tail : Alternative)
    deriving Repr
  inductive Alternative
    | absent
    | otherwise (items : List Statement)
    | elsif (left right : Expression) (yes : List Statement) (tail : Alternative)
    deriving Repr
end

mutual
  def statementDecEq (a b : Statement) : Decidable (a = b) :=
    match a, b with
    | .simple x, .simple y => decidable_of_iff (x = y) (by simp only [Statement.simple.injEq])
    | .choice l r yes tail, .choice l' r' yes' tail' =>
        letI : Decidable (yes = yes') := statementsDecEq yes yes'
        letI : Decidable (tail = tail') := alternativeDecEq tail tail'
        decidable_of_iff (l = l' ∧ r = r' ∧ yes = yes' ∧ tail = tail')
          (by simp only [Statement.choice.injEq])
    | .simple _, .choice _ _ _ _ => isFalse (by intro h; cases h)
    | .choice _ _ _ _, .simple _ => isFalse (by intro h; cases h)
  termination_by sizeOf a
  def alternativeDecEq (a b : Alternative) : Decidable (a = b) :=
    match a, b with
    | .absent, .absent => isTrue rfl
    | .otherwise items, .otherwise items' =>
        letI : Decidable (items = items') := statementsDecEq items items'
        decidable_of_iff (items = items') (by simp only [Alternative.otherwise.injEq])
    | .elsif l r yes tail, .elsif l' r' yes' tail' =>
        letI : Decidable (yes = yes') := statementsDecEq yes yes'
        letI : Decidable (tail = tail') := alternativeDecEq tail tail'
        decidable_of_iff (l = l' ∧ r = r' ∧ yes = yes' ∧ tail = tail')
          (by simp only [Alternative.elsif.injEq])
    | .absent, .otherwise _ | .absent, .elsif _ _ _ _ |
      .otherwise _, .absent | .otherwise _, .elsif _ _ _ _ |
      .elsif _ _ _ _, .absent | .elsif _ _ _ _, .otherwise _ => isFalse (by intro h; cases h)
  termination_by sizeOf a
  def statementsDecEq (a b : List Statement) : Decidable (a = b) :=
    match a, b with
    | [], [] => isTrue rfl
    | x :: xs, y :: ys =>
        letI : Decidable (x = y) := statementDecEq x y
        letI : Decidable (xs = ys) := statementsDecEq xs ys
        decidable_of_iff (x = y ∧ xs = ys) (by simp only [List.cons.injEq])
    | [], _ :: _ | _ :: _, [] => isFalse (by intro h; cases h)
  termination_by sizeOf a
end

instance : DecidableEq Statement := statementDecEq
instance : DecidableEq Alternative := alternativeDecEq

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
  | .output _ | .put _ => true
  | _ => false

mutual
  def Statement.hasAssignment : Statement → Bool
    | .simple item => item.hasAssignment
    | .choice _ _ yes tail => statementsHaveAssignment yes || tail.hasAssignment
  termination_by item => sizeOf item
  def Alternative.hasAssignment : Alternative → Bool
    | .absent => false
    | .otherwise items => statementsHaveAssignment items
    | .elsif _ _ yes tail => statementsHaveAssignment yes || tail.hasAssignment
  termination_by tail => sizeOf tail
  def statementsHaveAssignment : List Statement → Bool
    | [] => false
    | item :: rest => item.hasAssignment || statementsHaveAssignment rest
  termination_by items => sizeOf items
end

mutual
  def Statement.hasOutput : Statement → Bool
    | .simple item => item.hasOutput
    | .choice _ _ yes tail => statementsHaveOutput yes || tail.hasOutput
  termination_by item => sizeOf item
  def Alternative.hasOutput : Alternative → Bool
    | .absent => false
    | .otherwise items => statementsHaveOutput items
    | .elsif _ _ yes tail => statementsHaveOutput yes || tail.hasOutput
  termination_by tail => sizeOf tail
  def statementsHaveOutput : List Statement → Bool
    | [] => false
    | item :: rest => item.hasOutput || statementsHaveOutput rest
  termination_by items => sizeOf items
end

def Body.hasAssignment (body : Body) : Bool := body.statements.any Statement.hasAssignment

def Body.hasOutput (body : Body) : Bool := body.statements.any Statement.hasOutput

def SimpleStatement.Valid (shape : Shape) (capacity : Nat) : SimpleStatement → Prop
  | .null => True
  | .assign update => update.Valid shape ∧ SafeExpression update.value shape capacity
  | .output expression | .put expression => SafeExpression expression shape capacity

def SimpleStatementsValid (shape : Shape) (capacity : Nat) (items : List SimpleStatement) : Prop :=
  ∀ item ∈ items, item.Valid shape capacity

mutual
  def Statement.Valid (shape : Shape) (capacity : Nat) : Statement → Prop
    | .simple item => item.Valid shape capacity
    | .choice left right yes tail =>
        SafeExpression left shape capacity ∧ SafeExpression right shape capacity ∧
        yes ≠ [] ∧ StatementsValid shape capacity yes ∧ tail.Valid shape capacity
  termination_by item => sizeOf item
  def Alternative.Valid (shape : Shape) (capacity : Nat) : Alternative → Prop
    | .absent => True
    | .otherwise items => items ≠ [] ∧ StatementsValid shape capacity items
    | .elsif left right yes tail =>
        SafeExpression left shape capacity ∧ SafeExpression right shape capacity ∧
        yes ≠ [] ∧ StatementsValid shape capacity yes ∧ tail.Valid shape capacity
  termination_by tail => sizeOf tail
  def StatementsValid (shape : Shape) (capacity : Nat) : List Statement → Prop
    | [] => True
    | item :: rest => item.Valid shape capacity ∧ StatementsValid shape capacity rest
  termination_by items => sizeOf items
end

theorem statementsValid_iff {shape : Shape} {capacity : Nat} {items : List Statement} :
    StatementsValid shape capacity items ↔ ∀ item ∈ items, item.Valid shape capacity := by
  induction items with
  | nil => simp [StatementsValid]
  | cons item rest ih => simp only [StatementsValid, ih, List.mem_cons, forall_eq_or_imp]

theorem statementsHaveAssignment_eq_any (items : List Statement) :
    statementsHaveAssignment items = items.any Statement.hasAssignment := by
  induction items with
  | nil => simp only [statementsHaveAssignment, List.any_nil]
  | cons item rest ih => simp only [statementsHaveAssignment, List.any_cons, ih]

theorem statementsHaveOutput_eq_any (items : List Statement) :
    statementsHaveOutput items = items.any Statement.hasOutput := by
  induction items with
  | nil => simp only [statementsHaveOutput, List.any_nil]
  | cons item rest ih => simp only [statementsHaveOutput, List.any_cons, ih]

def Body.Valid (shape : Shape) (body : Body) : Prop :=
  body.shell.capacity ≤ maxSourceLength ∧ body.statements ≠ [] ∧
    StatementsValid shape body.shell.capacity body.statements

def Program.Valid (program : Program) : Prop :=
  DeclarationsValid emptyShape program.declarations program.names.shape ∧
    Bindings.Printable program.fallback ∧ program.fallback.length ≤ maxSourceLength ∧
    program.body.Valid program.names.shape

inductive Effect
  | output (bytes : Source)
  | put (bytes : Source)
  | reject
  deriving DecidableEq, Repr

def Effect.Valid : Effect → Prop
  | .output bytes | .put bytes => bytes.length ≤ maxSourceLength ∧ Bindings.Printable bytes
  | .reject => True

def EffectsValid (effects : List Effect) : Prop := ∀ effect ∈ effects, effect.Valid

end Silver.Sequence

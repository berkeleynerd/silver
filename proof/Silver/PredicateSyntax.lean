module

public import Silver.ComposeExpression
public import Silver.IntegerChecks
public import Silver.IntegerComparisons
public import Silver.StringExecution
public import Silver.BooleanModel
public import Silver.BooleanArrays

@[expose] public section

/-! Predicate syntax keeps grouping and each short-circuit operator explicit.
Integer spelling belongs to the source reading; this tree retains its value.
Grammar excludes mixed unparenthesized Boolean chains. -/

namespace Silver.Predicate
open Bindings Compose

inductive Comparison
  | eq | ne | lt | le | gt | ge
  deriving DecidableEq, Repr

inductive LengthOperand
  | literal (value : Nat)
  | binding (index : Nat)
  deriving DecidableEq, Repr

inductive Condition
  | stringCompare (unequal : Bool) (left right : Expression)
  | lengthCompare (operator : Comparison) (leftBinding : Nat) (right : LengthOperand)
  | scalarCompare (operator : Integer.Comparison) (left right : Integer.Expr)
  | characterCompare (operator : Comparison) (left right : Character.Expr)
  | inputValid
  | booleanLiteral (value : Bool)
  | booleanName (index : Nat)
  | booleanArrayRead (array : Boolean.ArrayDescriptor) (index : Integer.Expr)
  | parenthesized (inner : Condition)
  | negated (inner : Condition)
  | andThen (left right : Condition)
  | orElse (left right : Condition)
  | eager (operator : Boolean.Operator) (left right : Condition)
  | booleanCompare (unequal : Bool) (left right : Condition)
  deriving DecidableEq, Repr

def Condition.isPrimary : Condition → Bool
  | .inputValid | .booleanLiteral _ | .booleanName _ | .booleanArrayRead _ _ | .parenthesized _ => true
  | _ => false

def Condition.isFactor : Condition → Bool
  | .negated inner => inner.isPrimary
  | inner => inner.isPrimary

def Condition.isRelation : Condition → Bool
  | .andThen _ _ | .orElse _ _ | .eager _ _ _ => false
  | _ => true

def Condition.isAndHead : Condition → Bool
  | .orElse _ _ | .eager _ _ _ => false
  | _ => true

def Condition.isOrHead : Condition → Bool
  | .andThen _ _ | .eager _ _ _ => false
  | _ => true

def Condition.isEagerHead (operator : Boolean.Operator) : Condition → Bool
  | .andThen _ _ | .orElse _ _ => false
  | .eager prior _ _ => prior == operator
  | _ => true

/-- A chain associates to the left and uses one Boolean operator. Parentheses
start a fresh condition. Ada's `not` applies to one primary, not a relation. -/
def Condition.Grammatical : Condition → Prop
  | .stringCompare _ _ _ | .lengthCompare _ _ _ | .scalarCompare _ _ _ | .characterCompare _ _ _ | .inputValid |
      .booleanLiteral _ | .booleanName _ | .booleanArrayRead _ _ => True
  | .parenthesized inner => inner.Grammatical
  | .negated inner => inner.isPrimary = true ∧ inner.Grammatical
  | .andThen left right =>
      left.isAndHead = true ∧ right.isRelation = true ∧ left.Grammatical ∧ right.Grammatical
  | .orElse left right =>
      left.isOrHead = true ∧ right.isRelation = true ∧ left.Grammatical ∧ right.Grammatical
  | .eager operator left right =>
      left.isEagerHead operator = true ∧ right.isRelation = true ∧ left.Grammatical ∧ right.Grammatical
  | .booleanCompare _ left right =>
      left.isFactor = true ∧ right.isFactor = true ∧ left.Grammatical ∧ right.Grammatical

def LengthOperand.Readable (shape : Shape) : LengthOperand → Prop
  | .literal value => value ≤ maxSourceLength
  | .binding index => ∃ info, shape index = some info

def LengthOperand.summary (shape : Shape) : LengthOperand → Option Summary
  | .literal value => some ⟨value, 0⟩
  | .binding index => (shape index).map fun info => info.bound.summary

/-- All names resolve even on an unreachable path. Only the evaluation bounds
may use path facts; validity calls also require the argument package context. -/
def Condition.Readable (hasArguments : Bool) (shape : Shape) (condition : Condition)
    (booleans : Boolean.Analysis := {}) : Prop :=
  match condition with
  | .stringCompare _ left right =>
      left.StringReadable shape ∧ right.StringReadable shape ∧ left.LiteralsPrintable ∧ right.LiteralsPrintable ∧
      left ≠ [] ∧ left.length ≤ maxExpressionOperands ∧
      right ≠ [] ∧ right.length ≤ maxExpressionOperands
  | .lengthCompare _ left right => (∃ info, shape left = some info) ∧ right.Readable shape
  | .scalarCompare _ _ _ => True
  | .characterCompare _ left right =>
      left.Readable shape.fixedLengths ∧ right.Readable shape.fixedLengths ∧
      left.PrintableLiterals ∧ right.PrintableLiterals
  | .inputValid => hasArguments = true
  | .booleanLiteral _ => True
  | .booleanName index => booleans.initialized index = true
  | .booleanArrayRead array _ => array.initialized booleans = true
  | .parenthesized inner | .negated inner => inner.Readable hasArguments shape booleans
  | .andThen left right | .orElse left right | .eager _ left right | .booleanCompare _ left right =>
      left.Readable hasArguments shape booleans ∧ right.Readable hasArguments shape booleans

end Silver.Predicate

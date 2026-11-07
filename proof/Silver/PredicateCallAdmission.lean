module

public import Silver.PredicateConditionAdmission
public import Silver.FunctionBindings

@[expose] public section

/-! The source-facing call reader uses one incoming flow for all actuals.
The signature table contains only already completed function declarations. -/
namespace Silver.Predicate
open Compose

structure CallResult where
  after : Nat := 0
  kind : FunctionBindings.ScalarKind := .integer
  bounds : Integer.Interval := .empty
  deriving DecidableEq, Repr

def invalidCall : CallResult := {}

def actualAfter (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (parameter : FunctionBindings.Formal) : Nat :=
  if parameter.kind = .boolean then (readCondition text context position facts).after
  else
    let value := readScalarInFlow text context position facts
    if value.after = 0 ∨ value.bounds.isEmpty ∨ !value.bounds.included parameter.bounds
    then 0 else value.after

def actualsAfter (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (catalog : FunctionBindings.Metadata) (first last : Nat) : Nat :=
  let after := actualAfter text context position facts (FunctionBindings.parameter catalog first)
  if after = 0 then 0
  else if first = last then fixedAfter text after ")" false
  else if _within : first < last then
    actualsAfter text context (fixedAfter text after "," false) facts catalog (first + 1) last
  else 0
termination_by last - first

def calleeAt (text : Source) (context : ParseContext) (position : Nat)
    (catalog : FunctionBindings.Metadata) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  if first = 0 ∨ after ≤ first ∨ lookupName text context.names first after ≠ 0 ∨
      ScalarExpression.lookup text context.scalarNames first after ≠ 0 ∨
      BooleanBindings.lookup text context.booleanNames first after ≠ 0 ∨
      ArrayBindings.lookup text context.arrayNames first after ≠ 0
  then 0 else FunctionBindings.lookup text catalog first after

def readCall (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (catalog : FunctionBindings.Metadata) : CallResult :=
  let callee := calleeAt text context position catalog
  if callee = 0 then invalidCall else
    let item := FunctionBindings.signature catalog callee
    let start := fixedAfter text (nameAfter text (skipAt text position)) "(" false
    let after := actualsAfter text context start facts catalog item.formalFirst
      (item.formalFirst + item.count - 1)
    if after ≤ position then invalidCall else ⟨after, item.resultKind, item.resultBounds⟩

theorem calleeAt_bound (text : Source) (context : ParseContext) (position : Nat)
    (catalog : FunctionBindings.Metadata) : calleeAt text context position catalog ≤ catalog.items.length := by
  dsimp only [calleeAt]
  split
  · exact Nat.zero_le _
  · exact FunctionBindings.lookup_bound ..

end Silver.Predicate

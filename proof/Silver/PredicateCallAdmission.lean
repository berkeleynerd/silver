module

public import Silver.PredicateConditionAdmission
public import Silver.PredicateFunctionCallArrayActual
public import Silver.FunctionBindings
public import Silver.PredicateAssociationAdmission

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
  if parameter.typeId ≠ 0 then arrayActualAfter text context position parameter.typeId
  else if parameter.kind = .boolean then (readCondition text context position facts).after
  else
    let value := readScalarInFlow text context position facts
    if value.after = 0 ∨ value.bounds.isEmpty ∨ !value.bounds.included parameter.bounds
    then 0 else value.after

/-- Rejected cursors stay rejected for both scalar result kinds. -/
theorem actualAfter_zero (text : Source) (context : ParseContext)
    (facts : ActiveFlow) (parameter : FunctionBindings.Formal) :
    actualAfter text context 0 facts parameter = 0 := by
  unfold actualAfter
  split
  · exact arrayActualAfter_zero ..
  split
  · rw [readCondition, readRelation]
    rfl
  · have scalar : readScalarInFlow text context 0 facts = ScalarExpression.invalid :=
      ScalarExpression.ArrayGrammar.read_zero ..
    simp [scalar, ScalarExpression.invalid]

def functionActualsTailModel (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (catalog : FunctionBindings.Metadata) (first last ordinal : Nat)
    (named : Bool) (seen : FormalSet) : Nat :=
  let association := functionAssociation text position catalog first last ordinal named
  if association.formal = 0 ∨ seen association.formal then 0
  else
    let after := actualAfter text context association.payloadFirst facts
      (FunctionBindings.parameter catalog association.formal)
    if after = 0 then 0
    else if ordinal = last then fixedAfter text after ")" false
    else if fixedAfter text after "," false = 0 then 0
    else if _within : ordinal < last then
      functionActualsTailModel text context (fixedAfter text after "," false) facts catalog
        first last (ordinal + 1) association.named (markFormal seen association.formal)
    else 0
termination_by last - ordinal

def actualsAfter (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (catalog : FunctionBindings.Metadata) (first last : Nat) : Nat :=
  functionActualsTailModel text context position facts catalog first last first false noFormals

theorem functionActualsTailModel_zero (text : Source) (context : ParseContext)
    (facts : ActiveFlow) (catalog : FunctionBindings.Metadata) (first last ordinal : Nat)
    (named : Bool) (seen : FormalSet) :
    functionActualsTailModel text context 0 facts catalog first last ordinal named seen = 0 := by
  rw [functionActualsTailModel, functionAssociation_zero]
  rfl

theorem actualsAfter_zero (text : Source) (context : ParseContext)
    (facts : ActiveFlow) (catalog : FunctionBindings.Metadata) (first last : Nat) :
    actualsAfter text context 0 facts catalog first last = 0 :=
  functionActualsTailModel_zero ..

def calleeAt (text : Source) (context : ParseContext) (position : Nat)
    (catalog : FunctionBindings.Metadata) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  if first = 0 ∨ after ≤ first ∨ lookupName text context.names first after ≠ 0 ∨
      ScalarExpression.lookup text context.scalarNames first after ≠ 0 ∨
      BooleanBindings.lookup text context.booleanNames first after ≠ 0 ∨
      ArrayBindings.lookup text context.arrayNames first after ≠ 0 ∨
      ArrayBindings.lookupType text context.arrayTypes first after ≠ 0
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

module

public import Silver.PredicateBodyPrimitives
public import Silver.ProcedureNameScanner

@[expose] public section

/-! Procedure-call admission makes two passes over the source associations.
Every input read uses the original flow, while the second pass accumulates
declared output ranges only after the lexical alias checks succeed. -/
namespace Silver.Predicate
open Compose

structure ProcedureActualResult where
  first : Nat := 0
  after : Nat := 0
  scalar : Nat := 0
  flag : Nat := 0
  deriving DecidableEq, Repr

def invalidProcedureActual : ProcedureActualResult := {}

def procedureTargetActual (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) : ProcedureActualResult :=
  let first := skipAt text position
  let after := nameAfter text first
  let scalar := scalarTarget text context position
  let flag := booleanTarget text context position
  if first = 0 ∨ after ≤ first then invalidProcedureActual
  else if parameter.kind = .integer then
    let binding := ScalarExpression.binding context.scalarNames scalar
    let incoming := facts.values.getD (scalar - 1) Integer.Interval.empty
    if scalar = 0 ∨ !binding.mutable ∨ parameter.bounds.isEmpty ∨
        !parameter.bounds.included binding.declaredBounds ∨
        (parameter.mode = .inputOutput ∧ (incoming.isEmpty ∨ !incoming.included parameter.bounds))
      then invalidProcedureActual
    else ⟨first, after, scalar, 0⟩
  else if flag = 0 ∨ !(BooleanBindings.binding context.booleanNames flag).mutable
    then invalidProcedureActual
  else ⟨first, after, 0, flag⟩

def procedureActualAfter (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) : Nat :=
  if parameter.mode = .input then
    actualAfter text context position facts ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds⟩
  else (procedureTargetActual text context position facts parameter).after

def procedureActualsTailModel (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat)
    (named : Bool) (seen : FormalSet) : Nat :=
  let association := procedureAssociation text position catalog first last ordinal named
  if association.formal = 0 ∨ seen association.formal then 0
  else
    let after := procedureActualAfter text context association.payloadFirst facts
      (ProcedureBindings.parameter catalog association.formal)
    if after = 0 then 0
    else if ordinal = last then fixedAfter text after ")" false
    else if fixedAfter text after "," false = 0 then 0
    else if _within : ordinal < last then
      procedureActualsTailModel text context (fixedAfter text after "," false) facts catalog
        first last (ordinal + 1) association.named (markFormal seen association.formal)
    else 0
termination_by last - ordinal

def procedureActualsAfter (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last : Nat) : Nat :=
  procedureActualsTailModel text context position facts catalog first last first false noFormals

/-- Replay the same associations, skipping selector labels. Only the exact
writable actual's own payload span is exempt from the lexical exclusion check. -/
def procedurePayloadsFreeModel (text : Source) (context : ParseContext) (position : Nat)
    (incoming : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat)
    (named : Bool) (callAfter targetFirst targetAfter : Nat) : Bool :=
  let association := procedureAssociation text position catalog first last ordinal named
  if callAfter = 0 ∨ association.formal = 0 then false
  else
    let after := procedureActualAfter text context association.payloadFirst incoming
      (ProcedureBindings.parameter catalog association.formal)
    if after = 0 then false
    else if !((skipAt text association.payloadFirst == targetFirst && after == targetAfter) ||
        actualNameFree text association.payloadFirst after targetFirst targetAfter) then false
    else if ordinal = last then fixedAfter text after ")" false == callAfter
    else if fixedAfter text after "," false = 0 then false
    else if _within : ordinal < last then
      procedurePayloadsFreeModel text context (fixedAfter text after "," false) incoming catalog
        first last (ordinal + 1) association.named callAfter targetFirst targetAfter
    else false
termination_by last - ordinal

def procedurePayloadsFree (text : Source) (context : ParseContext) (position : Nat)
    (incoming : ActiveFlow) (catalog : ProcedureBindings.Metadata) (first last : Nat)
    (callAfter targetFirst targetAfter : Nat) : Bool :=
  procedurePayloadsFreeModel text context position incoming catalog first last first false
    callAfter targetFirst targetAfter

def procedureUpdateStep (text : Source) (context : ParseContext) (incoming : ActiveFlow) (scan : BodyScan)
    (parameter : ProcedureBindings.Formal) (catalog : ProcedureBindings.Metadata)
    (first last callFirst callAfter : Nat) : BodyScan :=
  if parameter.mode = .input then
    let after := procedureActualAfter text context scan.position incoming parameter
    if after ≤ scan.position then invalidBody scan else {scan with position := after}
  else
    let target := procedureTargetActual text context scan.position incoming parameter
    if target.after = 0 ∨ target.first < callFirst ∨ target.after > callAfter ∨
        !procedurePayloadsFree text context callFirst incoming catalog first last callAfter target.first target.after
      then invalidBody scan
    else if target.scalar = 0 then {scan with position := target.after, assigned := true}
    else {scan with
      position := target.after
      assigned := true
      facts := scan.facts.replace target.scalar parameter.bounds}

def procedureUpdatesTailModel (text : Source) (context : ParseContext) (incoming : ActiveFlow) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat) (named : Bool) (seen : FormalSet)
    (callFirst callAfter : Nat) : BodyScan :=
  let association := procedureAssociation text scan.position catalog first last ordinal named
  if association.formal = 0 ∨ seen association.formal then invalidBody scan
  else
    let next := procedureUpdateStep text context incoming {scan with position := association.payloadFirst}
      (ProcedureBindings.parameter catalog association.formal) catalog first last callFirst callAfter
    if next.position = 0 then invalidBody scan
    else if ordinal = last then bodyToken text next (.symbol ")")
    else
      let following := bodyToken text next (.symbol ",")
      if following.position = 0 then invalidBody scan
      else if _within : ordinal < last then
        procedureUpdatesTailModel text context incoming following catalog first last (ordinal + 1)
          association.named (markFormal seen association.formal) callFirst callAfter
      else invalidBody scan
termination_by last - ordinal

def procedureUpdatesModel (text : Source) (context : ParseContext) (incoming : ActiveFlow) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat) : BodyScan :=
  procedureUpdatesTailModel text context incoming scan catalog first last first false noFormals callFirst callAfter

def procedureUpdates (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) (first last callFirst callAfter : Nat) : BodyScan :=
  procedureUpdatesModel text context scan.facts scan catalog first last callFirst callAfter

def procedureCalleeAt (text : Source) (context : ParseContext) (position : Nat)
    (catalog : ProcedureBindings.Metadata) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  if first = 0 ∨ after ≤ first ∨ lookupName text context.names first after ≠ 0 ∨
      ScalarExpression.lookup text context.scalarNames first after ≠ 0 ∨
      BooleanBindings.lookup text context.booleanNames first after ≠ 0 ∨
      ArrayBindings.lookup text context.arrayNames first after ≠ 0
  then 0 else ProcedureBindings.lookup text catalog first after

def procedureCallBody (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : ProcedureBindings.Metadata) : BodyScan :=
  let callee := procedureCalleeAt text context scan.position catalog
  if callee = 0 then invalidBody scan else
    let item := ProcedureBindings.signature catalog callee
    let start := fixedAfter text (nameAfter text (skipAt text scan.position)) "(" false
    let after := procedureActualsAfter text context start scan.facts catalog item.formalFirst
      (item.formalFirst + item.count - 1)
    if start = 0 ∨ after ≤ scan.position then invalidBody scan
    else procedureUpdates text context {scan with position := start} catalog item.formalFirst
      (item.formalFirst + item.count - 1) start after

theorem procedureCalleeAt_bound (text : Source) (context : ParseContext) (position : Nat)
    (catalog : ProcedureBindings.Metadata) :
    procedureCalleeAt text context position catalog ≤ catalog.items.length := by
  dsimp only [procedureCalleeAt]
  split
  · exact Nat.zero_le _
  · exact ProcedureBindings.lookup_bound ..

end Silver.Predicate

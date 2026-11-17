module

public import Silver.ComposeDeclarationAdmission
public import Silver.PredicateConditionAdmission
public import Silver.PredicateBodyFacts
public import Silver.PredicateCallAdmission
public import Silver.PredicateFlowWidening
public import Silver.PredicateCountedBoundModel

@[expose] public section

/-! Shared statement state and scalar targets, below both function and procedure call readers. -/
namespace Silver.Predicate
open Compose Bindings PathFacts

structure BodyScan where
  position : Nat
  target : Nat
  capacity : Nat
  facts : ActiveFlow
  assigned : Bool
  output : Bool
  deriving DecidableEq, Repr

def BodyScan.count (scan : BodyScan) : Nat := scan.facts.count

def invalidBody (scan : BodyScan) : BodyScan := ⟨0, 0, 0, scan.facts.invalid, false, false⟩

def bodyToken (text : Source) (scan : BodyScan) (token : ShellToken) : BodyScan :=
  {scan with position := tokenAfter text scan.position token}

def bodyTokens (text : Source) (scan : BodyScan) (tokens : List ShellToken) : BodyScan :=
  tokens.foldl (bodyToken text) scan

def parserState (context : ParseContext) (scan : BodyScan) : ParserState :=
  {position := scan.position, names := context.names, scalarNames := context.scalarNames, target := scan.target, capacity := scan.capacity}

def scalarTarget (text : Source) (context : ParseContext) (position : Nat) : Nat :=
  let first := skipAt text position
  ScalarExpression.lookup text context.scalarNames first (nameAfter text first)

def scalarAssignmentStart (text : Source) (scan : BodyScan) : Nat :=
  fixedAfter text (nameAfter text (skipAt text scan.position)) ":=" false

def scalarAssignmentBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  let target := scalarTarget text context scan.position
  let value := readScalarInFlow text context (scalarAssignmentStart text scan) scan.facts
  let binding := ScalarExpression.binding context.scalarNames target
  if target = 0 ∨ !binding.mutable ∨ value.after ≤ scan.position ∨
      value.bounds.isEmpty ∨ value.bounds.lower < binding.declaredBounds.lower ∨
      value.bounds.upper > binding.declaredBounds.upper
  then invalidBody scan else
    {scan with
      position := value.after, assigned := true,
      facts := scan.facts.replace target value.bounds}

def booleanTarget (text : Source) (context : ParseContext) (position : Nat) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  if ScalarExpression.lookup text context.scalarNames first after ≠ 0 then 0
  else BooleanBindings.lookup text context.booleanNames first after

def booleanAssignmentBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  let first := skipAt text scan.position
  let after := nameAfter text first
  let target := booleanTarget text context scan.position
  let value := readCondition text context (fixedAfter text after ":=" false) scan.facts
  if target = 0 ∨ !(BooleanBindings.binding context.booleanNames target).mutable ∨ value.after ≤ scan.position
  then invalidBody scan else {scan with position := value.after, assigned := true}

def callAssignmentResult (context : ParseContext) (scan : BodyScan)
    (scalar flag : Nat) (value : CallResult) : BodyScan :=
  if value.after ≤ scan.position then invalidBody scan
  else if scalar ≠ 0 then
    let binding := ScalarExpression.binding context.scalarNames scalar
    if value.kind ≠ .integer ∨ !binding.mutable ∨ value.bounds.isEmpty ∨
        !value.bounds.included binding.declaredBounds then invalidBody scan
    else
      {scan with
        position := value.after, assigned := true,
        facts := scan.facts.replace scalar value.bounds}
  else if flag ≠ 0 ∧ (BooleanBindings.binding context.booleanNames flag).mutable ∧
      value.kind = .boolean then {scan with position := value.after, assigned := true}
  else invalidBody scan

def callAssignmentBody (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata) : BodyScan :=
  callAssignmentResult context scan (scalarTarget text context scan.position)
    (booleanTarget text context scan.position)
    (readCall text context (scalarAssignmentStart text scan) scan.facts catalog)

end Silver.Predicate

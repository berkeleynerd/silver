module

public import Silver.ComposeDeclarationAdmission
public import Silver.PredicateConditionAdmission
public import Silver.PredicateBodyFacts
public import Silver.PredicateCallAdmission
public import Silver.PredicateFlowWidening
public import Silver.PredicateCountedBoundModel
public import Silver.PredicateProcedureCallAdmission

@[expose] public section

/-! Scalar statement scanner and two current outer shells. The source-reading
relations retain written elsif/else structure separately from this cursor and
path-fact implementation. Frames share immutable declaration names. -/

namespace Silver.Predicate
open Compose Bindings PathFacts

def arrayIndexStart (text : Source) (scan : BodyScan) : Nat :=
  fixedAfter text (nameAfter text (skipAt text scan.position)) "(" false

def arrayIndex (text : Source) (context : ParseContext) (scan : BodyScan) : ScalarExpression.Result :=
  ScalarExpression.read text (arrayIndexStart text scan) (context.readingNames scan.facts)

def arrayValueStart (text : Source) (context : ParseContext) (scan : BodyScan) : Nat :=
  fixedAfter text (fixedAfter text (arrayIndex text context scan).after ")" false) ":=" false

def arrayAssignmentBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  let target := arrayTarget text context scan.position
  let subscript := arrayIndex text context scan
  let value := readScalarInFlow text context (arrayValueStart text context scan) scan.facts
  let binding := ArrayBindings.binding context.arrayNames target
  if target = 0 ∨ !binding.mutable ∨ binding.isBoolean ∨ !ArrayBindings.contains binding subscript.bounds ∨
      subscript.operands = ScalarExpression.maxOperands ∨ value.after ≤ scan.position ∨ value.bounds.isEmpty ∨
      value.bounds.lower < binding.componentBounds.lower ∨ value.bounds.upper > binding.componentBounds.upper
  then invalidBody scan else {scan with position := value.after, assigned := true}

def booleanArrayAssignmentBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  let target := arrayTarget text context scan.position
  let targetAfter := booleanArrayAfter text context scan.position scan.facts
  let value := readCondition text context (fixedAfter text targetAfter ":=" false) scan.facts
  if target = 0 ∨ !(ArrayBindings.binding context.arrayNames target).isBoolean ∨
      !(ArrayBindings.binding context.arrayNames target).mutable ∨ targetAfter = 0 ∨ value.after ≤ scan.position
  then invalidBody scan else {scan with position := value.after, assigned := true}

inductive BasicKind | null | output | put | reject | scalarAssignment | arrayAssignment | booleanArrayAssignment | booleanAssignment | assignment
  deriving DecidableEq, Repr

def basicKind (text : Source) (context : ParseContext) (scan : BodyScan) : BasicKind :=
  if fixedAfter text scan.position "null" true ≠ 0 then .null
  else if !context.pure && decide (callAfter text context.names scan.position .output context.scalarNames context.arrayNames (context.subtypeHiding.get .output) context.booleanNames ≠ 0) then .output
  else if !context.pure && decide (callAfter text context.names scan.position .partialOutput context.scalarNames context.arrayNames (context.subtypeHiding.get .partialOutput) context.booleanNames ≠ 0) then .put
  else if context.hasArguments && decide (callAfter text context.names scan.position .reject context.scalarNames context.arrayNames (context.subtypeHiding.get .reject) context.booleanNames ≠ 0)
    then .reject
  else if scalarTarget text context scan.position ≠ 0 then .scalarAssignment
  else if !context.pure && decide (arrayTarget text context scan.position ≠ 0) then
    if (ArrayBindings.binding context.arrayNames (arrayTarget text context scan.position)).isBoolean
    then .booleanArrayAssignment else .arrayAssignment
  else if booleanTarget text context scan.position ≠ 0 then .booleanAssignment
  else .assignment

/-- These three source forms share the immutable String binding table, but
preserve distinct Ada Character, indexed-component and whole-String types. -/
inductive StringAssignmentKind | character | element | whole
  deriving DecidableEq, Repr

def stringAssignmentTarget (text : Source) (context : ParseContext) (scan : BodyScan) : ParserState :=
  targetAt text (parserState context scan) false

def stringAssignmentKind (text : Source) (context : ParseContext) (scan : BodyScan) : StringAssignmentKind :=
  let target := stringAssignmentTarget text context scan
  if ((context.names.get target.target).getD {}).isCharacter then .character
  else if fixedAfter text target.position "(" false ≠ 0 then .element
  else .whole

def stringAssignmentStart (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  let target := stringAssignmentTarget text context scan
  {scan with position := target.position, target := target.target}

def elementTargetRead (text : Source) (context : ParseContext) (scan : BodyScan) : ValueResult :=
  indexedAt text scan.position context.names (context.readingNames scan.facts)
    context.arrayNames [] false true

def characterAssignmentPosition (text : Source) (context : ParseContext) (scan : BodyScan) : Nat :=
  if stringAssignmentKind text context scan = .element then
    fixedAfter text (elementTargetRead text context scan).after ":=" false
  else fixedAfter text (stringAssignmentStart text context scan).position ":=" false

def stringAssignmentBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  let target := stringAssignmentStart text context scan
  if target.target = 0 then invalidBody scan else
  match stringAssignmentKind text context scan with
  | .character | .element =>
      let value := characterAt text (characterAssignmentPosition text context scan)
        context.names (context.readingNames scan.facts) context.arrayNames
      if value.after = 0 then invalidBody scan
      else {target with position := value.after, assigned := true}
  | .whole =>
      let start := bodyToken text target (.symbol ":=")
      let value := readStringInFlow text context start.position start.facts
      let bound := ((context.names.get start.target).getD {}).bound
      if value.after = 0 ∨ !fitsLengthSummary start.facts.path (summaryOf value) ∨
          !equalLengthSummary start.facts.path (summaryOf value) bound.summary
      then invalidBody scan
      else {start with position := value.after, assigned := true}

def basicRaw (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) : BodyScan :=
  match basicKind text context scan with
  | .null => bodyToken text scan (.word "null")
  | .output =>
      let call := {scan with position := Names.associationAfter text (fixedAfter text (callAfter text context.names scan.position .output context.scalarNames context.arrayNames (context.subtypeHiding.get .output) context.booleanNames) "(" false) false}
      let value := readStringInFlow text context call.position call.facts
      if value.after = 0 ∨ call.facts.path.invalidReachable ∨ !fitsLengthSummary call.facts.path (summaryOf value)
      then invalidBody scan else
      let result := bodyToken text {call with position := value.after} (.symbol ")")
      {result with output := true}
  | .put =>
      let call := {scan with position := Names.associationAfter text (fixedAfter text (callAfter text context.names scan.position .partialOutput context.scalarNames context.arrayNames (context.subtypeHiding.get .partialOutput) context.booleanNames) "(" false) false}
      let value := readStringInFlow text context call.position call.facts
      if value.after = 0 ∨ call.facts.path.invalidReachable ∨ !fitsLengthSummary call.facts.path (summaryOf value)
      then invalidBody scan else
      let result := bodyToken text {call with position := value.after} (.symbol ")")
      {result with output := true}
  | .reject =>
      let call := {scan with position := callAfter text context.names scan.position .reject context.scalarNames context.arrayNames (context.subtypeHiding.get .reject) context.booleanNames}
      {call with facts := {call.facts with path := call.facts.path.reject}}
  | .scalarAssignment =>
      let called := callAssignmentBody text context scan catalog
      if called.position ≠ 0 then called else scalarAssignmentBody text context scan
  | .arrayAssignment => arrayAssignmentBody text context scan
  | .booleanArrayAssignment => booleanArrayAssignmentBody text context scan
  | .booleanAssignment =>
      let called := callAssignmentBody text context scan catalog
      if called.position ≠ 0 then called else booleanAssignmentBody text context scan
  | .assignment =>
      if procedureCalleeAt text context scan.position procedures ≠ 0 then
        procedureCallBody text context scan procedures
      else if context.pure then invalidBody scan else stringAssignmentBody text context scan

def basicBody (text : Source) (context : ParseContext) (scan : BodyScan)
    (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) : BodyScan :=
  if scan.position = 0 then invalidBody scan else
  let result := bodyToken text (basicRaw text context scan catalog procedures) (.symbol ";")
  if result.position ≤ scan.position then invalidBody scan else result

inductive BodyStop | endOnly | elseOnly | arm | returnOnly
  deriving DecidableEq, Repr

def atBodyStop (text : Source) (position : Nat) : BodyStop → Bool
  | .returnOnly => decide (fixedAfter text position "return" true ≠ 0)
  | .endOnly => decide (fixedAfter text position "end" true ≠ 0)
  | .elseOnly => decide (fixedAfter text position "else" true ≠ 0)
  | .arm => decide (fixedAfter text position "elsif" true ≠ 0 ∨
      fixedAfter text position "else" true ≠ 0 ∨ fixedAfter text position "end" true ≠ 0)

def bodyRemaining (text : Source) (scan : BodyScan) : Nat := remainingAt text scan.position

def branchStart (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String) :
    BodyScan × ActiveFlow :=
  let start := bodyToken text scan (.word keyword)
  let condition := readCondition text context start.position start.facts
  let yes := bodyToken text {start with position := condition.after, facts := condition.whenTrue} (.word "then")
  (yes, condition.whenFalse)

/-- Source positions and inferred ranges of a loop header. Both bounds mask the
new index name, as Ada's scope excludes reading an outer homonym there. -/
structure LoopHeader where
  first : Nat
  after : Nat
  reverse : Bool
  lower : ScalarExpression.Result
  upper : ScalarExpression.Result
  entry : BodyScan
  isArray : Bool := false
  arrayTarget : Nat := 0
  componentBounds : Integer.Interval := .full
  deriving Repr

def loopFirst (text : Source) (scan : BodyScan) : Nat :=
  skipAt text (fixedAfter text scan.position "for" true)

def loopNameAfter (text : Source) (scan : BodyScan) : Nat := nameAfter text (loopFirst text scan)

def loopOfAfter (text : Source) (scan : BodyScan) : Nat :=
  fixedAfter text (loopNameAfter text scan) "of" true

def loopIsArray (text : Source) (scan : BodyScan) : Bool := decide (loopOfAfter text scan ≠ 0)

def loopInAfter (text : Source) (scan : BodyScan) : Nat :=
  if loopIsArray text scan then loopOfAfter text scan
  else fixedAfter text (loopNameAfter text scan) "in" true

def loopReverse (text : Source) (scan : BodyScan) : Bool :=
  decide (fixedAfter text (loopInAfter text scan) "reverse" true ≠ 0)

def loopLowerPosition (text : Source) (scan : BodyScan) : Nat :=
  if loopReverse text scan then fixedAfter text (loopInAfter text scan) "reverse" true
  else loopInAfter text scan

/-- Capture the iterable's binding identity before appending the element name.
The scoped name is masked in its own iterator specification. -/
def loopArrayTarget (text : Source) (context : ParseContext) (scan : BodyScan) : Nat :=
  arrayTarget text context (loopLowerPosition text scan)

def loopArrayAllowed (text : Source) (context : ParseContext) (scan : BodyScan) : Bool :=
  let target := loopArrayTarget text context scan
  let first := skipAt text (loopLowerPosition text scan)
  let after := nameAfter text first
  decide (first ≠ 0 ∧ first < after ∧ target ≠ 0) && !(ArrayBindings.binding context.arrayNames target).mutable &&
    !Named.equalName text (loopFirst text scan) (loopNameAfter text scan) first after &&
    !(ArrayBindings.binding context.arrayNames target).isBoolean

def LoopHeader.bounds (header : LoopHeader) : Integer.Interval :=
  if header.isArray then header.componentBounds else Integer.loopBounds header.lower.bounds header.upper.bounds

def loopHeader (text : Source) (context : ParseContext) (scan : BodyScan) : LoopHeader :=
  let first := loopFirst text scan
  let after := loopNameAfter text scan
  let isArray := loopIsArray text scan
  let lower := if isArray then ScalarExpression.invalid else
    readCountedBound text context (loopLowerPosition text scan) scan.facts first after
  let upper := if isArray then ScalarExpression.invalid else
    readCountedBound text context (fixedAfter text lower.after ".." false) scan.facts first after
  let components := (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).componentBounds
  let bounds := if isArray then components else Integer.loopBounds lower.bounds upper.bounds
  let opening := if isArray then
    if loopArrayAllowed text context scan then
      fixedAfter text (nameAfter text (skipAt text (loopLowerPosition text scan))) "loop" true
    else 0
    else fixedAfter text upper.after "loop" true
  ⟨first, after, loopReverse text scan, lower, upper,
    {scan with
      position := opening,
      facts := {(ActiveFlow.widen context.scalarNames scan.facts).append bounds with
        path := loopContext scan.facts.path bounds}}, isArray, loopArrayTarget text context scan, components⟩

def loopNameAllowed (text : Source) (context : ParseContext) (header : LoopHeader) : Bool :=
  decide (header.first ≠ 0 ∧ header.first < header.after) &&
    (!Named.forbiddenName text header.first header.after ||
      Named.nameIs text header.first header.after ("string".toList.map Char.toNat)) &&
    (!context.hasArguments ||
      !Named.nameIs text header.first header.after ("silver_arguments".toList.map Char.toNat)) &&
    decide (context.scalarNames.length ≠ ScalarExpression.maxBindings)

def loopInner (context : ParseContext) (header : LoopHeader) : ParseContext :=
  {context with scalarNames := context.scalarNames ++
    [⟨header.first, header.after, header.bounds, false, header.bounds, false⟩]}

def loopAfterFlow (context : ParseContext) (before after : ActiveFlow)
    (lower upper : Integer.Interval) : ActiveFlow :=
  let values := if (Integer.loopBounds lower upper).isEmpty then before.values
    else (ActiveFlow.widen context.scalarNames before).values
  ⟨loopAfter before.path after.path lower upper, values⟩

/-- Constant arrays are nonempty, so their final body path is always reached. -/
def loopAfterHeader (context : ParseContext) (before after : ActiveFlow) (header : LoopHeader) : ActiveFlow :=
  if header.isArray then ⟨after.path, (ActiveFlow.widen context.scalarNames before).values⟩
  else loopAfterFlow context before after header.lower.bounds header.upper.bounds

mutual
  def statementBody (text : Source) (context : ParseContext) (scan : BodyScan)
      (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) : BodyScan :=
    if scan.position = 0 then invalidBody scan
    else if fixedAfter text scan.position "if" true ≠ 0 then conditionalBody text context scan catalog procedures
    else if fixedAfter text scan.position "for" true ≠ 0 then loopBody text context scan catalog procedures
    else basicBody text context scan catalog procedures
  termination_by bodyRemaining text scan * 4 + 2
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def loopBody (text : Source) (context : ParseContext) (scan : BodyScan)
      (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) : BodyScan :=
    let header := loopHeader text context scan
    if !loopNameAllowed text context header then invalidBody scan
    else if header.entry.position ≤ scan.position then invalidBody scan
    else if _advanced : bodyRemaining text header.entry < bodyRemaining text scan then
      let body := readBody text (loopInner context header) header.entry .endOnly catalog procedures
      if body.position ≤ scan.position then invalidBody scan else
      let result := bodyTokens text
        {body with facts := loopAfterHeader context scan.facts body.facts header}
        [.word "end", .word "loop", .symbol ";"]
      if result.position ≤ scan.position then invalidBody scan else result
    else invalidBody scan
  termination_by bodyRemaining text scan * 4 + 1
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def conditionalBody (text : Source) (context : ParseContext) (scan : BodyScan)
      (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) : BodyScan :=
    let start := branchStart text context scan "if"
    if start.1.position ≤ scan.position then invalidBody scan else
    if _advanced : bodyRemaining text start.1 < bodyRemaining text scan then
      let yes := readBody text context start.1 .arm catalog procedures
      if yes.position ≤ scan.position then invalidBody scan else
      if _yesAdvanced : bodyRemaining text yes < bodyRemaining text scan then
        let no := alternativeBody text context {yes with facts := start.2} catalog procedures
        let joined := {no with facts := yes.facts.join no.facts}
        let result := bodyTokens text joined [.word "end", .word "if", .symbol ";"]
        if result.position ≤ scan.position then invalidBody scan else result
      else invalidBody scan
    else invalidBody scan
  termination_by bodyRemaining text scan * 4 + 1
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def alternativeBody (text : Source) (context : ParseContext) (scan : BodyScan)
      (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) : BodyScan :=
    if scan.position = 0 then invalidBody scan
    else if fixedAfter text scan.position "elsif" true ≠ 0 then
      let start := branchStart text context scan "elsif"
      if start.1.position ≤ scan.position then invalidBody scan else
      if _advanced : bodyRemaining text start.1 < bodyRemaining text scan then
        let yes := readBody text context start.1 .arm catalog procedures
        if yes.position ≤ scan.position then invalidBody scan else
        if _yesAdvanced : bodyRemaining text yes < bodyRemaining text scan then
          let no := alternativeBody text context {yes with facts := start.2} catalog procedures
          {no with facts := yes.facts.join no.facts}
        else invalidBody scan
      else invalidBody scan
    else if fixedAfter text scan.position "else" true ≠ 0 then
      let start := bodyToken text scan (.word "else")
      if start.position ≤ scan.position then invalidBody scan else
      if _advanced : bodyRemaining text start < bodyRemaining text scan then
        readBody text context start .endOnly catalog procedures
      else invalidBody scan
    else if fixedAfter text scan.position "end" true ≠ 0 then scan
    else invalidBody scan
  termination_by bodyRemaining text scan * 4 + 1
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def bodyTail (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) : BodyScan :=
    if scan.position = 0 then invalidBody scan
    else if atBodyStop text scan.position stop then scan
    else
      let next := statementBody text context scan catalog procedures
      if next.position ≤ scan.position then invalidBody next else
      if _advanced : bodyRemaining text next < bodyRemaining text scan then bodyTail text context next stop catalog procedures
      else invalidBody next
  termination_by bodyRemaining text scan * 4 + 3
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def readBody (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (catalog : FunctionBindings.Metadata := {})
      (procedures : ProcedureBindings.Metadata := {}) : BodyScan :=
    let next := statementBody text context scan catalog procedures
    if next.position = 0 then invalidBody next else
    if _advanced : bodyRemaining text next < bodyRemaining text scan then bodyTail text context next stop catalog procedures
    else invalidBody next
  termination_by bodyRemaining text scan * 4 + 3
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega
end


structure ScanResult where
  state : ParserState
  assigned : Bool := false
  output : Bool := false
  deriving DecidableEq, Repr

def initialScan : ScanResult := ⟨initialState, false, false⟩
def invalidScan : ScanResult := ⟨invalidState, false, false⟩

def initialFacts (arguments : Bool) : Context :=
  if arguments then Context.initial maxSourceLength else ⟨some ⟨0, 0⟩, false, false⟩

def contextOf (scan : ScanResult) : ParseContext :=
  ⟨scan.state.names, decide (scan.state.dynamicFirst ≠ 0),
    ScalarExpression.bodyEnvironment scan.state.scalarNames, scan.state.scalarNames.length, scan.state.arrayNames.names, scan.state.subtypeNames.hiddenCalls,
    scan.state.booleanNames, scan.state.subtypeNames.trueHidden || scan.state.hiding.trueHidden,
    scan.state.subtypeNames.falseHidden || scan.state.hiding.falseHidden,
    false, 0, 0, scan.state.pure, scan.state.hiding.integerHidden, scan.state.arrayNames.types⟩

def bodyOf (scan : ScanResult) : BodyScan :=
  ⟨scan.state.position, scan.state.target, scan.state.capacity,
    ActiveFlow.initial (contextOf scan).scalarNames
      (initialFacts (decide (scan.state.dynamicFirst ≠ 0))), scan.assigned, scan.output⟩

end Silver.Predicate

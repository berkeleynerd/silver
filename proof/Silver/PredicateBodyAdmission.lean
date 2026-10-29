module

public import Silver.PredicateAdmission
public import Silver.PredicateComposition
public import Silver.PredicateSourceSyntax
public import Silver.PredicateFlowWidening

@[expose] public section

/-! Scalar statement scanner and two current outer shells. The source-reading
relations retain written elsif/else structure separately from this cursor and
path-fact implementation. Frames share immutable declaration names. -/

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
  let value := ScalarExpression.read text (scalarAssignmentStart text scan) (context.readingNames scan.facts) (arrays := context.arrayNames)
  let binding := ScalarExpression.binding context.scalarNames target
  if target = 0 ∨ !binding.mutable ∨ value.after ≤ scan.position ∨
      value.bounds.isEmpty ∨ value.bounds.lower < binding.declaredBounds.lower ∨
      value.bounds.upper > binding.declaredBounds.upper
  then invalidBody scan else
    {scan with
      position := value.after, assigned := true,
      facts := scan.facts.replace target value.bounds}

def arrayTarget (text : Source) (context : ParseContext) (position : Nat) : Nat :=
  let first := skipAt text position
  let after := nameAfter text first
  if ScalarExpression.lookup text context.scalarNames first after ≠ 0 then 0
  else ArrayBindings.lookup text context.arrayNames first after

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
  if target = 0 ∨ !binding.mutable ∨ !ArrayBindings.contains binding subscript.bounds ∨
      subscript.operands = ScalarExpression.maxOperands ∨ value.after ≤ scan.position ∨ value.bounds.isEmpty ∨
      value.bounds.lower < binding.componentBounds.lower ∨ value.bounds.upper > binding.componentBounds.upper
  then invalidBody scan else {scan with position := value.after, assigned := true}

inductive BasicKind | null | output | put | reject | scalarAssignment | arrayAssignment | assignment
  deriving DecidableEq, Repr

def basicKind (text : Source) (context : ParseContext) (scan : BodyScan) : BasicKind :=
  if fixedAfter text scan.position "null" true ≠ 0 then .null
  else if callAfter text context.names scan.position .output context.scalarNames context.arrayNames (context.subtypeHiding.get .output) ≠ 0 then .output
  else if callAfter text context.names scan.position .partialOutput context.scalarNames context.arrayNames (context.subtypeHiding.get .partialOutput) ≠ 0 then .put
  else if context.hasArguments && decide (callAfter text context.names scan.position .reject context.scalarNames context.arrayNames (context.subtypeHiding.get .reject) ≠ 0)
    then .reject
  else if scalarTarget text context scan.position ≠ 0 then .scalarAssignment
  else if arrayTarget text context scan.position ≠ 0 then .arrayAssignment
  else .assignment

def basicRaw (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  match basicKind text context scan with
  | .null => bodyToken text scan (.word "null")
  | .output =>
      let call := {scan with position := Names.associationAfter text (fixedAfter text (callAfter text context.names scan.position .output context.scalarNames context.arrayNames (context.subtypeHiding.get .output)) "(" false) false}
      let value := expressionAt text call.position context.names (context.readingNames call.facts) (arrays := context.arrayNames)
      if value.after = 0 ∨ call.facts.path.invalidReachable ∨ !fitsLengthSummary call.facts.path (summaryOf value)
      then invalidBody scan else
      let result := bodyToken text {call with position := value.after} (.symbol ")")
      {result with output := true}
  | .put =>
      let call := {scan with position := Names.associationAfter text (fixedAfter text (callAfter text context.names scan.position .partialOutput context.scalarNames context.arrayNames (context.subtypeHiding.get .partialOutput)) "(" false) false}
      let value := expressionAt text call.position context.names (context.readingNames call.facts) (arrays := context.arrayNames)
      if value.after = 0 ∨ call.facts.path.invalidReachable ∨ !fitsLengthSummary call.facts.path (summaryOf value)
      then invalidBody scan else
      let result := bodyToken text {call with position := value.after} (.symbol ")")
      {result with output := true}
  | .reject =>
      let call := {scan with position := callAfter text context.names scan.position .reject context.scalarNames context.arrayNames (context.subtypeHiding.get .reject)}
      {call with facts := {call.facts with path := call.facts.path.reject}}
  | .scalarAssignment => scalarAssignmentBody text context scan
  | .arrayAssignment => arrayAssignmentBody text context scan
  | .assignment =>
      let state := targetAt text (parserState context scan) false
      let target := bodyToken text {scan with position := state.position, target := state.target} (.symbol ":=")
      let value := expressionAt text target.position context.names (context.readingNames target.facts) (arrays := context.arrayNames)
      let bound := ((context.names.get target.target).getD {}).bound
      if value.after = 0 ∨ target.target = 0 ∨ !fitsLengthSummary target.facts.path (summaryOf value) ∨
          !equalLengthSummary target.facts.path (summaryOf value) bound.summary
      then invalidBody scan
      else {target with position := value.after, assigned := true}

def basicBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  if scan.position = 0 then invalidBody scan else
  let result := bodyToken text (basicRaw text context scan) (.symbol ";")
  if result.position ≤ scan.position then invalidBody scan else result

inductive BodyStop | endOnly | elseOnly | arm
  deriving DecidableEq, Repr

def atBodyStop (text : Source) (position : Nat) : BodyStop → Bool
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
    !Named.equalName text (loopFirst text scan) (loopNameAfter text scan) first after

def LoopHeader.bounds (header : LoopHeader) : Integer.Interval :=
  if header.isArray then header.componentBounds else Integer.loopBounds header.lower.bounds header.upper.bounds

def loopHeader (text : Source) (context : ParseContext) (scan : BodyScan) : LoopHeader :=
  let first := loopFirst text scan
  let after := loopNameAfter text scan
  let isArray := loopIsArray text scan
  let lower := if isArray then ScalarExpression.invalid else
    ScalarExpression.read text (loopLowerPosition text scan) (context.readingNames scan.facts) first after (arrays := context.arrayNames)
  let upper := if isArray then ScalarExpression.invalid else
    ScalarExpression.read text (fixedAfter text lower.after ".." false) (context.readingNames scan.facts) first after (arrays := context.arrayNames)
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
  def statementBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
    if scan.position = 0 then invalidBody scan
    else if fixedAfter text scan.position "if" true ≠ 0 then conditionalBody text context scan
    else if fixedAfter text scan.position "for" true ≠ 0 then loopBody text context scan
    else basicBody text context scan
  termination_by bodyRemaining text scan * 4 + 2
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def loopBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
    let header := loopHeader text context scan
    if !loopNameAllowed text context header then invalidBody scan
    else if header.entry.position ≤ scan.position then invalidBody scan
    else if _advanced : bodyRemaining text header.entry < bodyRemaining text scan then
      let body := readBody text (loopInner context header) header.entry .endOnly
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

  def conditionalBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
    let start := branchStart text context scan "if"
    if start.1.position ≤ scan.position then invalidBody scan else
    if _advanced : bodyRemaining text start.1 < bodyRemaining text scan then
      let yes := readBody text context start.1 .arm
      if yes.position ≤ scan.position then invalidBody scan else
      if _yesAdvanced : bodyRemaining text yes < bodyRemaining text scan then
        let no := alternativeBody text context {yes with facts := start.2}
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

  def alternativeBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
    if scan.position = 0 then invalidBody scan
    else if fixedAfter text scan.position "elsif" true ≠ 0 then
      let start := branchStart text context scan "elsif"
      if start.1.position ≤ scan.position then invalidBody scan else
      if _advanced : bodyRemaining text start.1 < bodyRemaining text scan then
        let yes := readBody text context start.1 .arm
        if yes.position ≤ scan.position then invalidBody scan else
        if _yesAdvanced : bodyRemaining text yes < bodyRemaining text scan then
          let no := alternativeBody text context {yes with facts := start.2}
          {no with facts := yes.facts.join no.facts}
        else invalidBody scan
      else invalidBody scan
    else if fixedAfter text scan.position "else" true ≠ 0 then
      let start := bodyToken text scan (.word "else")
      if start.position ≤ scan.position then invalidBody scan else
      if _advanced : bodyRemaining text start < bodyRemaining text scan then
        readBody text context start .endOnly
      else invalidBody scan
    else if fixedAfter text scan.position "end" true ≠ 0 then scan
    else invalidBody scan
  termination_by bodyRemaining text scan * 4 + 1
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def bodyTail (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop) : BodyScan :=
    if scan.position = 0 then invalidBody scan
    else if atBodyStop text scan.position stop then scan
    else
      let next := statementBody text context scan
      if next.position ≤ scan.position then invalidBody next else
      if _advanced : bodyRemaining text next < bodyRemaining text scan then bodyTail text context next stop
      else invalidBody next
  termination_by bodyRemaining text scan * 4 + 3
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def readBody (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop) : BodyScan :=
    let next := statementBody text context scan
    if next.position = 0 then invalidBody next else
    if _advanced : bodyRemaining text next < bodyRemaining text scan then bodyTail text context next stop
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
    ScalarExpression.bodyEnvironment scan.state.scalarNames, scan.state.scalarNames.length, scan.state.arrayNames.names, scan.state.subtypeNames.hiddenCalls⟩

def bodyOf (scan : ScanResult) : BodyScan :=
  ⟨scan.state.position, scan.state.target, scan.state.capacity,
    ActiveFlow.initial (contextOf scan).scalarNames
      (initialFacts (decide (scan.state.dynamicFirst ≠ 0))), scan.assigned, scan.output⟩

def expandBody (before : ParserState) (scan : BodyScan) : ScanResult :=
  ⟨{before with position := scan.position, target := scan.target, capacity := scan.capacity, scalarNames := ScalarExpression.bodyEnvironment before.scalarNames},
    scan.assigned, scan.output⟩

def readStatements (text : Source) (scan : ScanResult) : ScanResult :=
  let result := readBody text (contextOf scan) (bodyOf scan) .endOnly
  if result.position = 0 ∨ !completed result.facts.path then invalidScan else expandBody scan.state result

inductive Form | direct | argument
  deriving DecidableEq, Repr

def allForms : List Form := [.direct, .argument]

def Form.hasArguments : Form → Bool | .direct => false | .argument => true

def Form.helper : Form → Compose.Form | .direct => .direct | .argument => .argument

inductive Token | helper (token : ShellToken) | statements
  deriving DecidableEq, Repr

def Form.prefix (form : Form) : List ShellToken := currentHeader form.hasArguments

def Form.footer (_form : Form) : List ShellToken := [.word "end", .word "main", .symbol ";"]

def Form.tokens (form : Form) : List Token :=
  form.prefix.map Token.helper ++ [.statements] ++ form.footer.map Token.helper

def scanStep (text : Source) (form : Form) (token : Token) (scan : ScanResult) : ScanResult :=
  match token with
  | .helper token => {scan with state := step text form.helper token scan.state}
  | .statements => readStatements text scan

def scanSuffix (text : Source) (form : Form) : List Token → ScanResult → ScanResult
  | [], scan =>
      if scan.state.position ≠ 0 ∧ Cursor.triviaPosition text scan.state.position = text.length + 1
      then scan else invalidScan
  | token :: rest, scan =>
      if scan.state.position = 0 then invalidScan
      else scanSuffix text form rest (scanStep text form token scan)

def formResult (text : Source) (form : Form) : ScanResult :=
  if decide (0 < text.length ∧ text.length ≤ maxSourceLength) && text.all allowedCharacter && withinWorkBudget text
  then scanSuffix text form form.tokens initialScan else invalidScan

def formAccepts (text : Source) (form : Form) : Bool := decide ((formResult text form).state.position ≠ 0)
def selectedForm (text : Source) : Option Form := allForms.find? (formAccepts text)
def accepts (text : Source) : Bool := (selectedForm text).isSome

def hasArguments (text : Source) : Bool := allForms.any fun form => formAccepts text form && form.hasArguments
def hasAssignment (text : Source) : Bool := allForms.any fun form => formAccepts text form && (formResult text form).assigned
def hasOutput (text : Source) : Bool := allForms.any fun form => formAccepts text form && (formResult text form).output

end Silver.Predicate

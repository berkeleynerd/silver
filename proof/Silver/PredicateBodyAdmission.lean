module

public import Silver.PredicateAdmission
public import Silver.PredicateComposition
public import Silver.PredicateSourceSyntax

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
  facts : Context
  assigned : Bool
  output : Bool
  deriving DecidableEq, Repr

def invalidBody : BodyScan := ⟨0, 0, 0, Context.empty, false, false⟩

def bodyToken (text : Source) (scan : BodyScan) (token : ShellToken) : BodyScan :=
  {scan with position := tokenAfter text scan.position token}

def bodyTokens (text : Source) (scan : BodyScan) (tokens : List ShellToken) : BodyScan :=
  tokens.foldl (bodyToken text) scan

def parserState (context : ParseContext) (scan : BodyScan) : ParserState :=
  {position := scan.position, names := context.names, scalarNames := context.scalarNames, target := scan.target, capacity := scan.capacity}

inductive BasicKind | null | output | put | reject | assignment
  deriving DecidableEq, Repr

def basicKind (text : Source) (context : ParseContext) (scan : BodyScan) : BasicKind :=
  if fixedAfter text scan.position "null" true ≠ 0 then .null
  else if callAfter text context.names scan.position .output context.scalarNames ≠ 0 then .output
  else if callAfter text context.names scan.position .partialOutput context.scalarNames ≠ 0 then .put
  else if context.hasArguments && decide (callAfter text context.names scan.position .reject context.scalarNames ≠ 0)
    then .reject
  else .assignment

def basicRaw (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  match basicKind text context scan with
  | .null => bodyToken text scan (.word "null")
  | .output =>
      let call := {scan with position := Names.associationAfter text (fixedAfter text (callAfter text context.names scan.position .output context.scalarNames) "(" false) false}
      let value := expressionAt text call.position context.names context.scalarNames
      if value.after = 0 ∨ call.facts.invalidReachable ∨ !fitsSummary call.facts (summaryOf value)
      then invalidBody else
      let result := bodyToken text {call with position := value.after} (.symbol ")")
      {result with output := true}
  | .put =>
      let call := {scan with position := Names.associationAfter text (fixedAfter text (callAfter text context.names scan.position .partialOutput context.scalarNames) "(" false) false}
      let value := expressionAt text call.position context.names context.scalarNames
      if value.after = 0 ∨ call.facts.invalidReachable ∨ !fitsSummary call.facts (summaryOf value)
      then invalidBody else
      let result := bodyToken text {call with position := value.after} (.symbol ")")
      {result with output := true}
  | .reject =>
      let call := {scan with position := callAfter text context.names scan.position .reject context.scalarNames}
      {call with facts := call.facts.reject}
  | .assignment =>
      let state := targetAt text (parserState context scan) false
      let target := bodyToken text {scan with position := state.position, target := state.target} (.symbol ":=")
      let value := expressionAt text target.position context.names context.scalarNames
      let bound := ((context.names.get target.target).getD {}).bound
      if value.after = 0 ∨ target.target = 0 ∨ !fitsSummary target.facts (summaryOf value) ∨
          !equalSummary target.facts (summaryOf value) bound.summary
      then invalidBody
      else {target with position := value.after, assigned := true}

def basicBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
  if scan.position = 0 then invalidBody else
  let result := bodyToken text (basicRaw text context scan) (.symbol ";")
  if result.position ≤ scan.position then invalidBody else result

inductive BodyStop | endOnly | elseOnly | arm
  deriving DecidableEq, Repr

def atBodyStop (text : Source) (position : Nat) : BodyStop → Bool
  | .endOnly => decide (fixedAfter text position "end" true ≠ 0)
  | .elseOnly => decide (fixedAfter text position "else" true ≠ 0)
  | .arm => decide (fixedAfter text position "elsif" true ≠ 0 ∨
      fixedAfter text position "else" true ≠ 0 ∨ fixedAfter text position "end" true ≠ 0)

def bodyRemaining (text : Source) (scan : BodyScan) : Nat := remainingAt text scan.position

def branchStart (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String) :
    BodyScan × Context :=
  let start := bodyToken text scan (.word keyword)
  let condition := readCondition text context start.position start.facts
  let yes := bodyToken text {start with position := condition.after, facts := condition.whenTrue} (.word "then")
  (yes, condition.whenFalse)

mutual
  def statementBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
    if scan.position = 0 then invalidBody
    else if fixedAfter text scan.position "if" true ≠ 0 then conditionalBody text context scan
    else basicBody text context scan
  termination_by bodyRemaining text scan * 4 + 2
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def conditionalBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
    let start := branchStart text context scan "if"
    if start.1.position ≤ scan.position then invalidBody else
    if _advanced : bodyRemaining text start.1 < bodyRemaining text scan then
      let yes := readBody text context start.1 .arm
      if yes.position ≤ scan.position then invalidBody else
      if _yesAdvanced : bodyRemaining text yes < bodyRemaining text scan then
        let no := alternativeBody text context {yes with facts := start.2}
        let joined := {no with facts := yes.facts.join no.facts}
        let result := bodyTokens text joined [.word "end", .word "if", .symbol ";"]
        if result.position ≤ scan.position then invalidBody else result
      else invalidBody
    else invalidBody
  termination_by bodyRemaining text scan * 4 + 1
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def alternativeBody (text : Source) (context : ParseContext) (scan : BodyScan) : BodyScan :=
    if scan.position = 0 then invalidBody
    else if fixedAfter text scan.position "elsif" true ≠ 0 then
      let start := branchStart text context scan "elsif"
      if start.1.position ≤ scan.position then invalidBody else
      if _advanced : bodyRemaining text start.1 < bodyRemaining text scan then
        let yes := readBody text context start.1 .arm
        if yes.position ≤ scan.position then invalidBody else
        if _yesAdvanced : bodyRemaining text yes < bodyRemaining text scan then
          let no := alternativeBody text context {yes with facts := start.2}
          {no with facts := yes.facts.join no.facts}
        else invalidBody
      else invalidBody
    else if fixedAfter text scan.position "else" true ≠ 0 then
      let start := bodyToken text scan (.word "else")
      if start.position ≤ scan.position then invalidBody else
      if _advanced : bodyRemaining text start < bodyRemaining text scan then
        readBody text context start .endOnly
      else invalidBody
    else if fixedAfter text scan.position "end" true ≠ 0 then scan
    else invalidBody
  termination_by bodyRemaining text scan * 4 + 1
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def bodyTail (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop) : BodyScan :=
    if scan.position = 0 then invalidBody
    else if atBodyStop text scan.position stop then scan
    else
      let next := statementBody text context scan
      if next.position ≤ scan.position then invalidBody else
      if _advanced : bodyRemaining text next < bodyRemaining text scan then bodyTail text context next stop
      else invalidBody
  termination_by bodyRemaining text scan * 4 + 3
  decreasing_by
    all_goals simp_wf
    all_goals (try dsimp (config := {zetaDelta := true}) only [bodyRemaining] at *)
    all_goals omega

  def readBody (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop) : BodyScan :=
    let next := statementBody text context scan
    if next.position = 0 then invalidBody else
    if _advanced : bodyRemaining text next < bodyRemaining text scan then bodyTail text context next stop
    else invalidBody
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
  ⟨scan.state.names, decide (scan.state.dynamicFirst ≠ 0), scan.state.scalarNames⟩

def bodyOf (scan : ScanResult) : BodyScan :=
  ⟨scan.state.position, scan.state.target, scan.state.capacity,
    initialFacts (decide (scan.state.dynamicFirst ≠ 0)), scan.assigned, scan.output⟩

def expandBody (before : ParserState) (scan : BodyScan) : ScanResult :=
  ⟨{before with position := scan.position, target := scan.target, capacity := scan.capacity},
    scan.assigned, scan.output⟩

def readStatements (text : Source) (scan : ScanResult) : ScanResult :=
  let result := readBody text (contextOf scan) (bodyOf scan) .endOnly
  if result.position = 0 ∨ !completed result.facts then invalidScan else expandBody scan.state result

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

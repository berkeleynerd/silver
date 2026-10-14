module

public import Silver.ComposeGrammar
public import Silver.SequenceSyntax

@[expose] public section

set_option backward.dsimp.instances true

/-! The finite statement scanner. It reuses the checked declaration/expression
scanners; statement traversal retains binding shapes and accumulates syntactic
report-routing flags across both branches. The decreasing checks make the model
total outside the native scanner's proved cursor domain. -/

namespace Silver.Sequence
open Compose

inductive Form | direct | argument | guardedArgument
  deriving DecidableEq, Repr

def allForms : List Form := [.direct, .argument, .guardedArgument]

def Form.hasArguments : Form → Bool
  | .direct => false
  | _ => true

def Form.helper : Form → Compose.Form
  | .direct => .direct
  | .argument => .argument
  | .guardedArgument => .guardedArgument

structure ScanResult where
  state : ParserState
  assigned : Bool := false
  output : Bool := false
  deriving DecidableEq, Repr

def initialScan : ScanResult := ⟨initialState, false, false⟩
def invalidScan : ScanResult := ⟨invalidState, false, false⟩

def scanToken (text : Source) (scan : ScanResult) (token : ShellToken) : ScanResult :=
  {scan with state := step text .direct token scan.state}

def scanTokens (text : Source) (form : Compose.Form) (tokens : List ShellToken)
    (scan : ScanResult) : ScanResult :=
  tokens.foldl (fun current token => {current with state := step text form token current.state}) scan

inductive BasicKind | null | output | assignment
  deriving DecidableEq, Repr

def BasicKind.tokens : BasicKind → List ShellToken
  | .null => [.word "null", .symbol ";"]
  | .output => outputTokens
  | .assignment => assignmentTokens .assignmentTarget

def basicKind (text : Source) (scan : ScanResult) : BasicKind :=
  if fixedAfter text scan.state.position "null" true ≠ 0 then .null
  else if fixedAfter text scan.state.position "silver_io" true ≠ 0 then .output
  else .assignment

def basicRaw (text : Source) (scan : ScanResult) : ScanResult :=
  let kind := basicKind text scan
  let result := scanTokens text .direct kind.tokens scan
  ⟨result.state, result.assigned || (kind == .assignment), result.output || (kind == .output)⟩

def basicStatementAt (text : Source) (scan : ScanResult) : ScanResult :=
  if scan.state.position = 0 then invalidScan
  else if (basicRaw text scan).state.position ≤ scan.state.position then invalidScan
  else basicRaw text scan

inductive BodyStop
  | token (value : ShellToken)
  | arm
  deriving DecidableEq, Repr

def stopAfter (text : Source) (position : Nat) : BodyStop → Nat
  | .token value => tokenAfter text position value
  | .arm =>
      let next := fixedAfter text position "elsif" true
      if next ≠ 0 then next else
      let next := fixedAfter text position "else" true
      if next ≠ 0 then next else fixedAfter text position "end" true

def tail (text : Source) (read : ScanResult → ScanResult) (stop : BodyStop)
    (scan : ScanResult) : ScanResult :=
  if scan.state.position = 0 then invalidScan
  else if stopAfter text scan.state.position stop ≠ 0 then scan
  else if (read scan).state.position = 0 then invalidScan
  else if _advancing : text.length + 1 - (read scan).state.position <
      text.length + 1 - scan.state.position then
    tail text read stop (read scan)
  else invalidScan
termination_by text.length + 1 - scan.state.position

def basicTail (text : Source) (scan : ScanResult) (stop : ShellToken) : ScanResult :=
  tail text (basicStatementAt text) (.token stop) scan

def readBasicStatements (text : Source) (scan : ScanResult) (stop : ShellToken) : ScanResult :=
  basicTail text (basicStatementAt text scan) stop

def remaining (text : Source) (scan : ScanResult) : Nat :=
  text.length + 1 - scan.state.position

def elsifTokens : List ShellToken :=
  [.word "elsif", .comparisonExpression, .word "then"]

mutual
  def statementAt (text : Source) (scan : ScanResult) : ScanResult :=
    if fixedAfter text scan.state.position "if" true ≠ 0
    then conditionalAt text scan else basicStatementAt text scan
  termination_by remaining text scan * 4 + 2
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def conditionalAt (text : Source) (scan : ScanResult) : ScanResult :=
    if scan.state.position = 0 then invalidScan else
    let comparison := scanTokens text .direct equalityTokens scan
    if _advanced : remaining text comparison < remaining text scan then
      let yes := readBody text comparison .arm
      if _advancedYes : remaining text yes < remaining text scan then
        let final := scanTokens text .direct endIfTokens (alternativeAt text yes)
        if final.state.position ≤ scan.state.position then invalidScan else final
      else invalidScan
    else invalidScan
  termination_by remaining text scan * 4 + 1
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def alternativeAt (text : Source) (scan : ScanResult) : ScanResult :=
    if scan.state.position = 0 then invalidScan
    else if fixedAfter text scan.state.position "elsif" true ≠ 0 then
      let comparison := scanTokens text .direct elsifTokens scan
      if _advanced : remaining text comparison < remaining text scan then
        let yes := readBody text comparison .arm
        if _advancedYes : remaining text yes < remaining text scan then alternativeAt text yes
        else invalidScan
      else invalidScan
    else if fixedAfter text scan.state.position "else" true ≠ 0 then
      let next := scanToken text scan (.word "else")
      if _advanced : remaining text next < remaining text scan then
        readBody text next (.token (.word "end"))
      else invalidScan
    else if fixedAfter text scan.state.position "end" true ≠ 0 then scan
    else invalidScan
  termination_by remaining text scan * 4 + 1
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def bodyTail (text : Source) (scan : ScanResult) (stop : BodyStop) : ScanResult :=
    if scan.state.position = 0 then invalidScan
    else if stopAfter text scan.state.position stop ≠ 0 then scan
    else
      let next := statementAt text scan
      if next.state.position = 0 then invalidScan
      else if _advanced : remaining text next < remaining text scan then bodyTail text next stop
      else invalidScan
  termination_by remaining text scan * 4 + 3
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def readBody (text : Source) (scan : ScanResult) (stop : BodyStop) : ScanResult :=
    let next := statementAt text scan
    if next.state.position = 0 then invalidScan
    else if _advanced : remaining text next < remaining text scan then bodyTail text next stop
    else invalidScan
  termination_by remaining text scan * 4 + 3
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega
end

def statementsTail (text : Source) (scan : ScanResult) (stop : ShellToken) : ScanResult :=
  bodyTail text scan (.token stop)

def readStatements (text : Source) (scan : ScanResult) (stop : ShellToken) : ScanResult :=
  readBody text scan (.token stop)

inductive Token
  | helper (token : ShellToken)
  | statements
  deriving DecidableEq, Repr

def Form.prefix (form : Form) : List ShellToken :=
  header form.hasArguments ++
    (if form.hasArguments then guardTokens (form == .guardedArgument) else [])

def Form.footer (form : Form) : List ShellToken :=
  (if form.hasArguments then rejectTokens else []) ++ [.word "end", .word "main", .symbol ";"]

def Form.stop (form : Form) : ShellToken :=
  if form.hasArguments then .word "else" else .word "end"

def Form.tokens (form : Form) : List Token :=
  form.prefix.map Token.helper ++ [.statements] ++ form.footer.map Token.helper

def scanStep (text : Source) (form : Form) (token : Token) (scan : ScanResult) : ScanResult :=
  match token with
  | .helper token => {scan with state := step text form.helper token scan.state}
  | .statements => readStatements text scan form.stop

def scanSuffix (text : Source) (form : Form) : List Token → ScanResult → ScanResult
  | [], scan =>
      if scan.state.position ≠ 0 ∧ Cursor.triviaPosition text scan.state.position = text.length + 1
      then scan else invalidScan
  | token :: rest, scan =>
      if scan.state.position = 0 then invalidScan
      else scanSuffix text form rest (scanStep text form token scan)

def formResult (source : Source) (form : Form) : ScanResult :=
  if decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
      source.all allowedCharacter && withinWorkBudget source
  then scanSuffix source form form.tokens initialScan else invalidScan

def formAccepts (source : Source) (form : Form) : Bool :=
  decide ((formResult source form).state.position ≠ 0)

def selectedForm (source : Source) : Option Form := allForms.find? (formAccepts source)
def accepts (source : Source) : Bool := (selectedForm source).isSome

def hasArguments (source : Source) : Bool :=
  allForms.any fun form => formAccepts source form && form.hasArguments

def hasAssignment (source : Source) : Bool :=
  allForms.any fun form => formAccepts source form && (formResult source form).assigned

def hasOutput (source : Source) : Bool :=
  allForms.any fun form => formAccepts source form && (formResult source form).output

theorem basic_progress {text : Source} {scan : ScanResult}
    (accepted : (basicStatementAt text scan).state.position ≠ 0) :
    scan.state.position < (basicStatementAt text scan).state.position := by
  unfold basicStatementAt at *
  split <;> rename_i h
  · simp [h, invalidScan, invalidState] at accepted
  · split <;> rename_i h₂
    · simp [h, h₂, invalidScan, invalidState] at accepted
    · omega

theorem conditional_progress {text : Source} {scan : ScanResult}
    (accepted : (conditionalAt text scan).state.position ≠ 0) :
    scan.state.position < (conditionalAt text scan).state.position := by
  rw [conditionalAt] at accepted ⊢
  dsimp only at accepted ⊢
  repeat' split at accepted <;> simp_all [invalidScan, invalidState]
  split <;> omega

theorem statement_progress {text : Source} {scan : ScanResult}
    (accepted : (statementAt text scan).state.position ≠ 0) :
    scan.state.position < (statementAt text scan).state.position := by
  by_cases h : fixedAfter text scan.state.position "if" true ≠ 0
  · rw [statementAt, ite_eq_left h] at accepted ⊢
    exact conditional_progress accepted
  · rw [statementAt, ite_eq_right h] at accepted ⊢
    exact basic_progress accepted


theorem bodyTail_failure {text : Source} {scan : ScanResult} {stop : BodyStop}
    (zero : (bodyTail text scan stop).state.position = 0) :
    bodyTail text scan stop = invalidScan := by
  rw [bodyTail] at zero ⊢
  dsimp only at zero ⊢
  by_cases failed : scan.state.position = 0
  · simp only [failed, ↓reduceIte]
  · simp only [failed, ↓reduceIte] at zero ⊢
    by_cases done : stopAfter text scan.state.position stop ≠ 0
    · rw [ite_eq_left done] at zero
      exact False.elim (failed zero)
    · rw [ite_eq_right done] at zero ⊢
      by_cases nextFailed : (statementAt text scan).state.position = 0
      · simp only [nextFailed, ↓reduceIte]
      · simp only [nextFailed, ↓reduceIte] at zero ⊢
        by_cases advanced : remaining text (statementAt text scan) < remaining text scan
        · simp only [advanced, ↓reduceDIte] at zero ⊢
          exact bodyTail_failure zero
        · simp only [advanced, ↓reduceDIte]
termination_by remaining text scan

theorem readBody_failure {text : Source} {scan : ScanResult} {stop : BodyStop}
    (zero : (readBody text scan stop).state.position = 0) :
    readBody text scan stop = invalidScan := by
  rw [readBody] at zero ⊢
  by_cases failed : (statementAt text scan).state.position = 0
  · simp only [failed, ↓reduceIte]
  · simp only [failed, ↓reduceIte] at zero ⊢
    by_cases advanced : remaining text (statementAt text scan) < remaining text scan
    · simp only [advanced, ↓reduceDIte] at zero ⊢
      exact bodyTail_failure zero
    · simp only [advanced, ↓reduceDIte]

theorem basic_failure {text : Source} {scan : ScanResult}
    (zero : (basicStatementAt text scan).state.position = 0) :
    basicStatementAt text scan = invalidScan := by
  unfold basicStatementAt at zero ⊢
  by_cases failed : scan.state.position = 0
  · simp only [failed, ↓reduceIte]
  · simp only [failed, ↓reduceIte] at zero ⊢
    by_cases stopped : (basicRaw text scan).state.position ≤ scan.state.position
    · simp only [stopped, ↓reduceIte]
    · simp only [stopped, ↓reduceIte] at zero
      omega

theorem conditional_zero {text : Source} {scan : ScanResult} (zero : scan.state.position = 0) :
    conditionalAt text scan = invalidScan := by
  rw [conditionalAt]
  simp only [zero, ↓reduceIte]

theorem alternative_zero {text : Source} {scan : ScanResult} (zero : scan.state.position = 0) :
    alternativeAt text scan = invalidScan := by
  rw [alternativeAt]
  simp only [zero, ↓reduceIte]

theorem statement_zero {text : Source} {scan : ScanResult} (zero : scan.state.position = 0) :
    statementAt text scan = invalidScan := by
  rw [statementAt]
  split
  · exact conditional_zero zero
  · simp only [basicStatementAt, zero, ↓reduceIte]

theorem conditional_failure {text : Source} {scan : ScanResult}
    (zero : (conditionalAt text scan).state.position = 0) :
    conditionalAt text scan = invalidScan := by
  rw [conditionalAt] at zero ⊢
  dsimp only at zero ⊢
  by_cases failed : scan.state.position = 0
  · simp only [failed, ↓reduceIte]
  · simp only [failed, ↓reduceIte] at zero ⊢
    by_cases comparison : remaining text (scanTokens text .direct equalityTokens scan) < remaining text scan
    · simp only [comparison, ↓reduceDIte] at zero ⊢
      by_cases yes : remaining text (readBody text (scanTokens text .direct equalityTokens scan) .arm) < remaining text scan
      · simp only [yes, ↓reduceDIte] at zero ⊢
        by_cases stopped : (scanTokens text .direct endIfTokens (alternativeAt text (readBody text (scanTokens text .direct equalityTokens scan) .arm))).state.position ≤ scan.state.position
        · simp only [stopped, ↓reduceIte]
        · simp only [stopped, ↓reduceIte] at zero
          omega
      · simp only [yes, ↓reduceDIte]
    · simp only [comparison, ↓reduceDIte]

theorem alternative_failure {text : Source} {scan : ScanResult}
    (zero : (alternativeAt text scan).state.position = 0) :
    alternativeAt text scan = invalidScan := by
  rw [alternativeAt] at zero ⊢
  dsimp only at zero ⊢
  by_cases failed : scan.state.position = 0
  · simp only [failed, ↓reduceIte]
  · simp only [failed, ↓reduceIte] at zero ⊢
    by_cases hasElsif : fixedAfter text scan.state.position "elsif" true ≠ 0
    · rw [ite_eq_left hasElsif] at zero ⊢
      by_cases comparison : remaining text (scanTokens text .direct elsifTokens scan) < remaining text scan
      · simp only [comparison, ↓reduceDIte] at zero ⊢
        by_cases yes : remaining text (readBody text (scanTokens text .direct elsifTokens scan) .arm) < remaining text scan
        · simp only [yes, ↓reduceDIte] at zero ⊢
          exact alternative_failure zero
        · simp only [yes, ↓reduceDIte]
      · simp only [comparison, ↓reduceDIte]
    · rw [ite_eq_right hasElsif] at zero ⊢
      by_cases hasElse : fixedAfter text scan.state.position "else" true ≠ 0
      · rw [ite_eq_left hasElse] at zero ⊢
        by_cases advanced : remaining text (scanToken text scan (.word "else")) < remaining text scan
        · simp only [advanced, ↓reduceDIte] at zero ⊢
          exact readBody_failure zero
        · simp only [advanced, ↓reduceDIte]
      · rw [ite_eq_right hasElse] at zero ⊢
        by_cases hasEnd : fixedAfter text scan.state.position "end" true ≠ 0
        · rw [ite_eq_left hasEnd] at zero
          exact False.elim (failed zero)
        · rw [ite_eq_right hasEnd]
termination_by remaining text scan

theorem statement_failure {text : Source} {scan : ScanResult}
    (zero : (statementAt text scan).state.position = 0) : statementAt text scan = invalidScan := by
  rw [statementAt] at zero ⊢
  by_cases choice : fixedAfter text scan.state.position "if" true ≠ 0
  · rw [ite_eq_left choice] at zero ⊢
    exact conditional_failure zero
  · rw [ite_eq_right choice] at zero ⊢
    exact basic_failure zero

end Silver.Sequence

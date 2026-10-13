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

def tail (text : Source) (read : ScanResult → ScanResult) (stop : ShellToken)
    (scan : ScanResult) : ScanResult :=
  if scan.state.position = 0 then invalidScan
  else if tokenAfter text scan.state.position stop ≠ 0 then scan
  else if (read scan).state.position = 0 then invalidScan
  else if _advancing : text.length + 1 - (read scan).state.position <
      text.length + 1 - scan.state.position then
    tail text read stop (read scan)
  else invalidScan
termination_by text.length + 1 - scan.state.position

def basicTail (text : Source) (scan : ScanResult) (stop : ShellToken) : ScanResult :=
  tail text (basicStatementAt text) stop scan

def readBasicStatements (text : Source) (scan : ScanResult) (stop : ShellToken) : ScanResult :=
  basicTail text (basicStatementAt text scan) stop

def conditionalRaw (text : Source) (scan : ScanResult) : ScanResult :=
  let comparison := scanTokens text .direct equalityTokens scan
  let yes := readBasicStatements text comparison (.word "else")
  let no := readBasicStatements text (scanToken text yes (.word "else")) (.word "end")
  scanTokens text .direct endIfTokens no

def conditionalAt (text : Source) (scan : ScanResult) : ScanResult :=
  if (conditionalRaw text scan).state.position ≤ scan.state.position then invalidScan
  else conditionalRaw text scan

def statementAt (text : Source) (scan : ScanResult) : ScanResult :=
  if fixedAfter text scan.state.position "if" true ≠ 0
  then conditionalAt text scan else basicStatementAt text scan

def statementsTail (text : Source) (scan : ScanResult) (stop : ShellToken) : ScanResult :=
  tail text (statementAt text) stop scan

def readStatements (text : Source) (scan : ScanResult) (stop : ShellToken) : ScanResult :=
  statementsTail text (statementAt text scan) stop

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
  unfold conditionalAt at *
  split <;> rename_i h
  · simp [h, invalidScan, invalidState] at accepted
  · omega

theorem statement_progress {text : Source} {scan : ScanResult}
    (accepted : (statementAt text scan).state.position ≠ 0) :
    scan.state.position < (statementAt text scan).state.position := by
  by_cases h : fixedAfter text scan.state.position "if" true ≠ 0
  · rw [statementAt, ite_eq_left h] at accepted ⊢
    exact conditional_progress accepted
  · rw [statementAt, ite_eq_right h] at accepted ⊢
    exact basic_progress accepted

end Silver.Sequence

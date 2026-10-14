module

public import Silver.PredicateBodyAdmission
public import Silver.ComposeExpressions
public import Silver.PredicateBodyCorrespondence

@[expose] public section

/-! Typed outer scanner expressions. Recursive body and lexical calls remain
arbitrary; shared constructors determine their rendering and interpretation. -/

namespace Silver.Predicate.Outer
open Compose

structure Calls where
  helpers : Compose.Expressions.Calls
  body : BodyNative.Calls
  readStatements : Source → ScanResult → ShellToken → ScanResult
  scanStep : Source → Form → Token → ScanResult → ScanResult
  suffix : Source → Form → Nat → ScanResult → ScanResult
  formResult : Source → Form → ScanResult
  member : Source → Bool
  arguments : Source → Bool
  assignment : Source → Bool
  output : Source → Bool

structure Context where
  text : Source
  scan : ScanResult := initialScan
  result : ScanResult := initialScan
  form : Form := .direct
  token : Token := .helper (.symbol ";")
  stop : ShellToken := .word "end"
  nextToken : Nat := 1

inductive HelperRef
  | literal (token : ShellToken)
  | currentToken | stopToken | bodyEnd
  deriving DecidableEq

inductive IndexRef | current | next | first
  deriving DecidableEq

def IndexRef.eval (ctx : Context) : IndexRef → Nat
  | .current => ctx.nextToken | .next => ctx.nextToken + 1 | .first => 1

def IndexRef.render : IndexRef → List String
  | .current => ["next_token"] | .next => ["next_token", "+", "1"] | .first => ["1"]

def HelperRef.eval (ctx : Context) : HelperRef → ShellToken
  | .literal token => token
  | .currentToken => match ctx.token with | .helper token => token | .statements => .symbol "_"
  | .stopToken => ctx.stop
  | .bodyEnd => .word "end"

def HelperRef.render : HelperRef → List String
  | .literal token => [Compose.Expressions.tokenName token]
  | .currentToken => ["token"]
  | .stopToken => ["stop"]
  | .bodyEnd => ["end_keyword"]

mutual
  inductive Expr
    | scan | result | initial | invalid
    | helperStep (direct : Bool) (token : HelperRef) (value : Expr)
    | readStatements (stop : HelperRef) (value : Expr)
    | scanStep (indexed : Bool) (value : Expr)
    | suffix (index : IndexRef) (value : Expr)
    | normalizedSuffix
    | choose (condition : Condition) (yes no : Expr)
    | group (value : Expr)
  inductive Condition
    | zero (value : Expr)
    | nonadvancing (value : Expr)
    | tokenPresent (token : HelperRef) (value : Expr)
    | finished | triviaFinished (value : Expr) | statements | sourceAllowed
end

mutual
  def Expr.eval (calls : Calls) (ctx : Context) : Expr → ScanResult
    | .scan => ctx.scan | .result => ctx.result | .initial => initialScan | .invalid => invalidScan
    | .helperStep direct token value =>
        let scan := value.eval calls ctx
        {scan with state := calls.helpers.function .step ctx.text (if direct then .direct else ctx.form.helper) (token.eval ctx) scan.state}
    | .readStatements stop value => calls.readStatements ctx.text (value.eval calls ctx) (stop.eval ctx)
    | .scanStep indexed value => calls.scanStep ctx.text ctx.form
        (if indexed then ctx.form.tokens.getD (ctx.nextToken - 1) (.helper (.symbol ";")) else ctx.token)
        (value.eval calls ctx)
    | .suffix index value => calls.suffix ctx.text ctx.form (index.eval ctx) (value.eval calls ctx)
    | .normalizedSuffix => calls.suffix ctx.text ctx.form 1 initialScan
    | .choose condition yes no => if condition.eval calls ctx then yes.eval calls ctx else no.eval calls ctx
    | .group value => value.eval calls ctx
  def Condition.eval (calls : Calls) (ctx : Context) : Condition → Bool
    | .zero value => decide ((value.eval calls ctx).state.position = 0)
    | .nonadvancing value => decide ((value.eval calls ctx).state.position ≤ ctx.scan.state.position)
    | .tokenPresent token value => decide (calls.helpers.function .takeToken ctx.text
        (value.eval calls ctx).state.position (token.eval ctx) ≠ 0)
    | .finished => decide (ctx.nextToken > ctx.form.tokens.length)
    | .triviaFinished value => decide (calls.helpers.primitive.trivia ctx.text
        (value.eval calls ctx).state.position = ctx.text.length + 1)
    | .statements => ctx.token == .statements
    | .sourceAllowed => decide (0 < ctx.text.length ∧ ctx.text.length ≤ maxSourceLength) &&
        ctx.text.all allowedCharacter && calls.helpers.function .workBudget ctx.text
end

def call (name : String) (arguments : List (List String)) : List String :=
  Compose.Expressions.call name arguments

def position (value : List String) : List String := value ++ [".", "state", ".", "position"]

mutual
  def Expr.render : Expr → List String
    | .scan => ["scan"] | .result => ["result"] | .initial => ["initial_scan"] | .invalid => ["invalid_scan"]
    | .helperStep direct token value => ["("] ++ value.render ++ ["with", "delta", "state", "=>"] ++
        call "step" [["text"], [if direct then "direct_form" else "form"], token.render,
          value.render ++ [".", "state"]] ++ [")"]
    | .readStatements stop value => call "read_statements" [["text"], value.render, stop.render]
    | .scanStep indexed value => call "scan_step" [["text"], ["form"],
        if indexed then ["tokens", "(", "form", ")", "(", "next_token", ")"] else ["token"], value.render]
    | .suffix index value => call "scan_suffix" [["text"], ["form"], index.render, value.render]
    | .normalizedSuffix => call "scan_suffix" [["normalized", "(", "source", ")"], ["form"], ["1"], ["initial_scan"]]
    | .choose condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++ no.renderElse
    | .group value => ["("] ++ value.render ++ [")"]
  def Expr.renderElse : Expr → List String
    | .choose condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++ no.renderElse
    | value => ["else"] ++ value.render
  def Condition.render : Condition → List String
    | .zero value => position value.render ++ ["=", "0"]
    | .nonadvancing value => position value.render ++ ["<="] ++ position ["scan"]
    | .tokenPresent token value => call "take_token" [["text"], position value.render, token.render] ++ ["/=", "0"]
    | .finished => ["next_token", ">", "tokens", "(", "form", ")", "'", "last"]
    | .triviaFinished value => call "trivia_end" [["text"], position value.render] ++ ["=", "text", "'", "last", "+", "1"]
    | .statements => ["token", "=", "statements"]
    | .sourceAllowed => ["source", "'", "length", "in", "1", "..", "max_source_length", "and", "then",
        "allowed_source", "(", "normalized", "(", "source", ")", ")", "and", "then",
        "within_work_budget", "(", "normalized", "(", "source", ")", ")"]
end

def scanStepBody : Expr :=
  .choose .statements (.readStatements .bodyEnd .scan) (.helperStep false .currentToken .scan)

def suffixBody : Expr :=
  .choose (.zero .scan) .invalid
    (.choose .finished (.group (.choose (.triviaFinished .scan) .scan .invalid))
      (.suffix .next (.scanStep true .scan)))

def formBody : Expr := .choose .sourceAllowed .normalizedSuffix .invalid

inductive Flag | arguments | assignment | output
  deriving DecidableEq

def Flag.eval (calls : Calls) (text : Source) (form : Form) : Flag → Bool
  | .arguments => form.hasArguments
  | .assignment => (calls.formResult text form).assigned
  | .output => (calls.formResult text form).output

def Flag.render : Flag → List String
  | .arguments => ["is_argument_form", "(", "form", ")"]
  | .assignment => ["form_result", "(", "source", ",", "form", ")", ".", "assigned"]
  | .output => ["form_result", "(", "source", ",", "form", ")", ".", "output"]

structure MembershipBody where
  flag : Option Flag := none

def MembershipBody.eval (body : MembershipBody) (calls : Calls) (text : Source) : Bool :=
  allForms.any fun form => decide ((calls.formResult text form).state.position ≠ 0) &&
    match body.flag with | none => true | some flag => flag.eval calls text form

def MembershipBody.render (body : MembershipBody) : List String :=
  ["for", "some", "form", "in", "form_kind", "=>", "form_result", "(", "source", ",", "form", ")",
    ".", "state", ".", "position", "/=", "0"] ++
    match body.flag with | none => [] | some flag => ["and", "then"] ++ flag.render

def memberBody : MembershipBody := ⟨none⟩
def argumentsBody : MembershipBody := ⟨some .arguments⟩
def assignmentBody : MembershipBody := ⟨some .assignment⟩
def outputBody : MembershipBody := ⟨some .output⟩

end Silver.Predicate.Outer

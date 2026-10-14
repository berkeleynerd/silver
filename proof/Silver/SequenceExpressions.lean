module

public import Silver.SequenceAdmission
public import Silver.ComposeExpressions
public import Silver.SequenceNativeExpressions

@[expose] public section

/-! A small typed interpretation of the scan expressions and imperative
statement readers present in the native recognizer. Rendering and evaluation
share the same constructors; no complete-recognizer equality is a primitive. -/

namespace Silver.Sequence.Expressions
open Compose

structure Calls where
  helpers : Compose.Expressions.Calls
  scanToken : Source → ScanResult → ShellToken → ScanResult
  basic : Source → ScanResult → ScanResult
  basicTail : Source → ScanResult → ShellToken → ScanResult
  readBasic : Source → ScanResult → ShellToken → ScanResult
  native : Native.Calls
  readStatements : Source → ScanResult → ShellToken → ScanResult
  scanStep : Source → Form → Token → ScanResult → ScanResult
  suffix : Source → Form → Nat → ScanResult → ScanResult
  formResult : Source → Form → ScanResult
  member : Source → Bool
  arguments : Source → Bool
  assignment : Source → Bool
  output : Source → Bool

def Calls.bodyPrimitives (calls : Calls) : Native.Primitives where
  take := calls.helpers.function .takeToken
  token := calls.scanToken
  basic := calls.basic

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
  | .bodyEnd => if ctx.form.hasArguments then .word "else" else .word "end"

def HelperRef.render : HelperRef → List String
  | .literal token => [Compose.Expressions.tokenName token]
  | .currentToken => ["token"]
  | .stopToken => ["stop"]
  | .bodyEnd => ["(", "if", "is_argument_form", "(", "form", ")", "then", "else_keyword", "else", "end_keyword", ")"]

mutual
  inductive Expr
    | scan | result | initial | invalid
    | helperStep (direct : Bool) (token : HelperRef) (value : Expr)
    | scanToken (token : HelperRef) (value : Expr)
    | basic (value : Expr)
    | basicTail (value : Expr)
    | readBasic (stop : HelperRef) (value : Expr)
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
    | .scanToken token value => calls.scanToken ctx.text (value.eval calls ctx) (token.eval ctx)
    | .basic value => calls.basic ctx.text (value.eval calls ctx)
    | .basicTail value => calls.basicTail ctx.text (value.eval calls ctx) ctx.stop
    | .readBasic stop value => calls.readBasic ctx.text (value.eval calls ctx) (stop.eval ctx)
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
    | .scanToken token value => call "scan_token" [["text"], value.render, token.render]
    | .basic value => call "basic_statement_at" [["text"], value.render]
    | .basicTail value => call "basic_tail" [["text"], value.render, ["stop"]]
    | .readBasic stop value => call "read_basic_statements" [["text"], value.render, stop.render]
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

inductive Command
  | nothing
  | assign (value : Expr)
  | setFlag (assignment : Bool)
  | ret (value : Expr)
  | sequence (first second : Command)
  | choose (condition : Condition) (yes no : Command)

/-- A returned value short-circuits remaining statements; otherwise the local
Result value flows to the following command. -/
def Command.eval (calls : Calls) (ctx : Context) : Command → Option ScanResult × ScanResult
  | .nothing => (none, ctx.result)
  | .assign value => (none, value.eval calls ctx)
  | .setFlag assignment => (none, if assignment then {ctx.result with assigned := true}
      else {ctx.result with output := true})
  | .ret value => (some (value.eval calls ctx), ctx.result)
  | .sequence first second =>
      let (returned, result) := first.eval calls ctx
      match returned with
      | some value => (some value, result)
      | none => second.eval calls {ctx with result}
  | .choose condition yes no => if condition.eval calls ctx then yes.eval calls ctx else no.eval calls ctx

mutual
  def Command.render : Command → List String
    | .nothing => []
    | .assign value => ["result", ":="] ++ value.render ++ [";"]
    | .setFlag assignment => ["result", ".", if assignment then "assigned" else "output", ":=", "true", ";"]
    | .ret value => ["return"] ++ value.render ++ [";"]
    | .sequence first second => first.render ++ second.render
    | .choose condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
        no.renderElse ++ ["end", "if", ";"]
  def Command.renderElse : Command → List String
    | .nothing => []
    | .choose condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++ no.renderElse
    | command => ["else"] ++ command.render
end

def Command.steps (tokens : List ShellToken) : Command :=
  tokens.foldr (fun token rest => .sequence (.assign (.scanToken (.literal token) .result)) rest) .nothing

def guardReturn (condition : Condition) : Command := .choose condition (.ret .invalid) .nothing

def finish : Command := .sequence (guardReturn (.nonadvancing .result)) (.ret .result)

def basicBody : Command :=
  .sequence (guardReturn (.zero .scan))
    (.sequence
      (.choose (.tokenPresent (.literal (.word "null")) .scan)
        (.steps BasicKind.null.tokens)
        (.choose (.tokenPresent (.literal (.word "silver_io")) .scan)
          (.sequence (.steps BasicKind.output.tokens) (.setFlag false))
          (.sequence (.steps BasicKind.assignment.tokens) (.setFlag true))))
      finish)

def Command.run (body : Command) (calls : Calls) (ctx : Context) : ScanResult :=
  ((body.eval calls {ctx with result := ctx.scan}).1).getD invalidScan

def Command.functionTokens (body : Command) (name : String) : List String :=
  ["result", ":", "scan_result", ":=", "scan", ";", "begin"] ++ body.render ++ ["end", name, ";"]

def scanTokenBody : Expr := .helperStep true .currentToken .scan

def basicTailBody : Expr :=
  .choose (.zero .scan) .invalid
    (.choose (.tokenPresent .stopToken .scan) .scan
      (.choose (.zero (.basic .scan)) .invalid (.basicTail (.basic .scan))))

def readBasicBody : Expr := .basicTail (.basic .scan)

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

end Silver.Sequence.Expressions

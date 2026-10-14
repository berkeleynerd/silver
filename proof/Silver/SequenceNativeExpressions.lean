module

public import Silver.SequenceNativeState

@[expose] public section

/-! Typed expressions for the scalar native body scanner. The same constructors
render Ada tokens and interpret its calls; the recursive calls remain arbitrary. -/

namespace Silver.Sequence.Native
open Compose

inductive Stop | endOnly | elseOnly | arm
  deriving DecidableEq, Repr

def Stop.model : Stop → BodyStop
  | .endOnly => .token (.word "end")
  | .elseOnly => .token (.word "else")
  | .arm => .arm

def Stop.render : Stop → List String
  | .endOnly => ["end_only"] | .elseOnly => ["else_only"] | .arm => ["arm_boundary"]

structure Primitives where
  take : Source → Nat → ShellToken → Nat
  token : Source → ScanResult → ShellToken → ScanResult
  basic : Source → ScanResult → ScanResult

structure Calls where
  token : Source → Context → Scan → ShellToken → Scan
  basic : Source → Context → Scan → Scan
  atStop : Source → Nat → Stop → Bool
  statement : Source → Context → Scan → Scan
  conditional : Source → Context → Scan → Scan
  alternative : Source → Context → Scan → Scan
  tail : Source → Context → Scan → Stop → Scan
  read : Source → Context → Scan → Stop → Scan

structure EvalContext where
  text : Source
  context : Context
  scan : Scan
  result : Scan := invalid
  token : ShellToken := .word "end"
  stop : Stop := .endOnly

inductive TokenRef | literal (token : ShellToken) | current
  deriving DecidableEq
inductive StopRef | literal (stop : Stop) | current
  deriving DecidableEq

def TokenRef.eval (ctx : EvalContext) : TokenRef → ShellToken
  | .literal token => token | .current => ctx.token
def TokenRef.render : TokenRef → List String
  | .literal token => [Compose.Expressions.tokenName token] | .current => ["token"]
def StopRef.eval (ctx : EvalContext) : StopRef → Stop
  | .literal stop => stop | .current => ctx.stop
def StopRef.render : StopRef → List String
  | .literal stop => stop.render | .current => ["stop"]

mutual
  inductive Expr
    | scan | result | invalid
    | compactToken | compactBasic
    | token (token : TokenRef) (value : Expr)
    | basic (value : Expr)
    | statement (value : Expr)
    | conditional (value : Expr)
    | alternative (value : Expr)
    | tail (stop : StopRef) (value : Expr)
    | read (stop : StopRef) (value : Expr)
    | choose (condition : Condition) (yes no : Expr)
    | group (value : Expr)
  inductive Condition
    | zero (value : Expr)
    | nonadvancing (value : Expr)
    | tokenPresent (token : TokenRef) (value : Expr)
    | atStop (value : Expr)
end

mutual
  def Expr.eval (primitive : Primitives) (calls : Calls) (ctx : EvalContext) : Expr → Scan
    | .scan => ctx.scan | .result => ctx.result | .invalid => invalid
    | .compactToken => compact ctx.context
        (primitive.token ctx.text (expand ctx.context ctx.scan) ctx.token)
    | .compactBasic => compact ctx.context (primitive.basic ctx.text (expand ctx.context ctx.scan))
    | .token token value => calls.token ctx.text ctx.context (value.eval primitive calls ctx) (token.eval ctx)
    | .basic value => calls.basic ctx.text ctx.context (value.eval primitive calls ctx)
    | .statement value => calls.statement ctx.text ctx.context (value.eval primitive calls ctx)
    | .conditional value => calls.conditional ctx.text ctx.context (value.eval primitive calls ctx)
    | .alternative value => calls.alternative ctx.text ctx.context (value.eval primitive calls ctx)
    | .tail stop value => calls.tail ctx.text ctx.context (value.eval primitive calls ctx) (stop.eval ctx)
    | .read stop value => calls.read ctx.text ctx.context (value.eval primitive calls ctx) (stop.eval ctx)
    | .choose condition yes no => if condition.eval primitive calls ctx then
        yes.eval primitive calls ctx else no.eval primitive calls ctx
    | .group value => value.eval primitive calls ctx
  def Condition.eval (primitive : Primitives) (calls : Calls) (ctx : EvalContext) : Condition → Bool
    | .zero value => decide ((value.eval primitive calls ctx).position = 0)
    | .nonadvancing value => decide ((value.eval primitive calls ctx).position ≤ ctx.scan.position)
    | .tokenPresent token value => decide (primitive.take ctx.text
        (value.eval primitive calls ctx).position (token.eval ctx) ≠ 0)
    | .atStop value => calls.atStop ctx.text (value.eval primitive calls ctx).position ctx.stop
end

def call := Compose.Expressions.call
def position (value : List String) : List String := value ++ [".", "position"]

mutual
  def Expr.render : Expr → List String
    | .scan => ["scan"] | .result => ["result"] | .invalid => ["invalid_body"]
    | .compactToken => call "compact_body" [["context"], call "scan_token"
        [["text"], call "expand_body" [["context"], ["scan"]], ["token"]]]
    | .compactBasic => call "compact_body" [["context"], call "basic_statement_at"
        [["text"], call "expand_body" [["context"], ["scan"]]]]
    | .token token value => call "body_token" [["text"], ["context"], value.render, token.render]
    | .basic value => call "basic_body" [["text"], ["context"], value.render]
    | .statement value => call "statement_body" [["text"], ["context"], value.render]
    | .conditional value => call "conditional_body" [["text"], ["context"], value.render]
    | .alternative value => call "alternative_body" [["text"], ["context"], value.render]
    | .tail stop value => call "body_tail" [["text"], ["context"], value.render, stop.render]
    | .read stop value => call "read_body" [["text"], ["context"], value.render, stop.render]
    | .choose condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++ no.renderElse
    | .group value => ["("] ++ value.render ++ [")"]
  def Expr.renderElse : Expr → List String
    | .choose condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++ no.renderElse
    | value => ["else"] ++ value.render
  def Condition.render : Condition → List String
    | .zero value => position value.render ++ ["=", "0"]
    | .nonadvancing value => position value.render ++ ["<="] ++ position ["scan"]
    | .tokenPresent token value => call "take_token" [["text"], position value.render, token.render] ++ ["/=", "0"]
    | .atStop value => call "at_body_stop" [["text"], position value.render, ["stop"]]
end

inductive Command
  | nothing
  | assign (value : Expr)
  | ret (value : Expr)
  | sequence (first second : Command)
  | choose (condition : Condition) (yes no : Command)

def Command.eval (primitive : Primitives) (calls : Calls) (ctx : EvalContext) : Command → Option Scan × Scan
  | .nothing => (none, ctx.result)
  | .assign value => (none, value.eval primitive calls ctx)
  | .ret value => (some (value.eval primitive calls ctx), ctx.result)
  | .sequence first second =>
      let (returned, result) := first.eval primitive calls ctx
      match returned with
      | some value => (some value, result)
      | none => second.eval primitive calls {ctx with result}
  | .choose condition yes no => if condition.eval primitive calls ctx then
      yes.eval primitive calls ctx else no.eval primitive calls ctx

mutual
  def Command.render : Command → List String
    | .nothing => []
    | .assign value => ["result", ":="] ++ value.render ++ [";"]
    | .ret value => ["return"] ++ value.render ++ [";"]
    | .sequence first second => first.render ++ second.render
    | .choose condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
        no.renderElse ++ ["end", "if", ";"]
  def Command.renderElse : Command → List String
    | .nothing => []
    | .choose condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++ no.renderElse
    | command => ["else"] ++ command.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing
def Command.steps (tokens : List ShellToken) : Command :=
  Command.list (tokens.map fun token => .assign (.token (.literal token) .result))
def guard (condition : Condition) : Command := .choose condition (.ret .invalid) .nothing
def finish : Command := .sequence (guard (.nonadvancing .result)) (.ret .result)

structure Function where
  initial : Expr
  constant : Bool := false
  body : Command

def Function.eval (fn : Function) (primitive : Primitives) (calls : Calls) (ctx : EvalContext) : Scan :=
  ((fn.body.eval primitive calls {ctx with result := fn.initial.eval primitive calls ctx}).1).getD invalid
def Function.render (fn : Function) (name : String) : List String :=
  ["result", ":"] ++ (if fn.constant then ["constant"] else []) ++ ["body_scan", ":="] ++
  fn.initial.render ++ [";", "begin"] ++ fn.body.render ++ ["end", name, ";"]

def tokenBody : Function := ⟨.compactToken, true, finish⟩
def basicBody : Expr := .compactBasic
def statementBody : Expr :=
  .choose (.zero .scan) .invalid
    (.choose (.tokenPresent (.literal (.word "if")) .scan) (.conditional .scan) (.basic .scan))
def tailBody : Expr :=
  .choose (.zero .scan) .invalid
    (.choose (.atStop .scan) .scan
      (.choose (.nonadvancing (.statement .scan)) .invalid (.tail .current (.statement .scan))))
def readBody : Expr := .group (.choose (.zero (.statement .scan)) .invalid (.tail .current (.statement .scan)))

/-- The executable traversal evaluates each child scanner once. The expression
equations above remain its simple recursive specification. -/
def tailImplementation : Function := ⟨.scan, false,
  .list [guard (.zero .result),
    .choose (.atStop .result) (.ret .result) .nothing,
    .assign (.statement .result), guard (.nonadvancing .result),
    .ret (.tail .current .result)]⟩

def readImplementation : Function := ⟨.statement .scan, true,
  .sequence (guard (.zero .result)) (.ret (.tail .current .result))⟩

theorem tailImplementation_eval (primitive : Primitives) (calls : Calls) (ctx : EvalContext) :
    tailImplementation.eval primitive calls ctx = tailBody.eval primitive calls ctx := by
  by_cases zero : ctx.scan.position = 0
  · simp [tailImplementation, tailBody, Function.eval, Command.list, Command.eval,
      guard, Expr.eval, Condition.eval, zero]
  · by_cases stopped : calls.atStop ctx.text ctx.scan.position ctx.stop = true
    · simp [tailImplementation, tailBody, Function.eval, Command.list, Command.eval,
        guard, Expr.eval, Condition.eval, zero, stopped]
    · by_cases failed : (calls.statement ctx.text ctx.context ctx.scan).position ≤ ctx.scan.position
      all_goals simp [tailImplementation, tailBody, Function.eval, Command.list, Command.eval,
        guard, Expr.eval, Condition.eval, StopRef.eval, zero, stopped, failed]

theorem readImplementation_eval (primitive : Primitives) (calls : Calls) (ctx : EvalContext) :
    readImplementation.eval primitive calls ctx = readBody.eval primitive calls ctx := by
  by_cases zero : (calls.statement ctx.text ctx.context ctx.scan).position = 0
  all_goals simp [readImplementation, readBody, Function.eval, Command.eval, guard,
    Expr.eval, Condition.eval, StopRef.eval, zero]

def conditionalBody : Function := ⟨.token (.literal (.word "if")) .scan, false,
  .list [ .steps [.comparisonExpression, .word "then"], guard (.nonadvancing .result),
    .assign (.read (.literal .arm) .result), guard (.nonadvancing .result),
    .assign (.alternative .result), .steps endIfTokens, finish ]⟩

def alternativeBody : Function := ⟨.scan, false,
  .sequence (guard (.zero .scan))
    (.choose (.tokenPresent (.literal (.word "elsif")) .scan)
      (.list [.steps elsifTokens, guard (.nonadvancing .result),
        .assign (.read (.literal .arm) .result), guard (.nonadvancing .result),
        .ret (.alternative .result)])
      (.choose (.tokenPresent (.literal (.word "else")) .scan)
        (.list [.assign (.token (.literal (.word "else")) .result),
          guard (.nonadvancing .result), .ret (.read (.literal .endOnly) .result)])
        (.choose (.tokenPresent (.literal (.word "end")) .scan) (.ret .scan) (.ret .invalid))))⟩

def stopBody (primitive : Primitives) (text : Source) (position : Nat) : Stop → Bool
  | .endOnly => decide (primitive.take text position (.word "end") ≠ 0)
  | .elseOnly => decide (primitive.take text position (.word "else") ≠ 0)
  | .arm => decide (primitive.take text position (.word "elsif") ≠ 0) ||
      decide (primitive.take text position (.word "else") ≠ 0) ||
      decide (primitive.take text position (.word "end") ≠ 0)

/-- Split fixed renderer text structurally so source certificates can reduce it
in the kernel without the legacy String splitter's well-founded implementation. -/
def words (source : String) : List String :=
  (source.toList.foldr (fun character words =>
    match words with
    | [] => [[character]]
    | word :: rest => if character = ' ' then [] :: word :: rest else (character :: word) :: rest)
    [[]]).map String.ofList

def stopRender : List String :=
  words "case stop is when end_only => take_token ( text , position , end_keyword ) /= 0 , when else_only => take_token ( text , position , else_keyword ) /= 0 , when arm_boundary => take_token ( text , position , elsif_keyword ) /= 0 or else take_token ( text , position , else_keyword ) /= 0 or else take_token ( text , position , end_keyword ) /= 0"

inductive Conversion | contextOf | bodyOf | expand | compact
  deriving DecidableEq

def Conversion.type : Conversion → Type
  | .contextOf => ScanResult → Context
  | .bodyOf => ScanResult → Scan
  | .expand => Context → Scan → ScanResult
  | .compact => Context → ScanResult → Scan
def Conversion.eval : (conversion : Conversion) → conversion.type
  | .contextOf => Native.contextOf
  | .bodyOf => Native.bodyOf
  | .expand => Native.expand
  | .compact => Native.compact
def Conversion.render : Conversion → List String
  | .contextOf => words "names => scan . state . names , dynamic_first => scan . state . dynamic_first , dynamic_after => scan . state . dynamic_after"
  | .bodyOf => words "position => scan . state . position , target => scan . state . target , capacity => scan . state . capacity , assigned => scan . assigned , output => scan . output"
  | .expand => words "state => ( position => scan . position , names => context . names , dynamic_first => context . dynamic_first , dynamic_after => context . dynamic_after , target => scan . target , capacity => scan . capacity ) , assigned => scan . assigned , output => scan . output"
  | .compact => words "if scan . state . position = 0 or else scan . state . target > context . names . count then invalid_body else body_of ( scan )"

inductive Adapter | statements

def Adapter.eval (_ : Adapter) (calls : Calls) (text : Source) (scan : ScanResult) (stop : ShellToken) : ScanResult :=
  let context := contextOf scan
  let result := calls.read text context (bodyOf scan) (if stop = .word "else" then .elseOnly else .endOnly)
  lift context result

def Adapter.render (_ : Adapter) : List String :=
  words "context : constant body_context := context_of ( scan ) ; result : constant body_scan := read_body ( text , context , body_of ( scan ) , ( if stop = else_keyword then else_only else end_only ) ) ; begin return ( if result . position = 0 then invalid_scan else expand_body ( context , result ) ) ; end read_statements ;"

end Silver.Sequence.Native

module

public import Silver.PredicateBodyProperties
public import Silver.PredicateNativeState

@[expose] public section

/-! Typed rendering and interpretation of the recursive native statement scanner.
Only the already modeled primitive expression/predicate scanners are abstract;
recursive body calls remain arbitrary until their equations establish meaning. -/
namespace Silver.Predicate.BodyNative
open Compose

structure Primitives where
  token : Source → Nat → ShellToken → Nat
  basic : Source → Native.Context → BodyScan → BodyScan
  predicate : Source → Native.Context → Nat → PathFacts.Context → ConditionResult

structure Calls where
  statement : Source → Native.Context → BodyScan → BodyScan
  conditional : Source → Native.Context → BodyScan → BodyScan
  alternative : Source → Native.Context → BodyScan → BodyScan
  tail : Source → Native.Context → BodyScan → BodyStop → BodyScan
  read : Source → Native.Context → BodyScan → BodyStop → BodyScan

structure Frame where
  text : Source
  context : Native.Context
  scan : BodyScan
  result : BodyScan := invalidBody
  condition : ConditionResult := invalidCondition
  yes : PathFacts.Context := PathFacts.Context.empty
  stop : BodyStop := .endOnly

inductive StopRef | literal (stop : BodyStop) | current
  deriving DecidableEq

def StopRef.eval (frame : Frame) : StopRef → BodyStop
  | .literal stop => stop | .current => frame.stop

def stopName : BodyStop → String
  | .endOnly => "end_only" | .elseOnly => "else_only" | .arm => "arm_boundary"

def StopRef.render : StopRef → List String
  | .literal stop => [stopName stop] | .current => ["stop"]

inductive ScanExpr
  | input | result | invalid
  | token (token : ShellToken) (value : ScanExpr)
  | basic (value : ScanExpr)
  | statement (value : ScanExpr)
  | conditional (value : ScanExpr)
  | alternative (value : ScanExpr)
  | tail (stop : StopRef) (value : ScanExpr)
  | read (stop : StopRef) (value : ScanExpr)
  deriving DecidableEq

def ScanExpr.eval (primitive : Primitives) (calls : Calls) (frame : Frame) : ScanExpr → BodyScan
  | .input => frame.scan | .result => frame.result | .invalid => invalidBody
  | .token tok value => let scan := value.eval primitive calls frame
      {scan with position := primitive.token frame.text scan.position tok}
  | .basic value => primitive.basic frame.text frame.context (value.eval primitive calls frame)
  | .statement value => calls.statement frame.text frame.context (value.eval primitive calls frame)
  | .conditional value => calls.conditional frame.text frame.context (value.eval primitive calls frame)
  | .alternative value => calls.alternative frame.text frame.context (value.eval primitive calls frame)
  | .tail stop value => calls.tail frame.text frame.context (value.eval primitive calls frame) (stop.eval frame)
  | .read stop value => calls.read frame.text frame.context (value.eval primitive calls frame) (stop.eval frame)

def call := Compose.Expressions.call

def ScanExpr.render : ScanExpr → List String
  | .input => ["scan"] | .result => ["result"] | .invalid => ["invalid_body"]
  | .token tok value => call "body_token" [["text"], ["context"], value.render, [Compose.Expressions.tokenName tok]]
  | .basic value => call "basic_body" [["text"], ["context"], value.render]
  | .statement value => call "statement_body" [["text"], ["context"], value.render]
  | .conditional value => call "conditional_body" [["text"], ["context"], value.render]
  | .alternative value => call "alternative_body" [["text"], ["context"], value.render]
  | .tail stop value => call "body_tail" [["text"], ["context"], value.render, stop.render]
  | .read stop value => call "read_body" [["text"], ["context"], value.render, stop.render]

inductive FactsExpr
  | result | yes | whenTrue | whenFalse
  | join (left right : FactsExpr)
  deriving DecidableEq

def FactsExpr.eval (frame : Frame) : FactsExpr → PathFacts.Context
  | .result => frame.result.facts | .yes => frame.yes
  | .whenTrue => frame.condition.whenTrue | .whenFalse => frame.condition.whenFalse
  | .join left right => (left.eval frame).join (right.eval frame)

def FactsExpr.render : FactsExpr → List String
  | .result => ["result", ".", "facts"] | .yes => ["yes"]
  | .whenTrue => ["condition", ".", "when_true"] | .whenFalse => ["condition", ".", "when_false"]
  | .join left right => ["paths", "."] ++ call "join" [left.render, right.render]

inductive Test
  | zero (value : ScanExpr)
  | nonadvancing (value : ScanExpr)
  | present (token : ShellToken) (value : ScanExpr)
  | stop (value : ScanExpr)
  deriving DecidableEq

def Test.eval (primitive : Primitives) (calls : Calls) (frame : Frame) : Test → Bool
  | .zero value => decide ((value.eval primitive calls frame).position = 0)
  | .nonadvancing value => decide ((value.eval primitive calls frame).position ≤ frame.scan.position)
  | .present token value => decide (primitive.token frame.text (value.eval primitive calls frame).position token ≠ 0)
  | .stop value => atBodyStop frame.text (value.eval primitive calls frame).position frame.stop

def Test.render : Test → List String
  | .zero value => value.render ++ [".", "position", "=", "0"]
  | .nonadvancing value => value.render ++ [".", "position", "<=", "scan", ".", "position"]
  | .present token value => call "take_token" [["text"], value.render ++ [".", "position"],
      [Compose.Expressions.tokenName token]] ++ ["/=", "0"]
  | .stop value => call "at_body_stop" [["text"], value.render ++ [".", "position"], ["stop"]]

inductive Command
  | nothing
  | assign (value : ScanExpr)
  | condition
  | positionAfter
  | facts (value : FactsExpr)
  | saveYes
  | ret (value : ScanExpr)
  | sequence (first second : Command)
  | choose (condition : Test) (yes no : Command)
  deriving DecidableEq

def Command.eval (primitive : Primitives) (calls : Calls) (frame : Frame) : Command → Option BodyScan × Frame
  | .nothing => (none, frame)
  | .assign value => (none, {frame with result := value.eval primitive calls frame})
  | .condition => (none, {frame with condition := primitive.predicate frame.text frame.context frame.result.position frame.result.facts})
  | .positionAfter => (none, {frame with result := {frame.result with position := frame.condition.after}})
  | .facts value => (none, {frame with result := {frame.result with facts := value.eval frame}})
  | .saveYes => (none, {frame with yes := frame.result.facts})
  | .ret value => (some (value.eval primitive calls frame), frame)
  | .sequence first second =>
      let (returned, next) := first.eval primitive calls frame
      match returned with
      | some result => (some result, next)
      | none => second.eval primitive calls next
  | .choose test yes no => if test.eval primitive calls frame then
      yes.eval primitive calls frame else no.eval primitive calls frame

def conditionCall : List String := call "read_condition"
  [["text"], ["context"], ["result", ".", "position"], ["result", ".", "facts"]]

mutual
  def Command.render : Command → List String
    | .nothing => []
    | .assign value => ["result", ":="] ++ value.render ++ [";"]
    | .condition => ["condition", ":="] ++ conditionCall ++ [";"]
    | .positionAfter => ["result", ".", "position", ":=", "condition", ".", "after", ";"]
    | .facts value => ["result", ".", "facts", ":="] ++ value.render ++ [";"]
    | .saveYes => ["yes", ":=", "result", ".", "facts", ";"]
    | .ret value => ["return"] ++ value.render ++ [";"]
    | .sequence first second => first.render ++ second.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++
        no.renderElse ++ ["end", "if", ";"]
  def Command.renderElse : Command → List String
    | .nothing => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | command => ["else"] ++ command.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing

def guard (test : Test) : Command := .choose test (.ret .invalid) .nothing

def finish : Command := .sequence (guard (.nonadvancing .result)) (.ret .result)

inductive Local | conditionConstant | conditionVariable | yes
  deriving DecidableEq

def Local.render : Local → List String
  | .conditionConstant => ["condition", ":", "constant", "condition_result", ":="] ++ conditionCall ++ [";"]
  | .conditionVariable => ["condition", ":", "condition_result", ";"]
  | .yes => ["yes", ":", "paths", ".", "context", ";"]

structure Function where
  initial : ScanExpr
  constant : Bool := false
  locals : List Local := []
  body : Command
  deriving DecidableEq

def Function.eval (fn : Function) (primitive : Primitives) (calls : Calls) (frame : Frame) : BodyScan :=
  let initial := {frame with result := fn.initial.eval primitive calls frame}
  let initialized := if fn.locals.contains .conditionConstant then
    {initial with condition := primitive.predicate initial.text initial.context initial.result.position initial.result.facts}
    else initial
  ((fn.body.eval primitive calls initialized).1).getD invalidBody

def Function.render (fn : Function) (name : String) : List String :=
  ["result", ":"] ++ (if fn.constant then ["constant"] else []) ++ ["body_scan", ":="] ++ fn.initial.render ++ [";"] ++
    (fn.locals.flatMap Local.render) ++ ["begin"] ++ fn.body.render ++ ["end", name, ";"]

def statementRender : List String :=
  ["if", "scan", ".", "position", "=", "0", "then", "invalid_body", "elsif"] ++
  (Test.present (.word "if") .input).render ++ ["then"] ++ (ScanExpr.conditional .input).render ++
  ["else"] ++ (ScanExpr.basic .input).render

def statementEval (primitive : Primitives) (calls : Calls) (frame : Frame) : BodyScan :=
  if (Test.zero .input).eval primitive calls frame then invalidBody
  else if (Test.present (.word "if") .input).eval primitive calls frame then
    (ScanExpr.conditional .input).eval primitive calls frame else (ScanExpr.basic .input).eval primitive calls frame

def tailFunction : Function := ⟨.input, false, [], .list [guard (.zero .result),
  .choose (.stop .result) (.ret .result) .nothing,
  .assign (.statement .result), guard (.nonadvancing .result), .ret (.tail .current .result)]⟩

def readFunction : Function := ⟨.statement .input, true, [], .list [guard (.zero .result), .ret (.tail .current .result)]⟩

def conditionalFunction : Function := ⟨.token (.word "if") .input, false, [.conditionConstant, .yes],
  .list [.positionAfter, .facts .whenTrue, .assign (.token (.word "then") .result),
    guard (.nonadvancing .result), .assign (.read (.literal .arm) .result), guard (.nonadvancing .result),
    .saveYes, .facts .whenFalse, .assign (.alternative .result), .facts (.join .yes .result),
    .assign (.token (.word "end") .result), .assign (.token (.word "if") .result),
    .assign (.token (.symbol ";") .result), finish]⟩

def alternativeFunction : Function := ⟨.input, false, [.conditionVariable, .yes],
  .sequence (guard (.zero .input)) (.choose (.present (.word "elsif") .input)
    (.list [.assign (.token (.word "elsif") .result), .condition, .positionAfter,
      .facts .whenTrue, .assign (.token (.word "then") .result), guard (.nonadvancing .result),
      .assign (.read (.literal .arm) .result), guard (.nonadvancing .result), .saveYes,
      .facts .whenFalse, .assign (.alternative .result), .facts (.join .yes .result), .ret .result])
    (.choose (.present (.word "else") .input)
      (.list [.assign (.token (.word "else") .result), guard (.nonadvancing .result),
        .ret (.read (.literal .endOnly) .result)])
      (.choose (.present (.word "end") .input) (.ret .input) (.ret .invalid))))⟩

def modelPrimitives : Primitives where
  token := tokenAfter
  basic text context scan := basicBody text context.model scan
  predicate text context position facts := readCondition text context.model position facts

def modelCalls : Calls where
  statement text context scan := statementBody text context.model scan
  conditional text context scan := conditionalBody text context.model scan
  alternative text context scan := alternativeBody text context.model scan
  tail text context scan stop := bodyTail text context.model scan stop
  read text context scan stop := readBody text context.model scan stop

end Silver.Predicate.BodyNative

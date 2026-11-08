module

public import Silver.PredicateBodyProperties
public import Silver.PredicateNativeState
public import Silver.PredicateBodyWrappers
public import Silver.PredicateLoopNative

@[expose] public section

/-! Typed rendering and interpretation of the recursive native statement scanner.
Only the already modeled primitive expression/predicate scanners are abstract;
recursive body calls remain arbitrary until their equations establish meaning. -/
namespace Silver.Predicate.BodyNative
open Compose

structure Primitives where
  loop : LoopNative.Imports
  token : Source → Nat → ShellToken → Nat
  bodyToken : Source → Native.Context → BodyScan → ShellToken → BodyScan
  basic : Source → Native.Context → BodyScan → FunctionBindings.Metadata → BodyScan
  predicate : Source → Native.Context → Nat → ActiveFlow → ConditionResult
  invalidModel : BodyScan → BodyScan
  invalid : BodyScan → BodyScan
  joinInto : ActiveFlow → ActiveFlow → ActiveFlow

structure Calls where
  statement : Source → Native.Context → BodyScan → FunctionBindings.Metadata → BodyScan
  loop : Source → Native.Context → BodyScan → FunctionBindings.Metadata → BodyScan
  conditional : Source → Native.Context → BodyScan → FunctionBindings.Metadata → BodyScan
  alternative : Source → Native.Context → BodyScan → FunctionBindings.Metadata → BodyScan
  tailModel : Source → Native.Context → BodyScan → BodyStop → FunctionBindings.Metadata → BodyScan
  tail : Source → Native.Context → BodyScan → BodyStop → FunctionBindings.Metadata → BodyScan
  read : Source → Native.Context → BodyScan → BodyStop → FunctionBindings.Metadata → BodyScan

structure Frame where
  catalog : FunctionBindings.Metadata
  text : Source
  context : Native.Context
  scan : BodyScan
  result : BodyScan := invalidBody scan
  condition : ConditionResult := invalidCondition scan.facts
  yes : ActiveFlow := scan.facts.invalid
  stop : BodyStop := .endOnly

inductive StopRef | literal (stop : BodyStop) | current
  deriving DecidableEq

def StopRef.eval (frame : Frame) : StopRef → BodyStop
  | .literal stop => stop | .current => frame.stop

def stopName : BodyStop → String
  | .endOnly => "end_only" | .elseOnly => "else_only" | .arm => "arm_boundary" | .returnOnly => "return_only"

def StopRef.render : StopRef → List String
  | .literal stop => [stopName stop] | .current => ["stop"]

inductive ScanExpr
  | input | result
  | invalid (value : ScanExpr)
  | invalidModel (value : ScanExpr)
  | token (token : ShellToken) (value : ScanExpr)
  | basic (value : ScanExpr)
  | statement (value : ScanExpr)
  | loop (value : ScanExpr)
  | conditional (value : ScanExpr)
  | alternative (value : ScanExpr)
  | tailModel (stop : StopRef) (value : ScanExpr)
  | tail (stop : StopRef) (value : ScanExpr)
  | read (stop : StopRef) (value : ScanExpr)
  deriving DecidableEq

def ScanExpr.eval (primitive : Primitives) (calls : Calls) (frame : Frame) : ScanExpr → BodyScan
  | .input => frame.scan | .result => frame.result
  | .invalid value => primitive.invalid (value.eval primitive calls frame)
  | .invalidModel value => primitive.invalidModel (value.eval primitive calls frame)
  | .token tok value => primitive.bodyToken frame.text frame.context (value.eval primitive calls frame) tok
  | .basic value => primitive.basic frame.text frame.context (value.eval primitive calls frame) frame.catalog
  | .statement value => calls.statement frame.text frame.context (value.eval primitive calls frame) frame.catalog
  | .loop value => calls.loop frame.text frame.context (value.eval primitive calls frame) frame.catalog
  | .conditional value => calls.conditional frame.text frame.context (value.eval primitive calls frame) frame.catalog
  | .alternative value => calls.alternative frame.text frame.context (value.eval primitive calls frame) frame.catalog
  | .tailModel stop value => calls.tailModel frame.text frame.context (value.eval primitive calls frame) (stop.eval frame) frame.catalog
  | .tail stop value => calls.tail frame.text frame.context (value.eval primitive calls frame) (stop.eval frame) frame.catalog
  | .read stop value => calls.read frame.text frame.context (value.eval primitive calls frame) (stop.eval frame) frame.catalog

def call := Compose.Expressions.call

def ScanExpr.render : ScanExpr → List String
  | .input => ["scan"] | .result => ["result"]
  | .invalid value => call "invalid_body" [value.render]
  | .invalidModel value => call "invalid_body_model" [value.render]
  | .token tok value => call "body_token" [["text"], ["context"], value.render, [Compose.Expressions.tokenName tok]]
  | .basic value => call "basic_body" [["text"], ["context"], value.render, ["catalog"]]
  | .statement value => call "statement_body" [["text"], ["context"], value.render, ["catalog"]]
  | .loop value => call "loop_body" [["text"], ["context"], value.render, ["catalog"]]
  | .conditional value => call "conditional_body" [["text"], ["context"], value.render, ["catalog"]]
  | .alternative value => call "alternative_body" [["text"], ["context"], value.render, ["catalog"]]
  | .tailModel stop value => call "body_tail_model" [["text"], ["context"], value.render, stop.render, ["catalog"]]
  | .tail stop value => call "body_tail" [["text"], ["context"], value.render, stop.render, ["catalog"]]
  | .read stop value => call "read_body" [["text"], ["context"], value.render, stop.render, ["catalog"]]

inductive FactsExpr
  | result | yes | whenTrue | whenFalse
  deriving DecidableEq

def FactsExpr.eval (frame : Frame) : FactsExpr → ActiveFlow
  | .result => frame.result.facts | .yes => frame.yes
  | .whenTrue => frame.condition.whenTrue | .whenFalse => frame.condition.whenFalse

def FactsExpr.render : FactsExpr → List String
  | .result => ["result", ".", "facts"] | .yes => ["yes"]
  | .whenTrue => ["condition", ".", "when_true"] | .whenFalse => ["condition", ".", "when_false"]

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
  | joinYes
  | ret (value : ScanExpr)
  | sequence (first second : Command)
  | choose (condition : Test) (yes no : Command)
  deriving DecidableEq

/-- Executable meaning of the exact source commands. The fixed Static assertions
and Static Lemma_Joined_Flow call attached to saveYes/joinYes in the rendering
are erased by the native frontend. Source checks require that helper's complete
Ghost/Global/pre/post header, and native verification must prove its obligations
and every call precondition; there is no generic ignored-source constructor. -/
def Command.eval (primitive : Primitives) (calls : Calls) (frame : Frame) : Command → Option BodyScan × Frame
  | .nothing => (none, frame)
  | .assign value => (none, {frame with result := value.eval primitive calls frame})
  | .condition => (none, {frame with condition := primitive.predicate frame.text frame.context frame.result.position frame.result.facts})
  | .positionAfter => (none, {frame with result := {frame.result with position := frame.condition.after}})
  | .facts value => (none, {frame with result := {frame.result with facts := value.eval frame}})
  | .saveYes => (none, {frame with yes := frame.result.facts})
  | .joinYes => (none, {frame with result := {frame.result with
      facts := primitive.joinInto frame.result.facts frame.yes}})
  | .ret value => (some (value.eval primitive calls frame), frame)
  | .sequence first second =>
      let (returned, next) := first.eval primitive calls frame
      match returned with
      | some result => (some result, next)
      | none => second.eval primitive calls next
  | .choose test yes no => if test.eval primitive calls frame then
      yes.eval primitive calls frame else no.eval primitive calls frame

def conditionCall : List String := call "read_condition_into"
  [["text"], ["context"], ["result", ".", "position"], ["result", ".", "facts"], ["condition"]]

mutual
  def Command.render : Command → List String
    | .nothing => []
    | .assign value => ["result", ":="] ++ value.render ++ [";"]
    | .condition => conditionCall ++ [";"]
    | .positionAfter => ["result", ".", "position", ":=", "condition", ".", "after", ";"]
    | .facts value => ["result", ".", "facts", ":="] ++ value.render ++ [";"]
    | .saveYes => ["yes", ":=", "result", ".", "facts", ";"] ++
        ["pragma", "assert", "(", "static", "=>"] ++
        call "valid_flow" [["context"], ["yes"]] ++ [")", ";"]
    | .joinYes =>
        ["pragma", "assert", "(", "static", "=>"] ++
        call "valid_flow" [["context"], ["result", ".", "facts"]] ++ [")", ";"] ++
        call "lemma_joined_flow" [["context"], ["result", ".", "facts"], ["yes"]] ++ [";"] ++
        call "join_into" [["result", ".", "facts"], ["yes"]] ++ [";"] ++
        ["pragma", "assert", "(", "static", "=>"] ++
        call "valid_flow" [["context"], ["result", ".", "facts"]] ++ [")", ";"]
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

def guard (test : Test) (failure : ScanExpr := .input) : Command :=
  .choose test (.ret (.invalid failure)) .nothing

def finish : Command := .sequence (guard (.nonadvancing .result)) (.ret .result)

inductive Local | conditionVariable | yes
  deriving DecidableEq

def Local.render : Local → List String
  | .conditionVariable => ["condition", ":", "condition_result", "(", "scan", ".", "count", ")", ";"]
  | .yes => ["yes", ":", "scalar_flow", "(", "scan", ".", "count", ")", ";"]

structure Function where
  initial : ScanExpr
  constant : Bool := false
  locals : List Local := []
  body : Command
  deriving DecidableEq

def Function.eval (fn : Function) (primitive : Primitives) (calls : Calls) (frame : Frame) : BodyScan :=
  let initial := {frame with result := fn.initial.eval primitive calls frame}
  ((fn.body.eval primitive calls initial).1).getD (primitive.invalid frame.scan)

def Function.render (fn : Function) (name : String) : List String :=
  ["result", ":"] ++ (if fn.constant then ["constant"] else []) ++ ["body_scan", "(", "scan", ".", "count", ")", ":="] ++ fn.initial.render ++ [";"] ++
    (fn.locals.flatMap Local.render) ++ ["begin"] ++ fn.body.render ++ ["end", name, ";"]

def statementRender : List String :=
  ["if", "scan", ".", "position", "=", "0", "then"] ++
  (ScanExpr.invalid .input).render ++ ["elsif"] ++
  (Test.present (.word "if") .input).render ++ ["then"] ++ (ScanExpr.conditional .input).render ++
  ["elsif"] ++ (Test.present (.word "for") .input).render ++ ["then"] ++ (ScanExpr.loop .input).render ++
  ["else"] ++ (ScanExpr.basic .input).render

def statementEval (primitive : Primitives) (calls : Calls) (frame : Frame) : BodyScan :=
  if (Test.zero .input).eval primitive calls frame then primitive.invalid frame.scan
  else if (Test.present (.word "if") .input).eval primitive calls frame then
    (ScanExpr.conditional .input).eval primitive calls frame
  else if (Test.present (.word "for") .input).eval primitive calls frame then
    (ScanExpr.loop .input).eval primitive calls frame else (ScanExpr.basic .input).eval primitive calls frame

/-- The recursive Static model is interpreted independently of the executable
Body_Tail loop. The constrained local retains its source allocation count. -/
inductive ModelExpr
  | value : ScanExpr → ModelExpr
  | choose : Test → ModelExpr → ModelExpr → ModelExpr
  | elsif : Test → ModelExpr → ModelExpr → ModelExpr
  | localResult : ScanExpr → ModelExpr → ModelExpr
  | group : ModelExpr → ModelExpr
  deriving DecidableEq

def ModelExpr.eval (primitive : Primitives) (calls : Calls) (frame : Frame) : ModelExpr → BodyScan
  | .value expression => expression.eval primitive calls frame
  | .group expression => expression.eval primitive calls frame
  | .choose test yes no | .elsif test yes no =>
      if test.eval primitive calls frame then yes.eval primitive calls frame else no.eval primitive calls frame
  | .localResult initial rest => rest.eval primitive calls {frame with result := initial.eval primitive calls frame}

mutual
  def ModelExpr.render : ModelExpr → List String
    | .value expression => expression.render
    | .group expression => ["("] ++ expression.render ++ [")"]
    | .choose test yes no | .elsif test yes no =>
        ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | .localResult initial rest =>
        ["(", "declare", "result", ":", "constant", "body_scan", "(", "scan", ".", "count", ")", ":="] ++
        initial.render ++ [";", "begin", "("] ++ rest.render ++ [")", ")"]
  def ModelExpr.renderElse : ModelExpr → List String
    | .elsif test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | expression => ["else"] ++ expression.render
end

/-- Ada's elsif spelling belongs to the preceding conditional expression. -/
def tailModelBody : ModelExpr :=
  .choose (.zero .input) (.value (.invalidModel .input))
    (.elsif (.stop .input) (.value .input)
      (.localResult (.statement .input)
        (.choose (.nonadvancing .result) (.value (.invalidModel .result)) (.value (.tailModel .current .result)))))

def readContractBody : ModelExpr :=
  .group (.choose (.zero (.statement .input)) (.value (.invalid (.statement .input)))
    (.value (.tailModel .current (.statement .input))))

def readFunction : Function := ⟨.statement .input, true, [], .list [guard (.zero .result) .result, .ret (.tail .current .result)]⟩

def conditionalFunction : Function := ⟨.token (.word "if") .input, false, [.conditionVariable, .yes],
  .list [.condition, .positionAfter, .facts .whenTrue, .assign (.token (.word "then") .result),
    guard (.nonadvancing .result), .assign (.read (.literal .arm) .result), guard (.nonadvancing .result),
    .saveYes, .facts .whenFalse, .assign (.alternative .result), .joinYes,
    .assign (.token (.word "end") .result), .assign (.token (.word "if") .result),
    .assign (.token (.symbol ";") .result), finish]⟩

def alternativeFunction : Function := ⟨.input, false, [.conditionVariable, .yes],
  .sequence (guard (.zero .input)) (.choose (.present (.word "elsif") .input)
    (.list [.assign (.token (.word "elsif") .result), .condition, .positionAfter,
      .facts .whenTrue, .assign (.token (.word "then") .result), guard (.nonadvancing .result),
      .assign (.read (.literal .arm) .result), guard (.nonadvancing .result), .saveYes,
      .facts .whenFalse, .assign (.alternative .result), .joinYes, .ret .result])
    (.choose (.present (.word "else") .input)
      (.list [.assign (.token (.word "else") .result), guard (.nonadvancing .result),
        .ret (.read (.literal .endOnly) .result)])
      (.choose (.present (.word "end") .input) (.ret .input) (.ret (.invalid .input)))))⟩

def modelPrimitives : Primitives where
  loop := LoopNative.modelImports
  token := tokenAfter
  bodyToken text _ scan token := Predicate.bodyToken text scan token
  basic text context scan catalog := basicBody text context.model scan catalog
  predicate text context position facts := readCondition text context.model position facts
  invalidModel := invalidBody
  invalid := invalidBody
  joinInto := ActiveFlow.join

def modelCalls : Calls where
  statement text context scan catalog := statementBody text context.model scan catalog
  loop text context scan catalog := loopBody text context.model scan catalog
  conditional text context scan catalog := conditionalBody text context.model scan catalog
  alternative text context scan catalog := alternativeBody text context.model scan catalog
  tailModel text context scan stop catalog := bodyTail text context.model scan stop catalog
  tail text context scan stop catalog := bodyTail text context.model scan stop catalog
  read text context scan stop catalog := readBody text context.model scan stop catalog

end Silver.Predicate.BodyNative

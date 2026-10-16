module

public import Silver.PredicateBodyAdmission
public import Silver.PredicateNativeState
public import Silver.LengthIntervalModel

@[expose] public section

namespace Silver.Predicate.BasicNative
open Compose Bindings

/-- Expand_Body preserves native immutable argument-name fields. Basic_Body
only observes the returned target scanner's position and target. -/
def expandedState (context : Native.Context) (scan : BodyScan) : ParserState :=
  ⟨scan.position, context.names, context.dynamicFirst, context.dynamicAfter, scan.target, scan.capacity, context.scalarNames⟩

structure Primitives where
  callAfter : Source → Compose.BindingEnvironment → Nat → Names.Operation → ScalarExpression.Environment → Nat
  associationAfter : Source → Nat → Bool → Nat
  token : Source → Nat → ShellToken → Nat
  expression : Source → Nat → Compose.BindingEnvironment → ScalarExpression.Environment → ExpressionResult
  target : Source → ParserState → Bool → ParserState
  fits : PathFacts.Context → LengthSummary → Bool
  sameLength : PathFacts.Context → LengthSummary → LengthSummary → Bool
  reject : PathFacts.Context → PathFacts.Context

structure Frame where
  text : Source
  context : Native.Context
  scan : BodyScan
  result : BodyScan := invalidBody
  value : ExpressionResult := {}
  state : ParserState := invalidState

def bindingSummary (info : Compose.BindingInfo) : LengthSummary := .ofExact info.bound.summary

def Primitives.bodyToken (primitive : Primitives) (text : Source) (scan : BodyScan) (token : ShellToken) : BodyScan :=
  {scan with position := primitive.token text scan.position token}

inductive Test
  | operation (value : Names.Operation)
  | zeroResult | nonadvancing | present (token : ShellToken) | hasArguments
  | zeroValue | invalidInput | notFits | zeroTarget | notSameLength
  | orElse (left right : Test) | andThen (left right : Test)

def Test.eval (primitive : Primitives) (frame : Frame) : Test → Bool
  | .operation value => decide (primitive.callAfter frame.text frame.context.names frame.result.position value frame.context.scalarNames ≠ 0)
  | .zeroResult => decide (frame.result.position = 0)
  | .nonadvancing => decide (frame.result.position ≤ frame.scan.position)
  | .present token => decide (primitive.token frame.text frame.result.position token ≠ 0)
  | .hasArguments => decide (frame.context.dynamicFirst ≠ 0)
  | .zeroValue => decide (frame.value.after = 0)
  | .invalidInput => frame.result.facts.invalidReachable
  | .notFits => !primitive.fits frame.result.facts (summaryOf frame.value)
  | .zeroTarget => decide (frame.result.target = 0)
  | .notSameLength => !primitive.sameLength frame.result.facts (summaryOf frame.value)
      (bindingSummary ((frame.context.names.get frame.result.target).getD {}))
  | .orElse left right => left.eval primitive frame || right.eval primitive frame
  | .andThen left right => left.eval primitive frame && right.eval primitive frame

def call := Compose.Expressions.call

def Test.render : Test → List String
  | .operation value => call "call_after" [["text"], ["context", ".", "names"], ["result", ".", "position"], (Compose.Expressions.Expr.operation value).render, ["context", ".", "scalar_names"]] ++ ["/=", "0"]
  | .zeroResult => ["result", ".", "position", "=", "0"]
  | .nonadvancing => ["result", ".", "position", "<=", "scan", ".", "position"]
  | .present token => call "take_token" [["text"], ["result", ".", "position"], [Compose.Expressions.tokenName token]] ++ ["/=", "0"]
  | .hasArguments => ["context", ".", "dynamic_first", "/=", "0"]
  | .zeroValue => ["value", ".", "after", "=", "0"]
  | .invalidInput => ["result", ".", "facts", ".", "invalid_reachable"]
  | .notFits => ["not", "length_intervals", "."] ++ call "fits"
      [["result", ".", "facts"], call "summary_of" [["value"]]]
  | .zeroTarget => ["result", ".", "target", "=", "0"]
  | .notSameLength => ["not", "length_intervals", "."] ++ call "same_length"
      [["result", ".", "facts"], call "summary_of" [["value"]], call "binding_summary"
        [["context", ".", "names", ".", "items", "(", "result", ".", "target", ")"]]]
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render

inductive Update
  | operation (value : Names.Operation) | association
  | token (token : ShellToken)
  | valueAfter | statePosition | stateTarget | output | assigned | rejected

def Update.eval (primitive : Primitives) (frame : Frame) : Update → BodyScan
  | .operation value => {frame.result with position := primitive.callAfter frame.text frame.context.names frame.result.position value frame.context.scalarNames}
  | .association => {frame.result with position := primitive.associationAfter frame.text frame.result.position false}
  | .token tok => primitive.bodyToken frame.text frame.result tok
  | .valueAfter => {frame.result with position := frame.value.after}
  | .statePosition => {frame.result with position := frame.state.position}
  | .stateTarget => {frame.result with target := frame.state.target}
  | .output => {frame.result with output := true}
  | .assigned => {frame.result with assigned := true}
  | .rejected => {frame.result with facts := primitive.reject frame.result.facts}

def Update.render : Update → List String
  | .operation value => ["result", ".", "position", ":="] ++ call "call_after" [["text"], ["context", ".", "names"], ["result", ".", "position"], (Compose.Expressions.Expr.operation value).render, ["context", ".", "scalar_names"]] ++ [";"]
  | .association => ["result", ".", "position", ":=", "names", "."] ++ call "association_after" [["text"], ["result", ".", "position"], ["false"]] ++ [";"]
  | .token tok => ["result", ":="] ++ call "body_token"
      [["text"], ["context"], ["result"], [Compose.Expressions.tokenName tok]] ++ [";"]
  | .valueAfter => ["result", ".", "position", ":=", "value", ".", "after", ";"]
  | .statePosition => ["result", ".", "position", ":=", "state", ".", "position", ";"]
  | .stateTarget => ["result", ".", "target", ":=", "state", ".", "target", ";"]
  | .output => ["result", ".", "output", ":=", "true", ";"]
  | .assigned => ["result", ".", "assigned", ":=", "true", ";"]
  | .rejected => ["result", ".", "facts", ":=", "paths", "."] ++ call "rejected" [["result", ".", "facts"]] ++ [";"]

inductive Command
  | nothing | update (value : Update) | expression | target | returnInvalid | returnResult
  | sequence (first second : Command) | choose (test : Test) (yes no : Command)

/-- Continuation interpretation of the finite imperative block; return bypasses the continuation. -/
def Command.eval (primitive : Primitives) (frame : Frame) (next : Frame → BodyScan) : Command → BodyScan
  | .nothing => next frame
  | .update value => next {frame with result := value.eval primitive frame}
  | .expression => next {frame with value := primitive.expression frame.text frame.result.position frame.context.names frame.context.scalarNames}
  | .target => next {frame with state := primitive.target frame.text (expandedState frame.context frame.result) false}
  | .returnInvalid => invalidBody
  | .returnResult => frame.result
  | .sequence first second => first.eval primitive frame (fun updated => second.eval primitive updated next)
  | .choose test yes no => if test.eval primitive frame then yes.eval primitive frame next else no.eval primitive frame next

mutual
  def Command.render : Command → List String
    | .nothing => [] | .update value => value.render
    | .expression => ["value", ":="] ++ call "expression_at" [["text"], ["result", ".", "position"], ["context", ".", "names"], ["context", ".", "scalar_names"]] ++ [";"]
    | .target => ["state", ":="] ++ call "target_at"
        [["text"], call "expand_body" [["context"], ["result"]] ++ [".", "state"], ["false"]] ++ [";"]
    | .returnInvalid => ["return", "invalid_body", ";"] | .returnResult => ["return", "result", ";"]
    | .sequence first second => first.render ++ second.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
  def Command.renderElse : Command → List String
    | .nothing => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | value => ["else"] ++ value.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing
def guard (test : Test) : Command := .choose test .returnInvalid .nothing
def outputCommands : Command := .list [
  .update (.operation .output), .update (.token (.symbol "(")), .update .association, .expression,
  guard (.orElse (.orElse .zeroValue .invalidInput) .notFits), .update .valueAfter,
  .update (.token (.symbol ")")), .update .output]
def putCommands : Command := .list [
  .update (.operation .partialOutput), .update (.token (.symbol "(")), .update .association, .expression,
  guard (.orElse (.orElse .zeroValue .invalidInput) .notFits), .update .valueAfter,
  .update (.token (.symbol ")")), .update .output]
def rejectCommands : Command := .list [
  .update (.operation .reject), .update .rejected]
def assignmentCommands : Command := .list [
  .target, .update .statePosition, .update .stateTarget,
  .update (.token (.symbol ":=")), .expression,
  guard (.orElse (.orElse (.orElse .zeroValue .zeroTarget) .notFits) .notSameLength),
  .update .valueAfter, .update .assigned]
def dispatchCommands : Command :=
  .choose (.present (.word "null")) (.update (.token (.word "null")))
    (.choose (.operation .output) outputCommands
      (.choose (.operation .partialOutput) putCommands
        (.choose (.andThen .hasArguments (.operation .reject)) rejectCommands assignmentCommands)))
def basicCommands : Command := .list [guard .zeroResult, dispatchCommands,
  .update (.token (.symbol ";")), guard .nonadvancing, .returnResult]

def basicRender : List String :=
  ["result", ":", "body_scan", ":=", "scan", ";", "value", ":", "expression_result", ";",
    "state", ":", "parser_state", ";", "begin"] ++ basicCommands.render ++ ["end", "basic_body", ";"]

def basicEval (primitive : Primitives) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  basicCommands.eval primitive ⟨text, context, scan, scan, {}, invalidState⟩ (fun _ => invalidBody)

def modelPrimitives : Primitives where
  callAfter := fun text names position operation scalarNames => Compose.callAfter text names position operation scalarNames
  associationAfter := Names.associationAfter
  token := tokenAfter
  expression := fun text position names scalarNames => expressionAt text position names scalarNames
  target := targetAt
  fits := fitsLengthSummary
  sameLength := equalLengthIntervals
  reject := PathFacts.Context.reject

end Silver.Predicate.BasicNative

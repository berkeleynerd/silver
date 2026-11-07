module

public import Silver.PredicateBodyAdmission
public import Silver.PredicateBooleanBodyNative
public import Silver.PredicateBooleanArrayBodyNative
public import Silver.PredicateScalarBodyNative
public import Silver.PredicateArrayBodyNative
public import Silver.PredicateNativeState
public import Silver.LengthIntervalModel

@[expose] public section

namespace Silver.Predicate.BasicNative
open Compose Bindings

structure Primitives where
  callAfter : Source → Compose.BindingEnvironment → Nat → Names.Operation → ScalarExpression.Environment → ArrayBindings.Metadata → Bool → BooleanBindings.Environment → Nat
  associationAfter : Source → Nat → Bool → Nat
  token : Source → Nat → ShellToken → Nat
  expression : Source → Native.Context → Nat → ActiveFlow → ExpressionResult
  readingNames : Native.Context → ActiveFlow → ScalarExpression.Environment
  character : Source → Nat → Compose.BindingEnvironment → ScalarExpression.Environment →
    ArrayBindings.Metadata → ValueResult
  indexed : Source → Nat → Compose.BindingEnvironment → ScalarExpression.Environment →
    ArrayBindings.Metadata → ArrayBindings.Initials → Bool → Bool → ValueResult
  target : Source → Native.Context → Nat → ScalarBodyNative.StringTargetResult
  bodyToken : Source → Native.Context → BodyScan → ShellToken → BodyScan
  invalid : BodyScan → BodyScan
  scalarTarget : Source → Native.Context → Nat → Nat
  scalarAssignment : Source → Native.Context → BodyScan → BodyScan
  booleanTarget : Source → Native.Context → Nat → Nat
  booleanAssignment : Source → Native.Context → BodyScan → BodyScan
  arrayTarget : Source → Native.Context → Nat → Nat
  arrayAssignment : Source → Native.Context → BodyScan → BodyScan
  booleanArrayAssignment : Source → Native.Context → BodyScan → BodyScan
  fits : PathFacts.Context → LengthSummary → Bool
  sameLength : PathFacts.Context → LengthSummary → LengthSummary → Bool
  reject : PathFacts.Context → PathFacts.Context

structure Frame where
  text : Source
  context : Native.Context
  scan : BodyScan
  result : BodyScan := scan
  value : ExpressionResult := {}
  target : ScalarBodyNative.StringTargetResult := {}
  characterValue : ValueResult := {}

def bindingSummary (info : Compose.BindingInfo) : LengthSummary := .ofExact info.bound.summary

inductive Test
  | operation (value : Names.Operation)
  | zeroResult | nonadvancing | present (token : ShellToken) | hasArguments
  | zeroValue | zeroCharacter | characterTarget | invalidInput | notFits | zeroTarget | notSameLength | scalarTarget | booleanTarget | arrayTarget | booleanArrayTarget
  | orElse (left right : Test) | andThen (left right : Test)

def Test.eval (primitive : Primitives) (frame : Frame) : Test → Bool
  | .operation value => decide (primitive.callAfter frame.text frame.context.names frame.result.position value frame.context.scalarNames frame.context.arrayNames (frame.context.subtypeHiding.get value) frame.context.booleanNames ≠ 0)
  | .zeroResult => decide (frame.result.position = 0)
  | .nonadvancing => decide (frame.result.position ≤ frame.scan.position)
  | .present token => decide (primitive.token frame.text frame.result.position token ≠ 0)
  | .hasArguments => decide (frame.context.dynamicFirst ≠ 0)
  | .zeroValue => decide (frame.value.after = 0)
  | .zeroCharacter => decide (frame.characterValue.after = 0)
  | .characterTarget => ((frame.context.names.get frame.result.target).getD {}).isCharacter
  | .invalidInput => frame.result.facts.path.invalidReachable
  | .notFits => !primitive.fits frame.result.facts.path (summaryOf frame.value)
  | .scalarTarget => decide (primitive.scalarTarget frame.text frame.context frame.result.position ≠ 0)
  | .booleanTarget => decide (primitive.booleanTarget frame.text frame.context frame.result.position ≠ 0)
  | .arrayTarget => decide (primitive.arrayTarget frame.text frame.context frame.result.position ≠ 0)
  | .booleanArrayTarget => (ArrayBindings.binding frame.context.arrayNames
      (primitive.arrayTarget frame.text frame.context frame.result.position)).isBoolean
  | .zeroTarget => decide (frame.result.target = 0)
  | .notSameLength => !primitive.sameLength frame.result.facts.path (summaryOf frame.value)
      (bindingSummary ((frame.context.names.get frame.result.target).getD {}))
  | .orElse left right => left.eval primitive frame || right.eval primitive frame
  | .andThen left right => left.eval primitive frame && right.eval primitive frame

def call := Compose.Expressions.call

def Test.render : Test → List String
  | .operation value => call "call_after" [["text"], ["context", ".", "names"], ["result", ".", "position"], (Compose.Expressions.Expr.operation value).render, ["context", ".", "scalar_names"], ["context", ".", "array_names"], ["context", ".", "subtype_hiding", "("] ++ (Compose.Expressions.Expr.operation value).render ++ [")"], ["context", ".", "boolean_names"]] ++ ["/=", "0"]
  | .zeroResult => ["result", ".", "position", "=", "0"]
  | .nonadvancing => ["result", ".", "position", "<=", "scan", ".", "position"]
  | .present token => call "take_token" [["text"], ["result", ".", "position"], [Compose.Expressions.tokenName token]] ++ ["/=", "0"]
  | .hasArguments => ["context", ".", "dynamic_first", "/=", "0"]
  | .zeroValue => ["value", ".", "after", "=", "0"]
  | .zeroCharacter => ["character_value", ".", "after", "=", "0"]
  | .characterTarget => ["context", ".", "names", ".", "items", "(", "result", ".", "target", ")", ".", "is_character"]
  | .invalidInput => ["result", ".", "facts", ".", "path", ".", "invalid_reachable"]
  | .notFits => ["not", "length_intervals", "."] ++ call "fits"
      [["result", ".", "facts", ".", "path"], call "summary_of" [["value"]]]
  | .scalarTarget => call "scalar_target" [["text"], ["context"], ["result", ".", "position"]] ++ ["/=", "0"]
  | .booleanTarget => call "boolean_target" [["text"], ["context"], ["result", ".", "position"]] ++ ["/=", "0"]
  | .arrayTarget => call "array_target" [["text"], ["context"], ["result", ".", "position"]] ++ ["/=", "0"]
  | .booleanArrayTarget => ["context", ".", "array_names", ".", "items", "("] ++
      call "array_target" [["text"], ["context"], ["result", ".", "position"]] ++ [")", ".", "boolean_elements"]
  | .zeroTarget => ["result", ".", "target", "=", "0"]
  | .notSameLength => ["not", "length_intervals", "."] ++ call "same_length"
      [["result", ".", "facts", ".", "path"], call "summary_of" [["value"]], call "binding_summary"
        [["context", ".", "names", ".", "items", "(", "result", ".", "target", ")"]]]
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render

inductive Update
  | operation (value : Names.Operation) | association
  | token (token : ShellToken)
  | valueAfter | characterAfter | statePosition | stateTarget | output | assigned | rejected | scalarAssignment | booleanAssignment | arrayAssignment | booleanArrayAssignment

def Update.eval (primitive : Primitives) (frame : Frame) : Update → BodyScan
  | .operation value => {frame.result with position := primitive.callAfter frame.text frame.context.names frame.result.position value frame.context.scalarNames frame.context.arrayNames (frame.context.subtypeHiding.get value) frame.context.booleanNames}
  | .association => {frame.result with position := primitive.associationAfter frame.text frame.result.position false}
  | .token tok => primitive.bodyToken frame.text frame.context frame.result tok
  | .scalarAssignment => primitive.scalarAssignment frame.text frame.context frame.result
  | .booleanAssignment => primitive.booleanAssignment frame.text frame.context frame.result
  | .arrayAssignment => primitive.arrayAssignment frame.text frame.context frame.result
  | .booleanArrayAssignment => primitive.booleanArrayAssignment frame.text frame.context frame.result
  | .valueAfter => {frame.result with position := frame.value.after}
  | .characterAfter => {frame.result with position := frame.characterValue.after}
  | .statePosition => {frame.result with position := frame.target.after}
  | .stateTarget => {frame.result with target := frame.target.target}
  | .output => {frame.result with output := true}
  | .assigned => {frame.result with assigned := true}
  | .rejected => {frame.result with facts := {frame.result.facts with path := primitive.reject frame.result.facts.path}}

def Update.render : Update → List String
  | .operation value => ["result", ".", "position", ":="] ++ call "call_after" [["text"], ["context", ".", "names"], ["result", ".", "position"], (Compose.Expressions.Expr.operation value).render, ["context", ".", "scalar_names"], ["context", ".", "array_names"], ["context", ".", "subtype_hiding", "("] ++ (Compose.Expressions.Expr.operation value).render ++ [")"], ["context", ".", "boolean_names"]] ++ [";"]
  | .association => ["result", ".", "position", ":=", "names", "."] ++ call "association_after" [["text"], ["result", ".", "position"], ["false"]] ++ [";"]
  | .token tok => ["result", ":="] ++ call "body_token"
      [["text"], ["context"], ["result"], [Compose.Expressions.tokenName tok]] ++ [";"]
  | .scalarAssignment => ["result", ":="] ++ call "scalar_assignment_body" [["text"], ["context"], ["result"]] ++ [";"]
  | .booleanAssignment => ["result", ":="] ++ call "boolean_assignment_body" [["text"], ["context"], ["result"]] ++ [";"]
  | .arrayAssignment => ["result", ":="] ++ call "array_assignment_body" [["text"], ["context"], ["result"]] ++ [";"]
  | .booleanArrayAssignment => ["result", ":="] ++ call "boolean_array_assignment_body" [["text"], ["context"], ["result"]] ++ [";"]
  | .valueAfter => ["result", ".", "position", ":=", "value", ".", "after", ";"]
  | .characterAfter => ["result", ".", "position", ":=", "character_value", ".", "after", ";"]
  | .statePosition => ["result", ".", "position", ":=", "target", ".", "after", ";"]
  | .stateTarget => ["result", ".", "target", ":=", "target", ".", "target", ";"]
  | .output => ["result", ".", "output", ":=", "true", ";"]
  | .assigned => ["result", ".", "assigned", ":=", "true", ";"]
  | .rejected => ["result", ".", "facts", ".", "path", ":=", "paths", "."] ++ call "rejected" [["result", ".", "facts", ".", "path"]] ++ [";"]

inductive Command
  | nothing | update (value : Update) | expression | character | indexed | target | returnInvalid | returnResult
  | sequence (first second : Command) | choose (test : Test) (yes no : Command)

/-- Continuation interpretation of the finite imperative block; return bypasses the continuation. -/
def Command.eval (primitive : Primitives) (frame : Frame) (next : Frame → BodyScan) : Command → BodyScan
  | .nothing => next frame
  | .update value => next {frame with result := value.eval primitive frame}
  | .expression => next {frame with value := primitive.expression frame.text frame.context frame.result.position frame.result.facts}
  | .character => next {frame with
      characterValue := primitive.character frame.text frame.result.position
        frame.context.names (primitive.readingNames frame.context frame.result.facts) frame.context.arrayNames}
  | .indexed => next {frame with
      characterValue := primitive.indexed frame.text frame.scan.position
        frame.context.names (primitive.readingNames frame.context frame.result.facts)
        frame.context.arrayNames [] false true}
  | .target => next {frame with target := primitive.target frame.text frame.context frame.result.position}
  | .returnInvalid => primitive.invalid frame.scan
  | .returnResult => frame.result
  | .sequence first second => first.eval primitive frame (fun updated => second.eval primitive updated next)
  | .choose test yes no => if test.eval primitive frame then yes.eval primitive frame next else no.eval primitive frame next

mutual
  def Command.render : Command → List String
    | .nothing => [] | .update value => value.render
    | .expression => ["value", ":="] ++ call "read_string_in_flow" [["text"], ["context"], ["result", ".", "position"], ["result", ".", "facts"]] ++ [";"]
    | .character => ["character_value", ":="] ++ call "character_at"
        [["text"], ["result", ".", "position"], ["context", ".", "names"],
          call "reading_names" [["context"], ["result", ".", "facts"]], ["context", ".", "array_names"]] ++ [";"]
    | .indexed => ["character_value", ":="] ++ call "indexed_at"
        [["text"], ["scan", ".", "position"], ["context", ".", "names"],
          call "reading_names" [["context"], ["result", ".", "facts"]], ["context", ".", "array_names"],
          ["array_bindings", ".", "empty_values"], ["false"], ["true"]] ++ [";"]
    | .target => ["target", ":="] ++ call "body_string_target"
        [["text"], ["context"], ["result", ".", "position"]] ++ [";"]
    | .returnInvalid => ["return", "invalid_body", "(", "scan", ")", ";"] | .returnResult => ["return", "result", ";"]
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
def characterCommands : Command := .list [
  .update (.token (.symbol ":=")), .character,
  guard .zeroCharacter, .update .characterAfter]
def elementCommands : Command := .list [
  .indexed, .update .characterAfter, characterCommands]
def wholeCommands : Command := .list [
  .update (.token (.symbol ":=")), .expression,
  guard (.orElse (.orElse .zeroValue .notFits) .notSameLength), .update .valueAfter]
def assignmentCommands : Command := .list [
  .target, .update .statePosition, .update .stateTarget,
  guard .zeroTarget,
  .choose .characterTarget characterCommands
    (.choose (.present (.symbol "(")) elementCommands wholeCommands),
  .update .assigned]
def dispatchCommands : Command :=
  .choose (.present (.word "null")) (.update (.token (.word "null")))
    (.choose (.operation .output) outputCommands
      (.choose (.operation .partialOutput) putCommands
        (.choose (.andThen .hasArguments (.operation .reject)) rejectCommands
          (.choose .scalarTarget (.update .scalarAssignment)
            (.choose .arrayTarget
              (.choose .booleanArrayTarget (.update .booleanArrayAssignment) (.update .arrayAssignment))
              (.choose .booleanTarget (.update .booleanAssignment) assignmentCommands))))))
def basicCommands : Command := .list [guard .zeroResult, dispatchCommands,
  .update (.token (.symbol ";")), guard .nonadvancing, .returnResult]

def basicRender : List String :=
  ["result", ":", "body_scan", "(", "scan", ".", "count", ")", ":=", "scan", ";", "value", ":", "expression_result", ";",
    "target", ":", "string_target_result", ";", "character_value", ":", "value_result", ";", "begin"] ++ basicCommands.render ++ ["end", "basic_body", ";"]

def basicEval (primitive : Primitives) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  basicCommands.eval primitive ⟨text, context, scan, scan, {}, {}, {}⟩ (fun _ => primitive.invalid scan)

def modelPrimitives : Primitives where
  callAfter := fun text names position operation scalarNames arrays hidden booleans => Compose.callAfter text names position operation scalarNames arrays hidden booleans
  associationAfter := Names.associationAfter
  token := tokenAfter
  expression := fun text context position facts => readStringInFlow text context.model position facts
  readingNames := fun context facts => context.model.readingNames facts
  character := fun text position names scalarNames arrays => characterAt text position names scalarNames arrays
  indexed := indexedAt
  target := ScalarBodyNative.stringTargetEval ScalarBodyNative.modelImports
  bodyToken := fun text _ scan token => Predicate.bodyToken text scan token
  invalid := invalidBody
  scalarTarget := fun text context position => Predicate.scalarTarget text context.model position
  scalarAssignment := fun text context scan => scalarAssignmentBody text context.model scan
  booleanTarget := fun text context position => Predicate.booleanTarget text context.model position
  booleanAssignment := fun text context scan => booleanAssignmentBody text context.model scan
  arrayTarget := fun text context position => Predicate.arrayTarget text context.model position
  arrayAssignment := fun text context scan => arrayAssignmentBody text context.model scan
  booleanArrayAssignment := fun text context scan => booleanArrayAssignmentBody text context.model scan
  fits := fitsLengthSummary
  sameLength := equalLengthIntervals
  reject := PathFacts.Context.reject

end Silver.Predicate.BasicNative

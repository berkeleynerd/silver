module

public import Silver.PredicateLoopProperties
public import Silver.PredicateNativeState

@[expose] public section

/-! The finite native Loop_Body block. Every command determines its source
rendering and state transition together; the recursive body reader remains
arbitrary. The lexical/scalar callees are interpreted imported operations. -/
namespace Silver.Predicate.LoopNative
open Compose

abbrev Reader := Source → Native.Context → BodyScan → BodyStop → BodyScan

/-- Imported operations retain their native call identities. The independent
model is one interpretation; source bridges supply the actual interpretation. -/
@[ext] structure Imports where
  token : Source → Nat → ShellToken → Nat
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  forbidden : Source → Nat → Nat → Bool
  nameIs : Source → Nat → Nat → String → Bool
  readScalar : Source → Nat → ScalarExpression.Environment → Nat → Nat → ScalarExpression.Result
  append : ScalarExpression.Environment → ScalarExpression.Binding → ScalarExpression.Environment
  isEmpty : Integer.Interval → Bool
  normalize : Integer.Interval → Integer.Interval
  join : PathFacts.Context → PathFacts.Context → PathFacts.Context
  emptyBounds : Integer.Interval
  emptyFacts : PathFacts.Context

def modelImports : Imports where
  token := tokenAfter
  skip := skipAt
  nameAfter := Compose.nameAfter
  forbidden := Named.forbiddenName
  nameIs := fun text first after word => Named.nameIs text first after (word.toList.map Char.toNat)
  readScalar := fun text position names first after => ScalarExpression.read text position names first after
  append := fun names item => names ++ [item]
  isEmpty := Integer.Interval.isEmpty
  normalize := Integer.Interval.normalize
  join := PathFacts.Context.join
  emptyBounds := Integer.Interval.empty
  emptyFacts := PathFacts.Context.empty

structure Frame where
  text : Source
  context : Native.Context
  scan : BodyScan
  result : BodyScan
  first : Nat
  after : Nat
  inner : Native.Context
  low : ScalarExpression.Result := ScalarExpression.invalid
  high : ScalarExpression.Result := ScalarExpression.invalid
  bounds : Integer.Interval := Integer.Interval.empty
  definite : Bool := false

inductive Test
  | invalidName | reverse | nonadvancing | empty | indefinite
  deriving DecidableEq

def Test.eval (frame : Frame) : Test → Bool
  | .invalidName => decide (frame.first = 0 ∨ frame.after ≤ frame.first) ||
      (Named.forbiddenName frame.text frame.first frame.after &&
        !Named.nameIs frame.text frame.first frame.after ("string".toList.map Char.toNat)) ||
      (decide (frame.context.dynamicFirst ≠ 0) &&
        Named.nameIs frame.text frame.first frame.after ("silver_arguments".toList.map Char.toNat)) ||
      decide (frame.context.scalarNames.length = ScalarExpression.maxBindings)
  | .reverse => decide (fixedAfter frame.text frame.result.position "reverse" true ≠ 0)
  | .nonadvancing => decide (frame.result.position ≤ frame.scan.position)
  | .empty => frame.bounds.isEmpty
  | .indefinite => !frame.definite

def Test.evalWith (imports : Imports) (frame : Frame) : Test → Bool
  | .invalidName => decide (frame.first = 0 ∨ frame.after ≤ frame.first) ||
      (imports.forbidden frame.text frame.first frame.after &&
        !imports.nameIs frame.text frame.first frame.after "string") ||
      (decide (frame.context.dynamicFirst ≠ 0) &&
        imports.nameIs frame.text frame.first frame.after "silver_arguments") ||
      decide (frame.context.scalarNames.length = ScalarExpression.maxBindings)
  | .reverse => decide (imports.token frame.text frame.result.position (.word "reverse") ≠ 0)
  | .nonadvancing => decide (frame.result.position ≤ frame.scan.position)
  | .empty => imports.isEmpty frame.bounds
  | .indefinite => !frame.definite

@[simp] theorem Test.evalWith_model (frame : Frame) (test : Test) :
    test.evalWith modelImports frame = test.eval frame := by cases test <;> rfl

def call := Compose.Expressions.call

def Test.render : Test → List String
  | .invalidName => ["first", "=", "0", "or", "else", "after", "<=", "first", "or", "else", "("] ++
      call "forbidden_name" [["text"], ["first"], ["after"]] ++ ["and", "then", "not"] ++
      call "name_is" [["text"], ["first"], ["after"], ["\"string\""]] ++ [")", "or", "else", "(",
      "context", ".", "dynamic_first", "/=", "0", "and", "then"] ++
      call "name_is" [["text"], ["first"], ["after"], ["\"silver_arguments\""]] ++ [")", "or", "else",
      "context", ".", "scalar_names", ".", "count", "=", "scalar_expressions", ".", "max_bindings"]
  | .reverse => call "take_token" [["text"], ["result", ".", "position"], ["reverse_keyword"]] ++ ["/=", "0"]
  | .nonadvancing => ["result", ".", "position", "<=", "scan", ".", "position"]
  | .empty => ["scalars", "."] ++ call "is_empty" [["index_bounds"]]
  | .indefinite => ["not", "definite"]

inductive Update
  | inside | reverse | low | delimiter | high | opening | bounds | definite | inner
  | emptyFacts | restoreFacts | joinFacts | readBody | token (value : ShellToken)
  deriving DecidableEq

def Update.eval (read : Reader) (frame : Frame) : Update → Frame
  | .inside => {frame with result := {frame.result with position := fixedAfter frame.text frame.after "in" true}}
  | .reverse => {frame with result := bodyToken frame.text frame.result (.word "reverse")}
  | .low => {frame with low := ScalarExpression.read frame.text frame.result.position frame.context.scalarNames frame.first frame.after}
  | .delimiter => {frame with result := {frame.result with position := fixedAfter frame.text frame.low.after ".." false}}
  | .high => {frame with high := ScalarExpression.read frame.text frame.result.position frame.context.scalarNames frame.first frame.after}
  | .opening => {frame with result := {frame.result with position := fixedAfter frame.text frame.high.after "loop" true}}
  | .bounds => {frame with bounds := Integer.loopBounds frame.low.bounds frame.high.bounds}
  | .definite => {frame with definite := Integer.loopDefinite frame.low.bounds frame.high.bounds}
  | .inner => {frame with inner := {frame.inner with scalarNames := frame.context.scalarNames ++
      [⟨frame.first, frame.after, frame.bounds, false, frame.bounds, false⟩]}}
  | .emptyFacts => {frame with result := {frame.result with facts := PathFacts.Context.empty}}
  | .restoreFacts => {frame with result := {frame.result with facts := frame.scan.facts}}
  | .joinFacts => {frame with result := {frame.result with facts := frame.scan.facts.join frame.result.facts}}
  | .readBody => {frame with result := read frame.text frame.inner frame.result .endOnly}
  | .token value => {frame with result := bodyToken frame.text frame.result value}

def Update.evalWith (imports : Imports) (read : Reader) (frame : Frame) : Update → Frame
  | .inside => {frame with result := {frame.result with position := imports.token frame.text frame.after (.word "in")}}
  | .reverse => {frame with result := {frame.result with position := imports.token frame.text frame.result.position (.word "reverse")}}
  | .low => {frame with low := imports.readScalar frame.text frame.result.position frame.context.scalarNames frame.first frame.after}
  | .delimiter => {frame with result := {frame.result with position := imports.token frame.text frame.low.after (.symbol "..")}}
  | .high => {frame with high := imports.readScalar frame.text frame.result.position frame.context.scalarNames frame.first frame.after}
  | .opening => {frame with result := {frame.result with position := imports.token frame.text frame.high.after (.word "loop")}}
  | .bounds => {frame with bounds := if imports.isEmpty frame.low.bounds || imports.isEmpty frame.high.bounds
      then imports.emptyBounds else imports.normalize ⟨frame.low.bounds.lower, frame.high.bounds.upper⟩}
  | .definite => {frame with definite := (!imports.isEmpty frame.low.bounds && !imports.isEmpty frame.high.bounds &&
      decide (frame.low.bounds.upper ≤ frame.high.bounds.lower))}
  | .inner => {frame with inner := {frame.inner with scalarNames := (imports.append frame.context.scalarNames
      ⟨frame.first, frame.after, frame.bounds, false, frame.bounds, false⟩)}}
  | .emptyFacts => {frame with result := {frame.result with facts := imports.emptyFacts}}
  | .restoreFacts => {frame with result := {frame.result with facts := frame.scan.facts}}
  | .joinFacts => {frame with result := {frame.result with facts := imports.join frame.scan.facts frame.result.facts}}
  | .readBody => {frame with result := read frame.text frame.inner frame.result .endOnly}
  | .token value => {frame with result := {frame.result with position := imports.token frame.text frame.result.position value}}

@[simp] theorem Update.evalWith_model (read : Reader) (frame : Frame) (update : Update) :
    update.evalWith modelImports read frame = update.eval read frame := by cases update <;> rfl

def emptyBounds (side : String) : List String := ["scalars", "."] ++ call "is_empty" [[side, ".", "bounds"]]

def Update.render : Update → List String
  | .inside => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["after"], ["in_keyword"]] ++ [";"]
  | .reverse => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["result", ".", "position"], ["reverse_keyword"]] ++ [";"]
  | .low => ["low", ":=", "scalar_expressions", "."] ++ call "read_expression"
      [["text"], ["result", ".", "position"], ["context", ".", "scalar_names"], ["first"], ["after"]] ++ [";"]
  | .delimiter => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["low", ".", "after"], ["range_delimiter"]] ++ [";"]
  | .high => ["high", ":=", "scalar_expressions", "."] ++ call "read_expression"
      [["text"], ["result", ".", "position"], ["context", ".", "scalar_names"], ["first"], ["after"]] ++ [";"]
  | .opening => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["high", ".", "after"], ["loop_keyword"]] ++ [";"]
  | .bounds => ["index_bounds", ":=", "(", "if"] ++ emptyBounds "low" ++ ["or", "else"] ++ emptyBounds "high" ++
      ["then", "scalars", ".", "empty", "else", "scalars", "."] ++
      call "normalize" [["(", "low", ".", "bounds", ".", "lower", ",", "high", ".", "bounds", ".", "upper", ")"]] ++ [")", ";"]
  | .definite => ["definite", ":=", "not"] ++ emptyBounds "low" ++ ["and", "then", "not"] ++ emptyBounds "high" ++
      ["and", "then", "low", ".", "bounds", ".", "upper", "<=", "high", ".", "bounds", ".", "lower", ";"]
  | .inner => ["inner", ".", "scalar_names", ":=", "scalar_expressions", "."] ++
      call "append" [["context", ".", "scalar_names"], ["(", "first", ",", "after", ",", "index_bounds", ",", "false", ",", "index_bounds", ",", "false", ")"]] ++ [";"]
  | .emptyFacts => ["result", ".", "facts", ":=", "paths", ".", "empty_context", ";"]
  | .restoreFacts => ["result", ".", "facts", ":=", "scan", ".", "facts", ";"]
  | .joinFacts => ["result", ".", "facts", ":=", "paths", "."] ++ call "join" [["scan", ".", "facts"], ["result", ".", "facts"]] ++ [";"]
  | .readBody => ["result", ":="] ++ call "read_body" [["text"], ["inner"], ["result"], ["end_only"]] ++ [";"]
  | .token value => ["result", ":="] ++ call "body_token"
      [["text"], ["context"], ["result"], [Compose.Expressions.tokenName value]] ++ [";"]

inductive Command
  | nothing | update (value : Update) | invalid | result
  | sequence (first second : Command) | choose (test : Test) (yes no : Command)
  deriving DecidableEq

def Command.eval (read : Reader) (frame : Frame) (next : Frame → BodyScan) : Command → BodyScan
  | .nothing => next frame
  | .update value => next (value.eval read frame)
  | .invalid => invalidBody
  | .result => frame.result
  | .sequence first second => first.eval read frame (fun updated => second.eval read updated next)
  | .choose test yes no => if test.eval frame then yes.eval read frame next else no.eval read frame next

def Command.evalWith (imports : Imports) (read : Reader) (frame : Frame) (next : Frame → BodyScan) : Command → BodyScan
  | .nothing => next frame
  | .update value => next (value.evalWith imports read frame)
  | .invalid => invalidBody
  | .result => frame.result
  | .sequence first second => first.evalWith imports read frame
      (fun updated => second.evalWith imports read updated next)
  | .choose test yes no => if test.evalWith imports frame then yes.evalWith imports read frame next
      else no.evalWith imports read frame next

@[simp] theorem Command.evalWith_model (command : Command) (read : Reader) (frame : Frame)
    (next : Frame → BodyScan) :
    command.evalWith modelImports read frame next = command.eval read frame next := by
  induction command generalizing frame next with
  | sequence first second ihFirst ihSecond => simp only [evalWith, eval, ihFirst, ihSecond]
  | choose test yes no ihYes ihNo => simp only [evalWith, eval, Test.evalWith_model, ihYes, ihNo]
  | _ => simp only [evalWith, eval, Update.evalWith_model]

mutual
  def Command.render : Command → List String
    | .nothing => [] | .update value => value.render
    | .invalid => ["return", "invalid_body", ";"] | .result => ["return", "result", ";"]
    | .sequence first second => first.render ++ second.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
  def Command.renderElse : Command → List String
    | .nothing => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | value => ["else"] ++ value.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing
def guard (test : Test) : Command := .choose test .invalid .nothing

def commands : Command := .list [guard .invalidName, .update .inside,
  .choose .reverse (.update .reverse) .nothing, .update .low, .update .delimiter, .update .high,
  .update .opening, guard .nonadvancing, .update .bounds, .update .definite, .update .inner,
  .choose .empty (.update .emptyFacts) .nothing, .update .readBody, guard .nonadvancing,
  .choose .empty (.update .restoreFacts) (.choose .indefinite (.update .joinFacts) .nothing),
  .update (.token (.word "end")), .update (.token (.word "loop")), .update (.token (.symbol ";")),
  guard .nonadvancing, .result]

def initial (text : Source) (context : Native.Context) (scan : BodyScan) : Frame :=
  let result := bodyToken text scan (.word "for")
  let first := skipAt text result.position
  {text, context, scan, result, first, after := nameAfter text first, inner := context}

def eval (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  commands.eval read (initial text context scan) (fun _ => invalidBody)

def initialWith (imports : Imports) (text : Source) (context : Native.Context) (scan : BodyScan) : Frame :=
  let result := {scan with position := imports.token text scan.position (.word "for")}
  let first := imports.skip text result.position
  {text, context, scan, result, first, after := imports.nameAfter text first, inner := context}

def evalWith (imports : Imports) (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  commands.evalWith imports read (initialWith imports text context scan) (fun _ => invalidBody)

@[simp] theorem evalWith_model (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) :
    evalWith modelImports read text context scan = eval read text context scan := by
  simp only [evalWith, Command.evalWith_model]
  rfl

def render : List String :=
  ["result", ":", "body_scan", ":="] ++ call "body_token" [["text"], ["context"], ["scan"], ["for_keyword"]] ++
  [";", "first", ":", "constant", "literal_position", ":="] ++ call "skip_at" [["text"], ["result", ".", "position"]] ++
  [";", "after", ":", "constant", "literal_position", ":="] ++ call "name_after" [["text"], ["first"]] ++
  [";", "inner", ":", "body_context", ":=", "context", ";", "low", ",", "high", ":", "scalar_expressions", ".", "expression_result",
    ";", "index_bounds", ":", "scalars", ".", "interval", ";", "definite", ":", "boolean", ";", "begin"] ++
    commands.render ++ ["end", "loop_body", ";"]

def inner (context : Native.Context) (header : LoopHeader) : Native.Context :=
  {context with scalarNames := (loopInner context.model header).scalarNames}

@[simp] theorem inner_model (context : Native.Context) (header : LoopHeader) :
    (inner context header).model = loopInner context.model header := rfl

def equation (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  let header := loopHeader text context.model scan
  if !loopNameAllowed text context.model header then invalidBody
  else if header.entry.position ≤ scan.position then invalidBody else
    let body := read text (inner context header) header.entry .endOnly
    if body.position ≤ scan.position then invalidBody else
    let result := bodyTokens text
      {body with facts := loopAfter scan.facts body.facts header.lower.bounds header.upper.bounds}
      [.word "end", .word "loop", .symbol ";"]
    if result.position ≤ scan.position then invalidBody else result

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 3000000

attribute [local irreducible] ScalarExpression.read

theorem invalidName_allowed (text : Source) (context : Native.Context) (scan : BodyScan) :
    Test.invalidName.eval (initial text context scan) =
      !loopNameAllowed text context.model (loopHeader text context.model scan) := by
  apply Bool.eq_iff_iff.mpr
  dsimp +instances only [Test.eval, initial, loopNameAllowed, loopHeader, loopFirst, loopNameAfter,
    Native.Context.model, bodyToken, tokenAfter, ShellToken.word]
  cases hf : Named.forbiddenName text (skipAt text (fixedAfter text scan.position "for" true))
    (nameAfter text (skipAt text (fixedAfter text scan.position "for" true))) <;>
    simp_all [decide_eq_true_eq, decide_eq_false_iff_not] <;> omega

theorem eval_equation (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) :
    eval read text context scan = equation read text context scan := by
  simp only [eval, commands, Command.list, List.foldr_cons, List.foldr_nil,
    guard, Command.eval]
  rw [invalidName_allowed]
  unfold equation
  by_cases allowed : loopNameAllowed text context.model (loopHeader text context.model scan) = true
  · simp only [allowed, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
    by_cases reversed : fixedAfter text (loopInAfter text scan) "reverse" true ≠ 0
    all_goals dsimp +instances only [Update.eval, Test.eval, initial,
      loopHeader, loopFirst, loopNameAfter, loopInAfter, loopReverse, loopLowerPosition,
      loopContext, loopAfter, inner, loopInner, Native.Context.model,
      bodyToken, bodyTokens, List.foldl_cons, List.foldl_nil, tokenAfter, ShellToken.word, ShellToken.symbol]
    all_goals simp only [loopInAfter, loopNameAfter, loopFirst] at reversed
    all_goals generalize hf : skipAt text (fixedAfter text scan.position "for" true) = first at *
    all_goals generalize ha : nameAfter text first = after at *
    all_goals generalize hi : fixedAfter text after "in" true = inside at *
    all_goals generalize hr : fixedAfter text inside "reverse" true = rev at *
    all_goals simp +instances (config := {maxSteps := 500000}) [reversed]
    all_goals generalize hl : ScalarExpression.read text inside context.scalarNames first after = low at *
    all_goals generalize hlr : ScalarExpression.read text rev context.scalarNames first after = lowRev at *
    all_goals generalize hu : ScalarExpression.read text (fixedAfter text low.after ".." false) context.scalarNames first after = high at *
    all_goals generalize hur : ScalarExpression.read text (fixedAfter text lowRev.after ".." false) context.scalarNames first after = highRev at *
    all_goals repeat' first | rfl | (simp_all +instances; done) | split
  · have disallowed := Bool.eq_false_iff.mpr allowed
    simp only [disallowed, Bool.not_false, ↓reduceIte]

end Silver.Predicate.LoopNative

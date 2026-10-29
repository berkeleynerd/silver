module

public import Silver.PredicateLoopProperties
public import Silver.PredicateNativeState
public import Silver.PredicateFlowCopy

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
  bodyToken : Source → Native.Context → BodyScan → ShellToken → BodyScan
  invalid : BodyScan → BodyScan
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  forbidden : Source → Nat → Nat → Bool
  nameIs : Source → Nat → Nat → String → Bool
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  arrayTarget : Source → Native.Context → Nat → Nat
  readScalar : Source → Native.Context → Nat → ActiveFlow → Nat → Nat → ScalarExpression.Result
  widen : Native.Context → ActiveFlow → ActiveFlow
  append : ScalarExpression.Environment → ScalarExpression.Binding → ScalarExpression.Environment
  isEmpty : Integer.Interval → Bool
  normalize : Integer.Interval → Integer.Interval
  join : PathFacts.Context → PathFacts.Context → PathFacts.Context
  emptyBounds : Integer.Interval
  fullBounds : Integer.Interval
  emptyFacts : PathFacts.Context

def modelImports : Imports where
  token := tokenAfter
  bodyToken := fun text _ scan token => Predicate.bodyToken text scan token
  invalid := invalidBody
  skip := skipAt
  nameAfter := Compose.nameAfter
  forbidden := Named.forbiddenName
  nameIs := fun text first after word => Named.nameIs text first after (word.toList.map Char.toNat)
  equalName := Named.equalName
  arrayTarget := fun text context position => Predicate.arrayTarget text context.model position
  readScalar := fun text context position facts first after =>
    ScalarExpression.read text position (context.model.readingNames facts) first after (arrays := context.arrayNames)
  widen := fun context facts => ActiveFlow.widen context.scalarNames facts
  append := fun names item => names ++ [item]
  isEmpty := Integer.Interval.isEmpty
  normalize := Integer.Interval.normalize
  join := PathFacts.Context.join
  emptyBounds := Integer.Interval.empty
  fullBounds := Integer.Interval.full
  emptyFacts := PathFacts.Context.empty

structure Frame where
  text : Source
  context : Native.Context
  scan : BodyScan
  result : BodyScan
  first : Nat
  after : Nat
  inner : Native.Context
  innerScan : BodyScan
  low : ScalarExpression.Result := ScalarExpression.invalid
  high : ScalarExpression.Result := ScalarExpression.invalid
  bounds : Integer.Interval := Integer.Interval.empty
  definite : Bool := false
  arrayFirst : Nat := 0
  arrayAfter : Nat := 0
  arrayTarget : Nat := 0

inductive Test
  | invalidName | array | invalidArray | reverse | nonadvancing | innerNonadvancing | empty | definite
  deriving DecidableEq

def Test.eval (frame : Frame) : Test → Bool
  | .invalidName => decide (frame.first = 0 ∨ frame.after ≤ frame.first) ||
      (Named.forbiddenName frame.text frame.first frame.after &&
        !Named.nameIs frame.text frame.first frame.after ("string".toList.map Char.toNat)) ||
      (decide (frame.context.dynamicFirst ≠ 0) &&
        Named.nameIs frame.text frame.first frame.after ("silver_arguments".toList.map Char.toNat)) ||
      decide (frame.context.scalarNames.length = ScalarExpression.maxBindings)
  | .array => decide (fixedAfter frame.text frame.after "of" true ≠ 0)
  | .invalidArray => decide (frame.arrayFirst = 0 ∨ frame.arrayAfter ≤ frame.arrayFirst) ||
      Named.equalName frame.text frame.first frame.after frame.arrayFirst frame.arrayAfter ||
      decide (frame.arrayTarget = 0) || (ArrayBindings.binding frame.context.arrayNames frame.arrayTarget).mutable
  | .reverse => decide (fixedAfter frame.text frame.result.position "reverse" true ≠ 0)
  | .nonadvancing => decide (frame.result.position ≤ frame.scan.position)
  | .innerNonadvancing => decide (frame.innerScan.position ≤ frame.scan.position)
  | .empty => frame.bounds.isEmpty
  | .definite => frame.definite

def Test.evalWith (imports : Imports) (frame : Frame) : Test → Bool
  | .invalidName => decide (frame.first = 0 ∨ frame.after ≤ frame.first) ||
      (imports.forbidden frame.text frame.first frame.after &&
        !imports.nameIs frame.text frame.first frame.after "string") ||
      (decide (frame.context.dynamicFirst ≠ 0) &&
        imports.nameIs frame.text frame.first frame.after "silver_arguments") ||
      decide (frame.context.scalarNames.length = ScalarExpression.maxBindings)
  | .array => decide (imports.token frame.text frame.after (.word "of") ≠ 0)
  | .invalidArray => decide (frame.arrayFirst = 0 ∨ frame.arrayAfter ≤ frame.arrayFirst) ||
      imports.equalName frame.text frame.first frame.after frame.arrayFirst frame.arrayAfter ||
      decide (frame.arrayTarget = 0) || (ArrayBindings.binding frame.context.arrayNames frame.arrayTarget).mutable
  | .reverse => decide (imports.token frame.text frame.result.position (.word "reverse") ≠ 0)
  | .nonadvancing => decide (frame.result.position ≤ frame.scan.position)
  | .innerNonadvancing => decide (frame.innerScan.position ≤ frame.scan.position)
  | .empty => imports.isEmpty frame.bounds
  | .definite => frame.definite

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
  | .array => call "take_token" [["text"], ["after"], ["of_keyword"]] ++ ["/=", "0"]
  | .invalidArray => ["array_first", "=", "0", "or", "else", "array_after", "<=", "array_first", "or", "else"] ++
      call "equal_name" [["text"], ["first"], ["after"], ["array_first"], ["array_after"]] ++
      ["or", "else", "target", "=", "0", "or", "else", "context", ".", "array_names", ".", "items", "(", "target", ")", ".", "mutable"]
  | .reverse => call "take_token" [["text"], ["result", ".", "position"], ["reverse_keyword"]] ++ ["/=", "0"]
  | .nonadvancing => ["result", ".", "position", "<=", "scan", ".", "position"]
  | .innerNonadvancing => ["inner_scan", ".", "position", "<=", "scan", ".", "position"]
  | .empty => ["scalars", "."] ++ call "is_empty" [["index_bounds"]]
  | .definite => ["definite"]

/-- The five ordinary fields copied across the distinct scan discriminants. -/
inductive ScanField | position | target | capacity | assigned | output
  deriving DecidableEq

def ScanField.name : ScanField → String
  | .position => "position" | .target => "target" | .capacity => "capacity"
  | .assigned => "assigned" | .output => "output"

def ScanField.copy (source target : BodyScan) : ScanField → BodyScan
  | .position => {target with position := source.position}
  | .target => {target with target := source.target}
  | .capacity => {target with capacity := source.capacity}
  | .assigned => {target with assigned := source.assigned}
  | .output => {target with output := source.output}

/-- Increasing-index array assignment, represented on the remaining active
suffixes. Each step copies exactly the current source cell; no target suffix
cell is read until that index is reached. -/
def copyValuesInto : List Integer.Interval → List Integer.Interval → List Integer.Interval
  | [], target => target
  | _ :: _, [] => []
  | value :: rest, _ :: target => value :: copyValuesInto rest target

theorem copyValuesInto_prefix (values tail : List Integer.Interval) :
    copyValuesInto values (List.replicate values.length Integer.Interval.empty ++ tail) = values ++ tail := by
  induction values with
  | nil => rfl
  | cons head rest ih => simp only [List.length_cons, List.replicate_succ, List.cons_append, copyValuesInto, ih]

theorem copyValuesInto_count (values target : List Integer.Interval) :
    (copyValuesInto values target).length = target.length := by
  induction values generalizing target with
  | nil => rfl
  | cons head rest ih => cases target <;> simp only [copyValuesInto, List.length_cons, List.length_nil, ih]

theorem set_last (values : List Integer.Interval) (old value : Integer.Interval) :
    (values ++ [old]).set values.length value = values ++ [value] := by
  simp only [List.set_append_right (s := values) (t := [old]) values.length value (Nat.le_refl _),
    Nat.sub_self, List.set_cons_zero]

/-- The suffix interpreter is the existing one-based imperative copy loop,
including initialization of the extra slot and the final indexed assignment. -/
theorem copyValuesInto_imperative (flow : ActiveFlow) (bounds : Integer.Interval) :
    {flow with values :=
      (copyValuesInto flow.values (List.replicate (flow.count + 1) Integer.Interval.empty)).set flow.count bounds} =
      flow.copyAppend bounds := by
  rw [ActiveFlow.copyAppend_eq]
  simp only [ActiveFlow.count, List.replicate_succ', copyValuesInto_prefix, set_last, ActiveFlow.append]

def freshInnerScan (scan : BodyScan) : BodyScan :=
  ⟨0, 0, 0, ⟨PathFacts.Context.empty, List.replicate (scan.count + 1) Integer.Interval.empty⟩, false, false⟩

def enterScope (frame : Frame) : Frame :=
  {frame with inner := frame.context, innerScan := freshInnerScan frame.scan}

def enterArray (frame : Frame) : Frame :=
  let first := skipAt frame.text frame.result.position
  {frame with
    arrayFirst := first
    arrayAfter := nameAfter frame.text first
    arrayTarget := Predicate.arrayTarget frame.text frame.context.model frame.result.position}

def enterArrayWith (imports : Imports) (frame : Frame) : Frame :=
  let first := imports.skip frame.text frame.result.position
  {frame with
    arrayFirst := first
    arrayAfter := imports.nameAfter frame.text first
    arrayTarget := imports.arrayTarget frame.text frame.context frame.result.position}

inductive Update
  | inside | iterable | reverse | low | delimiter | high | opening | arrayOpening | bounds | arrayBounds | definite | arrayDefinite | widen | inner
  | copyToInner (field : ScanField) | copyFromInner (field : ScanField)
  | innerPath | clearInnerValues | copyInnerValues | indexValue
  | restoreFacts | bodyPath | joinFacts | readBody | token (value : ShellToken)
  deriving DecidableEq

/-- The fixed Static assertions attached to widen/indexValue in the rendering
have no executable state effects. Their exact tokens remain part of the source
check, and native verification must discharge their obligations; no constructor
accepts arbitrary ignored source. -/
def Update.eval (read : Reader) (frame : Frame) : Update → Frame
  | .inside => {frame with result := {frame.result with position := fixedAfter frame.text frame.after "in" true}}
  | .iterable => {frame with result := {frame.result with position := fixedAfter frame.text frame.after "of" true}}
  | .reverse => {frame with result := bodyToken frame.text frame.result (.word "reverse")}
  | .low => {frame with low := (ScalarExpression.read frame.text frame.result.position
      (frame.context.model.readingNames frame.scan.facts) frame.first frame.after (arrays := frame.context.arrayNames))}
  | .delimiter => {frame with result := {frame.result with position := fixedAfter frame.text frame.low.after ".." false}}
  | .high => {frame with high := (ScalarExpression.read frame.text frame.result.position
      (frame.context.model.readingNames frame.scan.facts) frame.first frame.after (arrays := frame.context.arrayNames))}
  | .opening => {frame with result := {frame.result with position := fixedAfter frame.text frame.high.after "loop" true}}
  | .arrayOpening => {frame with result := {frame.result with position := fixedAfter frame.text frame.arrayAfter "loop" true}}
  | .bounds => {frame with bounds := Integer.loopBounds frame.low.bounds frame.high.bounds}
  | .arrayBounds => {frame with bounds := Integer.Interval.full}
  | .definite => {frame with definite := Integer.loopDefinite frame.low.bounds frame.high.bounds}
  | .arrayDefinite => {frame with definite := true}
  | .widen => {frame with result := {frame.result with facts := ActiveFlow.widen frame.context.scalarNames frame.result.facts}}
  | .inner => {frame with inner := {frame.inner with scalarNames := frame.context.scalarNames ++
      [⟨frame.first, frame.after, frame.bounds, false, frame.bounds, false⟩]}}
  | .copyToInner field => {frame with innerScan := field.copy frame.result frame.innerScan}
  | .copyFromInner field => {frame with result := field.copy frame.innerScan frame.result}
  | .innerPath => {frame with innerScan := {frame.innerScan with facts := {frame.innerScan.facts with
      path := if frame.bounds.isEmpty then PathFacts.Context.empty else frame.result.facts.path}}}
  | .clearInnerValues => {frame with innerScan := {frame.innerScan with facts := {frame.innerScan.facts with
      values := List.replicate frame.innerScan.count Integer.Interval.empty}}}
  | .copyInnerValues => {frame with innerScan := {frame.innerScan with facts := {frame.innerScan.facts with
      values := copyValuesInto frame.result.facts.values frame.innerScan.facts.values}}}
  | .indexValue => {frame with innerScan := {frame.innerScan with facts := {frame.innerScan.facts with
      values := frame.innerScan.facts.values.set (frame.innerScan.count - 1) frame.bounds}}}
  | .restoreFacts => {frame with result := {frame.result with facts := frame.scan.facts}}
  | .bodyPath => {frame with result := {frame.result with facts := {frame.result.facts with path := frame.innerScan.facts.path}}}
  | .joinFacts => {frame with result := {frame.result with facts := {frame.result.facts with
      path := frame.scan.facts.path.join frame.innerScan.facts.path}}}
  | .readBody => {frame with innerScan := read frame.text frame.inner frame.innerScan .endOnly}
  | .token value => {frame with result := bodyToken frame.text frame.result value}

def Update.evalWith (imports : Imports) (read : Reader) (frame : Frame) : Update → Frame
  | .inside => {frame with result := {frame.result with position := imports.token frame.text frame.after (.word "in")}}
  | .iterable => {frame with result := {frame.result with position := imports.token frame.text frame.after (.word "of")}}
  | .reverse => {frame with result := {frame.result with position := imports.token frame.text frame.result.position (.word "reverse")}}
  | .low => {frame with low := imports.readScalar frame.text frame.context frame.result.position frame.scan.facts frame.first frame.after}
  | .delimiter => {frame with result := {frame.result with position := imports.token frame.text frame.low.after (.symbol "..")}}
  | .high => {frame with high := imports.readScalar frame.text frame.context frame.result.position frame.scan.facts frame.first frame.after}
  | .opening => {frame with result := {frame.result with position := imports.token frame.text frame.high.after (.word "loop")}}
  | .arrayOpening => {frame with result := {frame.result with position := imports.token frame.text frame.arrayAfter (.word "loop")}}
  | .bounds => {frame with bounds := if imports.isEmpty frame.low.bounds || imports.isEmpty frame.high.bounds
      then imports.emptyBounds else imports.normalize ⟨frame.low.bounds.lower, frame.high.bounds.upper⟩}
  | .arrayBounds => {frame with bounds := imports.fullBounds}
  | .definite => {frame with definite := (!imports.isEmpty frame.low.bounds && !imports.isEmpty frame.high.bounds &&
      decide (frame.low.bounds.upper ≤ frame.high.bounds.lower))}
  | .arrayDefinite => {frame with definite := true}
  | .widen => {frame with result := {frame.result with facts := imports.widen frame.context frame.result.facts}}
  | .inner => {frame with inner := {frame.inner with scalarNames := (imports.append frame.context.scalarNames
      ⟨frame.first, frame.after, frame.bounds, false, frame.bounds, false⟩)}}
  | .copyToInner field => {frame with innerScan := field.copy frame.result frame.innerScan}
  | .copyFromInner field => {frame with result := field.copy frame.innerScan frame.result}
  | .innerPath => {frame with innerScan := {frame.innerScan with facts := {frame.innerScan.facts with
      path := if imports.isEmpty frame.bounds then imports.emptyFacts else frame.result.facts.path}}}
  | .clearInnerValues => {frame with innerScan := {frame.innerScan with facts := {frame.innerScan.facts with
      values := List.replicate frame.innerScan.count imports.emptyBounds}}}
  | .copyInnerValues => {frame with innerScan := {frame.innerScan with facts := {frame.innerScan.facts with
      values := copyValuesInto frame.result.facts.values frame.innerScan.facts.values}}}
  | .indexValue => {frame with innerScan := {frame.innerScan with facts := {frame.innerScan.facts with
      values := frame.innerScan.facts.values.set (frame.innerScan.count - 1) frame.bounds}}}
  | .restoreFacts => {frame with result := {frame.result with facts := frame.scan.facts}}
  | .bodyPath => {frame with result := {frame.result with facts := {frame.result.facts with path := frame.innerScan.facts.path}}}
  | .joinFacts => {frame with result := {frame.result with facts := {frame.result.facts with
      path := imports.join frame.scan.facts.path frame.innerScan.facts.path}}}
  | .readBody => {frame with innerScan := read frame.text frame.inner frame.innerScan .endOnly}
  | .token value => {frame with result := imports.bodyToken frame.text frame.context frame.result value}

@[simp] theorem Update.evalWith_model (read : Reader) (frame : Frame) (update : Update) :
    update.evalWith modelImports read frame = update.eval read frame := by cases update <;> rfl

def emptyBounds (side : String) : List String := ["scalars", "."] ++ call "is_empty" [[side, ".", "bounds"]]

def Update.render : Update → List String
  | .inside => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["after"], ["in_keyword"]] ++ [";"]
  | .iterable => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["after"], ["of_keyword"]] ++ [";"]
  | .reverse => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["result", ".", "position"], ["reverse_keyword"]] ++ [";"]
  | .low => ["low", ":="] ++ call "read_scalar_in_flow"
      [["text"], ["context"], ["result", ".", "position"], ["scan", ".", "facts"], ["first"], ["after"]] ++ [";"]
  | .delimiter => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["low", ".", "after"], ["range_delimiter"]] ++ [";"]
  | .high => ["high", ":="] ++ call "read_scalar_in_flow"
      [["text"], ["context"], ["result", ".", "position"], ["scan", ".", "facts"], ["first"], ["after"]] ++ [";"]
  | .opening => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["high", ".", "after"], ["loop_keyword"]] ++ [";"]
  | .arrayOpening => ["result", ".", "position", ":="] ++ call "take_token" [["text"], ["array_after"], ["loop_keyword"]] ++ [";"]
  | .bounds => ["index_bounds", ":=", "(", "if"] ++ emptyBounds "low" ++ ["or", "else"] ++ emptyBounds "high" ++
      ["then", "scalars", ".", "empty", "else", "scalars", "."] ++
      call "normalize" [["(", "low", ".", "bounds", ".", "lower", ",", "high", ".", "bounds", ".", "upper", ")"]] ++ [")", ";"]
  | .arrayBounds => ["index_bounds", ":=", "scalars", ".", "full", ";"]
  | .definite => ["definite", ":=", "not"] ++ emptyBounds "low" ++ ["and", "then", "not"] ++ emptyBounds "high" ++
      ["and", "then", "low", ".", "bounds", ".", "upper", "<=", "high", ".", "bounds", ".", "lower", ";"]
  | .arrayDefinite => ["definite", ":=", "true", ";"]
  | .widen => call "widen_into" [["context"], ["result", ".", "facts"]] ++ [";"] ++
      ["pragma", "assert", "(", "static", "=>"] ++
      call "valid_flow" [["context"], ["result", ".", "facts"]] ++ [")", ";"]
  | .inner => ["inner", ".", "scalar_names", ":=", "scalar_expressions", "."] ++
      call "append" [["context", ".", "scalar_names"], ["(", "first", ",", "after", ",", "index_bounds", ",", "false", ",", "index_bounds", ",", "false", ")"]] ++ [";"]
  | .copyToInner field => ["inner_scan", ".", field.name, ":=", "result", ".", field.name, ";"]
  | .copyFromInner field => ["result", ".", field.name, ":=", "inner_scan", ".", field.name, ";"]
  | .innerPath => ["inner_scan", ".", "facts", ".", "path", ":=", "(", "if", "scalars", "."] ++
      call "is_empty" [["index_bounds"]] ++ ["then", "paths", ".", "empty_context", "else",
        "result", ".", "facts", ".", "path", ")", ";"]
  | .clearInnerValues => ["inner_scan", ".", "facts", ".", "values", ":=", "(", "others", "=>", "scalars", ".", "empty", ")", ";"]
  | .copyInnerValues =>
      ["for", "index", "in", "result", ".", "facts", ".", "values", "'", "range", "loop",
       "pragma", "loop_invariant", "(", "static", "=>", "(", "for", "all", "done", "in",
       "result", ".", "facts", ".", "values", "'", "first", "..", "index", "-", "1", "=>",
       "inner_scan", ".", "facts", ".", "values", "(", "done", ")", "=", "result", ".", "facts", ".", "values", "(", "done", ")", ")", ")", ";",
       "inner_scan", ".", "facts", ".", "values", "(", "index", ")", ":=", "result", ".", "facts", ".", "values", "(", "index", ")", ";", "end", "loop", ";"]
  | .indexValue =>
      ["pragma", "assert", "(", "static", "=>", "(", "for", "all", "index", "in",
       "result", ".", "facts", ".", "values", "'", "range", "=>",
       "inner_scan", ".", "facts", ".", "values", "(", "index", ")", "=",
       "result", ".", "facts", ".", "values", "(", "index", ")", ")", ")", ";",
       "pragma", "assert", "(", "static", "=>", "(", "for", "all", "index", "in", "1", "..",
       "context", ".", "scalar_names", ".", "count", "=>",
       "inner", ".", "scalar_names", ".", "items", "(", "index", ")", "=",
       "context", ".", "scalar_names", ".", "items", "(", "index", ")", ")", ")", ";",
       "pragma", "assert", "(", "static", "=>",
       "inner", ".", "declaration_count", "=", "context", ".", "declaration_count", ")", ";",
       "inner_scan", ".", "facts", ".", "values", "(", "inner_scan", ".", "count", ")", ":=", "index_bounds", ";",
       "pragma", "assert", "(", "static", "=>", "not",
       "inner", ".", "scalar_names", ".", "items", "(", "inner_scan", ".", "count", ")", ".", "mutable", ")", ";",
       "pragma", "assert", "(", "static", "=>",
       "inner_scan", ".", "count", ">", "inner", ".", "declaration_count", ")", ";",
       "pragma", "assert", "(", "static", "=>", "included", "(",
       "inner_scan", ".", "facts", ".", "values", "(", "inner_scan", ".", "count", ")", ",",
       "inner", ".", "scalar_names", ".", "items", "(", "inner_scan", ".", "count", ")", ".", "bounds", ")", ")", ";",
       "pragma", "assert", "(", "static", "=>"] ++
      call "valid_flow" [["inner"], ["inner_scan", ".", "facts"]] ++ [")", ";"]
  | .restoreFacts => ["result", ".", "facts", ":=", "scan", ".", "facts", ";"]
  | .bodyPath => ["result", ".", "facts", ".", "path", ":=", "inner_scan", ".", "facts", ".", "path", ";"]
  | .joinFacts => ["result", ".", "facts", ".", "path", ":=", "paths", "."] ++
      call "join" [["scan", ".", "facts", ".", "path"], ["inner_scan", ".", "facts", ".", "path"]] ++ [";"]
  | .readBody => ["inner_scan", ":="] ++ call "read_body" [["text"], ["inner"], ["inner_scan"], ["end_only"]] ++ [";"]
  | .token value => ["result", ":="] ++ call "body_token"
      [["text"], ["context"], ["result"], [Compose.Expressions.tokenName value]] ++ [";"]

inductive Command
  | nothing | update (value : Update) | invalid | result
  | scope (body : Command)
  | arrayScope (body : Command)
  | sequence (first second : Command) | choose (test : Test) (yes no : Command)
  deriving DecidableEq

def Command.eval (read : Reader) (frame : Frame) (next : Frame → BodyScan) : Command → BodyScan
  | .nothing => next frame
  | .update value => next (value.eval read frame)
  | .invalid => invalidBody frame.scan
  | .result => frame.result
  | .scope body => body.eval read (enterScope frame) next
  | .arrayScope body => body.eval read (enterArray frame) next
  | .sequence first second => first.eval read frame (fun updated => second.eval read updated next)
  | .choose test yes no => if test.eval frame then yes.eval read frame next else no.eval read frame next

def Command.evalWith (imports : Imports) (read : Reader) (frame : Frame) (next : Frame → BodyScan) : Command → BodyScan
  | .nothing => next frame
  | .update value => next (value.evalWith imports read frame)
  | .invalid => imports.invalid frame.scan
  | .result => frame.result
  | .scope body => body.evalWith imports read (enterScope frame) next
  | .arrayScope body => body.evalWith imports read (enterArrayWith imports frame) next
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
  | scope body ih => exact ih (enterScope frame) next
  | arrayScope body ih => exact ih (enterArray frame) next
  | invalid => rfl
  | _ => simp only [evalWith, eval, Update.evalWith_model]

mutual
  def Command.render : Command → List String
    | .nothing => [] | .update value => value.render
    | .invalid => ["return", "invalid_body", "(", "scan", ")", ";"] | .result => ["return", "result", ";"]
    | .scope body => ["declare", "inner", ":", "body_context", ":=", "context", ";",
        "inner_scan", ":", "body_scan", "(", "scan", ".", "count", "+", "1", ")", ";", "begin"] ++ body.render ++ ["end", ";"]
    | .arrayScope body => ["declare", "array_first", ":", "constant", "literal_position", ":="] ++
        call "skip_at" [["text"], ["result", ".", "position"]] ++
        [";", "array_after", ":", "constant", "literal_position", ":="] ++ call "name_after" [["text"], ["array_first"]] ++
        [";", "target", ":", "constant", "array_bindings", ".", "binding_count", ":="] ++
        call "array_target" [["text"], ["context"], ["result", ".", "position"]] ++ [";", "begin"] ++ body.render ++ ["end", ";"]
    | .sequence first second => first.render ++ second.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
  def Command.renderElse : Command → List String
    | .nothing => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | value => ["else"] ++ value.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing
def guard (test : Test) : Command := .choose test .invalid .nothing

def commands : Command := .list [guard .invalidName,
  .choose .array
    (.list [.update .iterable, .choose .reverse (.update .reverse) .nothing,
      .arrayScope (.list [guard .invalidArray, .update .arrayOpening]),
      .update .arrayBounds, .update .arrayDefinite])
    (.list [.update .inside, .choose .reverse (.update .reverse) .nothing,
      .update .low, .update .delimiter, .update .high, .update .opening,
      .update .bounds, .update .definite]),
  guard .nonadvancing, .update .widen,
  .scope (.list [.update .inner,
    .update (.copyToInner .position), .update (.copyToInner .target), .update (.copyToInner .capacity),
    .update (.copyToInner .assigned), .update (.copyToInner .output),
    .update .innerPath, .update .clearInnerValues, .update .copyInnerValues, .update .indexValue,
    .update .readBody, guard .innerNonadvancing,
    .update (.copyFromInner .position), .update (.copyFromInner .target), .update (.copyFromInner .capacity),
    .update (.copyFromInner .assigned), .update (.copyFromInner .output),
    .choose .empty (.update .restoreFacts) (.choose .definite (.update .bodyPath) (.update .joinFacts))]),
  .update (.token (.word "end")), .update (.token (.word "loop")), .update (.token (.symbol ";")),
  guard .nonadvancing, .result]

def initial (text : Source) (context : Native.Context) (scan : BodyScan) : Frame :=
  let result := bodyToken text scan (.word "for")
  let first := skipAt text result.position
  {text, context, scan, result, first, after := nameAfter text first, inner := context, innerScan := freshInnerScan scan}

def eval (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  commands.eval read (initial text context scan) (fun _ => invalidBody scan)

def initialWith (imports : Imports) (text : Source) (context : Native.Context) (scan : BodyScan) : Frame :=
  let result := imports.bodyToken text context scan (.word "for")
  let first := imports.skip text result.position
  {text, context, scan, result, first, after := imports.nameAfter text first, inner := context, innerScan := freshInnerScan scan}

def evalWith (imports : Imports) (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  commands.evalWith imports read (initialWith imports text context scan) (fun _ => imports.invalid scan)

@[simp] theorem evalWith_model (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) :
    evalWith modelImports read text context scan = eval read text context scan := by
  simp only [evalWith, Command.evalWith_model]
  rfl

def render : List String :=
  ["result", ":", "body_scan", "(", "scan", ".", "count", ")", ":="] ++ call "body_token" [["text"], ["context"], ["scan"], ["for_keyword"]] ++
  [";", "first", ":", "constant", "literal_position", ":="] ++ call "skip_at" [["text"], ["result", ".", "position"]] ++
  [";", "after", ":", "constant", "literal_position", ":="] ++ call "name_after" [["text"], ["first"]] ++
  [";", "low", ",", "high", ":", "scalar_expressions", ".", "expression_result",
    ";", "index_bounds", ":", "scalars", ".", "interval", ";", "definite", ":", "boolean", ";", "begin"] ++
    commands.render ++ ["end", "loop_body", ";"]

def inner (context : Native.Context) (header : LoopHeader) : Native.Context :=
  {context with scalarNames := (loopInner context.model header).scalarNames}

@[simp] theorem inner_model (context : Native.Context) (header : LoopHeader) :
    (inner context header).model = loopInner context.model header := rfl

def equation (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  let header := loopHeader text context.model scan
  if !loopNameAllowed text context.model header then invalidBody scan
  else if header.entry.position ≤ scan.position then invalidBody scan else
    let body := read text (inner context header) header.entry .endOnly
    if body.position ≤ scan.position then invalidBody scan else
    let result := bodyTokens text
      {body with facts := loopAfterHeader context.model scan.facts body.facts header}
      [.word "end", .word "loop", .symbol ";"]
    if result.position ≤ scan.position then invalidBody scan else result

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

private def tailCommands : Command := .list [
  guard .nonadvancing, .update .widen,
  .scope (.list [.update .inner,
    .update (.copyToInner .position), .update (.copyToInner .target), .update (.copyToInner .capacity),
    .update (.copyToInner .assigned), .update (.copyToInner .output),
    .update .innerPath, .update .clearInnerValues, .update .copyInnerValues, .update .indexValue,
    .update .readBody, guard .innerNonadvancing,
    .update (.copyFromInner .position), .update (.copyFromInner .target), .update (.copyFromInner .capacity),
    .update (.copyFromInner .assigned), .update (.copyFromInner .output),
    .choose .empty (.update .restoreFacts) (.choose .definite (.update .bodyPath) (.update .joinFacts))]),
  .update (.token (.word "end")), .update (.token (.word "loop")), .update (.token (.symbol ";")),
  guard .nonadvancing, .result]

private def tailEquation (read : Reader) (frame : Frame) : BodyScan :=
  if frame.result.position ≤ frame.scan.position then invalidBody frame.scan else
  let inner := {frame.context with scalarNames := frame.context.scalarNames ++
    [⟨frame.first, frame.after, frame.bounds, false, frame.bounds, false⟩]}
  let widened := ActiveFlow.widen frame.context.scalarNames frame.scan.facts
  let entry := {frame.result with facts := {widened.append frame.bounds with
    path := loopContext frame.scan.facts.path frame.bounds}}
  let body := read frame.text inner entry .endOnly
  if body.position ≤ frame.scan.position then invalidBody frame.scan else
  let facts := if frame.bounds.isEmpty then frame.scan.facts else
    ⟨if frame.definite then body.facts.path else frame.scan.facts.path.join body.facts.path,
      widened.values⟩
  let result := bodyTokens frame.text {body with facts := facts}
    [.word "end", .word "loop", .symbol ";"]
  if result.position ≤ frame.scan.position then invalidBody frame.scan else result

private theorem tail_eval (read : Reader) (frame : Frame) (next : Frame → BodyScan)
    (facts : frame.result.facts = frame.scan.facts)
    (count : frame.scan.facts.count = frame.context.scalarNames.length) :
    tailCommands.eval read frame next = tailEquation read frame := by
  have widenedCount : (ActiveFlow.widen frame.context.scalarNames frame.scan.facts).values.length = frame.scan.count :=
    ActiveFlow.widen_count frame.context.scalarNames frame.scan.facts count
  have copied : copyValuesInto (ActiveFlow.widen frame.context.scalarNames frame.scan.facts).values
      (List.replicate (frame.scan.count + 1) Integer.Interval.empty) =
      (ActiveFlow.widen frame.context.scalarNames frame.scan.facts).values ++ [Integer.Interval.empty] := by
    rw [← widenedCount, List.replicate_succ', copyValuesInto_prefix]
  simp only [tailCommands, Command.list, List.foldr_cons, List.foldr_nil, guard, Command.eval]
  dsimp only [Update.eval, Test.eval, enterScope, freshInnerScan, ScanField.copy]
  simp only [facts, BodyScan.count, ActiveFlow.count] at copied widenedCount ⊢
  simp only [List.length_replicate, copyValuesInto_count, Nat.add_sub_cancel]
  rw [copied]
  rw [← widenedCount, set_last]
  simp only [ActiveFlow.widen_path, decide_eq_true_eq]
  unfold tailEquation
  simp only [ActiveFlow.append, loopContext, ActiveFlow.widen_path, bodyTokens, List.foldl_cons,
    List.foldl_nil, bodyToken]
  repeat' first | rfl | (simp_all +instances; done) | split

private def arrayCommands : Command := .list [
  .update .iterable, .choose .reverse (.update .reverse) .nothing,
  .arrayScope (.list [guard .invalidArray, .update .arrayOpening]),
  .update .arrayBounds, .update .arrayDefinite]

private def countedCommands : Command := .list [
  .update .inside, .choose .reverse (.update .reverse) .nothing,
  .update .low, .update .delimiter, .update .high, .update .opening,
  .update .bounds, .update .definite]

private def arrayFrame (text : Source) (context : Native.Context) (scan : BodyScan) : Frame :=
  {initial text context scan with
    result := {scan with position := (loopHeader text context.model scan).entry.position}
    bounds := Integer.Interval.full
    definite := true
    arrayFirst := skipAt text (loopLowerPosition text scan)
    arrayAfter := nameAfter text (skipAt text (loopLowerPosition text scan))
    arrayTarget := loopArrayTarget text context.model scan}

private def countedFrame (text : Source) (context : Native.Context) (scan : BodyScan) : Frame :=
  let header := loopHeader text context.model scan
  {initial text context scan with
    result := {scan with position := header.entry.position}
    low := header.lower
    high := header.upper
    bounds := header.bounds
    definite := Integer.loopDefinite header.lower.bounds header.upper.bounds}

private theorem invalid_array_guard (first after target : Nat) (equal mutable : Bool) :
    (decide (first = 0 ∨ after ≤ first) || equal || decide (target = 0) || mutable) =
      !(decide (first ≠ 0 ∧ first < after ∧ target ≠ 0) && !mutable && !equal) := by
  apply Bool.eq_iff_iff.mpr
  cases equal <;> cases mutable <;>
    simp [Bool.or_eq_true, decide_eq_true_eq, decide_eq_false_iff_not] <;> omega

private def iteratorFrame (text : Source) (context : Native.Context) (scan : BodyScan) : Frame :=
  {initial text context scan with result := {scan with position := loopLowerPosition text scan}}

private def reverseFrame (frame : Frame) : Frame :=
  let position := if fixedAfter frame.text frame.result.position "reverse" true ≠ 0 then
    fixedAfter frame.text frame.result.position "reverse" true else frame.result.position
  {frame with result := {frame.result with position := position}}

private theorem reverse_eval (read : Reader) (frame : Frame) (next : Frame → BodyScan) :
    (Command.choose .reverse (.update .reverse) .nothing).eval read frame next =
      next (reverseFrame frame) := by
  simp only [Command.eval, Test.eval, Update.eval, bodyToken, tokenAfter, ShellToken.word,
    reverseFrame, decide_eq_true_eq]
  split <;> rfl

private theorem iterator_invalid (text : Source) (context : Native.Context) (scan : BodyScan) :
    Test.invalidArray.eval (enterArray (iteratorFrame text context scan)) =
      !loopArrayAllowed text context.model scan := by
  exact invalid_array_guard (skipAt text (loopLowerPosition text scan))
    (nameAfter text (skipAt text (loopLowerPosition text scan))) (loopArrayTarget text context.model scan)
    (Named.equalName text (loopFirst text scan) (loopNameAfter text scan)
      (skipAt text (loopLowerPosition text scan)) (nameAfter text (skipAt text (loopLowerPosition text scan))))
    (ArrayBindings.binding context.arrayNames (loopArrayTarget text context.model scan)).mutable

private theorem array_eval (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan)
    (next : Frame → BodyScan) (iterable : loopIsArray text scan = true) :
    arrayCommands.eval read (initial text context scan) next =
      if loopArrayAllowed text context.model scan then next (arrayFrame text context scan)
      else invalidBody scan := by
  change (Command.choose .reverse (.update .reverse) .nothing).eval read
    (Update.iterable.eval read (initial text context scan))
    (fun frame => (Command.arrayScope (.list [guard .invalidArray, .update .arrayOpening])).eval read frame
      (fun frame => next (Update.arrayDefinite.eval read (Update.arrayBounds.eval read frame)))) = _
  rw [reverse_eval]
  have cursor : reverseFrame (Update.iterable.eval read (initial text context scan)) =
      iteratorFrame text context scan := by
    simp only [reverseFrame, iteratorFrame, loopLowerPosition, loopReverse, loopInAfter,
      iterable, ↓reduceIte, decide_eq_true_eq]
    rfl
  rw [cursor]
  simp only [Command.eval, Command.list, List.foldr_cons, List.foldr_nil, guard]
  rw [iterator_invalid]
  cases permitted : loopArrayAllowed text context.model scan with
  | false => simp only [Bool.not_false, Bool.false_eq_true, ↓reduceIte]; rfl
  | true =>
      simp only [Bool.not_true, Bool.false_eq_true, ↓reduceIte]
      congr 1
      simp only [Update.eval, enterArray, iteratorFrame, arrayFrame, loopHeader, iterable, permitted, ↓reduceIte]
      rfl

private theorem counted_eval (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan)
    (next : Frame → BodyScan) (counted : loopIsArray text scan = false) :
    countedCommands.eval read (initial text context scan) next = next (countedFrame text context scan) := by
  simp only [countedCommands, Command.list, List.foldr_cons, List.foldr_nil, Command.eval]
  dsimp only [Update.eval, Test.eval, initial]
  unfold countedFrame
  simp only [loopHeader, LoopHeader.bounds, counted, Bool.false_eq_true, ↓reduceIte, loopInAfter,
    loopLowerPosition, loopReverse, loopNameAfter, loopFirst, initial, bodyToken, tokenAfter, ShellToken.word]
  by_cases reverse : fixedAfter text (fixedAfter text (nameAfter text
      (skipAt text (fixedAfter text scan.position "for" true))) "in" true) "reverse" true ≠ 0
  all_goals try simp_all +instances
  all_goals rfl

private def headerFrame (text : Source) (context : Native.Context) (scan : BodyScan) : Frame :=
  let header := loopHeader text context.model scan
  {initial text context scan with
    result := {scan with position := header.entry.position}
    bounds := header.bounds
    definite := if header.isArray then true else Integer.loopDefinite header.lower.bounds header.upper.bounds}

private def headerContinuation (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  let header := loopHeader text context.model scan
  if header.entry.position ≤ scan.position then invalidBody scan else
    let body := read text (inner context header) header.entry .endOnly
    if body.position ≤ scan.position then invalidBody scan else
    let result := bodyTokens text
      {body with facts := loopAfterHeader context.model scan.facts body.facts header}
      [.word "end", .word "loop", .symbol ";"]
    if result.position ≤ scan.position then invalidBody scan else result

private theorem header_exit (context : Native.Context) (before after : ActiveFlow) (header : LoopHeader) :
    (if header.bounds.isEmpty then before else
      ⟨if (if header.isArray then true else Integer.loopDefinite header.lower.bounds header.upper.bounds) then
        after.path else before.path.join after.path,
        (ActiveFlow.widen context.scalarNames before).values⟩) =
      loopAfterHeader context.model before after header := by
  have fullNonempty : Integer.Interval.full.isEmpty = false := by decide +kernel
  cases array : header.isArray with
  | true => simp only [LoopHeader.bounds, loopAfterHeader, array, ↓reduceIte, fullNonempty, Bool.false_eq_true]; rfl
  | false =>
      simp only [LoopHeader.bounds, loopAfterHeader, array, Bool.false_eq_true, ↓reduceIte,
        loopAfterFlow, loopAfter]
      split <;> rfl

private theorem header_tail (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan) :
    tailEquation read (headerFrame text context scan) = headerContinuation read text context scan := by
  unfold tailEquation headerFrame
  dsimp only [initial]
  rw [header_exit]
  rfl

private theorem array_tail (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan)
    (iterable : loopIsArray text scan = true) :
    tailEquation read (arrayFrame text context scan) = headerContinuation read text context scan := by
  rw [← header_tail]
  have selected : (loopHeader text context.model scan).isArray = true := iterable
  simp only [tailEquation, arrayFrame, headerFrame, LoopHeader.bounds, selected, ↓reduceIte]

private theorem counted_tail (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan)
    (counted : loopIsArray text scan = false) :
    tailEquation read (countedFrame text context scan) = headerContinuation read text context scan := by
  rw [← header_tail]
  have selected : (loopHeader text context.model scan).isArray = false := counted
  simp only [tailEquation, countedFrame, headerFrame, selected, Bool.false_eq_true, ↓reduceIte]
  rfl

private theorem commands_decompose :
    commands = .sequence (guard .invalidName)
      (.sequence (.choose .array arrayCommands countedCommands) tailCommands) := rfl

attribute [local irreducible] tailCommands arrayCommands countedCommands

theorem eval_equation (read : Reader) (text : Source) (context : Native.Context) (scan : BodyScan)
    (count : scan.facts.count = context.scalarNames.length) :
    eval read text context scan = equation read text context scan := by
  rw [eval, commands_decompose]
  change (guard .invalidName).eval read (initial text context scan)
    (fun frame => (Command.choose .array arrayCommands countedCommands).eval read frame
      (fun frame => tailCommands.eval read frame (fun _ => invalidBody scan))) =
    (if !loopNameAllowed text context.model (loopHeader text context.model scan) then invalidBody scan
     else headerContinuation read text context scan)
  simp only [guard, Command.eval, invalidName_allowed]
  by_cases allowed : loopNameAllowed text context.model (loopHeader text context.model scan) = true
  · simp only [allowed, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
    have arrayTest : Test.array.eval (initial text context scan) = loopIsArray text scan := rfl
    rw [arrayTest]
    by_cases iterable : loopIsArray text scan = true
    · simp only [iterable, ↓reduceIte]
      rw [array_eval read text context scan _ iterable]
      by_cases valid : loopArrayAllowed text context.model scan = true
      · simp only [valid, ↓reduceIte]
        rw [tail_eval read _ _ rfl count, array_tail read text context scan iterable]
      · simp only [valid, Bool.false_eq_true, ↓reduceIte]
        have zero : (loopHeader text context.model scan).entry.position = 0 := by
          simp only [loopHeader, iterable, ↓reduceIte, valid, Bool.false_eq_true]
        simp only [headerContinuation, zero, Nat.zero_le, ↓reduceIte]
    · have counted := Bool.eq_false_iff.mpr iterable
      simp only [counted, Bool.false_eq_true, ↓reduceIte]
      rw [counted_eval read text context scan _ counted]
      rw [tail_eval read _ _ rfl count, counted_tail read text context scan counted]
  · have disallowed := Bool.eq_false_iff.mpr allowed
    simp only [disallowed, Bool.not_false, ↓reduceIte]
    rfl


end Silver.Predicate.LoopNative

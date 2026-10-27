module

public import Silver.PredicateScalarBodyNative

@[expose] public section

/-! Typed source trees for indexed target lookup and assignment. Subscripts
retain the native scalar-only reader; assigned values use the array-aware flow
reader. An indexed write preserves every scalar flow fact. -/
namespace Silver.Predicate.ArrayBodyNative
open Compose

@[ext] structure Imports where
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  scalarLookup : Source → ScalarExpression.Environment → Nat → Nat → Nat
  arrayLookup : Source → ArrayBindings.Metadata → Nat → Nat → Nat
  token : Source → Nat → ShellToken → Nat
  readIndex : Source → Native.Context → Nat → ActiveFlow → ScalarExpression.Result
  readValue : Source → Native.Context → Nat → ActiveFlow → ScalarExpression.Result
  contains : ArrayBindings.Binding → Integer.Interval → Bool
  isEmpty : Integer.Interval → Bool
  invalid : BodyScan → BodyScan

def modelImports : Imports where
  skip := skipAt
  nameAfter := Compose.nameAfter
  scalarLookup := ScalarExpression.lookup
  arrayLookup := ArrayBindings.lookup
  token := tokenAfter
  readIndex := fun text context position facts =>
    ScalarExpression.read text position (context.model.readingNames facts)
  readValue := fun text context position facts =>
    ScalarExpression.read text position (context.model.readingNames facts) (arrays := context.arrayNames)
  contains := ArrayBindings.contains
  isEmpty := Integer.Interval.isEmpty
  invalid := invalidBody

abbrev TargetCall := Source → Native.Context → Nat → Nat

structure Frame where
  text : Source
  context : Native.Context
  position : Nat := 0
  scan : BodyScan := ⟨0, 0, 0, ⟨PathFacts.Context.empty, []⟩, false, false⟩
  first : Nat := 0
  after : Nat := 0
  target : Nat := 0
  subscript : ScalarExpression.Result := ScalarExpression.invalid
  value : ScalarExpression.Result := ScalarExpression.invalid

inductive Expr : Type → Type 1
  | inputPosition : Expr Nat
  | scanPosition : Expr Nat
  | localFirst : Expr Nat
  | localAfter : Expr Nat
  | localTarget : Expr Nat
  | zero : Expr Nat
  | maxOperands : Expr Nat
  | localSubscript : Expr ScalarExpression.Result
  | localValue : Expr ScalarExpression.Result
  | skip (position : Expr Nat) : Expr Nat
  | nameAfter (first : Expr Nat) : Expr Nat
  | scalarLookup (first after : Expr Nat) : Expr Nat
  | arrayLookup (first after : Expr Nat) : Expr Nat
  | arrayTarget (position : Expr Nat) : Expr Nat
  | token (position : Expr Nat) (token : ShellToken) : Expr Nat
  | readIndex (position : Expr Nat) : Expr ScalarExpression.Result
  | readValue (position : Expr Nat) : Expr ScalarExpression.Result
  | binding (target : Expr Nat) : Expr ArrayBindings.Binding
  | mutable (item : Expr ArrayBindings.Binding) : Expr Bool
  | resultAfter (value : Expr ScalarExpression.Result) : Expr Nat
  | operands (value : Expr ScalarExpression.Result) : Expr Nat
  | resultBounds (value : Expr ScalarExpression.Result) : Expr Integer.Interval
  | contains (item : Expr ArrayBindings.Binding) (indices : Expr Integer.Interval) : Expr Bool
  | isEmpty (bounds : Expr Integer.Interval) : Expr Bool
  | eqNat (left right : Expr Nat) : Expr Bool
  | neNat (left right : Expr Nat) : Expr Bool
  | leNat (left right : Expr Nat) : Expr Bool
  | not (value : Expr Bool) : Expr Bool
  | orElse (left right : Expr Bool) : Expr Bool
  | invalid : Expr BodyScan
  | assigned (position : Expr Nat) : Expr BodyScan
  | choose (test : Expr Bool) (yes no : Expr α) : Expr α
  | guardReturn (test : Expr Bool) (rejected accepted : Expr BodyScan) : Expr BodyScan
  | group (value : Expr α) : Expr α
  | locals (value : Expr α) : Expr α
  | beginValue (value : Expr α) : Expr α
  | letFirst (value : Expr Nat) (body : Expr α) : Expr α
  | letAfter (value : Expr Nat) (body : Expr α) : Expr α
  | letTarget (value : Expr Nat) (body : Expr α) : Expr α
  | letSubscript (value : Expr ScalarExpression.Result) (body : Expr α) : Expr α
  | letValue (value : Expr ScalarExpression.Result) (body : Expr α) : Expr α

def Expr.eval (imports : Imports) (target : TargetCall) (frame : Frame) : Expr α → α
  | .inputPosition => frame.position
  | .scanPosition => frame.scan.position
  | .localFirst => frame.first
  | .localAfter => frame.after
  | .localTarget => frame.target
  | .zero => 0
  | .maxOperands => ScalarExpression.maxOperands
  | .localSubscript => frame.subscript
  | .localValue => frame.value
  | .skip position => imports.skip frame.text (position.eval imports target frame)
  | .nameAfter first => imports.nameAfter frame.text (first.eval imports target frame)
  | .scalarLookup first after => imports.scalarLookup frame.text frame.context.scalarNames
      (first.eval imports target frame) (after.eval imports target frame)
  | .arrayLookup first after => imports.arrayLookup frame.text frame.context.arrayNames
      (first.eval imports target frame) (after.eval imports target frame)
  | .arrayTarget position => target frame.text frame.context (position.eval imports target frame)
  | .token position tok => imports.token frame.text (position.eval imports target frame) tok
  | .readIndex position => imports.readIndex frame.text frame.context (position.eval imports target frame) frame.scan.facts
  | .readValue position => imports.readValue frame.text frame.context (position.eval imports target frame) frame.scan.facts
  | .binding index => ArrayBindings.binding frame.context.arrayNames (index.eval imports target frame)
  | .mutable item => (item.eval imports target frame).mutable
  | .resultAfter value => (value.eval imports target frame).after
  | .operands value => (value.eval imports target frame).operands
  | .resultBounds value => (value.eval imports target frame).bounds
  | .contains item indices => imports.contains (item.eval imports target frame) (indices.eval imports target frame)
  | .isEmpty bounds => imports.isEmpty (bounds.eval imports target frame)
  | .eqNat left right => decide (left.eval imports target frame = right.eval imports target frame)
  | .neNat left right => decide (left.eval imports target frame ≠ right.eval imports target frame)
  | .leNat left right => decide (left.eval imports target frame ≤ right.eval imports target frame)
  | .not value => !value.eval imports target frame
  | .orElse left right => left.eval imports target frame || right.eval imports target frame
  | .invalid => imports.invalid frame.scan
  | .assigned position => {frame.scan with position := position.eval imports target frame, assigned := true}
  | .choose test yes no => if test.eval imports target frame then yes.eval imports target frame else no.eval imports target frame
  | .guardReturn test rejected accepted =>
      if test.eval imports target frame then rejected.eval imports target frame else accepted.eval imports target frame
  | .group value | .locals value | .beginValue value => value.eval imports target frame
  | .letFirst value body => body.eval imports target {frame with first := value.eval imports target frame}
  | .letAfter value body => body.eval imports target {frame with after := value.eval imports target frame}
  | .letTarget value body => body.eval imports target {frame with target := value.eval imports target frame}
  | .letSubscript value body => body.eval imports target {frame with subscript := value.eval imports target frame}
  | .letValue value body => body.eval imports target {frame with value := value.eval imports target frame}

def call := Compose.Expressions.call

def Expr.render : Expr α → List String
  | .inputPosition => ["position"]
  | .scanPosition => ["scan", ".", "position"]
  | .localFirst => ["first"]
  | .localAfter => ["after"]
  | .localTarget => ["target"]
  | .zero => ["0"]
  | .maxOperands => ["scalar_expressions", ".", "max_operands"]
  | .localSubscript => ["subscript"]
  | .localValue => ["value"]
  | .skip position => call "skip_at" [["text"], position.render]
  | .nameAfter first => call "name_after" [["text"], first.render]
  | .scalarLookup first after => ["scalar_expressions", "."] ++ call "lookup"
      [["text"], ["context", ".", "scalar_names"], first.render, after.render]
  | .arrayLookup first after => ["array_bindings", "."] ++ call "lookup"
      [["text"], ["context", ".", "array_names"], first.render, after.render]
  | .arrayTarget position => call "array_target" [["text"], ["context"], position.render]
  | .token position tok => call "take_token" [["text"], position.render, [Compose.Expressions.tokenName tok]]
  | .readIndex position => ["scalar_expressions", "."] ++ call "read_expression"
      [["text"], position.render, call "reading_names" [["context"], ["scan", ".", "facts"]]]
  | .readValue position => call "read_scalar_in_flow" [["text"], ["context"], position.render, ["scan", ".", "facts"]]
  | .binding index => ["context", ".", "array_names", ".", "items", "("] ++ index.render ++ [")"]
  | .mutable item => item.render ++ [".", "mutable"]
  | .resultAfter value => value.render ++ [".", "after"]
  | .operands value => value.render ++ [".", "operands"]
  | .resultBounds value => value.render ++ [".", "bounds"]
  | .contains item indices => ["array_bindings", "."] ++ call "contains" [item.render, indices.render]
  | .isEmpty bounds => ["scalars", "."] ++ call "is_empty" [bounds.render]
  | .eqNat left right => left.render ++ ["="] ++ right.render
  | .neNat left right => left.render ++ ["/="] ++ right.render
  | .leNat left right => left.render ++ ["<="] ++ right.render
  | .not value => ["not"] ++ value.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .invalid => call "invalid_body" [["scan"]]
  | .assigned position => ["(", "scan", "with", "delta", "position", "=>"] ++ position.render ++
      [",", "assigned", "=>", "true", ")"]
  | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render
  | .guardReturn test rejected accepted => ["if"] ++ test.render ++ ["then", "return"] ++
      rejected.render ++ [";", "end", "if", ";", "return"] ++ accepted.render ++ [";"]
  | .group value => ["("] ++ value.render ++ [")"]
  | .locals value => ["declare"] ++ value.render
  | .beginValue value => ["begin"] ++ value.render
  | .letFirst value body => ["first", ":", "constant", "literal_position", ":="] ++ value.render ++ [";"] ++ body.render
  | .letAfter value body => ["after", ":", "constant", "literal_position", ":="] ++ value.render ++ [";"] ++ body.render
  | .letTarget value body => ["target", ":", "constant", "array_bindings", ".", "binding_count", ":="] ++ value.render ++ [";"] ++ body.render
  | .letSubscript value body => ["subscript", ":", "constant", "scalar_expressions", ".", "expression_result", ":="] ++ value.render ++ [";"] ++ body.render
  | .letValue value body => ["value", ":", "constant", "scalar_expressions", ".", "expression_result", ":="] ++ value.render ++ [";"] ++ body.render

def targetBody : Expr Nat :=
  .locals <| .letFirst (.skip .inputPosition) <| .letAfter (.nameAfter .localFirst) <|
    .beginValue <| .group <| .choose (.neNat (.scalarLookup .localFirst .localAfter) .zero)
      .zero (.arrayLookup .localFirst .localAfter)

def assignmentBody : Expr BodyScan :=
  .letFirst (.skip .scanPosition) <| .letAfter (.nameAfter .localFirst) <|
  .letTarget (.arrayTarget .scanPosition) <|
  .letSubscript (.readIndex (.token .localAfter (.symbol "("))) <|
  .letValue (.readValue (.token (.token (.resultAfter .localSubscript) (.symbol ")")) (.symbol ":="))) <|
  .beginValue <| .guardReturn
    (.orElse (.orElse (.orElse (.orElse (.orElse
      (.eqNat .localTarget .zero) (.not (.mutable (.binding .localTarget))))
      (.not (.contains (.binding .localTarget) (.resultBounds .localSubscript))))
      (.eqNat (.operands .localSubscript) .maxOperands))
      (.leNat (.resultAfter .localValue) .scanPosition)) (.isEmpty (.resultBounds .localValue)))
    .invalid (.assigned (.resultAfter .localValue))

def assignmentRender : List String := assignmentBody.render ++ ["end", "array_assignment_body", ";"]

def targetEval (imports : Imports) (text : Source) (context : Native.Context) (position : Nat) : Nat :=
  targetBody.eval imports (fun _ _ _ => 0) {text, context, position}

def assignmentEval (imports : Imports) (target : TargetCall)
    (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  assignmentBody.eval imports target {text, context, scan}

def modelTarget : TargetCall := fun text context position => arrayTarget text context.model position

theorem targetEval_model (text : Source) (context : Native.Context) (position : Nat) :
    targetEval modelImports text context position = arrayTarget text context.model position := by
  dsimp +instances only [targetEval, targetBody, Expr.eval, modelImports, arrayTarget, Native.Context.model]
  simp only [decide_eq_true_eq]

theorem assignmentEval_model (text : Source) (context : Native.Context) (scan : BodyScan) :
    assignmentEval modelImports modelTarget text context scan = arrayAssignmentBody text context.model scan := by
  dsimp +instances only [assignmentEval, assignmentBody, Expr.eval, modelImports, modelTarget,
    arrayAssignmentBody, arrayIndex, arrayIndexStart, arrayValueStart, readScalarInFlow,
    tokenAfter, ShellToken.symbol, Native.Context.model]
  simp only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]

theorem assignmentEval_model_count (text : Source) (context : Native.Context) (scan : BodyScan) :
    (assignmentEval modelImports modelTarget text context scan).count = scan.count := by
  rw [assignmentEval_model]
  dsimp only [arrayAssignmentBody]
  split <;> rfl

structure Calls where
  target : TargetCall
  assignment : Source → Native.Context → BodyScan → BodyScan

def modelCalls : Calls where
  target := modelTarget
  assignment text context scan := arrayAssignmentBody text context.model scan

end Silver.Predicate.ArrayBodyNative

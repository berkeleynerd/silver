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
  arrayLookup : Source → ArrayBindings.Table → Nat → Nat → Nat
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
  arrayLookup := fun text names => ArrayBindings.lookup text names.items
  token := tokenAfter
  readIndex := fun text context position facts =>
    ScalarExpression.ArrayGrammar.read text position (context.model.readingNames facts) context.arrayTable (arrayReads := .noElements)
  readValue := fun text context position facts =>
    readScalarInFlow text context.model position facts
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
  | booleanElements (item : Expr ArrayBindings.Binding) : Expr Bool
  | componentBounds (item : Expr ArrayBindings.Binding) : Expr Integer.Interval
  | lower (bounds : Expr Integer.Interval) : Expr Int
  | upper (bounds : Expr Integer.Interval) : Expr Int
  | resultAfter (value : Expr ScalarExpression.Result) : Expr Nat
  | operands (value : Expr ScalarExpression.Result) : Expr Nat
  | resultBounds (value : Expr ScalarExpression.Result) : Expr Integer.Interval
  | contains (item : Expr ArrayBindings.Binding) (indices : Expr Integer.Interval) : Expr Bool
  | isEmpty (bounds : Expr Integer.Interval) : Expr Bool
  | eqNat (left right : Expr Nat) : Expr Bool
  | neNat (left right : Expr Nat) : Expr Bool
  | leNat (left right : Expr Nat) : Expr Bool
  | ltInt (left right : Expr Int) : Expr Bool
  | gtInt (left right : Expr Int) : Expr Bool
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
  | .arrayLookup first after => imports.arrayLookup frame.text frame.context.arrayTable
      (first.eval imports target frame) (after.eval imports target frame)
  | .arrayTarget position => target frame.text frame.context (position.eval imports target frame)
  | .token position tok => imports.token frame.text (position.eval imports target frame) tok
  | .readIndex position => imports.readIndex frame.text frame.context (position.eval imports target frame) frame.scan.facts
  | .readValue position => imports.readValue frame.text frame.context (position.eval imports target frame) frame.scan.facts
  | .binding index => ArrayBindings.binding frame.context.arrayNames (index.eval imports target frame)
  | .mutable item => (item.eval imports target frame).mutable
  | .booleanElements item => (item.eval imports target frame).isBoolean
  | .componentBounds item => (item.eval imports target frame).componentBounds
  | .lower bounds => (bounds.eval imports target frame).lower
  | .upper bounds => (bounds.eval imports target frame).upper
  | .resultAfter value => (value.eval imports target frame).after
  | .operands value => (value.eval imports target frame).operands
  | .resultBounds value => (value.eval imports target frame).bounds
  | .contains item indices => imports.contains (item.eval imports target frame) (indices.eval imports target frame)
  | .isEmpty bounds => imports.isEmpty (bounds.eval imports target frame)
  | .eqNat left right => decide (left.eval imports target frame = right.eval imports target frame)
  | .neNat left right => decide (left.eval imports target frame ≠ right.eval imports target frame)
  | .leNat left right => decide (left.eval imports target frame ≤ right.eval imports target frame)
  | .ltInt left right => decide (left.eval imports target frame < right.eval imports target frame)
  | .gtInt left right => decide (left.eval imports target frame > right.eval imports target frame)
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
      [["text"], position.render, call "reading_names" [["context"], ["scan", ".", "facts"]],
       ["arrays", "=>", "context", ".", "array_names"], ["array_reads", "=>", "scalar_expressions", ".", "no_elements"]]
  | .readValue position => call "read_scalar_in_flow" [["text"], ["context"], position.render, ["scan", ".", "facts"]]
  | .binding index => ["context", ".", "array_names", ".", "items", "("] ++ index.render ++ [")"]
  | .mutable item => item.render ++ [".", "mutable"]
  | .booleanElements item => item.render ++ [".", "boolean_elements"]
  | .componentBounds item => item.render ++ [".", "component_bounds"]
  | .lower bounds => bounds.render ++ [".", "lower"]
  | .upper bounds => bounds.render ++ [".", "upper"]
  | .resultAfter value => value.render ++ [".", "after"]
  | .operands value => value.render ++ [".", "operands"]
  | .resultBounds value => value.render ++ [".", "bounds"]
  | .contains item indices => ["array_bindings", "."] ++ call "contains" [item.render, indices.render]
  | .isEmpty bounds => ["scalars", "."] ++ call "is_empty" [bounds.render]
  | .eqNat left right => left.render ++ ["="] ++ right.render
  | .neNat left right => left.render ++ ["/="] ++ right.render
  | .leNat left right => left.render ++ ["<="] ++ right.render
  | .ltInt left right => left.render ++ ["<"] ++ right.render
  | .gtInt left right => left.render ++ [">"] ++ right.render
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
    (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse
      (.eqNat .localTarget .zero) (.not (.mutable (.binding .localTarget))))
      (.booleanElements (.binding .localTarget)))
      (.not (.contains (.binding .localTarget) (.resultBounds .localSubscript))))
      (.eqNat (.operands .localSubscript) .maxOperands))
      (.leNat (.resultAfter .localValue) .scanPosition)) (.isEmpty (.resultBounds .localValue)))
      (.ltInt (.lower (.resultBounds .localValue)) (.lower (.componentBounds (.binding .localTarget)))))
      (.gtInt (.upper (.resultBounds .localValue)) (.upper (.componentBounds (.binding .localTarget)))))
    .invalid (.assigned (.resultAfter .localValue))

def assignmentRender : List String := assignmentBody.render ++ ["end", "array_assignment_body", ";"]

/-- Categories are explicit: declaration and statement fragments are never
primaries, even when their result has the same Lean type as an expression. -/
def Expr.primary : Expr α → Bool
  | .inputPosition | .scanPosition | .localFirst | .localAfter | .localTarget
  | .zero | .maxOperands | .localSubscript | .localValue | .skip _ | .nameAfter _
  | .scalarLookup _ _ | .arrayLookup _ _ | .arrayTarget _ | .token _ _
  | .readIndex _ | .readValue _ | .binding _ | .mutable _ | .booleanElements _ | .resultAfter _
  | .componentBounds _ | .lower _ | .upper _
  | .operands _ | .resultBounds _ | .contains _ _ | .isEmpty _
  | .invalid | .assigned _ | .group _ => true
  | _ => false

def Expr.relation : Expr α → Bool
  | .eqNat _ _ | .neNat _ _ | .leNat _ _ | .ltInt _ _ | .gtInt _ _ | .not _ => true
  | value => value.primary

def Expr.expression : Expr α → Bool
  | .orElse _ _ => true
  | value => value.relation

def Expr.groupable : Expr α → Bool
  | .choose _ _ _ | .locals _ => true
  | value => value.expression

def Expr.isDeclaration : Expr α → Bool
  | .letFirst _ _ | .letAfter _ _ | .letTarget _ _ | .letSubscript _ _ | .letValue _ _ => true
  | _ => false

def Expr.isReturn : Expr α → Bool | .guardReturn _ _ _ => true | _ => false

/-- A declare expression ends in an expression; the ordinary function body
ends in its guarded return statements. Neither admits a nested bare declaration
or a statement in an expression position. -/
def Expr.declarationSequence (returning : Bool) : Expr α → Bool
  | .letFirst _ body | .letAfter _ body | .letTarget _ body
  | .letSubscript _ body | .letValue _ body => body.declarationSequence returning
  | .beginValue body => if returning then body.isReturn else body.expression
  | _ => false

def Expr.wellFormed : Expr α → Bool
  | .inputPosition | .scanPosition | .localFirst | .localAfter | .localTarget
  | .zero | .maxOperands | .localSubscript | .localValue | .invalid => true
  | .skip value | .nameAfter value | .arrayTarget value | .token value _
  | .readIndex value | .readValue value | .binding value | .assigned value =>
      value.expression && value.wellFormed
  | .scalarLookup a b | .arrayLookup a b | .contains a b =>
      a.expression && b.expression && a.wellFormed && b.wellFormed
  | .mutable value | .booleanElements value | .componentBounds value | .lower value | .upper value
  | .resultAfter value | .operands value | .resultBounds value =>
      value.primary && value.wellFormed
  | .isEmpty value => value.expression && value.wellFormed
  | .eqNat a b | .neNat a b | .leNat a b | .ltInt a b | .gtInt a b => a.primary && b.primary && a.wellFormed && b.wellFormed
  | .not value => value.primary && value.wellFormed
  | .orElse a b => a.expression && b.relation && a.wellFormed && b.wellFormed
  | .choose c a b | .guardReturn c a b => c.expression && a.expression && b.expression &&
      c.wellFormed && a.wellFormed && b.wellFormed
  | .group value => value.groupable && value.wellFormed
  | .locals body => body.isDeclaration && body.declarationSequence false && body.wellFormed
  | .beginValue body => (body.expression || body.isReturn) && body.wellFormed
  | .letFirst value body | .letAfter value body | .letTarget value body
  | .letSubscript value body | .letValue value body =>
      value.expression && value.wellFormed && body.wellFormed

def Expr.expressionBody (body : Expr α) : Bool := body.groupable && body.wellFormed

def Expr.functionBody (body : Expr BodyScan) : Bool :=
  body.isDeclaration && body.declarationSequence true && body.wellFormed

abbrev WellFormedTrees : Prop :=
  targetBody.expressionBody = true ∧ assignmentBody.functionBody = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

namespace PrecedenceChecks

private def condition : Expr Bool := .eqNat .zero .zero
private def booleanAtom : Expr Bool := .isEmpty (.resultBounds .localValue)
private def choice : Expr Nat := .choose condition .zero .inputPosition
private def returned : Expr BodyScan := .guardReturn condition .invalid .invalid
private def declared : Expr Nat := .locals (.letFirst .zero (.beginValue .localFirst))

/-- The alternate tree is well formed and has the shared tokens' Ada
association. A true Boolean primary makes the two meanings different. -/
private theorem negation_collision (imports : Imports) (target : TargetCall) (frame : Frame)
    (positive : booleanAtom.eval imports target frame = true) :
    (Expr.not (.orElse booleanAtom booleanAtom)).render =
      (Expr.orElse (.not booleanAtom) booleanAtom).render ∧
    (Expr.not (.orElse booleanAtom booleanAtom)).eval imports target frame = false ∧
    (Expr.orElse (.not booleanAtom) booleanAtom).eval imports target frame = true := by
  refine ⟨rfl, ?_, ?_⟩
  · change (!(booleanAtom.eval imports target frame || booleanAtom.eval imports target frame)) = false
    simp [positive]
  · change (!booleanAtom.eval imports target frame || booleanAtom.eval imports target frame) = true
    simp [positive]

private theorem expression_categories :
    (Expr.not condition).wellFormed = false ∧
    (Expr.not (.group condition)).wellFormed = true ∧
    (Expr.not (.orElse condition condition)).wellFormed = false ∧
    (Expr.not (.group (.orElse condition condition))).wellFormed = true ∧
    (Expr.not (.orElse booleanAtom booleanAtom)).wellFormed = false ∧
    (Expr.not (.group (.orElse booleanAtom booleanAtom))).wellFormed = true ∧
    (Expr.orElse (.not booleanAtom) booleanAtom).wellFormed = true ∧
    (Expr.eqNat choice .zero).wellFormed = false ∧
    (Expr.eqNat (.group choice) .zero).wellFormed = true ∧
    (Expr.choose condition choice .zero).wellFormed = false ∧
    (Expr.choose condition (.group choice) .zero).wellFormed = true ∧
    (Expr.skip declared).wellFormed = false ∧
    (Expr.skip (.group declared)).wellFormed = true := by decide +kernel

private theorem statement_placement :
    returned.expressionBody = false ∧
    (Expr.group returned).expressionBody = false ∧
    (Expr.choose condition returned .invalid).expressionBody = false ∧
    (Expr.locals (.letFirst .zero (.beginValue returned))).expressionBody = false ∧
    (Expr.letFirst .zero (.beginValue returned)).functionBody = true ∧
    (Expr.letFirst .zero (.beginValue .invalid)).functionBody = false ∧
    declared.expressionBody = true ∧
    (Expr.group declared).expressionBody = true ∧
    (Expr.locals (.beginValue (.zero : Expr Nat))).expressionBody = false ∧
    (Expr.group (.letFirst .zero (.beginValue (.zero : Expr Nat)))).expressionBody = false := by decide +kernel

end PrecedenceChecks

def targetEval (imports : Imports) (text : Source) (context : Native.Context) (position : Nat) : Nat :=
  targetBody.eval imports (fun _ _ _ => 0) {text, context, position}

def assignmentEval (imports : Imports) (target : TargetCall)
    (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  assignmentBody.eval imports target {text, context, scan}

def modelTarget : TargetCall := fun text context position => arrayTarget text context.model position

theorem targetEval_model (text : Source) (context : Native.Context) (position : Nat) :
    targetEval modelImports text context position = arrayTarget text context.model position := by
  dsimp +instances only [targetEval, targetBody, Expr.eval, modelImports, arrayTarget,
    Native.Context.arrayTable, Native.Context.model]
  simp only [decide_eq_true_eq]

theorem assignmentEval_model (text : Source) (context : Native.Context) (scan : BodyScan) :
    assignmentEval modelImports modelTarget text context scan = arrayAssignmentBody text context.model scan := by
  dsimp +instances only [assignmentEval, assignmentBody, Expr.eval, modelImports, modelTarget,
    arrayAssignmentBody, arrayIndex, arrayIndexStart, arrayValueStart, readScalarInFlow,
    tokenAfter, ShellToken.symbol, Native.Context.model, Native.Context.arrayTable, ParseContext.arrayTable]
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

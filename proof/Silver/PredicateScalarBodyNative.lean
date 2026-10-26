module

public import Silver.PredicateBodyAdmission
public import Silver.PredicateNativeState
public import Silver.ComposeContracts
public import Silver.PredicateBodyFlow

@[expose] public section

/-! Typed expressions for the native scalar target and assignment helpers.
Every expression determines both its source rendering and denotation; imported
lexical/scalar operations retain their actual callee identities. -/
namespace Silver.Predicate.ScalarBodyNative
open Compose

@[ext] structure Imports where
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  lookup : Source → ScalarExpression.Environment → Nat → Nat → Nat
  stringLookup : Source → BindingEnvironment → Nat → Nat → Nat
  assignment : Source → Nat → Nat
  read : Source → Native.Context → Nat → ActiveFlow → ScalarExpression.Result
  invalidModel : BodyScan → BodyScan
  isEmpty : Integer.Interval → Bool

def modelImports : Imports where
  skip := skipAt
  nameAfter := Compose.nameAfter
  lookup := ScalarExpression.lookup
  stringLookup := lookupName
  assignment := fun text position => fixedAfter text position ":=" false
  read := fun text context position facts => ScalarExpression.read text position (context.model.readingNames facts)
  invalidModel := invalidBody
  isEmpty := Integer.Interval.isEmpty

structure StringTargetResult where
  after : Nat := 0
  target : Nat := 0
  deriving DecidableEq, Repr

structure Frame where
  text : Source
  context : Native.Context
  position : Nat := 0
  scan : BodyScan := ⟨0, 0, 0, ⟨PathFacts.Context.empty, []⟩, false, false⟩
  first : Nat := 0
  after : Nat := 0
  target : Nat := 0
  index : Nat := 0
  value : ScalarExpression.Result := ScalarExpression.invalid

inductive Expr : Type → Type 1
  | inputPosition : Expr Nat
  | scanPosition : Expr Nat
  | localFirst : Expr Nat
  | localAfter : Expr Nat
  | localTarget : Expr Nat
  | localIndex : Expr Nat
  | zero : Expr Nat
  | scalarValue : Expr ScalarExpression.Result
  | skip (position : Expr Nat) : Expr Nat
  | nameAfter (first : Expr Nat) : Expr Nat
  | lookup (first after : Expr Nat) : Expr Nat
  | stringLookup (first after : Expr Nat) : Expr Nat
  | stringMutable (index : Expr Nat) : Expr Bool
  | targetResult (after index : Expr Nat) : Expr StringTargetResult
  | assignment (position : Expr Nat) : Expr Nat
  | read (position : Expr Nat) : Expr ScalarExpression.Result
  | binding (index : Expr Nat) : Expr ScalarExpression.Binding
  | mutable (item : Expr ScalarExpression.Binding) : Expr Bool
  | declaredBounds (item : Expr ScalarExpression.Binding) : Expr Integer.Interval
  | valueAfter (value : Expr ScalarExpression.Result) : Expr Nat
  | valueBounds (value : Expr ScalarExpression.Result) : Expr Integer.Interval
  | lower (bounds : Expr Integer.Interval) : Expr Int
  | upper (bounds : Expr Integer.Interval) : Expr Int
  | isEmpty (bounds : Expr Integer.Interval) : Expr Bool
  | eqNat (left right : Expr Nat) : Expr Bool
  | neNat (left right : Expr Nat) : Expr Bool
  | leNat (left right : Expr Nat) : Expr Bool
  | ltInt (left right : Expr Int) : Expr Bool
  | gtInt (left right : Expr Int) : Expr Bool
  | not (value : Expr Bool) : Expr Bool
  | orElse (left right : Expr Bool) : Expr Bool
  | andThen (left right : Expr Bool) : Expr Bool
  | invalid : Expr BodyScan
  | assigned (position : Expr Nat) : Expr BodyScan
  | choose (test : Expr Bool) (yes no : Expr α) : Expr α
  | group (value : Expr α) : Expr α
  | locals (value : Expr α) : Expr α
  | letFirst (value : Expr Nat) (body : Expr α) : Expr α
  | letAfter (value : Expr Nat) (body : Expr α) : Expr α
  | letTarget (value : Expr Nat) (body : Expr α) : Expr α
  | letIndex (value : Expr Nat) (body : Expr α) : Expr α
  | letValue (value : Expr ScalarExpression.Result) (body : Expr α) : Expr α
  | beginValue (value : Expr α) : Expr α

def Expr.eval (imports : Imports) (frame : Frame) : Expr α → α
  | .inputPosition => frame.position
  | .scanPosition => frame.scan.position
  | .localFirst => frame.first
  | .localAfter => frame.after
  | .localTarget => frame.target
  | .localIndex => frame.index
  | .zero => 0
  | .scalarValue => frame.value
  | .skip position => imports.skip frame.text (position.eval imports frame)
  | .nameAfter first => imports.nameAfter frame.text (first.eval imports frame)
  | .lookup first after => imports.lookup frame.text frame.context.scalarNames
      (first.eval imports frame) (after.eval imports frame)
  | .stringLookup first after => imports.stringLookup frame.text frame.context.names
      (first.eval imports frame) (after.eval imports frame)
  | .stringMutable index => ((frame.context.names.get (index.eval imports frame)).getD {}).mutable
  | .targetResult after index => ⟨after.eval imports frame, index.eval imports frame⟩
  | .assignment position => imports.assignment frame.text (position.eval imports frame)
  | .read position => imports.read frame.text frame.context (position.eval imports frame) frame.scan.facts
  | .binding index => ScalarExpression.binding frame.context.scalarNames (index.eval imports frame)
  | .mutable item => (item.eval imports frame).mutable
  | .declaredBounds item => (item.eval imports frame).declaredBounds
  | .valueAfter value => (value.eval imports frame).after
  | .valueBounds value => (value.eval imports frame).bounds
  | .lower bounds => (bounds.eval imports frame).lower
  | .upper bounds => (bounds.eval imports frame).upper
  | .isEmpty bounds => imports.isEmpty (bounds.eval imports frame)
  | .eqNat left right => decide (left.eval imports frame = right.eval imports frame)
  | .neNat left right => decide (left.eval imports frame ≠ right.eval imports frame)
  | .leNat left right => decide (left.eval imports frame ≤ right.eval imports frame)
  | .ltInt left right => decide (left.eval imports frame < right.eval imports frame)
  | .gtInt left right => decide (left.eval imports frame > right.eval imports frame)
  | .not value => !value.eval imports frame
  | .orElse left right => left.eval imports frame || right.eval imports frame
  | .andThen left right => left.eval imports frame && right.eval imports frame
  | .invalid => imports.invalidModel frame.scan
  | .assigned position =>
      {frame.scan with
        position := position.eval imports frame
        assigned := true
        facts := frame.scan.facts.replace frame.target frame.value.bounds}
  | .choose test yes no => if test.eval imports frame then yes.eval imports frame else no.eval imports frame
  | .group value | .locals value | .beginValue value => value.eval imports frame
  | .letFirst value body => body.eval imports {frame with first := value.eval imports frame}
  | .letAfter value body => body.eval imports {frame with after := value.eval imports frame}
  | .letTarget value body => body.eval imports {frame with target := value.eval imports frame}
  | .letIndex value body => body.eval imports {frame with index := value.eval imports frame}
  | .letValue value body => body.eval imports {frame with value := value.eval imports frame}

def call := Compose.Expressions.call

def Expr.render : Expr α → List String
  | .inputPosition => ["position"]
  | .scanPosition => ["scan", ".", "position"]
  | .localFirst => ["first"]
  | .localAfter => ["after"]
  | .localTarget => ["target"]
  | .localIndex => ["index"]
  | .zero => ["0"]
  | .scalarValue => ["value"]
  | .skip position => call "skip_at" [["text"], position.render]
  | .nameAfter first => call "name_after" [["text"], first.render]
  | .lookup first after => ["scalar_expressions", "."] ++ call "lookup"
      [["text"], ["context", ".", "scalar_names"], first.render, after.render]
  | .stringLookup first after => call "lookup_name"
      [["text"], ["context", ".", "names"], first.render, after.render]
  | .stringMutable index => ["context", ".", "names", ".", "items", "("] ++ index.render ++ [")", ".", "mutable"]
  | .targetResult after index => ["("] ++ after.render ++ [","] ++ index.render ++ [")"]
  | .assignment position => call "take_token" [["text"], position.render, ["assignment"]]
  | .read position => call "read_scalar_in_flow"
      [["text"], ["context"], position.render, ["scan", ".", "facts"]]
  | .binding index => ["context", ".", "scalar_names", ".", "items", "("] ++ index.render ++ [")"]
  | .mutable item => item.render ++ [".", "mutable"]
  | .declaredBounds item => item.render ++ [".", "declared_bounds"]
  | .valueAfter value => value.render ++ [".", "after"]
  | .valueBounds value => value.render ++ [".", "bounds"]
  | .lower bounds => bounds.render ++ [".", "lower"]
  | .upper bounds => bounds.render ++ [".", "upper"]
  | .isEmpty bounds => ["scalars", "."] ++ call "is_empty" [bounds.render]
  | .eqNat left right => left.render ++ ["="] ++ right.render
  | .neNat left right => left.render ++ ["/="] ++ right.render
  | .leNat left right => left.render ++ ["<="] ++ right.render
  | .ltInt left right => left.render ++ ["<"] ++ right.render
  | .gtInt left right => left.render ++ [">"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .invalid => call "invalid_body_model" [["scan"]]
  | .assigned position => ["(", "scan", "with", "delta", "position", "=>"] ++ position.render ++
      [",", "assigned", "=>", "true", ",", "facts", "=>", "(", "scan", ".", "facts", "with", "delta",
       "values", "=>", "(", "scan", ".", "facts", ".", "values", "with", "delta", "target", "=>", "value", ".", "bounds", ")", ")", ")"]
  | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .locals value => ["declare"] ++ value.render
  | .letFirst value body => ["first", ":", "constant", "literal_position", ":="] ++
      value.render ++ [";"] ++ body.render
  | .letAfter value body => ["after", ":", "constant", "literal_position", ":="] ++
      value.render ++ [";"] ++ body.render
  | .letTarget value body => ["target", ":", "constant", "scalar_expressions", ".", "binding_count", ":="] ++
      value.render ++ [";"] ++ body.render
  | .letIndex value body => ["index", ":", "constant", "binding_count", ":="] ++
      value.render ++ [";"] ++ body.render
  | .letValue value body => ["value", ":", "constant", "scalar_expressions", ".", "expression_result", ":="] ++
      value.render ++ [";"] ++ body.render
  | .beginValue value => ["begin"] ++ value.render

def targetBody : Expr Nat :=
  .locals (.letFirst (.skip .inputPosition) (.letAfter (.nameAfter .localFirst)
    (.beginValue (.lookup .localFirst .localAfter))))

def stringTargetBody : Expr StringTargetResult :=
  .locals (.letFirst (.skip .inputPosition) (.letAfter (.nameAfter .localFirst)
    (.letIndex (.stringLookup .localFirst .localAfter)
      (.beginValue (.group (.choose
        (.orElse (.orElse (.eqNat .localIndex .zero)
          (.neNat (.lookup .localFirst .localAfter) .zero))
          (.not (.stringMutable .localIndex)))
        (.targetResult .zero .zero) (.targetResult .localAfter .localIndex)))))))

def assignmentBody : Expr BodyScan :=
  .locals (.letFirst (.skip .scanPosition) (.letAfter (.nameAfter .localFirst)
    (.letTarget (.lookup .localFirst .localAfter) (.letValue (.read (.assignment .localAfter))
      (.beginValue (.group (.choose
        (.orElse (.orElse (.orElse (.orElse (.orElse
          (.eqNat .localTarget .zero) (.not (.mutable (.binding .localTarget))))
          (.leNat (.valueAfter .scalarValue) .scanPosition))
          (.isEmpty (.valueBounds .scalarValue)))
          (.ltInt (.lower (.valueBounds .scalarValue)) (.lower (.declaredBounds (.binding .localTarget)))))
          (.gtInt (.upper (.valueBounds .scalarValue)) (.upper (.declaredBounds (.binding .localTarget)))))
        .invalid (.assigned (.valueAfter .scalarValue)))))))))

def targetEval (imports : Imports) (text : Source) (context : Native.Context) (position : Nat) : Nat :=
  targetBody.eval imports {text, context, position}

def stringTargetEval (imports : Imports) (text : Source) (context : Native.Context) (position : Nat) : StringTargetResult :=
  stringTargetBody.eval imports {text, context, position}

def assignmentEval (imports : Imports) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  assignmentBody.eval imports {text, context, scan}

theorem targetEval_model (text : Source) (context : Native.Context) (position : Nat) :
    targetEval modelImports text context position = scalarTarget text context.model position := rfl

theorem assignmentEval_model (text : Source) (context : Native.Context) (scan : BodyScan) :
    assignmentEval modelImports text context scan = scalarAssignmentBody text context.model scan := by
  dsimp +instances only [assignmentEval, assignmentBody, Expr.eval, modelImports, scalarAssignmentBody,
    scalarTarget, scalarAssignmentStart, Native.Context.model]
  simp only [Bool.or_eq_true, decide_eq_true_eq, or_assoc]


theorem stringTargetEval_model (text : Source) (context : Native.Context) (scan : BodyScan) :
    stringTargetEval modelImports text context scan.position =
      ⟨(targetAt text (parserState context.model scan) false).position,
       (targetAt text (parserState context.model scan) false).target⟩ := by
  dsimp +instances only [stringTargetEval, stringTargetBody, Expr.eval, modelImports,
    targetAt, parserState, Native.Context.model]
  simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq,
    Bool.false_eq_true, false_and, or_false, or_assoc]
  split <;> rfl

/-- The discriminant of the constrained extended return is retained. -/
theorem assignmentEval_model_count (text : Source) (context : Native.Context) (scan : BodyScan) :
    (assignmentEval modelImports text context scan).count = scan.count := by
  rw [assignmentEval_model]
  exact scalarAssignment_count ..

structure Calls where
  target : Source → Native.Context → Nat → Nat
  stringTarget : Source → Native.Context → Nat → StringTargetResult
  assignmentModel : Source → Native.Context → BodyScan → BodyScan
  assignment : Source → Native.Context → BodyScan → BodyScan

inductive RuntimeExpr | assignmentModel

def RuntimeExpr.eval (calls : Calls) (text : Source) (context : Native.Context) (scan : BodyScan) : RuntimeExpr → BodyScan
  | .assignmentModel => calls.assignmentModel text context scan

def RuntimeExpr.render : RuntimeExpr → List String
  | .assignmentModel => call "scalar_assignment_model" [["text"], ["context"], ["scan"]]

def assignmentRhs : RuntimeExpr := .assignmentModel

def modelCalls : Calls where
  target text context position := scalarTarget text context.model position
  stringTarget := stringTargetEval modelImports
  assignmentModel text context scan := scalarAssignmentBody text context.model scan
  assignment text context scan := scalarAssignmentBody text context.model scan

end Silver.Predicate.ScalarBodyNative

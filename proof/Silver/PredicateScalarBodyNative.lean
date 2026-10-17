module

public import Silver.PredicateBodyAdmission
public import Silver.PredicateNativeState
public import Silver.ComposeContracts

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
  assignment : Source → Nat → Nat
  read : Source → Nat → ScalarExpression.Environment → ScalarExpression.Result
  isEmpty : Integer.Interval → Bool

def modelImports : Imports where
  skip := skipAt
  nameAfter := Compose.nameAfter
  lookup := ScalarExpression.lookup
  assignment := fun text position => fixedAfter text position ":=" false
  read := fun text position names => ScalarExpression.read text position names
  isEmpty := Integer.Interval.isEmpty

structure Frame where
  text : Source
  context : Native.Context
  position : Nat := 0
  scan : BodyScan := invalidBody
  first : Nat := 0
  after : Nat := 0
  target : Nat := 0
  value : ScalarExpression.Result := ScalarExpression.invalid

inductive Expr : Type → Type 1
  | inputPosition : Expr Nat
  | scanPosition : Expr Nat
  | localFirst : Expr Nat
  | localAfter : Expr Nat
  | localTarget : Expr Nat
  | zero : Expr Nat
  | scalarValue : Expr ScalarExpression.Result
  | skip (position : Expr Nat) : Expr Nat
  | nameAfter (first : Expr Nat) : Expr Nat
  | lookup (first after : Expr Nat) : Expr Nat
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
  | letValue (value : Expr ScalarExpression.Result) (body : Expr α) : Expr α
  | beginValue (value : Expr α) : Expr α

def Expr.eval (imports : Imports) (frame : Frame) : Expr α → α
  | .inputPosition => frame.position
  | .scanPosition => frame.scan.position
  | .localFirst => frame.first
  | .localAfter => frame.after
  | .localTarget => frame.target
  | .zero => 0
  | .scalarValue => frame.value
  | .skip position => imports.skip frame.text (position.eval imports frame)
  | .nameAfter first => imports.nameAfter frame.text (first.eval imports frame)
  | .lookup first after => imports.lookup frame.text frame.context.scalarNames
      (first.eval imports frame) (after.eval imports frame)
  | .assignment position => imports.assignment frame.text (position.eval imports frame)
  | .read position => imports.read frame.text (position.eval imports frame) frame.context.scalarNames
  | .binding index => ScalarExpression.binding frame.context.scalarNames (index.eval imports frame)
  | .mutable item => (item.eval imports frame).mutable
  | .declaredBounds item => (item.eval imports frame).declaredBounds
  | .valueAfter value => (value.eval imports frame).after
  | .valueBounds value => (value.eval imports frame).bounds
  | .lower bounds => (bounds.eval imports frame).lower
  | .upper bounds => (bounds.eval imports frame).upper
  | .isEmpty bounds => imports.isEmpty (bounds.eval imports frame)
  | .eqNat left right => decide (left.eval imports frame = right.eval imports frame)
  | .leNat left right => decide (left.eval imports frame ≤ right.eval imports frame)
  | .ltInt left right => decide (left.eval imports frame < right.eval imports frame)
  | .gtInt left right => decide (left.eval imports frame > right.eval imports frame)
  | .not value => !value.eval imports frame
  | .orElse left right => left.eval imports frame || right.eval imports frame
  | .andThen left right => left.eval imports frame && right.eval imports frame
  | .invalid => invalidBody
  | .assigned position => {frame.scan with position := position.eval imports frame, assigned := true}
  | .choose test yes no => if test.eval imports frame then yes.eval imports frame else no.eval imports frame
  | .group value | .locals value | .beginValue value => value.eval imports frame
  | .letFirst value body => body.eval imports {frame with first := value.eval imports frame}
  | .letAfter value body => body.eval imports {frame with after := value.eval imports frame}
  | .letTarget value body => body.eval imports {frame with target := value.eval imports frame}
  | .letValue value body => body.eval imports {frame with value := value.eval imports frame}

def call := Compose.Expressions.call

def Expr.render : Expr α → List String
  | .inputPosition => ["position"]
  | .scanPosition => ["scan", ".", "position"]
  | .localFirst => ["first"]
  | .localAfter => ["after"]
  | .localTarget => ["target"]
  | .zero => ["0"]
  | .scalarValue => ["value"]
  | .skip position => call "skip_at" [["text"], position.render]
  | .nameAfter first => call "name_after" [["text"], first.render]
  | .lookup first after => ["scalar_expressions", "."] ++ call "lookup"
      [["text"], ["context", ".", "scalar_names"], first.render, after.render]
  | .assignment position => call "take_token" [["text"], position.render, ["assignment"]]
  | .read position => ["scalar_expressions", "."] ++ call "read_expression"
      [["text"], position.render, ["context", ".", "scalar_names"]]
  | .binding index => ["context", ".", "scalar_names", ".", "items", "("] ++ index.render ++ [")"]
  | .mutable item => item.render ++ [".", "mutable"]
  | .declaredBounds item => item.render ++ [".", "declared_bounds"]
  | .valueAfter value => value.render ++ [".", "after"]
  | .valueBounds value => value.render ++ [".", "bounds"]
  | .lower bounds => bounds.render ++ [".", "lower"]
  | .upper bounds => bounds.render ++ [".", "upper"]
  | .isEmpty bounds => ["scalars", "."] ++ call "is_empty" [bounds.render]
  | .eqNat left right => left.render ++ ["="] ++ right.render
  | .leNat left right => left.render ++ ["<="] ++ right.render
  | .ltInt left right => left.render ++ ["<"] ++ right.render
  | .gtInt left right => left.render ++ [">"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .invalid => ["invalid_body"]
  | .assigned position => ["(", "scan", "with", "delta", "position", "=>"] ++ position.render ++
      [",", "assigned", "=>", "true", ")"]
  | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .locals value => ["declare"] ++ value.render
  | .letFirst value body => ["first", ":", "constant", "literal_position", ":="] ++
      value.render ++ [";"] ++ body.render
  | .letAfter value body => ["after", ":", "constant", "literal_position", ":="] ++
      value.render ++ [";"] ++ body.render
  | .letTarget value body => ["target", ":", "constant", "scalar_expressions", ".", "binding_count", ":="] ++
      value.render ++ [";"] ++ body.render
  | .letValue value body => ["value", ":", "constant", "scalar_expressions", ".", "expression_result", ":="] ++
      value.render ++ [";"] ++ body.render
  | .beginValue value => ["begin"] ++ value.render

def targetBody : Expr Nat :=
  .locals (.letFirst (.skip .inputPosition) (.letAfter (.nameAfter .localFirst)
    (.beginValue (.lookup .localFirst .localAfter))))

def assignmentBody : Expr BodyScan :=
  .locals (.letFirst (.skip .scanPosition) (.letAfter (.nameAfter .localFirst)
    (.letTarget (.lookup .localFirst .localAfter) (.letValue (.read (.assignment .localAfter))
      (.beginValue (.group (.choose
        (.orElse (.orElse (.orElse (.eqNat .localTarget .zero) (.not (.mutable (.binding .localTarget))))
          (.leNat (.valueAfter .scalarValue) .scanPosition))
          (.group (.andThen (.not (.isEmpty (.valueBounds .scalarValue)))
            (.group (.orElse
              (.ltInt (.lower (.valueBounds .scalarValue)) (.lower (.declaredBounds (.binding .localTarget))))
              (.gtInt (.upper (.valueBounds .scalarValue)) (.upper (.declaredBounds (.binding .localTarget)))))))))
        .invalid (.assigned (.valueAfter .scalarValue)))))))))

def targetEval (imports : Imports) (text : Source) (context : Native.Context) (position : Nat) : Nat :=
  targetBody.eval imports {text, context, position}

def assignmentEval (imports : Imports) (text : Source) (context : Native.Context) (scan : BodyScan) : BodyScan :=
  assignmentBody.eval imports {text, context, scan}

theorem targetEval_model (text : Source) (context : Native.Context) (position : Nat) :
    targetEval modelImports text context position = scalarTarget text context.model position := rfl

theorem assignmentEval_model (text : Source) (context : Native.Context) (scan : BodyScan) :
    assignmentEval modelImports text context scan = scalarAssignmentBody text context.model scan := by
  dsimp +instances only [assignmentEval, assignmentBody, Expr.eval, modelImports, scalarAssignmentBody,
    scalarTarget, scalarAssignmentStart, Native.Context.model]
  simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq, or_assoc]

end Silver.Predicate.ScalarBodyNative

module

public import Silver.StaticBooleanNative

@[expose] public section

/-! The complete typed body of `Static_Boolean_Relation`. Scalar and Boolean
branches retain their native order, imported calls take their actual arguments,
and the result is independent of all initially unassigned local values. -/
namespace Silver.BooleanElaboration.Native.Relation

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

inductive ScalarLocal | left | right
  deriving DecidableEq, Repr
inductive FlagLocal | left | right
  deriving DecidableEq, Repr
inductive ComparisonLocal | scalar | boolean
  deriving DecidableEq, Repr

def ScalarLocal.name : ScalarLocal → String | .left => "left" | .right => "right"
def FlagLocal.name : FlagLocal → String | .left => "flag_left" | .right => "flag_right"
def ComparisonLocal.name : ComparisonLocal → String
  | .scalar => "compare" | .boolean => "boolean_compare"

structure Frame where
  text : Source
  state : Compose.ParserState
  position : Nat
  scalars : ScalarLocal → ScalarExpression.Result
  flags : FlagLocal → Result
  comparisons : ComparisonLocal → Predicate.ComparisonResult

def Frame.setScalar (frame : Frame) (name : ScalarLocal) (value : ScalarExpression.Result) : Frame :=
  {frame with scalars := fun query => if query = name then value else frame.scalars query}
def Frame.setFlag (frame : Frame) (name : FlagLocal) (value : Result) : Frame :=
  {frame with flags := fun query => if query = name then value else frame.flags query}
def Frame.setComparison (frame : Frame) (name : ComparisonLocal) (value : Predicate.ComparisonResult) : Frame :=
  {frame with comparisons := fun query => if query = name then value else frame.comparisons query}

inductive Expr : Type → Type 1
  | number : Nat → Expr Nat
  | position : Expr Nat
  | scalar : ScalarLocal → Expr ScalarExpression.Result
  | flag : FlagLocal → Expr Result
  | comparison : ComparisonLocal → Expr Predicate.ComparisonResult
  | invalid : Expr Result
  | afterScalar : Expr ScalarExpression.Result → Expr Nat
  | bounds : Expr ScalarExpression.Result → Expr Integer.Interval
  | lower : Expr Integer.Interval → Expr Int
  | upper : Expr Integer.Interval → Expr Int
  | afterFlag : Expr Result → Expr Nat
  | resultValue : Expr Result → Expr Bool
  | afterComparison : Expr Predicate.ComparisonResult → Expr Nat
  | comparisonOperator : Expr Predicate.ComparisonResult → Expr Predicate.Comparison
  | empty : Expr Integer.Interval → Expr Bool
  | readScalar : Expr Nat → Expr ScalarExpression.Result
  | readComparison : Expr Nat → Expr Predicate.ComparisonResult
  | factor : Expr Nat → Expr Result
  | aggregate : Expr Nat → Expr Bool → Expr Result
  | equal : Expr Nat → Expr Nat → Expr Bool
  | unequal : Expr Nat → Expr Nat → Expr Bool
  | compareInt : Predicate.Comparison → Expr Int → Expr Int → Expr Bool
  | equalFlag : Expr Bool → Expr Bool → Expr Bool
  | equalOperator : Expr Predicate.Comparison → Predicate.Comparison → Expr Bool
  | notEqualityOperator : Expr Predicate.Comparison → Expr Bool
  | andThen : Expr Bool → Expr Bool → Expr Bool
  | orElse : Expr Bool → Expr Bool → Expr Bool
  | group : Expr α → Expr α
  | operatorCase : Expr Predicate.Comparison → Expr Bool → Expr Bool → Expr Bool →
      Expr Bool → Expr Bool → Expr Bool → Expr Bool

def Expr.eval (imports : Imports) (factor : Reader) (frame : Frame) : Expr α → α
  | .number value => value
  | .position => frame.position
  | .scalar name => frame.scalars name
  | .flag name => frame.flags name
  | .comparison name => frame.comparisons name
  | .invalid => Silver.BooleanElaboration.Native.invalid
  | .afterScalar value => (value.eval imports factor frame).after
  | .bounds value => (value.eval imports factor frame).bounds
  | .lower value => (value.eval imports factor frame).lower
  | .upper value => (value.eval imports factor frame).upper
  | .afterFlag value => (value.eval imports factor frame).after
  | .resultValue result => (result.eval imports factor frame).value
  | .afterComparison value => (value.eval imports factor frame).after
  | .comparisonOperator value => (value.eval imports factor frame).operator
  | .empty value => (value.eval imports factor frame).isEmpty
  | .readScalar cursor => imports.scalar frame.text (cursor.eval imports factor frame) frame.state.scalarNames
  | .readComparison cursor => imports.comparison frame.text (cursor.eval imports factor frame)
  | .factor cursor => factor frame.text frame.state (cursor.eval imports factor frame)
  | .aggregate finish value => ⟨finish.eval imports factor frame, value.eval imports factor frame⟩
  | .equal left right => left.eval imports factor frame == right.eval imports factor frame
  | .unequal left right => left.eval imports factor frame != right.eval imports factor frame
  | .compareInt operator left right => compareValues operator (left.eval imports factor frame) (right.eval imports factor frame)
  | .equalFlag left right => left.eval imports factor frame == right.eval imports factor frame
  | .equalOperator value operator => value.eval imports factor frame == operator
  | .notEqualityOperator value => decide (value.eval imports factor frame ≠ .eq ∧ value.eval imports factor frame ≠ .ne)
  | .andThen left right => left.eval imports factor frame && right.eval imports factor frame
  | .orElse left right => left.eval imports factor frame || right.eval imports factor frame
  | .group value => value.eval imports factor frame
  | .operatorCase operator eqValue neValue less lessEqual greater greaterEqual =>
      match operator.eval imports factor frame with
      | .eq => eqValue.eval imports factor frame | .ne => neValue.eval imports factor frame
      | .lt => less.eval imports factor frame | .le => lessEqual.eval imports factor frame
      | .gt => greater.eval imports factor frame | .ge => greaterEqual.eval imports factor frame

def comparisonName : Predicate.Comparison → String
  | .eq => "equal" | .ne => "unequal" | .lt => "less" | .le => "less_equal"
  | .gt => "greater" | .ge => "greater_equal"
def comparisonSymbol : Predicate.Comparison → String
  | .eq => "=" | .ne => "/=" | .lt => "<" | .le => "<=" | .gt => ">" | .ge => ">="

def Expr.render : Expr α → List String
  | .number value => [toString value]
  | .position => ["position"]
  | .scalar name => [name.name]
  | .flag name => [name.name]
  | .comparison name => [name.name]
  | .invalid => ["invalid_static_boolean"]
  | .afterScalar value | .afterFlag value | .afterComparison value => value.render ++ [".", "after"]
  | .bounds value => value.render ++ [".", "bounds"]
  | .lower value => value.render ++ [".", "lower"]
  | .upper value => value.render ++ [".", "upper"]
  | .resultValue result => result.render ++ [".", "value"]
  | .comparisonOperator value => value.render ++ [".", "operator"]
  | .empty value => call ["scalars", ".", "is_empty"] [value.render]
  | .readScalar cursor => call ["scalar_expressions", ".", "read_expression"]
      [["text"], cursor.render, ["frame", ".", "scalar_names"], ["elaborating", "=>", "true"]]
  | .readComparison cursor => call ["scalar_comparison_at"] [["text"], cursor.render]
  | .factor cursor => call ["static_boolean_factor"] [["text"], ["frame"], cursor.render]
  | .aggregate finish value => ["("] ++ finish.render ++ [","] ++ value.render ++ [")"]
  | .equal left right | .equalFlag left right => left.render ++ ["="] ++ right.render
  | .unequal left right => left.render ++ ["/="] ++ right.render
  | .compareInt operator left right => left.render ++ [comparisonSymbol operator] ++ right.render
  | .equalOperator value operator => value.render ++ ["=", "paths", ".", comparisonName operator]
  | .notEqualityOperator value => value.render ++ ["not", "in", "paths", ".", "equal", "|", "paths", ".", "unequal"]
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .operatorCase operator eqValue neValue less lessEqual greater greaterEqual =>
      ["case"] ++ operator.render ++ ["is", "when", "paths", ".", "equal", "=>"] ++ eqValue.render ++
      [",", "when", "paths", ".", "unequal", "=>"] ++ neValue.render ++
      [",", "when", "paths", ".", "less", "=>"] ++ less.render ++
      [",", "when", "paths", ".", "less_equal", "=>"] ++ lessEqual.render ++
      [",", "when", "paths", ".", "greater", "=>"] ++ greater.render ++
      [",", "when", "paths", ".", "greater_equal", "=>"] ++ greaterEqual.render

def Expr.recordName : Expr α → Bool
  | .scalar _ | .flag _ | .comparison _ => true
  | .bounds value => value.recordName
  | _ => false
def Expr.primaryOperand : Expr α → Bool
  | .equal _ _ | .unequal _ _ | .compareInt _ _ _ | .equalFlag _ _ | .equalOperator _ _ |
      .notEqualityOperator _ | .andThen _ _ | .orElse _ _ | .operatorCase _ _ _ _ _ _ _ => false
  | _ => true
def Expr.relation : Expr Bool → Bool
  | .andThen _ _ | .orElse _ _ | .operatorCase _ _ _ _ _ _ _ => false
  | _ => true
def Expr.wellFormed : Expr α → Bool
  | .number _ | .position | .scalar _ | .flag _ | .comparison _ | .invalid => true
  | .afterScalar value | .bounds value | .lower value | .upper value | .afterFlag value |
      .resultValue value | .afterComparison value | .comparisonOperator value => value.recordName
  | .empty value => value.primaryOperand && value.wellFormed
  | .readScalar cursor | .readComparison cursor | .factor cursor => cursor.primaryOperand && cursor.wellFormed
  | .aggregate finish value => finish.primaryOperand && finish.wellFormed && value.wellFormed
  | .equal left right | .unequal left right | .compareInt _ left right | .equalFlag left right =>
      left.primaryOperand && left.wellFormed && right.primaryOperand && right.wellFormed
  | .equalOperator value _ | .notEqualityOperator value => value.primaryOperand && value.wellFormed
  | .andThen left right => (match left with | .orElse _ _ => false | _ => left.wellFormed) &&
      right.relation && right.wellFormed
  | .orElse left right => (match left with | .andThen _ _ => false | _ => left.wellFormed) &&
      right.relation && right.wellFormed
  | .group value => value.wellFormed
  | .operatorCase operator eqValue neValue less lessEqual greater greaterEqual =>
      operator.primaryOperand && operator.wellFormed && eqValue.wellFormed && neValue.wellFormed &&
      less.wellFormed && lessEqual.wellFormed && greater.wellFormed && greaterEqual.wellFormed

inductive Command
  | nothing
  | setScalar : ScalarLocal → Expr ScalarExpression.Result → Command
  | setFlag : FlagLocal → Expr Result → Command
  | setComparison : ComparisonLocal → Expr Predicate.ComparisonResult → Command
  | sequence : Command → Command → Command
  | choose : Expr Bool → Command → Command → Command
  | returned : Expr Result → Command

def Command.eval (imports : Imports) (factor : Reader) (frame : Frame) (next : Frame → Result) : Command → Result
  | .nothing => next frame
  | .setScalar name value => next (frame.setScalar name (value.eval imports factor frame))
  | .setFlag name value => next (frame.setFlag name (value.eval imports factor frame))
  | .setComparison name value => next (frame.setComparison name (value.eval imports factor frame))
  | .sequence first rest => first.eval imports factor frame (fun updated => rest.eval imports factor updated next)
  | .choose test yes no => if test.eval imports factor frame then yes.eval imports factor frame next
      else no.eval imports factor frame next
  | .returned value => value.eval imports factor frame

mutual
  def Command.render : Command → List String
    | .nothing => []
    | .setScalar name value => [name.name, ":="] ++ value.render ++ [";"]
    | .setFlag name value => [name.name, ":="] ++ value.render ++ [";"]
    | .setComparison name value => [name.name, ":="] ++ value.render ++ [";"]
    | .sequence first rest => first.render ++ rest.render
    | .choose test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
    | .returned value => ["return"] ++ value.render ++ [";"]
  def Command.renderElse : Command → List String
    | .nothing => []
    | .choose test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++ no.renderElse
    | command => ["else"] ++ command.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .nothing
def Command.wellFormed : Command → Bool
  | .nothing => true
  | .setScalar _ value | .setFlag _ value | .setComparison _ value | .returned value => value.wellFormed
  | .sequence first rest => first.wellFormed && rest.wellFormed
  | .choose test yes no => test.wellFormed && yes.wellFormed && no.wellFormed

def scalarCase : Expr Bool :=
  .group (.operatorCase (.comparisonOperator (.comparison .scalar))
    (.compareInt .eq (.lower (.bounds (.scalar .left))) (.lower (.bounds (.scalar .right))))
    (.compareInt .ne (.lower (.bounds (.scalar .left))) (.lower (.bounds (.scalar .right))))
    (.compareInt .lt (.lower (.bounds (.scalar .left))) (.lower (.bounds (.scalar .right))))
    (.compareInt .le (.lower (.bounds (.scalar .left))) (.lower (.bounds (.scalar .right))))
    (.compareInt .gt (.lower (.bounds (.scalar .left))) (.lower (.bounds (.scalar .right))))
    (.compareInt .ge (.lower (.bounds (.scalar .left))) (.lower (.bounds (.scalar .right)))))

theorem scalarCase_eval (imports : Imports) (factor : Reader) (frame : Frame) :
    scalarCase.eval imports factor frame = compareValues (frame.comparisons .scalar).operator
      (frame.scalars .left).bounds.lower (frame.scalars .right).bounds.lower := by
  cases h : (frame.comparisons .scalar).operator <;> simp only [scalarCase, Expr.eval, h]

def commands : Command := .list [
  .choose (.andThen (.unequal (.afterScalar (.scalar .left)) (.number 0))
      (.unequal (.afterComparison (.comparison .scalar)) (.number 0)))
    (.list [
      .setScalar .right (.readScalar (.afterComparison (.comparison .scalar))),
      .choose (.orElse (.orElse (.orElse (.orElse
          (.equal (.afterScalar (.scalar .right)) (.number 0)) (.empty (.bounds (.scalar .left))))
          (.empty (.bounds (.scalar .right))))
          (.compareInt .ne (.lower (.bounds (.scalar .left))) (.upper (.bounds (.scalar .left)))))
          (.compareInt .ne (.lower (.bounds (.scalar .right))) (.upper (.bounds (.scalar .right)))))
        (.returned .invalid) .nothing,
      .returned (.aggregate (.afterScalar (.scalar .right)) scalarCase)]) .nothing,
  .setFlag .left (.factor .position),
  .choose (.equal (.afterFlag (.flag .left)) (.number 0)) (.returned .invalid) .nothing,
  .setComparison .boolean (.readComparison (.afterFlag (.flag .left))),
  .choose (.equal (.afterComparison (.comparison .boolean)) (.number 0)) (.returned (.flag .left)) .nothing,
  .choose (.notEqualityOperator (.comparisonOperator (.comparison .boolean))) (.returned .invalid) .nothing,
  .setFlag .right (.factor (.afterComparison (.comparison .boolean))),
  .choose (.equal (.afterFlag (.flag .right)) (.number 0)) (.returned .invalid) .nothing,
  .returned (.aggregate (.afterFlag (.flag .right))
    (.equalFlag (.group (.equalFlag (.resultValue (.flag .left)) (.resultValue (.flag .right))))
      (.group (.equalOperator (.comparisonOperator (.comparison .boolean)) .eq))))]

inductive Declaration
  | scalar : ScalarLocal → Bool → Option (Expr ScalarExpression.Result) → Declaration
  | comparison : ComparisonLocal → Bool → Option (Expr Predicate.ComparisonResult) → Declaration
  | flags

def Declaration.eval (imports : Imports) (factor : Reader) (frame : Frame) : Declaration → Frame
  | .scalar name _ value => match value with
      | none => frame | some initial => frame.setScalar name (initial.eval imports factor frame)
  | .comparison name _ value => match value with
      | none => frame | some initial => frame.setComparison name (initial.eval imports factor frame)
  | .flags => (frame.setFlag .left invalid).setFlag .right invalid

def Declaration.render : Declaration → List String
  | .scalar name constant value => [name.name, ":"] ++ (if constant then ["constant"] else []) ++
      ["scalar_expressions", ".", "expression_result"] ++
      (match value with | none => [] | some initial => [":="] ++ initial.render) ++ [";"]
  | .comparison name constant value => [name.name, ":"] ++ (if constant then ["constant"] else []) ++
      ["comparison_result"] ++
      (match value with | none => [] | some initial => [":="] ++ initial.render) ++ [";"]
  | .flags => ["flag_left", ",", "flag_right", ":", "static_boolean_result", ";"]

def declarations : List Declaration := [
  .scalar .left true (some (.readScalar .position)),
  .comparison .scalar true (some (.readComparison (.afterScalar (.scalar .left)))),
  .scalar .right false none, .flags, .comparison .boolean false none]

def eval (imports : Imports) (factor : Reader) (initial : Frame) : Result :=
  commands.eval imports factor (declarations.foldl (Declaration.eval imports factor) initial) (fun _ => invalid)
def render : List String := declarations.flatMap Declaration.render ++ ["begin"] ++ commands.render ++
  ["end", "static_boolean_relation", ";"]

theorem wellFormed : commands.wellFormed = true := rfl

/-- Uninitialized native locals are arbitrary; no definite value is assumed
before their first assignment. The equation holds for every initial frame. -/
theorem denotation (imports : Imports) (factor : Reader) (initial : Frame) :
    eval imports factor initial = relationStep imports factor initial.text initial.state initial.position := by
  dsimp +instances only [eval, commands, Command.list, List.foldr, Command.eval, declarations,
    List.foldl, Declaration.eval, Expr.eval, Frame.setScalar, Frame.setFlag, Frame.setComparison]
  simp only [scalarCase_eval]
  dsimp only [Frame.setScalar, Frame.setFlag, Frame.setComparison, relationStep]
  simp only [Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq, bne_iff_ne, decide_eq_true_eq,
    compareValues, reduceCtorEq, ↓reduceIte, or_assoc]

end Silver.BooleanElaboration.Native.Relation

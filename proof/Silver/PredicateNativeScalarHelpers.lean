module

public import Silver.PredicateNativeState
public import Silver.PredicateFlowSourceBridge
public import Silver.ScalarsNativeSourceBridge

@[expose] public section

/-! Checked scalar-guard helper expressions. Arbitrary helper interpretations
are constrained by their source definition equations on the actual caller
domains. The scalar library is interpreted through its existing checked
equations; neither Bare_Target nor Scalar_Condition is assumed to equal the
parser model. -/
namespace Silver.Predicate.Native.ScalarHelpers
open Silver.SourceBridge Compose Compose.Expressions

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

inductive Ty
  | number | value | truth | text | context | flow | result | condition
  | comparison | scalarComparison | interval | binding | names
  deriving DecidableEq

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .value => Int | .truth => Bool | .text => Source
  | .context => Native.Context | .flow => ActiveFlow | .result => ScalarExpression.Result
  | .condition => ConditionResult | .comparison => Comparison
  | .scalarComparison => Integer.Comparison | .interval => Integer.Interval
  | .binding => ScalarExpression.Binding | .names => ScalarExpression.Environment

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .value => 0 | .truth => false | .text => []
  | .context => ⟨[], 0, 0, [], 0, []⟩ | .flow => ⟨PathFacts.Context.empty, []⟩
  | .result => ScalarExpression.invalid
  | .condition => Predicate.invalidCondition ⟨PathFacts.Context.empty, []⟩
  | .comparison => .eq | .scalarComparison => .eq | .interval => Integer.Interval.empty
  | .binding => ScalarExpression.emptyBinding | .names => []

structure Calls where
  scalars : Integer.Native.Calls
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  lookup : Source → ScalarExpression.Environment → Nat → Nat → Nat
  invalid : ActiveFlow → ConditionResult
  operator : Comparison → Integer.Comparison
  refineKeep : Integer.Interval → Integer.Comparison → Int → Bool → Integer.Interval
  bareTarget : Source → Native.Context → Nat → Nat → Nat
  refinedFlow : ActiveFlow → Nat → Integer.Comparison → Int → Bool → ActiveFlow
  scalarCondition : Source → Native.Context → Nat → Nat → ActiveFlow →
    ScalarExpression.Result → ScalarExpression.Result → Comparison → ConditionResult

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

/-- The native nested Values delta is a one-cell storage update. Its finite
projection is proved below before the typed evaluator uses ActiveFlow.replace. -/
def storageReplace (facts : ActiveFlow.Storage) (index : Nat) (bounds : Integer.Interval) : ActiveFlow.Storage :=
  {facts with values := fun key => if key = index then bounds else facts.values key}

theorem storageReplace_active (facts : ActiveFlow.Storage) (index : Nat) (bounds : Integer.Interval)
    (positive : 0 < index) (_bounded : index ≤ facts.count) :
    (storageReplace facts index bounds).active = facts.active.replace index bounds := by
  apply FlowSourceBridge.activeFlow_ext
  · simp only [storageReplace, ActiveFlow.Storage.active, ActiveFlow.replace,
      show index ≠ 0 by omega, ↓reduceIte]
  · apply List.ext_getElem
    · simp only [storageReplace, ActiveFlow.Storage.active, ActiveFlow.replace,
        show index ≠ 0 by omega, ↓reduceIte, List.length_ofFn, List.length_set]
    · intro other leftBound rightBound
      have equivalent : (index - 1 = other) ↔ (other + 1 = index) := by omega
      simp only [storageReplace, ActiveFlow.Storage.active, ActiveFlow.replace,
        show index ≠ 0 by omega, ↓reduceIte, List.getElem_ofFn, List.getElem_set, equivalent]

inductive Expr : Ty → Type
  | variable (name : String) : Expr ty
  | number (value : Nat) : Expr .number
  | truth (value : Bool) : Expr .truth
  | scalarComparison (value : Integer.Comparison) : Expr .scalarComparison
  | names : Expr .context → Expr .names
  | declarations : Expr .context → Expr .number
  | bindingAt : Expr .names → Expr .number → Expr .binding
  | mutable : Expr .binding → Expr .truth
  | lower : Expr .interval → Expr .value
  | upper : Expr .interval → Expr .value
  | resultBounds : Expr .result → Expr .interval
  | resultAfter : Expr .result → Expr .number
  | resultStatic : Expr .result → Expr .truth
  | count : Expr .flow → Expr .number
  | cell : Expr .flow → Expr .number → Expr .interval
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | valueEq : Expr .value → Expr .value → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | ite : Expr .truth → Expr ty → Expr ty → Expr ty
  | elsif : Expr .truth → Expr ty → Expr ty → Expr ty
  | group : Expr ty → Expr ty
  | local (name : String) (typeName : List String) : Expr a → Expr b → Expr b
  | locals : Expr ty → Expr ty
  | operatorCase : Expr .comparison → Expr .scalarComparison → Expr .scalarComparison →
      Expr .scalarComparison → Expr .scalarComparison → Expr .scalarComparison →
      Expr .scalarComparison → Expr .scalarComparison
  | emptyPath : Expr .flow → Expr .flow
  | replace : Expr .flow → Expr .number → Expr .interval → Expr .flow
  | condition : Expr .number → Expr .number → Expr .flow → Expr .flow → Expr .condition
  | skip : Expr .text → Expr .number → Expr .number
  | nameAfter : Expr .text → Expr .number → Expr .number
  | lookup : Expr .text → Expr .names → Expr .number → Expr .number → Expr .number
  | scalarRefine : Expr .interval → Expr .scalarComparison → Expr .value → Expr .truth → Expr .interval
  | scalarEmpty : Expr .interval → Expr .truth
  | scalarSwap : Expr .scalarComparison → Expr .scalarComparison
  | scalarOperator : Expr .comparison → Expr .scalarComparison
  | refineKeep : Expr .interval → Expr .scalarComparison → Expr .value → Expr .truth → Expr .interval
  | bareTarget : Expr .text → Expr .context → Expr .number → Expr .number → Expr .number
  | refinedFlow : Expr .flow → Expr .number → Expr .scalarComparison → Expr .value → Expr .truth → Expr .flow

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .variable name => locals _ name
  | .number value => value | .truth value => value | .scalarComparison value => value
  | .names context => (context.eval calls locals).scalarNames
  | .declarations context => (context.eval calls locals).declarationCount
  | .bindingAt environment index => ScalarExpression.binding (environment.eval calls locals) (index.eval calls locals)
  | .mutable item => (item.eval calls locals).mutable
  | .lower bounds => (bounds.eval calls locals).lower
  | .upper bounds => (bounds.eval calls locals).upper
  | .resultBounds result => (result.eval calls locals).bounds
  | .resultAfter result => (result.eval calls locals).after
  | .resultStatic result => (result.eval calls locals).isStatic
  | .count facts => (facts.eval calls locals).count
  | .cell facts index => (facts.eval calls locals).values.getD (index.eval calls locals - 1) Integer.Interval.empty
  | .eq first second => decide (first.eval calls locals = second.eval calls locals)
  | .ne first second => decide (first.eval calls locals ≠ second.eval calls locals)
  | .gt first second => decide (first.eval calls locals > second.eval calls locals)
  | .valueEq first second => decide (first.eval calls locals = second.eval calls locals)
  | .andThen first second => first.eval calls locals && second.eval calls locals
  | .orElse first second => first.eval calls locals || second.eval calls locals
  | .ite testExpr yes no | .elsif testExpr yes no => if testExpr.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .group value | .locals value => value.eval calls locals
  | .local name _ value rest => rest.eval calls (locals.set _ name (value.eval calls locals))
  | .operatorCase operator equal unequal less lessEqual greater greaterEqual =>
      match operator.eval calls locals with
      | .eq => equal.eval calls locals | .ne => unequal.eval calls locals
      | .lt => less.eval calls locals | .le => lessEqual.eval calls locals
      | .gt => greater.eval calls locals | .ge => greaterEqual.eval calls locals
  | .emptyPath facts => {facts.eval calls locals with path := PathFacts.Context.empty}
  | .replace facts index bounds => (facts.eval calls locals).replace (index.eval calls locals) (bounds.eval calls locals)
  | .condition _ after yes no => ⟨after.eval calls locals, yes.eval calls locals, no.eval calls locals⟩
  | .skip text position => calls.skip (text.eval calls locals) (position.eval calls locals)
  | .nameAfter text position => calls.nameAfter (text.eval calls locals) (position.eval calls locals)
  | .lookup text environment first after => calls.lookup (text.eval calls locals) (environment.eval calls locals)
      (first.eval calls locals) (after.eval calls locals)
  | .scalarRefine bounds operator threshold outcome => calls.scalars .refine (bounds.eval calls locals)
      (operator.eval calls locals) (threshold.eval calls locals) (outcome.eval calls locals)
  | .scalarEmpty bounds => calls.scalars .isEmpty (bounds.eval calls locals)
  | .scalarSwap operator => calls.scalars .swap (operator.eval calls locals)
  | .scalarOperator operator => calls.operator (operator.eval calls locals)
  | .refineKeep bounds operator threshold outcome => calls.refineKeep (bounds.eval calls locals)
      (operator.eval calls locals) (threshold.eval calls locals) (outcome.eval calls locals)
  | .bareTarget text context position after => calls.bareTarget (text.eval calls locals) (context.eval calls locals)
      (position.eval calls locals) (after.eval calls locals)
  | .refinedFlow facts index operator threshold outcome => calls.refinedFlow (facts.eval calls locals)
      (index.eval calls locals) (operator.eval calls locals) (threshold.eval calls locals) (outcome.eval calls locals)

/-- The separate discriminant interpretation is mandatory for every returned
condition aggregate. It checks the actual Count expression, not just equality
of the two projected output lengths. Declaration wrappers retain their values. -/
def Expr.Sized (calls : Calls) (locals : Locals) : Expr .condition → Prop
  | .variable name =>
      (locals .condition name).whenTrue.count ≤ ScalarExpression.maxBindings ∧
      (locals .condition name).whenFalse.count = (locals .condition name).whenTrue.count
  | .condition size _ yes no => size.eval calls locals ≤ ScalarExpression.maxBindings ∧
      (yes.eval calls locals).count = size.eval calls locals ∧
      (no.eval calls locals).count = size.eval calls locals
  | .ite testExpr yes no | .elsif testExpr yes no =>
      if testExpr.eval calls locals then yes.Sized calls locals else no.Sized calls locals
  | .group body | .locals body => body.Sized calls locals
  | .local name _ value rest => rest.Sized calls (locals.set _ name (value.eval calls locals))

def callTokens (name : List String) (arguments : List (List String)) : List String :=
  name ++ ["("] ++ List.flatten (List.intersperse [","] arguments) ++ [")"]

def Expr.render : Expr ty → List String
  | .variable name => [name]
  | .number value => [toString value] | .truth value => [if value then "true" else "false"]
  | .scalarComparison value => ["scalars", ".", Integer.Native.comparisonName value]
  | .names context => context.render ++ [".", "scalar_names"]
  | .declarations context => context.render ++ [".", "declaration_count"]
  | .bindingAt environment index => environment.render ++ [".", "items", "("] ++ index.render ++ [")"]
  | .mutable item => item.render ++ [".", "mutable"]
  | .lower bounds => bounds.render ++ [".", "lower"]
  | .upper bounds => bounds.render ++ [".", "upper"]
  | .resultBounds result => result.render ++ [".", "bounds"]
  | .resultAfter result => result.render ++ [".", "after"]
  | .resultStatic result => result.render ++ [".", "static"]
  | .count facts => facts.render ++ [".", "count"]
  | .cell facts index => facts.render ++ [".", "values", "("] ++ index.render ++ [")"]
  | .eq first second | .valueEq first second => first.render ++ ["="] ++ second.render
  | .ne first second => first.render ++ ["/="] ++ second.render
  | .gt first second => first.render ++ [">"] ++ second.render
  | .andThen first second => first.render ++ ["and", "then"] ++ second.render
  | .orElse first second => first.render ++ ["or", "else"] ++ second.render
  | .ite testExpr yes no => ["if"] ++ testExpr.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif testExpr yes no => ["elsif"] ++ testExpr.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .group value => ["("] ++ value.render ++ [")"]
  | .local name typeName value rest => [name, ":", "constant"] ++ typeName ++ [":="] ++ value.render ++ [";"] ++
      (match rest with | .local _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .operatorCase operator equal unequal less lessEqual greater greaterEqual =>
      ["case"] ++ operator.render ++ ["is", "when", "paths", ".", "equal", "=>"] ++ equal.render ++
      [",", "when", "paths", ".", "unequal", "=>"] ++ unequal.render ++
      [",", "when", "paths", ".", "less", "=>"] ++ less.render ++
      [",", "when", "paths", ".", "less_equal", "=>"] ++ lessEqual.render ++
      [",", "when", "paths", ".", "greater", "=>"] ++ greater.render ++
      [",", "when", "paths", ".", "greater_equal", "=>"] ++ greaterEqual.render
  | .emptyPath facts => ["("] ++ facts.render ++ expectedTokens "with delta Path => Paths.Empty_Context)"
  | .replace facts index bounds => ["("] ++ facts.render ++ expectedTokens "with delta Values => (" ++
      facts.render ++ [".", "values", "with", "delta"] ++ index.render ++ ["=>"] ++ bounds.render ++ [")", ")"]
  | .condition size after yes no => ["(", "count", "=>"] ++ size.render ++ [",", "after", "=>"] ++ after.render ++
      [",", "when_true", "=>"] ++ yes.render ++ [",", "when_false", "=>"] ++ no.render ++ [")"]
  | .skip text position => callTokens ["skip_at"] [text.render, position.render]
  | .nameAfter text position => callTokens ["name_after"] [text.render, position.render]
  | .lookup text environment first after => callTokens ["scalar_expressions", ".", "lookup"]
      [text.render, environment.render, first.render, after.render]
  | .scalarRefine bounds operator threshold outcome => callTokens ["scalars", ".", "refine"]
      [bounds.render, operator.render, threshold.render, outcome.render]
  | .scalarEmpty bounds => callTokens ["scalars", ".", "is_empty"] [bounds.render]
  | .scalarSwap operator => callTokens ["scalars", ".", "swap"] [operator.render]
  | .scalarOperator operator => callTokens ["scalar_operator"] [operator.render]
  | .refineKeep bounds operator threshold outcome => callTokens ["refine_or_keep"]
      [bounds.render, operator.render, threshold.render, outcome.render]
  | .bareTarget text context position after => callTokens ["bare_target"]
      [text.render, context.render, position.render, after.render]
  | .refinedFlow facts index operator threshold outcome => callTokens ["refined_flow"]
      [facts.render, index.render, operator.render, threshold.render, outcome.render]

def invalidBody : Expr .condition :=
  let facts : Expr .flow := .variable "facts"
  .condition (.count facts) (.number 0) (.emptyPath facts) (.emptyPath facts)

def operatorBody : Expr .scalarComparison :=
  .operatorCase (.variable "operator") (.scalarComparison .eq) (.scalarComparison .ne)
    (.scalarComparison .lt) (.scalarComparison .le) (.scalarComparison .gt) (.scalarComparison .ge)

def refineKeepBody : Expr .interval :=
  let refined : Expr .interval := .variable "refined"
  let bounds : Expr .interval := .variable "bounds"
  .locals <| .local "refined" ["scalars", ".", "interval"]
    (.scalarRefine bounds (.variable "operator") (.variable "threshold") (.variable "truth"))
    (.group (.ite (.scalarEmpty refined) bounds refined))

def bareTargetBody : Expr .number :=
  let text : Expr .text := .variable "text"
  let context : Expr .context := .variable "context"
  let first : Expr .number := .variable "first"
  let last : Expr .number := .variable "last"
  let index : Expr .number := .variable "index"
  .locals <| .local "first" ["literal_position"] (.skip text (.variable "position")) <|
    .local "last" ["literal_position"] (.nameAfter text first) <|
    .local "index" ["scalar_expressions", ".", "binding_count"] (.lookup text (.names context) first last) <|
    .group <| .ite (.andThen (.ne index (.number 0))
      (.andThen (.eq last (.variable "after"))
        (.group (.orElse (.mutable (.bindingAt (.names context) index)) (.gt index (.declarations context))))))
      index (.number 0)

def refinedFlowBody : Expr .flow :=
  let facts : Expr .flow := .variable "facts"
  let index : Expr .number := .variable "index"
  .ite (.eq index (.number 0)) facts (.replace facts index
    (.refineKeep (.cell facts index) (.variable "operator") (.variable "threshold") (.variable "truth")))

def scalarConditionBody : Expr .condition :=
  let text : Expr .text := .variable "text"
  let context : Expr .context := .variable "context"
  let facts : Expr .flow := .variable "facts"
  let left : Expr .result := .variable "left"
  let right : Expr .result := .variable "right"
  let leftTarget : Expr .number := .variable "left_target"
  let rightTarget : Expr .number := .variable "right_target"
  let target : Expr .number := .variable "target"
  let selected : Expr .scalarComparison := .variable "selected"
  let threshold : Expr .value := .variable "threshold"
  let convert : Expr .scalarComparison := .scalarOperator (.variable "operator")
  let candidate (index : Expr .number) (value : Expr .result) : Expr .truth :=
    .andThen (.ne index (.number 0)) (.andThen (.resultStatic value)
      (.valueEq (.lower (.resultBounds value)) (.upper (.resultBounds value))))
  .locals <| .local "left_target" ["scalar_expressions", ".", "binding_count"]
    (.bareTarget text context (.variable "position") (.resultAfter left)) <|
    .local "right_target" ["scalar_expressions", ".", "binding_count"]
      (.bareTarget text context (.variable "right_position") (.resultAfter right)) <|
    .local "target" ["scalar_expressions", ".", "binding_count"]
      (.group (.ite (candidate leftTarget right) leftTarget
        (.elsif (candidate rightTarget left) rightTarget (.number 0)))) <|
    .local "selected" ["scalars", ".", "comparison"]
      (.group (.ite (candidate leftTarget right) convert (.scalarSwap convert))) <|
    .local "threshold" ["scalars", ".", "value"]
      (.group (.ite (candidate leftTarget right) (.lower (.resultBounds right)) (.lower (.resultBounds left)))) <|
    .condition (.count facts) (.resultAfter right)
      (.refinedFlow facts target selected threshold (.truth true))
      (.refinedFlow facts target selected threshold (.truth false))

structure Inputs where
  text : Source := []
  context : Native.Context := ⟨[], 0, 0, [], 0, []⟩
  facts : ActiveFlow := ⟨PathFacts.Context.empty, []⟩
  position : Nat := 0
  rightPosition : Nat := 0
  after : Nat := 0
  index : Nat := 0
  left : ScalarExpression.Result := ScalarExpression.invalid
  right : ScalarExpression.Result := ScalarExpression.invalid
  operator : Comparison := .eq
  scalarOperator : Integer.Comparison := .eq
  bounds : Integer.Interval := Integer.Interval.empty
  threshold : Int := 0
  truth : Bool := false

def Inputs.locals (inputs : Inputs) : Locals
  | .text, "text" => inputs.text
  | .context, "context" => inputs.context
  | .flow, "facts" => inputs.facts
  | .number, "position" => inputs.position
  | .number, "right_position" => inputs.rightPosition
  | .number, "after" => inputs.after
  | .number, "index" => inputs.index
  | .result, "left" => inputs.left
  | .result, "right" => inputs.right
  | .comparison, "operator" => inputs.operator
  | .scalarComparison, "operator" => inputs.scalarOperator
  | .interval, "bounds" => inputs.bounds
  | .value, "threshold" => inputs.threshold
  | .truth, "truth" => inputs.truth
  | ty, _ => ty.default

def refineKeepEquation (calls : Calls) (bounds : Integer.Interval) (operator : Integer.Comparison)
    (threshold : Int) (truth : Bool) : Integer.Interval :=
  let refined := calls.scalars .refine bounds operator threshold truth
  if calls.scalars .isEmpty refined then bounds else refined

def bareTargetEquation (calls : Calls) (text : Source) (context : Native.Context) (position after : Nat) : Nat :=
  let first := calls.skip text position
  let last := calls.nameAfter text first
  let index := calls.lookup text context.scalarNames first last
  if decide (index ≠ 0) && (decide (last = after) &&
      ((ScalarExpression.binding context.scalarNames index).mutable || decide (index > context.declarationCount)))
  then index else 0

def refinedFlowEquation (calls : Calls) (facts : ActiveFlow) (index : Nat)
    (operator : Integer.Comparison) (threshold : Int) (truth : Bool) : ActiveFlow :=
  if index = 0 then facts else
    facts.replace index (calls.refineKeep (facts.values.getD (index - 1) Integer.Interval.empty) operator threshold truth)

def scalarConditionEquation (calls : Calls) (text : Source) (context : Native.Context)
    (position rightPosition : Nat) (facts : ActiveFlow) (left right : ScalarExpression.Result)
    (operator : Comparison) : ConditionResult :=
  let leftTarget := calls.bareTarget text context position left.after
  let rightTarget := calls.bareTarget text context rightPosition right.after
  let target := if decide (leftTarget ≠ 0) && (right.isStatic && decide (right.bounds.lower = right.bounds.upper))
      then leftTarget
    else if decide (rightTarget ≠ 0) && (left.isStatic && decide (left.bounds.lower = left.bounds.upper))
      then rightTarget else 0
  let selected := if decide (leftTarget ≠ 0) && (right.isStatic && decide (right.bounds.lower = right.bounds.upper))
    then calls.operator operator else calls.scalars .swap (calls.operator operator)
  let threshold := if decide (leftTarget ≠ 0) && (right.isStatic && decide (right.bounds.lower = right.bounds.upper))
    then right.bounds.lower else left.bounds.lower
  ⟨right.after, calls.refinedFlow facts target selected threshold true,
    calls.refinedFlow facts target selected threshold false⟩

theorem invalid_denotation (calls : Calls) (facts : ActiveFlow) :
    invalidBody.eval calls ({facts} : Inputs).locals = Predicate.invalidCondition facts := rfl

theorem operator_denotation (calls : Calls) (operator : Comparison) :
    operatorBody.eval calls ({operator} : Inputs).locals = operator.toInteger := by cases operator <;> rfl

theorem refineKeep_denotation (calls : Calls) (bounds : Integer.Interval) (operator : Integer.Comparison)
    (threshold : Int) (truth : Bool) :
    refineKeepBody.eval calls ({bounds, scalarOperator := operator, threshold, truth} : Inputs).locals =
      refineKeepEquation calls bounds operator threshold truth := rfl

theorem bareTarget_denotation (calls : Calls) (text : Source) (context : Native.Context) (position after : Nat) :
    bareTargetBody.eval calls ({text, context, position, after} : Inputs).locals =
      bareTargetEquation calls text context position after := rfl

theorem refinedFlow_denotation (calls : Calls) (facts : ActiveFlow) (index : Nat)
    (operator : Integer.Comparison) (threshold : Int) (truth : Bool) :
    refinedFlowBody.eval calls ({facts, index, scalarOperator := operator, threshold, truth} : Inputs).locals =
      refinedFlowEquation calls facts index operator threshold truth := by
  simp only [refinedFlowBody, Expr.eval, Inputs.locals, refinedFlowEquation, decide_eq_true_eq]

theorem scalarCondition_denotation (calls : Calls) (text : Source) (context : Native.Context)
    (position rightPosition : Nat) (facts : ActiveFlow) (left right : ScalarExpression.Result)
    (operator : Comparison) :
    scalarConditionBody.eval calls ({text, context, position, rightPosition, facts, left, right, operator} : Inputs).locals =
      scalarConditionEquation calls text context position rightPosition facts left right operator := by
  simp only [scalarConditionBody, Expr.eval, Inputs.locals, Locals.set, scalarConditionEquation]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]

structure PrimitiveMeaning (calls : Calls) : Prop where
  scalars : Integer.NativeSourceBridge.InterpretedSource calls.scalars
  skip : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 → calls.skip text position = skipAt text position
  nameAfter : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.nameAfter text position = Compose.nameAfter text position
  lookup : ∀ text, ValidText text → ∀ names first after,
    ScalarExpression.ValidEnvironment text names → first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookup text names first after = ScalarExpression.lookup text names first after

structure DefinitionEquations (calls : Calls) : Prop where
  invalid : ∀ facts, facts.count ≤ ScalarExpression.maxBindings →
    calls.invalid facts = invalidBody.eval calls ({facts} : Inputs).locals
  operator : ∀ operator, calls.operator operator = operatorBody.eval calls ({operator} : Inputs).locals
  refineKeep : ∀ (bounds : Integer.Interval) operator threshold truth, bounds.Bounded → Integer.InRange threshold →
    calls.refineKeep bounds operator threshold truth =
      refineKeepBody.eval calls ({bounds, scalarOperator := operator, threshold, truth} : Inputs).locals
  bareTarget : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position after, position ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.bareTarget text context position after =
      bareTargetBody.eval calls ({text, context, position, after} : Inputs).locals
  refinedFlow : ∀ facts index, facts.count ≤ ScalarExpression.maxBindings → index ≤ facts.count →
    ∀ operator threshold truth, facts.model.scalars.Bounded → Integer.InRange threshold →
    calls.refinedFlow facts index operator threshold truth =
      refinedFlowBody.eval calls ({facts, index, scalarOperator := operator, threshold, truth} : Inputs).locals
  scalarCondition : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position rightPosition, position ≤ text.length + 1 → rightPosition ≤ text.length + 1 →
    ∀ facts, ValidFlow context facts → ∀ (left right : ScalarExpression.Result),
    left.after ≤ text.length + 1 → right.after ≤ text.length + 1 →
    ∀ operator, left.bounds.Bounded → right.bounds.Bounded →
    calls.scalarCondition text context position rightPosition facts left right operator =
      scalarConditionBody.eval calls ({text, context, position, rightPosition, facts, left, right, operator} : Inputs).locals

theorem invalid_meaning {calls : Calls} (definitions : DefinitionEquations calls) (facts : ActiveFlow)
    (capacity : facts.count ≤ ScalarExpression.maxBindings) :
    calls.invalid facts = Predicate.invalidCondition facts := by
  rw [definitions.invalid facts capacity, invalid_denotation]

theorem invalid_extents {calls : Calls} (definitions : DefinitionEquations calls) (facts : ActiveFlow)
    (capacity : facts.count ≤ ScalarExpression.maxBindings) :
    (calls.invalid facts).whenTrue.count = facts.count ∧
      (calls.invalid facts).whenFalse.count = facts.count := by
  rw [invalid_meaning definitions facts capacity]
  exact ⟨rfl, rfl⟩

theorem operator_meaning {calls : Calls} (definitions : DefinitionEquations calls) (operator : Comparison) :
    calls.operator operator = operator.toInteger := by
  rw [definitions.operator, operator_denotation]

theorem refineKeep_meaning {calls : Calls} (primitives : PrimitiveMeaning calls)
    (definitions : DefinitionEquations calls) (bounds : Integer.Interval) (operator : Integer.Comparison)
    (threshold : Int) (truth : Bool) (boundsType : bounds.Bounded) (thresholdType : Integer.InRange threshold) :
    calls.refineKeep bounds operator threshold truth = bounds.refineOrKeep operator threshold truth := by
  rw [definitions.refineKeep bounds operator threshold truth boundsType thresholdType, refineKeep_denotation]
  simp only [refineKeepEquation,
    Integer.NativeSourceBridge.interpreted_functions calls.scalars primitives.scalars .refine,
    Integer.NativeSourceBridge.interpreted_functions calls.scalars primitives.scalars .isEmpty,
    Integer.Native.Function.eval, Integer.Interval.refineOrKeep]

theorem bareTarget_meaning {calls : Calls} (primitives : PrimitiveMeaning calls)
    (definitions : DefinitionEquations calls) (text : Source) (tv : ValidText text)
    (context : Native.Context) (cv : ValidContext text context) (position after : Nat)
    (positionBound : position ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.bareTarget text context position after = Predicate.bareTarget text context.model position after := by
  rw [definitions.bareTarget text tv context cv position after positionBound afterBound, bareTarget_denotation]
  have firstBound := model_skip_valid text position positionBound
  have skipEquation := primitives.skip text tv position positionBound
  have nameEquation := primitives.nameAfter text tv _ firstBound
  have lookupEquation := primitives.lookup text tv _ _ _ cv.2.2.1 firstBound
    (model_name_valid text (skipAt text position))
  simp [bareTargetEquation, Predicate.bareTarget, Native.Context.model,
    skipEquation, nameEquation, lookupEquation]

theorem bareTarget_bound (text : Source) (context : ParseContext) (position after : Nat) :
    Predicate.bareTarget text context position after ≤ context.scalarNames.length := by
  unfold Predicate.bareTarget
  dsimp only
  split
  · exact ScalarExpression.lookup_bound ..
  · omega

theorem refine_eq_replace (facts : ActiveFlow) (index : Nat) (bounded : index ≤ facts.count)
    (operator : Integer.Comparison) (threshold : Int) (truth : Bool) :
    facts.refine index operator threshold truth =
      if index = 0 then facts else facts.replace index
        ((facts.values.getD (index - 1) Integer.Interval.empty).refineOrKeep operator threshold truth) := by
  by_cases zero : index = 0
  · simp only [zero, ActiveFlow.refine, ActiveFlow.ranges_zero, ↓reduceIte]
  · have within : index - 1 < facts.values.length := by
      change index ≤ facts.values.length at bounded
      omega
    have present : ActiveFlow.ranges facts.values index =
        some (facts.values.getD (index - 1) Integer.Interval.empty) := by
      simp only [ActiveFlow.ranges, zero, ↓reduceIte, List.getD_eq_getElem?_getD,
        List.getElem?_eq_getElem within, Option.getD_some]
    simp only [ActiveFlow.refine, present, zero, ↓reduceIte]

theorem refinedFlow_meaning {calls : Calls} (primitives : PrimitiveMeaning calls)
    (definitions : DefinitionEquations calls) (facts : ActiveFlow) (index : Nat)
    (capacity : facts.count ≤ ScalarExpression.maxBindings) (bounded : index ≤ facts.count)
    (operator : Integer.Comparison) (threshold : Int) (truth : Bool)
    (scalarTypes : facts.model.scalars.Bounded) (thresholdType : Integer.InRange threshold) :
    calls.refinedFlow facts index operator threshold truth = facts.refine index operator threshold truth := by
  rw [definitions.refinedFlow facts index capacity bounded operator threshold truth scalarTypes thresholdType,
    refinedFlow_denotation,
    refine_eq_replace facts index bounded]
  unfold refinedFlowEquation
  by_cases zero : index = 0
  · simp only [zero, ↓reduceIte]
  · have within : index - 1 < facts.values.length := by
      change index ≤ facts.values.length at bounded
      omega
    have present : facts.model.scalars index =
        some (facts.values.getD (index - 1) Integer.Interval.empty) := by
      simp only [ActiveFlow.model, ActiveFlow.ranges, zero, ↓reduceIte,
        List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
    simp only [zero, ↓reduceIte,
      refineKeep_meaning primitives definitions _ operator threshold truth (scalarTypes index _ present) thresholdType]

theorem scalarCondition_meaning {calls : Calls} (primitives : PrimitiveMeaning calls)
    (definitions : DefinitionEquations calls) (text : Source) (tv : ValidText text)
    (context : Native.Context) (cv : ValidContext text context) (position rightPosition : Nat)
    (positionBound : position ≤ text.length + 1) (rightBound : rightPosition ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (left right : ScalarExpression.Result)
    (leftAfter : left.after ≤ text.length + 1) (rightAfter : right.after ≤ text.length + 1)
    (operator : Comparison) (leftType : left.bounds.Bounded) (rightType : right.bounds.Bounded) :
    calls.scalarCondition text context position rightPosition facts left right operator =
      Predicate.scalarCondition text context.model position rightPosition facts left right operator := by
  rw [definitions.scalarCondition text tv context cv position rightPosition positionBound rightBound
    facts fv left right leftAfter rightAfter operator leftType rightType, scalarCondition_denotation]
  unfold scalarConditionEquation
  rw [bareTarget_meaning primitives definitions text tv context cv position left.after positionBound leftAfter,
    bareTarget_meaning primitives definitions text tv context cv rightPosition right.after rightBound rightAfter]
  simp only [Bool.and_eq_true, decide_eq_true_eq, operator_meaning definitions,
    Integer.NativeSourceBridge.interpreted_functions calls.scalars primitives.scalars .swap, Integer.Native.Function.eval]
  let target := if Predicate.bareTarget text context.model position left.after ≠ 0 ∧
        right.isStatic = true ∧ right.bounds.lower = right.bounds.upper
      then Predicate.bareTarget text context.model position left.after
    else if Predicate.bareTarget text context.model rightPosition right.after ≠ 0 ∧
        left.isStatic = true ∧ left.bounds.lower = left.bounds.upper
      then Predicate.bareTarget text context.model rightPosition right.after else 0
  have targetBound : target ≤ facts.count := by
    have count := fv.2.compatible.count
    have leftBound := bareTarget_bound text context.model position left.after
    have rightTargetBound := bareTarget_bound text context.model rightPosition right.after
    change _ ≤ context.scalarNames.length at leftBound rightTargetBound
    dsimp only [target]
    split
    · omega
    · split <;> omega
  let threshold := if Predicate.bareTarget text context.model position left.after ≠ 0 ∧
      right.isStatic = true ∧ right.bounds.lower = right.bounds.upper
    then right.bounds.lower else left.bounds.lower
  have thresholdType : Integer.InRange threshold := by
    dsimp only [threshold]
    split
    · exact rightType.1
    · exact leftType.1
  have refined : ∀ selected truth,
      calls.refinedFlow facts target selected threshold truth = facts.refine target selected threshold truth :=
    fun selected truth => refinedFlow_meaning primitives definitions facts target
      (by rw [fv.2.compatible.count]; exact cv.2.2.1.1) targetBound selected threshold truth fv.2.bounded thresholdType
  change ConditionResult.mk _ (calls.refinedFlow facts target _ threshold true)
    (calls.refinedFlow facts target _ threshold false) = _
  rw [refined, refined]
  rfl

theorem scalarCondition_model_extents (text : Source) (context : ParseContext)
    (position rightPosition : Nat) (facts : ActiveFlow) (left right : ScalarExpression.Result)
    (operator : Comparison) :
    (Predicate.scalarCondition text context position rightPosition facts left right operator).whenTrue.count = facts.count ∧
      (Predicate.scalarCondition text context position rightPosition facts left right operator).whenFalse.count = facts.count := by
  simp only [Predicate.scalarCondition, ActiveFlow.refine_count, and_self]

theorem scalarCondition_sized_iff (calls : Calls) (text : Source) (context : Native.Context)
    (position rightPosition : Nat) (facts : ActiveFlow) (left right : ScalarExpression.Result)
    (operator : Comparison) :
    scalarConditionBody.Sized calls ({text, context, position, rightPosition, facts, left, right, operator} : Inputs).locals ↔
      facts.count ≤ ScalarExpression.maxBindings ∧
      (scalarConditionBody.eval calls ({text, context, position, rightPosition, facts, left, right, operator} : Inputs).locals).whenTrue.count = facts.count ∧
      (scalarConditionBody.eval calls ({text, context, position, rightPosition, facts, left, right, operator} : Inputs).locals).whenFalse.count = facts.count := by
  simp only [scalarConditionBody, Expr.Sized, Expr.eval, Inputs.locals, Locals.set]
  simp only [reduceCtorEq, String.reduceEq, ↓reduceIte, ↓reduceDIte]

structure SizedModels (calls : Calls) : Prop where
  invalid : ∀ facts, facts.count ≤ ScalarExpression.maxBindings →
    invalidBody.Sized calls ({facts} : Inputs).locals
  scalarCondition : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position rightPosition, position ≤ text.length + 1 → rightPosition ≤ text.length + 1 →
    ∀ facts, ValidFlow context facts → ∀ (left right : ScalarExpression.Result),
    left.after ≤ text.length + 1 → right.after ≤ text.length + 1 →
    ∀ operator, left.bounds.Bounded → right.bounds.Bounded →
    scalarConditionBody.Sized calls ({text, context, position, rightPosition, facts, left, right, operator} : Inputs).locals

theorem interpreted_sized {calls : Calls} (primitives : PrimitiveMeaning calls)
    (definitions : DefinitionEquations calls) : SizedModels calls where
  invalid facts capacity := by
    simpa [invalidBody, Expr.Sized, Expr.eval, Inputs.locals, ActiveFlow.count] using capacity
  scalarCondition text tv context cv position rightPosition positionBound rightBound
      facts fv left right leftAfter rightAfter operator leftType rightType := by
    rw [scalarCondition_sized_iff]
    refine ⟨by rw [fv.2.compatible.count]; exact cv.2.2.1.1, ?_⟩
    rw [← definitions.scalarCondition text tv context cv position rightPosition positionBound rightBound
      facts fv left right leftAfter rightAfter operator leftType rightType,
      scalarCondition_meaning primitives definitions text tv context cv position rightPosition positionBound rightBound
        facts fv left right leftAfter rightAfter operator leftType rightType]
    exact scalarCondition_model_extents text context.model position rightPosition facts left right operator

def modelCalls : Calls where
  scalars := Integer.Native.Function.eval
  skip := skipAt
  nameAfter := Compose.nameAfter
  lookup := ScalarExpression.lookup
  invalid := Predicate.invalidCondition
  operator := Comparison.toInteger
  refineKeep := Integer.Interval.refineOrKeep
  bareTarget := fun text context position after => Predicate.bareTarget text context.model position after
  refinedFlow := ActiveFlow.refine
  scalarCondition := fun text context position rightPosition facts left right operator =>
    Predicate.scalarCondition text context.model position rightPosition facts left right operator

theorem model_primitives : PrimitiveMeaning modelCalls where
  scalars := Integer.NativeSourceBridge.model_interpreted
  skip _ _ _ _ := rfl
  nameAfter _ _ _ _ := rfl
  lookup _ _ _ _ _ _ _ _ := rfl

theorem model_equations : DefinitionEquations modelCalls where
  invalid facts _ := (invalid_denotation modelCalls facts).symm
  operator operator := (operator_denotation modelCalls operator).symm
  refineKeep bounds operator threshold truth _ _ := by
    rw [refineKeep_denotation]
    rfl
  bareTarget text _ context _ position after _ _ := by
    rw [bareTarget_denotation]
    simp [bareTargetEquation, modelCalls, Predicate.bareTarget, Native.Context.model]
  refinedFlow facts index _ bounded operator threshold truth _ _ := by
    rw [refinedFlow_denotation]
    exact refine_eq_replace facts index bounded operator threshold truth
  scalarCondition text _ context _ position rightPosition _ _ facts _ left right _ _ operator _ _ := by
    rw [scalarCondition_denotation]
    simp [scalarConditionEquation, modelCalls, Predicate.scalarCondition, Integer.Native.Function.eval]

theorem model_sized : SizedModels modelCalls := interpreted_sized model_primitives model_equations

structure Checked (tokens : List String) : Prop where
  invalid : expressionDeclaration "invalid_condition" tokens =
    some (invalidBody.render.tail.dropLast, expectedTokens "with Ghost => Static")
  invalidHeader : functionHeader "invalid_condition" "is" tokens =
    some (expectedTokens "(Facts : Scalar_Flow) return Condition_Result")
  operator : expressionDeclaration "scalar_operator" tokens = some (operatorBody.render, [])
  operatorHeader : functionHeader "scalar_operator" "is" tokens =
    some (expectedTokens "(Operator : Paths.Comparison) return Scalars.Comparison")
  refineKeep : expressionDeclaration "refine_or_keep" tokens = some (refineKeepBody.render,
    expectedTokens "with Post => (Static => Included (Refine_Or_Keep'Result, Bounds) and then (Scalars.Is_Empty (Refine_Or_Keep'Result) = Scalars.Is_Empty (Bounds)))")
  refineKeepHeader : functionHeader "refine_or_keep" "is" tokens =
    some (expectedTokens "(Bounds : Scalars.Interval; Operator : Scalars.Comparison; Threshold : Scalars.Value; Truth : Boolean) return Scalars.Interval")
  bareTarget : expressionDeclaration "bare_target" tokens = some (bareTargetBody.render, [])
  bareTargetHeader : functionHeader "bare_target" ";" tokens = some (expectedTokens
    "(Text : String; Context : Body_Context; Position, After : Literal_Position) return Scalar_Expressions.Binding_Count with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Position <= Text'Last + 1 and then After <= Text'Last + 1, Post => Bare_Target'Result <= Context.Scalar_Names.Count and then (Bare_Target'Result = 0 or else Context.Scalar_Names.Items (Bare_Target'Result).Mutable or else Bare_Target'Result > Context.Declaration_Count)")
  refinedFlow : expressionDeclaration "refined_flow" tokens =
    some (refinedFlowBody.render, expectedTokens "with Ghost => Static, Pre => Index <= Facts.Count")
  refinedFlowHeader : functionHeader "refined_flow" "is" tokens = some (expectedTokens
    "(Facts : Scalar_Flow; Index : Scalar_Expressions.Binding_Count; Operator : Scalars.Comparison; Threshold : Scalars.Value; Truth : Boolean) return Scalar_Flow")
  scalarCondition : expressionDeclaration "scalar_condition" tokens = some (scalarConditionBody.render, [])
  scalarConditionHeader : functionHeader "scalar_condition" ";" tokens = some (expectedTokens
    "(Text : String; Context : Body_Context; Position, Right_Position : Literal_Position; Facts : Scalar_Flow; Left, Right : Scalar_Expressions.Expression_Result; Operator : Paths.Comparison) return Condition_Result with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Position <= Text'Last + 1 and then Right_Position <= Text'Last + 1 and then Left.After <= Text'Last + 1 and then Right.After <= Text'Last + 1")
  conditionType : Lexical.SourceBridge.discriminatedRecordDeclaration "condition_result" tokens = some (expectedTokens
    "(Count : Scalar_Expressions.Binding_Count) is record After : Literal_Position; When_True, When_False : Scalar_Flow (Count); end record")

theorem checked_correspondence (tokens : List String) (checked : Checked tokens)
    (calls : Calls) (primitives : PrimitiveMeaning calls) (definitions : DefinitionEquations calls) :
    Checked tokens ∧ SizedModels calls ∧
    (∀ facts, facts.count ≤ ScalarExpression.maxBindings → calls.invalid facts = Predicate.invalidCondition facts) ∧
    (∀ text, ValidText text → ∀ context, ValidContext text context →
      ∀ position rightPosition, position ≤ text.length + 1 → rightPosition ≤ text.length + 1 →
      ∀ facts, ValidFlow context facts → ∀ (left right : ScalarExpression.Result),
      left.after ≤ text.length + 1 → right.after ≤ text.length + 1 →
      ∀ operator, left.bounds.Bounded → right.bounds.Bounded →
      calls.scalarCondition text context position rightPosition facts left right operator =
        Predicate.scalarCondition text context.model position rightPosition facts left right operator) :=
  ⟨checked, interpreted_sized primitives definitions, invalid_meaning definitions,
    scalarCondition_meaning primitives definitions⟩

end Silver.Predicate.Native.ScalarHelpers

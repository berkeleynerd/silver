module

public import Silver.ComposeGrammar
public import Silver.PredicateChecking
public import Silver.IntegerLiteral
public import Silver.PredicateFlowOverlay
public import Silver.PredicateArrayFlow

@[expose] public section

/-! Scalar predicate scanner. Short-circuit chains are accumulated from left to
right, and each right relation receives exactly the path context in which it is
reached. Source readings recover the expression payloads independently. -/

namespace Silver.Predicate
open Compose Bindings PathFacts

structure ParseContext where
  names : Compose.BindingEnvironment
  hasArguments : Bool
  scalarNames : ScalarExpression.Environment := []
  declarationCount : Nat := 0
  arrayNames : ArrayBindings.Metadata := []
  deriving Repr

def ParseContext.analysis (context : ParseContext) : Integer.Analysis :=
  ArrayFlow.analysis context.arrayNames (ScalarMetadata.analysis context.scalarNames context.declarationCount)

def ParseContext.flow (context : ParseContext) (facts : ActiveFlow) : Flow :=
  ArrayFlow.flow context.arrayNames facts

def ParseContext.readingNames (context : ParseContext) (facts : ActiveFlow) : ScalarExpression.Environment :=
  ScalarMetadata.readingNames context.scalarNames context.declarationCount facts

def ParseContext.ArraysReady (context : ParseContext) (text : Source) : Prop :=
  ArrayBindings.ValidMetadata text context.arrayNames ∧
    context.arrayNames.Pairwise (fun left right => left.offset + left.length ≤ right.offset)

theorem ParseContext.reading_ranges {context : ParseContext} {facts : ActiveFlow}
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts) :
    ArrayBindings.ranges context.arrayNames [] false (ScalarExpression.ranges (context.readingNames facts)) =
      (context.flow facts).scalars := by
  unfold ParseContext.readingNames
  rw [ScalarMetadata.readingNames_ranges compatible]
  rfl

@[simp] theorem ParseContext.flow_path (context : ParseContext) (facts : ActiveFlow) :
    (context.flow facts).path = facts.path := rfl

theorem ParseContext.flow_scalar (context : ParseContext) (facts : ActiveFlow)
    {index : Nat} (low : index ≤ ArrayBindings.scalarLimit) :
    (context.flow facts).scalars index = facts.model.scalars index :=
  ArrayFlow.ranges_scalar context.arrayNames facts.model.scalars low

theorem ParseContext.flow_join (context : ParseContext) (left right : ActiveFlow) :
    context.flow (left.join right) = (context.flow left).join (context.flow right) :=
  ArrayFlow.flow_join context.arrayNames left right

theorem ParseContext.flow_refine (context : ParseContext) (facts : ActiveFlow)
    (index : Nat) (operator : Integer.Comparison) (threshold : Int) (truth : Bool)
    (low : index ≤ ArrayBindings.scalarLimit) :
    context.flow (facts.refine index operator threshold truth) =
      ⟨facts.path, (context.flow facts).scalars.refineName index operator threshold truth⟩ :=
  ArrayFlow.flow_refine context.arrayNames facts index operator threshold truth low

@[simp] theorem ParseContext.flow_withPath (context : ParseContext) (facts : ActiveFlow)
    (path : Context) : context.flow {facts with path} = {context.flow facts with path} := rfl

def readScalarInFlow (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (maskFirst maskAfter : Nat := 0) : ScalarExpression.Result :=
  ScalarExpression.read text position (context.readingNames facts) maskFirst maskAfter (arrays := context.arrayNames)

def readStringInFlow (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
    ExpressionResult := expressionAt text position context.names (context.readingNames facts) (arrays := context.arrayNames)

def Comparison.toInteger : Comparison → Integer.Comparison
  | .eq => .eq | .ne => .ne | .lt => .lt | .le => .le | .gt => .gt | .ge => .ge

structure ComparisonResult where
  after : Nat
  operator : Comparison
  deriving DecidableEq, Repr

def comparisonAt (text : Source) (position : Nat) : ComparisonResult :=
  if fixedAfter text position "/=" false ≠ 0 then ⟨fixedAfter text position "/=" false, .ne⟩
  else if fixedAfter text position "<=" false ≠ 0 then ⟨fixedAfter text position "<=" false, .le⟩
  else if fixedAfter text position ">=" false ≠ 0 then ⟨fixedAfter text position ">=" false, .ge⟩
  else if fixedAfter text position "=" false ≠ 0 then ⟨fixedAfter text position "=" false, .eq⟩
  else if fixedAfter text position "<" false ≠ 0 then ⟨fixedAfter text position "<" false, .lt⟩
  else if fixedAfter text position ">" false ≠ 0 then ⟨fixedAfter text position ">" false, .gt⟩
  else ⟨0, .eq⟩

structure LengthResult where
  after : Nat
  value : Bound
  deriving DecidableEq, Repr

def lengthAt (text : Source) (context : ParseContext) (position : Nat) (literal : Bool) : LengthResult :=
  let first := skipAt text position
  let after := nameAfter text first
  let index := lookupName text context.names first after
  let number := IntegerLiteral.read text first
  if literal && decide (number.after ≠ 0) then ⟨number.after, .fixed number.value⟩
  else if index = 0 ∨ ScalarExpression.lookup text context.scalarNames first after ≠ 0 then ⟨0, .fixed 0⟩
  else ⟨fixedAfter text (fixedAfter text after "'" false) "length" true,
    ((context.names.get index).getD {}).bound⟩

structure ConditionResult where
  after : Nat
  whenTrue : ActiveFlow
  whenFalse : ActiveFlow
  deriving DecidableEq, Repr

def ConditionResult.count (result : ConditionResult) : Nat := result.whenTrue.count

def invalidCondition (facts : ActiveFlow) : ConditionResult := ⟨0, facts.invalid, facts.invalid⟩

def bareTarget (text : Source) (context : ParseContext) (position after : Nat) : Nat :=
  let first := skipAt text position
  let last := nameAfter text first
  let index := ScalarExpression.lookup text context.scalarNames first last
  if index ≠ 0 ∧ last = after ∧
      ((ScalarExpression.binding context.scalarNames index).mutable || decide (context.declarationCount < index))
  then index else 0

def scalarCondition (text : Source) (context : ParseContext) (position rightPosition : Nat)
    (facts : ActiveFlow) (left right : ScalarExpression.Result) (operator : Comparison) : ConditionResult :=
  let leftTarget := bareTarget text context position left.after
  let rightTarget := bareTarget text context rightPosition right.after
  let target := if leftTarget ≠ 0 ∧ right.isStatic ∧ right.bounds.lower = right.bounds.upper then leftTarget
    else if rightTarget ≠ 0 ∧ left.isStatic ∧ left.bounds.lower = left.bounds.upper then rightTarget else 0
  let selected := if leftTarget ≠ 0 ∧ right.isStatic ∧ right.bounds.lower = right.bounds.upper
    then operator.toInteger else operator.toInteger.swap
  let threshold := if leftTarget ≠ 0 ∧ right.isStatic ∧ right.bounds.lower = right.bounds.upper
    then right.bounds.lower else left.bounds.lower
  ⟨right.after, facts.refine target selected threshold true, facts.refine target selected threshold false⟩

def refineFlowBounds (facts : ActiveFlow) (operator : Comparison) (left right : Bound) (truth : Bool) : ActiveFlow :=
  {facts with path := refineBounds facts.path operator left right truth}

def summaryOf (value : ExpressionResult) : LengthSummary := value.lengthSummary

def remainingAt (text : Source) (position : Nat) : Nat := text.length + 1 - position

/-- `some true` records an `and then` chain, `some false` an `or else`
chain; `none` permits the first operator to select the chain kind. -/
def chainOperator (text : Source) (position : Nat) : Option Bool :=
  if fixedAfter text position "and" true ≠ 0 then some true
  else if fixedAfter text position "or" true ≠ 0 then some false
  else none

def chainAfter (text : Source) (position : Nat) (andThen : Bool) : Nat :=
  fixedAfter text (fixedAfter text position (if andThen then "and" else "or") true)
    (if andThen then "then" else "else") true

def chainContext (result : ConditionResult) (andThen : Bool) : ActiveFlow :=
  if andThen then result.whenTrue else result.whenFalse

def chainJoin (left right : ConditionResult) (andThen : Bool) : ConditionResult :=
  if andThen then ⟨right.after, right.whenTrue, left.whenFalse.join right.whenFalse⟩
  else ⟨right.after, left.whenTrue.join right.whenTrue, right.whenFalse⟩

mutual
  def readPrimary (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) : ConditionResult :=
    if position = 0 then invalidCondition facts else
    let after := fixedAfter text position "(" false
    if after ≠ 0 then
      if _advanced : remainingAt text after < remainingAt text position then
        let result := readCondition text context after facts
        let close := fixedAfter text result.after ")" false
        if close = 0 then invalidCondition facts else {result with after := close}
      else invalidCondition facts
    else if !context.hasArguments then invalidCondition facts
    else
      let afterCall := callAfter text context.names position .validity context.scalarNames context.arrayNames
      if afterCall = 0 then invalidCondition facts else
        ⟨afterCall, {facts with path := facts.path.assumeValid}, {facts with path := facts.path.assumeInvalid}⟩
  termination_by remainingAt text position * 5 + 1
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def readRelation (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) : ConditionResult :=
    if position = 0 then invalidCondition facts else
    let after := fixedAfter text position "not" true
    if after ≠ 0 then
      if _advanced : remainingAt text after < remainingAt text position then
        let result := readPrimary text context after facts
        ⟨result.after, result.whenFalse, result.whenTrue⟩
      else invalidCondition facts
    else
      let leftLength := lengthAt text context position false
      if leftLength.after ≠ 0 then
        let operator := comparisonAt text leftLength.after
        let rightLength := lengthAt text context operator.after true
        if rightLength.after ≤ position then invalidCondition facts else
        ⟨rightLength.after,
          refineFlowBounds facts operator.operator leftLength.value rightLength.value true,
          refineFlowBounds facts operator.operator leftLength.value rightLength.value false⟩
      else
        let leftScalar := ScalarExpression.read text position (context.readingNames facts) (arrays := context.arrayNames)
        if leftScalar.after ≠ 0 then
          let operator := comparisonAt text leftScalar.after
          let rightScalar := ScalarExpression.read text operator.after (context.readingNames facts) (arrays := context.arrayNames)
          if rightScalar.after ≤ position then invalidCondition facts
          else scalarCondition text context position operator.after facts leftScalar rightScalar operator.operator
        else
        let left := expressionAt text position context.names (context.readingNames facts) (arrays := context.arrayNames)
        if left.after ≠ 0 then
          let operator := comparisonAt text left.after
          if operator.after = 0 ∨ (operator.operator ≠ .eq ∧ operator.operator ≠ .ne) then invalidCondition facts
          else
            let right := expressionAt text operator.after context.names (context.readingNames facts) (arrays := context.arrayNames)
            if right.after ≤ position ∨ !(left.namedSeen || right.namedSeen) ∨
                !fitsLengthSummary facts.path (summaryOf left) ∨ !fitsLengthSummary facts.path (summaryOf right) then invalidCondition facts
            else
              let equalFacts := {facts with path := refineLengthOverlap facts.path (summaryOf left) (summaryOf right)}
              ⟨right.after, if operator.operator == .eq then equalFacts else facts,
                if operator.operator == .eq then facts else equalFacts⟩
        else readPrimary text context position facts
  termination_by remainingAt text position * 5 + 2
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def conditionTail (text : Source) (context : ParseContext) (result : ConditionResult)
      (chained : Option Bool) : ConditionResult :=
    if result.after = 0 then invalidCondition result.whenTrue else
    match chainOperator text result.after with
    | none => result
    | some operator =>
        if chained.isSome && decide (chained ≠ some operator) then invalidCondition result.whenTrue else
        let after := chainAfter text result.after operator
        if after = 0 then invalidCondition result.whenTrue else
        if _advanced : remainingAt text after < remainingAt text result.after then
          let right := readRelation text context after (chainContext result operator)
          if right.after = 0 then invalidCondition result.whenTrue else
          let next := chainJoin result right operator
          if _rightAdvanced : remainingAt text next.after < remainingAt text result.after then
            conditionTail text context next (some operator)
          else invalidCondition result.whenTrue
        else invalidCondition result.whenTrue
  termination_by remainingAt text result.after * 5 + 4
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def readCondition (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) : ConditionResult :=
    let result := readRelation text context position facts
    if result.after = 0 then invalidCondition facts else
    if _advanced : remainingAt text result.after < remainingAt text position then
      let final := conditionTail text context result none
      if final.after = 0 then invalidCondition facts else final
    else invalidCondition facts
  termination_by remainingAt text position * 5 + 3
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega
end

end Silver.Predicate

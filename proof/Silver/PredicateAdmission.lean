module

public import Silver.ComposeGrammar
public import Silver.PredicateChecking
public import Silver.IntegerLiteral

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
  deriving Repr

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
  whenTrue : Context
  whenFalse : Context
  deriving DecidableEq, Repr

def invalidCondition : ConditionResult := ⟨0, Context.empty, Context.empty⟩

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

def chainContext (result : ConditionResult) (andThen : Bool) : Context :=
  if andThen then result.whenTrue else result.whenFalse

def chainJoin (left right : ConditionResult) (andThen : Bool) : ConditionResult :=
  if andThen then ⟨right.after, right.whenTrue, left.whenFalse.join right.whenFalse⟩
  else ⟨right.after, left.whenTrue.join right.whenTrue, right.whenFalse⟩

mutual
  def readPrimary (text : Source) (context : ParseContext) (position : Nat) (facts : Context) : ConditionResult :=
    if position = 0 then invalidCondition else
    let after := fixedAfter text position "(" false
    if after ≠ 0 then
      if _advanced : remainingAt text after < remainingAt text position then
        let result := readCondition text context after facts
        {result with after := fixedAfter text result.after ")" false}
      else invalidCondition
    else if !context.hasArguments then invalidCondition
    else ⟨callAfter text context.names position .validity context.scalarNames, facts.assumeValid, facts.assumeInvalid⟩
  termination_by remainingAt text position * 5 + 1
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def readRelation (text : Source) (context : ParseContext) (position : Nat) (facts : Context) : ConditionResult :=
    if position = 0 then invalidCondition else
    let after := fixedAfter text position "not" true
    if after ≠ 0 then
      if _advanced : remainingAt text after < remainingAt text position then
        let result := readPrimary text context after facts
        ⟨result.after, result.whenFalse, result.whenTrue⟩
      else invalidCondition
    else
      let leftLength := lengthAt text context position false
      if leftLength.after ≠ 0 then
        let operator := comparisonAt text leftLength.after
        let rightLength := lengthAt text context operator.after true
        if rightLength.after ≤ position then invalidCondition else
        ⟨rightLength.after,
          refineBounds facts operator.operator leftLength.value rightLength.value true,
          refineBounds facts operator.operator leftLength.value rightLength.value false⟩
      else
        let leftScalar := ScalarExpression.read text position context.scalarNames
        if leftScalar.after ≠ 0 then
          let operator := comparisonAt text leftScalar.after
          let rightScalar := ScalarExpression.read text operator.after context.scalarNames
          if rightScalar.after ≤ position then invalidCondition
          else ⟨rightScalar.after, facts, facts⟩
        else
        let left := expressionAt text position context.names context.scalarNames
        if left.after ≠ 0 then
          let operator := comparisonAt text left.after
          if operator.after = 0 ∨ (operator.operator ≠ .eq ∧ operator.operator ≠ .ne) then invalidCondition
          else
            let right := expressionAt text operator.after context.names context.scalarNames
            if right.after ≤ position ∨ !(left.namedSeen || right.namedSeen) ∨
                !fitsLengthSummary facts (summaryOf left) ∨ !fitsLengthSummary facts (summaryOf right) then invalidCondition
            else
              let equalFacts := refineLengthOverlap facts (summaryOf left) (summaryOf right)
              ⟨right.after, if operator.operator == .eq then equalFacts else facts,
                if operator.operator == .eq then facts else equalFacts⟩
        else readPrimary text context position facts
  termination_by remainingAt text position * 5 + 2
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def conditionTail (text : Source) (context : ParseContext) (result : ConditionResult)
      (chained : Option Bool) : ConditionResult :=
    if result.after = 0 then invalidCondition else
    match chainOperator text result.after with
    | none => result
    | some operator =>
        if chained.isSome && decide (chained ≠ some operator) then invalidCondition else
        let after := chainAfter text result.after operator
        if after = 0 then invalidCondition else
        if _advanced : remainingAt text after < remainingAt text result.after then
          let right := readRelation text context after (chainContext result operator)
          if right.after = 0 then invalidCondition else
          let next := chainJoin result right operator
          if _rightAdvanced : remainingAt text next.after < remainingAt text result.after then
            conditionTail text context next (some operator)
          else invalidCondition
        else invalidCondition
  termination_by remainingAt text result.after * 5 + 4
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega

  def readCondition (text : Source) (context : ParseContext) (position : Nat) (facts : Context) : ConditionResult :=
    let result := readRelation text context position facts
    if result.after = 0 then invalidCondition else
    if _advanced : remainingAt text result.after < remainingAt text position then
      conditionTail text context result none
    else invalidCondition
  termination_by remainingAt text position * 5 + 3
  decreasing_by all_goals simp_wf; all_goals try dsimp (config := {zetaDelta := true}) only at *; all_goals omega
end

end Silver.Predicate

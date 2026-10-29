module

public import Silver.PredicateReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

set_option backward.dsimp.instances true

/-- String relations retain the named operand required for Ada's overload
resolution. This does not grant byte equalities to mutable objects. -/
def StringRelationReady (facts : ActiveFlow) (left right : ExpressionResult) (operator : ComparisonResult) : Prop :=
  left.after ≠ 0 ∧ operator.after ≠ 0 ∧ (operator.operator = .eq ∨ operator.operator = .ne) ∧
    right.after ≠ 0 ∧ (left.namedSeen || right.namedSeen) = true ∧
    fitsLengthSummary facts.path (summaryOf left) = true ∧ fitsLengthSummary facts.path (summaryOf right) = true

def stringResult (facts : ActiveFlow) (left right : ExpressionResult) (operator : ComparisonResult) : ConditionResult :=
  let equalFacts := {facts with path := refineLengthOverlap facts.path (summaryOf left) (summaryOf right)}
  ⟨right.after, if operator.operator == .eq then equalFacts else facts,
    if operator.operator == .eq then facts else equalFacts⟩

def chainCondition (left right : Condition) (andThen : Bool) : Condition :=
  if andThen then .andThen left right else .orElse left right

mutual
  inductive PrimaryAt (text : Source) (context : ParseContext) : Nat → ActiveFlow → Condition → ConditionResult → Prop
    | group {position facts inner result} : position ≠ 0 →
        fixedAfter text position "(" false ≠ 0 →
        remainingAt text (fixedAfter text position "(" false) < remainingAt text position →
        ConditionAt text context (fixedAfter text position "(" false) facts inner result →
        fixedAfter text result.after ")" false ≠ 0 →
        PrimaryAt text context position facts (.parenthesized inner)
          {result with after := fixedAfter text result.after ")" false}
    | valid {position facts} : position ≠ 0 → fixedAfter text position "(" false = 0 →
        context.hasArguments = true →
        callAfter (arrays := context.arrayNames) (subtypeHidden := context.subtypeHiding.get .validity) text context.names position .validity context.scalarNames ≠ 0 →
        PrimaryAt text context position facts .inputValid
          ⟨callAfter (arrays := context.arrayNames) (subtypeHidden := context.subtypeHiding.get .validity) text context.names position .validity context.scalarNames, {facts with path := facts.path.assumeValid}, {facts with path := facts.path.assumeInvalid}⟩

  inductive RelationAt (text : Source) (context : ParseContext) : Nat → ActiveFlow → Condition → ConditionResult → Prop
    | negated {position facts inner result} : position ≠ 0 →
        fixedAfter text position "not" true ≠ 0 →
        remainingAt text (fixedAfter text position "not" true) < remainingAt text position →
        PrimaryAt text context (fixedAfter text position "not" true) facts inner result →
        RelationAt text context position facts (.negated inner) ⟨result.after, result.whenFalse, result.whenTrue⟩
    | length {position facts left right leftResult rightResult} : position ≠ 0 →
        fixedAfter text position "not" true = 0 →
        leftResult.after ≠ 0 →
        LengthAt text context position false (.binding left) leftResult →
        LengthAt text context (comparisonAt text leftResult.after).after true right rightResult →
        position < rightResult.after →
        RelationAt text context position facts (.lengthCompare (comparisonAt text leftResult.after).operator left right)
          ⟨rightResult.after,
            refineFlowBounds facts (comparisonAt text leftResult.after).operator leftResult.value rightResult.value true,
            refineFlowBounds facts (comparisonAt text leftResult.after).operator leftResult.value rightResult.value false⟩
    | scalars {position facts left right leftResult rightResult} : position ≠ 0 →
        fixedAfter text position "not" true = 0 → (lengthAt text context position false).after = 0 →
        leftResult.after ≠ 0 →
        ScalarExpression.At (arrays := context.arrayNames) text (context.readingNames facts) position left leftResult →
        ScalarExpression.At (arrays := context.arrayNames) text (context.readingNames facts) (comparisonAt text leftResult.after).after right rightResult →
        position < rightResult.after →
        RelationAt text context position facts
          (.scalarCompare (comparisonAt text leftResult.after).operator.toInteger left right)
          (scalarCondition text context position (comparisonAt text leftResult.after).after
            facts leftResult rightResult (comparisonAt text leftResult.after).operator)
    | strings {position facts left right leftResult rightResult} : position ≠ 0 →
        fixedAfter text position "not" true = 0 → (lengthAt text context position false).after = 0 →
        (ScalarExpression.read (arrays := context.arrayNames) text position (context.readingNames facts)).after = 0 →
        ExpressionAt (scalarNames := context.readingNames facts) (arrays := context.arrayNames) text context.names position left leftResult →
        ExpressionAt (scalarNames := context.readingNames facts) (arrays := context.arrayNames) text context.names (comparisonAt text leftResult.after).after right rightResult →
        StringRelationReady facts leftResult rightResult (comparisonAt text leftResult.after) →
        position < rightResult.after →
        RelationAt text context position facts
          (.stringCompare ((comparisonAt text leftResult.after).operator != .eq) left right)
          (stringResult facts leftResult rightResult (comparisonAt text leftResult.after))
    | primary {position facts inner result} : position ≠ 0 →
        fixedAfter text position "not" true = 0 → (lengthAt text context position false).after = 0 →
        (ScalarExpression.read (arrays := context.arrayNames) text position (context.readingNames facts)).after = 0 →
        (expressionAt (arrays := context.arrayNames) text position context.names (context.readingNames facts)).after = 0 →
        PrimaryAt text context position facts inner result →
        RelationAt text context position facts inner result

  inductive ChainAt (text : Source) (context : ParseContext) :
      Condition → ConditionResult → Option Bool → Condition → ConditionResult → Prop
    | done {condition result chained} : result.after ≠ 0 → chainOperator text result.after = none →
        ChainAt text context condition result chained condition result
    | next {condition result chained operator right rightResult final finalResult} :
        conditionTail text context result chained = finalResult →
        result.after ≠ 0 → chainOperator text result.after = some operator →
        ¬(chained.isSome = true ∧ chained ≠ some operator) →
        chainAfter text result.after operator ≠ 0 →
        remainingAt text (chainAfter text result.after operator) < remainingAt text result.after →
        RelationAt text context (chainAfter text result.after operator) (chainContext result operator) right rightResult →
        rightResult.after ≠ 0 →
        remainingAt text (chainJoin result rightResult operator).after < remainingAt text result.after →
        ChainAt text context (chainCondition condition right operator) (chainJoin result rightResult operator)
          (some operator) final finalResult →
        ChainAt text context condition result chained final finalResult

  inductive ConditionAt (text : Source) (context : ParseContext) : Nat → ActiveFlow → Condition → ConditionResult → Prop
    | condition {position facts first result condition final} :
        readCondition text context position facts = final →
        RelationAt text context position facts first result → result.after ≠ 0 →
        remainingAt text result.after < remainingAt text position →
        ChainAt text context first result none condition final →
        ConditionAt text context position facts condition final
end

theorem condition_complete {text context position facts condition result}
    (parsed : ConditionAt text context position facts condition result) :
    readCondition text context position facts = result := by
  cases parsed with | condition scanned => exact scanned

theorem primary_complete {text context position facts condition result}
    (parsed : PrimaryAt text context position facts condition result) :
    readPrimary text context position facts = result := by
  cases parsed with
  | group positive opening advanced inner closed =>
      rw [readPrimary]
      simp [positive, opening, advanced, condition_complete inner, closed]
  | valid positive noOpening arguments accepted =>
      simp only [readPrimary, positive, noOpening, arguments, Bool.not_true, Bool.false_eq_true,
        ne_eq, not_true_eq_false, ↓reduceIte, accepted]


theorem relation_complete {text context position facts condition result}
    (parsed : RelationAt text context position facts condition result) :
    readRelation text context position facts = result := by
  cases parsed with
  | negated positive opening advanced inner =>
      rw [readRelation]
      simp [positive, opening, advanced, primary_complete inner]
  | length positive noNot leftPositive left right advanced =>
      rw [readRelation]
      simp [positive, noNot, lengthAt_complete left, leftPositive, lengthAt_complete right, Nat.not_le.mpr advanced]
  | scalars positive noNot noLength leftPositive left right advanced =>
      rw [readRelation]
      simp only [positive, noNot, noLength, ScalarExpression.read_complete left,
        leftPositive, ScalarExpression.read_complete right, Nat.not_le.mpr advanced,
        ne_eq, not_true_eq_false, not_false_eq_true, ↓reduceIte]
  | @strings position facts leftExpr rightExpr leftResult rightResult positive noNot noLength noScalar left right ready advanced =>
      have leftEq : expressionAt (arrays := context.arrayNames) text position context.names (context.readingNames facts) = leftResult := expressionTail_complete left
      have rightEq : expressionAt (arrays := context.arrayNames) text (comparisonAt text leftResult.after).after context.names (context.readingNames facts) = rightResult := expressionTail_complete right
      have operatorAllowed : ¬((comparisonAt text leftResult.after).after = 0 ∨
          ((comparisonAt text leftResult.after).operator ≠ .eq ∧ (comparisonAt text leftResult.after).operator ≠ .ne)) := by
        rcases ready with ⟨_, present, kind, _⟩
        rintro (zero | different)
        · exact present zero
        · rcases kind with equal | unequal
          · exact different.1 equal
          · exact different.2 unequal
      simp only [readRelation, positive, noNot, noLength, noScalar, ne_eq, not_true_eq_false, ↓reduceIte,
        leftEq, ready.1,
        operatorAllowed, rightEq,
        Nat.not_le.mpr advanced, ready.2.2.2.2.1, ready.2.2.2.2.2.1, ready.2.2.2.2.2.2,
        Bool.not_true, Bool.false_eq_true, or_self, not_false_eq_true, stringResult]
  | primary positive noNot noLength noScalar noExpression primary =>
      simp only [readRelation, positive, noNot, noLength, noScalar, noExpression, ne_eq, not_true_eq_false,
        ↓reduceIte, primary_complete primary]


theorem chain_complete {text context condition result chained final finalResult}
    (parsed : ChainAt text context condition result chained final finalResult) :
    conditionTail text context result chained = finalResult := by
  cases parsed with
  | done positive done => simp only [conditionTail, positive, done, ↓reduceIte]
  | next scanned => exact scanned

end Silver.Predicate

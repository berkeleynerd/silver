module

public import Silver.PredicateConditionValidity

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

mutual
  theorem primary_unique {text context position facts left right leftResult rightResult}
      (first : PrimaryAt text context position facts left leftResult)
      (second : PrimaryAt text context position facts right rightResult) : left = right := by
    cases first with
    | group _ opening _ inner _ =>
        cases second with
        | group _ _ _ other _ => exact congrArg Condition.parenthesized (condition_unique inner other)
        | valid _ noOpening _ _ => exact False.elim (opening noOpening)
    | valid _ noOpening _ _ =>
        cases second with
        | group _ opening _ _ _ => exact False.elim (opening noOpening)
        | valid => rfl
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem relation_unique {text context position facts left right leftResult rightResult}
      (first : RelationAt text context position facts left leftResult)
      (second : RelationAt text context position facts right rightResult) : left = right := by
    cases first with
    | negated _ opening _ inner =>
        cases second with
        | negated _ _ _ other => exact congrArg Condition.negated (primary_unique inner other)
        | length _ noNot | scalars _ noNot | strings _ noNot | primary _ noNot => exact False.elim (opening noNot)
    | length _ noNot leftPositive leftRead rightRead _ =>
        cases second with
        | negated _ opening => exact False.elim (opening noNot)
        | length _ _ _ otherLeft otherRight _ =>
            obtain ⟨leftSame, resultSame⟩ := lengthAt_unique leftRead otherLeft
            cases leftSame
            cases resultSame
            have rightSame := (lengthAt_unique rightRead otherRight).1
            cases rightSame
            rfl
        | scalars _ _ noLength | strings _ _ noLength | primary _ _ noLength =>
            rw [lengthAt_complete leftRead] at noLength
            exact False.elim (leftPositive noLength)
    | scalars _ noNot noLength leftPositive leftRead rightRead _ =>
        cases second with
        | negated _ opening => exact False.elim (opening noNot)
        | length _ _ leftPositive left _ _ =>
            rw [lengthAt_complete left] at noLength
            exact False.elim (leftPositive noLength)
        | scalars _ _ _ _ otherLeft otherRight _ =>
            obtain ⟨rfl, rfl⟩ := ScalarExpression.at_unique leftRead otherLeft
            obtain ⟨rfl, _⟩ := ScalarExpression.at_unique rightRead otherRight
            rfl
        | strings _ _ _ noScalar | primary _ _ _ noScalar =>
            rw [ScalarExpression.read_complete leftRead] at noScalar
            exact False.elim (leftPositive noScalar)
    | strings _ noNot noLength noScalar leftRead rightRead ready _ =>
        cases second with
        | negated _ opening => exact False.elim (opening noNot)
        | length _ _ leftPositive left _ _ =>
            rw [lengthAt_complete left] at noLength
            exact False.elim (leftPositive noLength)
        | scalars _ _ _ leftPositive left _ _ =>
            rw [ScalarExpression.read_complete left] at noScalar
            exact False.elim (leftPositive noScalar)
        | strings _ _ _ _ otherLeft otherRight _ _ =>
            obtain ⟨rfl, rfl⟩ := expressionTail_unique leftRead otherLeft
            obtain ⟨rfl, _⟩ := expressionTail_unique rightRead otherRight
            rfl
        | primary _ _ _ _ noExpression =>
            rw [show expressionAt text position context.names context.scalarNames = _ from expressionTail_complete leftRead] at noExpression
            exact False.elim (ready.1 noExpression)
    | primary _ noNot noLength noScalar noExpression inner =>
        cases second with
        | negated _ opening => exact False.elim (opening noNot)
        | length _ _ leftPositive left _ _ =>
            rw [lengthAt_complete left] at noLength
            exact False.elim (leftPositive noLength)
        | scalars _ _ _ leftPositive left _ _ =>
            rw [ScalarExpression.read_complete left] at noScalar
            exact False.elim (leftPositive noScalar)
        | strings _ _ _ _ left _ ready _ =>
            rw [show expressionAt text position context.names context.scalarNames = _ from expressionTail_complete left] at noExpression
            exact False.elim (ready.1 noExpression)
        | primary _ _ _ _ _ other => exact primary_unique inner other

  termination_by (remainingAt text position, 2)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem chain_unique {text context condition result chained left right leftResult rightResult}
      (first : ChainAt text context condition result chained left leftResult)
      (second : ChainAt text context condition result chained right rightResult) : left = right := by
    cases first with
    | done _ stopped =>
        cases second with
        | done => rfl
        | next _ _ operator => simp [stopped] at operator
    | @next condition result chained operator rightCondition rightResult final finalResult _ _ operatorEq _ _ _ rightRead _ _ rest =>
        cases second with
        | done _ stopped => simp [stopped] at operatorEq
        | @next _ _ _ otherOperator otherCondition otherResult _ _ _ _ otherOpEq _ _ _ otherRead _ _ otherRest =>
            have same : operator = otherOperator := Option.some.inj (operatorEq.symm.trans otherOpEq)
            subst otherOperator
            have conditionSame := relation_unique rightRead otherRead
            have resultSame := (relation_complete rightRead).symm.trans (relation_complete otherRead)
            subst otherCondition
            subst otherResult
            exact chain_unique rest otherRest
  termination_by (remainingAt text result.after, 4)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem condition_unique {text context position facts left right leftResult rightResult}
      (first : ConditionAt text context position facts left leftResult)
      (second : ConditionAt text context position facts right rightResult) : left = right := by
    cases first with
    | condition _ firstRead _ _ tail =>
        cases second with
        | condition _ otherRead _ _ otherTail =>
            have conditionSame := relation_unique firstRead otherRead
            have resultSame := (relation_complete firstRead).symm.trans (relation_complete otherRead)
            cases conditionSame
            cases resultSame
            exact chain_unique tail otherTail
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

end Silver.Predicate

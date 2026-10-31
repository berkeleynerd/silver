module

public import Silver.PredicateConditionReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

theorem booleanAtom_unique {text context position left right leftAfter rightAfter}
    (first : BooleanAtomAt text context position left leftAfter)
    (second : BooleanAtomAt text context position right rightAfter) : left = right := by
  cases first with
  | name _ found =>
      cases second with
      | name => rfl
      | literal _ absent _ => exact False.elim (found absent)
  | @literal value spelling _ absent literal =>
      cases second with
      | name _ found => exact False.elim (found absent)
      | @literal other otherSpelling _ _ otherLiteral =>
          have length : ∀ value : Bool,
              Named.nameIs text (skipAt text position) (nameAfter text (skipAt text position))
                ((if value then "true" else "false").toList.map Char.toNat) = true →
              nameAfter text (skipAt text position) - skipAt text position = (if value then 4 else 5) := by
            intro value spelling
            cases value <;> simp only [Named.nameIs, Bool.and_eq_true, decide_eq_true_eq] at spelling
            all_goals exact spelling.1
          have a := length value literal
          have b := length other otherLiteral
          cases value <;> cases other <;> simp_all


mutual
  theorem primary_unique {text context position facts left right leftResult rightResult initials}
      (first : PrimaryAt text context position facts left leftResult initials)
      (second : PrimaryAt text context position facts right rightResult initials) : left = right := by
    cases first with
    | group _ opening _ inner _ =>
        cases second with
        | group _ _ _ other _ => exact congrArg Condition.parenthesized (condition_unique inner other)
        | valid _ noOpening | boolean _ noOpening => exact False.elim (opening noOpening)
    | boolean _ noOpening atomAfter nonzero atom =>
        cases second with
        | group _ opening => exact False.elim (opening noOpening)
        | boolean _ _ _ _ other => exact booleanAtom_unique atom other
        | valid _ _ noAtom => rw [atomAfter] at noAtom; exact False.elim (nonzero noAtom)
    | valid _ noOpening noAtom _ _ =>
        cases second with
        | group _ opening => exact False.elim (opening noOpening)
        | boolean _ _ atomAfter nonzero => rw [atomAfter] at noAtom; exact False.elim (nonzero noAtom)
        | valid => rfl
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem booleanFactor_unique {text context position facts left right leftResult rightResult initials}
      (first : BooleanFactorAt text context position facts left leftResult initials)
      (second : BooleanFactorAt text context position facts right rightResult initials) : left = right := by
    cases first with
    | primary noNot inner =>
        cases second with
        | primary _ other => exact primary_unique inner other
        | negated hasNot => exact False.elim (hasNot noNot)
    | negated hasNot _ inner =>
        cases second with
        | primary noNot => exact False.elim (hasNot noNot)
        | negated _ _ other => exact congrArg Condition.negated (primary_unique inner other)
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem booleanRelation_unique {text context position facts left right leftResult rightResult initials}
      (first : BooleanRelationAt text context position facts left leftResult initials)
      (second : BooleanRelationAt text context position facts right rightResult initials) : left = right := by
    cases first with
    | factor inner _ noComparison =>
        cases second with
        | factor other _ _ => exact booleanFactor_unique inner other
        | comparison other _ hasComparison _ _ _ _ =>
            have same := (booleanFactor_complete inner).symm.trans (booleanFactor_complete other)
            cases same
            exact False.elim (hasComparison noComparison)
    | comparison left _ hasComparison _ _ right _ =>
        cases second with
        | factor other _ noComparison =>
            have same := (booleanFactor_complete left).symm.trans (booleanFactor_complete other)
            cases same
            exact False.elim (hasComparison noComparison)
        | comparison otherLeft _ _ _ _ otherRight _ =>
            have leftSame := booleanFactor_unique left otherLeft
            have resultSame := (booleanFactor_complete left).symm.trans (booleanFactor_complete otherLeft)
            cases leftSame
            cases resultSame
            have rightSame := booleanFactor_unique right otherRight
            cases rightSame
            rfl
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem relation_unique {text context position facts left right leftResult rightResult initials}
      (first : RelationAt text context position facts left leftResult initials)
      (second : RelationAt text context position facts right rightResult initials) : left = right := by
    cases first with
    | booleanNot _ opening inner =>
        cases second with
        | booleanNot _ _ other => exact booleanRelation_unique inner other
        | length _ noNot | scalars _ noNot | strings _ noNot | character _ noNot | primary _ noNot => exact False.elim (opening noNot)
    | length _ noNot leftPositive leftRead rightRead _ =>
        cases second with
        | booleanNot _ opening => exact False.elim (opening noNot)
        | length _ _ _ otherLeft otherRight _ =>
            obtain ⟨leftSame, resultSame⟩ := lengthAt_unique leftRead otherLeft
            cases leftSame
            cases resultSame
            have rightSame := (lengthAt_unique rightRead otherRight).1
            cases rightSame
            rfl
        | scalars _ _ noLength | strings _ _ noLength | character _ _ noLength | primary _ _ noLength =>
            rw [lengthAt_complete leftRead] at noLength
            exact False.elim (leftPositive noLength)
    | scalars _ noNot noLength leftPositive leftRead rightRead _ =>
        cases second with
        | booleanNot _ opening => exact False.elim (opening noNot)
        | length _ _ leftPositive left _ _ =>
            rw [lengthAt_complete left] at noLength
            exact False.elim (leftPositive noLength)
        | scalars _ _ _ _ otherLeft otherRight _ =>
            obtain ⟨rfl, rfl⟩ := ScalarExpression.at_unique leftRead otherLeft
            obtain ⟨rfl, _⟩ := ScalarExpression.at_unique rightRead otherRight
            rfl
        | strings _ _ _ noScalar | character _ _ _ noScalar | primary _ _ _ noScalar =>
            change (ScalarExpression.read text position (context.readingNames facts) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating)).after = 0 at noScalar
            rw [ScalarExpression.read_complete leftRead] at noScalar
            exact False.elim (leftPositive noScalar)
    | strings _ noNot noLength noScalar leftRead rightRead ready _ =>
        cases second with
        | booleanNot _ opening => exact False.elim (opening noNot)
        | length _ _ leftPositive left _ _ =>
            rw [lengthAt_complete left] at noLength
            exact False.elim (leftPositive noLength)
        | scalars _ _ _ leftPositive left _ _ =>
            change (ScalarExpression.read text position (context.readingNames facts) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating)).after = 0 at noScalar
            rw [ScalarExpression.read_complete left] at noScalar
            exact False.elim (leftPositive noScalar)
        | strings _ _ _ _ otherLeft otherRight _ _ =>
            obtain ⟨rfl, rfl⟩ := expressionTail_unique leftRead otherLeft
            obtain ⟨rfl, _⟩ := expressionTail_unique rightRead otherRight
            rfl
        | character _ _ _ _ noExpression | primary _ _ _ _ noExpression =>
            rw [show readStringInFlow text context position facts initials = _ from expressionTail_complete leftRead] at noExpression
            exact False.elim (ready.1 noExpression)
    | character _ noNot noLength noScalar noExpression inner =>
        cases second with
        | booleanNot _ opening => exact False.elim (opening noNot)
        | length _ _ leftPositive left _ _ =>
            rw [lengthAt_complete left] at noLength
            exact False.elim (leftPositive noLength)
        | scalars _ _ _ leftPositive left _ _ =>
            change (ScalarExpression.read text position (context.readingNames facts) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating)).after = 0 at noScalar
            rw [ScalarExpression.read_complete left] at noScalar
            exact False.elim (leftPositive noScalar)
        | strings _ _ _ _ left _ ready _ =>
            rw [show readStringInFlow text context position facts initials = _ from expressionTail_complete left] at noExpression
            exact False.elim (ready.1 noExpression)
        | character _ _ _ _ _ other => exact characterRelation_unique inner other
        | primary _ _ _ _ _ noCharacter _ =>
            have positive := characterRelation_positive inner
            rw [← characterRelation_complete inner, noCharacter] at positive
            contradiction
    | primary _ noNot noLength noScalar noExpression noCharacter inner =>
        cases second with
        | booleanNot _ opening => exact False.elim (opening noNot)
        | length _ _ leftPositive left _ _ =>
            rw [lengthAt_complete left] at noLength
            exact False.elim (leftPositive noLength)
        | scalars _ _ _ leftPositive left _ _ =>
            change (ScalarExpression.read text position (context.readingNames facts) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating)).after = 0 at noScalar
            rw [ScalarExpression.read_complete left] at noScalar
            exact False.elim (leftPositive noScalar)
        | strings _ _ _ _ left _ ready _ =>
            rw [show readStringInFlow text context position facts initials = _ from expressionTail_complete left] at noExpression
            exact False.elim (ready.1 noExpression)
        | character _ _ _ _ _ other =>
            have positive := characterRelation_positive other
            rw [← characterRelation_complete other, noCharacter] at positive
            contradiction
        | primary _ _ _ _ _ _ other => exact booleanRelation_unique inner other

  termination_by (remainingAt text position, 4)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem chain_unique {text context condition result chained left right leftResult rightResult incoming initials originalStart}
      (first : ChainAt text context condition result chained left leftResult incoming initials originalStart)
      (second : ChainAt text context condition result chained right rightResult incoming initials originalStart) : left = right := by
    cases first with
    | done _ stopped =>
        cases second with
        | done => rfl
        | next _ _ operator => simp [stopped] at operator
    | @next incoming originalStart condition result chained operator rightCondition rightResult final finalResult _ _ operatorEq _ _ _ _ rightRead _ _ _ rest =>
        cases second with
        | done _ stopped => simp [stopped] at operatorEq
        | @next _ _ _ _ _ otherOperator otherCondition otherResult _ _ _ _ otherOpEq _ _ _ _ otherRead _ _ _ otherRest =>
            have same : operator = otherOperator := Option.some.inj (operatorEq.symm.trans otherOpEq)
            subst otherOperator
            have conditionSame := relation_unique rightRead otherRead
            have resultSame := (relation_complete rightRead).symm.trans (relation_complete otherRead)
            subst otherCondition
            subst otherResult
            exact chain_unique rest otherRest
  termination_by (remainingAt text result.after, 6)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem condition_unique {text context position facts left right leftResult rightResult initials}
      (first : ConditionAt text context position facts left leftResult initials)
      (second : ConditionAt text context position facts right rightResult initials) : left = right := by
    cases first with
    | condition _ firstRead _ _ tail =>
        cases second with
        | condition _ otherRead _ _ otherTail =>
            have conditionSame := relation_unique firstRead otherRead
            have resultSame := (relation_complete firstRead).symm.trans (relation_complete otherRead)
            cases conditionSame
            cases resultSame
            exact chain_unique tail otherTail
  termination_by (remainingAt text position, 5)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

end Silver.Predicate

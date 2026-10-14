module

public import Silver.PredicateBodyReadings

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

mutual
  theorem statement_unique {text context scan left right first second}
      (a : StatementAt text context scan left first) (b : StatementAt text context scan right second) : left = right := by
    cases a with
    | basic _ noIf reading _ =>
        cases b with
        | basic _ _ other _ => exact (basic_unique reading other).1
        | choice _ found => exact False.elim (found noIf)
    | choice _ found reading _ =>
        cases b with
        | basic _ noIf => exact False.elim (found noIf)
        | choice _ _ other _ =>
            obtain ⟨rfl, rfl, rfl⟩ := choice_unique reading other
            rfl
  termination_by (bodyRemaining text scan, 2)

  theorem choice_unique {text context scan leftCondition rightCondition leftYes rightYes leftTail rightTail first second}
      (a : ChoiceAt text context scan leftCondition leftYes leftTail first)
      (b : ChoiceAt text context scan rightCondition rightYes rightTail second) :
      leftCondition = rightCondition ∧ leftYes = rightYes ∧ leftTail = rightTail := by
    cases a with
    | choice conditionRead _ yesRead _ noRead _ _ _ =>
        cases b with
        | choice otherCondition _ otherYes _ otherNo _ _ _ =>
            have conditionSame := condition_unique conditionRead otherCondition
            have yesSame := body_unique yesRead otherYes
            have yesResultSame := (body_complete yesRead).symm.trans (body_complete otherYes)
            cases yesResultSame
            have noSame := alternative_unique noRead otherNo
            exact ⟨conditionSame, yesSame, noSame⟩
  termination_by (bodyRemaining text scan, 1)

  theorem alternative_unique {text context scan left right first second}
      (a : AlternativeAt text context scan left first) (b : AlternativeAt text context scan right second) : left = right := by
    cases a with
    | absent _ noElsif noElse _ =>
        cases b with
        | absent => rfl
        | otherwise _ _ found => exact False.elim (found noElse)
        | elsif _ found => exact False.elim (found noElsif)
    | otherwise _ noElsif found _ body _ =>
        cases b with
        | absent _ _ noElse => exact False.elim (found noElse)
        | elsif _ found => exact False.elim (found noElsif)
        | otherwise _ _ _ _ other _ => exact congrArg SourceAlternative.otherwise (body_unique body other)
    | elsif _ found conditionRead _ yesRead _ noRead _ _ _ =>
        cases b with
        | absent _ noElsif | otherwise _ noElsif => exact False.elim (found noElsif)
        | elsif _ _ otherCondition _ otherYes _ otherNo _ _ _ =>
            have conditionSame := condition_unique conditionRead otherCondition
            have yesSame := body_unique yesRead otherYes
            have yesResultSame := (body_complete yesRead).symm.trans (body_complete otherYes)
            cases yesResultSame
            have noSame := alternative_unique noRead otherNo
            cases conditionSame
            cases yesSame
            cases noSame
            rfl
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_unique {text context stop scan left right first second}
      (a : BodyTailAt text context stop scan left first) (b : BodyTailAt text context stop scan right second) : left = right := by
    cases a with
    | done _ stopped =>
        cases b with
        | done => rfl
        | next _ notStopped => simp [stopped] at notStopped
    | next _ notStopped item _ rest _ =>
        cases b with
        | done _ stopped => simp [stopped] at notStopped
        | next _ _ other _ otherRest _ =>
            have itemSame := statement_unique item other
            have nextSame := (statement_complete item).symm.trans (statement_complete other)
            cases nextSame
            have restSame := bodyTail_unique rest otherRest
            cases itemSame
            cases restSame
            rfl
  termination_by (bodyRemaining text scan, 3)

  theorem body_unique {text context scan stop left right first second}
      (a : BodyAt text context scan stop left first) (b : BodyAt text context scan stop right second) : left = right := by
    cases a with
    | cons item _ rest _ =>
        cases b with
        | cons other _ otherRest _ =>
            have itemSame := statement_unique item other
            have nextSame := (statement_complete item).symm.trans (statement_complete other)
            cases nextSame
            have restSame := bodyTail_unique rest otherRest
            cases itemSame
            cases restSame
            rfl
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate

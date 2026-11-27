module

public import Silver.ProcedureNameConditionBounds
public import Silver.ProcedureNameStringCursors

@[expose] public section

namespace Silver.Predicate
open Compose

/-- Both reference forms consume their complete original spelling. -/
theorem reference_source_advance {text : Source} {position : Nat} {reference : QualifiedNames.Reference}
    (source : QualifiedNames.At text position reference)
    (positionBound : position ≤ text.length + 1) : position < reference.after := by
  have start := QualifiedNames.skip_bounds text position positionBound
  cases source with
  | bare _ identifier _ =>
      have bounds := Named.identifier_bounds identifier
      dsimp only
      omega
  | @qualified packageBytes memberBytes packageAfter memberAfter _ packageName dotted _ memberName =>
      have packageBounds := Named.identifier_bounds packageName
      have dotStart := QualifiedNames.skip_bounds text _ packageBounds.2.2.2
      have memberBounds := Named.identifier_bounds memberName
      have memberStart := QualifiedNames.skip_bounds text
        (QualifiedNames.skip text packageAfter + 1) (by
          have bound := dotted.2.1
          omega)
      dsimp only
      omega

/-- Source productions bound their own cursors without requiring unrelated
metadata value-summary invariants. -/
theorem length_source_bound {text context position literal operand result}
    (source : LengthAt text context position literal operand result) :
    result.after ≤ text.length + 1 := by
  cases source with
  | number _ literal => exact (IntegerLiteral.integer_bounds literal).2.1
  | binding _ _ _ _ _ _ afterEq _ =>
      dsimp only
      rw [afterEq]
      exact fixedAfter_result_bound text _ "length" true (by decide)

theorem primary_source_bound {text context position facts condition result initials}
    (source : PrimaryAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) : result.after ≤ text.length + 1 := by
  cases source with
  | group => exact fixedAfter_result_bound text _ ")" false (by decide)
  | booleanArray _ _ _ _ atom =>
      cases atom
      exact fixedAfter_result_bound text _ ")" false (by decide)
  | boolean _ _ _ _ _ atom =>
      cases atom with
      | name reference _ | literal reference _ _ _ => exact reference_after_bounded reference
  | valid => exact Compose.Expressions.model_callAfter_valid text _ _ _ positionBound _ _ _ _ _

theorem booleanFactor_source_bound {text context position facts condition result initials}
    (source : BooleanFactorAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) : result.after ≤ text.length + 1 := by
  cases source with
  | primary _ inner => exact primary_source_bound inner positionBound
  | negated _ _ inner =>
      have bounded := primary_source_bound inner
        (fixedAfter_result_bound text position "not" true (by decide))
      exact bounded

theorem booleanRelation_source_bound {text context position facts condition result initials}
    (source : BooleanRelationAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) : result.after ≤ text.length + 1 := by
  cases source with
  | factor inner _ _ => exact booleanFactor_source_bound inner positionBound
  | comparison left _ _ _ _ right _ =>
      have bounded := booleanFactor_source_bound right
        (comparison_bound text _ (booleanFactor_source_bound left positionBound))
      exact bounded

theorem relation_source_bound {text context position facts condition result initials}
    (source : RelationAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) : result.after ≤ text.length + 1 := by
  cases source with
  | booleanNot _ _ inner | pureBoolean _ _ _ _ _ inner | primary _ _ _ _ _ _ inner _ =>
      exact booleanRelation_source_bound inner positionBound
  | length _ _ _ _ right _ => exact length_source_bound right
  | scalars _ _ _ _ _ right _ => exact right.cursorBounds.2.2
  | strings _ _ _ _ left right _ _ _ =>
      have bounded := stringTail_source_bound right
        (comparison_bound text _ (stringTail_source_bound left positionBound))
      exact bounded
  | character _ _ _ _ _ inner _ => exact characterRelation_after_bounded inner

private theorem chain_source_bound_aux (fuel : Nat) {text context initials} :
    ∀ {incoming originalStart condition result chained final finalResult},
      remainingAt text result.after < fuel →
      ChainAt text context condition result chained final finalResult incoming initials originalStart →
      result.after ≤ text.length + 1 → finalResult.after ≤ text.length + 1 := by
  induction fuel with
  | zero => intro incoming originalStart condition result chained final finalResult smaller source bounded; omega
  | succ fuel ih =>
      intro incoming originalStart condition result chained final finalResult smaller source positionBound
      cases source with
      | done => exact positionBound
      | @next _ _ _ _ _ operator _ _ _ _ _ _ _ _ _ _ _ right _ _ advance rest =>
          have bounded := relation_source_bound right (chainAfter_bound text _ operator positionBound)
          apply ih (by omega) rest
          cases operator <;> exact bounded

theorem chain_source_bound {text context condition result chained final finalResult incoming initials originalStart}
    (source : ChainAt text context condition result chained final finalResult incoming initials originalStart)
    (positionBound : result.after ≤ text.length + 1) : finalResult.after ≤ text.length + 1 :=
  chain_source_bound_aux (remainingAt text result.after + 1) (by omega) source positionBound

theorem condition_source_bound {text context position facts condition result initials}
    (source : ConditionAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) : result.after ≤ text.length + 1 := by
  cases source with
  | condition _ first _ _ tail =>
      exact chain_source_bound tail (relation_source_bound first positionBound)

theorem condition_source_advance {text context position facts condition result initials}
    (source : ConditionAt text context position facts condition result initials) : position < result.after := by
  have progress := Native.condition_progress text context position facts
    (initials := initials) (by rw [condition_complete source]; exact condition_source_positive source)
  simpa only [condition_complete source] using progress

theorem primary_source_advance {text context position facts condition result initials}
    (source : PrimaryAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) : position < result.after := by
  cases source with
  | group _ opening _ inner closing =>
      have opened := Compose.Expressions.model_fixed_advances text position "(" false positionBound (by decide) opening
      have innerAdvance := condition_source_advance inner
      have innerBound := condition_source_bound inner (fixedAfter_result_bound text position "(" false (by decide))
      have closed := Compose.Expressions.model_fixed_advances text _ ")" false innerBound (by decide) closing
      dsimp only
      omega
  | booleanArray _ _ _ _ atom => cases atom with | read _ _ _ _ _ _ _ advance => exact advance
  | boolean positive _ _ _ _ atom =>
      have skipped := ScalarExpression.skip_bounds text position positionBound
      change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at skipped
      cases atom with
      | name reference _ | literal reference _ _ _ =>
          have advance := reference_source_advance reference positionBound
          exact advance
  | valid _ _ _ _ _ accepted => exact Compose.Expressions.model_callAfter_advances text _ _ _ positionBound accepted

theorem booleanFactor_source_advance {text context position facts condition result initials}
    (source : BooleanFactorAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) : position < result.after := by
  cases source with
  | primary _ inner => exact primary_source_advance inner positionBound
  | negated opening _ inner =>
      have opened := Compose.Expressions.model_fixed_advances text position "not" true positionBound (by decide) opening
      have advance := primary_source_advance inner (fixedAfter_result_bound text position "not" true (by decide))
      exact Nat.lt_trans opened advance

theorem booleanRelation_source_advance {text context position facts condition result initials}
    (source : BooleanRelationAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) : position < result.after := by
  cases source with
  | factor inner _ _ => exact booleanFactor_source_advance inner positionBound
  | comparison left _ _ _ progress right _ =>
      have advance := booleanFactor_source_advance right
        (comparison_bound text _ (booleanFactor_source_bound left positionBound))
      unfold remainingAt at progress
      dsimp only
      omega

theorem relation_source_advance {text context position facts condition result initials}
    (source : RelationAt text context position facts condition result initials)
    (positionBound : position ≤ text.length + 1) : position < result.after := by
  cases source with
  | booleanNot _ _ inner | pureBoolean _ _ _ _ _ inner | primary _ _ _ _ _ _ inner _ =>
      exact booleanRelation_source_advance inner positionBound
  | length _ _ _ _ _ advance | scalars _ _ _ _ _ _ advance | strings _ _ _ _ _ _ _ advance _ => exact advance
  | character _ _ _ _ _ inner _ => cases inner with | comparison _ _ _ _ advance _ => exact advance

theorem chain_source_nondecreasing {text context condition result chained final finalResult incoming initials originalStart}
    (source : ChainAt text context condition result chained final finalResult incoming initials originalStart) :
    result.after ≤ finalResult.after := by
  have advance := Native.tail_nondecreasing text context result chained incoming
    (initials := initials) (originalStart := originalStart)
    (by rw [chain_complete source]; exact chain_source_positive source)
  simpa only [chain_complete source] using advance

end Silver.Predicate

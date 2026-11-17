module

public import Silver.ProcedureNameLengthReadings
public import Silver.PredicateNativeProgress

@[expose] public section

namespace Silver.Predicate
open Compose

theorem length_source_advance {text context position literal operand result}
    (source : LengthAt text context position literal operand result)
    (positionBound : position ≤ text.length + 1) : position < result.after := by
  cases source with
  | number _ number =>
      have bounds := IntegerLiteral.integer_bounds number
      have skipped := ScalarExpression.skip_bounds text position positionBound
      change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at skipped
      dsimp only
      omega
  | @binding index info name after _ indexEq found _ _ identifier afterEq positive =>
      have indexPositive : index ≠ 0 := by
        intro zero
        simp [Bindings.BindingEnvironment.get, zero] at found
      have nameFields := lookupName_found (indexEq ▸ indexPositive)
      have bounds := Named.identifier_bounds identifier
      have skipped := skipAt_advances text position positionBound nameFields.1
      have tickBound := fixedAfter_result_bound text (nameAfter text (skipAt text position)) "'" false (by decide)
      have fullPositive : fixedAfter text (fixedAfter text (nameAfter text (skipAt text position)) "'" false) "length" true ≠ 0 := by
        simpa only [afterEq] using positive
      have tickPositive := Compose.Expressions.model_fixed_input_nonzero text _ "length" true fullPositive
      have tickAdvance := Compose.Expressions.model_fixed_advances text _ "'" false bounds.2.2.2 (by decide) tickPositive
      have attributeAdvance := Compose.Expressions.model_fixed_advances text _ "length" true tickBound (by decide) fullPositive
      dsimp only
      omega

theorem primary_source_positive {text context position facts condition result initials}
    (source : PrimaryAt text context position facts condition result initials) : result.after ≠ 0 := by
  cases source with
  | group _ _ _ _ positive => exact positive
  | booleanArray _ _ _ positive _ => exact positive
  | boolean _ _ _ _ positive _ => exact positive
  | valid _ _ _ _ _ positive => exact positive

theorem booleanFactor_source_positive {text context position facts condition result initials}
    (source : BooleanFactorAt text context position facts condition result initials) : result.after ≠ 0 := by
  cases source with
  | primary _ inner => exact primary_source_positive inner
  | negated _ _ inner =>
      have positive := primary_source_positive inner
      exact positive

theorem booleanRelation_source_positive {text context position facts condition result initials}
    (source : BooleanRelationAt text context position facts condition result initials) : result.after ≠ 0 := by
  cases source with
  | factor _ positive _ => exact positive
  | comparison _ _ _ _ _ _ positive => exact positive

theorem relation_source_positive {text context position facts condition result initials}
    (source : RelationAt text context position facts condition result initials) : result.after ≠ 0 := by
  cases source with
  | booleanNot _ _ inner | pureBoolean _ _ _ _ _ inner | primary _ _ _ _ _ _ inner _ =>
      exact booleanRelation_source_positive inner
  | length _ _ _ _ _ advance => exact Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advance)
  | scalars _ _ _ _ _ _ advance => exact Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advance)
  | strings _ _ _ _ _ _ ready _ _ => exact ready.2.2.2.1
  | character _ _ _ _ _ inner _ =>
      cases inner with
      | comparison _ _ _ _ advance _ => exact Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advance)

private theorem chain_source_positive_aux (fuel : Nat) {text context initials} :
    ∀ {incoming originalStart condition result chained final finalResult},
      remainingAt text result.after < fuel →
      ChainAt text context condition result chained final finalResult incoming initials originalStart →
      finalResult.after ≠ 0 := by
  induction fuel with
  | zero => intro incoming originalStart condition result chained final finalResult smaller source; omega
  | succ fuel ih =>
      intro incoming originalStart condition result chained final finalResult smaller source
      cases source with
      | done positive _ => exact positive
      | next _ _ _ _ _ _ _ _ _ _ advance rest => exact ih (by omega) rest

theorem chain_source_positive {text context condition result chained final finalResult incoming initials originalStart}
    (source : ChainAt text context condition result chained final finalResult incoming initials originalStart) :
    finalResult.after ≠ 0 :=
  chain_source_positive_aux (remainingAt text result.after + 1) (by omega) source

theorem condition_source_positive {text context position facts condition result initials}
    (source : ConditionAt text context position facts condition result initials) : result.after ≠ 0 := by
  cases source with
  | condition _ _ _ _ tail => exact chain_source_positive tail

theorem relation_source_input {text context position facts condition result initials}
    (source : RelationAt text context position facts condition result initials) : position ≠ 0 := by
  cases source <;> assumption

theorem condition_source_input {text context position facts condition result initials}
    (source : ConditionAt text context position facts condition result initials) : position ≠ 0 := by
  cases source with
  | condition _ first _ _ _ => exact relation_source_input first

end Silver.Predicate

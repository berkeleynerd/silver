module

public import Silver.ComposeCharacterProperties
public import Silver.ComposeBounds

@[expose] public section

namespace Silver.Compose
open Named Bindings

/-- Character parsing never recovers from the failed-cursor sentinel. -/
theorem character_input_nonzero {text names scalarNames arrays initials elaborating position expression result}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    position ≠ 0 := by
  cases parsed with
  | literal _ source =>
      intro zero
      have positive := source.positive
      simp [zero, skipAt] at positive
  | reference _ _ selected nonzero _ _ _ =>
      have positive := (lookupName_found (selected ▸ nonzero)).1
      intro zero
      simp [zero, skipAt] at positive
  | indexed _ _ _ source =>
      have positive := (lookupName_found source.targetPositive).1
      intro zero
      simp [zero, skipAt] at positive
  | parenthesized positive _ _ _ =>
      intro zero
      simp [zero, skipAt, fixedAfter] at positive

theorem binding_get_count {names : BindingEnvironment} {index : Nat} {info : BindingInfo}
    (present : names.get index = some info) : index ≤ names.length := by
  by_cases zero : index = 0
  · omega
  · have bound := (List.getElem?_eq_some_iff.mp (by
        simpa only [BindingEnvironment.get, zero, ↓reduceIte] using present)).1
    omega

theorem character_storage_fields {text names scalarNames arrays initials elaborating position expression result}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result) :
    result.valueFirst = 0 ∧ result.reference ≤ names.length := by
  induction parsed with
  | literal => simp [characterValue]
  | reference _ _ _ _ present _ _ => exact ⟨rfl, binding_get_count present⟩
  | indexed _ _ _ source => exact ⟨rfl, binding_get_count source.selected⟩
  | parenthesized _ _ _ _ ih => exact ih

theorem character_value_valid {text names scalarNames arrays initials elaborating position expression result}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result)
    (count : names.length ≤ maxBindings) : Expressions.ValidValue text result := by
  have fields := character_storage_fields parsed
  have metadata := character_metadata parsed
  exact ⟨character_after_bounded parsed, by rw [fields.1]; omega,
    by rw [metadata.2.2.1]; decide, Nat.le_trans fields.2 count,
    by rw [metadata.2.1]; decide⟩

theorem character_advances {text names scalarNames arrays initials elaborating position expression result}
    (parsed : CharacterAt text names scalarNames arrays initials elaborating position expression result)
    (bound : position ≤ text.length + 1) : position < result.after := by
  induction parsed with
  | literal _ source =>
      have skipped := skipAt_advances text _ bound source.positive
      simp only [characterValue, source.following]
      omega
  | reference _ _ selected nonzero _ _ _ =>
      have found := lookupName_found (selected ▸ nonzero)
      have skipped := skipAt_advances text _ bound found.1
      simp only [characterValue]
      omega
  | indexed _ _ _ source => exact source.following
  | @parenthesized pos inner result _ advancing source close ih =>
      have openBound := fixedAfter_result_bound text (skipAt text pos) "(" false (by decide)
      have inner := ih openBound
      have following := Expressions.model_fixed_advances text _ ")" false
        (character_after_bounded source) (by decide) close
      simp only
      omega

end Silver.Compose

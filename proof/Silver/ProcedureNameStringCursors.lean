module

public import Silver.ComposeSemantics
public import Silver.ComposeBounds

@[expose] public section

namespace Silver.Predicate
open Compose

/-- Cursor bounds follow the retained source productions even when metadata
fields unrelated to source spans are outside native value-summary domains. -/
theorem stringValue_source_bound {text names scalarNames integerHidden arrays initials elaborating position value result}
    (source : ValueAt text names position value result scalarNames integerHidden arrays initials elaborating) :
    result.after ≤ text.length + 1 := by
  cases source with
  | literal _ _ _ literal => exact (Output.literalAt_bounds literal).2.1
  | reference _ identifier _ _ _ _ _ _ => exact (Named.identifier_bounds identifier).2.2.2
  | slice => exact fixedAfter_result_bound text _ ")" false (by decide)
  | image => exact fixedAfter_result_bound text _ ")" false (by decide)

theorem stringEmission_source_bound {text names scalarNames integerHidden arrays initials elaborating scan emitted}
    (source : EmissionAt text names scan emitted scalarNames integerHidden arrays initials elaborating)
    (positionBound : scan.position ≤ text.length + 1) :
    (expressionStep text names scan scalarNames integerHidden arrays initials elaborating).position ≤ text.length + 1 := by
  have atomBound : scan.needOperand = true ∧ fixedAfter text scan.position "(" false = 0 →
      (valueAt text scan.position names scalarNames integerHidden arrays initials elaborating).after ≤ text.length + 1 := by
    intro reading
    have parsed := source
    rw [EmissionAt, ite_eq_left reading] at parsed
    obtain ⟨atom, atomSource, _⟩ := parsed
    exact stringValue_source_bound atomSource
  have openBound := fixedAfter_result_bound text scan.position "(" false (by decide)
  have joinBound := fixedAfter_result_bound text scan.position "&" false (by decide)
  have closeBound := fixedAfter_result_bound text scan.position ")" false (by decide)
  unfold expressionStep
  dsimp only
  split
  · exact Nat.zero_le _
  · split
    · exact positionBound
    · split
      · rename_i need
        split
        · exact openBound
        · rename_i notOpened
          split
          · exact Nat.zero_le _
          · exact atomBound ⟨need, by omega⟩
      · split
        · exact joinBound
        · split
          · exact closeBound
          · split
            · exact positionBound
            · exact Nat.zero_le _

theorem stringTail_source_bound {text names scalarNames integerHidden arrays initials elaborating scan expression result}
    (source : ExpressionTailAt text names scan expression result scalarNames integerHidden arrays initials elaborating)
    (positionBound : scan.position ≤ text.length + 1) : result.after ≤ text.length + 1 := by
  induction source with
  | done => exact positionBound
  | last _ _ _ _ emitted => exact stringEmission_source_bound emitted positionBound
  | next _ _ _ _ _ emitted _ ih => exact ih (stringEmission_source_bound emitted positionBound)

end Silver.Predicate

module

public import Silver.PredicateAssociationAdmission
public import Silver.ComposeBounds
public import Silver.ScalarExpressionBounds

@[expose] public section

namespace Silver.Predicate
open Compose

theorem functionAssociation_payload_bound (text : Source) (position : Nat)
    (catalog : FunctionBindings.Metadata) (first last ordinal : Nat) (named : Bool)
    (bounded : position ≤ text.length + 1) :
    (functionAssociation text position catalog first last ordinal named).payloadFirst ≤ text.length + 1 := by
  dsimp only [functionAssociation]
  split
  · exact Nat.zero_le _
  · split
    · exact Compose.Expressions.model_fixed_valid text _ "=>" false (Compose.Expressions.model_name_valid text _)
    · split
      · exact Nat.zero_le _
      · exact bounded

theorem procedureAssociation_payload_bound (text : Source) (position : Nat)
    (catalog : ProcedureBindings.Metadata) (first last ordinal : Nat) (named : Bool)
    (bounded : position ≤ text.length + 1) :
    (procedureAssociation text position catalog first last ordinal named).payloadFirst ≤ text.length + 1 := by
  dsimp only [procedureAssociation]
  split
  · exact Nat.zero_le _
  · split
    · exact Compose.Expressions.model_fixed_valid text _ "=>" false (Compose.Expressions.model_name_valid text _)
    · split
      · exact Nat.zero_le _
      · exact bounded

theorem functionAssociation_payload_order {text position catalog first last ordinal named}
    (bounded : position ≤ text.length + 1)
    (found : (functionAssociation text position catalog first last ordinal named).formal ≠ 0) :
    position ≤ (functionAssociation text position catalog first last ordinal named).payloadFirst := by
  dsimp only [functionAssociation] at found ⊢
  split
  · simp_all [invalidAssociation]
  · split
    · rename_i arrow
      have namePositive := Compose.Expressions.model_fixed_input_nonzero text _ "=>" false arrow
      have nameAdvance := Compose.Expressions.model_name_advances text _ namePositive
      have skipped := ScalarExpression.skip_bounds text position bounded
      change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at skipped
      have arrowAdvance := Compose.Expressions.model_fixed_advances text _ "=>" false
        (Compose.Expressions.model_name_valid text _) (by decide) arrow
      dsimp only
      omega
    · split
      · simp_all [invalidAssociation]
      · exact Nat.le_refl _

theorem procedureAssociation_payload_order {text position catalog first last ordinal named}
    (bounded : position ≤ text.length + 1)
    (found : (procedureAssociation text position catalog first last ordinal named).formal ≠ 0) :
    position ≤ (procedureAssociation text position catalog first last ordinal named).payloadFirst := by
  dsimp only [procedureAssociation] at found ⊢
  split
  · simp_all [invalidAssociation]
  · split
    · rename_i arrow
      have namePositive := Compose.Expressions.model_fixed_input_nonzero text _ "=>" false arrow
      have nameAdvance := Compose.Expressions.model_name_advances text _ namePositive
      have skipped := ScalarExpression.skip_bounds text position bounded
      change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at skipped
      have arrowAdvance := Compose.Expressions.model_fixed_advances text _ "=>" false
        (Compose.Expressions.model_name_valid text _) (by decide) arrow
      dsimp only
      omega
    · split
      · simp_all [invalidAssociation]
      · exact Nat.le_refl _

end Silver.Predicate

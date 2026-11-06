module

public import Silver.PredicateBodyAdmission

@[expose] public section
namespace Silver.Predicate

/-- Every typed byte-store update either fails or preserves its incoming flow
and capacity, selecting one existing target and recording an assignment. -/
theorem stringAssignment_fields (text : Source) (context : ParseContext) (scan : BodyScan) :
    stringAssignmentBody text context scan = invalidBody scan ∨
      (stringAssignmentBody text context scan).target = (stringAssignmentTarget text context scan).target ∧
      (stringAssignmentBody text context scan).capacity = scan.capacity ∧
      (stringAssignmentBody text context scan).facts = scan.facts ∧
      (stringAssignmentBody text context scan).assigned = true ∧
      (stringAssignmentBody text context scan).output = scan.output := by
  unfold stringAssignmentBody
  dsimp only
  split
  · exact Or.inl rfl
  · cases stringAssignmentKind text context scan <;> dsimp only
    all_goals split
    all_goals first | exact Or.inl rfl | exact Or.inr ⟨rfl, rfl, rfl, rfl, rfl⟩

theorem stringAssignment_success_fields {text context scan}
    (positive : (stringAssignmentBody text context scan).position ≠ 0) :
      (stringAssignmentBody text context scan).target = (stringAssignmentTarget text context scan).target ∧
      (stringAssignmentBody text context scan).capacity = scan.capacity ∧
      (stringAssignmentBody text context scan).facts = scan.facts ∧
      (stringAssignmentBody text context scan).assigned = true ∧
      (stringAssignmentBody text context scan).output = scan.output := by
  rcases stringAssignment_fields text context scan with failed | fields
  · rw [failed] at positive
    exact False.elim (positive rfl)
  · exact fields

end Silver.Predicate

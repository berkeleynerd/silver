module

public import Silver.ScalarProcedureComposition

@[expose] public section

namespace Silver.ScalarProcedures

/-- Later function declarations enlarge the global evaluator but never the
function-signature prefix visible to an already accepted procedure body. -/
theorem Definition.checked_functions_append {definition : Definition}
    {functions : ScalarFunctions.Signatures} {earlier : Signatures}
    (checked : definition.Checked functions earlier) (more : ScalarFunctions.Signatures) :
    definition.Checked (functions ++ more) earlier := by
  obtain ⟨formed, after, checked⟩ := checked
  have parts := (definition.check_iff functions earlier after).mp checked
  have ready := (definition.ready_iff functions).mp parts.1
  have callablePrefix : (functions ++ more).take definition.functionCount = functions.take definition.functionCount :=
    List.take_append_of_le_length ready.2.2.2.2.2
  refine ⟨formed, after, (definition.check_iff (functions ++ more) earlier after).mpr ⟨?_, ?_⟩⟩
  · apply (definition.ready_iff (functions ++ more)).mpr
    refine ⟨ready.1, ready.2.1, ready.2.2.1, ready.2.2.2.1, ready.2.2.2.2.1, ?_⟩
    have bound := ready.2.2.2.2.2
    simp only [List.length_append]
    omega
  · simpa only [callablePrefix] using parts.2

theorem definitionsChecked_functions_append {functions : ScalarFunctions.Signatures}
    {earlier : Signatures} {definitions : List Definition}
    (checked : DefinitionsChecked functions earlier definitions) (more : ScalarFunctions.Signatures) :
    DefinitionsChecked (functions ++ more) earlier definitions := by
  induction definitions generalizing earlier with
  | nil => trivial
  | cons definition rest ih =>
      exact ⟨definition.checked_functions_append checked.1 more, ih checked.2⟩

end Silver.ScalarProcedures

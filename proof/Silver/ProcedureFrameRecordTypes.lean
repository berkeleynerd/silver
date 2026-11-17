module

public import Silver.ProcedureFrameValidity
public import Silver.FunctionDeclarationRecordTypes

@[expose] public section

/-! Complete native record domains stay in the raw source layer, independently
of the pure procedure-frame syntax and layout lemmas. -/
namespace Silver.Compose

namespace FunctionDeclarationNative

/-- Append_Procedure_Parameter has no logical precondition. Its interpretation
therefore retains arbitrary typed formal spans and intervals, including empty
intervals, across both success and capacity-failure branches. -/
theorem appendProcedureParameter_record (frame : ParserState) (parameter : ProcedureBindings.Formal)
    (typed : StateRecord frame) (parameterTyped : ProcedureBindings.Native.FormalType parameter) :
    StateRecord (appendProcedureParameter frame parameter) := by
  dsimp only [appendProcedureParameter]
  split
  · split
    · exact invalid_state_record
    · refine {typed with scalars := ?_}
      refine ⟨by have bound := typed.scalars.1; simp only [List.length_append, List.length_singleton]; omega, ?_⟩
      intro item member
      rcases List.mem_append.mp member with old | fresh
      · exact typed.scalars.2 item old
      · have same := List.mem_singleton.mp fresh
        subst item
        exact ⟨parameterTyped.1, parameterTyped.2.1, parameterTyped.2.2, parameterTyped.2.2⟩
  · split
    · exact invalid_state_record
    · refine {typed with booleans := ?_}
      refine ⟨by have bound := typed.booleans.1; simp only [List.length_append, List.length_singleton]; omega, ?_⟩
      intro item member
      rcases List.mem_append.mp member with old | fresh
      · exact typed.booleans.2 item old
      · have same := List.mem_singleton.mp fresh
        subst item
        exact ⟨parameterTyped.1, parameterTyped.2.1⟩

end FunctionDeclarationNative
end Silver.Compose

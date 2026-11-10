module

public import Silver.ProcedureHeaderAdmission
public import Silver.FunctionDeclarationRecordTypes

@[expose] public section

namespace Silver.Compose

/-- Successful formal binding changes only the two scalar binding tables.
In particular, signature pools, name-hiding flags and both formal cursors stay
attached to their exact declaration frame. -/
def ProcedureFrameFields (before after : ParserState) : Prop :=
  after = {before with scalarNames := after.scalarNames, booleanNames := after.booleanNames}

theorem ProcedureFrameFields.trans {first middle last : ParserState}
    (before : ProcedureFrameFields first middle) (after : ProcedureFrameFields middle last) :
    ProcedureFrameFields first last := by
  unfold ProcedureFrameFields at *
  rw [before] at after
  exact after

theorem appendProcedureParameter_fields (frame : ParserState) (parameter : ProcedureBindings.Formal)
    (accepted : (appendProcedureParameter frame parameter).position ≠ 0) :
    ProcedureFrameFields frame (appendProcedureParameter frame parameter) := by
  dsimp only [appendProcedureParameter] at accepted ⊢
  split <;> split <;> simp_all [ProcedureFrameFields, invalidState]

theorem appendProcedureParameter_grows (frame : ParserState) (parameter : ProcedureBindings.Formal)
    (accepted : (appendProcedureParameter frame parameter).position ≠ 0) :
    frame.scalarNames.length ≤ (appendProcedureParameter frame parameter).scalarNames.length ∧
      frame.booleanNames.length ≤ (appendProcedureParameter frame parameter).booleanNames.length := by
  dsimp only [appendProcedureParameter] at accepted ⊢
  split <;> split <;> simp_all [invalidState]

theorem procedureInputFrameModel_preserves (frame : ParserState) (index : Nat) :
    (procedureInputFrameModel frame index).position = 0 ∨
      (ProcedureFrameFields frame (procedureInputFrameModel frame index) ∧
        frame.scalarNames.length ≤ (procedureInputFrameModel frame index).scalarNames.length ∧
        frame.booleanNames.length ≤ (procedureInputFrameModel frame index).booleanNames.length) := by
  rw [procedureInputFrameModel]
  split
  · exact .inl rfl
  · split
    · exact .inr ⟨rfl, Nat.le_refl _, Nat.le_refl _⟩
    · split
      · exact procedureInputFrameModel_preserves frame (index + 1)
      · dsimp only
        split
        · exact .inl rfl
        · rename_i nextPositive
          split
          · rcases procedureInputFrameModel_preserves
                (appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index))
                (index + 1) with rejected | preserved
            · exact .inl rejected
            · have first := appendProcedureParameter_grows frame _ nextPositive
              exact .inr ⟨(appendProcedureParameter_fields frame _ nextPositive).trans preserved.1,
                Nat.le_trans first.1 preserved.2.1, Nat.le_trans first.2 preserved.2.2⟩
          · exact .inl rfl
termination_by frame.procedures.parameters.length + 1 - index
decreasing_by all_goals first | omega | assumption

theorem procedureInputFrameModel_fields (frame : ParserState) (index : Nat)
    (accepted : (procedureInputFrameModel frame index).position ≠ 0) :
    ProcedureFrameFields frame (procedureInputFrameModel frame index) :=
  ((procedureInputFrameModel_preserves frame index).resolve_left accepted).1

theorem procedureInputFrameModel_grows (frame : ParserState) (index : Nat)
    (accepted : (procedureInputFrameModel frame index).position ≠ 0) :
    frame.scalarNames.length ≤ (procedureInputFrameModel frame index).scalarNames.length ∧
      frame.booleanNames.length ≤ (procedureInputFrameModel frame index).booleanNames.length :=
  ((procedureInputFrameModel_preserves frame index).resolve_left accepted).2

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

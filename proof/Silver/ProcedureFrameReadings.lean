module

public import Silver.ProcedureFrameValidity

@[expose] public section

namespace Silver.Compose

/-- The input frame follows the actual pooled formal order, skipping every out
formal. Successful append steps retain their full native capacity guards. -/
inductive ProcedureInputFramesAt : ParserState → Nat → ParserState → Prop
  | done {frame : ParserState} {index : Nat} : frame.position ≠ 0 →
      frame.procedures.parameters.length < index → ProcedureInputFramesAt frame index frame
  | skip {frame final : ParserState} {index : Nat} : frame.position ≠ 0 →
      index ≤ frame.procedures.parameters.length →
      (ProcedureBindings.parameter frame.procedures index).mode = .output →
      ProcedureInputFramesAt frame (index + 1) final → ProcedureInputFramesAt frame index final
  | next {frame final : ParserState} {index : Nat} : frame.position ≠ 0 →
      index ≤ frame.procedures.parameters.length →
      (ProcedureBindings.parameter frame.procedures index).mode ≠ .output →
      (appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index)).position ≠ 0 →
      (appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index)).procedures.parameters.length + 1 -
          (index + 1) < frame.procedures.parameters.length + 1 - index →
      ProcedureInputFramesAt (appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index))
        (index + 1) final → ProcedureInputFramesAt frame index final

theorem procedureInputFrames_reading_or_rejected (frame : ParserState) (index : Nat) :
    (procedureInputFrameModel frame index).position = 0 ∨
      ProcedureInputFramesAt frame index (procedureInputFrameModel frame index) := by
  rw [procedureInputFrameModel]
  split
  · exact .inl rfl
  · rename_i positive
    split
    · rename_i done
      exact .inr (.done positive done)
    · rename_i more
      split
      · rename_i output
        rcases procedureInputFrames_reading_or_rejected frame (index + 1) with rejected | reading
        · exact .inl rejected
        · exact .inr (.skip positive (by omega) output reading)
      · rename_i input
        dsimp only
        split
        · exact .inl rfl
        · rename_i accepted
          split
          · rename_i advanced
            rcases procedureInputFrames_reading_or_rejected
                (appendProcedureParameter frame (ProcedureBindings.parameter frame.procedures index)) (index + 1)
              with rejected | reading
            · exact .inl rejected
            · exact .inr (.next positive (by omega) input accepted advanced reading)
          · exact .inl rfl
termination_by frame.procedures.parameters.length + 1 - index
decreasing_by all_goals first | omega | assumption

theorem procedureInputFrames_reading {frame : ParserState} {index : Nat}
    (accepted : (procedureInputFrameModel frame index).position ≠ 0) :
    ProcedureInputFramesAt frame index (procedureInputFrameModel frame index) :=
  (procedureInputFrames_reading_or_rejected frame index).resolve_left accepted

theorem ProcedureInputFramesAt.complete {frame index final}
    (source : ProcedureInputFramesAt frame index final) : procedureInputFrameModel frame index = final := by
  induction source with
  | done positive stopped =>
      rw [procedureInputFrameModel, ite_eq_right positive, dite_eq_left stopped]
  | skip positive more output _ ih =>
      rw [procedureInputFrameModel, ite_eq_right positive, dite_eq_right (by omega),
        ite_eq_left output]
      exact ih
  | next positive more input accepted advanced _ ih =>
      rw [procedureInputFrameModel, ite_eq_right positive, dite_eq_right (by omega),
        ite_eq_right input]
      dsimp only
      rw [ite_eq_right accepted, dite_eq_left advanced]
      exact ih

theorem ProcedureInputFramesAt.positive {frame index final}
    (source : ProcedureInputFramesAt frame index final) : final.position ≠ 0 := by
  induction source with
  | done positive _ => exact positive
  | skip _ _ _ _ ih | next _ _ _ _ _ _ ih => exact ih

theorem ProcedureInputFramesAt.fields {frame index final}
    (source : ProcedureInputFramesAt frame index final) : ProcedureFrameFields frame final := by
  have accepted : (procedureInputFrameModel frame index).position ≠ 0 := source.complete.symm ▸ source.positive
  simpa only [source.complete] using procedureInputFrameModel_fields frame index accepted

theorem ProcedureInputFramesAt.grows {frame index final}
    (source : ProcedureInputFramesAt frame index final) :
    frame.scalarNames.length ≤ final.scalarNames.length ∧ frame.booleanNames.length ≤ final.booleanNames.length := by
  have accepted : (procedureInputFrameModel frame index).position ≠ 0 := source.complete.symm ▸ source.positive
  simpa only [source.complete] using procedureInputFrameModel_grows frame index accepted

end Silver.Compose

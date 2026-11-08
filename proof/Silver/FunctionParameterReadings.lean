module

public import Silver.FunctionBodyFrameReadiness

@[expose] public section

namespace Silver.Compose

/-- Formal installation retains the exact pooled metadata and all nonlocal
frame fields, changing only the Integer and Boolean binding stores. -/
def ParameterFrameFieldsPreserved (before after : ParserState) : Prop :=
  after = {before with scalarNames := after.scalarNames, booleanNames := after.booleanNames}

theorem appendParameter_fields_or_rejected (frame : ParserState) (parameter : FunctionBindings.Formal) :
    (appendParameter frame parameter).position = 0 ∨
      ParameterFrameFieldsPreserved frame (appendParameter frame parameter) := by
  dsimp only [appendParameter]
  split
  · split
    · exact .inl rfl
    · exact .inr rfl
  · split
    · exact .inl rfl
    · exact .inr rfl

inductive ParameterFramesAt : ParserState → Nat → ParserState → Prop
  | done {frame : ParserState} {index : Nat} : frame.position ≠ 0 →
      frame.functions.parameters.length < index → ParameterFramesAt frame index frame
  | next {frame final : ParserState} {index : Nat} : frame.position ≠ 0 →
      index ≤ frame.functions.parameters.length →
      (appendParameter frame (FunctionBindings.parameter frame.functions index)).position ≠ 0 →
      (appendParameter frame (FunctionBindings.parameter frame.functions index)).functions.parameters.length + 1 -
          (index + 1) < frame.functions.parameters.length + 1 - index →
      ParameterFramesAt (appendParameter frame (FunctionBindings.parameter frame.functions index)) (index + 1) final →
      ParameterFramesAt frame index final

theorem parameterFrames_reading_or_rejected (frame : ParserState) (index : Nat) :
    (parameterFrameModel frame index).position = 0 ∨
      ParameterFramesAt frame index (parameterFrameModel frame index) := by
  rw [parameterFrameModel]
  split
  · exact .inl rfl
  · rename_i positive
    split
    · rename_i done
      exact .inr (.done positive done)
    · rename_i more
      dsimp only
      split
      · exact .inl rfl
      · rename_i nextPositive
        split
        · rename_i advanced
          rcases parameterFrames_reading_or_rejected
              (appendParameter frame (FunctionBindings.parameter frame.functions index)) (index + 1)
            with rejected | reading
          · exact .inl rejected
          · exact .inr (.next positive (by omega) nextPositive advanced reading)
        · exact .inl rfl
termination_by frame.functions.parameters.length + 1 - index
decreasing_by all_goals omega

theorem parameterFrames_reading {frame : ParserState} {index : Nat}
    (accepted : (parameterFrameModel frame index).position ≠ 0) :
    ParameterFramesAt frame index (parameterFrameModel frame index) :=
  (parameterFrames_reading_or_rejected frame index).resolve_left accepted

theorem ParameterFramesAt.fields {frame index final}
    (source : ParameterFramesAt frame index final) : ParameterFrameFieldsPreserved frame final := by
  induction source with
  | done => rfl
  | @next before final index _ _ accepted _ _ ih =>
      have first := (appendParameter_fields_or_rejected before
        (FunctionBindings.parameter before.functions index)).resolve_left accepted
      unfold ParameterFrameFieldsPreserved at first ih ⊢
      calc
        final = {appendParameter before (FunctionBindings.parameter before.functions index) with
          scalarNames := final.scalarNames, booleanNames := final.booleanNames} := ih
        _ = _ := by rw [first]

end Silver.Compose

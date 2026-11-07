module

public import Silver.FunctionFrameValidity
public import Silver.PredicateInitialFlowValidity

@[expose] public section

namespace Silver.Compose
open Predicate Silver.Compose.Expressions

/-- Installing immutable formals never removes a local Integer binding. -/
theorem appendParameter_scalar_count_or_rejected (frame : ParserState) (parameter : FunctionBindings.Formal) :
    (appendParameter frame parameter).position = 0 ∨
      frame.scalarNames.length ≤ (appendParameter frame parameter).scalarNames.length := by
  dsimp only [appendParameter]
  split
  · split
    · exact .inl rfl
    · exact .inr (by simp only [List.length_append, List.length_singleton]; omega)
  · split
    · exact .inl rfl
    · exact .inr (Nat.le_refl _)

theorem parameterFrameModel_scalar_count_or_rejected (frame : ParserState) (index : Nat) :
    (parameterFrameModel frame index).position = 0 ∨
      frame.scalarNames.length ≤ (parameterFrameModel frame index).scalarNames.length := by
  rw [parameterFrameModel]
  split
  · exact .inl rfl
  · split
    · exact .inr (Nat.le_refl _)
    · dsimp only
      split
      · exact .inl rfl
      · rename_i accepted
        have grows := (appendParameter_scalar_count_or_rejected frame
          (FunctionBindings.parameter frame.functions index)).resolve_left accepted
        split
        · rcases parameterFrameModel_scalar_count_or_rejected
              (appendParameter frame (FunctionBindings.parameter frame.functions index)) (index + 1)
            with rejected | more
          · exact .inl rejected
          · exact .inr (Nat.le_trans grows more)
        · exact .inl rfl
termination_by frame.functions.parameters.length + 1 - index
decreasing_by all_goals omega

theorem parameterFrameModel_scalar_count {frame : ParserState} {index : Nat}
    (accepted : (parameterFrameModel frame index).position ≠ 0) :
    frame.scalarNames.length ≤ (parameterFrameModel frame index).scalarNames.length :=
  (parameterFrameModel_scalar_count_or_rejected frame index).resolve_left accepted

/-- The fixed local declaration prefix remains a valid body context after
immutable interval formals are appended. This applies to every valid native
frame satisfying the count bound, independently of source reachability. -/
theorem functionFrame_contextReady {text : Source} {frame : ParserState} (declarations : Nat)
    (valid : ValidState text frame) (ready : ScalarMetadata.HeaderReady frame.scalarNames)
    (count : declarations ≤ frame.scalarNames.length) :
    ScalarMetadata.ContextReady (ScalarExpression.bodyEnvironment frame.scalarNames) declarations false := by
  have all := (ready.baseReady valid.2.2.2.2.2.1.1).toContextReady
  refine ⟨all.body, ?_, ?_, all.mutableBounds, all.size⟩
  · simpa only [ScalarExpression.bodyEnvironment_length] using count
  · intro index positive declared
    exact all.declarationsNonempty index positive (Nat.le_trans declared count)

/-- Initial flow satisfies the smaller local declaration prefix as well as
its full storage extent; formals occupy the immutable refinable suffix. -/
theorem functionFrame_flowReady {text : Source} {frame : ParserState} (declarations : Nat)
    (valid : ValidState text frame) (ready : ScalarMetadata.HeaderReady frame.scalarNames)
    (path : PathFacts.Context) :
    ScalarMetadata.FlowReady (ScalarExpression.bodyEnvironment frame.scalarNames) declarations
      (ActiveFlow.initial (ScalarExpression.bodyEnvironment frame.scalarNames) path) := by
  have all := ready.bodyEnvironment.initial
    (ScalarExpression.bodyEnvironment_valid valid.2.2.2.2.2.1) path
  exact ⟨ScalarMetadata.initial_compatible .., all.bounded, all.contained, all.mutableNonempty⟩

theorem parameterFrame_contextReady {text : Source} {frame : ParserState}
    (valid : ValidState text frame) (ready : ScalarMetadata.HeaderReady frame.scalarNames)
    (positive : 0 < frame.firstParameter)
    (accepted : (parameterFrame text frame).position ≠ 0) :
    ScalarMetadata.ContextReady
      (ScalarExpression.bodyEnvironment (parameterFrame text frame).scalarNames)
      frame.scalarNames.length false :=
  functionFrame_contextReady frame.scalarNames.length
    (parameterFrameModel_valid frame.firstParameter valid positive)
    (parameterFrameModel_headerReady frame.firstParameter valid positive ready)
    (parameterFrameModel_scalar_count accepted)

theorem parameterFrame_flowReady {text : Source} {frame : ParserState}
    (valid : ValidState text frame) (ready : ScalarMetadata.HeaderReady frame.scalarNames)
    (positive : 0 < frame.firstParameter) (path : PathFacts.Context) :
    ScalarMetadata.FlowReady
      (ScalarExpression.bodyEnvironment (parameterFrame text frame).scalarNames)
      frame.scalarNames.length
      (ActiveFlow.initial (ScalarExpression.bodyEnvironment (parameterFrame text frame).scalarNames) path) :=
  functionFrame_flowReady frame.scalarNames.length
    (parameterFrameModel_valid frame.firstParameter valid positive)
    (parameterFrameModel_headerReady frame.firstParameter valid positive ready) path

end Silver.Compose

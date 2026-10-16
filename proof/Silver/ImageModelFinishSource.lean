module

public import Silver.ImageModelFinishNative
public import Silver.ImageModelStringSource
public import Silver.ImageModelTheorySource

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.ImageModel.SourceBridge

theorem finish_block : block "function" "finish" Source.imageModelBodyTokens =
    some FinishNative.render := by
  simp only [FinishNative.render, FinishNative.commands, FinishNative.Command.render,
    FinishNative.Command.renderElse, FinishNative.Command.list, List.foldr_cons, List.foldr_nil,
    FinishNative.Action.render, FinishNative.Test.render]
  decide +kernel

/-- These are the exact default fields used by the typed Finish initializer. -/
theorem plan_declaration : Silver.Lexical.SourceBridge.recordDeclaration "plan" Source.imageModelSpecTokens =
    some ["record", "kind", ":", "plan_kind", ":=", "invalid_model", ";", "bytes", ":", "byte_count", ":=", "0", ";",
      "declarations_offset", ":", "byte_count", ":=", "0", ";", "includes_offset", ":", "byte_count", ":=", "0", ";",
      "greatest_id", ":", "original_node_id", ":=", "0", ";", "end", "record"] := by decide +kernel

structure InterpretedFinish (run : FinishNative.Input → FinishNative.Plan) : Prop where
  commands : ∀ state, run state = FinishNative.commands.eval (FinishNative.initial state) (·.result)

theorem interpreted_finish (run : FinishNative.Input → FinishNative.Plan) (source : InterpretedFinish run)
    (state : FinishNative.Input) : run state = FinishNative.model state := by
  rw [source.commands, FinishNative.eval_model]

theorem actual_refine_offsets (run : FinishNative.Input → FinishNative.Plan) (source : InterpretedFinish run)
    (state : FinishNative.Input) (refined : (run state).kind = .refine) :
    (run state).declarations = state.declarations ∧ (run state).includes = state.includes ∧
      state.declarations < state.includes ∧ state.includes < state.bytes := by
  rw [interpreted_finish run source] at refined ⊢
  exact FinishNative.refine_offsets state refined

end Silver.ImageModel.SourceBridge

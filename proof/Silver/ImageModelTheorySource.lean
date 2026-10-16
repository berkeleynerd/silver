module

public import Silver.ImageModelTheoryNative

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000
namespace Silver.ImageModel.SourceBridge

theorem end_theory_block : block "procedure" "end_theory" Source.imageModelBodyTokens =
    some TheoryNative.render := by
  simp only [TheoryNative.render, TheoryNative.commands, TheoryNative.Command.render,
    TheoryNative.Command.renderElse, TheoryNative.Command.list, List.foldr_cons, List.foldr_nil,
    TheoryNative.Action.render, TheoryNative.Test.render]
  decide +kernel

structure InterpretedTheory (tables : Native.Tables) (matchCall : DecodedNative.MatchCall)
    (run : TheoryNative.Frame → TheoryNative.Frame) : Prop where
  commands : ∀ frame, run frame = TheoryNative.commands.eval tables matchCall frame

theorem interpreted_endTheory (tables : Native.Tables) (matchCall : DecodedNative.MatchCall)
    (run : TheoryNative.Frame → TheoryNative.Frame) (source : InterpretedTheory tables matchCall run)
    (frame : TheoryNative.Frame) : run frame = TheoryNative.model tables matchCall frame := by
  rw [source.commands, TheoryNative.eval_model]

/-- Exact complete normalized content follows from the native closing guard and
its streamed invariant. No accepted target may contain a changed field or an
extra declaration, and duplicate target names fail before their offsets matter. -/
theorem actual_selected_content (tables : Native.Tables) (matchCall : DecodedNative.MatchCall)
    (matcherSource : InterpretedMatcher tables matchCall)
    (run : TheoryNative.Frame → TheoryNative.Frame) (source : InterpretedTheory tables matchCall run)
    (frame : TheoryNative.Frame) (kind : Native.Theory) (input : List Nat)
    (target : frame.theory = some kind) (active : frame.matcher.inTheory = true)
    (invariant : MatchInvariant (tables.byte kind) (tables.length kind) input (frame.matcher.cells kind))
    (accepted : (run frame).failed = false) :
    frame.seen kind = false ∧ (input ++ [93]).length = tables.length kind ∧
      ∀ i, (h : i < (input ++ [93]).length) → (input ++ [93])[i] = tables.byte kind (i+1) := by
  rw [interpreted_endTheory tables matchCall run source] at accepted
  obtain ⟨_, unseen, live, position⟩ := TheoryNative.successful_selected tables matchCall frame kind target accepted
  have closed := actual_matcher_preserves tables matchCall matcherSource frame.matcher 93 active kind input invariant
  obtain ⟨length, _, bytes⟩ := closed live
  exact ⟨unseen, length.symm.trans position, bytes⟩

end Silver.ImageModel.SourceBridge

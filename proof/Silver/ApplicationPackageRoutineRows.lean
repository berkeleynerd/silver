module

public import Silver.ApplicationPackageFormalStorage
public import Silver.ApplicationPackageObjectFrameOrder

@[expose] public section

namespace Silver.ApplicationPackageFormalStorage
open Compose ApplicationPackageBodies ApplicationPackageRoutineFrame ApplicationPackageObjectRows

structure Retained (before after : ParserState) : Prop where
  position : after.position = before.position
  integers : after.scalarNames.Sublist before.scalarNames
  flags : after.booleanNames.Sublist before.booleanNames

private theorem hideParameter_retained {calls : ApplicationPackageRoutineFrame.Calls}
    (native : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    {text : Source} {info : PackageBindings.Metadata} {frame after : ParserState} {index : Nat}
    (run : hideParameter calls text info frame index = some after) : Retained frame after := by
  dsimp only [hideParameter] at run
  split at run
  · contradiction
  · split at run
    · contradiction
    · rename_i present
      cases run
      rw [native] at present ⊢
      have fields := ApplicationPackageFrames.Native.hideOuter_frame present
      exact ⟨fields.1, fields.2.1, fields.2.2.1⟩

private theorem hides_retained {calls : ApplicationPackageRoutineFrame.Calls}
    (native : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    {text : Source} {info : PackageBindings.Metadata} (indices : List Nat) {frame after : ParserState}
    (run : parameters (hideParameter calls text info) indices frame = some after) : Retained frame after := by
  induction indices generalizing frame with
  | nil => cases run; exact ⟨rfl, .refl _, .refl _⟩
  | cons index rest ih =>
    simp only [parameters] at run
    obtain ⟨middle, step, finish⟩ := Option.bind_eq_some_iff.mp run
    have first := hideParameter_retained native step
    have last := ih finish
    exact ⟨last.position.trans first.position, last.integers.trans first.integers, last.flags.trans first.flags⟩

/-- Every original outer binding is widened at entry, then the native hide
passes can only remove rows. Readable header formals are installed in order
after the survivors, with the cursor held at the end of the signature. -/
theorem routineFrame_tables {calls : ApplicationPackageRoutineFrame.Calls}
    (hide : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {text : Source} {globals after : ParserState} {info : PackageBindings.Metadata} {routine position : Nat}
    (parsed : routineFrame calls text globals info routine position = after) (present : after.position ≠ 0) :
    ∃ hidden, Retained (entryFrame calls globals position) hidden ∧
      Stored hidden after (chosen false info (formalIndices (info.routineAt routine))) := by
  unfold routineFrame withItem at parsed
  split at parsed
  · cases parsed; exact False.elim (present rfl)
  · split at parsed
    · cases parsed; exact False.elim (present rfl)
    · dsimp only at parsed
      split at parsed
      · cases parsed; exact False.elim (present rfl)
      · rename_i hidden hiddenRun
        split at parsed
        · cases parsed; exact False.elim (present rfl)
        · rename_i result stored
          split at parsed
          · cases parsed
            exact ⟨hidden, hides_retained hide _ hiddenRun, parameters_stored append info _ stored⟩
          · cases parsed; exact False.elim (present rfl)

private theorem outputInitializer_frame {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {formal : PackageBindings.Formal} {before after : InitializationFrame}
    (run : outputInitializer calls text info formal before = some after) :
    after.frame = {before.frame with position := after.frame.position} ∧ before.frame.position ≤ after.frame.position := by
  dsimp only [outputInitializer] at run
  split at run
  · cases run; exact ⟨rfl, Nat.le_refl _⟩
  · split at run
    · contradiction
    · split at run
      · contradiction
      · split at run
        · contradiction
        · rename_i advanced
          cases run
          exact ⟨rfl, Nat.le_of_lt (Nat.lt_of_not_ge advanced)⟩

theorem outputInitializers_frame {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} (indices : List Nat) {before after : InitializationFrame}
    (run : outputInitializers calls text info indices before = some after) :
    after.frame = {before.frame with position := after.frame.position} ∧ before.frame.position ≤ after.frame.position := by
  induction indices generalizing before with
  | nil => cases run; exact ⟨rfl, Nat.le_refl _⟩
  | cons index rest ih =>
    simp only [outputInitializers] at run
    obtain ⟨middle, step, finish⟩ := Option.bind_eq_some_iff.mp run
    have first := outputInitializer_frame step
    have last := ih finish
    refine ⟨last.1.trans ?_, Nat.le_trans first.2 last.2⟩
    rw [first.1]

end Silver.ApplicationPackageFormalStorage

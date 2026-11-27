module

public import Silver.ApplicationPackageBodiesExecution

@[expose] public section

namespace Silver.ApplicationPackageBodies
open ApplicationPackageDeclarations (ObjectResult)

structure LocalObject where
  before : InitializationFrame
  object : ObjectResult

def LocalObject.after (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata)
    (row : LocalObject) : InitializationFrame :=
  {row.before with frame := row.object.frame, reads := (PackageBindings.stateUnion row.before.reads
    (calls.stateReads text (calls.contextOf ⟨row.object.frame, false, false⟩) info row.object.initFirst row.object.initAfter))}

def formalConflict (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (state : InitializationFrame) : Bool :=
  let first := calls.skipAt text state.frame.position
  let last := calls.nameAfter text first
  (formalIndices item).any fun index => calls.sameName text ⟨first, last⟩ (info.parameterAt index).bodyName

/-- The declaration-order history exposes the frame entering each Object_At,
the returned name and initializer spans, and the exact frame whose names the
subsequent effect scan uses. -/
inductive LocalObjects (calls : CompletionCalls) (text : Source) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) : InitializationFrame → List LocalObject → InitializationFrame → Prop where
  | finished {state : InitializationFrame} (atBegin : calls.takeToken text state.frame.position (.word "begin") ≠ 0) :
      LocalObjects calls text info item state [] state
  | added {row : LocalObject} {final : InitializationFrame} {following : List LocalObject}
      (beforeBegin : calls.takeToken text row.before.frame.position (.word "begin") = 0)
      (apart : formalConflict calls text info item row.before = false)
      (parsed : calls.objectAt text row.before.frame info true = row.object)
      (advances : row.before.frame.position < row.object.frame.position)
      (rest : LocalObjects calls text info item (row.after calls text info) following final) :
      LocalObjects calls text info item row.before (row :: following) final

set_option maxRecDepth 8000 in
theorem localExecution_objects {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {state final : InitializationFrame}
    (run : LocalExecution (localStep calls text info item) state (some final)) :
    ∃ rows, LocalObjects calls text info item state rows final := by
  generalize result : some final = outcome at run
  induction run with
  | failed _ => contradiction
  | finished step =>
    cases result
    dsimp only [localStep] at step
    split at step
    · rename_i started
      cases step
      exact ⟨[], .finished started⟩
    · split at step
      · contradiction
      · split at step <;> contradiction
  | @continued before next _ step _ ih =>
    obtain ⟨rest, read⟩ := ih result
    dsimp only [localStep] at step
    split at step
    · contradiction
    · rename_i notBegin
      split at step
      · contradiction
      · rename_i apart
        split at step
        · contradiction
        · rename_i advances
          cases step
          let row : LocalObject := ⟨before, calls.objectAt text before.frame info true⟩
          refine ⟨row :: rest, .added (row := row) (Classical.not_not.mp notBegin) ?_ rfl (Nat.lt_of_not_ge advances) read⟩
          exact Bool.eq_false_iff.mpr apart

theorem localsFuel_objects {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {fuel : Nat} {state final : InitializationFrame}
    (finished : localsFuel (localStep calls text info item) fuel state = some (some final)) :
    ∃ rows, LocalObjects calls text info item state rows final :=
  localExecution_objects (localsFuel_sound finished)

theorem LocalObjects.cursor_order {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {state final : InitializationFrame} {rows : List LocalObject}
    (history : LocalObjects calls text info item state rows final) :
    state.frame.position ≤ final.frame.position ∧
      ∀ row ∈ rows, state.frame.position ≤ row.before.frame.position ∧
        row.before.frame.position < row.object.frame.position ∧ row.object.frame.position ≤ final.frame.position := by
  induction history with
  | finished => exact ⟨Nat.le_refl _, by simp⟩
  | @added row _ _ _ _ _ advanced _ ih =>
    obtain ⟨finished, others⟩ := ih
    change row.object.frame.position ≤ _ at finished
    constructor
    · exact Nat.le_trans (Nat.le_of_lt advanced) finished
    · intro observed member
      rcases List.mem_cons.mp member with rfl | later
      · exact ⟨Nat.le_refl _, advanced, finished⟩
      · obtain ⟨start, positive, bound⟩ := others observed later
        exact ⟨Nat.le_trans (Nat.le_of_lt advanced) start, positive, bound⟩

end Silver.ApplicationPackageBodies

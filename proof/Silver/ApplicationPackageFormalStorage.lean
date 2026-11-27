module

public import Silver.ApplicationPackageDeclarationsModel
public import Silver.ApplicationPackageRoutineFrame

@[expose] public section

namespace Silver.ApplicationPackageFormalStorage
open Compose ApplicationPackageBodies ApplicationPackageRoutineFrame
open PackageBindings (Formal)

def mark (formal : Formal) : ApplicationPackageNames.PackageTypeResult :=
  ⟨formal.bodyTypeName, formal.bodyTypeName.after, formal.kind, formal.bounds, formal.typeIdentity⟩

def scalar (formal : Formal) : Option ScalarExpression.Binding :=
  if formal.kind = .integer then some ⟨formal.bodyName.first, formal.bodyName.after,
    formal.bounds, false, formal.bounds, decide (formal.mode ≠ .input), 0, 0⟩ else none

def flag (formal : Formal) : Option BooleanBindings.Binding :=
  if formal.kind = .boolean then some ⟨formal.bodyName.first, formal.bodyName.after,
    decide (formal.mode ≠ .input), 0, 0, false, false⟩ else none

def selected (outputs : Bool) (formal : Formal) : List Formal :=
  if decide (formal.mode = .output) = outputs then [formal] else []

def chosen (outputs : Bool) (info : PackageBindings.Metadata) (indices : List Nat) : List Formal :=
  indices.flatMap (fun index => selected outputs (info.parameterAt index))

structure Stored (before after : ParserState) (formals : List Formal) : Prop where
  position : after.position = before.position
  integers : after.scalarNames = before.scalarNames ++ formals.filterMap scalar
  flags : after.booleanNames = before.booleanNames ++ formals.filterMap flag
  scalarCapacity : before.scalarNames.length ≤ ScalarExpression.maxBindings →
    after.scalarNames.length ≤ ScalarExpression.maxBindings

theorem Stored.nil (frame : ParserState) : Stored frame frame [] := ⟨rfl, by simp, by simp, id⟩

theorem Stored.join {before middle after : ParserState} {first rest : List Formal}
    (start : Stored before middle first) (finish : Stored middle after rest) :
    Stored before after (first ++ rest) := by
  refine ⟨finish.position.trans start.position, ?_, ?_, fun size => finish.scalarCapacity (start.scalarCapacity size)⟩
  · simp only [finish.integers, start.integers, List.filterMap_append, List.append_assoc]
  · simp only [finish.flags, start.flags, List.filterMap_append, List.append_assoc]

theorem append_stored (frame : ParserState) (formal : Formal)
    (present : (ApplicationPackageDeclarations.appendFormal frame formal.bodyName (mark formal) formal.mode).position ≠ 0) :
    Stored frame (ApplicationPackageDeclarations.appendFormal frame formal.bodyName (mark formal) formal.mode) [formal] := by
  unfold ApplicationPackageDeclarations.appendFormal at present ⊢
  split at present
  · rename_i accepted
    rw [ite_eq_left accepted]
    have kind : formal.kind = .integer := accepted.1
    refine ⟨rfl, by simp [scalar, kind, mark], by simp [flag, kind], ?_⟩
    intro _
    change (frame.scalarNames ++ [_]).length ≤ ScalarExpression.maxBindings
    simp only [List.length_append, List.length_singleton]
    exact Nat.succ_le_of_lt accepted.2
  · rename_i missed
    rw [ite_eq_right missed]
    split at present
    · rename_i accepted
      rw [ite_eq_left accepted]
      have kind : formal.kind = .boolean := accepted.1
      exact ⟨rfl, by simp [scalar, kind], by simp [flag, kind], id⟩
    · exact False.elim (present rfl)

theorem appendParameter_stored {calls : ApplicationPackageRoutineFrame.Calls}
    (native : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {info : PackageBindings.Metadata} {frame after : ParserState} {index : Nat}
    (run : appendParameter calls info frame index = some after) :
    Stored frame after (selected false (info.parameterAt index)) := by
  dsimp only [ApplicationPackageRoutineFrame.appendParameter] at run
  split at run
  · rename_i output
    cases run
    simpa only [selected, output, decide_true, Bool.true_eq_false, ↓reduceIte] using Stored.nil frame
  · rename_i readable
    split at run
    · contradiction
    · rename_i present
      cases run
      rw [native] at present ⊢
      simpa only [selected, mark, decide_eq_false readable, ↓reduceIte] using append_stored frame (info.parameterAt index) present

theorem appendOutput_stored {calls : CompletionCalls} (native : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {text : Source} {formal : Formal} {frame after : ParserState}
    (run : appendOutput calls text formal frame = some after) : Stored frame after (selected true formal) := by
  dsimp only [appendOutput] at run
  split at run
  · rename_i readable
    cases run
    simpa only [selected, decide_eq_false readable, Bool.false_eq_true, ↓reduceIte] using Stored.nil frame
  · rename_i output
    have mode := Classical.not_not.mp output
    split at run
    · contradiction
    · split at run
      · contradiction
      · rename_i present
        cases run
        rw [native] at present ⊢
        simpa only [selected, mark, mode, decide_true, ↓reduceIte] using append_stored frame formal present

theorem parameters_stored {calls : ApplicationPackageRoutineFrame.Calls}
    (native : calls.appendFormal = ApplicationPackageDeclarations.appendFormal) (info : PackageBindings.Metadata)
    (indices : List Nat) {frame after : ParserState}
    (run : parameters (appendParameter calls info) indices frame = some after) :
    Stored frame after (chosen false info indices) := by
  induction indices generalizing frame with
  | nil => cases run; exact Stored.nil _
  | cons index rest ih =>
    simp only [parameters] at run
    obtain ⟨next, step, finish⟩ := Option.bind_eq_some_iff.mp run
    exact (appendParameter_stored native step).join (ih finish)

theorem outputs_stored {calls : CompletionCalls} (native : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    (text : Source) (info : PackageBindings.Metadata) (indices : List Nat) {frame after : ParserState}
    (run : appendOutputs calls text info indices frame = some after) :
    Stored frame after (chosen true info indices) := by
  induction indices generalizing frame with
  | nil => cases run; exact Stored.nil _
  | cons index rest ih =>
    simp only [appendOutputs] at run
    obtain ⟨next, step, finish⟩ := Option.bind_eq_some_iff.mp run
    exact (appendOutput_stored native step).join (ih finish)

end Silver.ApplicationPackageFormalStorage

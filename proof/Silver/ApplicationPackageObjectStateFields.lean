module

public import Silver.ApplicationPackageObjectFrameOrder
public import Silver.ApplicationPackageUnitObjectHistory
public import Silver.ApplicationPackageCompletionLocalHistory

@[expose] public section

namespace Silver.ApplicationPackageObjectRows
open Compose ApplicationPackageDeclarations ApplicationPackageBodies

/-- State declarations and visible scalar bindings sharing a defining byte
come from the same original Object. Local shadowing can remove a state row. -/
def ScalarStateFields (states : List PackageBindings.StateDeclaration) (names : ScalarExpression.Environment) : Prop :=
  ∀ row ∈ names, ∀ state ∈ states, row.first = state.name.first →
    row.declaredBounds = state.declaredBounds ∧ row.mutable = true

structure StateFrame (states : List PackageBindings.StateDeclaration) (frame : ParserState) : Prop where
  order : FrameOrder frame
  statesBefore : ∀ state ∈ states, state.name.first < frame.position
  scalarFields : ScalarStateFields states frame.scalarNames

theorem StateFrame.empty {frame : ParserState} (order : FrameOrder frame) : StateFrame [] frame :=
  ⟨order, by simp, by simp [ScalarStateFields]⟩

private theorem scalar_origin {reader : BooleanElaboration.Native.Reader} {text : Source} {frame : ParserState}
    {info : PackageBindings.Metadata} {localObject : Bool} {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls reader) text frame info localObject = out)
    (present : out.frame.position ≠ 0) {row : ScalarExpression.Binding} (member : row ∈ out.frame.scalarNames) :
    row ∈ frame.scalarNames ∨
      (row.first = out.name.first ∧ row.declaredBounds = out.mark.bounds ∧ row.mutable = !out.constantObject) := by
  obtain ⟨storage, kept, _⟩ := objectStep_storage parsed present
  cases kind : out.mark.kind with
  | integer =>
    obtain ⟨isStatic, installed, _⟩ := storage.integerStorage kind
    rw [installed] at member
    rcases List.mem_append.mp member with old | new
    · exact Or.inl (kept.subset old)
    · cases List.mem_singleton.mp new
      exact Or.inr ⟨rfl, rfl, rfl⟩
  | boolean =>
    obtain ⟨_, _, unchanged⟩ := storage.booleanStorage kind
    rw [unchanged] at member
    exact Or.inl (kept.subset member)

theorem StateFrame.after_object {reader : BooleanElaboration.Native.Reader} {text : Source} {frame : ParserState}
    {info : PackageBindings.Metadata} {localObject : Bool} {out : ObjectResult}
    {states : List PackageBindings.StateDeclaration} (prior : StateFrame states frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info localObject = out)
    (present : out.frame.position ≠ 0) : StateFrame states out.frame := by
  have positions := parsed ▸ objectStep_positions reader text frame info localObject (parsed ▸ present)
  have advanced := Nat.lt_of_le_of_lt positions.1 (Nat.lt_trans positions.2.1 positions.2.2.1)
  refine ⟨objectStep_frameOrder parsed present prior.order,
    fun state member => Nat.lt_trans (prior.statesBefore state member) advanced, ?_⟩
  intro row member state previous same
  rcases scalar_origin parsed present member with kept | new
  · exact prior.scalarFields row kept state previous same
  · have earlier := Nat.lt_of_lt_of_le (prior.statesBefore state previous) positions.1
    exact False.elim (Nat.ne_of_lt earlier (same.symm.trans new.1))

theorem StateFrame.after_state {reader : BooleanElaboration.Native.Reader} {text : Source} {frame : ParserState}
    {info : PackageBindings.Metadata} {out : ObjectResult} (prior : StateFrame info.states frame)
    (parsed : objectStep (modelObjectCalls reader) text frame info false = out)
    (present : out.frame.position ≠ 0) (writable : out.constantObject = false) :
    StateFrame (info.states ++ [stateDeclaration out]) out.frame := by
  have kept := prior.after_object parsed present
  have positions := parsed ▸ objectStep_positions reader text frame info false (parsed ▸ present)
  refine ⟨kept.order, ?_, ?_⟩
  · intro state selected
    rcases List.mem_append.mp selected with previous | new
    · exact kept.statesBefore state previous
    · cases List.mem_singleton.mp new
      exact Nat.lt_trans positions.2.1 positions.2.2.1
  · intro row member state selected same
    rcases List.mem_append.mp selected with previous | new
    · exact kept.scalarFields row member state previous same
    · cases List.mem_singleton.mp new
      change row.first = out.name.first at same
      rcases scalar_origin parsed present member with previous | installed
      · have earlier := Nat.lt_of_lt_of_le (prior.order.scalar_before previous) positions.1
        exact False.elim (Nat.ne_of_lt earlier same)
      · exact ⟨installed.2.1, by simpa only [writable, Bool.not_false] using installed.2.2⟩

/-- Fold over the actual per-row Object calls selected by an accepted Unit.
The source interpretation need only identify the calls in this history. -/
theorem stateHistory_fields {reader : BooleanElaboration.Native.Reader} {calls : UnitCalls} {text : Source}
    {before after : UnitState} {rows : List StateObject}
    (history : StateObjects calls text before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.globals row.before.info false =
      objectStep (modelObjectCalls reader) text row.before.globals row.before.info false)
    (initial : StateFrame before.info.states before.globals) : StateFrame after.info.states after.globals := by
  induction history with
  | finished => exact initial
  | @added row following final phase chosen capacity parsed advances writable rest ih =>
    apply ih (fun seen member => original seen (List.mem_cons_of_mem _ member))
    exact initial.after_state ((original row List.mem_cons_self).symm.trans parsed) (by omega) writable

theorem localHistory_fields {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {before after : InitializationFrame} {rows : List LocalObject}
    (history : LocalObjects calls text info item before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true)
    (initial : StateFrame info.states before.frame) : StateFrame info.states after.frame := by
  induction history with
  | finished => exact initial
  | @added row final following atBegin apart parsed advances rest ih =>
    apply ih (fun seen member => original seen (List.mem_cons_of_mem _ member))
    exact initial.after_object ((original row List.mem_cons_self).symm.trans parsed) (by omega)

end Silver.ApplicationPackageObjectRows

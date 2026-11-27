module

public import Silver.ApplicationPackageBodiesExecution

@[expose] public section

namespace Silver.ApplicationPackageBodies
open ApplicationPackageDeclarations (ObjectResult)

def objectSelected (calls : UnitCalls) (text : Source) (state : UnitState) : Prop :=
  calls.takeToken text state.globals.position (.word "function") = 0 ∧
    calls.takeToken text state.globals.position (.word "procedure") = 0 ∧
    calls.takeToken text state.globals.position (.word "end") = 0

structure StateObject where
  before : UnitState
  object : ObjectResult

def StateObject.after (row : StateObject) : UnitState :=
  ⟨row.object.frame, {row.before.info with states := row.before.info.states ++ [stateDeclaration row.object]}, .objects⟩

inductive StateObjects (calls : UnitCalls) (text : Source) : UnitState → List StateObject → UnitState → Prop where
  | finished {state : UnitState} (phase : state.phase = .objects) (ended : ¬objectSelected calls text state) :
      StateObjects calls text state [] {state with phase := .routines}
  | added {row : StateObject} {following : List StateObject} {final : UnitState}
      (phase : row.before.phase = .objects) (selected : objectSelected calls text row.before)
      (capacity : row.before.info.states.length ≠ PackageBindings.maxStates)
      (parsed : calls.objectAt text row.before.globals row.before.info false = row.object)
      (advanced : row.before.globals.position < row.object.frame.position) (writable : row.object.constantObject = false)
      (rest : StateObjects calls text row.after following final) :
      StateObjects calls text row.before (row :: following) final

private theorem object_step_failure {calls : UnitCalls} {text : Source} {state : UnitState}
    {result : ApplicationAdmission.BodyResult} (phase : state.phase = .objects)
    (returned : unitStep calls text state = .returned result) : result.accepted = false := by
  simp only [unitStep, phase] at returned
  split at returned
  · split at returned
    · cases returned; rfl
    · split at returned
      · cases returned; rfl
      · contradiction
  · contradiction

/-- A successful unit must leave its entire state declaration segment before
the first routine is completed. Each cell is the exact object and original
initializer/name/type span installed at its declaration-order ordinal. -/
theorem unitExecution_state_objects {calls : UnitCalls} {text : Source} {state : UnitState}
    {accepted : ApplicationAdmission.BodyResult} (run : UnitExecution (unitStep calls text) state accepted)
    (positive : accepted.accepted = true) (phase : state.phase = .objects) :
    ∃ rows after, StateObjects calls text state rows after ∧ UnitExecution (unitStep calls text) after accepted := by
  induction run with
  | returned step =>
    have rejected := object_step_failure phase step
    simp only [positive, Bool.true_eq_false] at rejected
  | @continued before after _ step remaining ih =>
    simp only [unitStep, phase] at step
    split at step
    · rename_i selected
      split at step
      · contradiction
      · rename_i capacity
        split at step
        · contradiction
        · rename_i acceptedObject
          cases step
          obtain ⟨rest, next, objects, body⟩ := ih positive rfl
          let row : StateObject := ⟨before, calls.objectAt text before.globals before.info false⟩
          have advances := Nat.lt_of_not_ge (fun failed => acceptedObject (Or.inl failed))
          have writable := Bool.eq_false_iff.mpr (fun isConst => acceptedObject (Or.inr isConst))
          exact ⟨row :: rest, next, .added (row := row) phase selected capacity rfl advances writable objects, body⟩
    · rename_i ended
      cases step
      exact ⟨[], _, .finished phase ended, remaining⟩

theorem StateObjects.table {calls : UnitCalls} {text : Source} {before after : UnitState} {rows : List StateObject}
    (objects : StateObjects calls text before rows after) :
    after.info.states = before.info.states ++ rows.map (fun row => stateDeclaration row.object) := by
  induction objects with
  | finished => simp
  | @added row _ _ _ _ _ _ _ _ _ ih =>
    simpa only [StateObject.after, List.map_cons, List.append_assoc, List.singleton_append] using ih

theorem StateObjects.stateAt {calls : UnitCalls} {text : Source} {before after : UnitState}
    {rows : List StateObject} (history : StateObjects calls text before rows after)
    {offset : Nat} {row : StateObject} (source : rows[offset]? = some row) :
    after.info.stateAt (before.info.states.length + offset + 1) = stateDeclaration row.object := by
  simp only [PackageBindings.Metadata.stateAt, history.table, Nat.add_one_sub_one,
    List.getD_eq_getElem?_getD, List.getElem?_append_right (Nat.le_add_right _ _),
    Nat.add_sub_cancel_left, List.getElem?_map, source, Option.map_some, Option.getD_some]

theorem StateObjects.cursor_order {calls : UnitCalls} {text : Source} {before after : UnitState}
    {rows : List StateObject} (history : StateObjects calls text before rows after) :
    before.globals.position ≤ after.globals.position ∧
      ∀ row ∈ rows, before.globals.position ≤ row.before.globals.position ∧
        row.before.globals.position < row.object.frame.position ∧ row.object.frame.position ≤ after.globals.position := by
  induction history with
  | finished => exact ⟨Nat.le_refl _, by simp⟩
  | @added row _ _ _ _ _ _ advanced _ _ ih =>
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

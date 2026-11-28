module

public import Silver.ApplicationPackageCallsActualStepProjection
public import Silver.ApplicationPackageCallsActualFold

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

theorem actualLocals_preserves {calls : ApplicationPackageCalls.Calls} {before after : Locals}
    (accepted : actualLocals calls before = some after) :
    preservedInputs before after ∧
      (frameOf after).actuals.length = (frameOf before).actuals.length := by
  simp only [actualLocals, Option.bind_eq_bind, Option.bind_eq_some_iff] at accepted
  obtain ⟨associated, select, loaded, read, finish⟩ := accepted
  have association := association_preserves select
  have payload := payload_preserves read
  have finished := finish_preserves finish
  refine ⟨(association.1.trans payload.1).trans finished.1, ?_⟩
  have length : (frameOf associated).actuals.length = (frameOf before).actuals.length := by
    rw [association.2]
  exact (finished.2.trans payload.2.2).trans length

theorem frameOf_ordinal (locals : Locals) (value : Nat) :
    frameOf (locals.set .number "ordinal" value) = frameOf locals := by
  simp [frameOf, Locals.set]

theorem aliasInputs_ordinal (locals : Locals) (value : Nat) :
    aliasInputs (locals.set .number "ordinal" value) = aliasInputs locals := by
  simp [aliasInputs, Locals.set]

def stepFromInputs (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (frame : ActualFrame) (ordinal : Nat) : Option ActualFrame :=
  actualStep calls inputs.text inputs.context inputs.input inputs.info inputs.item ordinal frame

theorem stepFromInputs_withFrame (calls : ApplicationPackageCalls.Calls) (inputs : AliasInputs)
    (frame : ActualFrame) : stepFromInputs calls (withActualFrame inputs frame) = stepFromInputs calls inputs := rfl

theorem actuals_fold_model (calls : ApplicationPackageCalls.Calls) (ordinals : List Nat) (locals : Locals)
    (next : AliasInputs → ActualFrame → ApplicationPackages.ApplicationCall)
    (positive : 0 < (aliasInputs locals).item.count)
    (window : ActualWindow (aliasInputs locals).item (frameOf locals).actuals.length)
    (each : ∀ ordinal ∈ ordinals, ordinal ≤ (aliasInputs locals).item.count) :
    forValues (resultType := .appCall)
      (fun current continuation => actualCommands.eval (resultType := .appCall) (imported calls) current continuation)
      "ordinal" ordinals locals (fun current => next (aliasInputs current) (frameOf current)) =
      match ordinals.foldlM (stepFromInputs calls (aliasInputs locals)) (frameOf locals) with
      | none => (aliasInputs locals).failure
      | some frame => next (withActualFrame (aliasInputs locals) frame) frame := by
  induction ordinals generalizing locals with
  | nil => rfl
  | cons ordinal rest ih =>
    let indexed := locals.set .number "ordinal" ordinal
    have inputs : aliasInputs indexed = aliasInputs locals := aliasInputs_ordinal locals ordinal
    have frame : frameOf indexed = frameOf locals := frameOf_ordinal locals ordinal
    have ordinalEq : indexed .number "ordinal" = ordinal := Locals.set_get_same ..
    have itemEq : indexed .routine "item" = (aliasInputs locals).item :=
      congrArg AliasInputs.item inputs
    have sourceWindow : ActualWindow (indexed .routine "item") (frameOf indexed).actuals.length := by
      rw [itemEq, frame]
      exact window
    have inRange : indexed .number "ordinal" ≤ (indexed .routine "item").count := by
      rw [ordinalEq, itemEq]
      exact each ordinal (List.mem_cons_self ..)
    have sourcePositive : 0 < (indexed .routine "item").count := by
      rw [itemEq]
      exact positive
    have projection := actualLocals_projection calls indexed sourcePositive sourceWindow inRange
    change (actualLocals calls indexed).map frameOf =
      stepFromInputs calls (aliasInputs indexed) (frameOf indexed) (indexed .number "ordinal") at projection
    rw [inputs, frame, ordinalEq] at projection
    rw [forValues, actual_body_denotation, List.foldlM_cons]
    cases accepted : actualLocals calls indexed with
    | none =>
      rw [accepted] at projection
      simp only [Option.map_none] at projection
      rw [← projection]
      rfl
    | some updated =>
      rw [accepted] at projection
      simp only [Option.map_some] at projection
      have stable := actualLocals_preserves accepted
      have changed : aliasInputs updated = withActualFrame (aliasInputs locals) (frameOf updated) := by
        rw [stable.1.1, inputs]
      have sameItem : (aliasInputs updated).item = (aliasInputs locals).item := by
        rw [changed]
        rfl
      have nextWindow : ActualWindow (aliasInputs updated).item (frameOf updated).actuals.length := by
        rw [sameItem, stable.2, frame]
        exact window
      have nextPositive : 0 < (aliasInputs updated).item.count := by
        rw [sameItem]
        exact positive
      have others : ∀ i ∈ rest, i ≤ (aliasInputs updated).item.count := by
        intro i restIn
        rw [sameItem]
        exact each i (List.mem_cons_of_mem _ restIn)
      rw [← projection]
      simp only [Option.bind_eq_bind, Option.bind_some]
      rw [ih updated nextPositive nextWindow others, changed, stepFromInputs_withFrame]
      rfl

theorem actual_scan_model (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : AliasInputs → ActualFrame → ApplicationPackages.ApplicationCall)
    (positive : 0 < (aliasInputs locals).item.count)
    (window : ActualWindow (aliasInputs locals).item (frameOf locals).actuals.length) :
    actualScan.eval (resultType := .appCall) (imported calls) locals
        (fun current => next (aliasInputs current) (frameOf current)) =
      match ((List.range (aliasInputs locals).item.count).map (1 + ·)).foldlM
          (stepFromInputs calls (aliasInputs locals)) (frameOf locals) with
      | none => (aliasInputs locals).failure
      | some frame => next (withActualFrame (aliasInputs locals) frame) frame := by
  change forValues (resultType := .appCall)
    (fun current continuation => actualCommands.eval (resultType := .appCall) (imported calls) current continuation)
    "ordinal" ((List.range ((aliasInputs locals).item.count + 1 - 1)).map (1 + ·)) locals
    (fun updated => next (aliasInputs (updated.set .number "ordinal" (locals .number "ordinal")))
      (frameOf (updated.set .number "ordinal" (locals .number "ordinal")))) = _
  simp only [Nat.add_sub_cancel, aliasInputs_ordinal, frameOf_ordinal]
  apply actuals_fold_model calls _ locals next positive window
  intro ordinal member
  obtain ⟨offset, inside, rfl⟩ := List.mem_map.mp member
  have bounded := List.mem_range.mp inside
  omega

end Silver.ApplicationPackageCalls.Native.Call

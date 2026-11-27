module

public import Silver.ApplicationPackageCallActualLoopImports

@[expose] public section

namespace Silver.ApplicationPackageCalls.PayloadImports
open Compose Compose.Expressions Predicate ApplicationPackages

set_option backward.dsimp.instances true

/-- Original alias-scan input fields. A zero target is retained as a rejected
or unused row; its name span is only consumed after the native positive guard. -/
structure ActualBounds (text : Source) (actual : PackageActual) : Prop where
  first : ValidCursor text actual.first
  after : ValidCursor text actual.after
  target : actual.target.after ≠ 0 →
    0 < actual.target.first ∧ actual.target.first < actual.target.after ∧
      actual.target.after ≤ text.length + 1

theorem empty_actual_bounds (text : Source) : ActualBounds text {} :=
  ⟨Nat.zero_le _, Nat.zero_le _, fun h => (h rfl).elim⟩

theorem target_name_bounds (text : Source) (context : ParseContext) (cursor : Nat)
    (facts : ActiveFlow) (parameter : ProcedureBindings.Formal) :
    let target := procedureTargetActual text context cursor facts parameter
    target.after ≠ 0 → 0 < target.first ∧ target.first < target.after ∧ target.after ≤ text.length + 1 := by
  dsimp only [procedureTargetActual]
  split
  · exact fun h => (h rfl).elim
  · rename_i named
    have positive : 0 < skipAt text cursor := by omega
    have advanced : skipAt text cursor < nameAfter text (skipAt text cursor) := by omega
    have bounded := model_name_valid text (skipAt text cursor)
    split
    · split
      · exact fun h => (h rfl).elim
      · exact fun _ => ⟨positive, advanced, bounded⟩
    · split
      · exact fun h => (h rfl).elim
      · exact fun _ => ⟨positive, advanced, bounded⟩

def ActualsBounded (text : Source) (actuals : List PackageActual) : Prop :=
  ∀ row ∈ actuals, ActualBounds text row

theorem actual_lookup_bounds {text : Source} {actuals : List PackageActual}
    (bounded : ActualsBounded text actuals) (index : Nat) :
    ActualBounds text (actuals.getD index {}) := by
  cases found : actuals[index]? with
  | none => simpa only [List.getD_eq_getElem?_getD, found, Option.getD_none] using empty_actual_bounds text
  | some row =>
    simpa only [List.getD_eq_getElem?_getD, found, Option.getD_some] using bounded row (List.mem_of_getElem? found)

theorem actual_set_bounds {text : Source} {actuals : List PackageActual}
    (bounded : ActualsBounded text actuals) (index : Nat) (row : PackageActual)
    (valid : ActualBounds text row) : ActualsBounded text (actuals.set index row) := by
  intro value member
  rcases List.mem_or_eq_of_mem_set member with old | same
  · exact bounded value old
  · exact same ▸ valid

theorem model_payload_cursor (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationScan) (parameter : PackageBindings.Formal) (info : PackageBindings.Metadata)
    (cursor : Nat) (bounded : ValidCursor text cursor) (original : PackageActual) :
    ValidCursor text (actualPayload modelCalls text native.model input parameter info cursor original).1 := by
  unfold actualPayload
  split
  · exact ApplicationPackageActual.actual_model_bound text native cursor input.scan.facts
      (inputFormal parameter) valid contextValid bounded
  · exact procedureTargetActual_after_bound text native.model cursor input.scan.facts (outputFormal parameter)

theorem recorded_bounds (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationScan) (parameter : PackageBindings.Formal) (info : PackageBindings.Metadata)
    (cursor : Nat) (bounded : ValidCursor text cursor) (original : PackageActual)
    (originalBounds : ActualBounds text original) :
    let payload := actualPayload modelCalls text native.model input parameter info cursor
      {original with first := cursor}
    ActualBounds text (recordedActual modelCalls text native.model info parameter cursor payload) := by
  let payload := actualPayload modelCalls text native.model input parameter info cursor
    {original with first := cursor}
  have afterBound := model_payload_cursor text valid native contextValid input parameter info cursor bounded
    {original with first := cursor}
  have first : payload.2.first = cursor := by
    dsimp only [payload, actualPayload]
    split <;> rfl
  have target : payload.2.target.after ≠ 0 →
      0 < payload.2.target.first ∧ payload.2.target.first < payload.2.target.after ∧
        payload.2.target.after ≤ text.length + 1 := by
    dsimp only [payload, actualPayload]
    split
    · exact originalBounds.target
    · exact target_name_bounds text native.model cursor input.scan.facts (outputFormal parameter)
  change ActualBounds text (recordedActual modelCalls text native.model info parameter cursor payload)
  unfold recordedActual
  dsimp only
  split <;> exact ⟨first.symm ▸ bounded, afterBound, target⟩

theorem model_step_bounds {text : Source} (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (ordinal : Nat) (before after : ActualFrame) (cursor : ValidCursor text before.cursor)
    (rows : ActualsBounded text before.actuals)
    (accepted : actualStep modelCalls text native.model input info item ordinal before = some after) :
    ActualsBounded text after.actuals := by
  obtain ⟨slot, named, position, selected, _, _, fields⟩ := actual_step_fields accepted
  rw [fields.2.2.1]
  exact actual_set_bounds rows _ _ (recorded_bounds text valid native contextValid input
    (info.parameterAt slot) info position (association_cursor cursor selected) (before.actual slot)
    (actual_lookup_bounds rows (slot - 1)))

theorem model_fold_bounds {text : Source} (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (offsets : List Nat) (before after : ActualFrame) (cursor : ValidCursor text before.cursor)
    (rows : ActualsBounded text before.actuals)
    (accepted : offsets.foldlM (fun frame index => actualStep modelCalls text native.model input info item
      (index + 1) frame) before = some after) : ActualsBounded text after.actuals := by
  induction offsets generalizing before with
  | nil => exact (Option.some.inj accepted) ▸ rows
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at accepted
    obtain ⟨middle, step, remaining⟩ := accepted
    exact ih middle (model_step_cursor step)
      (model_step_bounds valid native contextValid input info item (index + 1) before middle cursor rows step) remaining

theorem model_read_bounds {text : Source} (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (afterName : Nat) (after : ActualFrame)
    (accepted : readActuals modelCalls text native.model input info item afterName = some after) :
    ActualsBounded text after.actuals := by
  have empty : ActualsBounded text (List.replicate PackageBindings.maxFormals {}) := by
    intro row member
    have same := (List.mem_replicate.mp member).2
    exact same ▸ empty_actual_bounds text
  unfold readActuals at accepted
  dsimp only at accepted
  split at accepted
  · cases accepted
    exact empty
  · split at accepted
    · contradiction
    · exact model_fold_bounds valid native contextValid input info item (List.range item.count)
        {cursor := tokenAfter text afterName (.symbol "("), result := {result := input}, callWrites := item.mayWrite}
        after (fixedAfter_result_bound text afterName "(" false (by decide)) empty accepted

end Silver.ApplicationPackageCalls.PayloadImports

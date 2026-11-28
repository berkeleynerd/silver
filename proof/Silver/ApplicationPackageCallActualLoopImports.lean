module

public import Silver.ApplicationPackageCallActualImports
public import Silver.ApplicationPackageCallsActualSelection

@[expose] public section

namespace Silver.ApplicationPackageCalls.PayloadImports
open Compose Compose.Expressions Predicate ApplicationPackages

set_option backward.dsimp.instances true

theorem model_step_cursor {text : Source} {context : ParseContext} {input : ApplicationScan}
    {info : PackageBindings.Metadata} {item : PackageBindings.Routine} {ordinal : Nat}
    {before after : ActualFrame}
    (accepted : actualStep modelCalls text context input info item ordinal before = some after) :
    ValidCursor text after.cursor := by
  obtain ⟨slot, named, cursor, _, _, _, fields⟩ := actual_step_fields accepted
  rw [fields.2.2.2.1]
  by_cases last : ordinal = item.count
  · simp only [last, ↓reduceIte, modelCalls]
    exact fixedAfter_result_bound text _ ")" false (by decide)
  · simp only [last, ↓reduceIte, modelCalls]
    exact fixedAfter_result_bound text _ "," false (by decide)

namespace Library

/-- Every source-order step uses the unchanged incoming flow. Successful
separator reads establish the next cursor's native domain; a rejection ends
both folds at the same point. No completed association trace is assumed. -/
theorem actual_fold (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationScan) (flow : Predicate.Native.ValidFlow native input.scan.facts)
    (info : PackageBindings.Metadata) (typed : info.Typed) (item : PackageBindings.Routine)
    (offsets : List Nat) (frame : ActualFrame) (bounded : ValidCursor text frame.cursor) :
    offsets.foldlM (fun current index => actualStep (library.calls other) text native.model
      input info item (index + 1) current) frame =
    offsets.foldlM (fun current index => actualStep modelCalls text native.model
      input info item (index + 1) current) frame := by
  induction offsets generalizing frame with
  | nil => rfl
  | cons index rest ih =>
    simp only [List.foldlM_cons]
    rw [library.actual_step other text valid native contextValid input flow info typed item (index + 1) frame bounded]
    cases step : actualStep modelCalls text native.model input info item (index + 1) frame with
    | none => rfl
    | some next =>
      simp only [Option.bind_eq_bind, Option.bind_some]
      exact ih next (model_step_cursor step)

theorem read_actuals (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationScan) (flow : Predicate.Native.ValidFlow native input.scan.facts)
    (info : PackageBindings.Metadata) (typed : info.Typed) (item : PackageBindings.Routine)
    (afterName : Nat) (bounded : ValidCursor text afterName) :
    readActuals (library.calls other) text native.model input info item afterName =
      readActuals modelCalls text native.model input info item afterName := by
  have opened : (library.calls other).take text afterName (.symbol "(") =
      modelCalls.take text afterName (.symbol "(") :=
    interpreted_take library.effects.composed library.effects.inherited text valid afterName
      (.symbol "(") bounded (by unfold ValidToken; decide)
  unfold readActuals
  dsimp only
  split
  · rfl
  · rw [opened]
    split
    · rfl
    · exact library.actual_fold other text valid native contextValid input flow info typed item
        (List.range item.count) _ (fixedAfter_result_bound text _ "(" false (by decide))

end Library
end Silver.ApplicationPackageCalls.PayloadImports

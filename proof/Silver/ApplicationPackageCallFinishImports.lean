module

public import Silver.ApplicationPackageCallActualBounds

@[expose] public section

namespace Silver.ApplicationPackageCalls.PayloadImports.Library
open Compose Compose.Expressions Predicate ApplicationPackages

set_option backward.dsimp.instances true

theorem alias_step (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (actuals : List PackageActual) (bounded : ActualsBounded text actuals)
    (result : ApplicationCall) (index : Nat) :
    aliasStep (library.calls other) text info item actuals result index =
      aliasStep modelCalls text info item actuals result index := by
  unfold aliasStep
  dsimp only
  split
  · rfl
  · split
    · rfl
    · split
      · rfl
      · rename_i present
        split
        · rfl
        · have scan : (fun slot => decide (index ≠ slot) &&
              !(library.calls other).actualNameFree text (actuals.getD (slot - 1) {}).first
                (actuals.getD (slot - 1) {}).after (actuals.getD (index - 1) {}).target.first
                (actuals.getD (index - 1) {}).target.after) =
            (fun slot => decide (index ≠ slot) &&
              !modelCalls.actualNameFree text (actuals.getD (slot - 1) {}).first
                (actuals.getD (slot - 1) {}).after (actuals.getD (index - 1) {}).target.first
                (actuals.getD (index - 1) {}).target.after) := by
            funext slot
            have row := actual_lookup_bounds bounded (slot - 1)
            have target := (actual_lookup_bounds bounded (index - 1)).target present
            have meaning := (ApplicationPackageEffects.imported_primitives library.effects).actualNameFree
              text valid _ _ _ _ row.first row.after target
            change library.effects.nameScan text _ _ _ _ = Predicate.actualNameFree text _ _ _ _ at meaning
            change (decide (index ≠ slot) && !library.effects.nameScan text _ _ _ _) = _
            rw [meaning]
            rfl
          rw [scan]

/-- The alias fold consumes only bounds derived by the actual reader, retaining
all native rejection tests and source-name comparisons. -/
theorem aliases (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (frame : ActualFrame)
    (bounded : ActualsBounded text frame.actuals) :
    checkAliases (library.calls other) text info item frame =
      checkAliases modelCalls text info item frame := by
  have step : aliasStep (library.calls other) text info item frame.actuals =
      aliasStep modelCalls text info item frame.actuals := by
    funext result index
    exact library.alias_step other text valid info item frame.actuals bounded result index
  unfold checkAliases
  rw [step]

theorem reset_state (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (context : ParseContext) (domain : ApplicationPackageEffects.LookupDomain text context)
    (info : PackageBindings.Metadata) (writes : PackageBindings.StateSet)
    (result : ApplicationCall) (index : Nat) :
    resetState (library.calls other) text context info writes result index =
      resetState modelCalls text context info writes result index := by
  have visible : (library.calls other).visibleState text context info index =
      modelCalls.visibleState text context info index :=
    ApplicationPackageEffects.imported_visible library.effects text valid context domain info index
  unfold resetState
  dsimp only
  rw [visible]
  split
  · rename_i selected
    have named := (ApplicationPackageEffects.visibleState_guard selected.2.1).2
    have span := (ApplicationPackageNames.Native.validName_domain named).2
    have first : (info.stateAt index).name.first ≤ text.length + 1 :=
      Nat.le_trans (Nat.le_of_lt span.2.1) span.2.2
    have lookup := ScalarExpression.SourceBridge.interpreted_lookup library.effects.scalars
      library.effects.scalarSource text valid context.scalarNames domain.scalars
      (info.stateAt index).name.first (info.stateAt index).name.after first span.2.2
    change replaceScalar result (library.effects.scalars.lookup text context.scalarNames
      (info.stateAt index).name.first (info.stateAt index).name.after)
      (ScalarExpression.binding context.scalarNames (library.effects.scalars.lookup text context.scalarNames
        (info.stateAt index).name.first (info.stateAt index).name.after)).declaredBounds = _
    rw [lookup]
    rfl
  · rfl

theorem finish_call (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (context : ParseContext) (domain : ApplicationPackageEffects.LookupDomain text context)
    (info : PackageBindings.Metadata) (kind : PackageBindings.RoutineKind)
    (item : PackageBindings.Routine) (frame : ActualFrame) (checked : ApplicationCall) :
    finishCall (library.calls other) text context info kind item frame checked =
      finishCall modelCalls text context info kind item frame checked := by
  have reset : resetState (library.calls other) text context info frame.callWrites =
      resetState modelCalls text context info frame.callWrites := by
    funext result index
    exact library.reset_state other text valid context domain info frame.callWrites result index
  unfold finishCall
  rw [reset]

end Silver.ApplicationPackageCalls.PayloadImports.Library

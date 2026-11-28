module

public import Silver.ApplicationPackageCallPayloadImports

@[expose] public section

namespace Silver.ApplicationPackageCalls.PayloadImports
open Compose Compose.Expressions Predicate ApplicationPackages

set_option backward.dsimp.instances true

/-- Native storage gives every selected or default formal its scalar subtypes.
No valid-name, signature or successful selection is required. -/
theorem parameter_typed (info : PackageBindings.Metadata) (typed : info.Typed) (index : Nat) :
    (info.parameterAt index).Typed := by
  rcases typed with ⟨_, _, _, _, _, _, _, _, _, _, _, parameters⟩
  unfold PackageBindings.Metadata.parameterAt
  cases found : info.parameters[index - 1]? with
  | none =>
    simp only [List.getD_eq_getElem?_getD, found, Option.getD_none]
    exact ⟨⟨by decide, by decide⟩, ⟨by decide, by decide⟩, ⟨by decide, by decide⟩,
      ⟨by decide, by decide⟩, Integer.Interval.empty_bounded, by decide⟩
  | some parameter =>
    simpa only [List.getD_eq_getElem?_getD, found, Option.getD_some] using
      parameters parameter (List.mem_of_getElem? found)

theorem association_cursor {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {ordinal : Nat} {frame : ActualFrame}
    {slot : Nat} {named : Bool} {cursor : Nat}
    (bounded : ValidCursor text frame.cursor)
    (selected : actualAssociation modelCalls text info item ordinal frame = some (slot, named, cursor)) :
    ValidCursor text cursor := by
  unfold actualAssociation at selected
  dsimp only at selected
  split at selected
  · cases selected
    exact fixedAfter_result_bound text _ "=>" false (by decide)
  · split at selected
    · contradiction
    · cases selected
      exact bounded

namespace Library

theorem association (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (ordinal : Nat)
    (frame : ActualFrame) (bounded : ValidCursor text frame.cursor) :
    actualAssociation (library.calls other) text info item ordinal frame =
      actualAssociation modelCalls text info item ordinal frame :=
  LexicalImports.association library.effects other text valid info item ordinal frame bounded

theorem actual_step (library : Library) (other : Calls) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (input : ApplicationScan) (flow : Predicate.Native.ValidFlow native input.scan.facts)
    (info : PackageBindings.Metadata) (typed : info.Typed) (item : PackageBindings.Routine)
    (ordinal : Nat) (frame : ActualFrame) (bounded : ValidCursor text frame.cursor) :
    actualStep (library.calls other) text native.model input info item ordinal frame =
      actualStep modelCalls text native.model input info item ordinal frame := by
  unfold actualStep
  rw [library.association other text valid info item ordinal frame bounded]
  cases selected : actualAssociation modelCalls text info item ordinal frame with
  | none => rfl
  | some chosen =>
    rcases chosen with ⟨slot, named, cursor⟩
    have cursorBound := association_cursor bounded selected
    simp only [Option.bind_eq_bind, Option.bind_some]
    split
    · rfl
    · have same := library.payload other text valid native contextValid input flow
        (info.parameterAt slot) (parameter_typed info typed slot) info cursor cursorBound
        {frame.actual slot with first := cursor}
      rw [same]
      dsimp only
      split
      · rfl
      · let payload := actualPayload modelCalls text native.model input (info.parameterAt slot)
          info cursor {frame.actual slot with first := cursor}
        have afterBound : ValidCursor text payload.1 := by
          have bound := library.payload_bound other text valid native contextValid input flow
            (info.parameterAt slot) (parameter_typed info typed slot) info cursor cursorBound
            {frame.actual slot with first := cursor}
          rw [same] at bound
          exact bound
        have reads := ApplicationPackageEffects.imported_reads library.effects text valid native.model
          (ApplicationPackageEffects.LookupDomain.of_native contextValid) info cursor payload.1 cursorBound afterBound
        have tokenValid : ValidToken (if ordinal = item.count then .symbol ")" else .symbol ",") := by
          split <;> unfold ValidToken <;> decide
        have token := interpreted_take library.effects.composed library.effects.inherited text valid payload.1
          (if ordinal = item.count then .symbol ")" else .symbol ",") afterBound tokenValid
        change (let actual := {payload.2 with after := payload.1};
          let actual := if (info.parameterAt slot).mode ≠ .output then
            {actual with reads := (ApplicationPackageEffects.stateReads
              (ApplicationPackageEffects.importedCalls library.effects) text native.model info cursor payload.1)}
            else actual;
          let result := {frame.result with result := {frame.result.result with
            reads := PackageBindings.stateUnion frame.result.result.reads actual.reads}};
          let finish := library.effects.composed.function .takeToken text payload.1
            (if ordinal = item.count then .symbol ")" else .symbol ",");
          if finish = 0 then none else some {frame with cursor := finish, named := named, actuals := frame.actuals.set (slot - 1) actual, seen := frame.seen.set (slot - 1) true, result := result, callWrites := markState frame.callWrites actual.writtenState}) = _
        rw [reads, token]
        by_cases last : ordinal = item.count <;> simp only [last, ↓reduceIte] <;> rfl

end Library
end Silver.ApplicationPackageCalls.PayloadImports

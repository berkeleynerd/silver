module

public import Silver.ApplicationPackageCallsActualProjection

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

theorem selected_slot_bound {calls : ApplicationPackageCalls.Calls} {text info item ordinal frame slot named cursor}
    (window : ActualWindow item frame.actuals.length) (ordinalIn : ordinal ≤ item.count)
    (found : selectedAssociation calls text info item ordinal frame = some (slot, named, cursor)) :
    slot ≤ frame.actuals.length := by
  dsimp only [selectedAssociation, actualAssociation] at found
  split at found
  · cases found
    exact namedSlot_bound calls text info item _ _ _ window
  · split at found
    · contradiction
    · cases found
      have := window.last
      omega

def processSelection (calls : ApplicationPackageCalls.Calls) (text : Source)
    (context : Predicate.ParseContext) (input : ApplicationPackages.ApplicationScan)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (ordinal : Nat)
    (frame : ActualFrame) (selection : Nat × Bool × Nat) : Option ActualFrame := do
  let (slot, named, cursor) := selection
  let payload ← payloadModel calls text context input info slot {frame with cursor := cursor, named := named}
  finishModel calls text context info item ordinal payload

def normalizedActualStep (calls : ApplicationPackageCalls.Calls) (text : Source)
    (context : Predicate.ParseContext) (input : ApplicationPackages.ApplicationScan)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (ordinal : Nat) (frame : ActualFrame) :
    Option ActualFrame :=
  (selectedAssociation calls text info item ordinal frame).bind
    (processSelection calls text context input info item ordinal frame)

theorem normalizedActualStep_meaning (calls : ApplicationPackageCalls.Calls) (text : Source)
    (context : Predicate.ParseContext) (input : ApplicationPackages.ApplicationScan)
    (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (ordinal : Nat) (frame : ActualFrame)
    (window : ActualWindow item frame.actuals.length) (ordinalIn : ordinal ≤ item.count) :
    normalizedActualStep calls text context input info item ordinal frame =
      actualStep calls text context input info item ordinal frame := by
  unfold normalizedActualStep actualStep
  change (selectedAssociation calls text info item ordinal frame).bind
    (processSelection calls text context input info item ordinal frame) =
    (selectedAssociation calls text info item ordinal frame).bind _
  cases found : selectedAssociation calls text info item ordinal frame with
  | none => rfl
  | some selection =>
    obtain ⟨slot, named, cursor⟩ := selection
    have bounded := selected_slot_bound window ordinalIn found
    by_cases unavailable : slot = 0 ∨ frame.seen.getD (slot - 1) false = true
    · simp only [Option.bind_some, processSelection, payloadModel, unavailable, ↓reduceIte]
      rfl
    · have positive : slot ≠ 0 := fun zero => unavailable (Or.inl zero)
      have inside := actual_offset_lt_length positive bounded
      cases read : actualPayload calls text context input (info.parameterAt slot) info cursor
          {frame.actual slot with first := cursor} with
      | mk following actual =>
        by_cases stopped : following ≤ cursor <;>
          simp (disch := assumption) [processSelection, payloadModel, finishModel, ActualFrame.actual,
            List.getD_eq_getElem?_getD, *] at * <;>
          simp_all
        all_goals try rfl
        all_goals
          by_cases output : (info.parameterAt slot).mode = .output <;>
            by_cases last : ordinal = item.count <;>
            simp_all
        all_goals
          have advances : ¬ following ≤ cursor := by omega
          simp only [advances, ↓reduceIte, Option.bind_some]
          simp (disch := assumption) [*, List.set_set]

end Silver.ApplicationPackageCalls.Native.Call

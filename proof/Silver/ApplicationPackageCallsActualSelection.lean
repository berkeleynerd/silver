module

public import Silver.ApplicationPackageCallsModel
public import Silver.ScalarAssociations

@[expose] public section

namespace Silver.ApplicationPackageCalls

open Compose ApplicationPackages

/-- Last matching formal in the native named-association loop, including a
zero return when the loop saw no matching spelling. -/
private theorem last_matching_key (isMatch : Nat → Bool) (keys : List Nat) (start : Nat) :
    let selected := keys.foldl (fun previous key => if isMatch key then key else previous) start
    selected = start ∨ selected ∈ keys ∧ isMatch selected = true := by
  induction keys generalizing start with
  | nil => exact Or.inl rfl
  | cons head rest ih =>
    dsimp only [List.foldl_cons]
    rcases ih (if isMatch head then head else start) with same | ⟨member, found⟩
    · rw [same]
      by_cases accepts : isMatch head = true
      · rw [ite_eq_left accepts]
        exact Or.inr ⟨List.mem_cons_self .., accepts⟩
      · rw [ite_eq_right accepts]
        exact Or.inl rfl
    · exact Or.inr ⟨List.mem_cons_of_mem _ member, found⟩

theorem namedSlot_member {calls : Calls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {first after : Nat}
    (positive : namedSlot calls text info item first after ≠ 0) :
    let slot := namedSlot calls text info item first after
    slot ∈ formalSlots item ∧ calls.sameName text ⟨first, after⟩ (info.parameterAt slot).specName = true :=
  (last_matching_key (fun index => calls.sameName text ⟨first, after⟩ (info.parameterAt index).specName)
    (formalSlots item) 0).resolve_left positive

theorem association_slot_range {calls : Calls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {ordinal : Nat} {frame : ActualFrame} {slot : Nat}
    {named : Bool} {cursor : Nat}
    (selected : actualAssociation calls text info item ordinal frame = some (slot, named, cursor))
    (nonzero : slot ≠ 0) (fromOne : 0 < ordinal) (inCount : ordinal ≤ item.count) :
    item.formalFirst ≤ slot ∧ slot < item.formalFirst + item.count := by
  dsimp only [actualAssociation] at selected
  split at selected
  · cases selected
    obtain ⟨offset, member, index⟩ := List.mem_map.mp (namedSlot_member nonzero).1
    have inside := List.mem_range.mp member
    omega
  · split at selected
    · cases selected
    · cases selected
      omega

/-- The native procedure stores the payload end and, except for pure outputs,
the interval's exact state reads in the selected physical row. -/
def recordedActual (calls : Calls) (text : Source) (context : Predicate.ParseContext)
    (info : PackageBindings.Metadata) (parameter : PackageBindings.Formal) (cursor : Nat)
    (payload : Nat × PackageActual) : PackageActual :=
  let recorded := {payload.2 with after := payload.1}
  if parameter.mode ≠ .output then
    {recorded with reads := calls.stateReads text context info cursor payload.1}
  else recorded

/-- Expose one accepted source association, its payload and separator. Fixed
table lookup and named reordering are left explicit for the enclosing fold. -/
theorem actual_step_fields {calls : Calls} {text : Source} {context : Predicate.ParseContext}
    {input : ApplicationScan} {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {ordinal : Nat} {before after : ActualFrame}
    (accepted : actualStep calls text context input info item ordinal before = some after) :
    ∃ slot named cursor, actualAssociation calls text info item ordinal before = some (slot, named, cursor) ∧
      slot ≠ 0 ∧ before.seen.getD (slot - 1) false = false ∧
      let parameter := info.parameterAt slot
      let payload := actualPayload calls text context input parameter info cursor {before.actual slot with first := cursor}
      let written := recordedActual calls text context info parameter cursor payload
      cursor < payload.1 ∧ after.seen = before.seen.set (slot - 1) true ∧
      after.actuals = before.actuals.set (slot - 1) written ∧
      after.cursor = calls.take text payload.1 (if ordinal = item.count then .symbol ")" else .symbol ",") ∧
      after.cursor ≠ 0 ∧ after.named = named := by
  unfold actualStep at accepted
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff] at accepted
  obtain ⟨⟨slot, named, cursor⟩, selected, accepted⟩ := accepted
  dsimp only at accepted
  by_cases unavailable : slot = 0 ∨ before.seen.getD (slot - 1) false = true
  · simp only [unavailable, ↓reduceIte, reduceCtorEq] at accepted
  · have nonzero : slot ≠ 0 := fun zero => unavailable (Or.inl zero)
    have fresh : before.seen.getD (slot - 1) false = false :=
      Bool.of_not_eq_true (fun already => unavailable (Or.inr already))
    refine ⟨slot, named, cursor, selected, nonzero, fresh, ?_⟩
    simp only [unavailable, ↓reduceIte] at accepted
    cases read : actualPayload calls text context input (info.parameterAt slot) info cursor
        {before.actual slot with first := cursor} with
    | mk following value =>
      simp only [read] at accepted ⊢
      by_cases stopped : following ≤ cursor
      · simp only [stopped, ↓reduceIte, reduceCtorEq] at accepted
      · by_cases absent : calls.take text following (if ordinal = item.count then .symbol ")" else .symbol ",") = 0
        · simp only [stopped, absent, ↓reduceIte, reduceCtorEq] at accepted
        · simp only [stopped, absent, ↓reduceIte, Option.some.injEq] at accepted
          subst after
          exact ⟨by omega, rfl, rfl, rfl, absent, rfl⟩

end Silver.ApplicationPackageCalls

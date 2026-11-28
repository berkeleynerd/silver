module

public import Silver.ApplicationPackageCallsActualSelection
public import Silver.ApplicationPackageCallsSemantics
public import Silver.ApplicationPackageEffectBits

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages PackageBindings

private def NoTargets (rows : List PackageActual) : Prop := ∀ row ∈ rows, row.writtenState = 0

private theorem noTargets_lookup {rows : List PackageActual} (empty : NoTargets rows) (index : Nat) :
    (rows.getD index {}).writtenState = 0 := by
  rw [List.getD_eq_getElem?_getD]
  cases found : rows[index]? with
  | none => rfl
  | some row => exact empty row (List.mem_of_getElem? found)

private theorem noTargets_set {rows : List PackageActual} (empty : NoTargets rows) (index : Nat)
    (row : PackageActual) (zero : row.writtenState = 0) : NoTargets (rows.set index row) := by
  intro seen member
  rcases List.mem_or_eq_of_mem_set member with earlier | rfl
  · exact empty seen earlier
  · exact zero

/-- State retained while reading the actual list; read masks are accumulated
separately. The complete BodyScan is retained, including all flow intervals. -/
private def frameState (frame : ActualFrame) : BodyScan × Bool × StateSet × StateSet :=
  (frame.result.result.scan, frame.result.result.allowProcedureCalls, frame.result.result.writes, frame.callWrites)

private theorem input_step {calls : Calls} {text : Source} {context : ParseContext} {input : ApplicationScan}
    {info : Metadata} {item : Routine} {ordinal : Nat} {before after : ActualFrame}
    (modes : ∀ slot ∈ formalSlots item, (info.parameterAt slot).mode = .input)
    (one : 0 < ordinal) (last : ordinal ≤ item.count) (empty : NoTargets before.actuals)
    (read : actualStep calls text context input info item ordinal before = some after) :
    frameState after = frameState before ∧ NoTargets after.actuals := by
  unfold actualStep at read
  simp only [Option.bind_eq_bind, Option.bind_eq_some_iff] at read
  obtain ⟨⟨slot, named, cursor⟩, selected, read⟩ := read
  dsimp only at read
  split at read
  · contradiction
  · rename_i available
    have positive : slot ≠ 0 := fun zero => available (Or.inl zero)
    have inside := association_slot_range selected positive one last
    have member : slot ∈ formalSlots item :=
      List.mem_map.mpr ⟨slot - item.formalFirst, List.mem_range.mpr (by omega), by omega⟩
    have mode := modes slot member
    have target : (before.actual slot).writtenState = 0 := noTargets_lookup empty _
    simp only [actualPayload, mode, ↓reduceIte] at read
    split at read
    · contradiction
    · let following := calls.actualAfter text context cursor input.scan.facts (inputFormal (info.parameterAt slot))
      by_cases absent : calls.take text following (if ordinal = item.count then .symbol ")" else .symbol ",") = 0
      · simp [following, absent] at read
      · simp [following, absent] at read
        subst after
        refine ⟨?_, ?_⟩
        · simp only [frameState, markState, target, ↓reduceIte]
        · exact noTargets_set empty _ _ target

private theorem input_fold {calls : Calls} {text : Source} {context : ParseContext} {input : ApplicationScan}
    {info : Metadata} {item : Routine} (indices : List Nat) {before after : ActualFrame}
    (modes : ∀ slot ∈ formalSlots item, (info.parameterAt slot).mode = .input)
    (inside : ∀ index ∈ indices, index < item.count) (empty : NoTargets before.actuals)
    (read : indices.foldlM (fun frame index => actualStep calls text context input info item (index + 1) frame) before = some after) :
    frameState after = frameState before ∧ NoTargets after.actuals := by
  induction indices generalizing before with
  | nil =>
    cases Option.some.inj read
    exact ⟨rfl, empty⟩
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at read
    obtain ⟨middle, first, remaining⟩ := read
    have advanced := input_step modes (by omega) (Nat.succ_le_of_lt (inside index (List.mem_cons_self ..))) empty first
    have following := ih (fun i h => inside i (List.mem_cons_of_mem _ h)) advanced.2 remaining
    exact ⟨following.1.trans advanced.1, following.2⟩

theorem readActuals_input_frame {calls : Calls} {text : Source} {context : ParseContext} {input : ApplicationScan}
    {info : Metadata} {item : Routine} {position : Nat} {frame : ActualFrame}
    (modes : ∀ slot ∈ formalSlots item, (info.parameterAt slot).mode = .input)
    (read : readActuals calls text context input info item position = some frame) :
    frame.result.result.scan = input.scan ∧ frame.result.result.allowProcedureCalls = input.allowProcedureCalls ∧
      frame.result.result.writes = input.writes ∧ frame.callWrites = item.mayWrite := by
  have empty : NoTargets (List.replicate maxFormals ({} : PackageActual)) := by
    intro row member
    have same := (List.mem_replicate.mp member).2
    subst row
    rfl
  unfold readActuals at read
  split at read
  · cases Option.some.inj read
    exact ⟨rfl, rfl, rfl, rfl⟩
  · dsimp only at read
    split at read
    · contradiction
    · have state := (input_fold (List.range item.count) modes (fun i h => List.mem_range.mp h) empty read).1
      exact ⟨congrArg Prod.fst state, congrArg (fun value => value.2.1) state,
        congrArg (fun value => value.2.2.1) state, congrArg (fun value => value.2.2.2) state⟩

private theorem input_alias_step {calls text info item actuals before index after}
    (mode : (info.parameterAt index).mode = ProcedureBindings.Mode.input)
    (read : aliasStep calls text info item actuals before index = some after) : after = before := by
  simp only [aliasStep, mode, ↓reduceIte] at read
  split at read
  · contradiction
  · exact (Option.some.inj read).symm

private theorem input_alias_fold {calls text info item actuals} (indices : List Nat) {before after : ApplicationCall}
    (modes : ∀ index ∈ indices, (info.parameterAt index).mode = ProcedureBindings.Mode.input)
    (read : indices.foldlM (aliasStep calls text info item actuals) before = some after) : after = before := by
  induction indices generalizing before with
  | nil => exact (Option.some.inj read).symm
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at read
    obtain ⟨middle, first, remaining⟩ := read
    exact (ih (fun i h => modes i (List.mem_cons_of_mem _ h)) remaining).trans
      (input_alias_step (modes index (List.mem_cons_self ..)) first)

theorem checkAliases_inputs {calls text info item frame checked}
    (modes : ∀ index ∈ formalSlots item, (info.parameterAt index).mode = ProcedureBindings.Mode.input)
    (read : checkAliases calls text info item frame = some checked) : checked = frame.result :=
  input_alias_fold (formalSlots item) modes read

private theorem reset_empty_fold (calls : Calls) (text : Source) (context : ParseContext) (info : Metadata)
    (indices : List Nat) (value : ApplicationCall) :
    indices.foldl (fun result index => resetState calls text context info emptyStateSet result (index + 1)) value = value := by
  induction indices generalizing value with
  | nil => rfl
  | cons index rest ih =>
    rw [List.foldl_cons, ih]
    simp only [resetState, ApplicationPackageEffects.emptyStateSet_get, Bool.false_eq_true, false_and, ↓reduceIte]

/-- A successful input-only function call keeps the full incoming scan except
for its endpoint, and keeps permission flags. No input or state range is
silently replaced by a narrower value. The write-mask union remains exact even
for arbitrary caller-provided mask storage. -/
theorem function_call_frame {calls : Calls} {text : Source} {context : ParseContext} {input : ApplicationScan}
    {info : Metadata} {position : Nat}
    (accepted : (packageCallAt calls text context input info position .function).value.after ≠ 0)
    (modes : ∀ index ∈ formalSlots (info.routineAt (packageCallee calls text context info position .function)),
      (info.parameterAt index).mode = .input)
    (unwritten : (info.routineAt (packageCallee calls text context info position .function)).mayWrite = emptyStateSet) :
    let called := packageCallAt calls text context input info position .function
    called.result.scan = {input.scan with position := called.value.after} ∧
      called.result.allowProcedureCalls = input.allowProcedureCalls ∧
      called.result.writes = stateUnion input.writes emptyStateSet := by
  obtain ⟨callee, item, frame, checked, selected, _, itemEq, _, read, aliases, returned, _, _⟩ := accepted_call accepted
  have inputs : ∀ index ∈ formalSlots item, (info.parameterAt index).mode = ProcedureBindings.Mode.input := by
    rw [itemEq, selected]
    exact modes
  have noWrites : item.mayWrite = emptyStateSet := by rw [itemEq, selected]; exact unwritten
  obtain ⟨scan, permission, writes, effect⟩ := readActuals_input_frame inputs read
  have same := checkAliases_inputs inputs aliases
  rw [returned]
  simp only [finishCall, same, effect, noWrites, reset_empty_fold,
    reduceCtorEq, ↓reduceIte, scan, permission, writes, and_self]

end Silver.ApplicationPackageCalls

module

public import Silver.ApplicationPackageProcedureWriteBits

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose ApplicationPackages PackageBindings

set_option backward.dsimp.instances true

/-- Each fixed-table row retains the state identity of its own original
writable target. Input rows carry no write, including unfilled storage. -/
def ActualTargetRows (calls : Calls) (text : Source) (context : Predicate.ParseContext)
    (info : Metadata) (rows : List PackageActual) : Prop :=
  ∀ slot, 0 < slot → slot ≤ rows.length →
    let row := rows.getD (slot - 1) {}
    row.writtenState = if (info.parameterAt slot).mode = .input then 0
      else calls.stateTarget text context info row.first

private theorem recorded_target {calls : Calls} {text : Source} {context : Predicate.ParseContext}
    {input : ApplicationScan} {info : Metadata} {parameter : Formal} {cursor : Nat} {original : PackageActual}
    (inputTarget : parameter.mode = .input → original.writtenState = 0) :
    let payload := actualPayload calls text context input parameter info cursor {original with first := cursor}
    let row := recordedActual calls text context info parameter cursor payload
    row.writtenState = if parameter.mode = .input then 0 else calls.stateTarget text context info row.first := by
  by_cases inputMode : parameter.mode = .input <;> by_cases outputMode : parameter.mode = .output <;>
    simp [actualPayload, recordedActual, inputMode, outputMode, inputTarget]

private theorem actual_step_targets {calls text context input info item ordinal before after}
    (prior : ActualTargetRows calls text context info before.actuals)
    (read : actualStep calls text context input info item ordinal before = some after) :
    after.actuals.length = before.actuals.length ∧ ActualTargetRows calls text context info after.actuals := by
  obtain ⟨slot, named, cursor, _, positive, _, _, _, written, _, _, _⟩ := actual_step_fields read
  let payload := actualPayload calls text context input (info.parameterAt slot) info cursor
    {before.actual slot with first := cursor}
  let row := recordedActual calls text context info (info.parameterAt slot) cursor payload
  have updated : after.actuals = before.actuals.set (slot - 1) row := written
  refine ⟨by simp only [updated, List.length_set], ?_⟩
  intro observed observedPositive observedBound
  have oldBound : observed ≤ before.actuals.length := by simpa only [updated, List.length_set] using observedBound
  by_cases same : observed = slot
  · subst observed
    have inside : slot - 1 < before.actuals.length := by omega
    have original : (info.parameterAt slot).mode = .input → (before.actual slot).writtenState = 0 := by
      intro mode
      simpa only [mode, ↓reduceIte, ActualFrame.actual] using prior slot observedPositive oldBound
    dsimp only
    simp only [updated, List.getD_eq_getElem?_getD, List.getElem?_set_self inside, Option.getD_some]
    exact recorded_target original
  · have apart : slot - 1 ≠ observed - 1 := by omega
    dsimp only
    simp only [updated, List.getD_eq_getElem?_getD, List.getElem?_set_ne apart]
    simpa only [List.getD_eq_getElem?_getD] using prior observed observedPositive oldBound

private theorem actual_fold_targets {calls text context input info item}
    (indices : List Nat) {before after : ActualFrame}
    (prior : ActualTargetRows calls text context info before.actuals)
    (read : indices.foldlM (fun frame index => actualStep calls text context input info item (index + 1) frame)
      before = some after) :
    after.actuals.length = before.actuals.length ∧ ActualTargetRows calls text context info after.actuals := by
  induction indices generalizing before with
  | nil => cases Option.some.inj read; exact ⟨rfl, prior⟩
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at read
    obtain ⟨middle, first, remaining⟩ := read
    obtain ⟨count, changed⟩ := actual_step_targets prior first
    obtain ⟨finalCount, targets⟩ := ih changed remaining
    exact ⟨finalCount.trans count, targets⟩

/-- Named reordering and input/output modes preserve the target's own source
identity in the final physical actual table. No whole metadata validity premise
or semantic alias/safety certificate is used. -/
theorem readActuals_target_rows {calls text context input info item position frame}
    (zero : calls.stateTarget text context info 0 = 0)
    (read : readActuals calls text context input info item position = some frame) :
    frame.actuals.length = maxFormals ∧ ActualTargetRows calls text context info frame.actuals := by
  have initial : ActualTargetRows calls text context info (List.replicate maxFormals ({} : PackageActual)) := by
    intro slot positive bounded
    have inside : slot - 1 < maxFormals := by simp only [List.length_replicate] at bounded; omega
    simp only [List.getD_eq_getElem?_getD, List.getElem?_replicate, inside, ↓reduceIte, Option.getD_some]
    split
    · rfl
    · exact zero.symm
  unfold readActuals at read
  split at read
  · cases Option.some.inj read
    exact ⟨List.length_replicate, initial⟩
  · dsimp only at read
    split at read
    · contradiction
    · have result := actual_fold_targets (List.range item.count) initial read
      exact ⟨result.1.trans List.length_replicate, result.2⟩

/-- The raw write mask is exactly the callee's previous effect plus each
explicit writable source target. Input actuals cannot contribute a write. -/
theorem readActuals_writable_bits {calls text context input info item position frame}
    (zero : calls.stateTarget text context info 0 = 0)
    (read : readActuals calls text context input info item position = some frame)
    (first : 0 < item.count → 0 < item.formalFirst)
    (capacity : 0 < item.count → item.formalFirst + item.count - 1 ≤ maxFormals)
    (identity : Nat) (positive : 0 < identity) (inside : identity ≤ item.mayWrite.length) :
    StateSet.get frame.callWrites identity = true ↔ StateSet.get item.mayWrite identity = true ∨
      ∃ slot ∈ formalSlots item, (info.parameterAt slot).mode ≠ .input ∧
        calls.stateTarget text context info (frame.actual slot).first = identity := by
  rw [readActuals_write_bits read capacity identity positive inside]
  have targets := readActuals_target_rows zero read
  have meaning (slot : Nat) (member : slot ∈ formalSlots item) :
      (frame.actual slot).writtenState =
        if (info.parameterAt slot).mode = .input then 0
        else calls.stateTarget text context info (frame.actual slot).first := by
    obtain ⟨offset, bound, rfl⟩ := List.mem_map.mp member
    have active := List.mem_range.mp bound
    have nonempty : 0 < item.count := by omega
    apply targets.2
    · have start := first nonempty; omega
    · rw [targets.1]
      have last := capacity nonempty
      omega
  constructor
  · rintro (implicit | ⟨slot, member, written⟩)
    · exact Or.inl implicit
    · rw [meaning slot member] at written
      split at written
      · omega
      · exact Or.inr ⟨slot, member, by assumption, written⟩
  · rintro (implicit | ⟨slot, member, writable, written⟩)
    · exact Or.inl implicit
    · exact Or.inr ⟨slot, member, by rw [meaning slot member, ite_eq_right writable]; exact written⟩

end Silver.ApplicationPackageCalls

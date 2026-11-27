module

public import Silver.ApplicationPackageCallsActualOrder

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose ApplicationPackages PackageBindings

set_option backward.dsimp.instances true

private theorem actual_step_mask {calls : Calls} {text : Source} {context : Predicate.ParseContext}
    {input : ApplicationScan} {info : Metadata} {item : Routine} {ordinal : Nat}
    {before after : ActualFrame} {slot cursor : Nat} {named : Bool}
    (selected : actualAssociation calls text info item ordinal before = some (slot, named, cursor))
    (read : actualStep calls text context input info item ordinal before = some after) :
    let payload := actualPayload calls text context input (info.parameterAt slot) info cursor
      {before.actual slot with first := cursor}
    let row := recordedActual calls text context info (info.parameterAt slot) cursor payload
    after.callWrites = markState before.callWrites row.writtenState := by
  unfold actualStep at read
  rw [selected] at read
  simp only [Option.bind_eq_bind, Option.bind_some] at read
  split at read
  · contradiction
  · cases payload : actualPayload calls text context input (info.parameterAt slot) info cursor
        {before.actual slot with first := cursor} with
    | mk following actual =>
      rw [payload] at read
      dsimp only at read
      split at read
      · contradiction
      · by_cases absent : calls.take text following
            (if ordinal = item.count then .symbol ")" else .symbol ",") = 0
        · simp only [absent, ↓reduceIte, reduceCtorEq] at read
        · simp only [absent, ↓reduceIte, Option.some.injEq] at read
          subst after
          rfl

private theorem actual_step_write_source {calls text context input info item ordinal before after}
    (read : actualStep calls text context input info item ordinal before = some after) :
    ∃ entry, ActualSourceStep calls text context input info item ordinal before after entry ∧
      after.callWrites = markState before.callWrites entry.2.writtenState := by
  obtain ⟨slot, named, cursor, selected, positive, fresh, progress, seen, written, separator, consumed, namedEq⟩ :=
    actual_step_fields read
  let payload := actualPayload calls text context input (info.parameterAt slot) info cursor
    {before.actual slot with first := cursor}
  let row := recordedActual calls text context info (info.parameterAt slot) cursor payload
  have fields : row.first = cursor ∧ row.after = payload.1 ∧ row.target = payload.2.target := by
    by_cases inputMode : (info.parameterAt slot).mode = .input <;>
      by_cases outputMode : (info.parameterAt slot).mode = .output <;>
      simp [row, payload, recordedActual, actualPayload, inputMode, outputMode]
  refine ⟨(slot, row), ?_, actual_step_mask selected read⟩
  constructor
  · simpa only [namedEq, fields.1] using selected
  · exact Nat.pos_of_ne_zero positive
  · exact fresh
  · simpa only [fields.1, fields.2.1] using progress
  · dsimp only
    rw [fields.1]
    exact fields.2
  · exact seen
  · exact written
  · simpa only [fields.2.1] using separator
  · exact consumed

private theorem actual_fold_write_source {calls text context input info item}
    (offsets : List Nat) {before after : ActualFrame}
    (read : offsets.foldlM (fun frame index => actualStep calls text context input info item (index + 1) frame)
      before = some after) :
    ∃ entries, ActualSourceTrace calls text context input info item offsets before after entries ∧
      after.callWrites = entries.foldl (fun bits entry => markState bits entry.2.writtenState) before.callWrites := by
  induction offsets generalizing before with
  | nil => cases Option.some.inj read; exact ⟨[], .nil _, rfl⟩
  | cons offset rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at read
    obtain ⟨middle, first, remaining⟩ := read
    obtain ⟨entry, source, written⟩ := actual_step_write_source first
    obtain ⟨entries, later, writes⟩ := ih remaining
    refine ⟨entry :: entries, .cons source later, ?_⟩
    rw [writes, written]
    rfl

/-- Retain the exact source-order mask updates alongside the actual-list
reading, before translating them through the formal-order argument binding. -/
theorem readActuals_write_source {calls text context input info item position frame}
    (read : readActuals calls text context input info item position = some frame) :
    ∃ entries, ActualListAt calls text context input info item position frame entries ∧
      frame.callWrites = entries.foldl (fun bits entry => markState bits entry.2.writtenState) item.mayWrite := by
  unfold readActuals at read
  by_cases empty : item.count = 0
  · simp only [empty, ↓reduceIte, Option.some.injEq] at read
    subst frame
    exact ⟨[], .empty empty, rfl⟩
  · by_cases missing : calls.take text position (.symbol "(") = 0
    · simp only [empty, missing, ↓reduceIte, reduceCtorEq] at read
    · simp only [empty, missing, ↓reduceIte] at read
      obtain ⟨entries, trace, writes⟩ := actual_fold_write_source _ read
      exact ⟨entries, .supplied (Nat.pos_of_ne_zero empty) missing trace, writes⟩

theorem markState_length (bits : StateSet) (identity : Nat) :
    (markState bits identity).length = bits.length := by
  unfold markState
  split <;> simp only [List.length_set]

theorem markState_bit (bits : StateSet) (written observed : Nat)
    (positive : 0 < observed) (inside : observed ≤ bits.length) :
    StateSet.get (markState bits written) observed = true ↔
      StateSet.get bits observed = true ∨ written = observed := by
  by_cases zero : written = 0
  · simp only [markState, zero, ↓reduceIte, Nat.ne_of_lt positive, or_false]
  · by_cases same : written = observed
    · subst written
      simp only [markState, zero, ↓reduceIte, StateSet.get, List.getD_eq_getElem?_getD,
        List.getElem?_set_self (by omega : observed - 1 < bits.length), Option.getD_some, or_true]
    · have apart : written - 1 ≠ observed - 1 := by omega
      simp only [markState, zero, ↓reduceIte, StateSet.get, List.getD_eq_getElem?_getD,
        List.getElem?_set_ne apart, same, or_false]

private theorem marked_rows_bit (entries : List (Nat × PackageActual)) (bits : StateSet)
    (observed : Nat) (positive : 0 < observed) (inside : observed ≤ bits.length) :
    StateSet.get (entries.foldl (fun bits entry => markState bits entry.2.writtenState) bits) observed = true ↔
      StateSet.get bits observed = true ∨ ∃ entry ∈ entries, entry.2.writtenState = observed := by
  induction entries generalizing bits with
  | nil => simp only [List.foldl_nil, List.not_mem_nil, false_and, exists_false, or_false]
  | cons head rest ih =>
    rw [List.foldl_cons, ih _ (by rw [markState_length]; exact inside),
      markState_bit bits head.2.writtenState observed positive inside]
    constructor
    · rintro ((prior | first) | ⟨entry, member, written⟩)
      · exact Or.inl prior
      · exact Or.inr ⟨head, List.mem_cons_self .., first⟩
      · exact Or.inr ⟨entry, List.mem_cons_of_mem _ member, written⟩
    · rintro (prior | ⟨entry, member, written⟩)
      · exact Or.inl (Or.inl prior)
      · rcases List.mem_cons.mp member with rfl | later
        · exact Or.inl (Or.inr written)
        · exact Or.inr ⟨entry, later, written⟩

/-- Every live state bit is exactly the callee's previous write effect or one
of the original actual rows. Named source order is translated through the
checked complete formal permutation, without assuming distinct targets. -/
theorem readActuals_write_bits {calls text context input info item position frame}
    (read : readActuals calls text context input info item position = some frame)
    (capacity : 0 < item.count → item.formalFirst + item.count - 1 ≤ maxFormals)
    (identity : Nat) (positive : 0 < identity) (inside : identity ≤ item.mayWrite.length) :
    StateSet.get frame.callWrites identity = true ↔ StateSet.get item.mayWrite identity = true ∨
      ∃ slot ∈ formalSlots item, (frame.actual slot).writtenState = identity := by
  obtain ⟨entries, source, writes⟩ := readActuals_write_source read
  have covered := source.complete capacity
  have rows := source.rows capacity
  have entries_iff : (∃ entry ∈ entries, entry.2.writtenState = identity) ↔
      ∃ slot ∈ formalSlots item, (frame.actual slot).writtenState = identity := by
    constructor
    · rintro ⟨entry, member, written⟩
      have range := covered.mem_iff.mp (List.mem_map.mpr ⟨entry, member, rfl⟩)
      have slot : entry.1 ∈ formalSlots item := by
        simpa only [formalSlots, List.range'_eq_map_range] using range
      exact ⟨entry.1, slot, by rw [rows _ member]; exact written⟩
    · rintro ⟨slot, member, written⟩
      have range : slot ∈ List.range' item.formalFirst item.count := by
        simpa only [formalSlots, List.range'_eq_map_range] using member
      obtain ⟨entry, present, same⟩ := List.mem_map.mp (covered.mem_iff.mpr range)
      refine ⟨entry, present, ?_⟩
      rw [← same, rows _ present] at written
      exact written
  rw [writes, marked_rows_bit entries item.mayWrite identity positive inside, entries_iff]

end Silver.ApplicationPackageCalls

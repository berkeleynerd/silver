module

public import Silver.ApplicationPackageCallsActualTrace

@[expose] public section

namespace Silver.ApplicationPackageCalls

open Compose ApplicationPackages

def initialActualFrame (input : ApplicationScan) (item : PackageBindings.Routine) (cursor : Nat) : ActualFrame :=
  {cursor, result := {result := input}, callWrites := item.mayWrite}

inductive ActualListAt (calls : Calls) (text : Source) (context : Predicate.ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (item : PackageBindings.Routine) :
    Nat → ActualFrame → List (Nat × PackageActual) → Prop
  | empty {afterName} : item.count = 0 →
      ActualListAt calls text context input info item afterName (initialActualFrame input item afterName) []
  | supplied {afterName parsed entries} : 0 < item.count → calls.take text afterName (.symbol "(") ≠ 0 →
      ActualSourceTrace calls text context input info item (List.range item.count)
        (initialActualFrame input item (calls.take text afterName (.symbol "("))) parsed entries →
      ActualListAt calls text context input info item afterName parsed entries

theorem readActuals_source {calls text context input info item afterName parsed}
    (accepted : readActuals calls text context input info item afterName = some parsed) :
    ∃ entries, ActualListAt calls text context input info item afterName parsed entries := by
  unfold readActuals at accepted
  by_cases empty : item.count = 0
  · simp only [empty, ↓reduceIte, Option.some.injEq] at accepted
    subst parsed
    exact ⟨[], .empty empty⟩
  · by_cases missing : calls.take text afterName (.symbol "(") = 0
    · simp only [empty, missing, ↓reduceIte, reduceCtorEq] at accepted
    · simp only [empty, missing, ↓reduceIte] at accepted
      obtain ⟨entries, trace⟩ := actual_fold_trace _ accepted
      exact ⟨entries, .supplied (Nat.pos_of_ne_zero empty) missing trace⟩

theorem ActualListAt.complete {calls text context input info item afterName parsed entries}
    (source : ActualListAt calls text context input info item afterName parsed entries)
    (capacity : 0 < item.count → item.formalFirst + item.count - 1 ≤ PackageBindings.maxFormals) :
    (entries.map Prod.fst).Perm (List.range' item.formalFirst item.count) := by
  cases source with
  | empty zero => simp [zero]
  | supplied positive _ trace =>
    apply trace.complete
    simpa only [initialActualFrame, List.length_replicate] using capacity positive

/-- A physical slot seen before the suffix cannot be changed by any of its
successful source actuals. This holds for named and positional suffixes. -/
theorem ActualSourceTrace.keeps_seen_row {calls text context input info item offsets before after entries}
    (trace : ActualSourceTrace calls text context input info item offsets before after entries)
    {slot : Nat} (positive : 0 < slot) (used : before.seen.getD (slot - 1) false = true) :
    after.actual slot = before.actual slot := by
  induction trace with
  | nil => rfl
  | @cons index rest before middle after entry entries step tail ih =>
    have different : entry.1 - 1 ≠ slot - 1 := by
      intro eq
      have same : entry.1 = slot := by have := step.positive; omega
      have fresh := step.fresh
      rw [same, used] at fresh
      contradiction
    have stillUsed : middle.seen.getD (slot - 1) false = true := by
      rw [step.seen]
      simpa only [List.getD_eq_getElem?_getD, List.getElem?_set_ne different] using used
    rw [ih stillUsed]
    simp only [ActualFrame.actual, step.written, List.getD_eq_getElem?_getD, List.getElem?_set_ne different]

theorem ActualSourceTrace.rows {calls text context input info item offsets before after entries}
    (trace : ActualSourceTrace calls text context input info item offsets before after entries)
    (each : ∀ i ∈ offsets, i < item.count)
    (seenCapacity : item.formalFirst + item.count - 1 ≤ before.seen.length)
    (actualCapacity : item.formalFirst + item.count - 1 ≤ before.actuals.length) :
    ∀ row ∈ entries, after.actual row.1 = row.2 := by
  induction trace with
  | nil => simp
  | @cons index rest before middle after entry entries step tail ih =>
    have indexIn := each index (List.mem_cons_self ..)
    have inside := association_slot_range step.association (Nat.ne_of_gt step.positive) (by omega) (by omega)
    have positive := step.positive
    intro row member
    rcases List.mem_cons.mp member with same | later
    · subst row
      have marked : middle.seen.getD (entry.1 - 1) false = true := by
        rw [step.seen]
        simp only [List.getD_eq_getElem?_getD, List.getElem?_set_self (by omega : entry.1 - 1 < before.seen.length), Option.getD_some]
      rw [tail.keeps_seen_row positive marked]
      simp only [ActualFrame.actual, step.written, List.getD_eq_getElem?_getD,
        List.getElem?_set_self (by omega : entry.1 - 1 < before.actuals.length), Option.getD_some]
    · apply ih (fun i h => each i (List.mem_cons_of_mem _ h)) _ _ row later
      · simpa only [step.seen, List.length_set] using seenCapacity
      · simpa only [step.written, List.length_set] using actualCapacity

theorem ActualListAt.rows {calls text context input info item afterName parsed entries}
    (source : ActualListAt calls text context input info item afterName parsed entries)
    (capacity : 0 < item.count → item.formalFirst + item.count - 1 ≤ PackageBindings.maxFormals) :
    ∀ row ∈ entries, parsed.actual row.1 = row.2 := by
  cases source with
  | empty => simp
  | supplied positive _ trace =>
    apply trace.rows (fun _ h => List.mem_range.mp h)
    · simpa only [initialActualFrame, List.length_replicate] using capacity positive
    · simpa only [initialActualFrame, List.length_replicate] using capacity positive

end Silver.ApplicationPackageCalls

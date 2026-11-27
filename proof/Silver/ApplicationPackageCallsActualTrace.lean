module

public import Silver.ApplicationPackageCallsActualSelection

@[expose] public section

namespace Silver.ApplicationPackageCalls

open Compose ApplicationPackages

private theorem recorded_fields (calls : Calls) (text : Source) (context : Predicate.ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (parameter : PackageBindings.Formal)
    (first : Nat) (original : PackageActual) :
    let payload := actualPayload calls text context input parameter info first {original with first := first}
    let cell := recordedActual calls text context info parameter first payload
    cell.first = first ∧ cell.after = payload.1 ∧ cell.target = payload.2.target := by
  by_cases inputMode : parameter.mode = .input <;>
    by_cases outputMode : parameter.mode = .output <;>
    simp [recordedActual, actualPayload, inputMode, outputMode]

/-- One successful source actual, with its physical write and the original
incoming flow. The emitted entry is keyed by the selected formal and carries
the author's actual payload span. -/
structure ActualSourceStep (calls : Calls) (text : Source) (context : Predicate.ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (ordinal : Nat) (before after : ActualFrame) (entry : Nat × PackageActual) : Prop where
  association : actualAssociation calls text info item ordinal before =
    some (entry.1, after.named, entry.2.first)
  positive : 0 < entry.1
  fresh : before.seen.getD (entry.1 - 1) false = false
  progress : entry.2.first < entry.2.after
  payload : let native := actualPayload calls text context input (info.parameterAt entry.1) info
              entry.2.first {before.actual entry.1 with first := entry.2.first}
            entry.2.after = native.1 ∧ entry.2.target = native.2.target
  seen : after.seen = before.seen.set (entry.1 - 1) true
  written : after.actuals = before.actuals.set (entry.1 - 1) entry.2
  separator : after.cursor = calls.take text entry.2.after (if ordinal = item.count then .symbol ")" else .symbol ",")
  consumed : after.cursor ≠ 0

theorem actual_source_step {calls text context input info item ordinal before after}
    (success : actualStep calls text context input info item ordinal before = some after) :
    ∃ entry, ActualSourceStep calls text context input info item ordinal before after entry := by
  obtain ⟨slot, named, cursor, selected, nonzero, fresh, progress, seen, written, separator, consumed, namedEq⟩ :=
    actual_step_fields success
  let payload := actualPayload calls text context input (info.parameterAt slot) info cursor
    {before.actual slot with first := cursor}
  let row := recordedActual calls text context info (info.parameterAt slot) cursor payload
  have fields : row.first = cursor ∧ row.after = payload.1 ∧ row.target = payload.2.target :=
    recorded_fields calls text context input info (info.parameterAt slot) cursor (before.actual slot)
  refine ⟨(slot, row), ?_⟩
  constructor
  · simpa only [namedEq, fields.1] using selected
  · exact Nat.pos_of_ne_zero nonzero
  · exact fresh
  · simpa only [fields.1, fields.2.1] using progress
  · dsimp only
    rw [fields.1]
    exact fields.2
  · exact seen
  · exact written
  · simpa only [fields.2.1] using separator
  · exact consumed

/-- The sequence is in source order; each entry retains its absolute formal
slot and its exact stored payload. Offsets are the zero-based fold indices
used by `readActuals`. -/
inductive ActualSourceTrace (calls : Calls) (text : Source) (context : Predicate.ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (item : PackageBindings.Routine) :
    List Nat → ActualFrame → ActualFrame → List (Nat × PackageActual) → Prop
  | nil (frame) : ActualSourceTrace calls text context input info item [] frame frame []
  | cons {index offsets before middle after entry entries} :
      ActualSourceStep calls text context input info item (index + 1) before middle entry →
      ActualSourceTrace calls text context input info item offsets middle after entries →
      ActualSourceTrace calls text context input info item (index :: offsets) before after (entry :: entries)

theorem actual_fold_trace {calls text context input info item} (offsets : List Nat) {before after}
    (success : offsets.foldlM (fun frame index => actualStep calls text context input info item
        (index + 1) frame) before = some after) :
    ∃ entries, ActualSourceTrace calls text context input info item offsets before after entries := by
  induction offsets generalizing before with
  | nil =>
    exact ⟨[], (Option.some.inj success) ▸ ActualSourceTrace.nil before⟩
  | cons index rest ih =>
    simp only [List.foldlM_cons, Option.bind_eq_bind, Option.bind_eq_some_iff] at success
    obtain ⟨middle, advanced, remaining⟩ := success
    obtain ⟨entry, head⟩ := actual_source_step advanced
    obtain ⟨entries, tail⟩ := ih remaining
    exact ⟨entry :: entries, .cons head tail⟩

def sourceSeen (bits : List Bool) (slot : Nat) : Bool :=
  if slot = 0 then false else bits.getD (slot - 1) false

theorem sourceSeen_set {bits : List Bool} {slot : Nat} (positive : 0 < slot) (within : slot ≤ bits.length) :
    sourceSeen (bits.set (slot - 1) true) = ScalarAssociations.markFormal (sourceSeen bits) slot := by
  funext other
  by_cases same : other = slot
  · subst other
    simp only [sourceSeen, ScalarAssociations.markFormal, Nat.ne_of_gt positive, ↓reduceIte,
      List.getD_eq_getElem?_getD, List.getElem?_set_self (by omega : slot - 1 < bits.length), Option.getD_some]
  · by_cases zero : other = 0
    · subst other
      simp [sourceSeen, ScalarAssociations.markFormal, same]
    · have different : slot - 1 ≠ other - 1 := by omega
      simp only [sourceSeen, ScalarAssociations.markFormal, zero, same, ↓reduceIte, List.getD_eq_getElem?_getD,
        List.getElem?_set_ne different]

theorem ActualSourceTrace.selections {calls text context input info item offsets before after entries}
    (trace : ActualSourceTrace calls text context input info item offsets before after entries)
    (each : ∀ i ∈ offsets, i < item.count)
    (capacity : item.formalFirst + item.count - 1 ≤ before.seen.length) :
    ScalarAssociations.FreshSelections (sourceSeen before.seen) (entries.map Prod.fst) ∧
      entries.length = offsets.length ∧
      ∀ slot ∈ entries.map Prod.fst, item.formalFirst ≤ slot ∧ slot < item.formalFirst + item.count := by
  induction trace with
  | nil => exact ⟨.nil, rfl, fun _ h => (List.not_mem_nil h).elim⟩
  | @cons index rest before middle after entry entries step tail ih =>
    have indexIn := each index (List.mem_cons_self ..)
    have inside := association_slot_range step.association (Nat.ne_of_gt step.positive)
      (by omega) (by omega)
    have remaining := ih (fun i h => each i (List.mem_cons_of_mem _ h)) (by
      rw [step.seen, List.length_set]
      exact capacity)
    have fresh : sourceSeen before.seen entry.1 = false := by
      simpa only [sourceSeen, Nat.ne_of_gt step.positive, ↓reduceIte] using step.fresh
    have marked := remaining.1
    rw [step.seen, sourceSeen_set step.positive (by omega)] at marked
    refine ⟨.cons fresh marked, by simp [remaining.2.1], ?_⟩
    intro slot member
    rcases List.mem_cons.mp member with same | later
    · exact same ▸ inside
    · exact remaining.2.2 slot later

theorem ActualSourceTrace.complete {calls text context input info item before after entries}
    (trace : ActualSourceTrace calls text context input info item (List.range item.count) before after entries)
    (capacity : item.formalFirst + item.count - 1 ≤ before.seen.length) :
    (entries.map Prod.fst).Perm (List.range' item.formalFirst item.count) := by
  obtain ⟨fresh, size, inside⟩ := trace.selections (fun _ h => List.mem_range.mp h) capacity
  exact ScalarAssociations.selections_complete fresh.nodup (by simpa using size) inside

end Silver.ApplicationPackageCalls

module

public import Silver.ApplicationPackageCallsFormalArguments
public import Silver.ApplicationPackageCallsEffects

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages ScalarProcedures

theorem ActualSourceTrace.payload_positions {text context input info item offsets before after entries}
    (trace : ActualSourceTrace modelCalls text context input info item offsets before after entries)
    (beforeBound : before.cursor ≤ text.length + 1) :
    ∀ entry ∈ entries, entry.2.first ≤ text.length + 1 ∧ entry.2.after ≠ 0 := by
  induction trace with
  | nil => simp
  | @cons index rest before middle after first entries head _ ih =>
    obtain ⟨firstBound, nextBound⟩ := head.cursor_bounds beforeBound
    intro entry member
    rcases List.mem_cons.mp member with same | later
    · subst entry
      exact ⟨firstBound, Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) head.progress)⟩
    · exact ih nextBound entry later

theorem ActualListAt.slot_positions {text context input info item afterName frame entries}
    (source : ActualListAt modelCalls text context input info item afterName frame entries)
    (capacity : 0 < item.count → item.formalFirst + item.count - 1 ≤ PackageBindings.maxFormals) :
    ∀ slot ∈ formalSlots item, (frame.actual slot).first ≤ text.length + 1 ∧ (frame.actual slot).after ≠ 0 := by
  have positions : ∀ entry ∈ entries, entry.2.first ≤ text.length + 1 ∧ entry.2.after ≠ 0 := by
    cases source with
    | empty => simp
    | supplied _ _ trace => exact trace.payload_positions (fixedAfter_result_bound text _ "(" false (by decide))
  intro slot member
  have inRange : slot ∈ List.range' item.formalFirst item.count := by
    simpa only [formalSlots, List.range'_eq_map_range] using member
  obtain ⟨entry, present, same⟩ := List.mem_map.mp ((source.complete capacity).mem_iff.mpr inRange)
  rw [← same, source.rows capacity entry present]
  exact positions entry present

theorem ArgumentAt.procedure_source {text context input parameter row argument}
    (semantic : ArgumentAt text context input parameter row argument) (positive : row.after ≠ 0) :
    ProcedureActualAt text context.model row.first input.scan.facts (outputFormal parameter) argument row.after := by
  cases semantic with
  | value mode source _ _ => exact .input mode source
  | target mode targetEq ends _ =>
    have read : (procedureTargetActual text context.model row.first input.scan.facts (outputFormal parameter)).after ≠ 0 := by
      rw [targetEq, ← ends]; exact positive
    have parsed := ProcedureActualAt.target (parameter := outputFormal parameter) mode read
    rw [targetEq, ← ends] at parsed
    exact parsed

theorem ArgumentAt.target_spelling {text context input parameter row object}
    (semantic : ArgumentAt text context input parameter row (.target object)) (positive : row.after ≠ 0) :
    parameter.mode ≠ .input ∧ CellSpelling text context.model row.target.first row.target.after (targetCell object) := by
  cases semantic with
  | target mode targetEq ends _ =>
    have read : (procedureTargetActual text context.model row.first input.scan.facts (outputFormal parameter)).after ≠ 0 := by
      rw [targetEq, ← ends]; exact positive
    have spelling := procedureTargetActual_spelling read
    rw [targetEq] at spelling
    exact ⟨mode, spelling⟩

private theorem target_avoids_other {text : Source} {context : Predicate.Native.Context}
    {input} {info : PackageBindings.Metadata} {item} {frame : ActualFrame} {targetSlot otherSlot object argument}
    (target : ArgumentAt text context input (info.parameterAt targetSlot) (frame.actual targetSlot) (.target object))
    (other : ArgumentAt text context input (info.parameterAt otherSlot) (frame.actual otherSlot) argument)
    (checked : AliasSafe modelCalls text info item frame.actuals targetSlot)
    (targetEnd : (frame.actual targetSlot).after ≠ 0) (otherStart : (frame.actual otherSlot).first ≤ text.length + 1)
    (otherEnd : (frame.actual otherSlot).after ≠ 0) (otherMember : otherSlot ∈ formalSlots item)
    (different : targetSlot ≠ otherSlot) (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings) :
    Actual.avoids (targetCell object) argument = true := by
  obtain ⟨writable, spelling⟩ := target.target_spelling targetEnd
  have excluded := (checked.2 writable).2.2
  have noName : actualNameFree text (frame.actual otherSlot).first (frame.actual otherSlot).after
      (frame.actual targetSlot).target.first (frame.actual targetSlot).target.after = true := by
    apply Bool.of_not_eq_false
    intro present
    apply excluded (List.any_eq_true.mpr ⟨otherSlot, otherMember, ?_⟩)
    change (decide (targetSlot ≠ otherSlot) && !actualNameFree text (frame.actual otherSlot).first
        (frame.actual otherSlot).after (frame.actual targetSlot).target.first (frame.actual targetSlot).target.after) = true
    rw [Bool.and_eq_true]
    exact ⟨decide_eq_true different, congrArg Bool.not present⟩
  exact ((actualNameFree_sound noName).procedureActual (other.procedure_source otherEnd) otherStart (Nat.le_refl _)
    spelling (spelling.inNamespace scalarBound booleanBound)).1

private theorem FormalArgumentsAt.member_slot {text context input info frame slots arguments}
    (source : FormalArgumentsAt text context input info frame slots arguments) {argument} (member : argument ∈ arguments) :
    ∃ slot ∈ slots, ArgumentAt text context input (info.parameterAt slot) (frame.actual slot) argument := by
  induction source with
  | nil => simp at member
  | @cons slot slots first arguments head _ ih =>
    rcases List.mem_cons.mp member with same | later
    · exact ⟨slot, List.mem_cons_self .., same ▸ head⟩
    · obtain ⟨index, inside, reading⟩ := ih later
      exact ⟨index, List.mem_cons_of_mem _ inside, reading⟩

private theorem FormalArgumentsAt.pairwise {text context input info frame slots arguments}
    (source : FormalArgumentsAt text context input info frame slots arguments) (unique : slots.Nodup)
    (each : ∀ left ∈ slots, ∀ right ∈ slots, left ≠ right → ∀ a b,
      ArgumentAt text context input (info.parameterAt left) (frame.actual left) a →
      ArgumentAt text context input (info.parameterAt right) (frame.actual right) b → Actual.apart a b = true) :
    arguments.Pairwise (fun a b => Actual.apart a b = true) := by
  induction source with
  | nil => exact .nil
  | @cons slot slots first arguments head tail ih =>
    obtain ⟨fresh, distinct⟩ := List.nodup_cons.mp unique
    apply List.pairwise_cons.mpr
    constructor
    · intro argument member
      obtain ⟨index, inside, reading⟩ := tail.member_slot member
      exact each slot (List.mem_cons_self ..) index (List.mem_cons_of_mem _ inside) (fun same => fresh (same ▸ inside))
        first argument head reading
    · exact ih distinct (fun l left r right => each l (List.mem_cons_of_mem _ left) r (List.mem_cons_of_mem _ right))

/-- The native alias pass checked every other formal's own original source
span against each writable target. This proves the semantic pairwise test in
formal order, including calls that use named association. -/
theorem checked_arguments_apart {text : Source} {context : Predicate.Native.Context}
    {input info item afterName frame entries arguments result}
    (source : ActualListAt modelCalls text context.model input info item afterName frame entries)
    (semantic : FormalArgumentsAt text context input info frame (formalSlots item) arguments)
    (capacity : 0 < item.count → item.formalFirst + item.count - 1 ≤ PackageBindings.maxFormals)
    (aliases : checkAliases modelCalls text info item frame = some result)
    (scalarBound : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (booleanBound : context.booleanNames.length ≤ BooleanBindings.maxBindings) : actualsApart arguments = true := by
  have positions := source.slot_positions capacity
  have safe := checkAliases_safe aliases
  apply (actualsApart_pairwise _).mpr
  apply semantic.pairwise (by simpa only [formalSlots, ← List.range'_eq_map_range] using
    (List.nodup_range' (s := item.formalFirst) (n := item.count) 1))
  intro l left r right different a b one two
  cases a with
  | target object =>
    rw [target_apart_avoids]
    exact target_avoids_other one two (safe l left) (positions l left).2 (positions r right).1
      (positions r right).2 right different scalarBound booleanBound
  | value expression =>
    cases b with
    | value => rfl
    | target object =>
      apply actual_apart_symm
      rw [target_apart_avoids]
      exact target_avoids_other two one (safe r right) (positions r right).2 (positions l left).1
        (positions l left).2 left (Ne.symm different) scalarBound booleanBound

end Silver.ApplicationPackageCalls

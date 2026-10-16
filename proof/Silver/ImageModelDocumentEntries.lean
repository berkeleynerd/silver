module

public import Silver.ImageModelDocumentHeader

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- A successful entry includes its original surrounding whitespace. The
selected-theory check is retained at the actual closing bracket. -/
theorem theory_entry_run (tables : Native.Tables) (state : Core.State) (entry : JSON.TheoryEntry)
    (good : state.failed = false) (before : BeforeTheory state)
    (room : state.bytes + entry.bytes.length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (accepted : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false) :
    let ready := {state with bytes := state.bytes + entry.leading.length}
    let final := entry.span.bytes.foldl (consume (Core.modelHelpers tables)) ready
    entry.bytes.foldl (consume (Core.modelHelpers tables)) state = {final with bytes := final.bytes + entry.trailing.length} ∧
      final.failed = false ∧ AfterTheory final ∧ final.bytes = ready.bytes + entry.span.bytes.length ∧
      AfterTheory (entry.bytes.foldl (consume (Core.modelHelpers tables)) state) ∧
      (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).bytes = state.bytes + entry.bytes.length := by
  let ready := {state with bytes := state.bytes + entry.leading.length}
  let final := entry.span.bytes.foldl (consume (Core.modelHelpers tables)) ready
  have leading : entry.leading.foldl (consume (Core.modelHelpers tables)) state = ready :=
    consume_whitespace_run _ state entry.leading good
      (by simp only [JSON.TheoryEntry.bytes, List.length_append] at room; omega) before.mode entry.before
  have finalGood : final.failed = false := by
    have result := consume_prefix_good (Core.modelHelpers tables) state (entry.leading ++ entry.span.bytes) entry.trailing accepted
    simpa only [List.foldl_append, leading] using result
  obtain ⟨_, _, protocol, bytes, _⟩ := theory_span_run tables ready entry.span good before.mode before.pending before.depth before.phase
    (by change state.bytes + entry.leading.length + entry.span.bytes.length ≤ _
        simp only [JSON.TheoryEntry.bytes, List.length_append] at room; omega) depthRoom
  have run : entry.bytes.foldl (consume (Core.modelHelpers tables)) state = {final with bytes := final.bytes + entry.trailing.length} := by
    simp only [JSON.TheoryEntry.bytes, List.foldl_append, leading]
    exact consume_whitespace_run _ final entry.trailing finalGood
      (by rw [bytes]; change state.bytes + entry.leading.length + entry.span.bytes.length + entry.trailing.length ≤ _
          simp only [JSON.TheoryEntry.bytes, List.length_append] at room; omega) protocol.mode entry.after
  refine ⟨run, finalGood, protocol, bytes, ?_, ?_⟩
  · rw [run]
    exact ⟨protocol.mode, protocol.depth, protocol.phase, protocol.pending⟩
  · rw [run]
    change final.bytes + entry.trailing.length = _
    rw [bytes]
    simp only [JSON.TheoryEntry.bytes, List.length_append]
    change state.bytes + entry.leading.length + entry.span.bytes.length + entry.trailing.length = _
    omega

def theorySeparator (state : Core.State) : Core.State :=
  {counted state with phase := .nextTheory, previousArrayStart := false}

theorem theory_list_separator (tables : Native.Tables) (state : Core.State)
    (good : state.failed = false) (after : AfterTheory state) (room : state.bytes ≠ 9223372036854775807) :
    consume (Core.modelHelpers tables) state 44 = theorySeparator state := by
  rw [consume_between _ state 44 good room after.mode,
    structural_theory_separator _ (counted state) after.depth after.phase]
  rfl

theorem theorySeparator_before (state : Core.State) (after : AfterTheory state) :
    BeforeTheory (theorySeparator state) := ⟨after.mode, after.depth, after.pending, .inr rfl⟩

/-- A trace retains actual byte-fold states at every theory, including the
successful selected-schema check. It is derived from whole-list success below. -/
inductive EntriesTrace (tables : Native.Tables) : Core.State → List JSON.TheoryEntry → Core.State → Prop
  | empty (state) : EntriesTrace tables state [] state
  | single (state) (entry : JSON.TheoryEntry)
      (good : state.failed = false) (before : BeforeTheory state)
      (room : state.bytes + entry.bytes.length ≤ 9223372036854775807)
      (depthRoom : 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
      (accepted : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false) :
      EntriesTrace tables state [entry] (entry.bytes.foldl (consume (Core.modelHelpers tables)) state)
  | more (state) (entry : JSON.TheoryEntry) (entries : List JSON.TheoryEntry) (final)
      (nonempty : entries ≠ [])
      (good : state.failed = false) (before : BeforeTheory state)
      (room : state.bytes + entry.bytes.length ≤ 9223372036854775807)
      (depthRoom : 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
      (accepted : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false)
      (tail : EntriesTrace tables (theorySeparator (entry.bytes.foldl (consume (Core.modelHelpers tables)) state)) entries final) :
      EntriesTrace tables state (entry :: entries) final

theorem entries_trace (tables : Native.Tables) (entries : List JSON.TheoryEntry) :
    ∀ (state : Core.State), state.failed = false → BeforeTheory state →
      state.bytes + (JSON.entriesBytes entries).length ≤ 9223372036854775807 →
      (∀ entry ∈ entries, 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807) →
      ((JSON.entriesBytes entries).foldl (consume (Core.modelHelpers tables)) state).failed = false →
      EntriesTrace tables state entries ((JSON.entriesBytes entries).foldl (consume (Core.modelHelpers tables)) state) ∧
      ((JSON.entriesBytes entries).foldl (consume (Core.modelHelpers tables)) state).bytes = state.bytes + (JSON.entriesBytes entries).length ∧
      (entries ≠ [] → AfterTheory ((JSON.entriesBytes entries).foldl (consume (Core.modelHelpers tables)) state)) := by
  intro state good before room depthRoom accepted
  induction entries generalizing state with
  | nil => exact ⟨.empty state, by simp [JSON.entriesBytes], by simp⟩
  | cons entry entries ih =>
      cases entries with
      | nil =>
          have run := theory_entry_run tables state entry good before room (depthRoom entry (by simp)) accepted
          exact ⟨.single state entry good before room (depthRoom entry (by simp)) accepted, run.2.2.2.2.2, fun _ => run.2.2.2.2.1⟩
      | cons next rest =>
          have shape : JSON.entriesBytes (entry :: next :: rest) = entry.bytes ++ ([44] ++ JSON.entriesBytes (next :: rest)) := by
            simp only [JSON.entriesBytes, List.append_assoc]
          have headGood := consume_prefix_good (Core.modelHelpers tables) state entry.bytes ([44] ++ JSON.entriesBytes (next :: rest)) (by rw [← shape]; exact accepted)
          have headRoom : state.bytes + entry.bytes.length ≤ 9223372036854775807 := by
            rw [shape] at room; simp only [List.length_append, List.length_cons, List.length_nil] at room; omega
          have head := theory_entry_run tables state entry good before headRoom (depthRoom entry (by simp)) headGood
          let middle := entry.bytes.foldl (consume (Core.modelHelpers tables)) state
          have separator : consume (Core.modelHelpers tables) middle 44 = theorySeparator middle :=
            theory_list_separator tables middle headGood head.2.2.2.2.1
              (by have bytes := head.2.2.2.2.2; change middle.bytes = _ at bytes
                  rw [shape] at room; simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
          have fold : (JSON.entriesBytes (entry :: next :: rest)).foldl (consume (Core.modelHelpers tables)) state =
              (JSON.entriesBytes (next :: rest)).foldl (consume (Core.modelHelpers tables)) (theorySeparator middle) := by
            rw [shape, List.foldl_append, List.singleton_append, List.foldl_cons, separator]
          obtain ⟨trace, bytes, protocol⟩ := ih (theorySeparator middle) headGood (theorySeparator_before middle head.2.2.2.2.1)
            (by change middle.bytes + 1 + (JSON.entriesBytes (next :: rest)).length ≤ _
                have count := head.2.2.2.2.2; change middle.bytes = _ at count
                rw [shape] at room; simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
            (fun item member => depthRoom item (by simp [member])) (by rw [← fold]; exact accepted)
          rw [fold]
          refine ⟨.more state entry (next :: rest) _ (by simp) good before headRoom (depthRoom entry (by simp)) headGood trace, ?_, fun _ => protocol (by simp)⟩
          rw [bytes]
          change middle.bytes + 1 + (JSON.entriesBytes (next :: rest)).length = _
          have count := head.2.2.2.2.2; change middle.bytes = _ at count
          rw [count, shape]
          simp only [List.length_append, List.length_cons, List.length_nil]
          omega

end Silver.ImageModel.ScannerNative

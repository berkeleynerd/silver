module

public import Silver.ImageModelDocumentAllSelected

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem closed_theory_inactive (tables : Native.Tables) (state : Core.State) :
    (closedTheory tables state).matcher.inTheory = false := by
  simp only [closedTheory, Core.modelHelpers, Core.State.setTheory, TheoryNative.model]

theorem theory_entry_inactive (tables : Native.Tables) (state : Core.State) (entry : JSON.TheoryEntry)
    (ready : EntryReady tables state entry) :
    (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).matcher.inTheory = false := by
  obtain ⟨run, _, _, _, _, _⟩ := theory_entry_run tables state entry ready.good ready.before ready.room ready.depthRoom ready.accepted
  rw [run]
  change (entry.span.bytes.foldl (consume (Core.modelHelpers tables)) {state with bytes := state.bytes + entry.leading.length}).matcher.inTheory = false
  obtain ⟨spanRun, _, _, _, _⟩ := theory_span_run tables {state with bytes := state.bytes + entry.leading.length} entry.span
    ready.good ready.before.mode ready.before.pending ready.before.depth ready.before.phase
    (by have room := ready.room
        simp only [JSON.TheoryEntry.bytes, List.length_append] at room
        change state.bytes + entry.leading.length + entry.span.bytes.length ≤ _; omega) ready.depthRoom
  rw [spanRun, closed_theory_inactive]

theorem EntriesTrace.inactive {tables : Native.Tables} {state final : Core.State} {entries : List JSON.TheoryEntry}
    (trace : EntriesTrace tables state entries final) (nonempty : entries ≠ []) : final.matcher.inTheory = false := by
  induction trace with
  | empty => contradiction
  | single state entry good before room depthRoom accepted => exact theory_entry_inactive tables state entry ⟨good, before, room, depthRoom, accepted⟩
  | more initial entry tail final tailNonempty good before room depthRoom accepted trace ih => exact ih tailNonempty

theorem EntriesTrace.seen_preserved {tables : Native.Tables} {state final : Core.State} {entries : List JSON.TheoryEntry}
    (trace : EntriesTrace tables state entries final) (kind : Native.Theory) (seen : state.seen kind = true) : final.seen kind = true := by
  induction trace with
  | empty => exact seen
  | single state entry good before room depthRoom accepted =>
      rw [(theory_entry_effects tables state entry good before room depthRoom accepted).1 kind]
      split
      · rfl
      · exact seen
  | more state entry entries final _ good before room depthRoom accepted _ ih =>
      apply ih
      change (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).seen kind = true
      rw [(theory_entry_effects tables state entry good before room depthRoom accepted).1 kind]
      split
      · rfl
      · exact seen

theorem EntriesTrace.selected_seen {tables : Native.Tables} {state final : Core.State} {entries : List JSON.TheoryEntry}
    (trace : EntriesTrace tables state entries final) (kind : Native.Theory)
    (present : ∃ entry ∈ entries, selectedName entry.span.theory.name none = some kind) : final.seen kind = true := by
  induction trace with
  | empty => simp at present
  | single state entry good before room depthRoom accepted =>
      obtain ⟨chosen, member, name⟩ := present
      have same : chosen = entry := by simpa using member
      subst chosen
      rw [(theory_entry_effects tables state entry good before room depthRoom accepted).1 kind]
      simp only [name, ↓reduceIte]
  | more state entry entries final _ good before room depthRoom accepted tail ih =>
      obtain ⟨chosen, member, name⟩ := present
      rcases List.mem_cons.mp member with same | member
      · subst chosen
        apply tail.seen_preserved kind
        change (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).seen kind = true
        rw [(theory_entry_effects tables state entry good before room depthRoom accepted).1 kind]
        simp only [name, ↓reduceIte]
      · exact ih ⟨chosen, member, name⟩

theorem EntriesTrace.seen_exact {tables : Native.Tables} {state final : Core.State} {entries : List JSON.TheoryEntry}
    (trace : EntriesTrace tables state entries final) (kind : Native.Theory) (unseen : state.seen kind = false) :
    final.seen kind = true ↔ ∃ entry ∈ entries, selectedName entry.span.theory.name none = some kind := by
  constructor
  · intro seen
    obtain ⟨preceding, entry, following, atEntry, position, _, _, name⟩ := trace.seen_selected kind unseen seen
    exact ⟨entry, by rw [position]; simp, name⟩
  · exact trace.selected_seen kind

end Silver.ImageModel.ScannerNative

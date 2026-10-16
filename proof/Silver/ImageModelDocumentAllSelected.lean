module

public import Silver.ImageModelDocumentScan

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem EntriesTrace.seen_selected {tables : Native.Tables} {state final : Core.State} {entries : List JSON.TheoryEntry}
    (trace : EntriesTrace tables state entries final) (kind : Native.Theory)
    (unseen : state.seen kind = false) (seen : final.seen kind = true) :
    ∃ preceding entry following atEntry,
      entries = preceding ++ entry :: following ∧
      atEntry.bytes = state.bytes + (JSON.entryPrefix preceding).length ∧ EntryReady tables atEntry entry ∧
      selectedName entry.span.theory.name none = some kind := by
  induction trace with
  | empty state => rw [unseen] at seen; contradiction
  | single state entry good before room depthRoom accepted =>
      have effects := theory_entry_effects tables state entry good before room depthRoom accepted
      have selected : selectedName entry.span.theory.name none = some kind := by
        by_cases other : selectedName entry.span.theory.name none = some kind
        · exact other
        · have changed := effects.1 kind
          simp only [other, ↓reduceIte, unseen] at changed
          rw [changed] at seen
          contradiction
      exact ⟨[], entry, [], state, rfl, by simp [JSON.entryPrefix], ⟨good, before, room, depthRoom, accepted⟩, selected⟩
  | more state entry entries final nonempty good before room depthRoom accepted tail ih =>
      have effects := theory_entry_effects tables state entry good before room depthRoom accepted
      by_cases selected : selectedName entry.span.theory.name none = some kind
      · exact ⟨[], entry, entries, state, rfl, by simp [JSON.entryPrefix], ⟨good, before, room, depthRoom, accepted⟩, selected⟩
      · have headUnseen : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).seen kind = false := by
          simpa only [selected, ↓reduceIte, unseen] using effects.1 kind
        obtain ⟨preceding, chosen, following, atEntry, position, bytes, ready, chosenName⟩ := ih headUnseen seen
        refine ⟨entry :: preceding, chosen, following, atEntry, ?_, ?_, ready, chosenName⟩
        · rw [position]; rfl
        · have count := (theory_entry_run tables state entry good before room depthRoom accepted).2.2.2.2.2
          change atEntry.bytes = (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).bytes + 1 + (JSON.entryPrefix preceding).length at bytes
          rw [count] at bytes
          rw [JSON.entryPrefix_cons]
          simp only [List.length_append, List.length_cons, List.length_nil]
          omega

/-- A refining Finish requires every selected schema, not merely Image. -/
theorem finish_refine_seen (state : Core.State) (kind : Native.Theory)
    (refined : (FinishNative.model state.finishView).kind = .refine) : state.seen kind = true := by
  obtain ⟨_, image, ready⟩ := FinishNative.refine_ready state.finishView refined
  simp only [FinishNative.Test.eval, Bool.and_eq_true, Core.State.finishView] at ready
  cases kind with
  | integer => exact ready.1.1.1
  | string => exact ready.1.1.2
  | image => exact image

/-- Each of the three required selected theories is an actual accepted
original entry at its exact source position. This supplies the Integer and
String schema witnesses needed by the Image clone semantics. -/
theorem document_selected_entry (tables : Native.Tables) (document : JSON.DocumentSpan) (kind : Native.Theory)
    (room : document.bytes.length ≤ 9223372036854775807)
    (depthRoom : ∀ entry ∈ document.entries, 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (refined : (FinishNative.model (document.bytes.foldl (consume (Core.modelHelpers tables)) {}).finishView).kind = .refine) :
    ∃ preceding entry following atSpan,
      document.entries = preceding ++ entry :: following ∧
      atSpan.bytes = (document.header ++ JSON.entryPrefix preceding ++ entry.leading).length ∧
      SpanReady tables atSpan entry.span ∧ selectedName entry.span.theory.name none = some kind := by
  have nonempty : document.entries ≠ [] := by
    obtain ⟨preceding, entry, following, atSpan, position, _⟩ := document_image_entry tables document room depthRoom refined
    rw [position]
    simp
  let start := document.header.foldl (consume (Core.modelHelpers tables)) {}
  let middle := document.listBytes.foldl (consume (Core.modelHelpers tables)) start
  let final := document.bytes.foldl (consume (Core.modelHelpers tables)) {}
  have finalSeen := finish_refine_seen final kind refined
  have finalGood : final.failed = false := by
    have valid := (FinishNative.refine_ready final.finishView refined).1
    cases failed : final.failed with
    | false => rfl
    | true => simp [FinishNative.Test.eval, Core.State.finishView, failed] at valid
  have bound : document.header.length + document.listBytes.length + document.footer.length ≤ 9223372036854775807 := by
    rw [document.bytes_split] at room
    simpa only [List.length_append] using room
  obtain ⟨headerGood, headerBefore, headerBytes, headerSeen, _⟩ := document_header tables document (by omega)
  change start.failed = false at headerGood
  change BeforeTheory start at headerBefore
  change start.bytes = document.header.length at headerBytes
  change ∀ selected, start.seen selected = false at headerSeen
  have full : final = document.footer.foldl (consume (Core.modelHelpers tables)) middle := by
    simp only [final, document.bytes_split, List.foldl_append, middle, start]
  have middleGood : middle.failed = false := by
    have prefixGood := consume_prefix_good (Core.modelHelpers tables) {} (document.header ++ document.listBytes) document.footer
      (by rw [← document.bytes_split]; exact finalGood)
    simpa only [List.foldl_append] using prefixGood
  have listShape : document.listBytes = JSON.entriesBytes document.entries := by simp [JSON.DocumentSpan.listBytes, nonempty]
  obtain ⟨trace, middleBytes, after⟩ := entries_trace tables document.entries start headerGood headerBefore
    (by rw [headerBytes, ← listShape]; omega) depthRoom (by rw [← listShape]; exact middleGood)
  rw [← listShape] at trace middleBytes after
  change EntriesTrace tables start document.entries middle at trace
  change middle.bytes = start.bytes + document.listBytes.length at middleBytes
  have protocol : AfterTheory middle := after nonempty
  have footer := document_footer tables middle document middleGood protocol.mode protocol.depth protocol.pending (.inr protocol.phase)
    (by rw [middleBytes, headerBytes]; exact bound)
  have sameSeen : final.seen = middle.seen := by rw [full]; exact footer.2.2.2.2.2.2.1
  have seen : middle.seen kind = true := by rw [sameSeen] at finalSeen; exact finalSeen
  obtain ⟨preceding, entry, following, atEntry, position, bytes, ready, name⟩ := trace.seen_selected kind (headerSeen kind) seen
  let atSpan := {atEntry with bytes := atEntry.bytes + entry.leading.length}
  have entryRun := theory_entry_run tables atEntry entry ready.good ready.before ready.room ready.depthRoom ready.accepted
  refine ⟨preceding, entry, following, atSpan, position, ?_, ?_, name⟩
  · change atEntry.bytes + entry.leading.length = _
    rw [bytes, headerBytes]
    simp only [List.length_append]
  · exact ⟨ready.good, ⟨ready.before.mode, ready.before.depth, ready.before.pending, ready.before.phase⟩,
      by change atEntry.bytes + entry.leading.length + entry.span.bytes.length ≤ _
         have room := ready.room
         simp only [JSON.TheoryEntry.bytes, List.length_append] at room
         omega,
      ready.depthRoom, entryRun.2.1⟩

end Silver.ImageModel.ScannerNative

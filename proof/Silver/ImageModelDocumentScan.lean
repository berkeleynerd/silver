module

public import Silver.ImageModelDocumentSelection
public import Silver.ImageModelDocumentFooter

@[expose] public section
namespace Silver.ImageModel.ScannerNative

structure SpanReady (tables : Native.Tables) (state : Core.State) (span : JSON.TheorySpan) : Prop where
  good : state.failed = false
  before : BeforeTheory state
  room : state.bytes + span.bytes.length ≤ 9223372036854775807
  depthRoom : 3 + (JSON.fieldsBytes span.spans).length ≤ 9223372036854775807
  accepted : (span.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false

/-- Actual initialized whole-document scanning and Finish select an original
Image entry. The returned plan offsets are that entry's computed original
field positions; neither acceptance nor offsets are supplied for the entry. -/
theorem document_image_entry (tables : Native.Tables) (document : JSON.DocumentSpan)
    (room : document.bytes.length ≤ 9223372036854775807)
    (depthRoom : ∀ entry ∈ document.entries, 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (refined : (FinishNative.model (document.bytes.foldl (consume (Core.modelHelpers tables)) {}).finishView).kind = .refine) :
    ∃ preceding entry following atSpan,
      document.entries = preceding ++ entry :: following ∧
      atSpan.bytes = (document.header ++ JSON.entryPrefix preceding ++ entry.leading).length ∧
      SpanReady tables atSpan entry.span ∧ selectedName entry.span.theory.name none = some .image ∧
      (FinishNative.model (document.bytes.foldl (consume (Core.modelHelpers tables)) {}).finishView).declarations =
        (fieldsScope (scope (openedTheory tables atSpan)) (atSpan.bytes + 1) entry.span.spans).candidateDeclarations ∧
      (FinishNative.model (document.bytes.foldl (consume (Core.modelHelpers tables)) {}).finishView).includes =
        (fieldsScope (scope (openedTheory tables atSpan)) (atSpan.bytes + 1) entry.span.spans).candidateIncludes := by
  let start := document.header.foldl (consume (Core.modelHelpers tables)) {}
  let middle := document.listBytes.foldl (consume (Core.modelHelpers tables)) start
  let final := document.bytes.foldl (consume (Core.modelHelpers tables)) {}
  obtain ⟨valid, finalSeen, _⟩ := FinishNative.refine_ready final.finishView refined
  have finalGood : final.failed = false := by
    cases failed : final.failed with
    | false => rfl
    | true => simp [FinishNative.Test.eval, Core.State.finishView, failed] at valid
  have bound : document.header.length + document.listBytes.length + document.footer.length ≤ 9223372036854775807 := by
    rw [document.bytes_split] at room
    simpa only [List.length_append] using room
  obtain ⟨headerGood, headerBefore, headerBytes, headerSeen, _, _, headerPhase, _⟩ := document_header tables document (by omega)
  change start.failed = false at headerGood
  change BeforeTheory start at headerBefore
  change start.bytes = document.header.length at headerBytes
  change ∀ kind, start.seen kind = false at headerSeen
  change start.phase = .firstTheory at headerPhase
  have full : final = document.footer.foldl (consume (Core.modelHelpers tables)) middle := by
    simp only [final, document.bytes_split, List.foldl_append, middle, start]
  have middleGood : middle.failed = false := by
    have prefixGood := consume_prefix_good (Core.modelHelpers tables) {} (document.header ++ document.listBytes) document.footer
      (by rw [← document.bytes_split]; exact finalGood)
    simpa only [List.foldl_append] using prefixGood
  obtain ⟨planDeclarations, planIncludes, _⟩ := FinishNative.refine_offsets final.finishView refined
  by_cases empty : document.entries = []
  · have listRun : middle = {start with bytes := start.bytes + document.emptyList.length} := by
      change document.listBytes.foldl (consume (Core.modelHelpers tables)) start = _
      simp only [JSON.DocumentSpan.listBytes, empty, ↓reduceIte]
      exact consume_whitespace_run _ start document.emptyList headerGood
        (by have listLength : document.listBytes.length = document.emptyList.length := by simp [JSON.DocumentSpan.listBytes, empty]
            rw [headerBytes]; omega) headerBefore.mode document.emptyListSpace
    have footer := document_footer tables middle document middleGood
      (by rw [listRun]; exact headerBefore.mode) (by rw [listRun]; exact headerBefore.depth)
      (by rw [listRun]; exact headerBefore.pending) (.inl (by rw [listRun]; exact headerPhase))
      (by rw [listRun]; change start.bytes + document.emptyList.length + document.footer.length ≤ _
          rw [headerBytes]
          simpa only [JSON.DocumentSpan.listBytes, empty, ↓reduceIte] using bound)
    have sameSeen : final.seen = start.seen := by
      rw [full, footer.2.2.2.2.2.2.1, listRun]
    change final.seen .image = true at finalSeen
    rw [sameSeen, headerSeen .image] at finalSeen
    contradiction
  · have listShape : document.listBytes = JSON.entriesBytes document.entries := by simp [JSON.DocumentSpan.listBytes, empty]
    obtain ⟨trace, middleBytes, after⟩ := entries_trace tables document.entries start headerGood headerBefore
      (by rw [headerBytes, ← listShape]; omega) depthRoom (by rw [← listShape]; exact middleGood)
    rw [← listShape] at trace middleBytes after
    change EntriesTrace tables start document.entries middle at trace
    change middle.bytes = start.bytes + document.listBytes.length at middleBytes
    have protocol : AfterTheory middle := after empty
    have footer := document_footer tables middle document middleGood protocol.mode protocol.depth protocol.pending (.inr protocol.phase)
      (by rw [middleBytes, headerBytes]; exact bound)
    have sameSeen : final.seen = middle.seen := by rw [full]; exact footer.2.2.2.2.2.2.1
    have sameDeclarations : final.declarations = middle.declarations := by rw [full]; exact footer.2.2.2.2.2.2.2.1
    have sameIncludes : final.includes = middle.includes := by rw [full]; exact footer.2.2.2.2.2.2.2.2.1
    have seen : middle.seen .image = true := by change final.seen .image = true at finalSeen; rw [sameSeen] at finalSeen; exact finalSeen
    obtain ⟨preceding, entry, following, atEntry, position, bytes, ready, name, declarations, includes⟩ :=
      trace.image_selected (headerSeen .image) seen
    let atSpan := {atEntry with bytes := atEntry.bytes + entry.leading.length}
    have entryRun := theory_entry_run tables atEntry entry ready.good ready.before ready.room ready.depthRoom ready.accepted
    refine ⟨preceding, entry, following, atSpan, position, ?_, ?_, name, ?_, ?_⟩
    · change atEntry.bytes + entry.leading.length = _
      rw [bytes, headerBytes]
      simp only [List.length_append]
    · exact ⟨ready.good, ⟨ready.before.mode, ready.before.depth, ready.before.pending, ready.before.phase⟩,
        by change atEntry.bytes + entry.leading.length + entry.span.bytes.length ≤ _
           have room := ready.room
           simp only [JSON.TheoryEntry.bytes, List.length_append] at room
           omega,
        ready.depthRoom, entryRun.2.1⟩
    · exact planDeclarations.trans (sameDeclarations.trans declarations)
    · exact planIncludes.trans (sameIncludes.trans includes)

end Silver.ImageModel.ScannerNative

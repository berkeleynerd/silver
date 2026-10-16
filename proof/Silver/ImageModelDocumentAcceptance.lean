module

public import Silver.ImageModelTheoryAcceptance
public import Silver.ImageModelDocumentTraceProperties

@[expose] public section
namespace Silver.ImageModel.ScannerNative

def SelectedSchema (tables : Native.Tables) (span : JSON.TheorySpan) : Prop :=
  ∀ kind, selectedName span.theory.name none = some kind →
    JSON.Valid span.theory.value.eraseNodeIds ∧
    span.theory.value.eraseNodeIds.encode.length = tables.length kind ∧
    ∀ index, (bound : index < span.theory.value.eraseNodeIds.encode.length) →
      span.theory.value.eraseNodeIds.encode[index] = tables.byte kind (index + 1)

def SelectedDistinct (entries : List JSON.TheoryEntry) : Prop :=
  entries.Pairwise (fun left right => ∀ kind,
    selectedName left.span.theory.name none = some kind → selectedName right.span.theory.name none ≠ some kind)

theorem theory_entry_accepts (tables : Native.Tables) (state : Core.State) (entry : JSON.TheoryEntry)
    (good : state.failed = false) (before : BeforeTheory state)
    (room : state.bytes + entry.bytes.length ≤ 9223372036854775807)
    (depthRoom : 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (fresh : ∀ kind, selectedName entry.span.theory.name none = some kind → state.seen kind = false)
    (selected : SelectedSchema tables entry.span) :
    (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false := by
  let ready := {state with bytes := state.bytes + entry.leading.length}
  let final := entry.span.bytes.foldl (consume (Core.modelHelpers tables)) ready
  have spanRoom : ready.bytes + entry.span.bytes.length ≤ 9223372036854775807 := by
    simp only [JSON.TheoryEntry.bytes, List.length_append] at room
    change state.bytes + entry.leading.length + entry.span.bytes.length ≤ _; omega
  have finalGood : final.failed = false := theory_span_accepts tables ready entry.span good
    ⟨before.mode, before.depth, before.pending, before.phase⟩ spanRoom depthRoom fresh selected
  obtain ⟨_, _, protocol, bytes, _⟩ := theory_span_run tables ready entry.span good before.mode before.pending before.depth before.phase spanRoom depthRoom
  have leading : entry.leading.foldl (consume (Core.modelHelpers tables)) state = ready :=
    consume_whitespace_run _ state entry.leading good
      (by simp only [JSON.TheoryEntry.bytes, List.length_append] at room; omega) before.mode entry.before
  have trailing : entry.trailing.foldl (consume (Core.modelHelpers tables)) final = {final with bytes := final.bytes + entry.trailing.length} :=
    consume_whitespace_run _ final entry.trailing finalGood
      (by rw [bytes]; change state.bytes + entry.leading.length + entry.span.bytes.length + entry.trailing.length ≤ _
          simp only [JSON.TheoryEntry.bytes, List.length_append] at room; omega) protocol.mode entry.after
  simp only [JSON.TheoryEntry.bytes, List.foldl_append, leading]
  change (entry.trailing.foldl (consume (Core.modelHelpers tables)) final).failed = false
  rw [trailing]
  exact finalGood

/-- Ordered producer entries are accepted from their independent syntax,
selected schemas and uniqueness; no successful scan is an input. -/
theorem entries_accept (tables : Native.Tables) (entries : List JSON.TheoryEntry)
    (unique : SelectedDistinct entries) (schema : ∀ entry ∈ entries, SelectedSchema tables entry.span)
    (depthRoom : ∀ entry ∈ entries, 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807) :
    ∀ (state : Core.State), state.failed = false → BeforeTheory state →
      state.bytes + (JSON.entriesBytes entries).length ≤ 9223372036854775807 →
      (∀ entry ∈ entries, ∀ kind, selectedName entry.span.theory.name none = some kind → state.seen kind = false) →
      ((JSON.entriesBytes entries).foldl (consume (Core.modelHelpers tables)) state).failed = false := by
  intro state good before room fresh
  induction entries generalizing state with
  | nil => exact good
  | cons entry entries ih =>
      have distinct := List.pairwise_cons.mp unique
      cases entries with
      | nil =>
          exact theory_entry_accepts tables state entry good before room (depthRoom entry (by simp))
            (fresh entry (by simp)) (schema entry (by simp))
      | cons next rest =>
          have shape : JSON.entriesBytes (entry :: next :: rest) = entry.bytes ++ ([44] ++ JSON.entriesBytes (next :: rest)) := by
            simp only [JSON.entriesBytes, List.append_assoc]
          have headRoom : state.bytes + entry.bytes.length ≤ 9223372036854775807 := by
            rw [shape] at room
            simp only [List.length_append, List.length_cons, List.length_nil] at room
            omega
          have headGood := theory_entry_accepts tables state entry good before headRoom (depthRoom entry (by simp))
            (fresh entry (by simp)) (schema entry (by simp))
          have head := theory_entry_run tables state entry good before headRoom (depthRoom entry (by simp)) headGood
          have effects := theory_entry_effects tables state entry good before headRoom (depthRoom entry (by simp)) headGood
          let middle := entry.bytes.foldl (consume (Core.modelHelpers tables)) state
          have separator : consume (Core.modelHelpers tables) middle 44 = theorySeparator middle :=
            theory_list_separator tables middle headGood head.2.2.2.2.1
              (by have bytes := head.2.2.2.2.2; change middle.bytes = _ at bytes
                  rw [shape] at room; simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
          rw [shape, List.foldl_append, List.singleton_append, List.foldl_cons, separator]
          apply ih distinct.2 (fun item member => schema item (by simp [member]))
            (fun item member => depthRoom item (by simp [member])) (theorySeparator middle) headGood
            (theorySeparator_before middle head.2.2.2.2.1)
          · change middle.bytes + 1 + (JSON.entriesBytes (next :: rest)).length ≤ _
            have count := head.2.2.2.2.2; change middle.bytes = _ at count
            rw [shape] at room; simp only [List.length_append, List.length_cons, List.length_nil] at room
            omega
          · intro later member kind named
            have notHead : selectedName entry.span.theory.name none ≠ some kind := by
              intro headName
              exact distinct.1 later member kind headName named
            change middle.seen kind = false
            rw [effects.1 kind]
            simp only [notHead, ↓reduceIte]
            exact fresh later (by simp [member]) kind named

structure DocumentAccepted (document : JSON.DocumentSpan) (state : Core.State) : Prop where
  good : state.failed = false
  mode : state.mode = .between
  depth : state.depth = 0
  phase : state.phase = .afterRoot
  pending : state.nodeIdPending = false
  inactive : state.matcher.inTheory = false
  bytes : state.bytes = document.bytes.length
  selected : ∀ kind, state.seen kind = true ↔ ∃ entry ∈ document.entries, selectedName entry.span.theory.name none = some kind

/-- The actual initialized scanner completes the whole original document under
independent producer syntax, exact selected schemas and selected-name uniqueness. -/
theorem document_accepts (tables : Native.Tables) (document : JSON.DocumentSpan)
    (room : document.bytes.length ≤ 9223372036854775807)
    (depthRoom : ∀ entry ∈ document.entries, 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (unique : SelectedDistinct document.entries)
    (schema : ∀ entry ∈ document.entries, SelectedSchema tables entry.span) :
    DocumentAccepted document (document.bytes.foldl (consume (Core.modelHelpers tables)) {}) := by
  let start := document.header.foldl (consume (Core.modelHelpers tables)) {}
  let middle := document.listBytes.foldl (consume (Core.modelHelpers tables)) start
  let final := document.bytes.foldl (consume (Core.modelHelpers tables)) {}
  have length : document.bytes.length = document.header.length + document.listBytes.length + document.footer.length := by
    rw [document.bytes_split]; simp only [List.length_append]
  have bound : document.header.length + document.listBytes.length + document.footer.length ≤ 9223372036854775807 := by omega
  obtain ⟨headerGood, headerBefore, headerBytes, headerSeen, _, _, headerPhase, headerInactive⟩ := document_header tables document (by omega)
  change start.failed = false at headerGood
  change BeforeTheory start at headerBefore
  change start.bytes = document.header.length at headerBytes
  change ∀ kind, start.seen kind = false at headerSeen
  change start.phase = .firstTheory at headerPhase
  change start.matcher.inTheory = false at headerInactive
  have full : final = document.footer.foldl (consume (Core.modelHelpers tables)) middle := by
    simp only [final, document.bytes_split, List.foldl_append, middle, start]
  have middleProperties : middle.failed = false ∧ middle.mode = .between ∧ middle.depth = 2 ∧
      middle.nodeIdPending = false ∧ (middle.phase = .firstTheory ∨ middle.phase = .theorySeparator) ∧
      middle.matcher.inTheory = false ∧ middle.bytes = start.bytes + document.listBytes.length ∧
      (∀ kind, middle.seen kind = true ↔ ∃ entry ∈ document.entries, selectedName entry.span.theory.name none = some kind) := by
    by_cases empty : document.entries = []
    · have listShape : document.listBytes = document.emptyList := by simp [JSON.DocumentSpan.listBytes, empty]
      have run : middle = {start with bytes := start.bytes + document.emptyList.length} := by
        change document.listBytes.foldl (consume (Core.modelHelpers tables)) start = _
        rw [listShape]
        exact consume_whitespace_run _ start document.emptyList headerGood
          (by rw [headerBytes]; rw [listShape] at bound; omega) headerBefore.mode document.emptyListSpace
      rw [run]
      refine ⟨headerGood, headerBefore.mode, headerBefore.depth, headerBefore.pending, .inl headerPhase, headerInactive, ?_, ?_⟩
      · rw [listShape]
      · intro kind
        change start.seen kind = true ↔ _
        simp only [headerSeen kind, empty, Bool.false_eq_true, List.not_mem_nil, false_and, exists_false]
    · have listShape : document.listBytes = JSON.entriesBytes document.entries := by simp [JSON.DocumentSpan.listBytes, empty]
      have listRoom : start.bytes + (JSON.entriesBytes document.entries).length ≤ 9223372036854775807 := by
        rw [headerBytes, ← listShape]; omega
      have accepted := entries_accept tables document.entries unique schema depthRoom start headerGood headerBefore listRoom
        (fun _ _ kind _ => headerSeen kind)
      obtain ⟨trace, count, after⟩ := entries_trace tables document.entries start headerGood headerBefore listRoom depthRoom accepted
      rw [← listShape] at accepted trace count after
      change middle.failed = false at accepted
      change EntriesTrace tables start document.entries middle at trace
      have protocol : AfterTheory middle := after empty
      exact ⟨accepted, protocol.mode, protocol.depth, protocol.pending, .inr protocol.phase, trace.inactive empty, count,
        fun kind => trace.seen_exact kind (headerSeen kind)⟩
  obtain ⟨middleGood, middleMode, middleDepth, middlePending, middlePhase, middleInactive, middleBytes, middleSeen⟩ := middleProperties
  obtain ⟨good, mode, depth, phase, pending, matcher, seen, declarations, includes, bytes⟩ :=
    document_footer tables middle document middleGood middleMode middleDepth middlePending middlePhase
      (by rw [middleBytes, headerBytes]; exact bound)
  change DocumentAccepted document final
  rw [full]
  refine ⟨good, mode, depth, phase, pending, ?_, ?_, ?_⟩
  · rw [matcher]; exact middleInactive
  · rw [bytes, middleBytes, headerBytes, length]
  · intro kind; rw [seen]; exact middleSeen kind

end Silver.ImageModel.ScannerNative

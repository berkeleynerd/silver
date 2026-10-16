module

public import Silver.ImageModelDocumentEffects

@[expose] public section
namespace Silver.ImageModel.JSON

theorem entryPrefix_cons (entry : TheoryEntry) (entries : List TheoryEntry) :
    entryPrefix (entry :: entries) = entry.bytes ++ [44] ++ entryPrefix entries := by
  cases entries <;> simp [entryPrefix, entriesBytes, List.append_assoc]

end Silver.ImageModel.JSON

namespace Silver.ImageModel.ScannerNative

structure EntryReady (tables : Native.Tables) (state : Core.State) (entry : JSON.TheoryEntry) : Prop where
  good : state.failed = false
  before : BeforeTheory state
  room : state.bytes + entry.bytes.length ≤ 9223372036854775807
  depthRoom : 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807
  accepted : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).failed = false

theorem EntriesTrace.image_preserved {tables : Native.Tables} {state final : Core.State} {entries : List JSON.TheoryEntry}
    (trace : EntriesTrace tables state entries final) (seen : state.seen .image = true) :
    final.seen .image = true ∧ final.declarations = state.declarations ∧ final.includes = state.includes := by
  induction trace with
  | empty state => exact ⟨seen, rfl, rfl⟩
  | single state entry good before room depthRoom accepted =>
      have effects := theory_entry_effects tables state entry good before room depthRoom accepted
      have notImage : selectedName entry.span.theory.name none ≠ some .image := by
        intro selected
        have unseen := effects.2.2.2 .image selected
        rw [seen] at unseen
        contradiction
      exact ⟨by simpa only [notImage, ↓reduceIte, seen] using effects.1 .image,
        by simpa only [notImage, ↓reduceIte] using effects.2.1,
        by simpa only [notImage, ↓reduceIte] using effects.2.2.1⟩
  | more state entry entries final nonempty good before room depthRoom accepted tail ih =>
      have effects := theory_entry_effects tables state entry good before room depthRoom accepted
      have notImage : selectedName entry.span.theory.name none ≠ some .image := by
        intro selected
        have unseen := effects.2.2.2 .image selected
        rw [seen] at unseen
        contradiction
      have headSeen : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).seen .image = true := by
        simpa only [notImage, ↓reduceIte, seen] using effects.1 .image
      have headDeclarations : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).declarations = state.declarations := by
        simpa only [notImage, ↓reduceIte] using effects.2.1
      have headIncludes : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).includes = state.includes := by
        simpa only [notImage, ↓reduceIte] using effects.2.2.1
      obtain ⟨finalSeen, declarations, includes⟩ := ih headSeen
      exact ⟨finalSeen, declarations.trans headDeclarations, includes.trans headIncludes⟩

/-- A seen Image in the final successful list comes from an actual accepted
entry. Later successful entries cannot overwrite its original offsets. -/
theorem EntriesTrace.image_selected {tables : Native.Tables} {state final : Core.State} {entries : List JSON.TheoryEntry}
    (trace : EntriesTrace tables state entries final) (unseen : state.seen .image = false) (seen : final.seen .image = true) :
    ∃ preceding entry following atEntry,
      entries = preceding ++ entry :: following ∧
      atEntry.bytes = state.bytes + (JSON.entryPrefix preceding).length ∧ EntryReady tables atEntry entry ∧
      selectedName entry.span.theory.name none = some .image ∧
      final.declarations = (entryScope tables atEntry entry).candidateDeclarations ∧
      final.includes = (entryScope tables atEntry entry).candidateIncludes := by
  induction trace with
  | empty state => rw [unseen] at seen; contradiction
  | single state entry good before room depthRoom accepted =>
      have effects := theory_entry_effects tables state entry good before room depthRoom accepted
      have selected : selectedName entry.span.theory.name none = some .image := by
        by_cases other : selectedName entry.span.theory.name none = some .image
        · exact other
        · have changed := effects.1 .image
          simp only [other, ↓reduceIte, unseen] at changed
          rw [changed] at seen
          contradiction
      refine ⟨[], entry, [], state, rfl, by simp [JSON.entryPrefix], ⟨good, before, room, depthRoom, accepted⟩, selected, ?_, ?_⟩
      · simpa only [selected, ↓reduceIte] using effects.2.1
      · simpa only [selected, ↓reduceIte] using effects.2.2.1
  | more state entry entries final nonempty good before room depthRoom accepted tail ih =>
      have effects := theory_entry_effects tables state entry good before room depthRoom accepted
      by_cases selected : selectedName entry.span.theory.name none = some .image
      · have headSeen : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).seen .image = true := by
          simpa only [selected, ↓reduceIte] using effects.1 .image
        obtain ⟨_, declarations, includes⟩ := tail.image_preserved headSeen
        refine ⟨[], entry, entries, state, rfl, by simp [JSON.entryPrefix], ⟨good, before, room, depthRoom, accepted⟩, selected, ?_, ?_⟩
        · exact declarations.trans (by simpa only [selected, ↓reduceIte, theorySeparator, counted] using effects.2.1)
        · exact includes.trans (by simpa only [selected, ↓reduceIte, theorySeparator, counted] using effects.2.2.1)
      · have headUnseen : (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).seen .image = false := by
          simpa only [selected, ↓reduceIte, unseen] using effects.1 .image
        obtain ⟨preceding, chosen, following, atEntry, position, bytes, ready, chosenName, declarations, includes⟩ := ih headUnseen seen
        refine ⟨entry :: preceding, chosen, following, atEntry, ?_, ?_, ready, chosenName, declarations, includes⟩
        · rw [position]; rfl
        · have count := (theory_entry_run tables state entry good before room depthRoom accepted).2.2.2.2.2
          change atEntry.bytes = (entry.bytes.foldl (consume (Core.modelHelpers tables)) state).bytes + 1 + (JSON.entryPrefix preceding).length at bytes
          rw [count] at bytes
          rw [JSON.entryPrefix_cons]
          simp only [List.length_append, List.length_cons, List.length_nil]
          omega

end Silver.ImageModel.ScannerNative

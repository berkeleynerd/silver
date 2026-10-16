module

public import Silver.ImageModelDocumentAllSelected
public import Silver.ImageModelDocumentSplice
public import Silver.ImageModelTheoryRefinement
public import Silver.ImageModelSelectedTemplate
public import Silver.ImageModelSelectedMeaning
public import Silver.ImageModelCloneMeaning

@[expose] public section
namespace Silver.ImageModel

def scanPlan (tables : Native.Tables) (document : JSON.DocumentSpan) : FinishNative.Plan :=
  FinishNative.model (document.bytes.foldl (ScannerNative.consume (Core.modelHelpers tables)) {}).finishView

/-- Every required schema is identified in the actual original document. -/
def SelectedSchemas (document : JSON.DocumentSpan) : Prop :=
  ∀ kind : Native.Theory, ∃ entry ∈ document.entries,
    ScannerNative.selectedName entry.span.theory.name none = some kind ∧
    entry.span.theory.value.eraseNodeIds.meaning = (Templates.theoryValue kind).meaning

/-- The transformed document differs at one selected Image occurrence by
exactly one appended clone and one include. All other entries and context bytes
are preserved, including non-ASCII strings in unselected theories. -/
def RefinedDocument (document : JSON.DocumentSpan) (output : List Nat) : Prop :=
  SelectedSchemas document ∧
  ∃ preceding entry following core,
    document.entries = preceding ++ entry :: following ∧
    ScannerNative.selectedName entry.span.theory.name none = some .image ∧
    output = document.leading ++ core ++ document.trailing ∧
    JSON.CodeUnitSpelling
      (.object [(JSON.ascii "theory_declarations", .array
        (preceding.map JSON.TheoryEntry.value ++
          (entry.span.theory.appendNodes Clone.declaration Clone.includeDeclaration).value ::
          following.map JSON.TheoryEntry.value))]) core

section SourceSchemas
variable (calls : Templates.Calls) (source : Templates.InterpretedSource calls)
    (document : JSON.DocumentSpan)
    (room : document.bytes.length ≤ 9223372036854775807)
    (depthRoom : ∀ entry ∈ document.entries, 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (refined : (scanPlan calls.tables document).kind = .refine)
    (parse : List Nat → Option JSON.Meaning) (sound : JSON.ParserSound parse)
    (parsed : ∀ kind, parse (Templates.theoryValue kind).encode = some (Templates.theoryValue kind).meaning)

include source room depthRoom refined sound parsed

theorem selected_schemas : SelectedSchemas document := by
  intro kind
  obtain ⟨preceding, entry, following, state, position, _, ready, selected⟩ :=
    ScannerNative.document_selected_entry calls.tables document kind room depthRoom refined
  obtain ⟨normal, _, matched⟩ := Templates.accepted_selected_schema calls source state entry.span kind
    ready.good ready.before.mode ready.before.pending ready.before.depth ready.before.phase
    ready.room ready.depthRoom selected ready.accepted
  refine ⟨entry, ?_, selected, Templates.selected_meaning entry.span kind normal matched parse sound (parsed kind)⟩
  rw [position]
  simp

/-- Actual initialized acceptance, interpreted native template bytes and the
partial external parser boundary determine the entire refined document. The
offsets are derived from the consumed original spans, never supplied as a
splicing premise. -/
theorem refined_document
    (cloneSyntax : JSON.AsciiSpelling Clone.declaration Clone.declaration.encode)
    (includeSyntax : JSON.AsciiSpelling Clone.includeDeclaration Clone.includeDeclaration.encode) :
    let plan := scanPlan calls.tables document
    let output := splice document.bytes Clone.declarationsFragment Clone.includesFragment plan.declarations plan.includes
    RefinedDocument document output ∧
      eraseInsertions output plan.declarations plan.includes
        Clone.declarationsFragment.length Clone.includesFragment.length = document.bytes := by
  dsimp only
  obtain ⟨preceding, entry, following, state, position, prefixLength, ready, selected, declOffset, incOffset⟩ :=
    ScannerNative.document_image_entry calls.tables document room depthRoom refined
  obtain ⟨normal, _, matched⟩ := Templates.accepted_selected_schema calls source state entry.span .image
    ready.good ready.before.mode ready.before.pending ready.before.depth ready.before.phase
    ready.room ready.depthRoom selected ready.accepted
  obtain ⟨_, declarations, includes, decls, incs, _, _, declNonempty, incNonempty⟩ :=
    Templates.selected_schema_meaning entry.span .image normal matched parse sound (parsed .image)
  obtain ⟨a, b, da, ib, ordered, bounded, spelling⟩ :=
    entry.span.refined_spelling calls.tables state normal declarations includes decls incs declNonempty incNonempty
      Clone.declaration Clone.includeDeclaration _ _ cloneSyntax includeSyntax
  have declarationCut : (scanPlan calls.tables document).declarations =
      (document.header ++ JSON.entryPrefix preceding ++ entry.leading).length + a :=
    declOffset.trans (by rw [da, prefixLength])
  have includeCut : (scanPlan calls.tables document).includes =
      (document.header ++ JSON.entryPrefix preceding ++ entry.leading).length + b :=
    incOffset.trans (by rw [ib, prefixLength])
  obtain ⟨core, output, syntaxProof⟩ := document.spliced_entry_spelling preceding entry following position
    Clone.declarationsFragment Clone.includesFragment a b (by omega) (by omega)
    (entry.span.theory.appendNodes Clone.declaration Clone.includeDeclaration).value
    (JSON.AsciiSpelling.codeUnit _ _ spelling)
  have outputShape : splice document.bytes Clone.declarationsFragment Clone.includesFragment
      (scanPlan calls.tables document).declarations (scanPlan calls.tables document).includes =
      document.leading ++ core ++ document.trailing := by
    rw [declarationCut, includeCut]
    exact output
  refine ⟨⟨selected_schemas calls source document room depthRoom refined parse sound parsed,
    preceding, entry, following, core, position, selected, outputShape, syntaxProof⟩, ?_⟩
  apply erase_splice
  · rw [declarationCut, includeCut]; omega
  · rw [includeCut, document.split_entry preceding entry following position]
    simp only [List.length_append]
    omega

end SourceSchemas
end Silver.ImageModel

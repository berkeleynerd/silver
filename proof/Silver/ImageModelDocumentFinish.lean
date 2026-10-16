module

public import Silver.ImageModelDocumentAcceptance
public import Silver.ImageModelTheoryCuts

@[expose] public section
namespace Silver.ImageModel.ScannerNative

def SelectedPresent (entries : List JSON.TheoryEntry) (kind : Native.Theory) : Prop :=
  ∃ entry ∈ entries, selectedName entry.span.theory.name none = some kind

/-- Independent producer facts required by the native refinement scanner.
The pinned-producer review discharges this boundary; no scanner acceptance,
matching liveness or Finish result occurs in these assumptions. -/
structure ProducerEnvelope (tables : Native.Tables) (document : JSON.DocumentSpan) : Prop where
  schemas : ∀ entry ∈ document.entries, SelectedSchema tables entry.span
  unique : SelectedDistinct document.entries
  imageArrays : ∀ entry ∈ document.entries, selectedName entry.span.theory.name none = some .image →
    ∃ declarations includes, entry.span.theory.declarations = some declarations ∧ entry.span.theory.includes = some includes
  coPresence : SelectedPresent document.entries .image →
    SelectedPresent document.entries .integer ∧ SelectedPresent document.entries .string

theorem DocumentAccepted.finish_valid {document : JSON.DocumentSpan} {state : Core.State}
    (accepted : DocumentAccepted document state) : FinishNative.Test.invalid.eval state.finishView = false := by
  simp only [FinishNative.Test.eval, Core.State.finishView, accepted.good, accepted.mode,
    accepted.depth, accepted.phase, accepted.pending, accepted.inactive, ne_eq, not_true_eq_false,
    decide_false, Bool.false_or]

theorem DocumentAccepted.finish_unchanged {document : JSON.DocumentSpan} {state : Core.State}
    (accepted : DocumentAccepted document state) (absent : ¬ SelectedPresent document.entries .image) :
    (FinishNative.model state.finishView).kind = .unchanged := by
  have unseen : state.seen .image = false := by
    cases seen : state.seen .image with
    | false => rfl
    | true => exact False.elim (absent ((accepted.selected .image).mp seen))
  have noImage : FinishNative.Test.absent.eval state.finishView = true := by
    simp only [FinishNative.Test.eval, Core.State.finishView, unseen, Bool.not_false]
  simp only [FinishNative.model, accepted.finish_valid, Bool.false_eq_true, ↓reduceIte, noImage]

theorem DocumentAccepted.finish_refine {document : JSON.DocumentSpan} {state : Core.State}
    (accepted : DocumentAccepted document state)
    (image : SelectedPresent document.entries .image)
    (integer : SelectedPresent document.entries .integer) (string : SelectedPresent document.entries .string)
    (ordered : state.declarations < state.includes) (bounded : state.includes < state.bytes) :
    (FinishNative.model state.finishView).kind = .refine := by
  have noImage : FinishNative.Test.absent.eval state.finishView = false := by
    simp only [FinishNative.Test.eval, Core.State.finishView, (accepted.selected .image).mpr image, Bool.not_true]
  have ready : FinishNative.Test.ready.eval state.finishView = true := by
    simp only [FinishNative.Test.eval, Core.State.finishView, (accepted.selected .integer).mpr integer,
      (accepted.selected .string).mpr string, ordered, bounded, decide_true, Bool.and_self]
  simp only [FinishNative.model, accepted.finish_valid, Bool.false_eq_true, ↓reduceIte, noImage, ready]

/-- Image's original array closing positions are ordered and lie inside the
whole document. These bounds are derived before Finish is called. -/
theorem document_image_bounds (tables : Native.Tables) (document : JSON.DocumentSpan)
    (room : document.bytes.length ≤ 9223372036854775807)
    (depthRoom : ∀ entry ∈ document.entries, 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (envelope : ProducerEnvelope tables document)
    (accepted : DocumentAccepted document (document.bytes.foldl (consume (Core.modelHelpers tables)) {}))
    (present : SelectedPresent document.entries .image) :
    let final := document.bytes.foldl (consume (Core.modelHelpers tables)) {}
    final.declarations < final.includes ∧ final.includes < final.bytes := by
  obtain ⟨preceding, entry, following, atSpan, position, bytes, _, name, declarations, includes⟩ :=
    document_image_state_entry tables document room depthRoom accepted.good ((accepted.selected .image).mpr present)
  have member : entry ∈ document.entries := by rw [position]; simp
  obtain ⟨declarationNodes, includeNodes, decls, incs⟩ := envelope.imageArrays entry member name
  have normal := entry.span.normal_of_erased_valid (envelope.schemas entry member .image name).1
  obtain ⟨a, b, declCut, incCut, order, bound⟩ := entry.span.candidate_cuts tables atSpan normal declarationNodes includeNodes decls incs
  have whole := congrArg List.length (document.split_entry preceding entry following position)
  simp only [List.length_append] at whole
  have d := declarations.trans declCut
  have i := includes.trans incCut
  change (document.bytes.foldl (consume (Core.modelHelpers tables)) {}).declarations <
    (document.bytes.foldl (consume (Core.modelHelpers tables)) {}).includes ∧
    (document.bytes.foldl (consume (Core.modelHelpers tables)) {}).includes <
    (document.bytes.foldl (consume (Core.modelHelpers tables)) {}).bytes
  rw [d, i, accepted.bytes]
  simp only [List.length_append] at bytes
  omega

/-- Every independent reviewed producer document finishes successfully:
Image documents refine, while documents without Image are unchanged. -/
theorem document_finishes (tables : Native.Tables) (document : JSON.DocumentSpan)
    (room : document.bytes.length ≤ 9223372036854775807)
    (depthRoom : ∀ entry ∈ document.entries, 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (envelope : ProducerEnvelope tables document) :
    let plan := FinishNative.model (document.bytes.foldl (consume (Core.modelHelpers tables)) {}).finishView
    (SelectedPresent document.entries .image → plan.kind = .refine) ∧
      (¬ SelectedPresent document.entries .image → plan.kind = .unchanged) := by
  have accepted := document_accepts tables document room depthRoom envelope.unique envelope.schemas
  constructor
  · intro present
    obtain ⟨integer, string⟩ := envelope.coPresence present
    obtain ⟨ordered, bounded⟩ := document_image_bounds tables document room depthRoom envelope accepted present
    exact accepted.finish_refine present integer string ordered bounded
  · exact accepted.finish_unchanged

end Silver.ImageModel.ScannerNative

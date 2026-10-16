module

public import Silver.ImageRefinementEndpoint
public import Silver.ImageModelDocumentFinish

@[expose] public section
namespace Silver.ImageModel.JSON

/-- A theory's field-body depth bound follows from the complete file's byte
bound, since the original root and theory brackets occupy additional bytes. -/
theorem DocumentSpan.field_room (document : DocumentSpan)
    (room : document.bytes.length ≤ 9223372036854775807) :
    ∀ entry ∈ document.entries, 3 + (fieldsBytes entry.span.spans).length ≤ 9223372036854775807 := by
  intro entry member
  obtain ⟨preceding, following, position⟩ := List.mem_iff_append.mp member
  have whole := congrArg List.length (document.split_entry preceding entry following position)
  have header : 1 ≤ document.header.length := by
    simp only [DocumentSpan.header, List.length_append, List.length_cons, List.length_nil]
    omega
  simp only [List.length_append, TheorySpan.bytes, List.length_cons, List.length_nil] at whole
  omega

end Silver.ImageModel.JSON

namespace Silver.ImageModel

/-- The pinned external producer's source-reviewed schema interface. The typed
document independently describes original syntax and bounded occurrence IDs.
These facts concern producer construction, not acceptance by Silver. -/
structure ProducerSchemas (document : JSON.DocumentSpan) : Prop where
  selected : ∀ entry ∈ document.entries, ∀ kind,
    ScannerNative.selectedName entry.span.theory.name none = some kind →
    entry.span.theory.value.eraseNodeIds = Templates.theoryValue kind
  unique : ScannerNative.SelectedDistinct document.entries
  coPresence : ScannerNative.SelectedPresent document.entries .image →
    ScannerNative.SelectedPresent document.entries .integer ∧
    ScannerNative.SelectedPresent document.entries .string

/-- Finite validity and source-interpreted table bytes discharge all scanner
schema and array-shape premises from the independently reviewed producer ASTs. -/
theorem ProducerSchemas.envelope (document : JSON.DocumentSpan) (producer : ProducerSchemas document)
    (calls : Templates.Calls) (source : Templates.InterpretedSource calls) :
    ScannerNative.ProducerEnvelope calls.tables document := by
  constructor
  · intro entry member kind selected
    have equal := producer.selected entry member kind selected
    refine ⟨?_, ?_, ?_⟩
    · rw [equal]
      exact TemplateValidity.theory_valid kind
    · rw [equal, Templates.interpreted_theory_length calls source kind]
    · intro index bound
      simp only [equal] at bound ⊢
      rw [Templates.interpreted_theory_byte calls source kind (index+1) (by omega)
        (by rw [Templates.interpreted_theory_length calls source kind]; omega),
        Nat.add_sub_cancel, List.getElem?_eq_getElem bound, Option.getD_some]
  · exact producer.unique
  · intro entry member selected
    have equal := congrArg JSON.Value.meaning (producer.selected entry member .image selected)
    obtain ⟨declarations, includes, decls, incs, _⟩ := Templates.selected_original_lists entry.span .image equal
    exact ⟨declarations, includes, decls, incs⟩
  · exact producer.coPresence

theorem producer_finishes (calls : Templates.Calls) (source : Templates.InterpretedSource calls)
    (document : JSON.DocumentSpan) (producer : ProducerSchemas document)
    (room : document.bytes.length ≤ 9223372036854775807) :
    (ScannerNative.SelectedPresent document.entries .image → (scanPlan calls.tables document).kind = .refine) ∧
      (¬ ScannerNative.SelectedPresent document.entries .image → (scanPlan calls.tables document).kind = .unchanged) :=
  ScannerNative.document_finishes calls.tables document room (document.field_room room)
    (producer.envelope document calls source)

/-- Full output refinement for the reviewed producer envelope. The native
scanner's successful refinement decision is derived, rather than assumed. -/
theorem producer_refined_document
    (calls : Templates.Calls) (source : Templates.InterpretedSource calls)
    (document : JSON.DocumentSpan) (producer : ProducerSchemas document)
    (room : document.bytes.length ≤ 9223372036854775807)
    (image : ScannerNative.SelectedPresent document.entries .image)
    (parse : List Nat → Option JSON.Meaning) (sound : JSON.ParserSound parse)
    (parsed : ∀ kind, parse (Templates.theoryValue kind).encode = some (Templates.theoryValue kind).meaning) :
    let plan := scanPlan calls.tables document
    let output := splice document.bytes Clone.declarationsFragment Clone.includesFragment plan.declarations plan.includes
    plan.kind = .refine ∧ RefinedDocument document output ∧
      eraseInsertions output plan.declarations plan.includes
        Clone.declarationsFragment.length Clone.includesFragment.length = document.bytes := by
  have refined := (producer_finishes calls source document producer room).1 image
  exact ⟨refined, refined_document calls source document room (document.field_room room) refined parse sound parsed⟩

end Silver.ImageModel

namespace Silver.ImageModel.FilesSource
open FilesNative

/-- The forward producer guarantee also holds for the actual initialized
native loop and Finish calls, through their checked source interpretation. -/
theorem native_producer_finishes
    (calls : Templates.Calls) (templates : Templates.InterpretedSource calls)
    (nativeHelpers : Core.Helpers)
    (helpers : SourceBridge.NativeHelperBodies calls.tables nativeHelpers)
    (runStructural runConsume : Core.State → Nat → Core.State)
    (scanner : SourceBridge.InterpretedScanner
      (SourceBridge.totalizedHelpers calls.tables nativeHelpers) runStructural runConsume)
    (runFinish : FinishNative.Input → FinishNative.Plan)
    (finish : SourceBridge.InterpretedFinish runFinish)
    (initial : Core.State) (initialSource : SourceBridge.InterpretedInitial initial)
    (before after : Frame) (empty : before.read = []) (started : before.current = initial)
    (command : Command) (selected : command = snapshot ∨ command = refine)
    (execution : LoopRun command runConsume before after)
    (document : JSON.DocumentSpan) (input : after.read = document.bytes)
    (producer : ProducerSchemas document)
    (room : document.bytes.length ≤ 9223372036854775807) :
    (ScannerNative.SelectedPresent document.entries .image → (runFinish after.current.finishView).kind = .refine) ∧
      (¬ ScannerNative.SelectedPresent document.entries .image → (runFinish after.current.finishView).kind = .unchanged) := by
  have plan := initialized_plan command selected calls.tables nativeHelpers helpers
    runStructural runConsume scanner runFinish finish initial initialSource before after empty started execution
  rw [input] at plan
  rw [plan]
  exact producer_finishes calls templates document producer room

end Silver.ImageModel.FilesSource

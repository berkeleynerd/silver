module

public import Silver.ImageFilesEndpoint
public import Silver.ImageModelRefinement

@[expose] public section
namespace Silver.ImageModel.Templates

/-- The finite byte sequence emitted by the native insertion loop's calls. -/
def nativeFragment (calls : Calls) (kind : Fragment) : List Nat :=
  (List.range (calls.length (fragmentKind kind))).map
    (fun index => calls.byteAt (fragmentKind kind) (index + 1))

theorem native_fragment (calls : Calls) (source : InterpretedSource calls) (kind : Fragment) :
    nativeFragment calls kind = fragmentBytes kind := by
  have size := interpreted_fragment_length calls source kind
  apply List.ext_getElem
  · simp only [nativeFragment, List.length_map, List.length_range, size]
  · intro index leftBound rightBound
    simp only [nativeFragment, List.length_map, List.length_range] at leftBound
    simp only [nativeFragment, List.getElem_map, List.getElem_range]
    rw [interpreted_fragment_byte calls source kind (index + 1) (by omega) (by omega),
      Nat.add_sub_cancel, List.getElem?_eq_getElem rightBound, Option.getD_some]

end Silver.ImageModel.Templates

namespace Silver.ImageModel.FilesSource
open FilesNative

/-- End-to-end conditional refinement of the recorded native file execution.
The assumptions are the named interpretation boundaries of the checked native
source, the separately verified SPARK postcondition, and partial external JSON
parser soundness with successful parsing of the three finite templates.
Schema matching, selected occurrences, array nonemptiness, insertion offsets,
exact output syntax and original-byte recovery are conclusions. -/
theorem native_refined_document
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
    (execution : LoopRun refine runConsume before after)
    (refined : (runFinish after.current.finishView).kind = .refine)
    (document : JSON.DocumentSpan) (input : after.read = document.bytes)
    (room : document.bytes.length ≤ 9223372036854775807)
    (depthRoom : ∀ entry ∈ document.entries, 3 + (JSON.fieldsBytes entry.span.spans).length ≤ 9223372036854775807)
    (parse : List Nat → Option JSON.Meaning) (sound : JSON.ParserSound parse)
    (parsed : ∀ kind, parse (Templates.theoryValue kind).encode = some (Templates.theoryValue kind).meaning)
    (output : List Nat)
    (contract : FilesSplice.expression.eval
      { original := after.read, refined := output,
        declarations := Templates.nativeFragment calls .declarations,
        includes := Templates.nativeFragment calls .includes,
        count := (runFinish after.current.finishView).bytes,
        declarationsOffset := (runFinish after.current.finishView).declarations,
        includesOffset := (runFinish after.current.finishView).includes }) :
    RefinedDocument document output ∧
      eraseInsertions output (runFinish after.current.finishView).declarations
        (runFinish after.current.finishView).includes
        Clone.declarationsFragment.length Clone.includesFragment.length = document.bytes ∧
      Clone.insertedIds.Nodup ∧ Clone.insertedIds.length = insertedNodeCount ∧
      (∀ original id, original ≤ originalIdMaximum → id ∈ Clone.insertedIds →
        original < id ∧ id ≤ consumerIdMaximum) ∧
      CloneMeaning.interpret Clone.substitutions = some CloneMeaning.predefined ∧
      (∀ value, CloneMeaning.assertion CloneMeaning.predefined value) := by
  have plan := initialized_plan refine (.inr rfl) calls.tables nativeHelpers helpers
    runStructural runConsume scanner runFinish finish initial initialSource before after empty started execution
  rw [input] at plan
  change runFinish after.current.finishView = scanPlan calls.tables document at plan
  have modelRefined : (scanPlan calls.tables document).kind = .refine := by rw [← plan]; exact refined
  obtain ⟨exactOutput, recovery⟩ := refined_file_preserves calls.tables nativeHelpers helpers
    runStructural runConsume scanner runFinish finish initial initialSource before after empty started
    execution refined output _ _ contract
  have declBytes := Templates.native_fragment calls templates .declarations
  have incBytes := Templates.native_fragment calls templates .includes
  change Templates.nativeFragment calls .declarations = Clone.declarationsFragment at declBytes
  change Templates.nativeFragment calls .includes = Clone.includesFragment at incBytes
  rw [declBytes, incBytes, input, plan] at exactOutput
  rw [declBytes, incBytes, input] at recovery
  have model := refined_document calls templates document room depthRoom modelRefined parse sound parsed
  refine ⟨?_, recovery, Clone.inserted_ids_unique, Clone.inserted_ids_count, ?_,
    CloneMeaning.clone_interpretation, CloneMeaning.predefined_assertion⟩
  · rw [exactOutput]
    exact model.1
  · intro original id bounded member
    exact Clone.inserted_ids_fresh bounded member

end Silver.ImageModel.FilesSource

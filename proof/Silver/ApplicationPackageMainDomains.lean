module

public import Silver.ApplicationPackageMainFlowImports
public import Silver.ApplicationPackageDeclarationsSpecificationDomains

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose Compose.Expressions ApplicationPackageDeclarations ApplicationPackageFrames

/-- Qualification changes only name qualifiers. Native metadata subtypes supply
Main's positive context start; all other component bounds come from Exports. -/
theorem importedFrameRaw_typed (exports : ParserState) (typed : StateType exports)
    (info : PackageBindings.Metadata) (mainPositive : 1 ≤ (info.units .mainBody).first)
    (position : Nat) : StateType (importedFrameRaw exports info position) := by
  refine ⟨mainPositive, typed.capacity, typed.namesCount, typed.names, ?_, ?_, ?_, ?_, ?_,
    typed.firstParameter, typed.firstProcedureParameter⟩
  · simpa only [importedFrameRaw, List.length_map] using typed.scalarCount
  · intro item member
    obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
    exact typed.scalars original present
  · simpa only [importedFrameRaw, List.length_map] using typed.subtypeCount
  · intro item member
    obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
    exact typed.subtypes original present
  · simpa only [importedFrameRaw, List.length_map] using typed.booleanCount

private theorem invalid_reader_frame (text : Source) : ReaderFrame text invalidState := by
  constructor
  · constructor <;> simp [invalidState]
  · exact ((initial_reader_frame text).at_position (position := 0) (Nat.zero_le _)).valid

/-- The original executable Valid_State guard establishes the imported frame
on both return branches. No successful import is a premise. -/
theorem imported_reader_frame (text : Source) (exports : ParserState)
    (framed : ReaderFrame text exports) (info : PackageBindings.Metadata)
    (mainPositive : 1 ≤ (info.units .mainBody).first) (position : Nat) :
    ReaderFrame text (importedFrame text exports info position) := by
  unfold importedFrame
  dsimp only
  split
  · rename_i valid
    exact ⟨importedFrameRaw_typed exports framed.typed info mainPositive position, valid⟩
  · exact invalid_reader_frame text

/-- Complete_Metadata supplies the original Imported_Frame name/span
preconditions. Positive span starts come from Ada's metadata field types. -/
theorem imported_header_domain {text : Source} {info : PackageBindings.Metadata}
    (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText text) info = true) :
    Names.ValidNameState text info.nameFirst info.nameAfter ∧
      1 ≤ (info.units .mainBody).first ∧ (info.units .mainBody).first ≤ text.length + 1 := by
  have accepted : PackageBindings.validMetadata (ApplicationPackageNames.metadataText text) info = true :=
    (Bool.and_eq_true_iff.mp complete).1
  have metadata := PackageBindings.SourceBridge.validMetadata_name_and_main
    PackageBindings.Native.modelCalls PackageBindings.Native.model_primitives
    PackageBindings.Native.model_equations (ApplicationPackageNames.metadataText text) info accepted
  exact ⟨.inr (ApplicationPackageNames.Native.validName_domain metadata.1).2,
    (typed.2.2.1 .mainBody).1, metadata.2⟩

/-- Main's inherited state domain survives its original begin-token assignment,
including zero on rejection; no metadata, binding or flow field is replaced. -/
theorem begin_frame_domain {text : Source} (frame : ParserState)
    (valid : FunctionDeclarationNative.NativeValidState text frame) :
    FunctionDeclarationNative.NativeValidState text
      {frame with position := tokenAfter text frame.position (.word "begin")} := by
  refine ⟨⟨?_, valid.base.2⟩, valid.ready, valid.bounds⟩
  exact fixedAfter_result_bound text frame.position "begin" true (by decide)

namespace DeclarationLibraries

/-- The original imported frame has the full native domain consumed by the
optional argument and declaration readers, independently of later acceptance. -/
theorem imported_domain (library : DeclarationLibraries) {text : Source} (valid : ValidText text)
    (exports : ParserState) (framed : ReaderFrame text exports) (info : PackageBindings.Metadata)
    (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText text) info = true)
    (position : Nat) :
    FunctionDeclarationNative.NativeValidState text
      (library.identity.boundary.importedFrame text exports info position) := by
  rw [library.identity.boundary.frame valid exports framed info position]
  exact (imported_reader_frame text exports framed info
    (imported_header_domain typed complete).2.1 position).native

end DeclarationLibraries
end Silver.ApplicationPackageMain

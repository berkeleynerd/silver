module

public import Silver.ApplicationPackageDeclarationsSignatureLoopDomains

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

/-- A completed formal loop retains the reader frame only when it reaches
the finishing phase; a rejected result keeps its exact partial metadata. -/
def SignatureExitFramed (text : Source) : SignatureExit → Prop
  | .returned _ => True
  | .ready state => ReaderFrame text state.header

namespace NameLibraries

theorem signature_loop (library : NameLibraries) {text : Source} (valid : ValidText text)
    {completing : Bool} {state : SignatureState} {result : SignatureExit}
    (run : SignatureLoop modelSignatureCalls text completing state result)
    (framed : ReaderFrame text state.header) :
    SignatureLoop (library.signatureValidity modelSignatureCalls) text completing state result ∧
      SignatureExitFramed text result := by
  induction run with
  | returned step =>
    exact ⟨.returned ((library.signature_step valid completing _ framed).trans step), True.intro⟩
  | ready step =>
    have after := signature_step_framed completing _ framed
    rw [step] at after
    exact ⟨.ready ((library.signature_step valid completing _ framed).trans step), after⟩
  | next step _ ih =>
    have after := signature_step_framed completing _ framed
    rw [step] at after
    obtain ⟨tail, finalFrame⟩ := ih after
    exact ⟨.next ((library.signature_step valid completing _ framed).trans step) tail, finalFrame⟩

/-- The whole original Signature procedure terminates with the model's exact
result under the imported lexical, type, visibility and state predicates.
The only input assumptions are the original source and reader-frame domains. -/
theorem signature_exec (library : NameLibraries) {text : Source} (valid : ValidText text)
    (outer : ParserState) (framed : ReaderFrame text outer) (info : PackageBindings.Metadata)
    (completing : Bool) :
    SignatureExec (library.signatureValidity modelSignatureCalls) text outer info completing
      (readSignature text outer info completing) := by
  have start := library.signature_start
    {modelSignatureCalls with stateValid := fun text frame =>
      ApplicationPackageFrames.Native.frameCalls library.shared library.validity _ .validState text frame}
    valid outer framed info completing
  have startFrame := signature_start_framed outer framed info completing
  change signatureStart (library.signatureValidity modelSignatureCalls) text outer info completing =
    signatureStart modelSignatureCalls text outer info completing at start
  unfold SignatureExec
  rw [start]
  cases selected : signatureStart modelSignatureCalls text outer info completing with
  | returned result =>
    simp only [readSignature, selected]
  | ready state =>
    rw [selected] at startFrame
    simp only [readSignature, selected]
    exact (library.signature_finish modelSignatureCalls valid outer completing state startFrame).symm
  | loop state =>
    rw [selected] at startFrame
    obtain ⟨loop, finalFrame⟩ := library.signature_loop valid
      (runSignatureLoop_exec text completing state) startFrame
    refine ⟨runSignatureLoop text completing state, loop, ?_⟩
    simp only [readSignature, selected]
    cases ending : runSignatureLoop text completing state with
    | returned result => rfl
    | ready finalState =>
      rw [ending] at finalFrame
      exact (library.signature_finish modelSignatureCalls valid outer completing finalState finalFrame).symm

/-- Any execution of the imported procedure has that same result, including
early rejection and rejection after partial formal storage. -/
theorem signature_exec_iff (library : NameLibraries) {text : Source} (valid : ValidText text)
    (outer : ParserState) (framed : ReaderFrame text outer) (info : PackageBindings.Metadata)
    (completing : Bool) (result : SignatureResult) :
    SignatureExec (library.signatureValidity modelSignatureCalls) text outer info completing result ↔
      result = readSignature text outer info completing := by
  constructor
  · intro run
    exact run.unique (library.signature_exec valid outer framed info completing)
  · rintro rfl
    exact library.signature_exec valid outer framed info completing

end NameLibraries
end Silver.ApplicationPackageDeclarations

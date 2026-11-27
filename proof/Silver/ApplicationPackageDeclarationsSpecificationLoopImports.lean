module

public import Silver.ApplicationPackageDeclarationsSpecificationBranchImports

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationNative Control ApplicationPackageProcedure

def SpecificationExitFramed (text : Source) : SpecificationExit → Prop
  | .returned _ => True
  | .ready state => ReaderFrame text state.exports

namespace ObjectLibraries

theorem specification_loop (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (prior : ApplicationNative.Locals) {text : Source} (valid : ValidText text)
    {state : SpecificationState} {result : SpecificationExit}
    (run : SpecificationLoop (modelSpecificationCalls reader) text state result)
    (framed : ReaderFrame text state.exports) :
    SpecificationLoop (library.specification reader prior) text state result ∧ SpecificationExitFramed text result := by
  induction run with
  | returned step =>
    exact ⟨.returned ((library.specification_step reader prior valid _ framed).trans step), True.intro⟩
  | ready step =>
    have after := specification_step_framed reader valid _ framed
    rw [step] at after
    exact ⟨.ready ((library.specification_step reader prior valid _ framed).trans step), after⟩
  | next step _ ih =>
    have after := specification_step_framed reader valid _ framed
    rw [step] at after
    obtain ⟨tail, finalFrame⟩ := ih after
    exact ⟨.next ((library.specification_step reader prior valid _ framed).trans step) tail, finalFrame⟩

/-- Every original Specification execution keeps exact metadata, including
early rejection and partial declaration writes, under the imported callees. -/
theorem specification_exec (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (prior : ApplicationNative.Locals) {text : Source} (valid : ValidText text)
    (info : PackageBindings.Metadata) :
    SpecificationExec (library.specification reader prior) text info (readSpecification reader text info) := by
  have start := library.names.specification_start (library.specificationBranches reader prior) reader valid info
  change specificationStart (library.specification reader prior) text info =
    specificationStart (modelSpecificationCalls reader) text info at start
  have startFrame := specification_start_framed reader text info
  unfold SpecificationExec
  rw [start]
  cases selected : specificationStart (modelSpecificationCalls reader) text info with
  | returned result => simp only [readSpecification, selected]
  | loop state =>
    rw [selected] at startFrame
    obtain ⟨loop, finalFrame⟩ := library.specification_loop reader prior valid
      (runSpecificationLoop_exec reader text state) startFrame
    refine ⟨runSpecificationLoop reader text state, loop, ?_⟩
    simp only [readSpecification, selected]
    cases ending : runSpecificationLoop reader text state with
    | returned result => rfl
    | ready finalState =>
      rw [ending] at finalFrame
      exact (library.names.specification_finish (library.specificationBranches reader prior)
        reader valid finalState finalFrame).symm

theorem specification_exec_iff (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (prior : ApplicationNative.Locals) {text : Source} (valid : ValidText text)
    (info : PackageBindings.Metadata) (result : SpecificationResult) :
    SpecificationExec (library.specification reader prior) text info result ↔ result = readSpecification reader text info := by
  constructor
  · intro run
    exact run.unique (library.specification_exec reader prior valid info)
  · rintro rfl
    exact library.specification_exec reader prior valid info

end ObjectLibraries

/-- The complete typed Specification with actual imported lexical, subtype,
Object and state-predicate calls. The Signature callback is the exact total
procedure result established by signature_imported_reader_exec. All original
metadata and inactive caller/backing cells remain arbitrary. -/
theorem specification_imported_reader_exec (library : ObjectLibraries)
    (reader : BooleanElaboration.Native.Reader) (procedures : ProcedureCalls) (backing : Backing)
    (prior : ApplicationNative.Locals) (source : Source) (valid : ValidText source)
    (info : PackageBindings.Metadata) (result : SpecificationResult) :
    SpecificationNative.body.Exec (SpecificationNative.functions (library.specification reader prior))
      {procedures with signature := readSignature} backing (SpecificationNative.inputLocals prior source info)
      (fun store => result = SpecificationNative.projectResult store) ↔ result = readSpecification reader source info := by
  rw [SpecificationNative.exec_iff]
  exact library.specification_exec_iff reader prior valid info result

end Silver.ApplicationPackageDeclarations

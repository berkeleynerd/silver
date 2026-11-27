module

public import Silver.ApplicationPackageCompletionOutputDomains
public import Silver.ApplicationPackageRecursiveOutcomes
public import Silver.ApplicationPackageActualLibraries

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrames

def bodySource (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (state : InitializationFrame) : Statement.Input :=
  ⟨text, completionContextOf (declarationReaders reader calls) state,
    completionInput (declarationReaders reader calls) item state, info, {}, {}⟩

theorem body_source_domain (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (state : InitializationFrame) (framed : ReaderFrame text state.frame) :
    Recursive.NativeDomain (bodySource reader calls text info item state) := by
  refine ⟨valid, ⟨nativeContext state, rfl, context_valid state framed⟩,
    body_domain state framed, ?_, ?_⟩
  · simp [bodySource, FunctionBindings.ValidMetadata]
  · simp [bodySource, ProcedureBindings.ValidMetadata]

theorem tail_scan {readers : Recursive.Readers}
    (equations : Recursive.Equations (Recursive.nativeReaders readers) Recursive.NativeDomain)
    (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {text : Source} (valid : ValidText text) (info : PackageBindings.Metadata) (typed : info.Typed)
    (item : PackageBindings.Routine) (state : InitializationFrame) (framed : ReaderFrame text state.frame)
    (stop : BodyStop) (required : Bool) :
    Recursive.ScanDomain text (nativeContext state).model
      ((Recursive.nativeReaders readers).tailResult (bodySource reader calls text info item state) stop required).scan :=
  ((equations.outcomes (body_source_domain reader calls valid info item state framed) typed).2 stop required).scan

theorem return_domain {text : Source} (state : InitializationFrame)
    (framed : ReaderFrame text state.frame) (item : PackageBindings.Routine) (typed : item.Typed)
    (scan : BodyScan) (legal : Recursive.ScanDomain text (nativeContext state).model scan) :
    FunctionDeclarationNative.ReturnInput text (nativeContext state) scan
      ⟨0, item.resultKind, item.resultBounds, 0⟩ := by
  refine ⟨context_valid state framed, ⟨legal.position, legal.controls, legal.path, legal.flow⟩,
    ⟨Nat.zero_le _, ?_, Nat.zero_le _⟩⟩
  exact typed.2.2.2.2.2.2.2.2.2.2.1

end Silver.ApplicationPackageCompletion

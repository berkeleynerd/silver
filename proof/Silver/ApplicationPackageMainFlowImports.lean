module

public import Silver.ApplicationPackageMainDeclarationImports
public import Silver.PredicateAdapterEnvironment
public import Silver.PathNativeEquations

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose Predicate

/-- The original Body_Of model/wrapper and its Initial_Flow import. Definitions
are typed source equations and the verified native storage contract, not an
assumed equality with the semantic body scan. -/
structure FlowLibraries where
  body : BodyNative.Calls
  flow : FlowSourceBridge.Calls
  meaning : FlowSourceBridge.CallsMeaning flow
  initial : FlowSourceBridge.Context → FlowSourceBridge.FlowStorage
  initialSource : FlowSourceBridge.InterpretedInitial flow initial
  models : Adapter.Wrappers.Calls
  wrappers : Adapter.Wrappers.Calls
  definitions : Adapter.Wrappers.ModelEquations models body (Adapter.Environment.initialCall initial)
  refinement : Adapter.Wrappers.Refinement models wrappers

namespace FlowLibraries

def context (library : FlowLibraries) (scan : ScanResult) : Predicate.Native.Context :=
  Adapter.contextExpr.eval library.body {scan}

def calls (library : FlowLibraries) (other : Calls) : Calls :=
  {other with
    contextOf := fun scan => (library.context scan).model
    bodyOf := library.wrappers.bodyOf}

theorem context_meaning (library : FlowLibraries) (scan : ScanResult) :
    (library.context scan).model = Predicate.contextOf scan := rfl

theorem body_meaning (library : FlowLibraries) (scan : ScanResult)
    (bounded : scan.state.scalarNames.length ≤ ScalarExpression.maxBindings) :
    library.wrappers.bodyOf scan = Predicate.bodyOf scan :=
  Adapter.Wrappers.bodyOf_interpreted
    (Adapter.Wrappers.normalize_models library.flow library.meaning library.initial
      library.initialSource library.definitions) library.refinement scan bounded

theorem body_count (library : FlowLibraries) (scan : ScanResult)
    (bounded : scan.state.scalarNames.length ≤ ScalarExpression.maxBindings) :
    (library.wrappers.bodyOf scan).count = scan.state.scalarNames.length :=
  Adapter.Wrappers.bodyOf_count
    (Adapter.Wrappers.normalize_models library.flow library.meaning library.initial
      library.initialSource library.definitions) library.refinement scan bounded

/-- The entire inherited state precondition supplies context, flow, scan and
catalogue domains for Main's original Application_Tail call. -/
theorem body_domains (library : FlowLibraries) {text : Source} (scan : ScanResult)
    (framed : FunctionDeclarationNative.NativeValidState text scan.state) :
    Predicate.Native.ValidContext text (library.context scan) ∧
      BodyNative.ValidScan text (library.context scan) (library.wrappers.bodyOf scan) ∧
      FunctionBindings.ValidMetadata text scan.state.functions ∧
      ProcedureBindings.ValidMetadata text scan.state.procedures := by
  have native : OuterReadiness.ValidState text scan.state := ⟨framed.base, framed.ready, framed.bounds⟩
  have bounded := framed.base.2.2.2.2.2.1.1
  rw [library.body_meaning scan bounded]
  exact ⟨Adapter.context_valid text scan native, Adapter.body_valid text scan native,
    framed.base.functions, framed.base.procedures⟩

/-- Completed reads only the two native flags. Its meaning holds for arbitrary
inactive bounds and arbitrary remaining local storage, including rejected paths.
The existing PathFacts source bridge binds this exact expression to Ada. -/
theorem completed_native (locals : PathFacts.Native.Locals) :
    PathFacts.Native.completedBody.eval locals =
      Predicate.completed (locals .context "facts").model := rfl

end FlowLibraries
end Silver.ApplicationPackageMain

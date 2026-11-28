module

public import Silver.PredicateBodyLibraries
public import Silver.ApplicationPackageMainFlowImports

@[expose] public section

namespace Silver.ApplicationPackageBodies.Inherited
open Compose Compose.Expressions Predicate

/-- The existing original-source library equations, below the outer Main
scanner. Package bodies reuse these helpers without requiring a completed
standalone Main parse or an empty declaration frame. -/
structure Libraries where
  inherited : Compose.Expressions.Calls
  domain : StateDomain
  source : RawHelperEquations inherited (domain := domain)
  calls : Predicate.BodyLibraries.Calls inherited
  definitions : Predicate.BodyLibraries.Definitions calls

namespace Libraries

def flow (library : Libraries) : ApplicationPackageMain.FlowLibraries where
  body := library.calls.body
  flow := library.calls.flowLibraries
  meaning := library.definitions.flowLibraries
  initial := library.calls.initial
  initialSource := library.definitions.initial
  models := library.calls.bodyWrapperModels
  wrappers := library.calls.bodyWrappers
  definitions := Adapter.Wrappers.normalize_tokens library.source library.definitions.wrapperModels
  refinement := library.definitions.wrappers

theorem basic (library : Libraries) (text : Source) (valid : ValidText text)
    (context : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text context)
    (scan : BodyScan) (scanValid : BodyNative.ValidScan text context scan)
    (functions : FunctionBindings.Metadata) (functionsValid : FunctionBindings.ValidMetadata text functions)
    (procedures : ProcedureBindings.Metadata) (proceduresValid : ProcedureBindings.ValidMetadata text procedures) :
    library.calls.basic text context scan functions procedures =
      Predicate.basicBody text context.model scan functions procedures := by
  rw [library.definitions.basic text valid context contextValid scan scanValid functions procedures
    functionsValid proceduresValid]
  exact BasicNative.basicEval_normalized
    (Predicate.BodyLibraries.basic_helpers library.calls library.source library.definitions) _ _ _ _ _

theorem scalarTarget (library : Libraries) (text : Source) (valid : ValidText text)
    (context : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text context)
    (position : Nat) (bounded : ValidCursor text position) :
    library.calls.basicPrimitives.scalarTarget text context position =
      Predicate.scalarTarget text context.model position :=
  (Predicate.BodyLibraries.basic_helpers library.calls library.source library.definitions).scalarTarget
    text context position ⟨valid, contextValid, bounded⟩

theorem booleanTarget (library : Libraries) (text : Source) (valid : ValidText text)
    (context : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text context)
    (position : Nat) (bounded : ValidCursor text position) :
    library.calls.basicPrimitives.booleanTarget text context position =
      Predicate.booleanTarget text context.model position :=
  (Predicate.BodyLibraries.basic_helpers library.calls library.source library.definitions).booleanTarget
    text context position ⟨valid, contextValid, bounded⟩

/-- The wrapper's constrained result and Static equality are consumed through
the existing interpreted wrapper contract, including failed input scans. -/
theorem bodyToken (library : Libraries) (text : Source) (valid : ValidText text)
    (context : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text context)
    (scan : BodyScan) (scanValid : BodyNative.ValidScan text context scan)
    (token : ShellToken) (tokenValid : ValidToken token) (fixed : Adapter.FixedToken token) :
    library.calls.bodyWrappers.token text context scan token = Predicate.bodyToken text scan token :=
  Adapter.Wrappers.token_interpreted
    (Predicate.BodyLibraries.wrapper_models library.calls library.source library.definitions)
    library.definitions.wrappers text context scan token ⟨valid, contextValid, scanValid, tokenValid⟩ fixed

theorem condition (library : Libraries) (text : Source) (valid : ValidText text)
    (context : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text context)
    (position : Nat) (bounded : ValidCursor text position)
    (facts : ActiveFlow) (flowValid : Predicate.Native.ValidFlow context facts) :
    library.calls.predicate.condition text context position facts [] =
      Predicate.readCondition text context.model position facts :=
  Predicate.Native.condition_of_source_equations
    (Predicate.BodyLibraries.predicate_helpers library.calls library.source library.definitions)
    library.definitions.predicates library.definitions.predicateContracts text valid context contextValid
    position bounded facts flowValid [] (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])

theorem joinInto (library : Libraries) (left right : ActiveFlow)
    (capacity : left.count ≤ ScalarExpression.maxBindings) (same : left.count = right.count) :
    library.calls.joinInto left right = left.join right := by
  obtain ⟨calls, joined, into, meaning, joinedSource, source, observed⟩ := library.definitions.joinInto
  rw [observed left right capacity same]
  simpa only [FlowSourceBridge.ofFlow_active] using
    FlowSourceBridge.interpreted_joinInto calls meaning joined joinedSource into source
      (FlowSourceBridge.ofFlow left) (FlowSourceBridge.ofFlow right) capacity same

end Libraries
end Silver.ApplicationPackageBodies.Inherited

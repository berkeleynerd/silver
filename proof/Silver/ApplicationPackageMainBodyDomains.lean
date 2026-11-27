module

public import Silver.ApplicationPackageMainDeclarationComposition
public import Silver.ApplicationPackageRecursiveDomain

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose Predicate ApplicationPackages ApplicationPackageDeclarations

namespace FlowLibraries

/-- The original Application_Of leaves every body/flow field unchanged. Its
Main caller therefore supplies the exact common recursive reader precondition. -/
theorem recursive_domain (library : FlowLibraries) {text : Source} (validText : Expressions.ValidText text)
    (scan : ScanResult) (framed : FunctionDeclarationNative.NativeValidState text scan.state)
    (info : PackageBindings.Metadata) :
    ApplicationPackageBodies.Recursive.NativeDomain
      ⟨text, (library.context scan).model, applicationOf (library.wrappers.bodyOf scan),
        info, scan.state.functions, scan.state.procedures⟩ := by
  have domain := library.body_domains scan framed
  exact ⟨validText, ⟨library.context scan, rfl, domain.1⟩,
    ⟨domain.2.1.1, domain.2.1.2.1, domain.2.1.2.2.1, domain.2.1.2.2.2⟩,
    domain.2.2.1, domain.2.2.2⟩

end FlowLibraries

namespace DeclarationLibraries

def bodyInput (other : Calls) (flow : FlowLibraries) (sources : ApplicationUnits.Bundle)
    (exports : ParserState) (info : PackageBindings.Metadata) : ApplicationPackageBodies.Statement.Input :=
  let frame := bodyFrame (model other) sources exports info
  let scan : ScanResult := ⟨frame, frame.assignedInFunctions, false⟩
  ⟨textOf sources, (flow.context scan).model, applicationOf (flow.wrappers.bodyOf scan),
    info, frame.functions, frame.procedures⟩

/-- Native Main preconditions establish the recursive body reader domain after
its original imports, declarations and begin token. Later body acceptance is
not needed, and metadata is restricted only by actual native field types and
Main's declared Complete_Metadata precondition. -/
theorem body_input_domain (library : DeclarationLibraries) (other : Calls) (flow : FlowLibraries)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    ApplicationPackageBodies.Recursive.NativeDomain (bodyInput other flow sources exports info) := by
  exact flow.recursive_domain (textOf_valid valid) _
    (library.body_frame other valid exports framed info typed complete).2 info

end DeclarationLibraries
end Silver.ApplicationPackageMain

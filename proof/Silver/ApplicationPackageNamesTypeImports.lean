module

public import Silver.ApplicationPackageNamesImports
public import Silver.FunctionDeclarationHeaderLibraries

@[expose] public section

namespace Silver.ApplicationPackageNames.Native
open Compose

/-- Interpret the package type reader with the native Function_Type_At call.
Both levels use the same original source, cursor and complete parser frame. -/
theorem imported_type (imports : ApplicationPackageImports.Imports)
    (header : FunctionDeclarationNative.Calls)
    (equations : FunctionDeclarationNative.HeaderEquations header)
    (domain : FunctionDeclarationNative.ExactDomain imports.domain)
    {metadata : FunctionBindings.Native.Calls} (functions : FunctionBindings.SourceBridge.ImplementationCorrect metadata)
    {visibility : FunctionVisibilityNative.Implementation}
    (primitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilitySource : FunctionVisibilityNative.Equations visibility)
    (links : FunctionDeclarationNative.HeaderLinks header imports.composed metadata visibility)
    (text : Source) (valid : Expressions.ValidText text) (frame : ParserState)
    (info : PackageBindings.Metadata) (position : Nat)
    (input : FunctionDeclarationNative.StateInput text frame) (bounded : Expressions.ValidCursor text position) :
    packageTypeBody.eval (importedCalls imports (header .functionType)).get
      ({text,frame,info,position} : Inputs).locals = packageTypeAt text frame info position := by
  rw [type_denotation]
  apply type_meaning _ (imported_primitives imports (header .functionType)) _ valid _ _ _ bounded
  exact (equations.functionType text valid frame position input bounded).trans
    (FunctionDeclarationNative.functionType_imports header text frame position
      (FunctionDeclarationNative.header_type_imports imports.inherited domain functions primitives
        visibilitySource links text valid frame position input bounded))

end Silver.ApplicationPackageNames.Native

module

public import Silver.ApplicationPackagePrimitiveImports

@[expose] public section

namespace Silver.ApplicationPackageNames.Native
open Compose

/-- Native callees for the package name readers on the original pooled source.
The type reader is supplied by the enclosing parser's interpretation. -/
def importedCalls (imports : ApplicationPackageImports.Imports)
    (functionType : Source → ParserState → Nat → FunctionTypeResult) : Calls where
  skip := imports.composed.function .skip
  nameAfter := imports.composed.function .nameAfter
  takeToken := imports.composed.function .takeToken
  nameIs := ApplicationPackageImports.nameIs imports
  forbidden := ApplicationPackageImports.forbidden imports
  validName text := imports.packages.validName (metadataText text)
  sameName := ApplicationPackageImports.sameName imports
  lookupExport text := imports.packages.lookupExport (metadataText text)
  lookupState text := imports.packages.lookupState (metadataText text)
  functionType := functionType

theorem imported_primitives (imports : ApplicationPackageImports.Imports)
    (functionType : Source → ParserState → Nat → FunctionTypeResult) :
    PrimitiveMeaning (importedCalls imports functionType) where
  skip := Compose.Expressions.interpreted_skip imports.composed imports.inherited
  nameAfter := Compose.Expressions.interpreted_name imports.composed imports.inherited
  takeToken := Compose.Expressions.interpreted_take imports.composed imports.inherited
  nameIs text valid first after word name positive bounded :=
    ApplicationPackageImports.nameIs_meaning imports text valid first after name word positive bounded
  forbidden := ApplicationPackageImports.forbidden_meaning imports
  validName text := PackageBindings.Native.interpreted_validName imports.packages
    imports.packagePrimitives imports.packageEquations (metadataText text)
  sameName := ApplicationPackageImports.sameName_meaning imports
  lookupExport text info name := (PackageBindings.SourceBridge.executable_lookups imports.packages
    imports.packagePrimitives imports.packageEquations (metadataText text) info name).1
  lookupState text info name := (PackageBindings.SourceBridge.executable_lookups imports.packages
    imports.packagePrimitives imports.packageEquations (metadataText text) info name).2.1

end Silver.ApplicationPackageNames.Native

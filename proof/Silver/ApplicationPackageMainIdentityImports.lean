module

public import Silver.ApplicationPackageMainImports
public import Silver.ApplicationPackageSpellingCandidate
public import Silver.ApplicationPackageImportImports

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose ApplicationPackageImports

/-- The existing output-source normalization interpretation closes the import
scanner; Main's boundary library supplies the lexical and package callees. -/
structure IdentityLibraries where
  boundary : Libraries
  outputCalls : Output.Calls
  output : Output.PrimitiveCalls
  outputSource : Output.Expressions.PrimitiveInterpretation outputCalls output

namespace IdentityLibraries

def modelImported (source : Source) : Source :=
  (ApplicationPackageImport.Model.imported ApplicationPackageImport.modelCalls
    (source.length + 2) source).getD []

def scan (library : IdentityLibraries) (source : Source) : Source :=
  (ApplicationPackageImport.Native.execute
    (ApplicationPackageImport.importedCalls library.boundary.names.shared library.output)
    (source.length + 2) (fun ty _ => ty.default) source).getD []

theorem scan_meaning (library : IdentityLibraries) (source : Source) :
    library.scan source = modelImported source := by
  unfold scan modelImported
  rw [(ApplicationPackageImport.execute_imports library.boundary.names.shared library.outputCalls
    library.output library.outputSource source (source.length + 2) (by omega) (fun ty _ => ty.default)).1]

/-- No native scratch storage is fixed by the model: every incoming local store
executes the same finite scanner and produces the same original name bytes. -/
theorem scan_arbitrary_locals (library : IdentityLibraries) (source : Source) (locals : ApplicationNative.Locals) :
    ApplicationPackageImport.Native.execute
      (ApplicationPackageImport.importedCalls library.boundary.names.shared library.output)
      (source.length + 2) locals source = some (library.scan source) := by
  have result := ApplicationPackageImport.execute_imports library.boundary.names.shared library.outputCalls
    library.output library.outputSource source (source.length + 2) (by omega) locals
  obtain ⟨value, done⟩ := result.2
  have modelDone := result.1.symm.trans done
  rw [done, scan_meaning, modelImported, modelDone]
  rfl

def spelling (library : IdentityLibraries) (text : Source) (info : PackageBindings.Metadata)
    (word : Source) : Bool :=
  (ApplicationPackageSpelling.body.eval library.boundary.names.shared.packages
    (ApplicationPackageSpelling.inputs ⟨1,text⟩ info ⟨1,word⟩)).getD false

def modelSpelling (text : Source) (info : PackageBindings.Metadata) (word : Source) : Bool :=
  ApplicationPackageSpelling.sameSpelling ⟨1,text⟩ info ⟨1,word⟩

theorem spelling_meaning (library : IdentityLibraries) (text : Source)
    (info : PackageBindings.Metadata) (word : Source) :
    library.spelling text info word = modelSpelling text info word := by
  unfold spelling
  rw [ApplicationPackageSpelling.imported_body_meaning _ library.boundary.names.shared.packagePrimitives
    library.boundary.names.shared.packageEquations]
  rfl

/-- Main represents the scanner's returned String by bytes. This is valid even
when that String has a different lower bound; only the comparison, not its Ada
bounds, is normalized. -/
theorem spelling_arbitrary_word_first (library : IdentityLibraries) (text : Source)
    (info : PackageBindings.Metadata) (word : Source) (first : Int) :
    ApplicationPackageSpelling.body.eval library.boundary.names.shared.packages
      (ApplicationPackageSpelling.inputs ⟨1,text⟩ info ⟨first,word⟩) =
      some (library.spelling text info word) := by
  rw [ApplicationPackageSpelling.imported_body_meaning _ library.boundary.names.shared.packagePrimitives
    library.boundary.names.shared.packageEquations, spelling_meaning]
  rfl

def calls (library : IdentityLibraries) (other : Calls) : Calls :=
  {library.boundary.calls other with importedPackage := library.scan, samePackageSpelling := library.spelling}

def model (other : Calls) : Calls :=
  {boundaryModel other with importedPackage := modelImported, samePackageSpelling := modelSpelling}

theorem import_guard (library : IdentityLibraries) (other : Calls) (sources : ApplicationUnits.Bundle)
    (info : PackageBindings.Metadata) :
    (library.calls other).samePackageSpelling (textOf sources) info
      ((library.calls other).importedPackage (sources.unitSource .mainBody)) =
    (model other).samePackageSpelling (textOf sources) info
      ((model other).importedPackage (sources.unitSource .mainBody)) := by
  change library.spelling _ _ (library.scan _) = _
  rw [spelling_meaning, scan_meaning]
  rfl

end IdentityLibraries
end Silver.ApplicationPackageMain

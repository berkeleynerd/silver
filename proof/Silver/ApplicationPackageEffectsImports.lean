module

public import Silver.ApplicationPackageEffectsMeaning
public import Silver.PackageBindingsSourceBridge
public import Silver.ScalarExpressionSourceBridge
public import Silver.BooleanBindingsSourceBridge
public import Silver.ProcedureNameFreeNative

@[expose] public section

/-! Imported effect helpers use the existing native equations, not an assumed
completed scanner or package-effect meaning. The profile source aggregate
separately supplies the exact helper trees and their original-source witnesses. -/
namespace Silver.ApplicationPackageEffects
open Compose Compose.Expressions Predicate

structure Imports where
  packages : PackageBindings.Native.Calls
  packagePrimitives : PackageBindings.Native.Primitives packages
  packageEquations : PackageBindings.Native.Equations packages
  scalars : ScalarExpression.Native.Calls
  scalarSource : ScalarExpression.SourceBridge.InterpretedSource scalars
  booleans : BooleanBindings.SourceBridge.InterpretedSource
  composed : Compose.Expressions.Calls
  domain : StateDomain
  inherited : RawHelperEquations composed (domain := domain)
  nameStep : ProcedureNameNative.Step
  nameModel : ProcedureNameNative.Free
  nameScan : ProcedureNameNative.Free
  nameDefinitions : ProcedureNameNative.FreeDefinitionEquations composed nameStep nameModel nameScan

def importedCalls (imports : Imports) : Calls where
  validName text name := imports.packages.validName (ApplicationPackageNames.metadataText text) name
  scalarLookup text names first after := imports.scalars.lookup text names first after
  booleanLookup text names first after := imports.booleans.lookup text names first after
  skip := imports.composed.function .skip
  nameAfter := imports.composed.function .nameAfter
  lookupState text info name := imports.packages.lookupState (ApplicationPackageNames.metadataText text) info name
  actualNameFree := imports.nameScan

theorem imported_primitives (imports : Imports) : PrimitiveMeaning (importedCalls imports) where
  validName text name := PackageBindings.Native.interpreted_validName
    imports.packages imports.packagePrimitives imports.packageEquations
      (ApplicationPackageNames.metadataText text) name
  scalarLookup text valid names environment first after firstBound afterBound :=
    ScalarExpression.SourceBridge.interpreted_lookup imports.scalars imports.scalarSource
      text valid names environment first after firstBound afterBound
  booleanLookup text valid names environment first after firstBound afterBound :=
    imports.booleans.lookup_meaning text valid names environment first after firstBound afterBound
  skip text valid position bounded :=
    interpreted_skip imports.composed imports.inherited text valid position bounded
  nameAfter text valid position bounded :=
    interpreted_name imports.composed imports.inherited text valid position bounded
  lookupState text info name :=
    (PackageBindings.SourceBridge.executable_lookups imports.packages imports.packagePrimitives
      imports.packageEquations (ApplicationPackageNames.metadataText text) info name).2.1
  actualNameFree text valid first after targetFirst targetAfter firstBound afterBound named :=
    ProcedureNameNative.interpreted_free imports.composed imports.inherited
      imports.nameStep imports.nameModel imports.nameScan imports.nameDefinitions
      text first after targetFirst targetAfter ⟨valid, firstBound, afterBound, named⟩

theorem imported_visible (imports : Imports) (text : Source) (valid : ValidText text)
    (context : ParseContext) (domain : LookupDomain text context)
    (info : PackageBindings.Metadata) (index : Nat) :
    visibleState (importedCalls imports) text context info index =
      visibleState modelCalls text context info index :=
  visible_meaning _ (imported_primitives imports) text valid context domain info index

theorem imported_target (imports : Imports) (text : Source) (valid : ValidText text)
    (context : ParseContext) (domain : LookupDomain text context)
    (info : PackageBindings.Metadata) (position : Nat) (bounded : position ≤ text.length + 1) :
    stateTarget (importedCalls imports) text context info position =
      stateTarget modelCalls text context info position :=
  target_meaning _ (imported_primitives imports) text valid context domain info position bounded

theorem imported_reads (imports : Imports) (text : Source) (valid : ValidText text)
    (context : ParseContext) (domain : LookupDomain text context)
    (info : PackageBindings.Metadata) (first after : Nat)
    (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    stateReads (importedCalls imports) text context info first after =
      stateReads modelCalls text context info first after :=
  reads_meaning _ (imported_primitives imports) text valid context domain info first after firstBound afterBound

end Silver.ApplicationPackageEffects

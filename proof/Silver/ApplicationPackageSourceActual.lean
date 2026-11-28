module

public import Silver.ApplicationPackageSourceBridge
public import Silver.ApplicationAdmissionSourceChecks
public import Silver.ApplicationAdmissionChargeSourceChecks
public import Silver.ApplicationPackageDeclarationsSourceChecks
public import Silver.ApplicationPackageBodiesSourceChecks
public import Silver.ApplicationPackageMainSourceChecks
public import Silver.ApplicationPackageNamesSourceChecks
public import Silver.ApplicationPackageSupportSourceChecks
public import Silver.ApplicationPackageCallSourceChecks
public import Silver.ApplicationPackageImportSourceChecks
public import Silver.ApplicationPackageStatementSourceChecks
public import Silver.ApplicationUnitsSourceBridge
public import Silver.OutputSourceBridge

@[expose] public section

/-! The authoritative-source companion of the focused native interface. All
profile readers use the same certified Output_Profile token stream. Imported
source groups retain their own certified implementations and primitive native
interpretations; no accepted-program or semantic-check premise is introduced.
This module belongs in the final stable-source certificate batch. -/
namespace Silver.ApplicationPackageSourceBridge.Actual
open Compose Compose.Expressions ApplicationPackageDeclarations

theorem checked : Checked Source.outputSpecTokens Source.outputBodyTokens
    Source.scalarExpressionSpecTokens Source.packageBindingsSpecTokens where
  admission := ApplicationAdmission.Native.SourceChecks.actual_checked
  object := ObjectSourceChecks.actual_checked
  signature := ReaderSourceChecks.signature_actual_checked
  append := ReaderSourceChecks.append_actual_checked
  specification := ReaderSourceChecks.specification_actual_checked
  bodies := ApplicationPackageBodies.SourceChecks.actual_checked
  main := ApplicationPackageMain.Native.SourceChecks.actual_checked

/-- Unique source extractions accompany the native imported-call composition.
The records below check the original typed statements, callees and guards;
their native library interpretations are supplied to `interpreted` below. -/
structure CheckedSource : Prop where
  specification : Source.lex Source.outputProfileSpec = some Source.outputSpecTokens
  implementation : Source.lex Source.outputProfileBody = some Source.outputBodyTokens
  scalars : Source.lex Source.scalarExpressionSpec = some Source.scalarExpressionSpecTokens
  packages : Source.lex Source.packageBindingsSpec = some Source.packageBindingsSpecTokens
  core : Checked Source.outputSpecTokens Source.outputBodyTokens
    Source.scalarExpressionSpecTokens Source.packageBindingsSpecTokens
  charge : ApplicationAdmission.Charge.SourceChecks.Checked Source.outputBodyTokens
  units : ApplicationUnits.SourceBridge.CheckedSource
  output : Output.SourceBridge.CheckedSource
  names : ApplicationPackageNames.SourceChecks.CheckedSource
  support : ApplicationPackageSupport.SourceChecks.CheckedSource
  imports : ApplicationPackageImport.SourceChecks.CheckedSource
  statements : ApplicationPackageBodies.OriginalStatements.CheckedSource
  callee : ApplicationPackageCalls.Native.CalleeSource.Checked Source.outputBodyTokens
  calls : ApplicationPackageCalls.Native.Call.SourceChecks.Checked Source.outputBodyTokens
  validity : ApplicationPackageCalls.ValidityNative.Checked Source.outputBodyTokens
  boolean : BooleanElaboration.Native.SourceChecks.Checked Source.outputBodyTokens

theorem checked_source : CheckedSource where
  specification := Source.outputSpecTokens_correct
  implementation := Source.outputBodyTokens_correct
  scalars := Source.scalarExpressionSpecTokens_correct
  packages := Source.packageBindingsSpecTokens_correct
  core := checked
  charge := ApplicationAdmission.Charge.SourceChecks.actual_checked
  units := ApplicationUnits.SourceBridge.checked_source
  output := Output.SourceBridge.checked_source
  names := ApplicationPackageNames.SourceChecks.checked_source
  support := ApplicationPackageSupport.SourceChecks.checked_source
  imports := ApplicationPackageImport.SourceChecks.checked_source
  statements := ApplicationPackageBodies.OriginalStatements.checked_source
  callee := ApplicationPackageCalls.Native.CalleeSource.actual_checked
  calls := ApplicationPackageCalls.Native.Call.SourceChecks.actual_checked
  validity := ApplicationPackageCalls.ValidityNative.actual_checked
  boolean := BooleanElaboration.Native.SourceChecks.actual_checked

/-- Supply only native source equations/contracts and the literal import
libraries. The original Charge procedure and every high-level reader obtain
their exact source checks here, from the authoritative certified tokens. -/
def interpreted (completion : ApplicationPackageCompletion.Library)
    (main : ApplicationPackageMain.BodyLibraries)
    (chargeCalls : Compose.Expressions.Calls) (chargeDomain : StateDomain)
    (chargeImports : RawHelperEquations chargeCalls (domain := chargeDomain))
    (units : ApplicationUnits.Native.Calls) (unitSource : ApplicationUnits.InterpretedSource units)
    (outputCalls : Output.Calls) (output : Output.PrimitiveCalls)
    (outputSource : Output.Expressions.PrimitiveInterpretation outputCalls output) :
    InterpretedSource Source.outputSpecTokens Source.outputBodyTokens
      Source.scalarExpressionSpecTokens Source.packageBindingsSpecTokens where
  source := checked
  completion := completion
  main := main
  budget := {
    calls := chargeCalls
    domain := chargeDomain
    imports := chargeImports
    tokens := Source.outputBodyTokens
    source := ApplicationAdmission.Charge.SourceChecks.actual_checked }
  budgetSource := rfl
  units := units
  unitSource := unitSource
  outputCalls := outputCalls
  output := output
  outputSource := outputSource

/-- The exact original wrapper, its checked callees and its imported execution
equation are one result. The full native Bundle domain includes rejected input
and every arbitrary caller scratch store. Semantic assurance is composed later. -/
theorem analysis
    (source : InterpretedSource Source.outputSpecTokens Source.outputBodyTokens
      Source.scalarExpressionSpecTokens Source.packageBindingsSpecTokens)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (represented : (locals .bundle "sources").Representable) :
    CheckedSource ∧
      ApplicationAdmission.Native.analyzeBody.eval
        (ApplicationAdmission.Native.modelCallees (source.calls reader mainOther other)) locals =
        ApplicationAdmission.analyzeApplication (source.model reader mainOther other) (locals .bundle "sources") :=
  ⟨checked_source, source.analysis reader mainOther other locals represented⟩

end Silver.ApplicationPackageSourceBridge.Actual

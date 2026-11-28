module

public import Silver.ApplicationAdmissionSourceShape
public import Silver.ApplicationAdmissionPackageComposition
public import Silver.ApplicationAdmissionChargeBinding
public import Silver.ApplicationPackageDeclarationsReaderSourceRequirements
public import Silver.ApplicationPackageMainSourceShape
public import Silver.ApplicationPackageUnitNativeImports

@[expose] public section

/-! The original application wrapper and its complete procedure/function
callees share one source interpretation. Source extraction remains parameterized
here so focused interface checking does not rebuild the authoritative profile
certificate. The actual-source companion supplies the exact certified tokens.
The interpretation contains native equations/contracts and literal call
libraries, never semantic acceptance, body validity or successful checking. -/
namespace Silver.ApplicationPackageSourceBridge
open Compose Compose.Expressions ApplicationPackageDeclarations ApplicationPackageBodies

structure Checked (specification implementation scalarSpec packageSpec : List String) : Prop where
  admission : ApplicationAdmission.Native.SourceChecks.Checked specification implementation
  object : ObjectSourceChecks.Checked implementation scalarSpec
  signature : ReaderSourceChecks.SignatureChecked implementation packageSpec
  append : ReaderSourceChecks.AppendChecked implementation scalarSpec
  specification : ReaderSourceChecks.SpecificationChecked implementation packageSpec
  bodies : ApplicationPackageBodies.SourceChecks.Checked implementation
  main : ApplicationPackageMain.Native.SourceChecks.Checked implementation

structure InterpretedSource (specification implementation scalarSpec packageSpec : List String) where
  source : Checked specification implementation scalarSpec packageSpec
  completion : ApplicationPackageCompletion.Library
  main : ApplicationPackageMain.BodyLibraries
  budget : ApplicationAdmission.Charge.Library
  budgetSource : budget.tokens = implementation
  units : ApplicationUnits.Native.Calls
  unitSource : ApplicationUnits.InterpretedSource units
  outputCalls : Output.Calls
  output : Output.PrimitiveCalls
  outputSource : Output.Expressions.PrimitiveInterpretation outputCalls output

namespace InterpretedSource
variable {specification implementation scalarSpec packageSpec : List String}

/-- Only source alphabet and budget readers occupy the remaining outer import
slots. Every package parser is installed from the same imported library below. -/
def boundary (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (other : ApplicationAdmission.Calls) : ApplicationAdmission.Calls :=
  {other with allowedSource := source.output.allowed, chargeUnit := source.budget.reader}

noncomputable def calls (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) : ApplicationAdmission.Calls :=
  ApplicationAdmission.packageCalls source.completion reader (source.main.calls mainOther) (source.boundary other)

noncomputable def model (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) : ApplicationAdmission.Calls :=
  ApplicationAdmission.packageCalls source.completion reader (source.main.model mainOther) (source.boundary other)

theorem budget_checked (source : InterpretedSource specification implementation scalarSpec packageSpec) :
    ApplicationAdmission.Charge.SourceChecks.Checked implementation :=
  source.budgetSource ▸ source.budget.source

/-- The declared native Bundle representation is the complete outer domain.
Every rejected branch and arbitrary caller local is preserved by the original
wrapper equation and the original reached-callee domain derivation. -/
theorem analysis (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (represented : (locals .bundle "sources").Representable) :
    ApplicationAdmission.Native.analyzeBody.eval
      (ApplicationAdmission.Native.modelCallees (source.calls reader mainOther other)) locals =
      ApplicationAdmission.analyzeApplication (source.model reader mainOther other) (locals .bundle "sources") :=
  ApplicationAdmission.package_main_native source.completion reader source.main mainOther
    (source.boundary other) locals represented

theorem aliases (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (represented : (locals .bundle "sources").Representable) :
    let functions := ApplicationAdmission.Native.modelFunctions (source.calls reader mainOther other)
    let result := ApplicationAdmission.analyzeApplication (source.model reader mainOther other) (locals .bundle "sources")
    ApplicationAdmission.Native.analyzeModelBody.eval functions locals = result ∧
      ApplicationAdmission.Native.analyzeAliasBody.eval functions locals = result ∧
      ApplicationAdmission.Native.memberBody.eval functions locals = result.accepted ∧
      ApplicationAdmission.Native.acceptsBody.eval functions locals = result.accepted := by
  have same := ApplicationAdmission.package_main_imports source.completion reader source.main mainOther
    (source.boundary other) (locals .bundle "sources") represented
  change ApplicationAdmission.analyzeApplication (source.calls reader mainOther other) (locals .bundle "sources") =
    ApplicationAdmission.analyzeApplication (source.model reader mainOther other) (locals .bundle "sources") at same
  exact ⟨same, same, congrArg ApplicationAdmission.AnalysisResult.accepted same,
    congrArg ApplicationAdmission.AnalysisResult.accepted same⟩

/-- The outer two-output Specification slot is exactly the complete original
procedure execution, including every early rejection and arbitrary backing. -/
theorem specification_call (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) (procedures : ApplicationPackageProcedure.ProcedureCalls)
    (backing : Control.Backing) (prior : ApplicationNative.Locals)
    (text : Source) (valid : ValidText text) (info : PackageBindings.Metadata)
    (returned : ApplicationAdmission.SpecificationResult) :
    SpecificationNative.body.Exec (SpecificationNative.functions (source.completion.objects.specification reader prior))
      {procedures with signature := readSignature} backing (SpecificationNative.inputLocals prior text info)
      (fun store => returned = SpecificationNative.projectResult store) ↔
      returned = (source.calls reader mainOther other).packageSpecification text info :=
  specification_imported_reader_exec source.completion.objects reader procedures backing prior text valid info returned

/-- Object and Signature are the exact imported callees of Specification and
Completion. The native assertion dictionary and inactive formal backing remain
arbitrary; the full source-checked Append contract provides its update. -/
theorem object_call (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (frame : ParserState) (framed : ReaderFrame text frame) (info : PackageBindings.Metadata)
    (localObject : Bool) (prior : ApplicationNative.Locals) :
    ObjectNative.body.eval (source.completion.objects.object reader).get
      (ObjectNative.inputLocals prior text frame info localObject) =
      objectStep (modelObjectCalls reader) text frame info localObject :=
  source.completion.objects.object_meaning reader valid frame framed info localObject prior

theorem signature_call (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (assertions : SignatureNative.Calls) (procedures : ApplicationPackageProcedure.ProcedureCalls)
    (backing : Control.Backing) (prior : ApplicationNative.Locals)
    {text : Source} (valid : ValidText text) (outer : ParserState) (framed : ReaderFrame text outer)
    (info : PackageBindings.Metadata) (completing : Bool) :
    SignatureNative.body.Exec
      ({assertions with base := source.completion.objects.names.signatureValidity modelSignatureCalls} : SignatureNative.Calls).get
      {procedures with appendFormal := appendFormal} backing (SignatureNative.inputLocals prior text outer info completing)
      (fun store => source.completion.signature.call text outer info completing = SignatureNative.projectResult store) :=
  source.completion.signature.native assertions procedures backing prior valid outer framed info completing

theorem completion_call (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (locals : ApplicationNative.Locals)
    (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "globals"))
    (typed : (locals .metadata "info").Typed) :
    (ApplicationPackageCompletion.Native.body.eval
      (ApplicationPackageCompletion.Native.modelFunctions (source.completion.calls reader))
      (ApplicationPackageCompletion.Native.modelProcedures (source.completion.calls reader))
      ((locals .source "text").length + 2) locals).map ApplicationPackageCompletion.Native.observed =
      some (readCompletion reader (ApplicationPackageCompletion.LeafLibraries.model (source.completion.calls reader))
        (locals .source "text") (locals .state "globals") (locals .metadata "info")) :=
  source.completion.completion_native reader locals valid framed typed

/-- The original Unit slot is total on its full native precondition, and keeps
rejected partial metadata. Its scratch locals are never fixed to defaults. -/
theorem unit_call (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (valid : ValidText (locals .source "text"))
    (framed : ReaderFrame (locals .source "text") (locals .state "exports"))
    (typed : (locals .metadata "info").Typed)
    (cursor : ValidCursor (locals .source "text") ((locals .metadata "info").units .packageBody).first) :
    (ApplicationPackageUnit.Native.body.eval
      (ApplicationPackageUnit.Native.modelFunctions (source.completion.unitCalls reader))
      (ApplicationPackageUnit.Native.modelProcedures (source.completion.unitCalls reader))
      ((locals .source "text").length + 2) locals).map ApplicationPackageUnit.Native.observed =
      some ((source.calls reader mainOther other).packageBody
        (locals .source "text") (locals .state "exports") (locals .metadata "info")) :=
  source.completion.body_native reader locals valid framed typed cursor

theorem main_call (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (valid : (locals .bundle "sources").Valid)
    (framed : ReaderFrame (ApplicationPackageMain.textOf (locals .bundle "sources")) (locals .state "exports"))
    (typed : (locals .metadata "info").Typed)
    (complete : PackageBindings.completeMetadata
      (ApplicationPackageNames.metadataText (ApplicationPackageMain.textOf (locals .bundle "sources")))
      (locals .metadata "info") = true) :
    ApplicationPackageMain.Native.mainBody.eval
      (ApplicationPackageMain.Native.modelFunctions (source.main.calls mainOther)) locals =
      (source.model reader mainOther other).packageMain
        (locals .bundle "sources") (locals .state "exports") (locals .metadata "info") :=
  source.main.native_meaning mainOther locals valid framed typed complete

theorem charge_call (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) (text : Source) (valid : ValidText text)
    (remaining : Nat) (prior : Compose.Expressions.Locals) (returned : ApplicationAdmission.ChargeResult) :
    ApplicationAdmission.Charge.body.Exec source.budget.calls
      (ApplicationAdmission.Charge.inputLocals prior text remaining)
      (fun after => returned = ApplicationAdmission.Charge.output after) ↔
      returned = (source.calls reader mainOther other).chargeUnit text remaining :=
  source.budget.executed text valid remaining prior returned

theorem allowed_source (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) (text : Source) :
    (source.calls reader mainOther other).allowedSource text = text.all allowedCharacter :=
  (Output.Expressions.primitive_interpreted_equations source.outputCalls source.output source.outputSource).allowed text

theorem normalization (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (text : Source) (bound : text.length ≤ maxSourceLength) : source.output.normalize text = text :=
  source.outputSource.normalize text bound

/-- Valid_State is a total guard on native component types. No successful frame
predicate is needed to interpret its actual call. -/
theorem state_guard (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (mainOther : ApplicationPackageMain.Calls)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (valid : ValidText (locals .source "text"))
    (typed : ApplicationPackageFrames.ValidityNative.ImportedTypes (locals .state "state")) :
    ApplicationPackageFrames.ValidityNative.validStateBody.eval
      (ApplicationPackageFrames.ValidityNative.importedCalls source.completion.objects.names.validity) locals =
      (source.calls reader mainOther other).stateValid (locals .source "text") (locals .state "state") :=
  ApplicationPackageFrames.ValidityNative.imported_validState source.completion.objects.names.validity locals valid typed

/-- Native bundle storage is the only premise for the initial Valid guard.
Original source slices and prefixes use the stronger guard result, exactly as
in Analyze_Application; lower-bound identities stay explicit. -/
theorem unit_guard (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (sources : ApplicationUnits.Bundle) (represented : sources.Representable) :
    source.units.valid sources = decide sources.Layout := by
  rw [source.unitSource.valid sources represented, ApplicationUnits.validBody_meaning]

theorem unit_slices (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (sources : ApplicationUnits.Bundle) (valid : sources.Valid) (kind : ApplicationUnits.UnitKind) :
    source.units.unitSource sources kind = ⟨(sources.units kind).first, sources.unitSource kind⟩ ∧
      source.units.unitPrefix sources kind = ⟨1, sources.prefix kind⟩ :=
  ⟨ApplicationUnits.interpreted_unitSource source.units source.unitSource sources valid kind,
    ApplicationUnits.interpreted_prefix source.units source.unitSource sources valid kind⟩

theorem complete_guard (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (text : Source) (info : PackageBindings.Metadata) :
    source.completion.objects.names.shared.packages.completeMetadata
      (ApplicationPackageNames.metadataText text) info =
      PackageBindings.completeMetadata (ApplicationPackageNames.metadataText text) info :=
  PackageBindings.Native.interpreted_completeMetadata source.completion.objects.names.shared.packages
    source.completion.objects.names.shared.packagePrimitives source.completion.objects.names.shared.packageEquations
    (ApplicationPackageNames.metadataText text) info

theorem functions_guard (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (text : Source) (valid : ValidText text) (functions : FunctionBindings.Metadata)
    (typed : FunctionBindings.Native.MetadataType functions) :
    source.completion.objects.names.validity.functions.validMetadata text functions =
      decide (FunctionBindings.ValidMetadata text functions) :=
  (FunctionBindings.SourceBridge.interpreted_complete source.completion.objects.names.validity.functions
    source.completion.objects.names.validity.functionSource).validMetadata text valid functions typed

theorem procedures_guard (source : InterpretedSource specification implementation scalarSpec packageSpec)
    (text : Source) (valid : ValidText text) (procedures : ProcedureBindings.Metadata)
    (typed : ProcedureBindings.Native.MetadataType procedures) :
    source.completion.objects.names.validity.procedures.validMetadata text procedures =
      decide (ProcedureBindings.ValidMetadata text procedures) :=
  (ProcedureBindings.SourceBridge.interpreted_complete source.completion.objects.names.validity.procedures
    source.completion.objects.names.validity.procedureSource).validMetadata text valid procedures typed

end InterpretedSource
end Silver.ApplicationPackageSourceBridge

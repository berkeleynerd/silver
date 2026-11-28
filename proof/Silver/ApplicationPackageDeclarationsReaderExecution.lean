module

public import Silver.ApplicationPackageDeclarationsExecution
public import Silver.ApplicationPackageDeclarationsSignatureSimulation
public import Silver.ApplicationPackageDeclarationsSpecificationSimulation

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose ApplicationNative Control ApplicationPackageProcedure

/-- With the canonical declaration readers at each call site, the originally
typed Signature computes the total recursive result. The assertion dictionaries
and every caller-supplied inactive backing cell are arbitrary. -/
theorem signature_reader_exec (assertions : SignatureNative.Calls) (procedures : ProcedureCalls) (backing : Backing)
    (prior : Locals) (source : Source) (outer : ParserState) (info : PackageBindings.Metadata) (completing : Bool)
    (result : SignatureResult) :
    SignatureNative.body.Exec ({assertions with base := modelSignatureCalls} : SignatureNative.Calls).get
      {procedures with appendFormal := appendFormal} backing (SignatureNative.inputLocals prior source outer info completing)
      (fun store => result = SignatureNative.projectResult store) ↔ result = readSignature source outer info completing := by
  rw [SignatureNative.exec_iff]
  change SignatureExec modelSignatureCalls source outer info completing result ↔ _
  constructor
  · intro run
    exact run.unique (readSignature_exec source outer info completing)
  · rintro rfl
    exact readSignature_exec source outer info completing

/-- The originally typed Specification uses the total Signature at its routine
branch and computes the complete recursive Specification output on every input. -/
theorem specification_reader_exec (reader : BooleanElaboration.Native.Reader) (procedures : ProcedureCalls) (backing : Backing)
    (prior : Locals) (source : Source) (info : PackageBindings.Metadata) (result : SpecificationResult) :
    SpecificationNative.body.Exec (SpecificationNative.functions (modelSpecificationCalls reader))
      {procedures with signature := readSignature} backing (SpecificationNative.inputLocals prior source info)
      (fun store => result = SpecificationNative.projectResult store) ↔ result = readSpecification reader source info := by
  rw [SpecificationNative.exec_iff]
  change SpecificationExec (modelSpecificationCalls reader) source info result ↔ _
  constructor
  · intro run
    exact run.unique (readSpecification_exec reader source info)
  · rintro rfl
    exact readSpecification_exec reader source info

end Silver.ApplicationPackageDeclarations

module

public import Silver.ApplicationPackageDeclarationsSignatureLoopImports
public import Silver.ApplicationPackageDeclarationsReaderExecution

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationNative Control ApplicationPackageProcedure

/-- The complete typed Signature body uses the interpreted imported readers.
Append_Package_Formal is projected through its separately checked whole-frame
native contract; assertion dictionaries and inactive backing storage are arbitrary. -/
theorem signature_imported_reader_exec (library : NameLibraries)
    (assertions : SignatureNative.Calls) (procedures : ProcedureCalls) (backing : Backing)
    (prior : ApplicationNative.Locals) (source : Source) (valid : ValidText source)
    (outer : ParserState) (framed : ReaderFrame source outer)
    (info : PackageBindings.Metadata) (completing : Bool) (result : SignatureResult) :
    SignatureNative.body.Exec
      ({assertions with base := library.signatureValidity modelSignatureCalls} : SignatureNative.Calls).get
      {procedures with appendFormal := appendFormal} backing
      (SignatureNative.inputLocals prior source outer info completing)
      (fun store => result = SignatureNative.projectResult store) ↔
      result = readSignature source outer info completing := by
  rw [SignatureNative.exec_iff]
  exact library.signature_exec_iff valid outer framed info completing result

end Silver.ApplicationPackageDeclarations

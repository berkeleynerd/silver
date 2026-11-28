module

public import Silver.ApplicationPackageImportedFrame
public import Silver.ApplicationStateValidityImports

@[expose] public section

namespace Silver.ApplicationPackageFrames.Native
open ApplicationNative Compose

/-- Bind the executable validity aggregate; other callees remain arbitrary.
Imported_Frame invokes only this aggregate after its three qualification loops. -/
def withStateValidity (imports : ValidityNative.Imports) (other : Calls Function) : Calls Function
  | _, .validState => fun text state => ValidityNative.validStateBody.eval
      (ValidityNative.importedCalls imports) (ValidityNative.tableLocals text .state "state" state)
  | _, fn => other _ fn

theorem withStateValidity_meaning (imports : ValidityNative.Imports) (other : Calls Function)
    (text : Source) (valid : Compose.Expressions.ValidText text) (state : ParserState)
    (typed : ValidityNative.ImportedTypes state) :
    withStateValidity imports other _ .validState text state = stateValid text state := by
  exact ValidityNative.imported_validState imports
    (ValidityNative.tableLocals text .state "state" state) valid typed

/-- Qualification changes no imported function/procedure/array representation.
The exact native field-type bounds therefore suffice at the final validity call. -/
theorem importedFrameRaw_types (exports : ParserState) (info : PackageBindings.Metadata)
    (position : Nat) (typed : ValidityNative.ImportedTypes exports) :
    ValidityNative.ImportedTypes (importedFrameRaw exports info position) :=
  ⟨typed.functions, typed.procedures, typed.arrays⟩

theorem importedFrame_imports (imports : ValidityNative.Imports) (other : Calls Function)
    (locals : Locals) (valid : Compose.Expressions.ValidText (locals .source "text"))
    (typed : ValidityNative.ImportedTypes (locals .state "exports")) :
    importedFrameBody.eval (withStateValidity imports other) locals =
      importedFrame (locals .source "text") (locals .state "exports")
        (locals .metadata "info") (locals .number "position") := by
  rw [importedFrame_denotation]
  unfold importedEquation importedFrame
  dsimp only
  rw [withStateValidity_meaning imports other _ valid _
    (importedFrameRaw_types (locals .state "exports") (locals .metadata "info")
      (locals .number "position") typed)]

end Silver.ApplicationPackageFrames.Native

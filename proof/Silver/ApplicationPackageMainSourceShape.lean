module

public import Silver.ApplicationPackageMainEquations
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Exact-source requirements for the Main reader, including its complete native
precondition. Final integration checks these requirements against the current
authoritative Output_Profile reconstruction and binds the reader callees. -/
namespace Silver.ApplicationPackageMain.Native.SourceChecks
open Silver.SourceBridge

def mainHeader : List String := expectedTokens
  "(Sources : Units.Bundle; Exports : Parser_State; Info : Packages.Metadata) return Analysis_Result with Global => null, Pre => Units.Valid (Sources) and then Valid_State (Sources.Pool (1 .. Sources.Used), Exports) and then Packages.Complete_Metadata (Sources.Pool (1 .. Sources.Used), Info)"

structure Checked (implementation : List String) : Prop where
  tree : CheckedTree
  header : functionHeader "package_main_at" "is" implementation = some mainHeader
  body : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "package_main_at" implementation = some mainBody.render

structure Meaning (implementation : List String) (calls : ApplicationPackageMain.Calls) : Prop where
  source : Checked implementation
  evaluation : ∀ locals : ApplicationNative.Locals,
    mainBody.eval (modelFunctions calls) locals =
      packageMainAt calls (locals .bundle "sources") (locals .state "exports") (locals .metadata "info")

theorem checked_meaning {implementation : List String} (source : Checked implementation)
    (calls : ApplicationPackageMain.Calls) : Meaning implementation calls :=
  ⟨source, mainBody_meaning calls⟩

end Silver.ApplicationPackageMain.Native.SourceChecks

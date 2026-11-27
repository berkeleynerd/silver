module

public import Silver.ApplicationPackageBodiesStatementNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.SourceChecks
open SourceBridge

def implementationHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Input : Application_Scan; Info : Packages.Metadata; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Application_Scan"

def specificationHeader : List String := implementationHeader ++
  expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length" ++
  expectedTokens "and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Input.Scan)" ++
  expectedTokens "and then Functions.Valid_Metadata (Text, Catalog) and then Procedures.Valid_Metadata (Text, Procedure_Catalog)" ++
  expectedTokens ", Post => Application_Statement'Result.Count = Input.Count" ++
  expectedTokens "and then Application_Statement'Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls" ++
  expectedTokens "and then Valid_Body (Text, Context, Application_Statement'Result.Scan)" ++
  expectedTokens "and then (Application_Statement'Result.Scan.Position = 0" ++
  expectedTokens "or else Application_Statement'Result.Scan.Position > Input.Scan.Position)" ++
  expectedTokens ", Subprogram_Variant => (Decreases => (Text'Last + 1) - Input.Scan.Position," ++
  expectedTokens "Decreases => 1)"

structure Checked (tokens : List String) : Prop where
  tree : Native.body.checked Native.names Native.parameters Native.scope = true
  specification : functionHeader "application_statement" ";" tokens = some specificationHeader
  implementation : functionHeader "application_statement" "is" tokens = some implementationHeader
  body : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "application_statement" tokens =
    some (Native.body.render Native.names)

end Silver.ApplicationPackageBodies.Statement.SourceChecks

module

public import Silver.ApplicationPackageBodiesBasicNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

namespace Silver.ApplicationPackageBodies.Basic.SourceChecks
open SourceBridge

def header : List String := expectedTokens
  "(Text : String; Context : Body_Context; Input : Application_Scan; Info : Packages.Metadata; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Application_Scan with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Input.Scan) and then Functions.Valid_Metadata (Text, Catalog) and then Procedures.Valid_Metadata (Text, Procedure_Catalog), Post => Application_Basic'Result.Count = Input.Count and then Application_Basic'Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls and then Valid_Body (Text, Context, Application_Basic'Result.Scan) and then (Application_Basic'Result.Scan.Position = 0 or else Application_Basic'Result.Scan.Position > Input.Scan.Position)"

structure Checked (tokens : List String) : Prop where
  tree : CheckedTree
  header : functionHeader "application_basic" "is" tokens = some header
  body : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "application_basic" tokens =
    some (Basic.body.render names)

end Silver.ApplicationPackageBodies.Basic.SourceChecks

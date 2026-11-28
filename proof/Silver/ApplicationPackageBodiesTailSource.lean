module

public import Silver.ApplicationPackageBodiesTailNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

namespace Silver.ApplicationPackageBodies.Tail.SourceChecks
open SourceBridge

def header : List String := expectedTokens
  "(Text : String; Context : Body_Context; Input : Application_Scan; Info : Packages.Metadata; Stop : Body_Stop; Require_One : Boolean; Catalog : Functions.Metadata; Procedure_Catalog : Procedures.Metadata) return Application_Scan with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Input.Scan) and then Functions.Valid_Metadata (Text, Catalog) and then Procedures.Valid_Metadata (Text, Procedure_Catalog), Post => Application_Tail'Result.Count = Input.Count and then Application_Tail'Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls and then Valid_Body (Text, Context, Application_Tail'Result.Scan) and then (Application_Tail'Result.Scan.Position = 0 or else Application_Tail'Result.Scan.Position >= Input.Scan.Position), Subprogram_Variant => (Decreases => (Text'Last + 1) - Input.Scan.Position, Decreases => 2)"

structure Checked (tokens : List String) : Prop where
  tree : Tail.body.checked names parameters scope = true
  header : functionHeader "application_tail" "is" tokens = some header
  body : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction "application_tail" tokens =
    some (Tail.body.render names)

end Silver.ApplicationPackageBodies.Tail.SourceChecks

module

public import Silver.ApplicationPackageCallsNative
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section

/-! Complete native declarations and executable source tree requirements for
Package_Call_At. The native Count discriminants and full failure/unused actual
storage are explicit. A Checked witness must use the authoritative source. -/
namespace Silver.ApplicationPackageCalls.Native.Call.SourceChecks
open SourceBridge ApplicationNative

def header : List String := expectedTokens
  "(Text : String; Context : Body_Context; Input : Application_Scan; Info : Packages.Metadata; Position : Literal_Position; Kind : Packages.Routine_Kind) return Application_Call with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Input.Scan) and then Position <= Text'Last + 1, Post => Package_Call_At'Result.Count = Input.Count and then Package_Call_At'Result.Result.Allow_Procedure_Calls = Input.Allow_Procedure_Calls and then Valid_Body (Text, Context, Package_Call_At'Result.Result.Scan) and then (Package_Call_At'Result.Value.After = 0 or else Package_Call_At'Result.Value.After in Position + 1 .. Text'Last + 1)"

structure Checked (tokens : List String) : Prop where
  actualRecord : Lexical.SourceBridge.recordDeclaration "package_actual" tokens = some
    (expectedTokens "record First, After : Literal_Position := 0; Target : Procedure_Actual_Result := Invalid_Procedure_Actual; Reads : Packages.State_Set := Packages.Empty_State_Set; Written_State : Packages.State_Id := 0; end record")
  actualArray : SourceBridge.typeDeclaration "package_actual_array" tokens = some
    (expectedTokens "array (Packages.Formal_Index) of Package_Actual")
  seenArray : SourceBridge.typeDeclaration "package_seen_array" tokens = some
    (expectedTokens "array (Packages.Formal_Index) of Boolean")
  callRecord : Lexical.SourceBridge.discriminatedRecordDeclaration "application_call" tokens = some
    (expectedTokens "(Count : Scalar_Expressions.Binding_Count) is record Value : Call_Result := Invalid_Call; Result : Application_Scan (Count); end record")
  completeHeader : functionHeader "package_call_at" "is" tokens = some header
  completeBody : Compose.BooleanDeclarationNative.SourceChecks.ordinaryFunction
    "package_call_at" tokens = some (callBody.render functionNames)

end Silver.ApplicationPackageCalls.Native.Call.SourceChecks

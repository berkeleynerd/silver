module

public import Silver.FunctionDeclarationSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose
open Silver.Compose.FunctionDeclarationNative.SourceChecks

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem declaration_typeResult :
    Silver.Lexical.SourceBridge.recordDeclaration "function_type_result" Output.SourceShape.outputImplementation =
    some (expectedTokens "record After : Literal_Position; Kind : Functions.Scalar_Kind; Bounds : Scalars.Interval; Type_Id : Array_Bindings.Type_Count := 0; end record") := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts

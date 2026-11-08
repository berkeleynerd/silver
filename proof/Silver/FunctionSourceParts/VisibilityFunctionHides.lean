module

public import Silver.FunctionVisibilitySource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Compose.FunctionVisibilityNative
open Silver.Compose.FunctionVisibilityNative.SourceChecks

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.FunctionSourceCandidate.Parts

theorem visibility_functionHides :
    expressionDeclaration "function_hides" Output.SourceShape.outputImplementation =
    some (functionHidesBody.render, expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Functions.Valid_Metadata (Text, Catalog) and then Word'First = 1 and then Word'Length in 1 .. Max_Source_Length") := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts

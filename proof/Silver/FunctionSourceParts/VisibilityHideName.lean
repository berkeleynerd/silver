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

theorem visibility_hideName :
    expressionDeclaration "hide_name" Output.SourceShape.outputImplementation =
    some (renderMarks hideNameField, expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then First > 0 and then After > First and then After <= Text'Last + 1") := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts

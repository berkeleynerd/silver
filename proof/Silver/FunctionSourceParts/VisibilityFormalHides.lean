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

theorem visibility_formalHides :
    expressionDeclaration "formal_hides" Output.SourceShape.outputImplementation =
    some (formalHidesBody.render, expectedTokens "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State) and then First <= Text'Last + 1 and then After <= Text'Last + 1") := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts

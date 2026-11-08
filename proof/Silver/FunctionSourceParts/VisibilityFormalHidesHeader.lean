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

theorem visibility_formalHidesHeader :
    functionHeader "formal_hides" "is" Output.SourceShape.outputImplementation =
    some (expectedTokens "(Text : String; State : Parser_State; First, After : Literal_Position) return Boolean") := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts

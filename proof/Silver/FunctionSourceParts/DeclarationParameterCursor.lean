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

theorem declaration_parameterCursor :
    Silver.Lexical.SourceBridge.subtypeDeclaration "parameter_cursor" Output.SourceShape.outputImplementation =
    some (expectedTokens "Positive range 1 .. Functions.Max_Formals + 1") := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts

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

theorem declaration_stepResult :
    Silver.Lexical.SourceBridge.recordDeclaration "parameter_step_result" Output.SourceShape.outputImplementation =
    some (expectedTokens "record State : Parser_State; Closed : Boolean; end record") := by
  decide +kernel

end Silver.FunctionSourceCandidate.Parts

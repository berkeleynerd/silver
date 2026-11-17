module

public import Silver.ProcedureNameSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.ProcedureNameNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ProcedureNameSourceCandidate.Parts

theorem record :
    Silver.Lexical.SourceBridge.recordDeclaration "name_scan_step" Output.SourceShape.outputImplementation =
      some (expectedTokens "record Next : Literal_Position; Free : Boolean; end record") := by
  decide +kernel

end Silver.ProcedureNameSourceCandidate.Parts


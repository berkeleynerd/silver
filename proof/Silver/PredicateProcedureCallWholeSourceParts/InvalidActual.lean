module

public import Silver.PredicateProcedureCallSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.ProcedureCallNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.PredicateProcedureCallWholeSourceCandidate.Parts

theorem invalidActual : Source.declaration "invalid_procedure_actual" Output.SourceShape.outputImplementation =
    some (["constant", "procedure_actual_result", ":=", "(", "0", ",", "0", ",", "0", ",", "0", ")"]) := by
  decide +kernel

end Silver.PredicateProcedureCallWholeSourceCandidate.Parts

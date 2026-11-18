module

public import Silver.PredicateAssociationSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.AssociationNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.PredicateAssociationWholeSourceCandidate.Parts

theorem headers_10 :
    let item := SourceChecks.headers.get ⟨10, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem headers_11 :
    let item := SourceChecks.headers.get ⟨11, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem expressions_3 :
    let item := SourceChecks.expressions.get ⟨3, by decide⟩
    expressionDeclaration item.1 Output.SourceShape.outputImplementation = some (item.2.1, item.2.2) := by
  decide +kernel

end Silver.PredicateAssociationWholeSourceCandidate.Parts

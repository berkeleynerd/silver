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

theorem headers_8 :
    let item := SourceChecks.headers.get ⟨8, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem headers_9 :
    let item := SourceChecks.headers.get ⟨9, by decide⟩
    functionHeader item.1 item.2.1 Output.SourceShape.outputImplementation = some item.2.2 := by
  decide +kernel

theorem expressions_2 :
    let item := SourceChecks.expressions.get ⟨2, by decide⟩
    expressionDeclaration item.1 Output.SourceShape.outputImplementation = some (item.2.1, item.2.2) := by
  decide +kernel

end Silver.PredicateAssociationWholeSourceCandidate.Parts

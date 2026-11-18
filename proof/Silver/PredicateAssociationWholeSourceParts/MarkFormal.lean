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

theorem mark_formal_spec :
    functionHeader "mark_formal" ";" Output.SourceShape.outputImplementation =
      some SourceChecks.markFormalSpec := by decide +kernel

theorem mark_formal_impl :
    functionHeader "mark_formal" "is" Output.SourceShape.outputImplementation =
      some SourceChecks.markFormalImpl := by decide +kernel

theorem mark_formal_body :
    (Source.expressionBody "mark_formal" Output.SourceShape.outputImplementation).map
      (fun body => ["("] ++ body ++ [")"]) = some markFormalBody.render := by decide +kernel

end Silver.PredicateAssociationWholeSourceCandidate.Parts
